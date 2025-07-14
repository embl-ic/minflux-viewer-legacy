function save_data (app) 
    % get active data
    idx = get_active_data_index(app);
    if isempty (idx)
        return;
    end
    % get data, raw data, data file name and path
    data = app.data{idx};
    file = data.file;
    raw_data = file.raw_data;

    if ~isfield(raw_data, 'vld')
        return;
    end
    
    % ask user to provide the file path and name where to save the processed data
    [save_file, save_path, indx] = uiputfile(fullfile(file.folder, strcat('processed_', file.name)), 'File Selection');
    if indx == 0
        return;
    end

    % update the valid array, to include filter information
    %
    % we make use of the vld attribute to include filter information:
    %
    % disadvantage: it's not possible to recover the original data,
    % so the filter (json file) is recommended to be saved next to the 
    % saved and processed data.
    %

    vld = raw_data.vld;  % raw data valid array : n_valid / n_all
    ftr = data.attr.ftr; % filter array: n_filtered / n_valid
    idx = find(vld);    % index of valid data index in the original raw data
    idx = idx(ftr);     % index of valid data after filter applied
    vld_new = false(size(vld));
    vld_new(idx) = true;
    raw_data.vld = vld_new; % update the orginal valid array to include the filter array to it
    
    % save the processed data (no success check)
    save(fullfile(save_path, save_file), '-struct', 'raw_data', '-v7.3');

end