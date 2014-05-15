%%% findObject
%%% Input: An image to serch for objects in, the objects features
%%% Output: Nothing now. The matched points...?
%%% Displays an image with all of its pts, the matching ones highlighted. 

function findObject(image, objFeat, handles) % Returns nothing! 
disp('In findObject...');

if (size(image, 3) == 1)
    imBW = image;
else
    imBW = rgb2gray(image); % Fulhaxx; vad om varken rgb eller gray?
    %image = histeq(image);
end

% Show the target image in right axes
%imshow(image, 'Parent', axes2); hold on;
%figure(1);
%imshow(image);
% Detect features in the target image
disp('Detecting features...');
imgPts  = detectSURFFeatures(imBW);
imgPts  = imgPts.selectStrongest(100);
disp('Extracting features...');
imgFeat = extractFeatures(imBW, imgPts);

% Image with ALL the feature-pts 
%ptsImg = insertMarker(image, imgPts.Location, '+', 'Color', 'yellow');
%imshow(ptsImg);

disp('Matching features...');
idxPairs = matchFeatures(imgFeat, objFeat, 'MatchThreshold', 1);

matchPts = imgPts(idxPairs(:, 1));

% Annotates the target image with the points
ptsImage = insertMarker(image, matchPts.Location, 'X', 'Color', 'green');

disp('Showing matchedImg...');
imshow(ptsImage, 'Parent', handles.axes2);

disp('findObject done!');
%matchedRefPts = refPts(idxPairs(:, 2));

% Felsökning och testing
%{
matchedPtsImg = insertMarker(image, matchedImgPts.Location, 'X', 'Color', 'blue');
allPtsImg = insertMarker(ptsImg, matchedImgPts.Location, 'O', 'Color', 'green');
figure(2);
imshow(allPtsImg);
figure(3);
imshow(matchedPtsImg);
%In left axes
hold on; 
plot(camPts.Location(:, 1), objPts.Location(:, 2), 'O', 'Color', 'green');
%In right axes
figure(3);
plot(matchedImgPts.Location(:, 1), matchedImgPts.Location(:, 2), ...
     'O', 'Color', 'green');
%}