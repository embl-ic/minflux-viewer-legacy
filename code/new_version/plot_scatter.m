function fig_scatter = plot_scatter (app)

    % get active data from app
    idx = get_active_data_index (app);
    if isempty(idx)
        return;
    end
    data = app.data{idx};

    xnm = data.attr.loc_x * 1e9;
    ynm = data.attr.loc_y * 1e9;
    znm = data.attr.loc_z * 1e9 * data.cali.RIMF;
    
    ftr = data.attr.ftr;
    fig_name = strcat("Loc Scatter Plot : ", data.file.name);

    fig_scatter = findall(0, 'Type', 'figure', 'Name', fig_name);

    if isempty(fig_scatter)
        fig_scatter = uifigure('Name', fig_name, 'NumberTitle', 'off', 'Tag', "figure_scatter", "DeleteFcn", {@close_child_figure, app});
        ax_scatter = axes (fig_scatter);

        if isfield(data.cali, 'local_density')
            density = data.cali.local_density;
        else
            density = compute_local_density (xnm, ynm, znm);
            app.data{idx} = add_attribute_to_data (data, 'den', density, 41);
            app.data{idx}.cali.local_density = density;
            % data.prop.attr_names{end+1} = 'density'; % add density also to attribute list for plotting and investigation later
        end
        %scatter_plot = scatter3 (ax, xnm(ftr), ynm(ftr), znm(ftr), 1, density(ftr));
        scatter_plot = scatter3 (ax_scatter, xnm(ftr), ynm(ftr), znm(ftr), '.');
        scatter_plot.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("tid",  num2cell(data.attr.tid(ftr)));    
        scatter_plot.CData = density(ftr);

        colormap(ax_scatter, "hot");
        mu = mean(density);
        sd = std(single(density));
        clim(ax_scatter, [mu-sd, mu+sd]);
        cb = colorbar(ax_scatter);
        cb.Label.String = 'density';
        cb.Label.FontSize = 12;

        xlabel(ax_scatter, 'X (nm)', 'FontSize', 18);
        ylabel(ax_scatter, 'Y (nm)', 'FontSize', 18);
        zlabel(ax_scatter, 'Z (nm)', 'FontSize', 18);
        axis(ax_scatter, 'equal');
        set(ax_scatter,'Color', [0.75, 0.75, 0.75]);
        view(ax_scatter, 2);

    else
        
        scatter_plot = findobj(fig_scatter, 'Type', 'scatter');
        ax_scatter = findobj(fig_scatter, 'Type', 'axes');
        %set(ax_scatter, 'NextPlot', 'replacechildren');

        scatter_xlim = ax_scatter.XLim;
        scatter_ylim = ax_scatter.YLim;
        scatter_zlim = ax_scatter.ZLim;
        
        cb = findobj(fig_scatter, 'Type', 'colorbar');
        cval_str = cb.Label.String;
        if strcmp(cval_str, 'density')
            cval_str = "den";
        end
        cval = data.attr.(cval_str);

        scatter_plot.XData = xnm(ftr);
        scatter_plot.YData = ynm(ftr);
        scatter_plot.ZData = znm(ftr);
        scatter_plot.CData = cval(ftr);
        %app.scatterPlot.DataTipTemplate.DataTipRows(end).Value = num2cell(data.attr.tid(ftr));
        
        ax_scatter.XLim = scatter_xlim;
        ax_scatter.YLim = scatter_ylim;
        ax_scatter.ZLim = scatter_zlim;

    end


end