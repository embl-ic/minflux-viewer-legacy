function updateMainPlot (app)
    app.linePlot = scatter(app.UIAxes_overview, app.val_1, app.val_2, '.');
%             if ~isempty(app.histPlot)
%                 app.histPlot.Data = app.val_2;
%             else
%                 app.histPlot = histogram(app.UIAxes_histogram, app.val_2, 'EdgeAlpha', 0.1);
%             end
    xlabel(app.UIAxes_overview, app.attributeDropDown_2.Value);
    ylabel(app.UIAxes_overview, app.attributeDropDown_1.Value);
%            xlabel(app.UIAxes_histogram, app.attributeDropDown_1.Value);
    axis(app.UIAxes_overview, 'auto');
%            axis(app.UIAxes_histogram, 'auto');
    
    idx_selected = app.index_roi;
    
    % !!! apply filter also to ROI index

    if any(idx_selected)
        plotROI_overview(app, idx_selected);
        plotROI_histogram(app, idx_selected);
    end
end