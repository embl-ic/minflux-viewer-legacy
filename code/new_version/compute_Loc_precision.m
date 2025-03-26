function sigma = compute_Loc_precision (loc, nDim, num_loc_per_trace, trace_idx)
    % get number of localization per trace, with minimum 20 loc in trace
    minLoc = 20;
    valid_tid = num_loc_per_trace >= minLoc;
    % compute center for each trace
    center = arrayfun(@(id) mean( loc(trace_idx(id,1) : trace_idx(id,2), :), 1 ),  1:length(trace_idx), 'uni', 0);
    center = cell2mat(center');
    center_loc = repelem(center, num_loc_per_trace, 1);    % trace center
    % compute distance to its trace center for each localization
    diff_center_loc = loc - center_loc;         
    dist_loc_xy = vecnorm(diff_center_loc(:, 1:2), 2, 2);
    % std of (distance to center) per trace
    std_dist_xy = arrayfun(@(id) std(dist_loc_xy(trace_idx(id,1) : trace_idx(id,2), :), 1 ), 1:length(trace_idx));
    % compute the same for Z coordinates, if 3D data
    if nDim == 2
        std_dist_z = zeros(length(trace_idx), 1);
    else
        dist_loc_z = abs( diff_center_loc(:, 3) );
        std_dist_z = arrayfun(@(id) std(dist_loc_z(trace_idx(id,1) : trace_idx(id,2), :), 1 ), 1:length(trace_idx));
    end
    % sigma: median of the standarad deviations, XY, Z (no RIMF applied to Z)
    sigma = [median(std_dist_xy(valid_tid)); median(std_dist_z(valid_tid)) ];
end