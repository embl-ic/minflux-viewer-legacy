function applyFilter (app)

    %overview_xlim = app.UIAxes_overview.XLim;
    %overview_ylim = app.UIAxes_overview.YLim;
    %hist_xlim = app.UIAxes_histogram.XLim;
    %hist_ylim = app.UIAxes_histogram.YLim;


    app.linePlot.XData = app.val_1(app.ftr, :);
    app.linePlot.YData = app.val_2(app.ftr, :);
    
    app.val_hist = getHistPlotValue (app);
    updateHistPlot(app);
    %app.histPlot.Data = app.val_hist(app.ftr, :);
    
    
%             app.UIAxes_overview.XLimMode = 'auto';
%             app.UIAxes_overview.YLimMode = 'auto';
%             app.UIAxes_histogram.YLimMode = 'auto';
    % restore limits of plots
    %app.UIAxes_overview.XLim = overview_xlim;
    %app.UIAxes_overview.YLim = overview_ylim;
    %app.UIAxes_histogram.XLim = hist_xlim;
    %app.UIAxes_histogram.YLim = hist_ylim;

    if ~isempty(app.scatterPlot) && isgraphics(app.scatterPlot)
        %set(app.ax_scatter, 'NextPlot', 'replacechildren');
        scatter_xlim = app.ax_scatter.XLim;
        scatter_ylim = app.ax_scatter.YLim;
        scatter_zlim = app.ax_scatter.ZLim;
        
        app.scatterPlot.XData = app.xyz(app.ftr, 1);
        app.scatterPlot.YData = app.xyz(app.ftr, 2);
        app.scatterPlot.ZData = app.xyz(app.ftr, 3);
        app.scatterPlot.CData = app.val_c(app.ftr, end); 
        
        app.scatterPlot.DataTipTemplate.DataTipRows(end).Value = num2cell(app.data.tid(app.ftr));
        %app.ax_scatter.XLimMode = 'auto';
        %app.ax_scatter.YLimMode = 'auto';
        %app.ax_scatter.ZLimMode = 'auto';

        app.ax_scatter.XLim = scatter_xlim;
        app.ax_scatter.YLim = scatter_ylim;
        app.ax_scatter.ZLim = scatter_zlim;
    end
    
    % apply filter to ROI if there's any
    if any(app.index_roi)
        plotSelected(app, app.index_roi & app.ftr);
    end
end