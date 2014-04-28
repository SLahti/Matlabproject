%%%
%%%
%%%

function startTracking(runFlag, cam, faceDetector)

disp('startTracking...');

if runFlag
    
    
    frame = getsnapshot(cam);
    disp('Detecting face...');
    bbox = step(faceDetector, frame);
    disp(bbox);
   
    hueTracker = vision.HistogramBasedTracker;
    faceImage = imcrop(frame, bbox);
    % Get hue channel
    [hueChannel, ~, ~] = rgb2hsv(faceImage);
    % Initialize tracker
    initializeObject(hueTracker, hueChannel, bbox);

    % Track the face
    while runFlag
       % Extract the next video frame
        frame = getsnapshot(cam);
        % RGB -> HSV
        [hueChannel,~,~] = rgb2hsv(frame);

        % Track using the Hue channel data
        bbox = step(hueTracker, hueChannel);

        % Insert a bounding box around the object being tracked
        frameOut = insertObjectAnnotation(frame,'rectangle',bbox,'Face');

        % Display the annotated video frame using the video player object
        imshow(frameOut);
    end
end