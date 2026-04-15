        function computeLocPrecision(app)

            if isempty(app.data) || isempty(app.xyz)
                return;
            end
            minLoc = 5;

            loc = 1e9* [app.data.loc_x, app.data.loc_y, app.data.loc_z]; % loc in nanometer unit
            tid = app.data.tid;

            uid = unique(tid);
            numLoc = arrayfun(@(x) sum(tid==x), uid);


            % Keep only traces with at least minLoc localizations
            keep = numLoc >= minLoc;
            uid = uid(keep);
            numLoc = numLoc(keep);

            if isempty(uid)
                uialert(app.UIFigure, sprintf('No traces with at least %d localizations.', minLoc), 'Localization Precision');
                return;
            end


            % Per-trace coordinate standard deviations
            % Use sample std (normalization 0), matching the paper-style interpretation
            sigma_x = arrayfun(@(id) std(loc(tid == id, 1), 0), uid);
            sigma_y = arrayfun(@(id) std(loc(tid == id, 2), 0), uid);
            % the RMS of X and Y stddev combined, adapted from 
            % DNA-PAINT MINFLUX nanoscopy, Lynn et.al., 2022
            % (https://doi.org/10.1038/s41592-022-01577-1)
            sigma_r = sqrt((sigma_x.^2 + sigma_y.^2) / 2);  

            if app.nDim == 3
                sigma_z = arrayfun(@(id) std(loc(tid == id, 3), 0), uid);
            else
                sigma_z = [];
            end

            % Median single-localization precision across traces
            median_sig_x = median(sigma_x, 'omitnan');
            median_sig_y = median(sigma_y, 'omitnan');
            median_sig_r = median(sigma_r, 'omitnan');

            if app.nDim == 3
                median_sig_z = median(sigma_z, 'omitnan');
            end


            % Paper-style combined precision:
            % sigma_rc = < <sigma_r>_n / sqrt(n) >_n weighted by occurrence of n
            % This is algebraically equivalent to the simple mean over traces of sigma_r./sqrt(n)
            sigma_rc_each = sigma_r ./ sqrt(numLoc);
            sigma_rc = mean(sigma_rc_each, 'omitnan');

            if app.nDim == 3
                sigma_zc_each = sigma_z ./ sqrt(numLoc);
                sigma_zc = mean(sigma_zc_each, 'omitnan');
            end

            % Plot localization precision in a separate figure window
            figure('Name', strcat(app.file, ' - Localization Precision'), 'Color', 'w');

            if app.nDim == 3
                tiledlayout(2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

                nexttile;
                histogram(sigma_x);
                hold on;
                xline(median_sig_x, 'r--', 'LineWidth', 1.5);
                title(sprintf('\\sigma_x median = %.2f nm', median_sig_x));
                xlabel('\sigma_x (nm)');
                ylabel('Count');
                grid on;

                nexttile;
                histogram(sigma_y);
                hold on;
                xline(median_sig_y, 'r--', 'LineWidth', 1.5);
                title(sprintf('\\sigma_y median = %.2f nm', median_sig_y));
                xlabel('\sigma_y (nm)');
                ylabel('Count');
                grid on;

                nexttile;
                histogram(sigma_z);
                hold on;
                xline(median_sig_z, 'r--', 'LineWidth', 1.5);
                title(sprintf('\\sigma_z median = %.2f nm (raw z)', median_sig_z));
                xlabel('\sigma_z (nm)');
                ylabel('Count');
                grid on;

                nexttile([1 2]);
                histogram(sigma_r);
                hold on;
                xline(median_sig_r, 'r--', 'LineWidth', 1.5);
                title(sprintf('\\sigma_r median = %.2f nm', median_sig_r));
                xlabel('\sigma_r = sqrt[ (\sigma_x^2 + \sigma_y^2) / 2 ]  (nm)');
                ylabel('Count');
                grid on;

                nexttile;
                axis off;
                text(0, 0.85, sprintf('Traces used: %d', numel(uid)), 'FontSize', 11);
                text(0, 0.68, sprintf('min localizations / trace: %d', minLoc), 'FontSize', 11);
                text(0, 0.50, sprintf('Combined \\sigma_{rc}: %.2f nm', sigma_rc), 'FontSize', 11);
                text(0, 0.33, sprintf('Combined \\sigma_{zc}: %.2f nm (raw z)', sigma_zc), 'FontSize', 11);
                text(0, 0.12, 'No RI correction applied to z.', 'FontSize', 10, 'Color', [0.4 0.4 0.4]);

            else
                tiledlayout(1, 4, 'Padding', 'compact', 'TileSpacing', 'compact');

                nexttile;
                histogram(sigma_x);
                hold on;
                xline(median_sig_x, 'r--', 'LineWidth', 1.5);
                title(sprintf('\\sigma_x median = %.2f nm', median_sig_x));
                xlabel('\sigma_x (nm)');
                ylabel('Count');
                grid on;

                nexttile;
                histogram(sigma_y);
                hold on;
                xline(median_sig_y, 'r--', 'LineWidth', 1.5);
                title(sprintf('\\sigma_y median = %.2f nm', median_sig_y));
                xlabel('\sigma_y (nm)');
                ylabel('Count');
                grid on;

                nexttile;
                histogram(sigma_r);
                hold on;
                xline(median_sig_r, 'r--', 'LineWidth', 1.5);
                title(sprintf('\\sigma_r median = %.2f nm', median_sig_r));
                xlabel('\sigma_r (nm)');
                ylabel('Count');
                grid on;

                nexttile;
                axis off;
                text(0, 0.75, sprintf('Traces used: %d', numel(uid)), 'FontSize', 11);
                text(0, 0.55, sprintf('min localizations / trace: %d', minLoc), 'FontSize', 11);
                text(0, 0.35, sprintf('Combined \\sigma_{rc}: %.2f nm', sigma_rc), 'FontSize', 11);
            end

            sgtitle(sprintf('%s - localization precision from repeated localizations per TID', app.file), ...
                'Interpreter', 'none');



        end