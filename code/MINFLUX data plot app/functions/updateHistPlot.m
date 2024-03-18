function updateHistPlot (app, minVal, maxVal)
    % update histogram plot: check plotVar, filter, ROI, minVal, maxVal
    % get attr from histAttr dropdown, get plot var from plotVar dropdown
    % plot histogram, bin size auto
    % update bin size and step size
    % get minVal and maxVal from the min and max spinner, if init,
    % or
    % get attr, plotVar, min, max from selected filter
    %
    if isempty(app.val_hist) || all(isnan(app.val_hist))
        return;
    end
    % get min and max value, and update spinner
    if nargin == 1 % get hist plot parameter from UI
        minVal = double(min(app.val_hist));
        maxVal = double(max(app.val_hist));  
    end
    app.minSpinner.Value = minVal;
    app.maxSpinner.Value = maxVal;
    % udpate step size of the spinners
    stepSize = range(app.val_hist) / 20;
    if stepSize > 0
        app.minSpinner.Step = stepSize;
        app.maxSpinner.Step = stepSize;
        app.binsizeSpinner.Step = 4*stepSize / sqrt(numel(app.val_hist));
    end
    
    
    if ~isempty(app.histPlot) && isgraphics(app.histPlot)
        app.histPlot.Data = app.val_hist;
    else
        app.histPlot = histogram(app.UIAxes_histogram, app.val_hist);
    end
    xlabel(app.UIAxes_histogram, strcat(app.histAttributeDropDown_4.Value, {' : '}, app.plotVarDropDown.Value));
    
    app.histPlot.BinMethod = 'auto';
    app.UIAxes_histogram.YLimMode = 'auto';
    %app.axes_histogram.XLimMode = 'auto';
    %app.axes_histogram.YLimMode = 'auto';

    app.binsizeSpinner.Value = app.histPlot.BinWidth;
    
    if ~isempty(app.hist_minLine)
        app.hist_minLine.Value = minVal;
    else
        app.hist_minLine = xline(app.UIAxes_histogram, minVal, 'LineWidth', 2, 'Color', 'red', 'buttonDownFcn', @startDragFcn);
    end
    if ~isempty(app.hist_maxLine)
        app.hist_maxLine.Value = maxVal;
    else
        app.hist_maxLine = xline(app.UIAxes_histogram, maxVal, 'LineWidth', 2, 'Color', 'red', 'buttonDownFcn', @startDragFcn);
    end

    function startDragFcn(src, ~)
        set(app.UIFigureMain,'WindowButtonMotionFcn',{@draggingFcn, src});
    end

    function draggingFcn(~, ~, src_line)
        pt=get(app.UIAxes_histogram, 'CurrentPoint');
        newX = pt(1,1);
        src_line.Value = newX;
        if isequal(src_line, app.hist_minLine)
            app.minSpinner.Value = newX;
        else
            app.maxSpinner.Value = newX;
        end
    end
end
