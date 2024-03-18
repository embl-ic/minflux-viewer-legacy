function updateAttrList (app)
    % update drop-down menu items with number of iteration of data
    app.attributeDropDown_1.Items = app.attributes;
    app.attributeDropDown_2.Items = app.attributes;
    app.colorByAttributeDropDown_3.Items = app.attributes;
    app.histAttributeDropDown_4.Items = app.attributes;
    if app.firstLoad
        app.attributeDropDown_2.Value = app.attributes{end};
        app.histAttributeDropDown_4.Value = app.attributes{end};
    end
end