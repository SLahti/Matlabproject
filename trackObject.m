%%%
%%%
%%%
%%%

function trackObject(cam, points, tarImg)

% Create a point tracker and enable the bidirectional error constraint to
% make it more robust in the presence of noise and clutter.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Initialize the tracker with the initial point locations and the initial
% video frame.
points = points.Location;
initialize(pointTracker, points, tarImg);

% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames
oldPts = points;

index = 0;
while index <= 300
    
    frame = getsnapshot(cam);
    
    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, frame);
    visiblePts = points(isFound, :);
    oldInliers = oldPts(isFound, :);
    
    if size(visiblePts, 1) >= 2 % need at least 2 points

        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePts] = estimateGeometricTransform( ...
            oldInliers, visiblePts, 'similarity', 'MaxDistance', 4);

        % Apply the transformation to the bounding box
        [bboxPolygon(1:2:end), bboxPolygon(2:2:end)] = ...
            transformPointsForward(xform, bboxPolygon(1:2:end), ...
                                          bboxPolygon(2:2:end));

        % Insert a bounding box around the object being tracked
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon);

        % Display tracked points
        videoFrame = insertMarker(videoFrame, visiblePts, '+', ...
            'Color', 'white');

        % Reset the points
        oldPts = visiblePts;
        setPoints(pointTracker, oldPts);
    end

    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
    index = index + 1;
end