%%% newTrackTarget
%%%
%%%
%%%

function newTrackTarget()%video, refFeat)

%%%%% For testing %%%%%
video = videoinput('macvideo', 1);
triggerconfig(video,'manual');
set(video, 'ReturnedColorSpace', 'rgb');
video.FramesPerTrigger = Inf;
video.TriggerRepeat = 1;

refImg = getsnapshot(video);%imread('Images/img3.jpg');
figure(1);
imshow(refImg);
objReg = round(getPosition(imrect));
refImgBW = rgb2gray(refImg);
objImg   = imcrop(refImg, objReg);
objImgBW = imcrop(refImgBW, objReg);

objPts = detectSURFFeatures(objImgBW);
objPts = objPts.selectStrongest(200);

[refFeat, validPts] = extractFeatures(refImgBW, objPts, 'Method', 'SURF');

start(video);

% % % % % % % % % % % % 

    frame = getsnapshot(video);
    
    figure(1);
    imshow(frame);
    
    if (size(frame, 3) == 1)
        imgBW = frame;
    else
        imgBW = rgb2gray(frame);
    end

    % Detects the SURF-features in the cam image
    camPts = detectSURFFeatures(imgBW);
    camPts = camPts.selectStrongest(100);

    % Extracts the features around the pts in the image
    camFeat = extractFeatures(imgBW, camPts);

    % Get the points with matching features in cam image and the object
    idxPairs = matchFeatures(camFeat, refFeat);

    % Get the matching points in the cam- and ref image respectivly
    matchedCamPts = camPts(idxPairs(:, 1));
    %matchedRefPts = refPts(idxPairs(:, 2));
    
    disp('matchedCamPts: ');
    size(matchedCamPts)
    
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
        %oldPts = points;
        flag = true;
        disp('Tracker created and initialized.');
    % If there are no matching pts, the camera object is stoped
    else
        disp('No matching points!');
        if isrunning(video)
            disp('Stoping video.');
            stop(video);
        end
        close(figure(1));
        flag = false;
    end

% If there are matching pts (flag high) the tracking-loop is started
disp('@loop');
idx = 0;
while flag
    idx = idx + 1;
    
    frame = getsnapshot(video);
    
    [points, isFound] = step(pointTracker, frame);
    
    visiblePts = points(isFound, :);
    
    % Only if there are more than two visable pts
    if size(visiblePts, 1) >= 2
        %{
        % Estimate the geometric trans between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePts] = estimateGeometricTransform( ...
            oldInliers, visiblePts, 'similarity', 'MaxDistance', 4);
        
        % If annotating bbox is to be a polynom, so that it can rotate
        
        % Apply the transformation to the bounding box
        [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] = ...
            transformPointsForward(xform, bboxPolygon(1:2:end), ...
                                          bboxPolygon(2:2:end));
            
        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);
         %}
        
        % Annotated the visable pts in the frame
        frame = insertMarker(frame, visiblePts, 'X', 'Size', 10, ...
                                'Color', 'yellow');
        
        % Reset the points (and the pointTracker)
        %oldPts = visiblePts;
        %setPoints(pointTracker, oldPts);
    else
        % If 'all' pts are lost: end loop
        disp('Less than two points!'); 
        flag = false;
    end
    
    % Display the annotated video frame using the video player object
    figure(1);
    imshow(frame);%, 'Parent', handles.axes2);
    
    flushdata(video);%, 'triggers');
    
    %guidata(hObject, handles);
end
close(figure(1));
disp('Loop ended.');
disp({'No. of frames: ' num2str(idx)});

stop(video);
delete(video);

% Clean
if exist('pointTracker')
    release(pointTracker);
    delete(pointTracker);
    disp('Released and deleted.');
end

clear points isFound visablePts; 

disp('End trackTarget.');