% Demo to randomly place Gaussians in an image.
% By ImageAnalyst
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
tic;
% Set up some parameters.
fontSize = 20;
backgroundGrayLevel = 128;
windowSize = 50; % Could be random if you want.
sigma = 10; % Could be random if you want.
numberOfGaussians = 173340;
rows = 1080;
columns = 1920;
% Create one Gaussian.
g = fspecial('gaussian', windowSize, sigma);
grayImage = backgroundGrayLevel * ones(rows, columns);
% Create random signs so that the Gaussians are
% randomly brighter or darker than the background.
s = 2*randi(2, [1 numberOfGaussians])-3;
% Note: g and grayImage are floating point images, not uint8,
% though you could modify the program to have them be uint8 if you wanted.
% Get a list of random locations.
randomRow = randi(rows-windowSize+1, [1 numberOfGaussians]);
randomCol = randi(columns-windowSize+1, [1 numberOfGaussians]);
% Place the Gaussians on the image at those random locations.
for k = 1 : numberOfGaussians
  grayImage(randomRow(k):randomRow(k)+windowSize-1, randomCol(k):randomCol(k)+windowSize-1) = ...
    grayImage(randomRow(k):randomRow(k)+windowSize-1, randomCol(k):randomCol(k)+windowSize-1) + ...
    s(k) * g;
end
toc;
% Display the final image.
imshow(grayImage, []);
caption = sprintf('%d Gaussians, Randomly Placed', numberOfGaussians);
title(caption, 'FontSize', fontSize);
axis on;
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1])
set(gcf,'name','Demo by ImageAnalyst','numbertitle','off')