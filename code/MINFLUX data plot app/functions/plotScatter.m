function plotScatter (app)
    if (isempty(app.data) || ~isfield(app.data, 'loc_x'))
        return;
    end
    if isempty(app.xyz)
        getLocData(app);
    end
    app.fig_scatter = findobj( 'Type', 'Figure', 'Name', 'MINFLUX 3D Scatter Plot' );
    
    global scale_bar;
    
    
    if isempty(app.fig_scatter)
        app.fig_scatter = figure('Name', 'MINFLUX 3D Scatter Plot');
        app.fig_scatter.Position = [1000, 100, 1024, 1024];
        %app.fig_scatter.NumberTitle = 'off';
        bg_color = [1, 1, 1];
    else
        bg_color = 1 - gca().Color;
    end

    %app.fig_scatter.Position(3) = 1024;
    %app.fig_scatter.Position(4) = 1024;
    set(0, 'CurrentFigure', app.fig_scatter);
    app.scatterPlot = scatter3(app.xyz(app.ftr,1), app.xyz(app.ftr,2), app.xyz(app.ftr,3), '.');
    
    app.scatterPlot.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("tid",  num2cell(app.data.tid(app.ftr)));
    app.ax_scatter = gca;
    xlabel(app.ax_scatter, 'Xnm', 'FontSize', 24);
    ylabel(app.ax_scatter, 'Ynm', 'FontSize', 24);
    zlabel(app.ax_scatter, 'Znm', 'FontSize', 24);
    axis(app.ax_scatter, 'equal');
    view(app.ax_scatter, 2);

    app.ax_scatter.Color = bg_color;


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
        'Position',[0.2 0.02 0.08 0.03],...
        'Fontsize',10,...
        'string','ROI',...
        'Visible','on',...
        'Callback',{@ROIButtonScatterPushed});
    uicontrol('Parent', app.fig_scatter, ...
        'Style','togglebutton',...
        'Units','normalized',...
        'Position',[0.4 0.02 0.12 0.03],...
        'Fontsize',10,...
        'Min', 0, 'Max', 1, ...
        'string','Scale Bar',...
        'Visible','on',...
        'Callback',{@toggleScaleBar});
    sc_length = uicontrol('Parent', app.fig_scatter, ...
        'Style','edit',...
        'Units','normalized',...
        'Position',[0.53 0.02 0.12 0.03],...
        'Fontsize',10,...
        'String','500',...
        'Visible','on');
    uicontrol('Parent', app.fig_scatter, ...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.65 0.02 0.12 0.03],...
        'Fontsize',10,...
        'string','nm',...
        'Visible','on');

    % ROI button callback function
    function ROIButtonScatterPushed (~, ~) % input var differ from UIcontrol
        getSelectedIndex (app, 'Scatter');
        plotSelected(app, app.index_roi);
    end

    function toggleScaleBar (src, ~)
        if src.Value == 0 % delete scale bar
            if ~isempty(scale_bar)
                delete( scale_bar );
            end
            return;
        end
        
        width = str2double(sc_length.String);
        height = width/10;
        %roi = drawcrosshair(app.ax_scatter, 'Label', 'scale bar center position');
        %pos = roi.Position; 
        %disp(pos);
        posx = app.ax_scatter.XAxis.Limits(1) + 0.1 * (range (app.ax_scatter.XAxis.Limits) );
        posy = app.ax_scatter.YAxis.Limits(1) + 0.05 * (range (app.ax_scatter.YAxis.Limits) );
        % position in nm

        %pos_ax = app.ax_scatter.Position;
        %delete( roi );
        
        scale_bar = images.roi.Rectangle(app.ax_scatter, 'Color', 'w', 'FaceAlpha', 1, 'Position', [posx, posy, width, height], ...
            'FaceSelectable', false, 'InteractionsAllowed', "translate", "MarkerSize", 0.01, "LineWidth", 0.01);

    end
    %linkdata(app.fig_scatter, 'on');
end
