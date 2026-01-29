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



    % clear histogram visuals so next dataset starts clean
    try
        if ~isempty(app.histPlot) && isgraphics(app.histPlot), delete(app.histPlot); end
        app.histPlot = [];
        if ~isempty(app.hist_minLine) && isgraphics(app.hist_minLine), delete(app.hist_minLine); end
        app.hist_minLine = [];
        if ~isempty(app.hist_maxLine) && isgraphics(app.hist_maxLine), delete(app.hist_maxLine); end
        app.hist_maxLine = [];
        if ~isempty(app.histPlot_roi) && isgraphics(app.histPlot_roi), delete(app.histPlot_roi); end
        app.histPlot_roi = [];
        if ~isempty(app.histPlot_roi_box) && isgraphics(app.histPlot_roi_box), delete(app.histPlot_roi_box); end
        app.histPlot_roi_box = [];
        cla(app.UIAxes_histogram);
    catch
    end
    
end