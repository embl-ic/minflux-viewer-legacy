function density = compute_local_density (x, y, z, voxel_size, smooth_sigma, try_kdtree)

    % KDTree range search compute more accurate local density (spherical), but an order slower;
    tic;
    
    if nargin < 6
        try_kdtree = false;	
    end
    if nargin < 5
        smooth_sigma = 1;
    end
    if nargin < 4
        voxel_size = max([range(x), range(y), range(z)]) / 100;
    end

    if voxel_size < 1
        voxel_size = voxel_size * 1e9;
        x = x * 1e9; y = y * 1e9; z = z * 1e9;
    end
    
    
    if try_kdtree
        disp("compute local density with KD-Tree range search takes:");
        density = kdtree_range_density (x, y, z, voxel_size);
    else
        disp("compute local density with histocounts 3D takes:");
        density = histcount_density (x, y, z, voxel_size, smooth_sigma);
    end

    toc;
    
   
end



    function density = histcount_density (x, y, z, voxel_size, smooth_sigma)
        xedge = min(x) : voxel_size : max(x) + voxel_size;
        yedge = min(y) : voxel_size : max(y) + voxel_size;
        zedge = min(z) : voxel_size : max(z) + voxel_size;
        
        binCount3d = histcounts3 (x, y, z, xedge, yedge, zedge);
        density_map_smoothed = imgaussfilt3(binCount3d, smooth_sigma);
        [~, ~, xbin] = histcounts(x, xedge);
        [~, ~, ybin] = histcounts(y, yedge);
        [~, ~, zbin] = histcounts(z, zedge);
        xbin(xbin==0) = 1;
        ybin(ybin==0) = 1;
        zbin(zbin==0) = 1;
        density = arrayfun(@(i) density_map_smoothed(xbin(i), ybin(i), zbin(i)), 1:length(x));
    end


    function density = kdtree_range_density (x, y, z, range)
        [~, D] = rangesearch([x,y,z], [x,y,z], range);
        density = cellfun(@(x) length(x)-1, D);
    end
