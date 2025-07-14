function set_active_data_index (app, idx)

    
    if ~isprop(app, 'data') || isempty(app.data)
        return 
    end

    idx_current = get_active_data_index (app);
    
    if isempty(idx_current)
        app.data{idx}.active = true;
    elseif (idx ~= idx_current)
        app.data{idx_current}.active = false;
        app.data{idx}.active = true;
    else % (idx == idx_current), idx already active, do nothing
        
    end
    

end