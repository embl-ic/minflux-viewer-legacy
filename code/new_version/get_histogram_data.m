function val = get_histogram_data (app, attr_name, var_type, apply_filter)
    val = [];
    if isempty(app.data)
        return;
    end
    
    if nargin < 4
        apply_filter = true;
    end

    attr_value = app.data.attr.(attr_name); %getAttrValue(app, attr);

    if apply_filter
        attr_value = attr_value(app.data.attr.ftr, :);
    end

    if strcmp('per loc', var_type)
        val = attr_value;
        return;
    end
    tid = app.data.tid;
    if apply_filter
        tid = tid(app.ftr);
    end
    tid(isnan(attr_value)) = []; attr_value(isnan(attr_value)) = [];
    trace_ID = unique(tid);
    switch var_type
        case 'per loc'
            val = attr_value;
        case 'trace mean'
            val = arrayfun(@(x) mean(attr_value(tid==x, :)), trace_ID);
        case 'trace stdev'
            val = arrayfun(@(x) std(attr_value(tid==x, :)), trace_ID);
        case 'trace median'
            val = arrayfun(@(x) median(attr_value(tid==x, :)), trace_ID);
        case 'trace mode'
            val = arrayfun(@(x) mode(attr_value(tid==x, :)), trace_ID);
        case 'trace max'
            val = arrayfun(@(x) max(attr_value(tid==x, :)), trace_ID);
        case 'trace min'
            val = arrayfun(@(x) min(attr_value(tid==x, :)), trace_ID);
        case 'trace range'
            val = arrayfun(@(x) range(attr_value(tid==x, :)), trace_ID);
        otherwise
            val = attr_value;
    end
end