function idx = find_data_index (app, name)

    idx = [];
    if ~isprop(app, 'data') || isempty(app.data)
        return 
    end
    
    %fig_name = strcat("Loc Scatter Plot : ", data.file.name)

    idx = find( cellfun(@(x) strcmp(x.file.name, name), app.data), 1 );

end