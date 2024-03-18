        function loadFilterFromJson (app)
            if isempty(app.data)
                return;
            end
            [jsonfile, jsonpath] = uigetfile('*.json', "select filter config (.json) file");
            if isequal(jsonfile, 0)
               return;
            end
            jsonText = fileread(fullfile(jsonpath, jsonfile));
            jsonData = jsondecode(jsonText);
            % reset ftr, filter, and UI table
            app.ftr = true(app.nLoc, 1);
            app.filters = {};
            app.UITableFilter.Data = [];
            for i = 1 : length(jsonData)
                filter = jsonData(i);
                apply = filter.apply;
                attr = filter.attribute;
                if ~isfield(app.data, attr)
                    continue;
                end
                attrValue = getfield(app.data, attr); % we get the raw attribute value from data
                plotVar = filter.value_as;
                minVal = filter.min;
                maxVal = filter.max;
                
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

                new_filter = {apply, attr, plotVar, minVal, maxVal, histVal, ftr_new};
                if isempty(app.UITableFilter.Data)
                    app.UITableFilter.Data = new_filter(1:end-2);
                    app.filters = new_filter;
                else
                    app.UITableFilter.Data(end+1, :) = new_filter(1:end-2);
                    app.filters(end+1, :) = new_filter;
                end
            end
            % apply the newly created filter
            app.ftr = app.ftr & ftr_new;
            %applyFilter(app);
        end