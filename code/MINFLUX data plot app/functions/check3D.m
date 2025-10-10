function check3D (app)
    app.nDim = 0;
    if (isempty(app.data.loc_x))
        return;
    end
    
    if iqr(app.data.loc_z, 'all') < 1e-9    % if the 25%-75% interquantile range of Z axis value is less than 0.1 nm, consider the data as 2D
        app.nDim = 2;
        % maybe re-zero all z values?
        % app.data.loc_z = zeros( size(app.data.loc_z) );
    else
        app.nDim = 3;
    end

end