%%% highlightObject
%%% Input: Image to mark object in
%%% Output: The marked region
%%%

function [objReg] = highlightObject(image, handles)

axes(handles.axes1);
imshow(image, 'Parent', handles.axes1);
objReg = round(getPosition(imrect));

higImg = insertShape(image, 'Rectangle', objReg, 'Color', 'red');

imshow(higImg, 'Parent', handles.axes1);