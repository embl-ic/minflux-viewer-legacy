function check3D (app)
    app.nDim = 0;
    if (isempty(app.data.loc_x))
        return;
    end
    if (all(app.data.loc_z==0))
        app.nDim = 2;
    else
        app.nDim = 3;
    end
end