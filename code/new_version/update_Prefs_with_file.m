function update_Prefs_with_file (app, folder, file_name)
    
    if ~isprop(app, "Prefs")
        return;
    end
    
    % update default folder to the last data opening folder 
    if app.Prefs.file.keep_last_folder
        app.Prefs.file.default_folder = folder;
    end
    
    path = fullfile(folder, file_name);

    % add the file path to the list of recent files in app.Prefs
    if ~isfield(app.Prefs.file, "recent_files")
        app.Prefs.file.recent_files = {path};
    else
        % if it already exist, no need to add
        if any( strcmp(app.Prefs.file.recent_files, path) )
            return;
        end
        % add to the beginning of Prefs.recent_files list
        app.Prefs.file.recent_files = [{path}, app.Prefs.file.recent_files];
        % also add the new path to top of the recent files menu entry
        uimenu(app.OpenrecentfilesMenu, 'Text', path, 'MenuSelectedFcn', {@open_recent_file, app}, 'Position', 1);
        % keep only up to 100 recent file (also path) in app.Prefs
        while ( length(app.Prefs.file.recent_files) > 100 ) 
            app.Prefs.file.recent_files(end) = [];
        end
    end

    % update the Prefs to MATLAB presist parameter
    setpref('mfx_viewer', 'Prefs', app.Prefs);
    
end