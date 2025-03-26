function addExtraAttr (app)
    % add customized extra attribute: dt, time_trace, dst, spd, ftr(not in app.data), and idx 

    % 1-based iteration
    %app.data.itr = int8(1 + app.data.itr(app.data.vld, :));
    app.data.itr = int8(1 + app.data.itr);

    % add xnm, ynm, and znm
    app.data.xnm = app.data.loc_x * 1e9;
    app.data.ynm = app.data.loc_y * 1e9;
    app.data.znm = app.data.loc_z * 1e9;

    % locate trace change index in raw data
    tim = app.data.tim;
    tid = app.data.tid;
    idx = find(diff(tid));
    % compute time interval from time stamp
    dt = diff(tim);
    dt(idx) = 0;  % remove in-between trace time interval
    dt = [0; dt];
    app.data.dt = dt;
    % compute relative time stamp of each trace
    t_start = tim([1; idx+1]);
    %t_end = tim([idx; end]);
    app.data.nLoc = repelem(app.traceLength, app.traceLength);
    t_min = repelem(t_start, app.traceLength);
    app.data.tim_trace = tim - t_min;
    
    %t_min = repelem(t_start, trace_length);
    %t_max = repelem(t_end, trace_length);
    %t_diff = tim - t_min;
    %app.data.ttz = t_diff ./ (t_max-t_min);
    
    % add travel distance, and instaneous speed attribute
    loc = [app.data.loc_x, app.data.loc_y, app.data.loc_z];
    app.data.dst = [0; vecnorm(diff(loc), 2, 2)];
    app.data.dst(idx+1) = 0;
    app.data.spd = app.data.dst ./ dt;
    % add filter of data
    app.ftr = true(app.nLoc, 1);
    % add index of data
    app.data.idx = uint32(1:app.nLoc)';
end