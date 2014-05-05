%%% Function: browseImage
%%% Input: None
%%% Output: whole file path

function [filePath] = browseImage()

[file path] = uigetfile({'*.jpg';'*.png'}, 'Pick a file');

filePath = [path file];