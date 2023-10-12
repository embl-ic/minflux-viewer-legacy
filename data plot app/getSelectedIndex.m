% get selected index of (filtered/unfiltered) data ROI regions in:
% overview plot, histogram plot, and (if exist) scatter plot 
function getSelectedIndex (app, whichPlot)
    if isempty(app.data)
        return;
    end
    app.index_roi = zeros(app.nLoc, 1);
    % switch which figure/plot to draw ROI, and get selected index
    switch whichPlot
        case 'Overview'
            %roi = drawrectangle(app.UIAxes_overview, 'Color', 'y', 'StripeColor', 'none', 'LineWidth', 1);
            roi = drawRoi(app, app.UIAxes_overview);
            % get within range val_1 and val_2
            try
                app.index_roi = inROI(roi, double(app.val_1), double(app.val_2));
            catch ME
                disp(strcat(" line 533: ", ME.message));
            end
            roi.delete();  
        case 'Histogram'
            %roi = drawrectangle(app.UIAxes_histogram, 'Color', 'y', 'StripeColor', 'none', 'LineWidth', 1);
            roi = drawRoi(app, app.UIAxes_histogram);
            % get min and max of val_2
            x_min = roi.Position(1);
            x_max = x_min + roi.Position(3);
            app.index_roi = app.val_2 >= x_min & app.val_2 <= x_max;
            roi.delete();  
        case 'Scatter'
            %roi = drawrectangle(app.ax_3D, 'Color', 'y', 'StripeColor', 'none', 'LineWidth', 1);
            roi = drawRoi(app, app.ax_scatter);
            app.index_roi = inROI(roi, app.xyz(:,1), app.xyz(:,2)); % check 1st and 2nd dimension
            roi.delete();       % remove ROI
    end
    app.index_roi = app.index_roi & app.ftr;
end