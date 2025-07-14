function counts = histcounts3 (x, y, z, xedge, yedge, zedge, to_2D)
    % if compress to 2D, only take 1st and last Z bin edge
    % compress all localization in between the min and max Z into a 2D histogram
    
    if nargin < 7
        to_2D = false;
    end
    
    if to_2D
        zidx = z >= zedge(1) & z <= zedge(end);
        x = x(zidx); y = y(zidx);
        [counts, ~, ~] = histcounts2(x, y, xedge, yedge);
    else

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
end