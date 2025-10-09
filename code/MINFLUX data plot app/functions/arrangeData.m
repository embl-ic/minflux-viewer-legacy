function arrangeData (app)
%
%   parse MINFLUX MATLAB format data
%   rearrange: app.data
%   create: app.traceID,  app.traceLength
%
    
    parseAbberiorData (app);
    
    % sort by trace ID
    % [tid_sorted, idx_sort] = sort(app.data.tid);
    % 
    % attr_names = fieldnames(app.data);
    % for i = 1 : length(attr_names)
    %     % check attr dimension
    %     attrName = attr_names{i};
    %     value = app.data.(attrName);
    %     value = value(idx_sort);
    %     app.data.(attrName) = value;
    % end


    % take only valid data (moved into parseAbberiorData.m)
    take_valid = true;  
    if take_valid
        vld = true(app.nLoc, 1);
        if isfield(app.data, 'vld')
            vld = app.data.vld;
        end
        attr_names = fieldnames(app.data);
        % arrange attribute values to be: N*1, or N*3
        for i = 1 : length(attr_names)
            % check attr dimension
            attrName = attr_names{i};
            value = app.data.(attrName);
            app.data.(attrName) = value(vld, :);
        end
        app.nLoc = sum(vld);
    end
    
    % get trace ID, sort data by trace ID, and compute nLoc per trace
    if isfield(app.data, 'tid')
        % names = fieldnames(app.data);
        % for i = 1 : length(names)
        %     if strcmp(names{i}, 'mbm')
        %         continue;
        %     end
        %     data = app.data(names{i});
        %     app.data(names{i}) = data(idx_sort); 
        % end

        app.traceID = unique(app.data.tid);
        app.traceLength = arrayfun(@(x) sum(app.data.tid==x), app.traceID);
    end
 
end