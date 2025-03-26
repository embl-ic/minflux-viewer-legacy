function counts = histcounts3 (x, y, z, xedge, yedge, zedge)
    numX = length(xedge) - 1;
    numY = length(yedge) - 1;
    numZ = length(zedge) - 1;
    % Compute bin indices for each dimension
    binIdxX = discretize(x, xedge);
    binIdxY = discretize(y, yedge);
    binIdxZ = discretize(z, zedge);
    nidx = ~isnan(binIdxX) & ~isnan(binIdxY) & ~isnan(binIdxZ);
    counts = uint16( accumarray([binIdxX(nidx), binIdxY(nidx), binIdxZ(nidx)], 1, [numX, numY, numZ]) );
    if max(counts(:)) <= 255
        counts = uint8( counts );
    end
end