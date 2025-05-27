function getLocData (app)
    if (isempty(app.data) || ~isfield(app.data, 'loc_x'))
        return;
    end
    % get valid localization coordinates
    check3D(app);
    if app.nDim < 3
        app.zscaleEditField.Value = 0;
        app.zscaleEditField.Editable = false; 
        app.zScaleAutoCheckBox.Enable = 'off';
    else
        app.zscaleEditField.Value = 1.0;
        app.zscaleEditField.Editable = true; 
        app.zScaleAutoCheckBox.Enable = 'on';
    end
    app.data.znm = app.data.loc_z * app.zScale * 1e9;
    app.xyz = 1e9* [app.data.loc_x, app.data.loc_y, app.data.loc_z*app.zScale];
end