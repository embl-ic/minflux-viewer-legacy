function fig_render = render_test (app)   
    
    % get active data from app
    idx = get_active_data_index(app);
    if isempty(idx)
        return;
    end
    data = app.data{idx};
    
    % get property, attributes, calibration, and channel parameters from data
    prop = data.prop; attr = data.attr; cali = data.cali; channel = data.channel;
    % prop: num_dim, trace_idx, num_loc_per_trace
    % attr:
    % calibraion: RIMF, loc_precision, local_density
    % channel: dcr, dcr_trace, numC, cut1, cut2, do_trace, keep_ch3
    if isfield (cali, 'loc_precision')
        cali.loc_precision = compute_Loc_precision (data);
        app.data{idx}.cali.loc_precision = cali.loc_precision;
    end

    % get parameters necessary for rendering:
    RIMF = cali.RIMF;
    ftr = data.attr.ftr;
    
    xnm = -attr.loc_y(ftr) * 1e9;       % image axis is transposed, and y-> direction is up to down
    ynm =  attr.loc_x(ftr) * 1e9;
    znm =  attr.loc_z(ftr) * 1e9 * RIMF;
    znm = znm - mean(znm);
    sigma_xy = cali.loc_precision(1);
    sigma_z = cali.loc_precision(2);
    pixel_size = round( min(range(xnm), range(ynm)) / 1024 ) ; % default pixel size to make a 1024 pixel along shorter axis
    voxel_depth = pixel_size;

    % compute x, y edges for 2D histogram, z range between 2.5% ~ 97.5% quantile
    xedge = min(xnm) : pixel_size : max(xnm) + pixel_size;
    yedge = min(ynm) : pixel_size : max(ynm) + pixel_size;
    z_fiveQuantile = quantile(znm, [0.025, 0.975]);
    zMin = floor( z_fiveQuantile(1) ); %double( floor(min(z)) ); 
    zMax = ceil ( z_fiveQuantile(2) ); %double( ceil(max(z)) );

    zSliderRange = 2*round( std(znm) ); %double( (zMax - zMin) / 20 );
    zSliderRangeMin = double(0); % minimum Z size is 1 nm;
    zSliderRangeMax = zMax - zMin + 1;
    counts_3d = histcounts3(xnm, ynm, znm, xedge, yedge, [zMin, zMax], true);
    
    % create figure window, add rendered image to axes, add UI components and callbacks


    fig_name = strcat("Render Preview : ", data.file.name);
    fig_render = findall(0, 'Type', 'figure', 'Name', fig_name);
    
    if isempty( fig_render)

        fig_render = uifigure('Name', fig_name, 'NumberTitle', 'off', 'Tag', "figure_render", "DeleteFcn", {@close_child_figure, app});
        ax = axes(fig_render);
        img = imshow( counts_3d, [], 'parent', ax);
        axis( ax, 'image' );
        colormap(ax, 'hot');
        ax.Position(2) = 0.13; ax.Position(4) = 0.795; % [0.1300 0.1100 0.7750 0.8150]  [left bottom width height] normalized to figure window
        auto_lut(img);
        
        pos = fig_render.Position;
        %pos_ax = ax.Position; % [left bottom width height] normalized unit
    
        % UI position: [left bottom width height] inside figure window, pixel unit
        pos_edge_size = 60; ui_size = 40; spacing = 5;
    
        pos_label = [45, pos_edge_size, 25, ui_size];
    
        pos_slider = [pos_label(1)+pos_label(3), 20 + pos_edge_size, pos(3)-260, 3];
    
        pos_checkbox =  [pos_slider(1) + pos_slider(3) + 3*spacing,  pos_edge_size, 80, ui_size];
    
        pos_rangespinner = [pos_checkbox(1) + pos_checkbox(3), 10 + pos_edge_size, 90, 20];
        
        
        left_edge = 45; bottom_edge = 20; margin = 10; w_btn = 65; h_btn = 20;

        pos_btn1 = [left_edge, bottom_edge, w_btn, h_btn];
    
        pos_btn2 = [pos_btn1(1) + pos_btn1(3) + margin, bottom_edge, w_btn, h_btn];
    
        pos_btn3 = [pos_btn2(1) + pos_btn2(3) + margin, bottom_edge, w_btn, h_btn];
    
        pos_btn4 = [pos_btn3(1) + pos_btn3(3) + margin, bottom_edge, w_btn, h_btn];
    
        pos_btn5 = [pos_btn4(1) + pos_btn4(3) + margin, bottom_edge, w_btn, h_btn];
        
        pos_btn6 = [pos_btn5(1) + pos_btn5(3) + margin, bottom_edge, w_btn, h_btn];
    
        pos_label2 = [pos_checkbox(1) + pos_checkbox(3)-25, bottom_edge, 25, h_btn];
    
        pos_BCspinner = [pos_checkbox(1) + pos_checkbox(3), bottom_edge, 90, h_btn];
    
    
        % 1st row of UI control components:
        % Z slider; lock Z range checkbox; Z range spinner
    
                    uilabel( ...
                            'Parent', fig_render, ...
                            'Position', pos_label, ...
                            'Fontsize', 15, ...
                            'FontWeight', 'bold', ...
                            'Text', 'Z');
    
        zpos_slider = uislider( ...
                         fig_render, 'range', 'Tag', "zpos_slider", ...
                        'Position' , pos_slider, ...%[20 40 uint16(pos(3)-120)+1 20], ...
                        'Fontsize' , 12, ...
                        'Value', [double(-zSliderRange/2), double(zSliderRange/2)], ...
                        'Limits', [double(zMin), double(zMax)], ...
                        'Step', 1, ...
                        'MinorTicks', [], ... 
                        'ValueChangedFcn', @zSliderValue_update); %'ValueChangingFcn', @zSliderValue_update, ...
    
        lock_range = uicheckbox( ...
                        'Parent', fig_render, 'Tag', 'zrange_lock', ...
                        'Position', pos_checkbox, ...%[20 40 uint16(pos(3)-120)+1 20], ...
                        'Fontsize', 12, ...
                        'Text', 'lock range', ...
                        'Value', 0, ...
                        'ValueChangedFcn', @lock_zrange);
                        
        zrange_spinner = uispinner( ... %uieditfield( ...
                        'Parent', fig_render, 'Tag', "zrange_spinner", ...
                        'Position', pos_rangespinner, ...%[20 40 uint16(pos(3)-120)+1 20], ...
                        'ValueDisplayFormat', "%.1f (nm)", ...
                        'Fontsize', 12, ...
                        'Value', zSliderRange, ...
                        'Limits', [zSliderRangeMin, zSliderRangeMax], ...
                        'ValueChangedFcn', @zRange_update);
        
    
        % 2nd row of UI control components: 
        % Gaussian; Show Info.; Channel; ROI; Ortho-Views; Save to Tiff...; brightness spinner
    
                uibutton( ...
                        fig_render, 'state', 'Tag', 'info_btn', ...
                        'Position', pos_btn1, ...
                        'Fontsize', 12, ...
                        'Text', 'Show Info.', ...
                        'ValueChangedFcn', @fcn_annotation);
    
        gaussian_button = uibutton( ...
                        fig_render, 'state', 'Tag', 'gauss_btn', ...
                        'Position', pos_btn2, ...
                        'Fontsize', 12, ...
                        'Text', 'Gaussian', ...
                        'ValueChangedFcn', @fcn_gaussian);
    
                uibutton( ...
                        fig_render, 'state', 'Tag', 'channel_btn', ...
                        'Position', pos_btn3, ...
                        'Fontsize', 12, ...
                        'Text', 'Channel', ...
                        'ValueChangedFcn', @fcn_channel);
    
                uibutton( ...
                        'Parent', fig_render, 'Tag', 'roi_btn', ...
                        'Position', pos_btn4, ...
                        'Fontsize', 12, ...
                        'Text', 'ROI', ...
                        'ButtonPushed', @setup_roi);
    
                uibutton( ...
                        'Parent', fig_render, 'Tag', 'orthoview_btn', ...
                        'Position', pos_btn5, ...
                        'Fontsize', 12, ...
                        'Text', 'OrthoView', ...
                        'ButtonPushed', @show_orthoview);
                
                uibutton( ...
                        'Parent', fig_render, 'Tag', 'tiff_btn', ...
                        'Position', pos_btn6, ...
                        'Fontsize', 12, ...
                        'Text', 'Tiff...', ...
                        'ButtonPushed', @export_to_tiff);
    
                uilabel( ...
                            'Parent', fig_render, ...
                            'Position', pos_label2, ...
                            'Fontsize', 12, ...
                            'Text', 'B/C');
    
        cmax_spinner = uispinner( ...
                        'Parent', fig_render, 'Tag', "cmax_spinner", ...
                        'Position', pos_BCspinner, ...
                        'Fontsize', 12, ...
                        'HorizontalAlignment', 'left', ... 
                        'Value', ax.CLim(2), ...  %'AllowEmpty', 'on', ...
                        'Limits', [0, Inf], ...  
                        'Step', 1, ...
                        'ValueChangedFcn', @cmax_update, ...
                        'ValueChangingFcn', @cmax_update);
    
    
        % add figure window resize func, to dynamic position the UI control components
        %set (fig_render, 'ResizeFcn', @figureResized);
        % add figure window keyboard shortcuts
        %set (fig_render, 'KeyPressFcn', @keyPressed);




    else
        
        ax = findobj(fig_render, 'Type', 'axes');
        img = findobj(fig_render, 'Type', 'histogram');
        set(img, 'cdata', counts_3d);
        auto_lut(img);

    end


    
    

    

    function zSliderValue_update (src, evt)
        
        minValue = evt.Value(1);
        maxValue = evt.Value(2);

        if strcmp(evt.EventName, "ValueChanged") && lock_range.Value
            % range locked, and update finished
            rangeValue = zrange_spinner.Value;
            updateValue = evt.Value - evt.PreviousValue;
            
            % valid update of range slider, sync the other slider to the same range
            % 
            % update value 1: left slider: <0: moved left, 0: no move; >0: moved right
            % update value 2: right slider: <0: moved left, 0: no move; >0: moved right
            %
            % condition 1: - && - : both moved to left
            %   right spinner moved over previous left spinner position
            %   A: take current left spinner value, add range to udpate the right spinner position
            %
            % condition 2: - && 0 : left moved left, right not moved
            %   left spinner moved to the left
            %   A: take current left spinner value, add range to udpate the right spinner position
            %
            % condition 3: - && + : NOT POSSIBLE 
            %   C: do nothing
            %
            % condition 4: 0 && - : left not moved, right moved left
            %   right spinner moved to left, but not over previous left spinner position
            %   B: take current right spinner value, substract range to udpate the left spinner position
            %
            % condition 5: 0 && 0 : both not moved
            %   C: do nothing
            %
            % condition 6: 0 && + : left not moved, right moved right 
            %   right spinner moved to the right
            %   B: take current right spinner value, substract range to udpate the left spinner position
            %
            % condition 7: + && - : NOT POSSIBLE
            %   C: do nothing
            %
            % condition 8: + && 0 : left moved right, right not moved 
            %   left spinner moved to right, but not over previous right spinner position
            %   A: take current left spinner value, add range to udpate the left spinner position
            %
            % condition 9: + && + : both moved to right
            %   left spinner moved over previous right spinner position
            %   B: take current right spinner value, substract range to udpate the left spinner position

            l = updateValue(1); r = updateValue(2);

            if (l<0 && r<=0) || (l>0 && r==0)
                % A case: take left value, add range to right
                maxValue = minValue + rangeValue;
            elseif (r>0 && l>=0) || (r<0 && l==0)
                % B case: take right value, substract to left
                minValue = maxValue - rangeValue;
            else                                    
                % C case: do nothing
            end

            if maxValue >= zMax
                maxValue = zMax; minValue = maxValue - rangeValue;
            elseif minValue <= zMin
                minValue = zMin; maxValue = zMin + rangeValue;
            else
            end
            src.Value = [minValue, maxValue];

        end
        
        if ~lock_range.Value     % update z range field value if not locked
            zrange_spinner.Value = maxValue-minValue;
        end

        counts_3d = histcounts3(xnm, ynm, znm, xedge, yedge, [minValue, maxValue], true);
        set(img, 'cdata', counts_3d);
        %clim auto;
        auto_lut(img);

    end



    function lock_zrange (~, evt)
        if evt.Value
            zrange_spinner.Enable = 'off';
        else
            zrange_spinner.Enable = 'on';
        end   
    end


    function zRange_update (~, evt)

        minValue = zpos_slider.Value(1);
        %maxValue = zpos_slider.Value(2);
        zSliderRange = evt.Value;
        
        % if maxValue == zMax             % slider right border touches max
        %     minValue = max(zMin, maxValue - zSliderRange);
        % end
        % 
        % if minValue == zMin             % slider left border touches min
        %     maxValue = min(zMax, minValue + zSliderRange);
        % end

        % slider between [min, max], change range on max first
        maxValue = min(zMax, minValue + zSliderRange);
        minValue = max(zMin, maxValue - zSliderRange);
        if minValue == zMin
            maxValue = zMin + zSliderRange;
        end
        
        zpos_slider.Value = [minValue, maxValue];
        counts_3d = histcounts3(xnm, ynm, znm, xedge, yedge, [minValue, maxValue], true);
        set(img, 'cdata', counts_3d);
        auto_lut(img);
    end




    function fcn_annotation (~, evt)
        pause(0.5);     % delay to recognize two click as double click
        if strcmpi(fig_render.SelectionType, 'open')   % double click to setup
	        setup_annotation(); % disp('Double click');
        else            % single click to toggle display of scale annotation
	        toggle_annotation(evt.Value)% disp('Single click');
        end
    end
    

    function fcn_gaussian (~, evt)
        %pause(0.5);          % delay to recognize two click as double click
        if strcmpi(fig_render.SelectionType, 'open')    % double click to setup
	        setup_gaussian(); 
        else        % single click to toggle Gaussian blur on/off of image
            toggle_gaussian(evt.Value);
        end
    end
    

    function fcn_channel (~, evt) 
        pause(0.5);          % delay to recognize two click as double click
        if strcmpi(fig_render.SelectionType, 'open')   % double click to setup
	        setup_channel();% disp('Double click');
        else        % single click to toggle multi- or single- channel view
	        toggle_channel(evt.Value); % disp('Single click');
        end
    end


    function setup_roi (src, evt) 
        

    end
    

    function show_orthoview (src, evt) 
        if prop.num_dim == 2
            return;
        end

        xedge = min(xnm) : pixel_size : max(xnm) + pixel_size;
        yedge = min(ynm) : pixel_size : max(ynm) + pixel_size;
        zedge = min(znm) : voxel_depth : max(znm) + voxel_depth;
        %numX = length(xedge) - 1; numY = length(yedge) - 1 ; numZ = length(zedge) - 1;

        % if param.channel.doChannel
        %     ch_idx = getChannelIdx (true);
        %     counts_xy = zeros( [numX, numY, 3] );
        %     counts_xz = zeros( [numX, numZ, 3] );
        %     counts_zy = zeros( [numZ, numY, 3] );
        %     for c = 1 : 3
        %         if all(ch_idx(:, c)==0)
        %             continue;
        %         end
        %         counts_xy(:, :, c) = histcounts2 (xnm(ch_idx(:, c)), ynm(ch_idx(:, c)), xedge, yedge);
        %         counts_xz(:, :, c) = histcounts2 (xnm(ch_idx(:, c)), znm(ch_idx(:, c)), xedge, zedge);
        %         counts_zy(:, :, c) = histcounts2 (znm(ch_idx(:, c)), ynm(ch_idx(:, c)), zedge, yedge);
        %     end
        % else
            counts_xy = histcounts2 (xnm, ynm, xedge, yedge);
            counts_xz = histcounts2 (xnm, znm, xedge, zedge);
            counts_zy = histcounts2 (znm, ynm, zedge, yedge);
        %end
        
        fig_xy = figure('Name', 'XY view', 'NumberTitle', 'off', 'CloseRequestFcn', @close_all);
        if gaussian_button.Value && sigma_xy > 0
            sigmaXY = sigma_xy / pixel_size;
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
        
        
        if gaussian_button.Value && sigma_z > 0
            sigmaZ = sigma_z / voxel_depth;
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
    

    function export_to_tiff (src, evt)


    end



    function cmax_update (~, evt)
        clim(ax, [0, evt.Value]);
    end
    

    %% figure resize and keyboard shortcuts callback
    function figureResized(~, ~)
        S_Pos = [20 20 uint16(fig_render.Position(3)-40)+1 20];
        set(zpos_slider,'Position', S_Pos);
    end

    function keyPressed (~, evt)
        % keyboard shortcuts defined here:
        % disp(evt.Key); % to check key value
        switch evt.Key

            %case 'add'
            %case 'subtract'
            % +/- to zoom in out is too complicated in MATLAB
        end
    end



    function auto_lut (h_img)
        h_img.CDataMapping = 'scaled';      % check this, linear or scale
        cdata = h_img.CData;
        ax_img = ancestor(h_img, 'axes');
        if size(cdata, 3) == 3      % RGB image
            % check if need to adjust RGB channel colormap limit
        else
            cmax = prctile(cdata(cdata ~= 0), 95);

            set(ax_img, 'colormap', hot);
            if isnan(cmax) || cmax <= 1
                cmax = 1;
            end
            clim(ax_img, [double(0), cmax]);
            cmax_spinner.Value = cmax;
        end
        drawnow;
    end



    function setup_annotation ()
        
    end
    function toggle_annotation (show_annotation)
        if show_annotation

        else

        end
    end

    function setup_gaussian ()
        prompt = {'pixel size (xynm):', 'voxel depth (znm): (not applied in preview)', 'z scale factor:', 'Gaussian sigma (xynm):', 'Gaussian sigma (znm): (not applied in preview)'};
        title = 'calibration value:';
        dims = [1, 48];
        definput = { num2str(pixel_size), num2str(voxel_depth), num2str(RIMF), num2str(sigma_xy), num2str(sigma_z) };
        answer = inputdlg(prompt, title, dims, definput);
        if isempty(answer)
            focus(fig_render);
            return;
        end
        
        zdata_update = false; img_update = false;
        
        if pixel_size ~= str2double(answer{1})
            pixel_size = str2double(answer{1});
            
            xedge = min(xnm) : pixel_size : max(xnm) + pixel_size;
            yedge = min(ynm) : pixel_size : max(ynm) + pixel_size;

            counts_3d = histcounts3(xnm, ynm, znm, xedge, yedge, [minValue, maxValue], true);
            set(img, 'cdata', counts_3d);

        end

        voxel_depth = str2double(answer{2});

        if RIMF ~= str2double(answer{3})
            RIMF = str2double(answer{3});
            zdata_update = true;
        end

        if sigma_xy ~= str2double(answer{4})
            sigma_xy = str2double(answer{4});
            if gaussian_button.Value
            end

        end

        sigma_z = str2double(answer{5});
        


    end
    function toggle_gaussian (apply_gaussian)
        if apply_gaussian
            img.CData = imgaussfilt(counts_3d, sigma_xy, 'Padding', 0);
        else
            img.CData = counts_3d;
        end
    end


    function setup_channel ()

    end
    function toggle_channel (channel_view)
        if channel_view

        else

        end
    end

    

    function param = load_render_param (app)
        % check and get active data from app
        param = [];
        idx = get_active_data_index(app);
        if isempty(idx)
            return;
        end

        % init param struct
        data = app.data{idx};
        % get property, attributes, calibration, and channel parameters from data
        prop = data.prop; attr = data.attr; cali = data.cali; channel = data.channel;

        % prop: num_dim, trace_idx, num_loc_per_trace
        % attr: loc_x, loc_y, loc_z, vld, ftr, 
        % calibraion: RIMF, loc_precision, local_density, pixel_size, voxel_depth
        % channel: dcr, dcr_trace, numC, cut1, cut2, do_trace, keep_ch3
        if isfield (cali, 'loc_precision')
            cali.loc_precision = compute_Loc_precision (data);
            app.data{idx}.calibration.loc_precision = cali.loc_precision;
        end
    
        % get parameters necessary for rendering:
        RIMF = cali.RIMF;
        ftr = data.attr.ftr;
        
        xnm = -attr.loc_y(ftr) * 1e9;       % image axis is transposed, and y-> direction is up to down
        ynm =  attr.loc_x(ftr) * 1e9;
        znm =  attr.loc_z(ftr) * 1e9 * RIMF;
        znm = znm - mean(znm);
        sigma_xy = cali.loc_precision(1);
        sigma_z = cali.loc_precision(2);
        pixel_size = round( min(range(xnm), range(ynm)) / 1024 ) ; % default pixel size to make a 1024 pixel along shorter axis
        voxel_depth = pixel_size;
    
        % compute x, y edges for 2D histogram, z range between 2.5% ~ 97.5% quantile
        xedge = min(xnm) : pixel_size : max(xnm) + pixel_size;
        yedge = min(ynm) : pixel_size : max(ynm) + pixel_size;
        z_fiveQuantile = quantile(znm, [0.025, 0.975]);
        zMin = floor( z_fiveQuantile(1) ); %double( floor(min(z)) ); 
        zMax = ceil ( z_fiveQuantile(2) ); %double( ceil(max(z)) );
    
        zSliderRange = 2*round( std(znm) ); %double( (zMax - zMin) / 20 );
        zSliderRangeMin = double(0); % minimum Z size is 1 nm;
        zSliderRangeMax = zMax - zMin + 1;
        counts_3d = histcounts3(xnm, ynm, znm, xedge, yedge, [zMin, zMax], true);

    end

    function update_input_data ( var_name, var_value )
        switch lower(var_name)

            case 'rimf'

            case 'cut'

            case ''

        end

    end

end


