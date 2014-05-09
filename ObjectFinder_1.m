%%% ObjectFinder_1
%%% 2014-05-04
%%% Markera object i bild, matcha punkter. 
%%% 

clear all

cam = videoinput('macvideo', 1);
set(cam, 'ReturnedColorSpace', 'RGB');

%%%%% GET REFERENCE IMAGE 
refImg = getsnapshot(cam);%imread('refPic.jpg');
refImg = rgb2gray(refImg);
%refImg = im2bw(refImg);
%refImg = histeq(refImg);

figure(1); 
imshow(refImg); 
objReg = round(getPosition(imrect));

dispImg = insertShape(refImg, 'Rectangle', objReg, 'Color', 'red');
figure(1);
imshow(dispImg);
title('Red box shows object region');

objImg = imcrop(refImg, objReg);

% Detect interest points in the object region
refPts = detectSURFFeatures(objImg);%, 'ROI', objReg);
%refPts = detectHarrisFeatures(refImg, 'ROI', objReg);


% Display the detected points
ptsImg = insertMarker(objImg, refPts.Location, 'x', 'Color', 'green');
figure(1);
imshow(ptsImg);
title('Detected Interest Points: Reference Image');

refFeat = extractFeatures(objImg, refPts);

%%%%% GET CAM IMAGE
camImg = getsnapshot(cam);
camImg = rgb2gray(camImg);
%camImg = im2bw(camImg);
%camImg = histeq(camImg);

figure(2);
imshow(camImg); %hold on;
%objReg2 = round(getPosition(imrect));

%camObjImg = insertShape(camImg, 'Rectangle', objReg2, 'Color', 'red');
%figure(2);
%imshow(camObjImg);
%title(' ');

camPts = detectSURFFeatures(camImg);%, 'ROI', objReg2);
%camPts    = detectHarrisFeatures(camImg);%, 'ROI', objReg2);
%camPts    = camPts.selectStrongest(200);

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
showMatchedFeatures(camImg, objImg, ...
                    matchedCamPts, matchedRefPts, 'montage');

refPtsMv = [matchedRefPts.Location(:, 1).*(objReg(1, 1)) ...
            matchedRefPts.Location(:, 2).*(objReg(1, 2))];

allPts = [matchedCamPts.Location ; refPtsMv];
                
figure(4)
matchedPtsImg = insertMarker(camImg, allPts, 'X', 'Color', 'red'); hold on;
imshow(matchedPtsImg);
