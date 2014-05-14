%%% learnObject
%%% Input:  The "whole" img, GRAY. The object region to learn
%%% Output: the croped img, the feature pts. and the features. 
%%% 

function [objImg, objPts, objFeat] = learnObject(image, objReg, handles)

if (size(image, 3) == 1)
    % Already gray?
    imBW = image;
else
    %disp('Convert to gray!');
    imBW = rgb2gray(image); % Fulhaxx; vad om varken rgb eller gray?
    %image = histeq(image);
end

objImg   = imcrop(image, objReg);
objImgBW = imcrop(imBW, objReg);

objPts = detectSURFFeatures(objImgBW);
%objPts = objPts.selectStrongest(200);
ptsImg = insertMarker(objImg, objPts.Location, 'x', 'Color', 'green');

%objPts = detectMinEigenFeatures(objImg);
%objPts = objPts.selectStrongest(200);
%ptsImg = insertMarker(objImg, objPts.Location, 'x', 'Color', 'green');

%figure(1);
imshow(ptsImg, 'Parent', handles.axes1);

objFeat = extractFeatures(objImgBW, objPts);

%size(objFeat);

