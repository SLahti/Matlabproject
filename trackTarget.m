%%% trackObject
%%%
%%%
%%%

function trackTarget(video, refFeat, handles)

if isvalid(handles.video) && ~isrunning(handles.video)
    disp('video not running. Starting video...');
    start(handles.video);
end
disp('handles.video started.');

% When toggle button is set to 'high'
if isvalid(handles.video) && ~get(hObject,'Value')
     
    % Get (and edit) the cam image
    disp('Get cam image...'); 
    %camImg = getdata(handles.video, 1, 'uint8');
    frame = getsnapshot(handles.video);
    disp('camImg acquired!');
    
    % Check if/convert to gray
    if (size(frame, 3) == 1)
        imgBW = image;
    else
        imgBW = rgb2gray(frame); % Fulhaxx; vad om varken rgb eller gray?
    end
    
    %camImg = im2bw(camImg);
    %camImg = histeq(camImg);

    % Detects the SURF-features in the cam image
    camPts = detectSURFFeatures(imgBW);
    camPts = camPts.selectStrongest(100);

    % Extracts the features around the pts in the image
    camFeat = extractFeatures(imgBW, camPts);
    disp('camFeat: ');
    size(camFeat)
    disp('handles.objFeat: ');
    size(handles.objFeat.Features)

    % Get the points with matching features in cam image and the object
    idxPairs = matchFeatures(camFeat, handles.objFeat.Features);

    % Get the matching points in the cam- and ref image respectivly
    matchedCamPts = camPts(idxPairs(:, 1));
    %matchedRefPts = refPts(idxPairs(:, 2));
    
    % If there are matching pts is the tracker created and initialized
    if ~isempty(matchedCamPts)
        disp('Found matching points.');
        % Create a point tracker 
        pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
        % Init. the tracker with the init. pts locations and video frame.
        points = matchedCamPts.Location;
        initialize(pointTracker, points, frame);
        % Make a copy of the pts to be used for computing the geometric
        % trans between the pts in the prev and the current frames
        oldPts = points;
        flag = true;
        disp('Tracker created and initialized.');
    % If there are no matching pts, the camera object is stoped
    else
        disp('No matching points!');
        if isrunning(handles.video)
            disp('Stoping video.');
            stop(handles.video);
        end
        flag = false;
    end
    
% When toggle button is set to 'low', the object is stoped
else
    disp('Invalid video object!');
    disp('Stop video object!');
    if isvalid(handles.video) && isrunning(handles.video)
        disp('Stoping video.');
        stop(handles.video);
    end
    flag = false;
end

% If there are matching pts (flag high) the tracking-loop is started
disp('@loop');
while get(hObject,'Value') && flag
    
    % Get a new frame. 'getdata()' is suposed to be faster. 
    % Object must be started and 'TriggerRepeat = Inf;'. 
    frame = getsnapshot(handles.video);
    %frame = getdata(handles.video, 1, 'uint8');
    
    % Track the points with the tracker on each frame. 
    % "Note that some points may be lost." 
    [points, isFound] = step(pointTracker, frame);
    % Gets the found points
    visiblePts = points(isFound, :);
    % Saves the old pts which still are found
    %oldInliers = oldPts(isFound, :);
    
    % Only if there are more than two visable pts
    if size(visiblePts, 1) >= 2
        %{
        % Estimate the geometric trans between the old points
        % and the new points and eliminate outliers
     %   [xform, oldInliers, visiblePts] = estimateGeometricTransform( ...
      %      oldInliers, visiblePts, 'similarity', 'MaxDistance', 4);
        
        % If annotating bbox is to be a polynom, so that it can rotate
        
        % Apply the transformation to the bounding box
        [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] = ...
            transformPointsForward(xform, bboxPolygon(1:2:end), ...
                                          bboxPolygon(2:2:end));
            
        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);
         %}
        
        % Annotated the visable pts in the frame
        imageOut = insertMarker(frame, visiblePts, 'X', 'Size', 6, ...
                                'Color', 'green');
        
        % Reset the points (and the pointTracker)
        %oldPts = visiblePts;
        %setPoints(pointTracker, oldPts);
    else
        % If 'all' pts are lost: end loop
        disp('Less than two points!'); 
        flag = false;
    end
    
    % Display the annotated video frame using the video player object
    imshow(imageOut, 'Parent', handles.axes2);
    
    flushdata(handles.video);%, 'triggers');
    
    guidata(hObject, handles);
end

% Clean
if exist('pointTracker')
    release(pointTracker);
    delete(pointTracker);
    disp('Released and deleted.');
end

clear points isFound visablePts; 

disp('End trackTarget.');
