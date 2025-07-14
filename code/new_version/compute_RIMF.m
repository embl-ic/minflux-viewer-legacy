function RIMF = compute_RIMF (data, RIMF_guess, tolerance)
    %%
    %   compute Refractive Index Mismatch Factor : RIMF 
    %   a Z scaling factor to be applied onto Z axis localization value,
    %   for 3D quantification related processing and analysis
    %
    %
    %
    %
    %
    %
    %
    %
    %
    % Ziqiang Huang: <ziqiang.huang@embl.de>
    % Last update: 2025.04.28
    %%
    if data.prop.num_dim == 2
        RIMF = 1;
        return;
    end

    if nargin < 3
        tolerance = 0.1;
    end
    if nargin < 2
        RIMF_guess = 0.67; % should be around 0.66 ~ 0.67
    end

    loc = [data.attr.loc_x, data.attr.loc_y, data.attr.loc_z];
    RIMF_range = [RIMF_guess - tolerance, RIMF_guess + tolerance];  % [0, 2]; 
    
    %loc = file.raw_data.loc(file.raw_data.vld, :, :);        % in case all iteration will be needed;

    trace_idx = data.prop.trace_idx;
    freq = data.prop.num_loc_per_trace;
    zScale_trace = arrayfun(@(id) estimateZscale( loc(trace_idx(id, 1) : trace_idx(id, 2), :), RIMF_range ), (1:length(trace_idx))');

    % remove outlier
    outlier = isnan(zScale_trace);
    fprintf("%d out of %d value removed because out of range.", sum(outlier), length(trace_idx));
    zScale_trace = zScale_trace(~outlier, :);
    freq = freq(~outlier, :);

    % compute weighted average 
    RIMF = sum(zScale_trace.*freq) / sum(freq);

    disp("RIMF computed as: " + RIMF);

    if (RIMF < RIMF_guess - tolerance || RIMF > RIMF_guess + tolerance)
       warning("Failed to compute RIMF (Z-scaling) from loc data! Use set value in Preferences: " + RIMF_guess);
       RIMF = RIMF_guess;
    end
    




    % use inter-quantile distance to decide for the dispersion of each dimension
    function scale = estimateZscale (loc, scale_range)
        if ndims(loc) == 3  % loc with all iterations
            dispersion = squeeze(iqr(loc, [1, 2])); % 3 x 1 double
        else
            dispersion = iqr(loc, 1);   % 1 x 3 double
        end
        scale = geomean(dispersion(1:2)) / dispersion(3);
        if scale < scale_range(1) || scale > scale_range(2)
            scale = NaN;
        end
    end

end

