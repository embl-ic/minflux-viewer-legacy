function addFilterToTable (app)
    % get filter paramters from histogram panel
    apply = true;
    attr = app.histAttributeDropDown_4.Value;
    attrValue = getfield(app.data, attr); % we get the raw attribute value from data
    plotVar = app.plotVarDropDown.Value;
    minVal = app.minSpinner.Value;
    maxVal = app.maxSpinner.Value;
    
    switch plotVar
        case 'per loc'
            histVal = attrValue;
        case 'trace mean'
            histVal = arrayfun(@(x) mean(attrValue(app.data.tid==x, :)), app.traceID);
        case 'trace stdev'
            histVal = arrayfun(@(x) std(attrValue(app.data.tid==x, :)), app.traceID);
        case 'trace median'
            histVal = arrayfun(@(x) median(attrValue(app.data.tid==x, :)), app.traceID);
        case 'trace mode'
            histVal = arrayfun(@(x) mode(attrValue(app.data.tid==x, :)), app.traceID);
        case 'trace max'
            histVal = arrayfun(@(x) max(attrValue(app.data.tid==x, :)), app.traceID);
        case 'trace min'
            histVal = arrayfun(@(x) min(attrValue(app.data.tid==x, :)), app.traceID);
        case 'trace range'
            histVal = arrayfun(@(x) range(attrValue(app.data.tid==x, :)), app.traceID);
        otherwise
            histVal = attrValue;
    end

    ftr_new = histVal>=minVal & histVal<=maxVal;
    if startsWith(plotVar, 'trace')
        ftr_new = repelem(ftr_new, app.traceLength);
    end
    % create new filter param cell array
    new_filter = {apply, attr, plotVar, minVal, maxVal, histVal, ftr_new};
    % add filter to filter table UI
    if isempty(app.UITableFilter.Data)
        app.UITableFilter.Data = new_filter(1:end-2);
        app.filters = new_filter;
        % attempt to create a right click context menu on the
        % filter table list
%                 cm = uicontextmenu;
%                 m1 = uimenu(cm,'Text','Edit');
%                 m2 = uimenu(cm,'Text','Delete');
%                 app.UITableFilter.UIContextMenu = cm;
    else
        app.UITableFilter.Data(end+1, :) = new_filter(1:end-2);
        app.filters(end+1, :) = new_filter;
    end
    % apply the newly created filter
    app.ftr = app.ftr & ftr_new;
    applyFilter(app);
end