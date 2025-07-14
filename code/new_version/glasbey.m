function glasbey_LUT = glasbey (nObj)
    % nObj = 8; glasbey_LUT = zeros(nObj, 3);
    % if isempty(app.scatterPlot) || ~isgraphics(app.scatterPlot)
    %     return;
    % end
    % nObj = numel(unique(app.scatterPlot.CData));

    if nargin < 1
        nObj = 256;
    end
    
    glasbey_LUT = zeros(nObj,3);
    
    bg = [1 1 1]; % white background
    n_grid = 30;  % number of grid divisions along each axis in RGB space
    x = linspace(0, 1, n_grid);
    [R,G,B] = ndgrid(x,x,x);
    rgb = [R(:) G(:) B(:)];
    if (nObj > size(rgb,1)/3)
        error('You can''t readily distinguish that many colors');
    end
    % Convert to Lab color space, which more closely represents human perception
    C = makecform('srgb2lab');
    lab = applycform(rgb, C);
    bglab = applycform(bg, C);
    mindist2 = inf(size(rgb, 1), 1);
    for i = 1:size(bglab,1)-1
        dX = bsxfun(@minus, lab, bglab(i, :)); % displacement all colors from bg
        dist2 = sum(dX.^2,2);  % square distance
        mindist2 = min(dist2, mindist2);  % dist2 to closest previously-chosen color
    end
    % Iteratively pick the color that maximizes the distance to the nearest already-picked color
    lastlab = bglab(end,:);   % initialize by making the "previous" color equal to background
    for i = 1:nObj
        dX = bsxfun(@minus,lab,lastlab); % displacement of last from all colors on list
        dist2 = sum(dX.^2,2);  % square distance
        mindist2 = min(dist2,mindist2);  % dist2 to closest previously-chosen color
        [~, id] = max(mindist2);  % find the entry farthest from all previously-chosen colors
        glasbey_LUT(i,:) = rgb(id,:);  % save for output
        lastlab = lab(id,:);  % prepare for next iteration
    end
end