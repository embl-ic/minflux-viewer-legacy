function [file, folder] = get_file_path_raw_data ()

    %% 1, get MINFLUX data file, load into app.data.raw_data, check if first time load?
    %persistent lastPath;
    last_path = getpref('mfx_viewer', 'default_folder', "");
    if isempty(last_path)
        [file, folder] = uigetfile('*.mat', "select MINFLUX raw data .mat file");
    else
        [file, folder] = uigetfile('*.mat', "select MINFLUX raw data .mat file", last_path);
    end
    
    %lastPath = folder;

end