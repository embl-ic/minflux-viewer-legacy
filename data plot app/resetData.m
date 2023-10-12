function resetData (app)
    app.data = [];
    %app.data_filtered = [];
    app.attributes = [];
    app.nItr = 0;
    app.nLoc = 0;
    %app.xyz = [];
    app.nDim = 0;
    app.zScale = 1;
    app.zscaleEditField.Value = 1;
    app.val_1 = [];
    app.val_2 = [];
    app.val_c = [];
    app.zScaleAutoCheckBox.Value = 0; % by default, no auto scale Z
    app.filters = [];
    app.UITableFilter.Data = [];
    
    %app.filtered = [];
    if app.firstLoad    % some values can persist through different dataset
        app.color_roi = [1 0 1];    % default ROI color is yellow
    end
    % clear ROI
    app.index_roi = [];
    %if (app.roi_exist)
    %app.index_roi = [];
    %delete(app.linePlot_roi);
    %delete(app.histPlot_roi);
    %delete(app.histPlot_roi_box);
    %delete(app.scatterPlot_roi);
    %end
end