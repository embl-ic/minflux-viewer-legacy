function plotROI_histogram (app, idx_selected)
    roi_exist = ~isempty(app.histPlot_roi) && isgraphics(app.histPlot_roi);
    if roi_exist
        app.histPlot_roi.Data = app.val_2(idx_selected);
        delete(app.histPlot_roi_box);
    else
        set(app.UIAxes_histogram, 'NextPlot', 'add');
        app.histPlot_roi = histogram(app.UIAxes_histogram, app.val_2(idx_selected), ...
            'BinEdges', app.histPlot.BinEdges, 'FaceColor', app.color_roi, 'EdgeAlpha', 0.1);
        set(app.UIAxes_histogram, 'NextPlot', 'replace');
    end
    %app.histPlot_roi.FaceColor = app.color_roi;
    set(app.UIAxes_histogram, 'NextPlot', 'add');
    hist_roi_x = min(app.val_2(idx_selected));
    hist_roi_width = max(app.val_2(idx_selected)) - hist_roi_x;
    hist_roi_y = 0;
    hist_roi_height = app.UIAxes_histogram.YLim(2) - hist_roi_y;
    app.histPlot_roi_box = drawrectangle(app.UIAxes_histogram, ...
        'Color', app.color_roi, 'StripeColor', 'none', ...
        'Position', ...
        [hist_roi_x hist_roi_y hist_roi_width hist_roi_height]);
    set(app.UIAxes_histogram, 'NextPlot', 'replace');     
end