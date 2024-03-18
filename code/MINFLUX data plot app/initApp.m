
%  A script to start the MINFLUX data plot application
%
%  The MINFLUX data plot app is made to visualize, processing and analyze
%  MINFLUX data, with a specific focus on tracking project.
%
%  It will require the MINFLUX raw data in .mat format, either directly
%  exported from Abberior software, converted from numpy format, or zarr
%  file.
%
%  If confocal channel signal is of interest, it will also need the raw
%  .msr file, that can be loaded into Fiji via Bio-format plugin. It will
%  need the confocal channel images to be exported as multi-page tif, and
%  together with their original meta data, which described the pixel size
%  and axis offset when creating the confocal images. This info. is
%  critical to overlay localizations onto the confocal image.
%
% author: Ziqiang Huang <ziqiang.huang@embl.de>, EMBL Imaging Centre
% date: 2023.10.12
% version: v 1.0


addpath(genpath(pwd));

MINFLUX_data_plot
