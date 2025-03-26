function arrangeData (app)
%
%   parse MINFLUX MATLAB format data
%   rearrange: app.data
%   create: app.traceID,  app.traceLength
%
    
    parseAbberiorData (app);
    
    % take only valid data
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
    
    % get trace ID, and nLoc per trace
    if isfield(app.data, 'tid')
        app.traceID = unique(app.data.tid);
        app.traceLength = arrayfun(@(x) sum(app.data.tid==x), app.traceID);
    end
 
end