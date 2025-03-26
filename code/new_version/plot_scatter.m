function fig_scatter = plot_scatter (app)

    if isempty(app.data) || ~isfield(app.data, 'attr') || ~isfield(app.data.attr, 'loc_x')
        return;
    end

    x = app.data.attr.loc_x * 1e9;
    y = app.data.attr.loc_y * 1e9;
    z = app.data.attr.loc_z * 1e9 * app.data.prop.RIMF;
    
    ftr = app.data.attr.ftr;
    fig_name = strcat("Loc Scatter Plot : ", app.data.file.name);

    fig_scatter = findall(0, 'Type', 'figure', 'Name', fig_name);

    if isempty(fig_scatter)
        fig_scatter = uifigure('Name', fig_name, 'NumberTitle', 'off', 'Tag', "figure_scatter", "DeleteFcn", @delete_fig);
        ax = axes (fig_scatter);
        
        if isfield(app.data.attr, 'density')
            density = app.data.attr.density;
        else
            density = compute_local_density (x, y, z);
            app.data.attr.density = density;
            app.data.prop.attr_names{end+1} = 'density';
        end
        scatter_plot = scatter3 (ax, x, y, z, 1, density);
        scatter_plot.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("tid",  num2cell(app.data.attr.tid));
    
    
        colormap(ax, "jet");
        mu = mean(density);
        sd = std(single(density));
        clim(ax, [mu-sd, mu+sd]);
        cb = colorbar(ax);
        cb.Label.String = "density";
        cb.Label.FontSize = 12;

        xlabel(ax, 'X', 'FontSize', 18);
        ylabel(ax, 'Y', 'FontSize', 18);
        zlabel(ax, 'Z', 'FontSize', 18);
        axis(ax, 'equal');
        view(ax, 2);

    else

        scatter_plot = findobj(fig_scatter, 'Type', 'scatter');
        scatter_plot.XData = x(ftr, 1);
        scatter_plot.YData = y(ftr, 1);
        scatter_plot.ZData = z(ftr, 1);
        %scatter_plot.CData = 
        % check Cdata, and ROI

    end

    
    


    function delete_fig (~, ~)
        idx = find( cellfun(@(x) isequal(x, fig_scatter), app.children_apps) );
        app.children_apps(idx) = [];
    end


    

end