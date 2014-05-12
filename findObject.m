%%% findObject
%%% Input: An image to serch for objects in, the objects features
%%% Output: Nothing now. The matched points...?
%%% Displays an image with all of its pts, the matching ones highlighted. 

function [matchedImgPts] = findObject(image, objFeat)

figure(2);
imshow(image); hold on;%Show in right axes

imgPts = detectSURFFeatures(image);
%imgPts = imgPts.selectStrongest(500);

%ptsImg = insertMarker(image, imgPts.Location, 'X', 'Color', 'yellow');
figure(2);
plot(imgPts);

imgFeat = extractFeatures(image, imgPts);

idxPairs = matchFeatures(imgFeat, objFeat, 'MatchThreshold', 5);

matchedImgPts = imgPts(idxPairs(:, 1));
%matchedRefPts = refPts(idxPairs(:, 2));



%In left axes
%hold on; 
%plot(camPts.Location(:, 1), objPts.Location(:, 2), 'O', 'Color', 'green');

%In right axes
%figure(3);
%plot(matchedImgPts.Location(:, 1), matchedImgPts.Location(:, 2), ...
 %    'O', 'Color', 'green');