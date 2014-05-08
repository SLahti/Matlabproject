%%% ObjectFinder_1
%%% 2014-05-04
%%% Markera object i bild, matcha punkter. 
%%% 

clear all

cam = videoinput('macvideo');
set(cam, 'ReturnedColorSpace', 'RGB');

%%%%% GET REFERENCE IMAGE 
refImg = getsnapshot(cam);%imread('refPic.jpg');
refImg = rgb2gray(refImg);
%refImg = histeq(refImg);

figure(1); 
imshow(refImg); 
objReg = round(getPosition(imrect));

objImg = insertShape(refImg, 'Rectangle', objReg, 'Color', 'red');
figure(1);
imshow(objImg);
title('Red box shows object region');

% Detect interest points in the object region
%refPts = detectSURFFeatures(refImg, 'ROI', objReg);
refPts = detectMinEigenFeatures(refImg, 'ROI', objReg);

% Display the detected points
ptsImg = insertMarker(objImg, refPts.Location, 'x', 'Color', 'green');
figure(1);
imshow(ptsImg);
title('Detected Interest Points: Reference Image');

refFeat = extractFeatures(refImg, refPts);

%%%%% GET CAM IMAGE
camImg = getsnapshot(cam);
camImg = rgb2gray(camImg);
%camImg = histeq(camImg);

figure(2);
imshow(camImg); %hold on;
%objReg2 = round(getPosition(imrect));

%camObjImg = insertShape(camImg, 'Rectangle', objReg2, 'Color', 'red');
%figure(2);
%imshow(camObjImg);
%title(' ');

%camPts = detectSURFFeatures(camImg, 'ROI', objReg2);
camPts    = detectMinEigenFeatures(camImg);%, 'ROI', objReg2);
camPts    = camPts.selectStrongest(200);

camPtsImg = insertMarker(camImg, camPts.Location, 'x', 'Color', 'yellow');
figure(2);
imshow(camPtsImg);
title('Detected Interest Points: Camera');

camFeat = extractFeatures(camImg, camPts);


%%% 
idxPairs = matchFeatures(camFeat, refFeat);

matchedCamPts = camPts(idxPairs(:, 1));
matchedRefPts = refPts(idxPairs(:, 2));

figure(3)
showMatchedFeatures(camImg, refImg, ...
                    matchedCamPts, matchedRefPts, 'Montage');
%}
                
