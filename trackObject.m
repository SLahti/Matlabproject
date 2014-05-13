%%%
%%%
%%%
%%%

function trackObject(cam, refFeat)%, tarImg)

start(cam);

%%% FROM ObjectFInder_1
% Get camImg
camImg = getsnapshot(cam);
camImg = rgb2gray(camImg);
%camImg = im2bw(camImg);
%camImg = histeq(camImg);

camPts  = detectSURFFeatures(camImg);
%camPts = camPts.selectStrongest(200);

camFeat = extractFeatures(camImg, camPts);

idxPairs = matchFeatures(camFeat, refFeat);

matchedCamPts = camPts(idxPairs(:, 1));
%matchedRefPts = refPts(idxPairs(:, 2));

%%% FROM ex.m (taken example of pointTracker in VideoPlayer)
% Create a point tracker 
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

<<<<<<< HEAD
% Initialize the tracker with the initial point locations and video frame.
points = matchedCamPts.Location;
initialize(pointTracker, points, camImg);
=======
% Initialize the tracker with the initial point locations and the initial
% video frame.
points = points.Location;
initialize(pointTracker, points, tarImg);
>>>>>>> Sebastian

% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames
oldPts = points;

%index = 0;
while get(hObject,'Value')
    
    frame = getsnapshot(cam);
    frame = rgb2gray(frame);
    
    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, frame);
    visiblePts = points(isFound, :);
    oldInliers = oldPts(isFound, :);
    
    if size(visiblePts, 1) >= 2 % need at least 2 points

        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePts] = estimateGeometricTransform( ...
            oldInliers, visiblePts, 'similarity', 'MaxDistance', 4);
        
        %{
        % Apply the transformation to the bounding box
        [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] = ...
            transformPointsForward(xform, bboxPolygon(1:2:end), ...
                                          bboxPolygon(2:2:end));
            
        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);
         %}
            
        % Display tracked points
        frame = insertMarker(frame, visiblePts, '+', ...
            'Color', 'white');

        % Reset the points
        oldPts = visiblePts;
        setPoints(pointTracker, oldPts);
    end

    % Display the annotated video frame using the video player object
    figure(1);
    imshow(frame);
    %index = index + 1;
end
stop(cam);
