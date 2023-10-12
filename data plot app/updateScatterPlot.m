function updateScatterPlot (app)    % only used now when loading new dataset
    % use case
    % color by dropdown; colormap dropdown; z-scale; apply filter;
    if isempty(app.fig_scatter) || ~isgraphics(app.fig_scatter)
        return;
    end
    % get filter and ROI if there's any
    ftr_sc = true(app.nLoc, 1);
    idx_selected = app.index_roi;
    if (app.applyFilterCheckBox.Value)
        ftr_sc = app.ftr;
        idx_selected = idx_selected & app.ftr;
    end
    % update X, Y, Z and C data
    app.scatterPlot.XData = app.xyz(ftr_sc, 1);
    app.scatterPlot.YData = app.xyz(ftr_sc, 2);
    app.scatterPlot.ZData = app.xyz(ftr_sc, 3);
    app.scatterPlot.CData = app.val_c(ftr_sc, end);
    % update color map
    cmap = app.colormapDropDown.Value;
    if strcmp('default', cmap)
        cmap = [0 0.4470 0.7410];
    elseif strcmp('glasbey', cmap)
        cmap = makeGlasbey(app);
    end
    colormap(app.ax_scatter, cmap);
    %colorbar(app.ax_scatter); 
    % update ROI region if there's any
    if any(idx_selected)
        plotROI_scatter (app);
    end 
end