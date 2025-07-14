function close_child_figure (src, ~, app)
    

    %if ~isvalid(src)
    %    return;
    %end
    
    idx = find( cellfun(@(x) isequal(x, src), app.children_apps) );
    
    app.children_apps(idx) = [];

end