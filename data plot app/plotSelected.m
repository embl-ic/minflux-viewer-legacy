% plot selected (ROI) data portion, with ROI color, in overview,
% histogram, and (if exist) scatter plot
function plotSelected (app, idx_selected)
    % delete old ROI if there's any
    if isempty(idx_selected) || sum(idx_selected)==0
        app.linePlot_roi.XData = [];
        app.linePlot_roi.YData = [];
        app.histPlot_roi.Data = [];
        app.scatterPlot_roi.XData = [];
        app.scatterPlot_roi.YData = [];
        app.scatterPlot_roi.ZData = [];
        delete(app.histPlot_roi_box);
        return;
    end
    plotROI_overview(app, idx_selected);
    plotROI_histogram(app, idx_selected);
    try
        plotROI_scatter(app, idx_selected);
    catch ME
        disp(strcat(" line 454: ", ME.message));
    end
end