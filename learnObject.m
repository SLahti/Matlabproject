%%% learnObject
%%% Input:  The "whole" img, GRAY. The object region to learn
%%% Output: the croped img, the feature pts. and the features. 
%%% 

function [objImg, objPts, objFeat] = learnObject(image, objReg)

objImg = imcrop(image, objReg);

<<<<<<< HEAD
objPts = detectSURFFeatures(objImg);
%objPts = objPts.selectStrongest(200);
%ptsImg = insertMarker(objImg, objPts.Location, 'x', 'Color', 'green');
=======
objPts = detectMinEigenFeatures(objImg);
objPts = objPts.selectStrongest(200);
ptsImg = insertMarker(objImg, objPts.Location, 'x', 'Color', 'green');

%figure(1);
imshow(ptsImg);
>>>>>>> Sebastian

objFeat = extractFeatures(image, objPts);

