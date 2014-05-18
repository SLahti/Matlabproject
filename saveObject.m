%%% saveObject
%%% Input: (gray)image, reference points and feature points
%%% Output: none
%%% Saves an 'object', as an .mat-file.

function saveObject(image, points, features, validPts)

img    = image;
pts    = points;
feat   = features;
valPts = validPts;

uisave({'img', 'pts', 'feat', 'valPts'}, './Objects/object.mat');