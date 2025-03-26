function compute_extra_property (app)
    
    %app.data.attr = attributes;
    %app.data.prop = property;

    % get xyz, origin, num_dim, 
    if all (app.data.attr.loc_z == 0)
        app.data.prop.nDim = 2;
    else
        app.data.prop.nDim = 3;
    end
    
    %size_mb = get_size(app, app.data) / (1024^2);
    % disp("data takes " + size_mb + " MB.");
    % report_memory(app);
    % data = app.data;
    % report_memory(app);
    % data2 = data;
    % report_memory(app);
    size_mb = get_size(app, app.data) / (1024^2);
    disp("data takes " + size_mb + " MB.");

    app.data.prop.RIMF = 0.667; % may change 
    
    % xyz coordinates, in nanometer, and Z scaling corrected
    xyz = 1e9 * [app.data.attr.loc_x, app.data.attr.loc_y, app.data.attr.loc_z * app.data.prop.RIMF];

    app.data.prop.origin = min ( xyz );
    xyz = xyz - app.data.prop.origin;           % re-zero XYZ coordinates to axis origin
    xyz(:, 3) = xyz(:, 3) - mean( xyz(:, 3) );  % move Z=0 at the middle of the data volume

    app.data.prop.xyz = single( round(xyz, 2) ); % convert to single precision, and 0.01 nm resolution

    % get trace ID, and num_loc per trace
    [~, ia, ic] = unique(app.data.attr.tid);
    app.data.prop.trace_idx = [ia, [ ia(2:end)-1; length(app.data.attr.tid) ] ];
    app.data.prop.num_loc_per_trace = accumarray(ic, 1);    %num_loc = arrayfun(@(id) sum(tid==id), uid);  % !!! too slow

    % change iteration index to 1-based 
    app.data.attr.itr = int8(1 + app.data.attr.itr);


    % locate trace change index in raw data
    tim = app.data.attr.tim;
    tid = app.data.attr.tid;
    idx = find(diff(tid));
    % compute time interval from time stamp
    dt = diff(tim);
    dt(idx) = 0;  % remove in-between trace time interval
    dt = [0; dt];
    app.data.attr.dt = dt;
    % compute relative time stamp of each trace
    t_start = tim([1; idx+1]);
    app.data.attr.nLoc = repelem(app.data.prop.num_loc_per_trace, app.data.prop.num_loc_per_trace);
    t_min = repelem(t_start, app.data.prop.num_loc_per_trace);
    app.data.tim_trace = tim - t_min;
    
    % add travel distance, and instaneous speed attribute
    loc = [app.data.attr.loc_x, app.data.attr.loc_y, app.data.attr.loc_z];
    app.data.attr.dst = [0; vecnorm(diff(loc), 2, 2)];
    app.data.attr.dst(idx+1) = 0;
    app.data.attr.spd = app.data.attr.dst ./ dt;
    % add filter of data
    app.data.attr.ftr = true( app.data.prop.num_loc, 1 ); % filter index?
    % add index of data
    app.data.attr.idx = uint32( 1 : app.data.prop.num_loc )';

    app.data.prop.attr_names = fieldnames(app.data.attr);

end