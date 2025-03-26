function load_filter (app, jsonfile, jsonpath)

    if isequal(jsonfile, 0) || isequal(jsonpath, 0)
        return;
    end

    try
        jsonText = fileread(fullfile(jsonpath, jsonfile));
        jsonData = jsondecode(jsonText);

        filters = struct;
        
        filter = cell(length(jsonData), 5);

        for i = 1 : length ( jsonData )
            row = jsonData(i);
            apply = row.apply;     % not neccessary
            attr = row.attribute;
            % if ~isfield(app.data, attr)
            %     continue;
            % end
            %attrValue = getfield(app.data, attr); % we get the raw attribute value from data
            plotVar = row.value_as;
            minVal = row.min;
            maxVal = row.max;
            
            %ftr = compute_filter_array (app, {apply, attr, plotVar, minVal, maxVal});

            filter(i, 1:5) = {false, attr, plotVar, minVal, maxVal}; % when loading filter from json file, make apply filter to false for all
            
            if ~isempty(app.data) & isfield(app.data, 'attr')
                ftr = compute_filter_array (app, {apply, attr, plotVar, minVal, maxVal});
                filter{i, 6} = ftr;
            end

        end

        filters.jsonfile = fullfile(jsonpath, jsonfile);
        filters.filter = filter;

        if ~isempty(app.data) & isfield(app.data, 'attr')
            filters.ftr = app.data.attr.ftr;
        end

        app.data.filters = filters;

    catch Exception
        app.StatusTextArea.Value = "Failed loading filters from json file!";
    end

    app.StatusTextArea.Value = ["Filter loaded:"; jsonfile];

end