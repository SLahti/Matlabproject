%%% trackingLoop
%%% Input:  A pointtracker object, initiated and ready and  a run-flag
%%% Output: Non. Displays the points in the frames
%%% 

function trackingLoop(tracker, flag, handles)

while flag

    frame  = getsnapshot(handles.video);

    [points, isFound] = step(tracker, frame);
    visiblePts = points(isFound, :);

    % Only if there are more than two visable pts
    %if size(visiblePts, 1) >= 2
    % Annotated the visable pts in the frame
    frameOut = insertMarker(frame, visiblePts, 'X', 'Size', 10, ...
                             'Color', 'green');
                         
    imshow(frameOut, 'Parent', handles.axes2);
    
    flushdata(handles.video);
end