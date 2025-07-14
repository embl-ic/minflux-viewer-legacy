function fig_render = render_localization2 (app)
    %%
    %   render a pixel based image from localization data:
    % 
    %   - 1, get active data from app:
    %       - 1, check filter (ftr) (ROI?);
    %
    %       - 2, check prop:
    %           - xyz(nm), num_dim, trace_idx
    %       - 3, calibration:
    %           - pixel_size, voxel_depth, sigma, RIMF
    %       - 4, channel:
    %           - dcr: = data.file.raw_data.dcr; % load all iteration
    %           - dcr_trace: get_dcr_trace_mean (data.channel.dcr, data.prop.trace_idx);
    %           - doChannel: false;
    %           - do_trace: false;
    %           - numC: 1, 2, 3
    %           - cut1, cut2: 1, 1;
    %           - RGB: = [1, 2, 3]; % [R G B];
    %
    %       - 5, render:
    %           - param: pixel_size, voxel_depth, sigma_xy, sigma_z, do_smooth, do_channel, posZ
    %           - posZ
    %           - roi: = [min(data.prop.xyz); max(data.prop.xyz)];
    %           - bitDepth: 8, 16, 32;
    %           - images:
    %               - param: param
    %               - image: histcounts 2D or 3D
    %
    %
    %
    %
    %
    %
    %
    %
    %
    %
    %
    %
    %
    %   - 2, get render figure of the active data:
    %       - not exist:    make new
    %           - figure name: 
    %           - generate 1st render preview:
    %
    %           - create imshow figure, get figure handle, get axes handle
    %           - auto LUT (colormap) with local density
    %           - implement keyboard shortcuts
    %           - implement right click context menus
    %           - add annotation to figure: zPos, voxel size: [], scale bar, size, scale bar
    %
    %
    %
    %
    %
    %       - exist:        update
    %
    %
    %
    %
    %   - generate preview:
    %       - get loc x, y, z in nm, calibrate Z if 3D and RIMF
    %       - 
    %
    %
    %
    %
    %
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2025.02.05
    %%
 
    % get active data from app
    idx = get_active_data_index (app);
    if isempty(idx)
        return;
    end
    global data; %#ok<GVMIS>
    data = app.data{idx};


    % load data into appeter
    load_data ();
    
    % generate preview render image
    fig_name = strcat("Render Preview : ", data.file.name);
    fig_render = findall(0, 'Type', 'figure', 'Name', fig_name);


    if isempty(fig_render)

        fig_render = figure('Name', fig_name, 'NumberTitle', 'off', 'Tag', "figure_render", "DeleteFcn", {@close_child_figure, app});
        ax = axes (fig_render);

        screenSize = groot().ScreenSize;
        fig_pos = [screenSize(3)*0.1, screenSize(4)*0.1, screenSize(4)*0.8, screenSize(4)*0.8];
        fig_render.Position = fig_pos;
    
        image_handle = imshow(data.render.images.image, 'parent', ax);
        axis( ax, 'image' );
        ax_width_pixel = round( range(ax.XAxis.Limits) );
        
        auto_lut (image_handle);
        
        % generate keyboard shortcut
        set(fig_render, 'KeyPressFcn', @keyPressed);
        
        % generate context menu corresponding to right click on figure
        cm = uicontextmenu(fig_render);
        uimenu(cm, "Text", "Calibration", "MenuSelectedFcn", @config_calibration);
        uimenu(cm, "Text", "Channel", "MenuSelectedFcn", @config_channel);
        uimenu(cm, "Text", "Gaussian Smooth", "MenuSelectedFcn", @apply_gaussian);
        uimenu(cm, "Text", "Orthogonal View", "MenuSelectedFcn", @create_ortho_views);
        uimenu(cm, "Text", "Draw ROI (to export)", "MenuSelectedFcn", @draw_roi);
        uimenu(cm, "Text", "Export to Tiff", "MenuSelectedFcn", @export_to_tiff);
        uimenu(cm, "Text", "help", "MenuSelectedFcn", @show_help);
        image_handle.ContextMenu = cm;
    
        [~, cal_box] = make_annotation ();

    else

        data.render.images = generate_preview (data.render.param);
        img = data.render.images.image;
        set(image_handle, 'cdata', img);
        auto_lut (image_handle);

    end



    %set(fig, 'SizeChangedFcn', @fig_size_changed);

    %% call back functions of UI component
    % Callback function for load track data onto the scatter plot
    function keyPressed (~, evt)

        param = data.render.param;

        switch evt.Key

            case 'leftarrow'    % z - 1*(voxel depth)
                param.posZ = max(min(data.prop.xyz(:,3)), param.posZ - param.voxel_depth);
                param.posZ = round( param.posZ * 10 ) / 10; % allow 0.1 nm precision on Z position
                img = find_image ();
                set(image_handle, 'cdata', img);
                auto_lut (image_handle);
                cal_box.String{3} = strcat("zPos: ", num2str(param.posZ), " nm");

            case 'rightarrow'   % z + 1*(voxel depth)
                param.posZ = min(max(data.prop.xyz(:,3)), param.posZ + param.voxel_depth);
                param.posZ = round( param.posZ * 10 ) / 10; % allow 0.1 nm precision on Z position
                img = find_image ();
                set(image_handle, 'cdata', img);
                auto_lut (image_handle);
                cal_box.String{3} = strcat("zPos: ", num2str(param.posZ), " nm");

            case 'downarrow'    % increase max colormap limit, plot getting dimmer
                CLim = get(ax, 'CLim');
                step = max(image_handle.CData(:)) / 100;
                CLim(2) = CLim(2) + step;
                set(ax, 'CLim', CLim);

            case 'uparrow'      % reduce max colormap limit, plot getting brighter
                CLim = get(ax, 'CLim');
                step = max(image_handle.CData(:)) / 100;
                CLim(2) = max(CLim(2) - step, CLim(1)+1);
                set(ax, 'CLim', CLim);
            
            case 'c'
                config_channel();
            
            case 'g'    % apply Gaussian filter 2D / 3D to current image
                apply_gaussian();

            case 'i'    % info
                show_help();

            case 'r'    % draw ROI: rectangle on 2D, 
                draw_roi();

            case 's'    % export to tiff
                export_to_tiff();

            case 'x'    % orthogonal view
                create_ortho_views();

            otherwise
                %disp(evt.Key + " pressed");
        end
        
        data.render.param = param;
    end

    % configure pixel and voxel size, z scaling factor (RIMF)
    function config_calibration (~, ~)
        cali = data.calibration;
        xyz = data.prop.xyz;
        param = data.render.param;

        prompt = {'pixel size (nm):', 'voxel depth (znm):', 'z scale factor:', 'Gaussian sigma (xynm, znm):'};
        title = 'calibration value:';
        dims = [1, 45];
        definput = { num2str(param.pixel_size), num2str(param.voxel_depth), num2str(cali.RIMF), num2str(cali.sigma', '%.2f, %.2f') };
        answer = inputdlg(prompt, title, dims, definput);
        if isempty(answer)
            return;
        end
        
        pixel_size_old = param.pixel_size;
        cali.pixel_size =  str2double(answer{1});
        cali.voxel_depth = str2double(answer{2});
        RIMF =   str2double(answer{3});
        cali.sigma = str2double( [split(answer{4}, ",")] );
        if isnan(cali.sigma)
            cali.sigma = [0; 0];
        elseif length(cali.sigma) < 2
            cali.sigma(2) = 0;
        end
        
        if (RIMF ~= cali.RIMF)
            xyz(:, 3) = xyz(:, 3) / cali.RIMF * RIMF;
            param.posZ = param.posZ / cali.RIMF * RIMF;
            data.render.roi(:, 3) = data.render.roi(:, 3) / cali.RIMF * RIMF;
            for i = 1 : length(data.render.images)
                z_new = data.render.images(i).param.posZ / cali.RIMF * RIMF;
                z_new = round( z_new * 10 ) / 10;
                data.render.images(i).posZ = z_new;
            end
            cali.RIMF = RIMF;
        end
        
        xlim2 = ax.XLim(2);
        img = find_image ();
        set(image_handle, 'cdata', img);
        auto_lut (image_handle);

        % re-render image with current xlim ylim
        if cali.pixel_size ~= pixel_size_old && ax.XLim(2) == xlim2
            ax.XLim = ax.XLim * pixel_size_old / cali.pixel_size;
            ax.YLim = ax.YLim * pixel_size_old / cali.pixel_size;
            drawnow;
        end

        cal_box.String{1} = strcat("pixel size: ", num2str(cali.pixel_size), " nm");
        cal_box.String{2} = strcat("voxel depth:", num2str(cali.voxel_depth), " nm");
        cal_box.String{3} = strcat("zPos: ", num2str(param.posZ), " nm");
        
        param.pixel_size = cali.pixel_size;
        param.voxel_depth = cali.voxel_depth;
        param.sigma_xy = cali.sigma(1);
        param.sigma_z = cali.sigma(2);

        data.calibration = cali;
        data.prop.xyz = xyz;
        data.render.param = param;
    end


    function config_channel (~, ~)
        disp("... getting dcr info. create channel configuration figure...");
        dcr_all = data.channel.dcr(~isnan(data.channel.dcr));
        % create histogram, draw two color Box
        fig_dcr = figure('Name', 'dcr (all iter) histogram of data');
        cm_dcr = uicontextmenu(fig_dcr);
        uimenu(cm_dcr, "Text", "Setup", "MenuSelectedFcn", @channel_setup);
        uimenu(cm_dcr, "Text", "Apply (loc)", "MenuSelectedFcn", @apply_channel_loc);
        uimenu(cm_dcr, "Text", "Apply (trace)", "MenuSelectedFcn", @apply_channel_trace);
        ax_dcr = axes(fig_dcr);
        set(ax_dcr, 'ContextMenu', cm_dcr);
        histogram(ax_dcr, dcr_all, 'Normalization', 'pdf');
        hold on;
        data.channel.cut1 = max(0, ax_dcr.XLim(1)) + 0.01;
        data.channel.cut2 = min(1, ax_dcr.XLim(2)) - 0.01;
        data.channel.keep_ch3 = false;
        data.channel.RGB = [1, 2, 3]; % default LUT is RGB for the 1st, 2nd and 3rd channels
        cut1_line = images.roi.Rectangle(ax_dcr, 'Position', [0; 0; data.channel.cut1; ax_dcr.YLim(2)]', ...
            'Color', 'r', 'LineWidth', 0.1, 'FaceAlpha', 0.2, 'InteractionsAllowed', 'all', ...
            'Deletable', 0, 'ContextMenu', cm_dcr);

        cut2_line = images.roi.Rectangle(ax_dcr, 'Position', [data.channel.cut2; 0; 1-data.channel.cut2; ax_dcr.YLim(2)]', ...
            'Color', 'g', 'LineWidth', 0.1, 'FaceAlpha', 0.2, 'InteractionsAllowed', 'all', ...
            'Deletable', 0, 'ContextMenu', cm_dcr);
        drawnow;
        % perform linear gaussian mixture fit
        disp("... fitting Gaussian mixture model onto dcr histogram...")
        model1 = fitgmdist(dcr_all, 1);
        model2 = fitgmdist(dcr_all, 2);
        if model2.Converged && model2.AIC < model1.AIC && model2.BIC < model1.BIC && range(model2.ComponentProportion) < 0.6 % probably double channel data   
            mid = ( model2.mu(1)*sqrt(model2.Sigma(2))  +  model2.mu(2)*sqrt(model2.Sigma(1)) ) / sum(sqrt(model2.Sigma));
            x = 0 : 1e-2 : 1; y = pdf(model2, x');
            id_c = find(x>mid, 1, 'first');
            half_sum = 2.5 - 0.5*y(id_c);
            ysum1 = arrayfun(@(i) sum(y(id_c-i:id_c-1)), 1:id_c-1 );
            data.channel.cut1 = find(ysum1 >= half_sum, 1, 'first');
            ysum2 = arrayfun(@(i) sum(y(id_c+1:id_c+i)), 1:101-id_c );
            data.channel.cut2 = find(ysum2 >= half_sum, 1, 'first');
            data.channel.cut1 = (id_c - data.channel.cut1) / 100;
            data.channel.cut2 = (id_c + data.channel.cut2) / 100;
            plot(x, y, 'r-');
            set(cut1_line, 'Position', [0; 0; data.channel.cut1; ax_dcr.YLim(2)]');
            set(cut2_line, 'Position', [data.channel.cut2; 0; 1-data.channel.cut2; ax_dcr.YLim(2)]');
        else
            disp("... dcr distribution cannot be used to separate channels!"); 
        end
        hold off;

        function channel_setup (~, ~)
            d = dialog('Position', [300 300 200 150], 'Name', 'setup');
            uicontrol('Parent',d, 'Style','text', 'Position',[55 110 65 20],...
                   'String', 'Channel 1:', 'FontWeight', 'bold');
            color1 = uicontrol('Parent',d, 'Style','popup', 'Position',[60 95 55 15],...
                   'String', {'Red'; 'Green'; 'Blue'}, 'Value', 1);
            value1 = uicontrol('Parent',d, 'Style','edit', 'Position',[60 70 55 15],...
                   'String', num2str(cut1_line.Position(1) + cut1_line.Position(3)), 'Max', 1, 'Min', 0 );
            uicontrol('Parent',d, 'Style','text', 'Position',[125 110 65 20],...
                   'String', 'Channel 2:', 'FontWeight', 'bold');
            color2 = uicontrol('Parent',d, 'Style','popup', 'Position',[130 95 55 15],...
                   'String', {'Red'; 'Green'; 'Blue'}, 'Value', 2);
            value2 = uicontrol('Parent',d, 'Style','edit', 'Position',[130 70 55 15],...
                   'String', num2str(cut2_line.Position(1)), 'Max', 1, 'Min', 0 );
            uicontrol('Parent',d, 'Style','text', 'Position',[0 95 55 15],...
                   'String', 'Color:', 'FontWeight', 'bold');
            uicontrol('Parent',d, 'Style','text', 'Position',[0 70 55 15],...
                   'String', 'Value:', 'FontWeight', 'bold');
            do_ch3 = uicontrol('Parent',d, 'Style','checkbox', 'Position',[10 45 200 15],...
                   'String', 'keep middle portion in 3rd channel', 'Value', data.channel.keep_ch3 );
            uicontrol('Parent',d, 'Position',[100 10 55 25],'String','OK', 'Callback', @finish);

            uiwait(d);
            function finish (~, ~)
                data.channel.cut1 = str2double(value1.String);
                data.channel.cut2 = str2double(value2.String);
                set(cut1_line, 'Color', color1.String{color1.Value}, 'Position', [0; 0; data.channel.cut1; ax_dcr.YLim(2)]');
                set(cut2_line, 'Color', color2.String{color2.Value}, 'Position', [data.channel.cut2; 0; 1-data.channel.cut2; ax_dcr.YLim(2)]');
                data.channel.keep_ch3 = do_ch3.Value;
                %delete(d);
            end
        end


        % apply channel set up to rendered image
        function apply_channel_loc (~, ~)
            apply_channel ( false );
        end
        
        % apply channel set up to rendered image
        function apply_channel_trace (~, ~)
            apply_channel ( true );
        end

        function apply_channel ( on_trace )
            data.channel.do_trace = on_trace;
            data.channel.doChannel = true;
            data.channel.cut1 = cut1_line.Position(1) + cut1_line.Position(3);
            data.channel.cut2 = cut2_line.Position(1);
            if data.channel.keep_ch3
                app.numC = 3;
            else
                app.numC = 2;
            end
            data.channel.RGB(1) = find(cut1_line.Color);
            data.channel.RGB(2) = find(cut2_line.Color);
            img = find_image ();
            set(image_handle, 'cdata', img);
            auto_lut (image_handle);
        end

    end
    

    function apply_gaussian (~, ~)
        % apply 2D or 3D Gaussian to histogram rendered image
        sigma = data.calibration.sigma;
        if sigma(1) == 0
            return;
        end

        data.render.param.do_smooth = ~data.render.param.do_smooth;

        img = find_image ();
        set(image_handle, 'cdata', img);
        auto_lut (image_handle);

    end


    function create_ortho_views (~, ~)
        if data.prop.num_dim == 2
            return;
        end
        x = data.prop.xyz(:, 1); y = data.prop.xyz(:, 2); z = data.prop.xyz(:, 3);
        xedge = min(x) : data.calibration.pixel_size : max(x) + data.calibration.pixel_size;
        yedge = min(y) : data.calibration.pixel_size : max(y) + data.calibration.pixel_size;
        zedge = min(z) : data.calibration.voxel_depth : max(z) + data.calibration.voxel_depth;
        numX = length(xedge) - 1; numY = length(yedge) - 1 ; numZ = length(zedge) - 1;

        if data.channel.doChannel
            ch_idx = getChannelIdx (true);
            counts_xy = zeros( [numX, numY, 3] );
            counts_xz = zeros( [numX, numZ, 3] );
            counts_zy = zeros( [numZ, numY, 3] );
            for c = 1 : 3
                if all(ch_idx(:, c)==0)
                    continue;
                end
                counts_xy(:, :, c) = histcounts2 (x(ch_idx(:, c)), y(ch_idx(:, c)), xedge, yedge);
                counts_xz(:, :, c) = histcounts2 (x(ch_idx(:, c)), z(ch_idx(:, c)), xedge, zedge);
                counts_zy(:, :, c) = histcounts2 (z(ch_idx(:, c)), y(ch_idx(:, c)), zedge, yedge);
            end
        else
            counts_xy = histcounts2 (x, y, xedge, yedge);
            counts_xz = histcounts2 (x, z, xedge, zedge);
            counts_zy = histcounts2 (z, y, zedge, yedge);
        end
        
        fig_xy = figure('Name', 'XY view', 'NumberTitle', 'off', 'CloseRequestFcn', @close_all);
        if app.doSmooth && data.calibration.sigma(1) > 0
            sigmaXY = data.calibration.sigma(1) / data.calibration.pixel_size;
            auto_lut( imshow(imgaussfilt(counts_xy, [sigmaXY, sigmaXY]), 'parent', axes(fig_xy)) );
        else
            auto_lut( imshow(counts_xy, 'parent', axes(fig_xy)) );
        end
        
        pos_xy = fig_xy.Position;
        fig_xy.Position = [groot().ScreenSize(3)/2-pos_xy(3), groot().ScreenSize(4)-pos_xy(4)-120, pos_xy(3), pos_xy(4)];
        pos_xy = fig_xy.Position;
        
        width_z = 200;
        
        fig_xz = figure('Name', 'XZ view', 'NumberTitle', 'off', 'Position', [pos_xy(1)+pos_xy(3)+1, pos_xy(2), width_z, pos_xy(4)], 'CloseRequestFcn',@close_all);
        fig_zy = figure('Name', 'ZY view', 'NumberTitle', 'off', 'Position', [pos_xy(1), pos_xy(2)-200, pos_xy(3), width_z], 'CloseRequestFcn',@close_all);
        
        
        if app.doSmooth && data.calibration.sigma(2) > 0
            sigmaZ = data.calibration.sigma(2) / data.calibration.voxel_depth;
            auto_lut( imshow(imgaussfilt(counts_xz, [sigmaXY, sigmaZ]), 'parent', axes(fig_xz)) );
            auto_lut( imshow(imgaussfilt(counts_zy, [sigmaZ, sigmaXY]), 'parent', axes(fig_zy)) );
        else
            auto_lut( imshow(counts_xz, 'parent', axes(fig_xz)) );
            auto_lut( imshow(counts_zy, 'parent', axes(fig_zy)) );
        end


        function close_all (~, ~)
            delete(fig_xy);
            delete(fig_xz);
            delete(fig_zy);
        end

    end

    
    function draw_roi (~, ~)
        roi = app.roi;
        roi(:, 3) = roi(:, 3) - min(data.prop.xyz(:, 3)); % ROI Z coordinate to figure coordinates minZ : maxZ to 0 : rangeZ
        px = data.calibration.pixel_size; vx = data.calibration.voxel_depth;
        if roi(1, 1) == min( data.prop.xyz(:, 1) )
            xMin = range(ax.YLim) * 0.05 + ax.YLim(1); 
        else
            xMin = roi(1, 1) / px;
        end

        if roi(1, 2) == min( data.prop.xyz(:, 2) )
            yMin = range(ax.XLim) * 0.05 + ax.XLim(1); 
        else
            yMin = roi(1, 2) / px;
        end

        if roi(2, 1) == max( data.prop.xyz(:, 1) )
            xMax = range(ax.YLim) * 0.95 + ax.YLim(1); 
        else
            xMax = roi(2, 1) / px;
        end

        if roi(2, 2) == max( data.prop.xyz(:, 2) )
            yMax = range(ax.XLim) * 0.95 + ax.XLim(1); 
        else
            yMax = roi(2, 2) / px;
        end
        
        zMin = 0; zMax = 0;     % z min and max in figure coordinate

        if data.prop.num_dim == 2     % 2D case
            roi_xy = images.roi.Rectangle(ax, 'Color', 'y', 'LineWidth', 0.1, 'Position', [yMin; xMin; yMax-yMin; xMax-xMin]');
            fig_xy = fig_render;
        else
            fig_xy = findobj( 'Type', 'Figure', 'Name', 'XY view' );
            fig_xz = findobj( 'Type', 'Figure', 'Name', 'XZ view' );
            fig_zy = findobj( 'Type', 'Figure', 'Name', 'ZY view' );
            if isempty(fig_xy) || isempty(fig_xz) || isempty(fig_zy)    
                create_ortho_views;
            end % orthogonal view already exist
            fig_xy = findobj( 'Type', 'Figure', 'Name', 'XY view' );
            fig_xz = findobj( 'Type', 'Figure', 'Name', 'XZ view' );
            fig_zy = findobj( 'Type', 'Figure', 'Name', 'ZY view' );
            ax_xy = get(fig_xy,'Children');
            ax_xz = get(fig_xz,'Children');
            ax_zy = get(fig_zy,'Children');
            
            ZLim = min( range(ax_xz.XLim), range(ax_zy.YLim) );   % get Z axis size
            if roi(1, 3) == 0   %min( data.prop.xyz(:, 3) )
                zMin = ZLim * 0.25 + 0.5; 
            else
                zMin = roi(1, 3) / vx;
            end
    
            if roi(2, 3) == range( data.prop.xyz(:, 3) )
                zMax = ZLim * 0.75 + 0.5; 
            else
                zMax = roi(2, 3) / vx;
            end

            roi_xy = images.roi.Rectangle(ax_xy, 'Color', 'y', 'LineWidth', 0.1, 'Deletable', 0, 'Position', [yMin; xMin; yMax-yMin; xMax-xMin]');
            roi_xz = images.roi.Rectangle(ax_xz, 'Color', 'y', 'LineWidth', 0.1, 'Deletable', 0, 'Position', [zMin; xMin; zMax-zMin; xMax-xMin]');
            roi_zy = images.roi.Rectangle(ax_zy, 'Color', 'y', 'LineWidth', 0.1, 'Deletable', 0, 'Position', [yMin; zMin; yMax-yMin; zMax-zMin]');
            
            addlistener(roi_xz, 'ROIMoved', @update_roi);
            addlistener(roi_zy, 'ROIMoved', @update_roi);
            addlistener(roi_xy, 'ObjectBeingDestroyed', @delete_roi);
            addlistener(roi_xz, 'ObjectBeingDestroyed', @delete_roi);
            addlistener(roi_zy, 'ObjectBeingDestroyed', @delete_roi);
        end

        addlistener(roi_xy, 'ROIMoved', @update_roi);
        cm_roi = uicontextmenu(fig_xy);
        uimenu(cm_roi, "Text", "Cancel", "MenuSelectedFcn", @remove_roi);
        uimenu(cm_roi, "Text", "Apply", "MenuSelectedFcn", @apply_roi);
        set(roi_xy, 'ContextMenu', cm_roi);


        function update_roi (src, ~)
            pos = src.Position;
            switch src
                case roi_xy
                    yMin = pos(1);          xMin = pos(2); 
                    yMax = pos(1) + pos(3); xMax = pos(2) + pos(4);
                case roi_xz
                    zMin = pos(1);          xMin = pos(2); 
                    zMax = pos(1) + pos(3); xMax = pos(2) + pos(4);
                case roi_zy
                    yMin = pos(1);          zMin = pos(2); 
                    yMax = pos(1) + pos(3); zMax = pos(2) + pos(4);
            end
            %app.roi = [xMin, yMin, zMin; xMax, yMax, zMax];

            if any(data.prop.xyz(:,3) ~= 0)
                roi_xy.Position = [yMin; xMin; yMax-yMin; xMax-xMin]';
                roi_xz.Position = [zMin; xMin; zMax-zMin; xMax-xMin]';
                roi_zy.Position = [yMin; zMin; yMax-yMin; zMax-zMin]';
            end
        end

        function delete_roi (~, ~)
            delete(roi_xy);
            delete(roi_xz);
            delete(roi_zy);
        end
        
        function remove_roi (~, ~)
            delete(roi_xy);
            app.roi = [min(data.prop.xyz); max(data.prop.xyz)];
        end

        function apply_roi (~, ~)
            app.roi = [xMin*px, yMin*px, zMin*vx; xMax*px, yMax*px, zMax*vx];
            app.roi(:, 3) = app.roi(:, 3) + min(data.prop.xyz(:, 3));   % apply the z offset
            delete(roi_xy);
        end

    end


    function export_to_tiff (~, ~)
        % check bit depth here:
        %disp("current image max value: " + max(image_handle.CData(:)) ) ;
        %disp("app bit depth: " + app.bitDepth);

        % export to tiff file with current setting: pixel size, voxel size, channel option, roi bounds
        if isempty(app.file.name) || isempty(app.file.folder)
            save_path = "";
        else
            save_path = fullfile(app.file.folder, strcat(app.file.name(1 : end-4), ".tiff"));
        end
        [tif_name, tif_dir] = uiputfile('*.tiff', "save to tiff file", save_path);
        if isequal(tif_name, 0) || isequal(tif_dir, 0)
           return;
        end

        % calculate render image dimensions
        xedge = app.roi(1, 1) : data.calibration.pixel_size  : app.roi(2, 1) + data.calibration.pixel_size;
        yedge = app.roi(1, 2) : data.calibration.pixel_size  : app.roi(2, 2) + data.calibration.pixel_size;
        zedge = app.roi(1, 3) : data.calibration.voxel_depth : app.roi(2, 3) + data.calibration.voxel_depth;
        
        % call write to TIFF function
        success = false;

        if data.channel.doChannel
            ch_idx = getChannelIdx (false);
            for c = 1 : 3
                pathSave = fullfile(tif_dir, strcat(tif_name(1 : end-5), "_C", num2str(c), ".tiff"));
                success = render_to_tiff_file (data.prop.xyz, xedge, yedge, zedge, pathSave, ch_idx(:, c))  || success;
            end
        else    % no channel separation
            pathSave = fullfile(tif_dir, tif_name);
            success = render_to_tiff_file (data.prop.xyz, xedge, yedge, zedge, pathSave);
        end

        if success
            if data.channel.doChannel
                pathSave = extractBefore(pathSave, '_C') + "_C{i}.tiff";
            end
            
            h = questdlg(["Save to TIFF Completed."; "Open File Location?"], "Completed", 'YES', 'NO', 'YES');
            switch h
              case 'YES'
                 winopen( tif_dir );
              case 'NO'
                 disp("TIFF file saved to:");
                 disp(pathSave);
              otherwise
            end


            % mh = msgbox(['Saved to file:'; ''; pathSave], "Export to TIFF completed");
            % th = findall(mh, 'Type', 'Text');                   %get handle to text within msgbox
            % th.FontSize = 12; 
            % deltaWidth = sum(th.Extent([1,3]))-mh.Position(3) + th.Extent(1);
            % deltaHeight = sum(th.Extent([2,4]))-mh.Position(4) + 10;
            % mh.Position([3,4]) = mh.Position([3,4]) + [deltaWidth, deltaHeight];
        end

    end


    function show_help (~, ~)
        title = "info.";
        line1 = ["right click in figure to access menu options."; ""];
        line2 =  "default mouse actions apply:";
        line3 = ["        scroll to zoom / click and drag to move"; ""];
        line4 =  "use left ⇔ right arrow key to move along Z:";
        line5 = ["        each click move 1 voxel depth in Z"; ""];
        line6 =  "use up ⇕ down arrow key to adjust brightness:";
        line7 = ["        up is brighter, and down is dimmer"; ""];
        line8 =  "other keyboard shortcuts:";
        line9 =  "        c - Channel Configuration";
        line10 =  "        x - Orthogonal View";
        line11 =  "        r - Draw ROI (to export)";
        line12 = "        g - Gaussian Smooth 2D / 3D";
        line13 = "        f - Load Data";
        line14 = "        s - Export to Tiff";
        line15 = "        i - show info";
        msgbox([line1; line2; line3; line4; line5; line6; line7; line8; line9; line10; line11; line12; line13; line14; line15], title);
    end
    

%% member functions
    function load_data ()
        % calculation of Localization Precision, do not apply Gaussian filter by default
        if ~isfield(data, 'calibration')
            data.calibration = struct;
        end
        if ~isfield(data.calibration, 'sigma') || isempty( data.calibration.sigma )
            data.calibration.sigma = compute_Loc_precision( app );
        end
        % prepare coordinate data, convert to nanometer, apply z scaling, and re-zero
        if ~isfield(data.calibration, 'RIMF')
            data.calibration.RIMF = 0.67;   % default z scale is 0.67
        end


        % init render ROI, and bit depth
        data.render.roi = [min(data.prop.xyz); max(data.prop.xyz)];
        data.render.bitDepth = 16;

        % init render image parameters:
        data.render.param.do_smooth = false;
        data.render.param.do_channel = false;
        data.render.param.posZ = 0;
        

        % read dcr, plot histogram, get initial value of separation
        data.channel.dcr = data.file.raw_data.dcr; % load all iteration
        data.channel.dcr_trace = get_dcr_trace_mean (data.channel.dcr, data.prop.trace_idx);
        %data.channel.doChannel = false;
        data.channel.do_trace = false;
        data.channel.numC = 1;
        data.channel.cut1 = 1;
        data.channel.cut2 = 1;
        data.channel.RGB = [1, 2, 3];
        

        % generate preview figure
        pixel_size = min(range(data.prop.xyz(:, 1:2))) * 2 / max(groot().ScreenSize(3:4));
        data.calibration.pixel_size = pixel_size;
        
        if data.prop.num_dim == 3
            data.calibration.voxel_depth = pixel_size;
        else
            data.calibration.voxel_depth = 0;
        end
        data.render.param.pixel_size = data.calibration.pixel_size;
        data.render.param.voxel_depth = data.calibration.voxel_depth;
        data.render.param.sigma_xy = data.calibration.sigma(1);
        data.render.param.sigma_z = data.calibration.sigma(2);


        %data.render = struct;
        %data.render.posZ = 0;
        data.render.images = generate_preview (data.render.param);

        % data.render.images = struct("pixel_size", data.calibration.pixel_size, "voxel_depth", data.calibration.voxel_depth, "posZ", 0, ...
        %     "smoothed", false, "sigmaXY", data.calibration.sigma(1), "sigmaZ", data.calibration.sigma(2), ...
        %     "c", data.channel.numC, "channelTrace", data.channel.do_trace, "cut1", data.channel.cut1, "cut2", data.channel.cut2, "RGB", data.channel.RGB, ...
        %     "image", generate_preview ());
    end



    function dcr_trace = get_dcr_trace_mean (dcr, trace_idx)
        dcr_trace = arrayfun(@(id) mean( dcr(trace_idx(id,1) : trace_idx(id,2), :), 2, "omitnan"),  1:length(trace_idx), 'uni', 0);
        dcr_trace = cell2mat(dcr_trace');
    end


    function auto_lut (h_img)
        cdata = h_img.CData;
        if size(cdata, 3) == 3      % RGB image
            % check if need to adjust RGB channel colormap limit
        else
            cmax = prctile(cdata(cdata ~= 0), 95);
            set(get(h_img, 'parent'), 'colormap', hot);
            if cmax ~= 0
                clim(get(h_img, 'parent'), [0, cmax]);
            end
        end
        drawnow;
    end


    function img = find_image ( param )
        if nargin < 1
            param = data.render.param;
        end

        % if nargin < 2
        %     do_smooth = data.render.do_smooth;
        % end
        % if nargin < 1
        %     posZ = data.render.posZ;
        % end


        param.posZ = round( param.posZ * 10 ) / 10; % allow 0.1 nm precision on Z position
        images = data.render.images;
        
        exist = arrayfun(@(x) isequaln(x, param), [images.param]);

        % exist = ...
        %     [images.z] == posZn & ...
        %     [images.pixel_size] == data.calibration.pixel_size & ...
        %     [images.voxel_depth] == data.calibration.voxel_depth & ...
        %     [images.smoothed] == do_smooth & ...
        %     [images.sigmaXY] == data.calibration.sigma(1) & ...
        %     [images.sigmaZ] == data.calibration.sigma(2) & ...
        %     [images.c] == app.numC & ...
        %     [images.channelTrace] == data.channel.do_trace & ...
        %     [images.cut1] == data.channel.cut1 & ...
        %     [images.cut2] == data.channel.cut2 & ...
        %     cellfun(@(imageRGB) isequaln(imageRGB, data.channel.RGB), {images.RGB});
        
        if any(exist)
            img = images(exist).image;
        else    % image not exist, render new one and store to app
            
            %img = generate_preview ( param );
            data.render.images(end+1) = generate_preview ( param );
            img = data.render.images(end).image;
            % data.render(end+1) = struct( ...
            %     "pixel_size", data.calibration.pixel_size, "voxel_depth", data.calibration.voxel_depth, "z", posZn, ...
            %     "smoothed", do_smooth, "sigmaXY", data.calibration.sigma(1), "sigmaZ", data.calibration.sigma(2), ...
            %     "c", app.numC, "channelTrace", data.channel.do_trace, "cut1", data.channel.cut1, "cut2", data.channel.cut2, "RGB", data.channel.RGB, ...
            %     "image", img);
        end

    end


    function image = generate_preview (param)
        % check first if RAM is still avaiable to store cached images
        check_memory ();
        % get localization xyz coordinates
        ftr = data.attr.ftr;
        xyz = data.prop.xyz(ftr, :);
        % generate histogram preview
        if param.do_channel
            ch_idx = getChannelIdx (true);
            xedge = min(xyz(:,1)) : param.pixel_size : max(xyz(:,1)) + param.pixel_size;
            yedge = min(xyz(:,2)) : param.pixel_size : max(xyz(:,2)) + param.pixel_size;
            counts = zeros(length(xedge)-1, length(yedge)-1, 3);
            for c = 1 : 3
                if all(ch_idx(:, c)==0)
                    continue;
                end
                counts(:, :, c) = get2Dhist (xyz, param.posZ, param.pixel_size, param.voxel_depth, param.do_smooth, ch_idx(:, c));
            end
        else
            counts = get2Dhist (xyz, param.posZ, param.pixel_size, param.voxel_depth, param.do_smooth);
        end
        % create image struct, with render parameter
        param.posZ = round( param.posZ * 10 ) / 10;
        image = struct("param", param, "image", counts);
    end


    % function counts = generate_preview ( posZ, do_smooth )
    %     % generate new histcount rendered 2d image
    % 
    %     % check first if RAM is still avaiable to store cached images
    %     check_memory ();
    % 
    %     if nargin < 2
    %         do_smooth = false;     % apply Gaussian filter or not 
    %     end
    %     if nargin < 1
    %         posZ = 0;              % position of Z
    %     end
    % 
    %     if data.render.param.do_channel
    %         ch_idx = getChannelIdx (true);
    %         xedge = min(data.prop.xyz(:,1)) : data.calibration.pixel_size : max(data.prop.xyz(:,1)) + data.calibration.pixel_size;
    %         yedge = min(data.prop.xyz(:,2)) : data.calibration.pixel_size : max(data.prop.xyz(:,2)) + data.calibration.pixel_size;
    %         counts = zeros(length(xedge)-1, length(yedge)-1, 3);
    %         for c = 1 : 3
    %             if all(ch_idx(:, c)==0)
    %                 continue;
    %             end
    %             counts(:, :, c) = get2Dhist (data.prop.xyz, posZ, data.calibration.pixel_size, ...
    %                 data.calibration.voxel_depth, do_smooth, ch_idx(:, c));
    %         end
    %     else
    %         counts = get2Dhist (data.prop.xyz, posZ, data.calibration.pixel_size, data.calibration.voxel_depth, do_smooth);
    %     end
    % 
    % end

    function ch_idx = getChannelIdx ( apply_RGB )
        if data.channel.do_trace
            dcr = data.channel.dcr_trace;
        else
            dcr = data.channel.dcr(:, end);
        end
        
        ch_idx = false(length(dcr), 3);
        if apply_RGB
            ch_idx(:, data.channel.RGB(1)) = dcr >= 0 & dcr < data.channel.cut1;   %R
            ch_idx(:, data.channel.RGB(2)) = dcr >= data.channel.cut2 & dcr <= 1;  %G 
        else
            ch_idx(:, 1) = dcr >= 0 & dcr < data.channel.cut1;   % 1st channel
            ch_idx(:, 2) = dcr >= data.channel.cut2 & dcr <= 1;  % 1st channel
        end
        if data.channel.keep_ch3
            ch_idx(:, 3) = dcr >= data.channel.cut1 & dcr < data.channel.cut2;  %B
        end
    end
    


    function counts = get2Dhist (xyz, zPos, pixel_size, voxel_depth, do_smooth, idx)
        if nargin < 6
            idx = true(length(xyz), 1);
        end
        
        % make histogram bin edges of X, and Y axis
        x = xyz(:, 1); y = xyz(:, 2); z = xyz(:, 3);
        xedge = min(x) : pixel_size : max(x) + pixel_size;
        yedge = min(y) : pixel_size : max(y) + pixel_size;
        numX = length(xedge) - 1;  numY = length(yedge) - 1;

        if ~do_smooth       % no Gaussian blur, just compute 2D histogram
            if data.prop.num_dim == 3 && voxel_depth ~= 0 % 3D case, compute hist 2D from voxel depth defined 3D volume
                idx = idx & z >= zPos - voxel_depth & z < zPos + voxel_depth;
            end
            counts = histcounts2 (x(idx), y(idx), xedge, yedge);

        else                % do Gaussian blur, compute 3D histogram, and apply Gaussian kernel

            % compute dimension of input image (hist 2D) to be convolved with 3D Gaussian kernel
            sigma = data.calibration.sigma;
            sigma(1) = sigma(1) / pixel_size;  % XY sigma in unit of pixel
            sigma(2) = sigma(2) / voxel_depth; % Z sigma in unit of voxel
            zFilterSize = 2*sigma(2) ; % half of the Gaussian filter size in number of voxels along Z axis (size 1 size)
            % check if 2D data, or voxel size 0, or kernel Z size smaller than 1 voxel 
            if data.prop.num_dim == 2 || sigma(2) == 0 || zFilterSize < 1.0 % 2D case
                counts_2d = histcounts2 (x(idx), y(idx), xedge, yedge);
                counts = imgaussfilt(counts_2d, sigma(1), 'Padding', 0);
            else
                zFilterSize = ceil( zFilterSize );
                % construct Z edge, so that it put current Z position in the center, and evenly spaced with voxel depth
                zedge = (-zFilterSize - 0.5 : zFilterSize + 0.5) * voxel_depth + zPos;
                numZ = length(zedge) - 1;
                s = floor( (numZ - 1) / 4 ); slice_save = [1-s:0, 2:s+1] + zFilterSize;
                
                num_voxel = numX * numY * numZ;
                %counts_3d = get3Dhist (data.prop.xyz, xedge, yedge, zedge);
                if num_voxel * ( sigma(1)*2 + sigma(2) ) > exp(1)*1e8
                    disp("... Computing 3D histogram with dimension:");
                    disp("...    " + numX + " * " + numY + " * " + numZ + " voxels...");
                    tic; counts_3d = histcounts3 (x(idx), y(idx), z(idx), xedge, yedge, zedge); toc;
                    disp("... Filtering with 3D Gaussian kernel:");
                    disp("...    " + ( 2*ceil(2*sigma(1))+1 ) + " * " + ( 2*ceil(2*sigma(1))+1 ) + " * " + ( 2*ceil(2*sigma(2))+1 ) + " voxels...");
                    tic; img_gauss_3d = imgaussfilt3(counts_3d, [sigma(1), sigma(1), sigma(2)], 'Padding', 0); toc;
                else
                    counts_3d = histcounts3 (x(idx), y(idx), z(idx), xedge, yedge, zedge);
                    img_gauss_3d = imgaussfilt3(counts_3d, [sigma(1), sigma(1), sigma(2)], 'Padding', 0);
                end
                
                % save useful 3D slices into cached appeter
                for i = 1 : numZ
                    posZ = zedge(i) + 0.5; posZn = round( posZ * 10 ) / 10;
                    data.render(end+1) = struct( ...
                        "pixel_size", pixel_size, "voxel_depth", voxel_depth, "z", posZn, ...
                        "smoothed", false, "sigmaXY", data.calibration.sigma(1), "sigmaZ", data.calibration.sigma(2), ...
                        "c", app.numC, "channelTrace", data.channel.do_trace, "cut1", data.channel.cut1, "cut2", data.channel.cut2, "RGB", data.channel.RGB, ...
                        "image", counts_3d (:, :, i));
                    if ismember(i, slice_save)
                        data.render(end+1) = struct( ...
                        "pixel_size", pixel_size, "voxel_depth", voxel_depth, "z", posZn, ...
                        "smoothed", true, "sigmaXY", data.calibration.sigma(1), "sigmaZ", data.calibration.sigma(2), ...
                        "c", app.numC, "channelTrace", data.channel.do_trace, "cut1", data.channel.cut1, "cut2", data.channel.cut2, "RGB", data.channel.RGB, ...
                        "image", img_gauss_3d (:, :, i));
                    end
                end

                counts = img_gauss_3d (:, :, zFilterSize+1);  % only take center slice? maybe not efficient in the future

            end

        end

        maxCount = max(counts(:));
        % check the data type to store the pixel value dynamic range
        if maxCount <= 255
            data.render.bitDepth = 8;
            counts = uint8(counts);
        elseif maxCount <= 65535
            data.render.bitDepth = 16;
            counts = uint16(counts);
        else
            counts = uint32(counts);
            data.render.bitDepth = 32;    % !!! may not work with ImageJ !!!
            warning("max counts exceed unsigned 16 bit limit!");
            show_outlier ( counts >= 2e16 );
        end
    end
    

    % custom histcounts3 function, it is faster than slice by slice histcount2d approach
    function counts = histcounts3 (x, y, z, xedge, yedge, zedge)
        numX = length(xedge) - 1;
        numY = length(yedge) - 1;
        numZ = length(zedge) - 1;
        % Compute bin indices for each dimension
        binIdxX = discretize(x, xedge);
        binIdxY = discretize(y, yedge);
        binIdxZ = discretize(z, zedge);
        nidx = ~isnan(binIdxX) & ~isnan(binIdxY) & ~isnan(binIdxZ);
        counts = uint16( accumarray([binIdxX(nidx), binIdxY(nidx), binIdxZ(nidx)], 1, [numX, numY, numZ]) );
        if max(counts(:)) <= 255
            counts = uint8( counts );
        end
    end


    function success = render_to_tiff_file (xyz, xedge, yedge, zedge, save_path, channel_idx)
        success = false;
        % parse input appeters
        if nargin < 6
            channel_idx = true(length(xyz), 1);
        end
        % no channel separation
        if all( channel_idx == 0 )
            return;
        end
        % compute X, Y, Z dimensions, be aware of row or column first indexing
        x = xyz(channel_idx, 1); y = xyz(channel_idx, 2); z = xyz(channel_idx, 3);
        numX = length(xedge) - 1;
        numY = length(yedge) - 1;
        numZ = length(zedge) - 1;
        numZ = max(1, numZ);
        % populate TIFF property structure, same for 2D/3D image
        tagstruct.ImageLength = numX;
        tagstruct.ImageWidth =  numY;
        tagstruct.ResolutionUnit = Tiff.ResolutionUnit.Centimeter;  % pixel size only avaialbe in centimeter
        tagstruct.XResolution = 1e7 / data.calibration.pixel_size;
        tagstruct.YResolution = 1e7 / data.calibration.pixel_size;
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = app.bitDepth;    %  8, 16, or 32 bit gray value image
        tagstruct.SampleFormat = 1;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = ['MATLAB ', version('-release'), ' (voxle depth: ', num2str(data.calibration.voxel_depth), ' nm)']; % use software field to record voxel depth
        % single TIFF file size larger than 4GB will need w8 write format
        if numX * numY * numZ * app.bitDepth > 2^35 
            t = Tiff(save_path, 'w8');   % big TIFF, will trigger Bio-format
        else
            t = Tiff(save_path, 'w');
        end
        % Create a progress bar to monitor the exporting process
        f = waitbar(0, 'preparing', 'Name', 'Export to TIFF...', 'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
        setappdata(f, 'canceling', 0);
        try
            %disp("Export rendered localization to file: ");
            %disp(save_path);
            for slice = 1 : numZ
                % enable user cancel action with progress bar
                if getappdata(f,'canceling')
                    warning('TIFF export terminated by user.');
                    close(t);
                    delete(f);
                    return;
                end
                % get z coordinates corresponding to current Z edge
                if data.prop.num_dim == 2
                    idx = true(length(z), 1);
                else
                    idx = z >= zedge( slice ) & z < zedge( slice + 1 );
                end
                % populate image pixel data of current Z slice
                if sum(idx) ~= 0
                    count_2d = histcounts2(x(idx), y(idx), xedge, yedge);
                else
                    count_2d = zeros(numX, numY);
                end
                % update progress bar
                formatSpec = ['Writing  Z slice %d / ', num2str(numZ), ' ...'];
                waitbar( slice/numZ, f, sprintf(formatSpec, slice) );
                % prepare Tiff object for writing to file
                setTag(t, tagstruct);
                
                switch app.bitDepth
                    case 8
                        write(t, uint8(count_2d));
                    case 16
                        write(t, uint16(count_2d));
                    case 32
                        write(t, uint32(count_2d));
                end

                if slice ~= numZ
                    t.writeDirectory();
                end
            end

        catch ME
            close(t);
            delete(f);
            warning('Error occured during TIFF export!');
            rethrow(ME);
        end

        close(t);
        delete(f);
        success = true;
    end
    

    function show_outlier (idx_outlier)
        [xpos, ypos] = find(idx_outlier);
        disp("...Extreme pixel value coordinates:")
        for i = 1 : length(idx_outlier)
            disp("...   X: " + xpos(i)  + ", Y: " + ypos(i));
        end
    end


    function [scale_bar, cal_box] = make_annotation ()
        % scale bar is a line with width corresponding to figure width;
        % scale bar max width is 1/3 axes width, right edge is always 0.9 axes width
        % scale bar physical width = ( bar_width / axes width * loc_y range )  nm
        % scale bar should be [1, 2, 5, 10, 20, 50, 100, 200, 500] of [nm, um, mm] 
        % max width should be 100 um; with min width 10 nm
        
        param = data.render.param;

        ax_pos = ax.Position;
        nm_width_list = [1, 2, 5, 10, 20, 50, 1e2, 2e2, 5e2, 1e3, 2e3, 5e3, 1e4, 2e4, 5e4, 1e5, 2e5, 5e5, 1e6];
        min_width_ratio_axes = 0.1; max_width_ratio_axes = 0.4; % scale bar width should be between 0.1 - 0.25 axes width

        axes_width_nm = range( data.prop.xyz(:, 2) );
        axes_width_ratio = ax_pos(3);
        %axes_width_pixel = range( ax.XLim );
        
        width_nm = 0;
        for i = 1 : length(nm_width_list) % locate minimum suitable scale bar width in nm
            width_ratio_axes = nm_width_list(i) / axes_width_nm;
            if width_ratio_axes >= min_width_ratio_axes && width_ratio_axes <= max_width_ratio_axes
                width_nm = nm_width_list(i);
                break;
            end
        end

        width_ratio_axes = width_nm / axes_width_nm * axes_width_ratio;
        right_edge = ax_pos(1)+ax_pos(3) - 0.01; bottom_edge = ax_pos(2) + 0.02;

        bar_xpos = [right_edge-width_ratio_axes, right_edge];
        bar_ypos = [bottom_edge, bottom_edge];

        width = width_nm; unit = " nm";
        if width >= 5e5
            width = width / 1e6;
            unit = " mm";
        elseif width >= 500
            width = width / 1e3;
            unit = " um";
        end
        bar_str = string(width) + unit;
        
        scale_bar = annotation(fig_render, 'line', bar_xpos, bar_ypos);
        scale_bar.Color = "white";
        scale_bar.LineWidth = 4;
        
        % create a calibration annotation on upper left corner of current axes
        cal_str = { ...
            strcat("pixel size: ", num2str(param.pixel_size), " nm"), ...
            strcat("voxel depth:", num2str(param.voxel_depth), " nm"), ...
            strcat("zPos: ", num2str(param.posZ), " nm"), ...
            strcat("scale bar: ", bar_str) };
        cal_box = annotation(fig_render, 'textbox', [ax_pos(1) + 0.01, ax_pos(2) + ax_pos(4) - 0.11, 0.3, 0.1], ...
            'String', cal_str, 'Color', 'w', 'FitBoxToText', 'on');
        cal_box.FontWeight = 'bold';

        set(ax.XAxis, 'LimitsChangedFcn', @axLimitChanged);
        set(fig_render, 'SizeChangedFcn', @fig_size_changed);
    
        function axLimitChanged (src, ~)
            if round(range (src.Limits)) == ax_width_pixel
                return;
            end
            ax_width_pixel = round(range (src.Limits));
            %min_width_nm = ax_width_pixel * param.pixel_size * min_width_ratio_axes;
            ax_width_nm = ax_width_pixel * param.pixel_size;
            max_width_nm = ax_width_nm * max_width_ratio_axes;
            idx = find(nm_width_list<max_width_nm, 1, 'last');
            width_nm = nm_width_list(idx);
            pos = ax.Position;
            width_ratio_axes = width_nm / (range (src.Limits) * param.pixel_size);
            % calculate scale bar width in ratio to figure
            width_ratio_fig = width_ratio_axes * pos(3);
            
            right_edge = pos(1) + pos(3); 
            
            w_ax = fig_render.Position(3) * pos(3);
            h_ax = fig_render.Position(4) * pos(4);
            w_img = range(image_handle.XData) + 1;
            h_img = range(image_handle.YData) + 1;
            if w_ax / w_img > h_ax / h_img      % margin on left and right edge
                % calculate on the horizontal axis, the ratio to the figure of where the image left border sit
                margin = ( w_ax - (h_ax / h_img * w_img) ) / 2 / fig_render.Position(3);
                %left_edge = left_edge + margin;
                right_edge = right_edge - margin;
                width_ratio_fig = width_nm / ax_width_nm * ( h_ax / h_img * w_img / fig_render.Position(3) );
            end
            
            bottom_edge = pos(2) + pos(4)*0.02;
            bar_xpos = [right_edge - 0.01 - width_ratio_fig, right_edge - 0.01];
            bar_ypos = [bottom_edge, bottom_edge];
            scale_bar.X = bar_xpos;
            scale_bar.Y = bar_ypos;

            width = width_nm; unit = " nm";
            if width >= 5e5
                width = width / 1e6;
                unit = " mm";
            elseif width >= 500
                width = width / 1e3;
                unit = " um";
            else
                unit = " nm";
            end
            bar_str = string(width) + unit;
            cal_box.String{4} = strcat("scale bar: ", bar_str);
        end

        function fig_size_changed (~, ~)
            param = data.render.param;

            fg_pos = fig_render.Position();
            ax_pos = ax.Position;
            
            ax_width_pixel = round(range (ax.XAxis.Limits) );
            ax_width_nm = ax_width_pixel * param.pixel_size;
            width_ratio = width_nm / ax_width_nm * ax_pos(3);

            w_ax = fg_pos(3) * ax_pos(3);
            h_ax = fg_pos(4) * ax_pos(4);
    
            w_img = range(image_handle.XData) + 1;
            h_img = range(image_handle.YData) + 1;
            
            left_edge =  ax_pos(1); %ax l + (w-w_img) / 2;
            right_edge = ax_pos(1) + ax_pos(3);
            bottom_edge = ax_pos(2);
            up_edge = ax_pos(2) + ax_pos(4);
    
            if w_ax / w_img > h_ax / h_img      % margin on left and right edge
                % calculate on the horizontal axis, the ratio to the figure of where the image left border sit
                margin = ( w_ax - (h_ax / h_img * w_img) ) / 2 / fg_pos(3);
                left_edge = left_edge + margin;
                right_edge = right_edge - margin;

                width_ratio = width_nm / ax_width_nm * ( h_ax / h_img * w_img / fg_pos(3) );
      
            else                                % margin on bottom and up edge
                margin = ( h_ax - (w_ax / w_img * h_img) ) / 2 / fg_pos(4);
                bottom_edge = bottom_edge + margin;
                up_edge = up_edge - margin;
            end
    
            cal_box.Position(1) = left_edge + 0.01;
            cal_box.Position(2) = up_edge - cal_box.Position(4) - 0.01;
    
            bar_ypos = [bottom_edge + ax_pos(4)*0.02, bottom_edge + ax_pos(4)*0.02];
            
            scale_bar.X = [right_edge - 0.01 - width_ratio, right_edge - 0.01];
            scale_bar.Y = bar_ypos;
        end

    end
   


    function check_memory ()
        MinAvailableMem = 5 * 1024^3;   % minimum RAM left avaiable is 5 GB
        MaxRemoveMem = 2 * 1024^3;      % maximum RAM to be freed each time is 2 GB
        MaxRemoveImage = 10;            % remove maximum 10 images in cache each time
        if memory().MaxPossibleArrayBytes > MinAvailableMem
            return;
        end
        mem_removed = 0; img_removed = 0;
        while mem_removed <= MaxRemoveMem & img_removed <= MaxRemoveImage
            mem_before = memory().MemUsedMATLAB;
            data.render.images(1) = [];
            img_removed = img_removed + 1;
            mem_removed = mem_removed + mem_before - memory().MemUsedMATLAB;
        end
    end
    
end