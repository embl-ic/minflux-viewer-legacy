function close_child_app (app)

    idx = find( cellfun(@(x) isequal(x, app), app.CallingApp.children_apps) );
    
    app.CallingApp.children_apps(idx) = [];

    delete(app);

end