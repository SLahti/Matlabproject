%%% findObject
%%% Input:  An image to serch for objects in, the objects features
%%% Output: Nothing now. The matched points...?
%%% Displays an image with all of its pts, the matching ones highlighted. 

function findObject(image, objFeat, handles) % Returns nothing! 

% Converts to gray if RGB
if (size(image, 3) == 1)
    imgBW = image;
else
    imgBW = rgb2gray(image);
end
% Detect features in target image
imgPts = detectSURFFeatures(imgBW);
imgPts = imgPts.selectStrongest(200);

% Show all the feature pts at first
%allPtsImg = insertMarker(image, imgPts.Location, 'x', ...
%                         'Color', 'white', 'Size', 4);
%imshow(allPtsImg, 'Parent', handles.axes2);

% Extract and match features
[imgFeat, validPts] = extractFeatures(imgBW, imgPts, 'Method', 'SURF');
indexPairs = matchFeatures(imgFeat, objFeat, 'MatchThreshold', 1);

% The matching pts
matchPts = imgPts(indexPairs(:, 1));
%matchedRefPts = refPts(idxPairs(:, 2));

% Annotates the target image with the points
matchImage = insertMarker(image, matchPts.Location, 'X', ...
                          'Color', 'green', 'Size', 7);

imshow(matchImage, 'Parent', handles.axes2);