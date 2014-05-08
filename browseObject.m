%%% browseObject
%%% Input: None
%%% Output: An mat-file with image, points and and features
%%% 

function [object] = browseObject()

[file, path] = uigetfile('*.mat', 'Open an object');

filePath = fullfile(path, file);

object = open(filePath);
figure(1);
imshow(object);