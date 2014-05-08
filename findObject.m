%%% findObject
%%% Input: An image to serch for objects in, the objects features
%%% Output: Nothing now. The matched points...?
%%% Displays an image with all of its pts, the matching ones highlighted. 

function findObject(image, objFeat)

figure(1);
imshow(image); %Show in right axes

imgPts = detectMinEigenFeatures(image);
imgPts = imgPts.selectStrongest(500);

ptsImg = insertMarker(image, imgPts.Location, 'x', 'Color', 'yellow');
figure(1);
imshow(ptsImg); %Show in right axes
hold on;

imgFeat = extractFeatures(image, imgPts);

idxPairs = matchFeatures(imgFeat, objFeat);

matchedImgPts = imgPts(idxPairs(:, 1));
%matchedRefPts = refPts(idxPairs(:, 2));

%In left axes
%hold on; 
%plot(camPts.Location(:, 1), objPts.Location(:, 2), 'O', 'Color', 'green');

%In right axes
figure(1);
plot(matchedImgPts.Location(:, 1), matchedImgPts.Location(:, 2), ...
     'O', 'Color', 'green');