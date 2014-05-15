%%% Function: browseImage
%%% Input: None
%%% Output: image

function [image] = browseImage()

[file path] = uigetfile({'./Images/*.jpg;*.png'}, 'Pick a file');

filePath = [path file];

image = imread(filePath);