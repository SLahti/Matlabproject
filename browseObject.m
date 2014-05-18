%%% browseObject
%%% Input: None
%%% Output: A .mat-file with image, points and features
%%% 

function [object] = browseObject()

[file, path] = uigetfile('./Objects/*.mat', 'Open an object');

filePath = fullfile(path, file);

object = open(filePath);