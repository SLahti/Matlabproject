%%% saveObject
%%% Input: (gray)image, reference points and feature points
%%% Output: none
%%% Saves an 'object', as an .mat-file.

function saveObject(image, points, features)

img  = image;
pts  = points;
feat = features;

uisave({'img', 'pts', 'feat'}, 'object.mat');