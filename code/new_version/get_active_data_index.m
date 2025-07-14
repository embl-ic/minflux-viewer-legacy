function idx = get_active_data_index (app)

    idx = [];
    if ~isprop(app, 'data') || isempty(app.data)
        return 
    end

    idx = find( cellfun(@(x) x.active, app.data), 1 );

end