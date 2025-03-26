function load_data (app, file, folder)    
    %% 
    % create a open file dialog, ask for the MINFLUX raw data file
    % ? try persist last path
    % 
    % load parameter from parsed MINFLUX data structure

    % app.
    %
    %
    
    %% 1, get MINFLUX data file, load into app.data.raw_data, check if first time load?
    % val = getpref('mfx_data_viewer', 'RIMF', 0.67);
    %        disp("RIMF loaded from pref: " + val);
    
    % if isempty(lastPath)
    %     [file, folder] = uigetfile('*.mat', "select MINFLUX raw data .mat file");
    % else
    %     [file, folder] = uigetfile('*.mat', "select MINFLUX raw data .mat file", lastPath);
    % end
    
    if isequal(file, 0)
       return;
    end
    %lastPath = folder;

    %first_load = isempty( app.data );  % check whether it's the 1st time loading a dataset
        

    %% 2, validate new data, reset app.data structure, and load new data into it (reset GUI?)
    [valid, attributes, property, file] = validate_raw_data (app, folder, file);
    if ~valid
        app.StatusTextArea.Value = "MINFLUX raw data is not valid!";
        return;
    else % display data load message to status bar, and store path to prefs
        app.StatusTextArea.Value = ["Data loaded:"; file.name];
        %setpref('mfx_viewer', 'RIMF', Prefs.RIMF);    
        %app.Prefs.
    end
    
    if ~isprop( app, 'data' )
        app.data = [];
    end
    
    app.data.file = file;
    app.data.attr = attributes;
    app.data.prop = property;
    
    % app.data.file : name, folder, raw_data
    % app.data.attr : vld, itr, tid, dcr, efo, cfr, loc_x, loc_y, loc_z, tim, ftr, idx ... 
    % app.data.ROI
    % app.data.filter
    % app.data.calibration : pixel_size, voxel_depth, RIMF, sigma_xy, sigma_z
    % app.data.channel : dcr, dcr_trace, do_channel, numC, do_trace, cut1, cut2, do_ch3, ch_idx, RGB
    % app.data.images : posZ, pixel_size, voxel_depth, numC, channel_by_trace, cut1, cut2, RGB, gaussian_filtered, sigma_xy, sigma_z
    % app.data.extra : confocal_ch1, confocal_ch2

    % app.GUI


    %% 3, compute and store additional data properties
    compute_extra_property (app)

    %% 4, check additional action in prefs, associated with load data
    actions = app.Prefs.on_data_load;
    if actions.plot_attr
        app.children_apps{end+1} = plot_attribute (app);
    end

    if actions.plot_hist
        app.children_apps{end+1} = plot_histogram (app);
    end

    if actions.plot_scatter
        app.children_apps{end+1} = plot_scatter (app);
    end

    if actions.render_image
        app.children_apps{end+1} = interactive_render_MINFLUX (app);
    end

    
end