function plotScatter (app)
    if (isempty(app.data) || ~isfield(app.data, 'loc_x'))
        return;
    end
    if isempty(app.xyz)
        getLocData(app);
    end
    app.fig_scatter = findobj( 'Type', 'Figure', 'Name', 'MINFLUX 3D Scatter Plot' );
    if isempty(app.fig_scatter)
        app.fig_scatter = figure('Name', 'MINFLUX 3D Scatter Plot');
        app.fig_scatter.Position = [1000, 100, 1024, 1024];
        %app.fig_scatter.NumberTitle = 'off';
    end
    %app.fig_scatter.Position(3) = 1024;
    %app.fig_scatter.Position(4) = 1024;
    set(0, 'CurrentFigure', app.fig_scatter);
    app.scatterPlot = scatter3(app.xyz(app.ftr,1), app.xyz(app.ftr,2), app.xyz(app.ftr,3), '.');
    
    app.scatterPlot.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("tid",  num2cell(app.data.tid(app.ftr)));
    app.ax_scatter = gca;
    xlabel(app.ax_scatter, 'X', 'FontSize', 24);
    ylabel(app.ax_scatter, 'Y', 'FontSize', 24);
    zlabel(app.ax_scatter, 'Z', 'FontSize', 24);
    axis(app.ax_scatter, 'equal');
    view(app.ax_scatter, 2);
    % apply color attribute and color map
    app.val_c = getAttrValue(app, app.colorByAttributeDropDown_3.Value);
    app.scatterPlot.CData = app.val_c(app.ftr, end);
    cmap = app.colormapDropDown.Value;
    if strcmp('default', cmap)
        cmap = [0 0.4470 0.7410];
    elseif strcmp('glasbey', cmap)
        cmap = makeGlasbey(app);
    end
    colormap(app.ax_scatter, cmap);
    colorbar(app.ax_scatter);
    % create ROI button
    uicontrol('Parent', app.fig_scatter, ...
        'Style','pushbutton',...
        'Units','normalized',...
        'Position',[0.3 0.02 0.08 0.03],...
        'Fontsize',10,...
        'string','ROI',...
        'Visible','on',...
        'Callback',{@ROIButtonScatterPushed});
    % ROI button callback function
    function ROIButtonScatterPushed (~, ~) % input var differ from UIcontrol
        getSelectedIndex (app, 'Scatter');
        plotSelected(app, app.index_roi);
    end
    %linkdata(app.fig_scatter, 'on');
end
