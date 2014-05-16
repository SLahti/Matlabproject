%%% highlightObject
%%% Input: Image to mark object in
%%% Output: The marked region
%%%

function [region] = markObject(image, handles)
disp('1');
axes(handles.axes1);
disp('2');
imshow(image, 'Parent', handles.axes1);
disp('3');
region = round(getPosition(imrect));
disp('4');
higImg = insertShape(image, 'FilledRectangle', ...
                     region, 'Color', 'cyan', 'Opacity', 0.2);
disp('5');
imshow(higImg, 'Parent', handles.axes1);
disp('6');
set(handles.learnObject,'Value',1,'Enable','On');
disp('7');