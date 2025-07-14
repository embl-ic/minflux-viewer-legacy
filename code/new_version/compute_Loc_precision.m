function sigma = compute_Loc_precision (data, min_loc, display)
    
    if isempty(data)
        return;
    end

    if nargin < 3
        display = false;
    end

    if nargin < 2
        min_loc = 20;
    else
        min_loc = max(min_loc, 20);  % need at least 20 localization to compute
    end

    %valid_tid = app.traceLength >= minLoc;
    %loc_nm = 1e9 * app.xyz;      % get xyz coordinates after filter


    x = data.attr.loc_x * 1e9;
    y = data.attr.loc_y * 1e9;
    z = data.attr.loc_z * 1e9;
    loc_nm = [x, y, z];

    nDim = data.prop.num_dim;

    num_loc_per_trace = data.prop.num_loc_per_trace;
    trace_idx = data.prop.trace_idx;



    % get number of localization per trace, with min_loc data in trace
    valid_tid = num_loc_per_trace >= min_loc;


    % compute center for each trace
    center = arrayfun(@(id) mean(loc_nm(trace_idx(id,1) : trace_idx(id,2), :), 1, 'omitnan'),  1:length(trace_idx), 'uni', 0);
    center = cell2mat(center');
    center_loc = repelem(center, num_loc_per_trace, 1);    % trace center

    % compute distance to its trace center for each localization
    diff_center_loc = loc_nm - center_loc;

    % distance to center: X
    dist_loc_x = diff_center_loc(:, 1);
    std_dist_x  = arrayfun(@(id) std( dist_loc_x(trace_idx(id,1) : trace_idx(id,2), :), 1 ), 1:length(trace_idx));
    sigma_x = std_dist_x(valid_tid);    % stdDev of distance to center: X
    median_sig_x = median(sigma_x);     % median of stdDev_X

    % distance to center: Y
    dist_loc_y = diff_center_loc(:, 2);
    std_dist_y  = arrayfun(@(id) std( dist_loc_y(trace_idx(id,1) : trace_idx(id,2), :), 1 ), 1:length(trace_idx));
    sigma_y = std_dist_y(valid_tid);    % stdDev of distance to center: Y
    median_sig_y = median(sigma_y);     % median of stdDev_Y

    % distance to center: XY
    dist_loc_xy = vecnorm(diff_center_loc(:, 1:2), 2, 2);
    std_dist_xy = arrayfun(@(id) std(dist_loc_xy(trace_idx(id,1) : trace_idx(id,2), :), 1 ), 1:length(trace_idx));
    sigma_xy = std_dist_xy(valid_tid);  % stdDev of distance to center: XY
    median_sig_xy = median(sigma_xy);   % median of stdDev_XY


    % 3D data : compute the same for Z
    if nDim == 3

        % distance to center: Z
        dist_loc_z = diff_center_loc(:, 3); %abs( diff_center_loc(:, 3) );
        std_dist_z = arrayfun(@(id) std(dist_loc_z(trace_idx(id,1) : trace_idx(id,2), :), 1 ), 1:length(trace_idx));
        sigma_z = std_dist_z(valid_tid);
        median_sig_z = median(sigma_z);

        % distance to center: XYZ
        dist_loc_xyz = vecnorm(diff_center_loc, 2, 2);
    	std_dist_xyz = arrayfun(@(id) std(dist_loc_xyz(trace_idx(id,1) : trace_idx(id,2), :), 1 ), 1:length(trace_idx));
        sigma_xyz = std_dist_xyz(valid_tid);
        median_sig_xyz = median(sigma_xyz);

    else    % 2D data : 
        % distance to center : Z, and stdDev, all set to Zero
        sigma_z = 0;
        median_sig_z = 0;
    end


    % check whether to create figure to show the histograms
    if display
        fig_name = strcat("Localization Precision : ", data.file.name);
        fig_locPrec = findall(0, 'Type', 'figure', 'Name', fig_name);
        if ~isempty(fig_locPrec)
            close(fig_locPrec);     % keep up to one localization precision figure for each dataset
        end
        figure('Name', fig_name, 'NumberTitle', 'off', 'Tag', "figure_locPrec");

        % subplot for X
        ax_x = subplot(nDim-1, 3, 1);
        histogram(ax_x, sigma_x);
        line(ax_x, [median_sig_x, median_sig_x], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
        title(ax_x, strcat('x: Median (σ_{x}) = ', num2str(median_sig_x), ' nm') );
        xlabel(ax_x, 'σ_{x}(nm)');
        % subplot for Y
        ax_y = subplot(nDim-1, 3, 2);
        histogram(ax_y, sigma_y);
        line(ax_y, [median_sig_y, median_sig_y], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
        title(ax_y, strcat('y: Median (σ_{y}) = ', num2str(median_sig_y), ' nm') );
        xlabel(ax_y, 'σ_{y}(nm)');
        
        if (nDim == 3)  % x, y, z; xy, xyz
            % subplot for XY, in 3D case
            ax_xy = subplot(2, 3, 4);

            % subplot for Z
            ax_z = subplot(2, 3, 3);
            histogram(ax_z, sigma_z);
            line(ax_z, [median_sig_z, median_sig_z], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
            title(ax_z, strcat('z: Median (σ_{z}) = ', num2str(median_sig_z), ' nm') );
            xlabel(ax_z, 'σ_{z}(nm)');
    
            % subplot for XYZ
            ax_xyz = subplot(2, 3, [5, 6]);
            histogram(ax_xyz, sigma_xyz);
            line(ax_xyz, [median_sig_xyz, median_sig_xyz], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
            title(ax_xyz, strcat('xyz: Median (σ_{xyz}) = ', num2str(median_sig_xyz), ' nm') );
            xlabel(ax_xyz, 'σ_{xyz}(nm)');      
  
        else    % x, y, xy
            % subplot for XY, in 2D case
            ax_xy = subplot(1, 3, 3);
        end

        % subplot for XY
        histogram(ax_xy, sigma_xy);
        line(ax_xy, [median_sig_xy, median_sig_xy], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
        title(ax_xy, strcat('xy: Median (σ_{xy}) = ', num2str(median_sig_xy), ' nm') );
        xlabel(ax_xy, 'σ_{xy}(nm)');

    end

    % sigma: median of the standarad deviations, XY, Z (RIMF applied to Z)
    sigma = [ median_sig_xy; median_sig_z ];

end