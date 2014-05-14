%%% findObject
%%% Input: An image to serch for objects in, the objects features
%%% Output: Nothing now. The matched points...?
%%% Displays an image with all of its pts, the matching ones highlighted. 

function [matchedImgPts] = findObject(image, objFeat)

image = rgb2gray(image);

% Show the target image in right axes
%imshow(image, 'Parent', axes2); hold on;
figure(1);
imshow(image);
% Detect features in the target image
imgPts = detectSURFFeatures(image);
imgPts = imgPts.selectStrongest(250);

imgFeat = extractFeatures(image, imgPts);

ptsImg = insertMarker(image, imgPts.Location, '+', 'Color', 'yellow');

figure(1);
imshow(ptsImg);

idxPairs = matchFeatures(imgFeat, objFeat, 'MatchThreshold', 5);

matchedImgPts = imgPts(idxPairs(:, 1));
%matchedRefPts = refPts(idxPairs(:, 2));

matchedPtsImg = insertMarker(image, matchedImgPts.Location, 'X', 'Color', 'blue');
allPtsImg = insertMarker(ptsImg, matchedImgPts.Location, 'O', 'Color', 'green');

figure(2);
imshow(allPtsImg);

figure(3);
imshow(matchedPtsImg);

%In left axes
%hold on; 
%plot(camPts.Location(:, 1), objPts.Location(:, 2), 'O', 'Color', 'green');

%In right axes
%figure(3);
%plot(matchedImgPts.Location(:, 1), matchedImgPts.Location(:, 2), ...
 %    'O', 'Color', 'green');