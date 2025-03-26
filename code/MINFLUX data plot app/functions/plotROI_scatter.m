function plotROI_scatter (app, idx_selected)
    roi_exist = ~isempty(app.scatterPlot_roi) && isgraphics(app.scatterPlot_roi);
    if roi_exist
        app.scatterPlot_roi.XData = app.data.xnm( idx_selected );
        app.scatterPlot_roi.YData = app.data.ynm( idx_selected );
        app.scatterPlot_roi.ZData = app.data.znm( idx_selected );
    else
        %disp(strcat(" line 502: ", ME.message));
        set(app.ax_scatter, 'NextPlot', 'add');
        app.scatterPlot_roi = scatter3(app.ax_scatter, ...
            app.data.xnm( idx_selected ), ...
            app.data.ynm( idx_selected ), ...
            app.data.znm( idx_selected ), ...
            'Marker', '.', ...
            'MarkerEdgeColor', app.color_roi);
        set(app.ax_scatter, 'NextPlot', 'replace');
    end
    app.scatterPlot_roi.MarkerEdgeColor = app.color_roi;
end