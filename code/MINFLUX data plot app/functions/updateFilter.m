function updateFilter (app)
    app.ftr = true(app.nLoc, 1);
    if isempty(app.UITableFilter.Data) || isempty(app.filters)
        return;
    end
    for i = 1 : size(app.filters, 1)
        if (app.UITableFilter.Data{i, 1} == 1)
            app.ftr = app.ftr & app.filters{i, end};
        end
    end
end