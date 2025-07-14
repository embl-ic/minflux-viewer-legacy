function set_active_data (app, data)
    
    % check whether data already exist in app, it is first time loading or not?
    if ~isprop( app, 'data' ) || isempty( app.data )
        data.active = true;
        app.data = {data};

    else    % data already exist in app, set the newly inquiry data to active one

        % reset all data active, including the inquiring one to false, for comparison
        data.active = false;
        for i = 1 : numel( app.data )
            app.data{i}.active = false;
        end
        % check if data already exist, if so, return its index
        data_idx = find( cellfun(@(x) isequal(x, data), app.data), 1 );

        if isempty( data_idx )  % data not yet exist, add new entry
            data.active = true;
            app.data{end+1} = data;
        else
            app.data{data_idx}.active = true;
        end

    end


end