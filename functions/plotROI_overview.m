function plotROI_overview (app, idx_selected)
    roi_exist = ~isempty(app.linePlot_roi) && isgraphics(app.linePlot_roi);
    if roi_exist
        app.linePlot_roi.XData = app.val_1(idx_selected);
        app.linePlot_roi.YData = app.val_2(idx_selected);
    else
        set(app.UIAxes_overview, 'NextPlot', 'add');
        app.linePlot_roi = plot(app.UIAxes_overview, app.val_1(idx_selected), app.val_2(idx_selected), '.');
        app.linePlot_roi.MarkerEdgeColor = app.color_roi;
        set(app.UIAxes_overview, 'NextPlot', 'replace');
    end
end