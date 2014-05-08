%%% highlightObject
%%% Input: Image to mark object in
%%% Output: The marked region
%%%

function [objReg] = highlightObject(image)

if (size(image, 3) ~= 1)
    image = rgb2gray(image); % Fulhaxx; vad om varken rgb eller gray?
end

%figure(1);
imshow(image);

objReg = round(getPosition(imrect));
higImg = insertShape(image, 'Rectangle', objReg, 'Color', 'red');

%figure(1);
imshow(higImg);