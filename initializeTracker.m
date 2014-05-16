%%% initializeTracker
%%%
%%%
%%%

function [pointTracker, flag] = initializeTracker(frame, refFeat, handles)

%frame = getsnapshot(video);

imshow(frame, 'Parent', handles.axes2);

imgBW = rgb2gray(frame);

% Detects the SURF-features in the cam image
camPts = detectSURFFeatures(imgBW);
camPts = camPts.selectStrongest(100);

% Show a frame with all the feature pts
frameOut = insertMarker(frame, camPts.Location, '+', 'Size', 7, ...
                            'Color', 'yellow');
imshow(frameOut, 'Parent', handles.axes2);

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
    
    disp('Tracker created and initialized.');
    flag = true;
    
% If there are no matching pts, the camera object is stoped
else
    
    flag = false;
    
    error('No matching points! Tracker not initialized!');

end