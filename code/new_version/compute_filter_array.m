function ftr = compute_filter_array (data, row_data)

    ftr = [];
    if isempty(data) || ~isfield(data, 'attr')
        return;
    end

    %% here

    
    if ~isfield(data.attr, 'ftr')
        data.attr.ftr = true(data.prop.num_loc, 1);
    end

    trace_idx = data.prop.trace_idx;
    num_loc_per_trace = data.prop.num_loc_per_trace;
    %apply_filter = row_data{1};
    attr_name = row_data{2};
    var_type = row_data{3};
    min_value = row_data{4};
    max_value = row_data{5};

    attr_value = data.attr.(attr_name);

    switch var_type
        case "per loc"
            hist_value = attr_value;

        case "trace mean"
            hist_value = arrayfun(@(id) mean( double(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :)), 1, 'omitnan'), (1:length(trace_idx))');

        case "trace stdev"
            hist_value = arrayfun(@(id) std( double(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :)), 1, 'omitnan'), (1:length(trace_idx))');

        %case "trace median"
        %    val = arrayfun(@(id) median(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), 'omitnan'), (1:length(trace_idx))');

        %case "trace mode"
        %    val = arrayfun(@(id) mode(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :)), (1:length(trace_idx))');

        case "trace max"
            hist_value = arrayfun(@(id) max(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), [], 'all', 'omitnan'), (1:length(trace_idx))');

        case "trace min"
            hist_value = arrayfun(@(id) min(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), [], 'all', 'omitnan'), (1:length(trace_idx))');

        case "trace range"
            hist_value = arrayfun(@(id) range(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), 'all'), (1:length(trace_idx))');

        otherwise
            hist_value = attr_value;
    end
    
    ftr = hist_value >= min_value & hist_value <= max_value;

    if startsWith(var_type, "trace")
        ftr = repelem(ftr, num_loc_per_trace);
    end

    % if apply_filter
    %     app.data.attr.ftr = app.data.attr.ftr & ftr;
    % end

end