function apply_filter_to_data (app)
    % disp("apply filter takes:");
    % tic;

    %ftr = app.data.attr.ftr;
    tags_all = cellfun(@(window) window.Tag, app.children_apps, 'uni', 0);

    %!!! add tag to figure and apps.

    for i = 1 : length(tags_all)
        
        if ~startsWith(tags_all{i}, "figure")
            continue;
        end
        
        tag = extractAfter(tags_all{i}, "figure_");

        fig = app.children_apps{i}; % get figure handle
        if iscell(fig)
            fig = fig{1};
        end
        if isempty(fig)
            continue;
        end

        switch tag
            case "attribute"
                fig = plot_attribute (app);
                
            case "histogram"
                fig = plot_histogram (app);

            case "scatter"
                fig = plot_scatter (app);

            case "render"
                fig = render_localization (app);

        end
        
        app.children_apps{i} = fig;


        % sc_handle = findobj(fig, 'Type', 'scatter');
        % if ~isempty(sc_handle)
        %     sc_handle.CData = cdata;
        % end
        % img_handle = findobj(fig, 'Type', 'image');
        % if ~isempty(img_handle)
        %     img_handle.CData = cdata;
        % end
        % 
        % 
        % 
        % app.linePlot.XData = app.val_1(app.ftr, :);
        % app.linePlot.YData = app.val_2(app.ftr, :);
        % 
        % app.val_hist = getHistPlotValue (app);


    end

    % toc;
end