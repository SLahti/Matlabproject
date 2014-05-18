%%% highlightObject
%%% Input: Image to mark object in
%%% Output: The marked region
%%%

function [region] = markObject(image, handles)
axes(handles.axes1);
imshow(image, 'Parent', handles.axes1);
region = round(getPosition(imrect));
higImg = insertShape(image, 'FilledRectangle', ...
                     region, 'Color', 'cyan', 'Opacity', 0.2);
imshow(higImg, 'Parent', handles.axes1);
set(handles.learnObject,'Value',1,'Enable','On');