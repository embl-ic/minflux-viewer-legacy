        function saveFilterToJson (app)
            if isempty(app.UITableFilter.Data) || isempty(app.filters)
                return;
            end

            [save_file, save_path, indx] = uiputfile(fullfile(app.path, strcat(app.file(1:end-4), '_filter.json')), 'save filter as json file');
            if indx == 0
                return;
            end

            header = ["apply", "attribute", "value_as", "min", "max"];
            jsonData = cell2struct(app.UITableFilter.Data, header, 2);
            jsonText = jsonencode(jsonData, 'PrettyPrint', true);

            fid = fopen(fullfile(save_path, save_file), 'w');
            fprintf(fid, '%s', jsonText);
            fclose(fid); 
        end