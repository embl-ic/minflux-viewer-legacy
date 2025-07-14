function [file, folder] = get_file_path_raw_data ()

    %% 1, get MINFLUX data file, load into app.data.raw_data, check if first time load?
    
    if isfield(app.Prefs.file, "default_folder")
        [file, folder] = uigetfile('*.mat', "select MINFLUX raw data .mat file", app.Prefs.file.default_folder);
    else
        [file, folder] = uigetfile('*.mat', "select MINFLUX raw data .mat file");
    end
    
    %lastPath = folder;

end