function scale = estimateZscale (~, x, y, z)
    dispersion_x = iqr(x, 1);
    dispersion_x = dispersion_x(1);
    dispersion_y = iqr(y, 1);
    dispersion_y = dispersion_y(1);
    dispersion_z = iqr(z, 1);
    dispersion_z = dispersion_z(1);
    scale = geomean([dispersion_x, dispersion_y]) / dispersion_z;
end