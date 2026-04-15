        function computeLocPrecision(app)
            if isempty(app.data) || isempty(app.xyz)
                return;
            end
            minLoc = 5;


            %!!! Should not apply any filter when reporting localization precision of data, use raw value instead !!!
            loc = app.xyz(app.ftr, :);      % get xyz coordinates after filter
            tid = app.data.tid(app.ftr);    % get tid array after filter
            uid = unique(tid);
            numLoc = arrayfun(@(x) sum(tid==x), uid);


            % compute center for each trace,
            % and also distance to its trace center for each localization
            center = arrayfun(@(x) mean(loc(tid==x, :), 1), uid, 'UniformOutput', false);
            center = cell2mat(center);
            center_loc = repelem(center, numLoc, 1);    % trace center

            % remove single data point trace (after filtering),
            % otherwise standarad deviation cannot be properly calculated
            uid(numLoc<minLoc) = [];

            diff_center_loc = loc - center_loc;         % x,y,z array of difference to center

            dist_loc_x  = vecnorm(diff_center_loc(:, 1),   2, 2);
            dist_loc_y  = vecnorm(diff_center_loc(:, 2),   2, 2);
            dist_loc_xy = vecnorm(diff_center_loc(:, 1:2), 2, 2);

            std_dist_x  = arrayfun(@(x) std(dist_loc_x(tid==x),  1), uid);
            std_dist_y  = arrayfun(@(x) std(dist_loc_y(tid==x),  1), uid);
            std_dist_xy = arrayfun(@(x) std(dist_loc_xy(tid==x), 1), uid);

            if (app.nDim==3)
                dist_loc_z = vecnorm(diff_center_loc(:, 3), 2, 2);
                dist_loc_xyz = vecnorm(diff_center_loc, 2, 2);

                std_dist_z = arrayfun(@(x) std(dist_loc_z(tid==x), 1), uid);
                std_dist_xyz = arrayfun(@(x) std(dist_loc_xyz(tid==x), 1), uid);
            end

            % plot localization precision in a separate figure window
            figure('Name', strcat(app.file, ' - Localization Precision')); % create new figure for the plots
            ax_x = subplot(app.nDim-1, 3, 1);
            sigma_x = std_dist_x(std_dist_x~=0);
            median_sig_x = median(sigma_x);
            histogram(ax_x, sigma_x);
            line(ax_x, [median_sig_x, median_sig_x], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
            title(ax_x, strcat('x: Median (σ_{x}) = ', num2str(median_sig_x), ' nm') );
            xlabel(ax_x, 'σ_{x}(nm)');

            ax_y = subplot(app.nDim-1, 3, 2);
            sigma_y = std_dist_y(std_dist_y~=0);
            median_sig_y = median(sigma_y);
            histogram(ax_y, sigma_y);
            line(ax_y, [median_sig_y, median_sig_y], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
            title(ax_y, strcat('y: Median (σ_{y}) = ', num2str(median_sig_y), ' nm') );
            xlabel(ax_y, 'σ_{y}(nm)');

            if (app.nDim == 3)
                ax_xy = subplot(2, 3, 4);

                ax_z = subplot(2, 3, 3);
                sigma_z = std_dist_z(std_dist_z~=0);
                median_sig_z = median(sigma_z);
                histogram(ax_z, sigma_z);
                line(ax_z, [median_sig_z, median_sig_z], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
                title(ax_z, strcat('z: Median (σ_{z}) = ', num2str(median_sig_z), ' nm') );
                xlabel(ax_z, 'σ_{z}(nm)');

                ax_xyz = subplot(2, 3, [5, 6]);
                sigma_xyz = std_dist_xyz;
                median_sig_xyz = median(sigma_xyz);
                histogram(ax_xyz, sigma_xyz);
                line(ax_xyz, [median_sig_xyz, median_sig_xyz], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
                title(ax_xyz, strcat('xyz: Median (σ_{xyz}) = ', num2str(median_sig_xyz), ' nm') );
                xlabel(ax_xyz, 'σ_{xyz}(nm)');
            else
                ax_xy = subplot(1, 3, 3);
            end

            sigma_xy = std_dist_xy(std_dist_xy~=0);
            median_sig_xy = median(sigma_xy);
            histogram(ax_xy, sigma_xy);
            line(ax_xy, [median_sig_xy, median_sig_xy], ylim, 'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
            title(ax_xy, strcat('xy: Median (σ_{xy}) = ', num2str(median_sig_xy), ' nm') );
            xlabel(ax_xy, 'σ_{xy}(nm)');

        end