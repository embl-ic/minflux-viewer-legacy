function success = computeZscale (app)
    % get trace ID and occurence
    %tid_vld = app.data.tid(app.data.vld);
    success = false;
    tid = app.data.tid;
    id = unique(tid);
    freq = histcounts(tid, [id; inf])';
    num_id = numel(id);
    % estimate isotropy for each of the selected traces
    zScale_tid = zeros (num_id, 1);
    for i = 1 : num_id
        zScale_tid(i, :) = freq(i) .* ...
            estimateZscale ( app, ...
            app.data.loc_x(tid==id(i)), ...
            app.data.loc_y(tid==id(i)), ...
            app.data.loc_z(tid==id(i)) );
    end
    % remove outlier
    outlier = isoutlier(zScale_tid);
    zScale_tid = zScale_tid(~outlier, :);
    freq = freq(~outlier, :);
    if (size(zScale_tid, 1) ~= 1)
        %isotropy = isotropy ./ freq;
        zScale_tid = sum(zScale_tid,'omitnan') / sum(freq(~isnan(zScale_tid(:,1))));
    end
    if (zScale_tid<0.5 || zScale_tid>1.0)
        disp(' Failed to compute z-scale from loc data!');
    else
        success = true;
        app.zScale = zScale_tid;
    end
end