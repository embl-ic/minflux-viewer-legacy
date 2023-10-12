function plotROI_scatter (app, idx_selected)
    roi_exist = ~isempty(app.scatterPlot_roi) && isgraphics(app.scatterPlot_roi);
    if roi_exist
        app.scatterPlot_roi.XData = app.xyz(idx_selected, 1);
        app.scatterPlot_roi.YData = app.xyz(idx_selected, 2);
        app.scatterPlot_roi.ZData = app.xyz(idx_selected, 3);
    else
        %disp(strcat(" line 502: ", ME.message));
        set(app.ax_scatter, 'NextPlot', 'add');
        app.scatterPlot_roi = scatter3(app.ax_scatter, ...
            app.xyz(idx_selected, 1), ...
            app.xyz(idx_selected, 2), ...
            app.xyz(idx_selected, 3), ...
            'Marker', '.', ...
            'MarkerEdgeColor', app.color_roi);
        set(app.ax_scatter, 'NextPlot', 'replace');
    end
    app.scatterPlot_roi.MarkerEdgeColor = app.color_roi;
end