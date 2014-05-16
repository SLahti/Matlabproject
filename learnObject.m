%%% learnObject
%%% Input:  The "whole" img, GRAY. The object region to learn
%%% Output: the croped img, the feature pts. and the features. 
%%% 

function [objImg, objPts, objFeat, validPts] = ...
         learnObject(image, objReg, handles)
     
% Converts to gray if RGB
if (size(image, 3) == 1)
    imgBW = image;
else
    imgBW = rgb2gray(image);
end

% Crop the image to an 'object image'
objImg   = imcrop(image, objReg);
objImgBW = imcrop(imgBW, objReg);

% Detect features
objPts = detectSURFFeatures(objImgBW);
objPts = objPts.selectStrongest(200);

% Show the feature pts
ptsImg = insertMarker(objImg, objPts.Location, '+', 'Color', 'cyan');
imshow(ptsImg, 'Parent', handles.axes1);

% Extract the features and the valid pts
[objFeat, validPts] = extractFeatures(objImgBW, objPts, 'Method', 'SURF');