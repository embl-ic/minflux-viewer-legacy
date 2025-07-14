function parse_file_path (app, file_fullpath)
    
    if isempty(file_fullpath)
        return;
    end

    [folder, name, ext] = fileparts(file_fullpath);

    switch ext

        case ".mat"             % MINFLUX data file
            load_data (app, strcat(name, ext), folder);
            %updateFrontView(app);

        case ".json"            % filter file
            load_filter (app, strcat(name, ext), folder);

        case {".tif", ".tiff"}  % image file
            load_tif (app, strcat(name, ext), folder);

    end

end