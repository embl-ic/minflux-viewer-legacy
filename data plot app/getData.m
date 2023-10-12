function data = getData (app) % public
    data = app.data;
    % apply filters
    fnames = fieldnames(app.data);
    for i = 1 : numel(fnames)
        f = fnames{i};
        data.(f) = app.data.(f)(app.ftr, :);
    end
end