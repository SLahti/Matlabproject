%%% Test

function testBench

img1 = imread('img1.jpg');
img2 = imread('img3.jpg');

pts1 = detectMinEigenFeatures(img1);
pts1 = pts1.selectStrongest(500);

pts2 = detectMinEigenFeatures(img2);
pts2 = pts2.selectStrongest(500);


imgPts1 = insertMarker(img1, pts1.Location, 'X', 'Color', 'yellow');
imgPts2 = insertMarker(img2, pts2.Location, 'X', 'Color', 'yellow');

figure(1), imshow(imgPts1); hold on;
figure(2), imshow(imgPts2); hold on;

feat1 = extractFeatures(img1, pts1);
feat2 = extractFeatures(img2, pts2);

idxPairs = matchFeatures(feat1, feat2);

matchedPts1 = pts1(idxPairs(:, 1));
matchedPts2 = pts2(idxPairs(:, 2));

figure(1);
plot(matchedPts1.Location(:, 1), matchedPts1.Location(:, 2), ...
     'O', 'Color', 'blue');

figure(2);
plot(matchedPts2.Location(:, 1), matchedPts2.Location(:, 2), ...
     'O', 'Color', 'blue');
 
%figure(3); 
%showMatchedFeatures(img1, img2 ,matchedPts1,matchedPts2);
%legend('matched points 1','matched points 2');