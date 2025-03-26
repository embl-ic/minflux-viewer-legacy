function success = computeZscale (app)

    % known value range of RIMF
    RIMF = 0.65; tolerance = 0.1;

    success = false;
    tid = app.data.tid;
    id = unique(tid);
    freq = histcounts(tid, [id; inf])';
    num_id = numel(id);
    % estimate isotropy for each of the selected traces
    zScale_trace = zeros (num_id, 1);
    for i = 1 : num_id
         zScale = estimateZscale ( app, ...
                app.data.loc_x(tid==id(i)), ...
                app.data.loc_y(tid==id(i)), ...
                app.data.loc_z(tid==id(i)) );
         if (zScale < RIMF - tolerance || zScale > RIMF + tolerance)
             zScale = nan;
         end
         zScale_trace(i, :)  = zScale;
    end
    % remove outlier
    outlier = isnan(zScale_trace);
    zScale_trace = zScale_trace(~outlier, :);
    freq = freq(~outlier, :);
    if (size(zScale_trace, 1) ~= 1)
        %isotropy = isotropy ./ freq;
        zScale_trace = sum(zScale_trace.*freq) / sum(freq);
    end
    if (zScale_trace < RIMF - tolerance || zScale_trace > RIMF + tolerance)
        disp(' Failed to compute z-scale from loc data!');
    else
        success = true;
        app.zScale = zScale_trace;
    end
end