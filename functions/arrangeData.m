function arrangeData (app)
    if isempty(app.data) || ~isfield(app.data, 'itr')
        return
    end
    % store app.data into temporary variable
    data_temp = app.data;

    % remove reference point attribute
    if isfield(app.data, 'mbm')
        data_temp = rmfield(data_temp, 'mbm');
    end
    
    % Abberrior Imspector format, unwrap attr contained within 'itr'
    if ~isfield(app.data, 'loc')
        names_1 = fieldnames(data_temp.itr);
        cells_1 = struct2cell(data_temp.itr);
        data_temp = rmfield(data_temp, 'itr');
        names_2 = fieldnames(data_temp);
        cells_2 = struct2cell(data_temp);
        data_temp = cell2struct([cells_1; cells_2], [names_1; names_2]);
    end
    
    % localization data
    if ~isfield(data_temp, 'loc')
        return
    end
    
    % get complete data attribute name list
    attr_names = fieldnames(data_temp);

    % get N(loc) and N(itr)
    itr = data_temp.itr;
    [app.nLoc, app.nItr] = size(itr);
    vld = true(app.nLoc, 1);
    if isfield(data_temp, 'vld')
        vld = data_temp.vld;
    end
    % arrange format and dimension of nLoc and nItr
    if app.nLoc == 1
        app.nLoc = app.nItr;    % swap to get the correct number of localizations
        itr = itr';
        if app.nLoc == 1    % data with only 1 localization, invalid
            return
        end
        app.nItr = 1;   % only 1 iteration
    end
    app.nLoc = size(data_temp.loc(vld, :), 1);
    
    % check iteration (to account for 2024.02.19 Aberrior update
    newFormat = any(diff(itr(:,end)));  % if element of itr is not all the same value



    % arrange attribute values to be: N*1, or N*3
    for i = 1 : length(attr_names)
        % check attr dimension
        attrName = attr_names{i};
        value = data_temp.(attrName);

        % arrange attributes that more than 2 dimension: loc, lnc, ext
        if strcmp(attrName, 'loc') || strcmp(attrName, 'lnc') || strcmp(attrName, 'ext') %ndims(value)==3   % loc, lnc, ext
            data_temp = rmfield(data_temp, attrName);
            if (~newFormat)
                value = squeeze(value(vld, end, :));   % only take last iteration if all iteration provided
            end
            data_temp.([attrName, '_x']) = value(:, 1);
            data_temp.([attrName, '_y']) = value(:, 2);
            data_temp.([attrName, '_z']) = value(:, 3);
            continue;
        end

        % swap value to N by 1
        if (size(value, 1) == 1)
            value = value';
        end
        % only take value from last iteration, except for 'cfr',
        % and 'efc'
        
        % check which iteration 'cfr' and 'efc' might has valid values
        if strcmp(attrName, 'cfr') || strcmp(attrName, 'efc')
            [~, idx] = max(nansum(value)); %#ok<NANSUM> 
            if idx ~= app.nItr
                nthItr = 1 + itr(1, idx);
                nthText = 'th';
                if     1 == nthItr
                    nthText = 'st';
                elseif 2 == nthItr
                    nthText = 'nd';
                elseif 3 == nthItr
                    nthText = 'rd';
                end
                fprintf('reading %s from %d%s iteration (%d / %d).\n', ...
                    attrName, nthItr, nthText, idx, app.nItr);
            end
            value = value(vld, idx);
        else
            value = value(vld, end);
        end

        % remove all NaN attributes
%                 if all(isnan(value))
%                     continue;
%                 end
        % change logical to numerical, !!!maybe unnecessary
        %if isa(value, 'logical')    
        %    value = int8(value);
        %end
        data_temp.(attrName) = value;
    end
    app.data = data_temp;
    % get trace ID, and nLoc per trace
    app.traceID = unique(app.data.tid);
    app.traceLength = arrayfun(@(x) sum(app.data.tid==x), app.traceID);
end