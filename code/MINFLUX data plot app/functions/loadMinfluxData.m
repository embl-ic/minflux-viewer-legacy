function loadMinfluxData (app)
    app.data = load(fullfile(app.path, app.file), '-mat');
    arrangeData(app);
end