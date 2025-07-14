function fig_line = plot_attribute (app)
    
    % get active data from app
    idx = get_active_data_index (app);
    if isempty(idx)
        return;
    end
    data = app.data{idx};
    
    
    attr_names = data.prop.attr_names;
    attrs = data.attr;
    ftr = attrs.ftr;

    fig_name = strcat("Attribute Plot : ", data.file.name);

    fig_line = findall(0, 'Type', 'figure', 'Name', fig_name);


    if isempty(fig_line)

        fig_line = uifigure('Name', fig_name, 'NumberTitle', 'off', 'Tag', "figure_attribute", "DeleteFcn", {@close_child_figure, app});
        ax = axes (fig_line);
        screenSize = groot().ScreenSize;
        fig_line.Position = [screenSize(3)*0.5-320, screenSize(4)*0.5-352, 640, 704];
        
        val_x = attrs.idx(ftr, :);
        val_y = attrs.efo(ftr, :);
        val_z = attrs.idx(ftr, :);
    
        line_plot = plot3(ax, val_x, val_y, val_z, '.');
        view(ax, 2);
        ax.XGrid = 'on'; ax.YGrid = 'on'; ax.ZGrid = 'on';

        xlabel(ax, 'idx', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel(ax, 'efo', 'FontSize', 12, 'FontWeight', 'bold');
        zlabel(ax, 'idx', 'FontSize', 12, 'FontWeight', 'bold');

        ax.Position = [0.13, 0.125, 0.825, 0.825];
    
        % X axis data label and selection
        uilabel( ...
                        'Parent', fig_line, ...
                        'Position', [95 22 49 22], ...
                        'Fontsize', 12, ... %'FontWeight', 'bold', ...
                        'Text', 'attribute');
        attr_list_x = uidropdown( ...
                        'Parent', fig_line, ...
                        'Position' , [149 22 80 22], ...
                        'Fontsize' , 12, ...
                        'Items', attr_names, ...
                        'Value', 'idx', ...
                        'ValueChangedFcn', @data_x_changed);
        attr_list_x.Tag = "attr_x";

        % Y axis data label and selection
        uilabel( ...
                        'Parent', fig_line, ...
                        'Position', [250 22 49 22], ...
                        'Fontsize', 12, ... %'FontWeight', 'bold', ...
                        'Text', 'attribute');
        attr_list_y = uidropdown( ...
                        'Parent', fig_line, ...
                        'Position' , [309 22 80 22], ...
                        'Fontsize' , 12, ...
                        'Items', attr_names, ...
                        'Value', 'efo', ...
                        'ValueChangedFcn', @data_y_changed);
        attr_list_y.Tag = "attr_y";

        % Z axis data label and selection
        uilabel( ...
                        'Parent', fig_line, ...
                        'Position', [410 22 49 22], ...
                        'Fontsize', 12, ... %'FontWeight', 'bold', ...
                        'Text', 'attribute');
        attr_list_z = uidropdown( ...
                        'Parent', fig_line, ...
                        'Position' , [469 22 80 22], ...
                        'Fontsize' , 12, ...
                        'Items', attr_names, ...
                        'Value', 'idx', ...
                        'ValueChangedFcn', @data_z_changed);
        attr_list_z.Tag = "attr_z";

        % additional line axis label to indicate default orientation
        uilabel( ...
                        'Parent', fig_line, ...
                        'Position', [105 10 80 24], ...
                        'Fontsize', 24, ... %'FontWeight', 'bold', ...
                        'Text', '⎯⎯', ...
                        'Tooltip', 'X axis');
        uilabel( ...
                        'Parent', fig_line, ...
                        'Position', [268 5 30 24], ...
                        'Fontsize', 18, ... %'FontWeight', 'bold', ...
                        'Text', '│', ...
                        'Tooltip', 'Y axis');
        uilabel( ...
                        'Parent', fig_line, ...
                        'Position', [425 5 30 24], ...
                        'Fontsize', 18, ... %'FontWeight', 'bold', ...
                        'Text', '╱', ...
                        'Tooltip', 'Z axis');


    else
        
        line_plot = findobj(fig_line, 'Type', 'line');
        ax_line = findobj(fig_line, 'Type', 'axes');

        attr_list_x = findobj(fig_line, 'Type', 'uidropdown', 'Tag', 'attr_x');
        attr_list_y = findobj(fig_line, 'Type', 'uidropdown', 'Tag', 'attr_y');
        attr_list_z = findobj(fig_line, 'Type', 'uidropdown', 'Tag', 'attr_z');
        
        line_xlim = ax_line.XLim;
        line_ylim = ax_line.YLim;
        line_zlim = ax_line.ZLim;

        line_plot.XData = attrs.(attr_list_x.Value)(ftr, :);
        line_plot.YData = attrs.(attr_list_y.Value)(ftr, :);
        line_plot.ZData = attrs.(attr_list_z.Value)(ftr, :);

        ax_line.XLim = line_xlim;
        ax_line.YLim = line_ylim;
        ax_line.ZLim = line_zlim;

    end

    function data_x_changed (~, ~)
        val_x = attrs.(attr_list_x.Value)(ftr, :);
        ax.XLabel.String = attr_list_x.Value;
        line_plot.XData = val_x;
        axis(ax, 'auto');
    end

    function data_y_changed (~, ~)
        val_y = attrs.(attr_list_y.Value)(ftr, :);
        ax.YLabel.String = attr_list_y.Value;
        line_plot.YData = val_y;
        axis(ax, 'auto');
    end

    function data_z_changed (~, ~)
        val_z = attrs.(attr_list_z.Value)(ftr, :);
        ax.ZLabel.String = attr_list_z.Value;
        line_plot.ZData = val_z;
        axis(ax, 'auto');
    end


end