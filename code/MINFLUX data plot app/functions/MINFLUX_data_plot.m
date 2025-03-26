classdef MINFLUX_data_plot < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigureMain                matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        LeftPanel                   matlab.ui.container.Panel
        filterPanel                 matlab.ui.container.Panel
        loadFilterButton            matlab.ui.control.Button
        saveFilterButton            matlab.ui.control.Button
        UITableFilter               matlab.ui.control.Table
        addFilterButton             matlab.ui.control.Button
        deleteFilterButton          matlab.ui.control.Button
        displayFilterButton         matlab.ui.control.Button
        DataLabel                   matlab.ui.control.Label
        PanelData                   matlab.ui.container.Panel
        TextArea                    matlab.ui.control.TextArea
        LoadDataButton              matlab.ui.control.Button
        LoadConfocalButton          matlab.ui.control.Button
        SaveDataButton              matlab.ui.control.Button
        PanelVisualization          matlab.ui.container.Panel
        attributeDropDown_1         matlab.ui.control.DropDown
        attributeDropDown_2         matlab.ui.control.DropDown
        attributeDropDown_2Label    matlab.ui.control.Label
        attributeDropDownLabel      matlab.ui.control.Label
        PanelScatter                matlab.ui.container.Panel
        LocPrecButton               matlab.ui.control.Button
        ROIshapeDropDown            matlab.ui.control.DropDown
        ROIcolorButton              matlab.ui.control.Button
        ROIButton_scatter           matlab.ui.control.Button
        colormapDropDown            matlab.ui.control.DropDown
        colormapDropDownLabel       matlab.ui.control.Label
        colorByAttributeDropDown_3  matlab.ui.control.DropDown
        colorbyDropDownLabel        matlab.ui.control.Label
        zscaleEditField             matlab.ui.control.NumericEditField
        ZscaleEditFieldLabel        matlab.ui.control.Label
        zScaleAutoCheckBox          matlab.ui.control.CheckBox
        scatterPlotButton           matlab.ui.control.Button
        RightPanel                  matlab.ui.container.Panel
        TabGroup                    matlab.ui.container.TabGroup
        OverviewTab                 matlab.ui.container.Tab
        Image                       matlab.ui.control.Image
        UIAxes_overview             matlab.ui.control.UIAxes
        HistogramTab                matlab.ui.container.Tab
        addtofilterlistButton       matlab.ui.control.Button
        valueasDropDownLabel        matlab.ui.control.Label
        histAttributeDropDown_4     matlab.ui.control.DropDown
        attributeLabel              matlab.ui.control.Label
        plotVarDropDown             matlab.ui.control.DropDown
        minSpinner                  matlab.ui.control.Spinner
        maxSpinner                  matlab.ui.control.Spinner
        maxSpinnerLabel             matlab.ui.control.Label
        binsizeSpinner              matlab.ui.control.Spinner
        binsizeSpinnerLabel         matlab.ui.control.Label
        minSpinnerLabel             matlab.ui.control.Label
        reverseFilterButton         matlab.ui.control.Button
        UIAxes_histogram            matlab.ui.control.UIAxes
        TraceViewTab                matlab.ui.container.Tab
        Image2                      matlab.ui.control.Image
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % The app displays the data by using the scatter plot, histogram, and table.
    % It makes use of tabs to separate the ploting options output from the table display of the data.
    % There are several graphical elements used such as checkboxes, slider, switch, dropdown, and radiobutton group.
    % The data used in the app is shipped with the product.
    
    properties (Access = public)
        % Declare properties of the PatientsDisplay class.
        file            % MINFLUX file name
        path            % MINFLUX file path (dir)
        
        firstLoad       % boolean, true when 1st dataset loaded
        data            % MINFLUX raw data loaded as struct
        attributes      % MINFLUX data attributes
        nItr            % number of iteration
        nLoc            % number of recorded localization
        traceID         % unique trace IDs
        traceLength     % number of localizations per trace

        %data_filtered  % MINFLUX raw data after applied filter(s)
        %FilterDialogApp % Filter Dialog app
        ftr
        filters         % cell array to store filters
        filter_idx_selected
        %app.ftr             % N by 1 logical array, serve as filter
        
        TraceViewerApp
        
        xyz             % raw x,y,z coordiates of localization data
        nDim            % localization data dimension, 0 when no valid data detected
        zScale          % Z aixs scaling factor, as realZ = dataZ * zScale

        %attr_1
        %attr_2
        val_1
        val_2
        val_c
        linePlot
        
        histPlot
        val_hist
        hist_minLine
        hist_maxLine


        %mainPlotColor
        
        %roi_exist           % boolean to decide if there's ROI in plots
        index_roi           % index of data within ROI
        linePlot_roi        % line object
        histPlot_roi        % histogram object
        histPlot_roi_box    % rectangle object
        scatterPlot_roi     % scatter object
        color_roi
        
        fig_scatter
        ax_scatter
        scatterPlot
        
    end
    
    methods (Access = private)
        
%         function loadMinfluxData (app)
%             app.data = load(fullfile(app.path, app.file), '-mat');
%             arrangeData(app);
%         end
%         
%         function arrangeData (app)
%             if isempty(app.data) || ~isfield(app.data, 'itr')
%                 return
%             end
%             % store app.data into temporary variable
%             data_temp = app.data;
% 
%             % remove reference point attribute
%             if isfield(app.data, 'mbm')
%                 data_temp = rmfield(data_temp, 'mbm');
%             end
%             
%             % Abberrior Imspector format, unwrap attr contained in 'itr'
%             if ~isfield(app.data, 'loc')
%                 names_1 = fieldnames(data_temp.itr);
%                 cells_1 = struct2cell(data_temp.itr);
%                 data_temp = rmfield(data_temp, 'itr');
%                 names_2 = fieldnames(data_temp);
%                 cells_2 = struct2cell(data_temp);
%                 data_temp = cell2struct([cells_1; cells_2], [names_1; names_2]);
%             end
%             
%             % localization data
%             if ~isfield(data_temp, 'loc')
%                 return
%             end
%             
%             % get complete data attribute name list
%             attr_names = fieldnames(data_temp);
% 
%             % get N(loc) and N(itr)
%             itr = data_temp.itr;
%             [app.nLoc, app.nItr] = size(itr);
%             vld = true(app.nLoc, 1);
%             if isfield(data_temp, 'vld')
%                 vld = data_temp.vld;
%             end
%             % arrange format and dimension of nLoc and nItr
%             if app.nLoc == 1
%                 app.nLoc = app.nItr;    % swap to get the correct number of localizations
%                 if app.nLoc == 1    % data with only 1 localization, invalid
%                     return
%                 end
%                 app.nItr = 1;   % only 1 iteration
%             end
%             app.nLoc = size(data_temp.loc(vld, :), 1);
% 
%             % arrange attribute values to be: N*1, or N*3
%             for i = 1 : length(attr_names)
%                 % check attr dimension
%                 attrName = attr_names{i};
%                 value = data_temp.(attrName);
%                 % squeeze attribute that more than 2 dimension
%                 if ndims(value)==3   % loc, lnc, ext
%                     data_temp = rmfield(data_temp, attrName);
%                     value = squeeze(value(vld, end, :));   % only take last iteration
%                     data_temp.([attrName, '_x']) = value(:, 1);
%                     data_temp.([attrName, '_y']) = value(:, 2);
%                     data_temp.([attrName, '_z']) = value(:, 3);
%                     continue;
%                 end
%                 % swap value to N by 1
%                 if (size(value, 1) == 1)
%                     value = value';
%                 end
%                 % only take value from last iteration, except for 'itr'
%                 %if ~strcmp(attrName, 'itr')
%                     value = value(vld, end);
%                 %end
%                 % remove all NaN attributes
% %                 if all(isnan(value))
% %                     continue;
% %                 end
%                 % change logical to numerical, !!!maybe unnecessary
%                 %if isa(value, 'logical')    
%                 %    value = int8(value);
%                 %end
%                 data_temp.(attrName) = value;
%             end
%             app.data = data_temp;
%             % get trace ID, and nLoc per trace
%             app.traceID = unique(app.data.tid(vld));
%             app.traceLength = arrayfun(@(x) sum(app.data.tid==x), app.traceID);
%         end
%         
%         function resetData (app)
%             app.data = [];
%             %app.data_filtered = [];
%             app.attributes = [];
%             app.nItr = 0;
%             app.nLoc = 0;
%             %app.xyz = [];
%             app.nDim = 0;
%             app.zScale = 1;
%             app.zscaleEditField.Value = 1;
%             app.val_1 = [];
%             app.val_2 = [];
%             app.val_c = [];
%             app.zScaleAutoCheckBox.Value = 0; % by default, no auto scale Z
%             app.filters = [];
%             app.UITableFilter.Data = [];
% 
%             %app.filtered = [];
%             if app.firstLoad    % some values can persist through different dataset
%                 app.color_roi = [1 0 1];    % default ROI color is yellow
%             end
%             % clear ROI
%             app.index_roi = [];
%             %if (app.roi_exist)
%                 %app.index_roi = [];
%                 %delete(app.linePlot_roi);
%                 %delete(app.histPlot_roi);
%                 %delete(app.histPlot_roi_box);
%                 %delete(app.scatterPlot_roi);
%             %end
%         end
% 
%         function value = getAttrValue (app, attrName)
%             if ~isempty(app.data)
%                 value = getfield(app.data, attrName);
%                 %value = value(app.ftr, :);     % apply filter
%             else
%                 value = [];
%             end
%         end
% 
%         function addExtraAttr (app)
%             % 1-based iteration
%             app.data.itr = int8(1 + app.data.itr(app.data.vld, :));
%             % locate trace change index in raw data
%             tim = app.data.tim;
%             tid = app.data.tid;
%             idx = find(diff(tid));
%             % compute time interval from time stamp
%             dt = diff(tim);
%             dt(idx) = 0;  % remove in-between trace time interval
%             dt = [0; dt];
%             app.data.dt = dt;
%             % compute relative time stamp of each trace
%             t_start = tim([1; idx+1]);
%             %t_end = tim([idx; end]);
%             app.data.nLoc = repelem(app.traceLength, app.traceLength);
%             t_min = repelem(t_start, app.traceLength);
%             app.data.tim_trace = tim - t_min;
%             
%             %t_min = repelem(t_start, trace_length);
%             %t_max = repelem(t_end, trace_length);
%             %t_diff = tim - t_min;
%             %app.data.ttz = t_diff ./ (t_max-t_min);
%             
%             % add travel distance, and instaneous speed attribute
%             loc = [app.data.loc_x, app.data.loc_y, app.data.loc_z];
%             app.data.dst = [0; vecnorm(diff(loc), 2, 2)];
%             app.data.dst(idx+1) = 0;
%             app.data.spd = app.data.dst ./ dt;
%             % add filter of data
%             app.ftr = true(app.nLoc, 1);
%             % add index of data
%             app.data.idx = uint32(1:app.nLoc)';
%         end
% 
%         function loadAttribute (app)
%             app.attributes = fieldnames(app.data);
%         end
% 
%         function updateAttrList (app)
%             % update drop-down menu items with number of iteration of data
%             app.attributeDropDown_1.Items = app.attributes;
%             app.attributeDropDown_2.Items = app.attributes;
%             app.colorByAttributeDropDown_3.Items = app.attributes;
%             app.histAttributeDropDown_4.Items = app.attributes;
%             if app.firstLoad
%                 app.attributeDropDown_2.Value = app.attributes{end};
%                 app.histAttributeDropDown_4.Value = app.attributes{end};
%             end
%         end
%              
%         function addFilterToTable (app)
%             % get filter paramters from histogram panel
%             apply = true;
%             attr = app.histAttributeDropDown_4.Value;
%             attrValue = getfield(app.data, attr); % we get the raw attribute value from data
%             plotVar = app.plotVarDropDown.Value;
%             minVal = app.minSpinner.Value;
%             maxVal = app.maxSpinner.Value;
%             
%             switch plotVar
%                 case 'per loc'
%                     histVal = attrValue;
%                 case 'trace mean'
%                     histVal = arrayfun(@(x) mean(attrValue(app.data.tid==x, :)), app.traceID);
%                 case 'trace stdev'
%                     histVal = arrayfun(@(x) std(attrValue(app.data.tid==x, :)), app.traceID);
%                 case 'trace median'
%                     histVal = arrayfun(@(x) median(attrValue(app.data.tid==x, :)), app.traceID);
%                 case 'trace mode'
%                     histVal = arrayfun(@(x) mode(attrValue(app.data.tid==x, :)), app.traceID);
%                 case 'trace max'
%                     histVal = arrayfun(@(x) max(attrValue(app.data.tid==x, :)), app.traceID);
%                 case 'trace min'
%                     histVal = arrayfun(@(x) min(attrValue(app.data.tid==x, :)), app.traceID);
%                 case 'trace range'
%                     histVal = arrayfun(@(x) range(attrValue(app.data.tid==x, :)), app.traceID);
%                 otherwise
%                     histVal = attrValue;
%             end
% 
%             ftr_new = histVal>=minVal & histVal<=maxVal;
%             if startsWith(plotVar, 'trace')
%                 ftr_new = repelem(ftr_new, app.traceLength);
%             end
%             % create new filter param cell array
%             new_filter = {apply, attr, plotVar, minVal, maxVal, histVal, ftr_new};
%             % add filter to filter table UI
%             if isempty(app.UITableFilter.Data)
%                 app.UITableFilter.Data = new_filter(1:end-2);
%                 app.filters = new_filter;
%                 % attempt to create a right click context menu on the
%                 % filter table list
% %                 cm = uicontextmenu;
% %                 m1 = uimenu(cm,'Text','Edit');
% %                 m2 = uimenu(cm,'Text','Delete');
% %                 app.UITableFilter.UIContextMenu = cm;
%             else
%                 app.UITableFilter.Data(end+1, :) = new_filter(1:end-2);
%                 app.filters(end+1, :) = new_filter;
%             end
%             % apply the newly created filter
%             app.ftr = app.ftr & ftr_new;
%             applyFilter(app);
%         end
%     
%         function updateFilter (app)
%             app.ftr = true(app.nLoc, 1);
%             if isempty(app.UITableFilter.Data) || isempty(app.filters)
%                 return;
%             end
%             for i = 1 : size(app.filters, 1)
%                 if (app.UITableFilter.Data{i, 1} == 1)
%                     app.ftr = app.ftr & app.filters{i, end};
%                 end
%             end
%         end
% 
%         function applyFilter (app)
% 
%             %overview_xlim = app.UIAxes_overview.XLim;
%             %overview_ylim = app.UIAxes_overview.YLim;
%             %hist_xlim = app.UIAxes_histogram.XLim;
%             %hist_ylim = app.UIAxes_histogram.YLim;
% 
% 
%             app.linePlot.XData = app.val_1(app.ftr, :);
%             app.linePlot.YData = app.val_2(app.ftr, :);
%             
%             app.val_hist = getHistPlotValue (app);
%             updateHistPlot(app);
%             %app.histPlot.Data = app.val_hist(app.ftr, :);
%             
%             
% %             app.UIAxes_overview.XLimMode = 'auto';
% %             app.UIAxes_overview.YLimMode = 'auto';
% %             app.UIAxes_histogram.YLimMode = 'auto';
%             % restore limits of plots
%             %app.UIAxes_overview.XLim = overview_xlim;
%             %app.UIAxes_overview.YLim = overview_ylim;
%             %app.UIAxes_histogram.XLim = hist_xlim;
%             %app.UIAxes_histogram.YLim = hist_ylim;
% 
%             if ~isempty(app.scatterPlot) && isgraphics(app.scatterPlot)
%                 %set(app.ax_scatter, 'NextPlot', 'replacechildren');
%                 scatter_xlim = app.ax_scatter.XLim;
%                 scatter_ylim = app.ax_scatter.YLim;
%                 scatter_zlim = app.ax_scatter.ZLim;
%                 
%                 app.scatterPlot.XData = app.xyz(app.ftr, 1);
%                 app.scatterPlot.YData = app.xyz(app.ftr, 2);
%                 app.scatterPlot.ZData = app.xyz(app.ftr, 3);
%                 app.scatterPlot.CData = app.val_c(app.ftr, end); 
%                 
%                 app.scatterPlot.DataTipTemplate.DataTipRows(end).Value = num2cell(app.data.tid(app.ftr));
%                 %app.ax_scatter.XLimMode = 'auto';
%                 %app.ax_scatter.YLimMode = 'auto';
%                 %app.ax_scatter.ZLimMode = 'auto';
% 
%                 app.ax_scatter.XLim = scatter_xlim;
%                 app.ax_scatter.YLim = scatter_ylim;
%                 app.ax_scatter.ZLim = scatter_zlim;
%             end
%             
%             % apply filter to ROI if there's any
%             if any(app.index_roi)
%                 plotSelected(app, app.index_roi & app.ftr);
%             end
%         end
%           
%         function updateMainPlot (app)
%             app.linePlot = scatter(app.UIAxes_overview, app.val_1, app.val_2, '.');
% %             if ~isempty(app.histPlot)
% %                 app.histPlot.Data = app.val_2;
% %             else
% %                 app.histPlot = histogram(app.UIAxes_histogram, app.val_2, 'EdgeAlpha', 0.1);
% %             end
%             xlabel(app.UIAxes_overview, app.attributeDropDown_2.Value);
%             ylabel(app.UIAxes_overview, app.attributeDropDown_1.Value);
% %            xlabel(app.UIAxes_histogram, app.attributeDropDown_1.Value);
%             axis(app.UIAxes_overview, 'auto');
% %            axis(app.UIAxes_histogram, 'auto');
%             
%             idx_selected = app.index_roi;
%             
%             % !!! apply filter also to ROI index
% 
%             if any(idx_selected)
%                 plotROI_overview(app, idx_selected);
%                 plotROI_histogram(app, idx_selected);
%             end
%         end
%         
%         function val = getHistPlotValue (app, attr, plotVar, applyFilter)
%             val = [];
%             if isempty(app.data)
%                 return;
%             end
%             
%             if nargin < 4
%                 applyFilter = true;
%             end
% 
%             if nargin == 1
%                 attr = app.histAttributeDropDown_4.Value;
%                 plotVar = app.plotVarDropDown.Value;
%             end
% 
%             attrValue = getAttrValue(app, attr);
%             if applyFilter
%                 attrValue = attrValue(app.ftr, :);
%             end
%             if strcmp('per loc', plotVar)
%                 val = attrValue;
%                 return;
%             end
%             tid = app.data.tid;
%             if applyFilter
%                 tid = tid(app.ftr);
%             end
%             tid(isnan(attrValue)) = []; attrValue(isnan(attrValue)) = [];
%             trace_ID = unique(tid);
%             switch plotVar
%                 case 'per loc'
%                     val = attrValue;
%                 case 'trace mean'
%                     val = arrayfun(@(x) mean(attrValue(tid==x, :)), trace_ID);
%                 case 'trace stdev'
%                     val = arrayfun(@(x) std(attrValue(tid==x, :)), trace_ID);
%                 case 'trace median'
%                     val = arrayfun(@(x) median(attrValue(tid==x, :)), trace_ID);
%                 case 'trace mode'
%                     val = arrayfun(@(x) mode(attrValue(tid==x, :)), trace_ID);
%                 case 'trace max'
%                     val = arrayfun(@(x) max(attrValue(tid==x, :)), trace_ID);
%                 case 'trace min'
%                     val = arrayfun(@(x) min(attrValue(tid==x, :)), trace_ID);
%                 case 'trace range'
%                     val = arrayfun(@(x) range(attrValue(tid==x, :)), trace_ID);
%                 otherwise
%                     val = attrValue;
%             end
%         end
% 
%         function updateHistPlot (app, minVal, maxVal)
%             % update histogram plot: check plotVar, filter, ROI, minVal, maxVal
%             % get attr from histAttr dropdown, get plot var from plotVar dropdown
%             % plot histogram, bin size auto
%             % update bin size and step size
%             % get minVal and maxVal from the min and max spinner, if init,
%             % or
%             % get attr, plotVar, min, max from selected filter
%             %
%             if isempty(app.val_hist) || all(isnan(app.val_hist))
%                 return;
%             end
%             % get min and max value, and update spinner
%             if nargin == 1 % get hist plot parameter from UI
%                 minVal = double(min(app.val_hist));
%                 maxVal = double(max(app.val_hist));  
%             end
%             app.minSpinner.Value = minVal;
%             app.maxSpinner.Value = maxVal;
%             % udpate step size of the spinners
%             stepSize = range(app.val_hist) / 20;
%             if stepSize > 0
%                 app.minSpinner.Step = stepSize;
%                 app.maxSpinner.Step = stepSize;
%                 app.binsizeSpinner.Step = 4*stepSize / sqrt(numel(app.val_hist));
%             end
%             
%             
%             if ~isempty(app.histPlot) && isgraphics(app.histPlot)
%                 app.histPlot.Data = app.val_hist;
%             else
%                 app.histPlot = histogram(app.UIAxes_histogram, app.val_hist);
%             end
%             xlabel(app.UIAxes_histogram, strcat(app.histAttributeDropDown_4.Value, {' : '}, app.plotVarDropDown.Value));
%             app.histPlot.BinMethod = 'auto';
%             app.UIAxes_histogram.YLimMode = 'auto';
%             %app.axes_histogram.XLimMode = 'auto';
%             %app.axes_histogram.YLimMode = 'auto';
% 
%             app.binsizeSpinner.Value = app.histPlot.BinWidth;
%             
%             if ~isempty(app.hist_minLine)
%                 app.hist_minLine.Value = minVal;
%             else
%                 app.hist_minLine = xline(app.UIAxes_histogram, minVal, 'LineWidth', 2, 'Color', 'red', 'buttonDownFcn', @startDragFcn);
%             end
%             if ~isempty(app.hist_maxLine)
%                 app.hist_maxLine.Value = maxVal;
%             else
%                 app.hist_maxLine = xline(app.UIAxes_histogram, maxVal, 'LineWidth', 2, 'Color', 'red', 'buttonDownFcn', @startDragFcn);
%             end
% 
%             function startDragFcn(src, ~)
%                 set(app.UIFigureMain,'WindowButtonMotionFcn',{@draggingFcn, src});
%             end
% 
%             function draggingFcn(~, ~, src_line)
%                 pt=get(app.UIAxes_histogram, 'CurrentPoint');
%                 newX = pt(1,1);
%                 src_line.Value = newX;
%                 if isequal(src_line, app.hist_minLine)
%                     app.minSpinner.Value = newX;
%                 else
%                     app.maxSpinner.Value = newX;
%                 end
%             end
%         end
%         
%         function updateScatterPlot (app)    % only used now when loading new dataset
%             % use case
%             % color by dropdown; colormap dropdown; z-scale; apply filter;
%             if isempty(app.fig_scatter) || ~isgraphics(app.fig_scatter)
%                 return;
%             end
%             % get filter and ROI if there's any
%             ftr_sc = true(app.nLoc, 1);
%             idx_selected = app.index_roi;
%             if (app.applyFilterCheckBox.Value)
%                 ftr_sc = app.ftr;
%                 idx_selected = idx_selected & app.ftr;
%             end
%             % update X, Y, Z and C data
%             app.scatterPlot.XData = app.xyz(ftr_sc, 1);
%             app.scatterPlot.YData = app.xyz(ftr_sc, 2);
%             app.scatterPlot.ZData = app.xyz(ftr_sc, 3);
%             app.scatterPlot.CData = app.val_c(ftr_sc, end);
%             % update color map
%             cmap = app.colormapDropDown.Value;
%             if strcmp('default', cmap)
%                 cmap = [0 0.4470 0.7410];
%             elseif strcmp('glasbey', cmap)
%                 cmap = makeGlasbey(app);
%             end
%             colormap(app.ax_scatter, cmap);
%             %colorbar(app.ax_scatter); 
%             % update ROI region if there's any
%             if any(idx_selected)
%                 plotROI_scatter (app);
%             end 
%         end
%         
%         function getLocData (app)
%             if (isempty(app.data) || ~isfield(app.data, 'loc_x'))
%                 return;
%             end
%             % get valid localization coordinates
%             check3D(app);
%             if app.nDim < 3
%                 app.zscaleEditField.Value = 0;
%                 app.zscaleEditField.Editable = false; 
%                 app.zScaleAutoCheckBox.Enable = 'off';
%             else
%                 app.zscaleEditField.Value = 1.0;
%                 app.zscaleEditField.Editable = true; 
%                 app.zScaleAutoCheckBox.Enable = 'on';
%             end
%             app.xyz = [app.data.loc_x, app.data.loc_y, app.data.loc_z*app.zScale];
%         end
% 
%         function plotScatter (app)
%             if (isempty(app.data) || ~isfield(app.data, 'loc_x'))
%                 return;
%             end
%             if isempty(app.xyz)
%                 getLocData(app);
%             end
%             app.fig_scatter = findobj( 'Type', 'Figure', 'Name', 'MINFLUX 3D Scatter Plot' );
%             if isempty(app.fig_scatter)
%                 app.fig_scatter = figure('Name', 'MINFLUX 3D Scatter Plot');
%                 app.fig_scatter.Position = [1000, 100, 1024, 1024];
%                 %app.fig_scatter.NumberTitle = 'off';
%             end
%             %app.fig_scatter.Position(3) = 1024;
%             %app.fig_scatter.Position(4) = 1024;
%             set(0, 'CurrentFigure', app.fig_scatter);
%             app.scatterPlot = scatter3(app.xyz(app.ftr,1), app.xyz(app.ftr,2), app.xyz(app.ftr,3), '.');
%             
%             app.scatterPlot.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("tid",  num2cell(app.data.tid(app.ftr)));
%             app.ax_scatter = gca;
%             xlabel(app.ax_scatter, 'X', 'FontSize', 24);
%             ylabel(app.ax_scatter, 'Y', 'FontSize', 24);
%             zlabel(app.ax_scatter, 'Z', 'FontSize', 24);
%             axis(app.ax_scatter, 'equal');
%             view(app.ax_scatter, 2);
%             % apply color attribute and color map
%             app.val_c = getAttrValue(app, app.colorByAttributeDropDown_3.Value);
%             app.scatterPlot.CData = app.val_c(app.ftr, end);
%             cmap = app.colormapDropDown.Value;
%             if strcmp('default', cmap)
%                 cmap = [0 0.4470 0.7410];
%             elseif strcmp('glasbey', cmap)
%                 cmap = makeGlasbey(app);
%             end
%             colormap(app.ax_scatter, cmap);
%             colorbar(app.ax_scatter);
%             % create ROI button
%             uicontrol('Parent', app.fig_scatter, ...
%                 'Style','pushbutton',...
%                 'Units','normalized',...
%                 'Position',[0.3 0.02 0.08 0.03],...
%                 'Fontsize',10,...
%                 'string','ROI',...
%                 'Visible','on',...
%                 'Callback',{@ROIButtonScatterPushed});
%             % ROI button callback function
%             function ROIButtonScatterPushed (~, ~) % input var differ from UIcontrol
%                 getSelectedIndex (app, 'Scatter');
%                 plotSelected(app, app.index_roi);
%             end
%             %linkdata(app.fig_scatter, 'on');
%         end
% 
%         function roi = drawRoi (app, ax)
%             switch app.ROIshapeDropDown.Value
%                 case 'Box'
%                     roi = drawrectangle(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
%                 case 'Oval'
%                     roi = drawcircle(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
%                 case 'Polygon'
%                     roi = drawpolygon(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
%                 case 'Freehand'
%                     roi = drawfreehand(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
%             end
%         end
%         
%         function plotSelected (app, idx_selected)
%             % plot selected (ROI) data portion, with ROI color, in overview,
%             % histogram, and (if exist) scatter plot
%             % delete old ROI if there's any
%             if isempty(idx_selected) || sum(idx_selected)==0
%                 app.linePlot_roi.XData = [];
%                 app.linePlot_roi.YData = [];
%                 app.histPlot_roi.Data = [];
%                 app.scatterPlot_roi.XData = [];
%                 app.scatterPlot_roi.YData = [];
%                 app.scatterPlot_roi.ZData = [];
%                 delete(app.histPlot_roi_box);
%                 return;
%             end
%             plotROI_overview(app, idx_selected);
%             plotROI_histogram(app, idx_selected);
%             try
%                 plotROI_scatter(app, idx_selected);
%             catch ME
%                 disp(strcat(" line 454: ", ME.message));
%             end
%         end
%         
%         function plotROI_overview (app, idx_selected)
%             roi_exist = ~isempty(app.linePlot_roi) && isgraphics(app.linePlot_roi);
%             if roi_exist
%                 app.linePlot_roi.XData = app.val_1(idx_selected);
%                 app.linePlot_roi.YData = app.val_2(idx_selected);
%             else
%                 set(app.UIAxes_overview, 'NextPlot', 'add');
%                 app.linePlot_roi = plot(app.UIAxes_overview, app.val_1(idx_selected), app.val_2(idx_selected), '.');
%                 app.linePlot_roi.MarkerEdgeColor = app.color_roi;
%                 set(app.UIAxes_overview, 'NextPlot', 'replace');
%             end
%         end
%         
%         function plotROI_histogram (app, idx_selected)
%             roi_exist = ~isempty(app.histPlot_roi) && isgraphics(app.histPlot_roi);
%             if roi_exist
%                 app.histPlot_roi.Data = app.val_2(idx_selected);
%                 delete(app.histPlot_roi_box);
%             else
%                 set(app.UIAxes_histogram, 'NextPlot', 'add');
%                 app.histPlot_roi = histogram(app.UIAxes_histogram, app.val_2(idx_selected), ...
%                     'BinEdges', app.histPlot.BinEdges, 'FaceColor', app.color_roi, 'EdgeAlpha', 0.1);
%                 set(app.UIAxes_histogram, 'NextPlot', 'replace');
%             end
%             %app.histPlot_roi.FaceColor = app.color_roi;
%             set(app.UIAxes_histogram, 'NextPlot', 'add');
%             hist_roi_x = min(app.val_2(idx_selected));
%             hist_roi_width = max(app.val_2(idx_selected)) - hist_roi_x;
%             hist_roi_y = 0;
%             hist_roi_height = app.UIAxes_histogram.YLim(2) - hist_roi_y;
%             app.histPlot_roi_box = drawrectangle(app.UIAxes_histogram, ...
%                 'Color', app.color_roi, 'StripeColor', 'none', ...
%                 'Position', ...
%                 [hist_roi_x hist_roi_y hist_roi_width hist_roi_height]);
%             set(app.UIAxes_histogram, 'NextPlot', 'replace');     
%         end
%         
%         function plotROI_scatter (app, idx_selected)
%             roi_exist = ~isempty(app.scatterPlot_roi) && isgraphics(app.scatterPlot_roi);
%             if roi_exist
%                 app.scatterPlot_roi.XData = app.xyz(idx_selected, 1);
%                 app.scatterPlot_roi.YData = app.xyz(idx_selected, 2);
%                 app.scatterPlot_roi.ZData = app.xyz(idx_selected, 3);
%             else
%                 %disp(strcat(" line 502: ", ME.message));
%                 set(app.ax_scatter, 'NextPlot', 'add');
%                 app.scatterPlot_roi = scatter3(app.ax_scatter, ...
%                     app.xyz(idx_selected, 1), ...
%                     app.xyz(idx_selected, 2), ...
%                     app.xyz(idx_selected, 3), ...
%                     'Marker', '.', ...
%                     'MarkerEdgeColor', app.color_roi);
%                 set(app.ax_scatter, 'NextPlot', 'replace');
%             end
%             app.scatterPlot_roi.MarkerEdgeColor = app.color_roi;
%         end
%         
%         
%         function getSelectedIndex (app, whichPlot)
%             % get selected index of (filtered/unfiltered) data ROI regions in:
%             % overview plot, histogram plot, and (if exist) scatter plot 
%             if isempty(app.data)
%                 return;
%             end
%             app.index_roi = zeros(app.nLoc, 1);
%             % switch which figure/plot to draw ROI, and get selected index
%             switch whichPlot
%                 case 'Overview'
%                     %roi = drawrectangle(app.UIAxes_overview, 'Color', 'y', 'StripeColor', 'none', 'LineWidth', 1);
%                     roi = drawRoi(app, app.UIAxes_overview);
%                     % get within range val_1 and val_2
%                     try
%                         app.index_roi = inROI(roi, double(app.val_1), double(app.val_2));
%                     catch ME
%                         disp(strcat(" line 533: ", ME.message));
%                     end
%                     roi.delete();  
%                 case 'Histogram'
%                     %roi = drawrectangle(app.UIAxes_histogram, 'Color', 'y', 'StripeColor', 'none', 'LineWidth', 1);
%                     roi = drawRoi(app, app.UIAxes_histogram);
%                     % get min and max of val_2
%                     x_min = roi.Position(1);
%                     x_max = x_min + roi.Position(3);
%                     app.index_roi = app.val_2 >= x_min & app.val_2 <= x_max;
%                     roi.delete();  
%                 case 'Scatter'
%                     %roi = drawrectangle(app.ax_3D, 'Color', 'y', 'StripeColor', 'none', 'LineWidth', 1);
%                     roi = drawRoi(app, app.ax_scatter);
%                     app.index_roi = inROI(roi, app.xyz(:,1), app.xyz(:,2)); % check 1st and 2nd dimension
%                     roi.delete();       % remove ROI
%             end
%             app.index_roi = app.index_roi & app.ftr;
%         end
% 
%         function check3D (app)
%             app.nDim = 0;
%             if (isempty(app.data.loc_x))
%                 return;
%             end
%             if (all(app.data.loc_z==0))
%                 app.nDim = 2;
%             else
%                 app.nDim = 3;
%             end
%         end
%         
%         function success = computeZscale (app)
%             % get trace ID and occurence
%             %tid_vld = app.data.tid(app.data.vld);
%             success = false;
%             tid = app.data.tid;
%             id = unique(tid);
%             freq = histcounts(tid, [id; inf])';
%             num_id = numel(id);
%             % estimate isotropy for each of the selected traces
%             zScale_tid = zeros (num_id, 1);
%             for i = 1 : num_id
%                 zScale_tid(i, :) = freq(i) .* ...
%                     estimateZscale ( app, ...
%                     app.data.loc_x(tid==id(i)), ...
%                     app.data.loc_y(tid==id(i)), ...
%                     app.data.loc_z(tid==id(i)) );
%             end
%             % remove outlier
%             outlier = isoutlier(zScale_tid);
%             zScale_tid = zScale_tid(~outlier, :);
%             freq = freq(~outlier, :);
%             if (size(zScale_tid, 1) ~= 1)
%                 %isotropy = isotropy ./ freq;
%                 zScale_tid = sum(zScale_tid,'omitnan') / sum(freq(~isnan(zScale_tid(:,1))));
%             end
%             if (zScale_tid<0.5 || zScale_tid>1.0)
%                 disp(' Failed to compute z-scale from loc data!');
%             else
%                 success = true;
%                 app.zScale = zScale_tid;
%             end
%         end
% 
%         function scale = estimateZscale (~, x, y, z)
%             dispersion_x = iqr(x, 1);
%             dispersion_x = dispersion_x(1);
%             dispersion_y = iqr(y, 1);
%             dispersion_y = dispersion_y(1);
%             dispersion_z = iqr(z, 1);
%             dispersion_z = dispersion_z(1);
%             scale = geomean([dispersion_x, dispersion_y]) / dispersion_z;
%         end
%         
%         function glasbey_LUT = makeGlasbey (app)
%             nObj = 8; glasbey_LUT = zeros(nObj, 3);
%             if isempty(app.scatterPlot) || ~isgraphics(app.scatterPlot)
%                 return;
%             end
%             nObj = numel(unique(app.scatterPlot.CData));
%             glasbey_LUT = zeros(nObj,3);
%             
%             bg = [1 1 1]; % white background
%             n_grid = 30;  % number of grid divisions along each axis in RGB space
%             x = linspace(0, 1, n_grid);
%             [R,G,B] = ndgrid(x,x,x);
%             rgb = [R(:) G(:) B(:)];
%             if (nObj > size(rgb,1)/3)
%                 error('You can''t readily distinguish that many colors');
%             end
%             % Convert to Lab color space, which more closely represents human perception
%             C = makecform('srgb2lab');
%             lab = applycform(rgb, C);
%             bglab = applycform(bg, C);
%             mindist2 = inf(size(rgb,1),1);
%             for i = 1:size(bglab,1)-1
%                 dX = bsxfun(@minus,lab,bglab(i,:)); % displacement all colors from bg
%                 dist2 = sum(dX.^2,2);  % square distance
%                 mindist2 = min(dist2,mindist2);  % dist2 to closest previously-chosen color
%             end
%             % Iteratively pick the color that maximizes the distance to the nearest
%             % already-picked color
%             
%             lastlab = bglab(end,:);   % initialize by making the "previous" color equal to background
%             for i = 1:nObj
%                 dX = bsxfun(@minus,lab,lastlab); % displacement of last from all colors on list
%                 dist2 = sum(dX.^2,2);  % square distance
%                 mindist2 = min(dist2,mindist2);  % dist2 to closest previously-chosen color
%                 [~, id] = max(mindist2);  % find the entry farthest from all previously-chosen colors
%                 glasbey_LUT(i,:) = rgb(id,:);  % save for output
%                 lastlab = lab(id,:);  % prepare for next iteration
%             end
%         end
%         

    end
    
    
    methods (Access = public)
        
%         function data = getData (app)
%             data = app.data;
%             % apply filters
%             fnames = fieldnames(app.data);
%             for i = 1 : numel(fnames)
%                 f = fnames{i};
%                 data.(f) = app.data.(f)(app.ftr, :);
%             end
%         end
%         
%         function attributes = getAttributes (app)
%             attributes = app.attributes;
%         end
%         
%         function xyz = getLoc (app)
%             xyz = app.xyz(app.ftr, :);
%         end
%                
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Load the data.
            %load('patients.mat','LastName','Gender','Smoker','Age','Height','Weight','Diastolic','Systolic','Location');
            
            % Store the data in a table and display it in one of the App's tabs.
            %app.Data = table(LastName,Gender,Smoker,Age,Height,Weight,Diastolic,Systolic,Location);
           % app.UITableFilter.Data = app.Data;
            %app.BinWidth = app.BinWidthSlider.Value;
            
            % Update the axes with the corresponding data.
           % updateSelectedGenders(app)
            %refreshplot(app)
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigureMain.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {688, 688};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {336, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end

        % Button pushed function: LoadDataButton
        function LoadDataButtonPushed(app, event)
            persistent lastPath;
            % user dialog to open .mat file
            if isempty(lastPath)
                curentDir = pwd;
                idcs = strfind(curentDir, filesep);
                lastPath = curentDir(1:idcs(end)-1);
                %[app.file, app.path] = uigetfile('*.mat', "select MINFLUX raw data .mat file");   
            end
            [app.file, app.path] = uigetfile('*.mat', "select MINFLUX raw data .mat file", lastPath);
            if isequal(app.file, 0)
               return;
            end
            lastPath = app.path;
            
            % close dependent plots and app window
            if isgraphics(app.fig_scatter)
                %app.fig_scatter.
                delete(app.fig_scatter);
            end
%             if ~isempty(app.FilterDialogApp)
%                 delete(app.FilterDialogApp);
%                 app.addFilterButton.Enable = 'on';
%                 app.deleteFilterButton.Enable = 'on';
%             	app.displayFilterButton.Enable = 'on';
%                 app.filterListBox.Enable = 'on';
%             end
            if ~isempty(app.TraceViewerApp)
                delete(app.TraceViewerApp);
                app.Image2.Enable = 'on';
            end
            
            % parse file path
            app.TextArea.Value = fullfile(app.path, app.file);            
            % load MINFLUX raw data
            app.firstLoad = isempty(app.data);  % check whether it's the 1st loaded dataset
            resetData(app);
            loadMinfluxData(app);
            if (isempty(app.data) || ~isfield(app.data, 'tid'))
                delete app.data;
                return;
            end

            % get localization coordinates
            getLocData(app);

            % add extra attribute
            addExtraAttr(app);
            % load attribute name as list
            loadAttribute(app);
            updateAttrList(app);
            
	        % get attribute value for overview plot
            app.val_1 = getAttrValue(app, app.attributeDropDown_2.Value);
            app.val_2 = getAttrValue(app, app.attributeDropDown_1.Value);
            
            
	        % estimate localization precision, pixel size,

            % update main and scatter plot
            updateMainPlot(app);
            updateScatterPlot(app);
            app.index_roi = false(app.nLoc, 1);
        end

        % Button pushed function: LoadConfocalButton
        function LoadConfocalButtonPushed(app, event)
            [imgFile, imgDir] = uigetfile('*.tif', "select confocal TIFF image", app.path);
            if imgFile == 0
               return;
            end
            prompt = {'pixel size (nm):', 'X offset (m):', 'Y offset (m):', 'attribute name'};
            dlgtitle = 'confocal channel parameter:';
            fieldsize = [1 55; 1 55; 1 55; 1 55;];
            definput = {'50', '-3.11e-6', '-9.96e-6', 'conf_ch1'};
            answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
            if isempty(answer)
                return;
            end

            pixel_size = str2double(answer{1}) * 1e-9;
            x_offset = str2double(answer{2});
            y_offset = str2double(answer{3});
            attr_name = answer{4};
            
            imgPath = fullfile(imgDir, imgFile);
            info = imfinfo(imgPath);
            numX = info.Width;
            numY = info.Height;
            numZ = length(info);
            
            % take sum and normalize
            im = zeros(numY, numX);
            for k = 1 : numZ
                im = im + double(imread(imgPath, k));
            end
            bg = min(min(im));
            im = im - bg;
            im(1, 1) = 0;

            % translate loc to xyr
            %x = app.data.loc(:, 1); y = app.data.loc(:, 2);
            xo = (app.data.loc_x - x_offset) / pixel_size;
            yo = (app.data.loc_y - y_offset) / pixel_size;
            
            

            hFig = figure('Name', 'Overlay of localization onto Confocal Image');
            hFig.OuterPosition(3) = 3*numX; hFig.OuterPosition(4) = 3*numY;
            annotStr = {'Arrow keys to move', 'Esc to reset', 'Enter to confirm and load.'};
            an = annotation('textbox', [.257, .064, .483, .034], 'string', annotStr); %, 'FitBoxToText', 'on');
            an.LineStyle = 'none';  an.FontSize = 12;   an.FontWeight = 'bold';
            an.HorizontalAlignment = 'left';  an.VerticalAlignment = 'middle';
            

            set(0,'CurrentFigure', hFig);
            imshow(im, []);
            hold on;
            sc = scatter(xo, yo, 'y.');
            sc.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("tid",  num2cell(app.data.tid));
            %linkdata(hFig, 'on');
            set(hFig, 'KeyPressFcn', {@moveScatterPlot, app, xo, yo, attr_name});
            hold off;
            
            function moveScatterPlot(src, event, app, xo, yo, attr_name)
                hImage = findobj(src, 'Type', 'Image');
                image = hImage.CData;
                %[height, width] = size(image);
                hPlot = findobj(src, 'Type', 'Scatter');


                switch event.Key
                    case 'leftarrow'     % move scatter left
                        hPlot.XData = hPlot.XData - 0.5;
                    case 'rightarrow'    % move scatter right
                        hPlot.XData = hPlot.XData + 0.5;
                    case 'uparrow'       % move scatter up
                        hPlot.YData = hPlot.YData - 0.5;
                    case 'downarrow'     % move scatter down
                        hPlot.YData = hPlot.YData + 0.5;
                    case 'escape'
                        hPlot.XData = xo; hPlot.YData = yo;
                    case 'return'
                        % bilinear interpolation from confocal pixel value
                        val = interp2(image, hPlot.XData, hPlot.YData);
                        val( isnan(val) ) = 0; % remove NaN values;
                        %val = arrayfun(@(x) image(yr(x), xr(x)), 1:length(xr));
                        if isfield(app.data, attr_name)
                            app.data = rmfield(app.data, attr_name);
                        end
                        app.data.(attr_name) = val';
                        len = length(fieldnames(app.data));
                        app.data = orderfields(app.data, [1:len-2 len len-1]);
                        loadAttribute(app);
                        updateAttrList(app);
                        close(src);
                    otherwise   % do nothing     
                end

            end
        end

        % Button pushed function: SaveDataButton
        function SaveDataButtonPushed(app, event)
            data_ori = load(fullfile(app.path, app.file), '-mat');
            if ~isfield(data_ori, 'vld')
                return;
            end
            [save_file, save_path, indx] = uiputfile(fullfile(app.path, strcat('processed_', app.file)), 'File Selection');
            if indx == 0
                return;
            end
            idx = find(data_ori.vld);
            idx = idx(app.ftr);
            vld_new = false(size(data_ori.vld));
            vld_new(idx) = true;
            data_ori.vld = vld_new;
            
            zscale = app.zscaleEditField.Value;
            if isfield(data_ori, 'loc')
                data_ori.loc(:, :, 3) = data_ori.loc(:, :, 3) * zscale;
            elseif isfield(data_ori.itr, 'loc')
                data_ori.itr.loc(:, :, 3) = data_ori.itr.loc(:, :, 3) * zscale;
            else % no 'loc' detected!
                % warning(' loc attribute not found in data! ');
            end

            save(fullfile(save_path, save_file), '-struct', 'data_ori', '-v7.3');

        end

        % Cell selection callback: UITableFilter
        function UITableFilterCellSelection(app, event)
            app.filter_idx_selected = event.Indices(:, 1);
        end

        % Cell edit callback: UITableFilter
        function UITableFilterCellEdit(app, event)
            % filter table edit: apply, min, or max value change
            indices = event.Indices;
            newData = event.NewData;
            app.filter_idx_selected = indices(1);
            item = indices(2);
            switch item
                case 1  % apply filter
                    %updateFilter(app);
                case 4  % filter min value
                    plotVar = app.filters{app.filter_idx_selected, 3};
                    app.filters{app.filter_idx_selected, 4} = newData;
                    maxVal = app.filters{app.filter_idx_selected, 5};
                    histVal = app.filters{app.filter_idx_selected, 6};
                    ftr_edit = histVal>=newData & histVal<=maxVal;
                    if ~strcmp(plotVar, 'per loc')
                        ftr_edit = repelem(ftr_edit, app.traceLength);
                    end
                    app.filters{app.filter_idx_selected, end} = ftr_edit;
                case 5  % filter max value
                    plotVar = app.filters{app.filter_idx_selected, 3};
                    minVal = app.filters{app.filter_idx_selected, 4};
                    app.filters{app.filter_idx_selected, 5} = newData;
                    histVal = app.filters{app.filter_idx_selected, 6};
                    ftr_edit = histVal>=minVal & histVal<=newData;
                    if ~strcmp(plotVar, 'per loc')
                        ftr_edit = repelem(ftr_edit, app.traceLength);
                    end
                    app.filters{app.filter_idx_selected, end} = ftr_edit;
                otherwise
            end
            updateFilter(app);
            applyFilter(app);
        end

        % Button pushed function: loadFilterButton
        function loadFilterButtonPushed(app, event)
            loadFilterFromJson(app);
        end

        % Button pushed function: saveFilterButton
        function saveFilterButtonPushed(app, event)
            saveFilterToJson(app);                         
        end
        
        % Button pushed function: addFilterButton
        function addFilterButtonPushed(app, event)
            % switch tab to Histogram, sync val_2, and val_hist
            app.TabGroup.SelectedTab = app.HistogramTab;
        end

        % Button pushed function: deleteFilterButton
        function deleteFilterButtonPushed(app, event)
            if isempty(app.UITableFilter.Data) || isempty(app.filters) || isempty(app.filter_idx_selected)
                return;
            end
            %tdata = app.UITableFilter.Data;
            app.UITableFilter.Data(app.filter_idx_selected, :) = [];
            %app.UITableFilter.Data = tdata;
            app.filters(app.filter_idx_selected, :) = [];
        end

        % Button pushed function: displayFilterButton
        function displayFilterButtonPushed(app, event)
            if isempty(app.UITableFilter.Data) || isempty(app.filter_idx_selected)
                return;
            end
            % display selected filter
            app.histAttributeDropDown_4.Value = app.filters{app.filter_idx_selected, 2};
            app.plotVarDropDown.Value = app.filters{app.filter_idx_selected, 3};
            minVal = app.filters{app.filter_idx_selected, 4};
            maxVal = app.filters{app.filter_idx_selected, 5};
            %app.hist_minLine.Value = app.filters{app.filter_idx_selected, 4};
            %app.hist_maxLine.Value = app.filters{app.filter_idx_selected, 5};
            app.val_hist = app.filters{app.filter_idx_selected, 6};
            updateHistPlot(app, minVal, maxVal);
        end

        % Value changed function: attributeDropDown_1
        function attributeDropDown1ValueChanged(app, event)
            app.histAttributeDropDown_4.Value = app.attributeDropDown_1.Value;
            app.val_2 = getAttrValue(app, app.attributeDropDown_1.Value);
            app.plotVarDropDown.Value = 'per loc';
            app.val_hist = getHistPlotValue(app, app.histAttributeDropDown_4.Value, app.plotVarDropDown.Value, false);
            updateHistPlot(app);
            updateMainPlot(app);
        end

        % Value changed function: attributeDropDown_2
        function attributeDropDown2ValueChanged(app, event)
            app.val_1 = getAttrValue(app, app.attributeDropDown_2.Value);
            updateMainPlot(app);
        end

        % Button pushed function: scatterPlotButton
        function ScatterPlotButtonPushed(app, event)
            plotScatter(app);
        end

        % Value changed function: colorByAttributeDropDown_3
        function colorByAttributeDropDownValueChanged(app, event)
            if ~isempty(app.scatterPlot) && isgraphics(app.scatterPlot)
                app.val_c = getAttrValue(app, app.colorByAttributeDropDown_3.Value);
                app.scatterPlot.CData = app.val_c(app.ftr, end);
            end
        end

        % Value changed function: colormapDropDown
        function colormapDropDownValueChanged(app, event)
            if ~isempty(app.scatterPlot) && isgraphics(app.scatterPlot)
                cmap = app.colormapDropDown.Value;
                if strcmp('default', cmap)
                    cmap = [0 0.4470 0.7410];
                elseif strcmp('glasbey', cmap)
                    cmap = makeGlasbey(app);
                end
                colormap(app.ax_scatter, cmap);
            end
        end

        % Button pushed function: ROIButton_scatter
        function ROIButtonPushed(app, event)
            try
                getSelectedIndex (app, app.TabGroup.SelectedTab.Title);
                plotSelected (app, app.index_roi);
            catch ME
                disp(strcat(" line 815: ", ME.message));
            end
        end

        % Button pushed function: ROIcolorButton
        function ROIcolorButtonPushed(app, event)
            c = uisetcolor;
            if (c==0)
                return;
            end
            app.color_roi = c;
            try
                app.linePlot_roi.MarkerEdgeColor = app.color_roi;
                app.histPlot_roi.FaceColor = app.color_roi;
                app.histPlot_roi_box.Color = app.color_roi;
                app.scatterPlot_roi.MarkerEdgeColor = app.color_roi;
            catch ME
                error(" line 857: Failed to update ROI color");
            end
        end

        % Value changed function: zscaleEditField
        function zscaleEditFieldValueChanged(app, event)
            app.zScale = app.zscaleEditField.Value;
            app.zScaleAutoCheckBox.Value = false;     % not neccessary
            app.xyz(:, 3) = app.data.loc_z * app.zScale;
            app.data.znm = app.data.loc_z * app.zScale * 1e9;

            try
                app.scatterPlot.ZData = app.data.znm( app.ftr );
            catch ME
                error(" line 870: Failed to update scatter Plot ROI!");
            end
            % apply filter to ROI if there's any
            if any(app.index_roi)
                plotSelected(app, app.index_roi & app.ftr);
            end
        end

        % Value changed function: zScaleAutoCheckBox
        function zScaleAutoCheckBoxValueChanged(app, event)
            if (isempty(app.data.loc_z) || all(app.data.loc_z==0)) % auto z scale computation
                app.zScale = 1;
                app.zscaleEditField.Editable = false; % disable z scale edit field
                return;
            end
            if app.zScaleAutoCheckBox.Value && computeZscale(app)
                app.zscaleEditField.Editable = false; % disable z scale edit field
            else
                app.zScaleAutoCheckBox.Value = false;
                app.zscaleEditField.Editable = true; 
                app.zScale = 1;
            end
            app.zscaleEditField.Value = app.zScale;
            app.xyz(:, 3) = app.data.loc_z * app.zScale;
            app.data.znm = app.data.loc_z * app.zScale * 1e9;
            try
                app.scatterPlot.ZData = app.data.znm( app.ftr );
                %app.scatterPlot_roi.ZData = app.xyz(app.index_roi && app.ftr, 3);
                %app.scatterPlot.ZData = app.scatterPlot.ZData * app.zScale;
                %app.scatterPlot_roi.ZData = app.scatterPlot_roi.ZData * app.zScale;
            catch ME
                error(" line 894: Failed to update scatter Plot!");
            end
            % apply filter to ROI if there's any
            if any(app.index_roi)
                plotSelected(app, app.index_roi & app.ftr);
            end
        end

        % Button pushed function: LocPrecButton
        function LocPrecButtonPushed(app, event)
            computeLocPrecision(app);
        end

        % Image clicked function: Image
        function ImageClicked(app, event)
            if app.TabGroup.SelectedTab == app.OverviewTab
                app.TabGroup.SelectedTab = app.HistogramTab;
                app.Image.Parent = app.HistogramTab;
            else
                app.TabGroup.SelectedTab = app.OverviewTab;
                app.Image.Parent = app.OverviewTab;
            end
        end

        % Image clicked function: Image2
        function Image2Clicked(app, event)
            if isempty(app.data)
                return;
            end
            app.TraceViewerApp = MINFLUX_data_plot_trace_viewer(app);
        end

        % Value changed function: histAttributeDropDown_4
        function histAttributeDropDown_4ValueChanged(app, event)
            app.val_hist = getHistPlotValue(app);
            updateHistPlot(app);
        end

        % Value changed function: plotVarDropDown
        function plotVarDropDownValueChanged(app, event)
            app.val_hist = getHistPlotValue(app); 
            xlabel(app.UIAxes_histogram, strcat(app.histAttributeDropDown_4.Value, {' : '}, app.plotVarDropDown.Value));
            if ~isempty(app.val_hist) && isgraphics(app.histPlot)
                app.histPlot.Data = app.val_hist;
                app.binsizeSpinner.Value = app.histPlot.BinWidth;
            end
        end

        % Value changing function: binsizeSpinner
        function binsizeSpinnerValueChanging(app, event)
            if isempty(app.histPlot)
                return;
            end
            if event.Value <= 0
                app.binsizeSpinner.Value = range(app.val_hist)/numel(app.val_hist);
            else
                app.histPlot.BinWidth = event.Value;    
            end
        end

        % Value changed function: binsizeSpinner
        function binsizeSpinnerValueChanged(app, event)
            if isempty(app.histPlot)
                return;
            end
            if event.Value <= 0
                app.binsizeSpinner.Value = event.PreviousValue / 2;
            end
            app.histPlot.BinWidth = app.binsizeSpinner.Value;
        end

        % Value changing function: minSpinner
        function minSpinnerValueChanging(app, event)
            if ~isempty(app.hist_minLine)
                app.hist_minLine.Value = event.Value;
            end
        end

        % Value changing function: maxSpinner
        function maxSpinnerValueChanging(app, event)
            if ~isempty(app.hist_maxLine)
                app.hist_maxLine.Value = event.Value;
            end
        end

        % Button pushed function: addtofilterlistButton
        function addtofilterlistButtonPushed(app, event)
            if isempty(app.val_hist) || isempty(app.hist_minLine) || isempty(app.hist_maxLine)
                return;
            end
            addFilterToTable(app);
            %createFilter(app);
        end

        % Button pushed function: reverseFilterButton
        function reverseFilterButtonPushed(app, event)
            if isempty (app.val_hist) || isempty(app.histPlot)
                return;
            end
            minVal = min(app.val_hist);
            maxVal = max(app.val_hist);
            
            if (app.minSpinner.Value <= minVal) && (app.maxSpinner.Value < maxVal)
                % min <= min, max < max, low pass filter
                app.minSpinner.Value = app.maxSpinner.Value;
                app.maxSpinner.Value = maxVal;    
            elseif (app.minSpinner.Value > minVal) && (app.maxSpinner.Value >= maxVal)
                % min > min, max >= max, high pass filter
                app.maxSpinner.Value = app.minSpinner.Value;
                app.minSpinner.Value = minVal;
            end
            
            app.hist_minLine.Value = app.minSpinner.Value;
            app.hist_maxLine.Value = app.maxSpinner.Value; 
        end

        % Window button up function: UIFigureMain
        function UIFigureMainWindowButtonUp(app, event)
            set(app.UIFigureMain, 'WindowButtonMotionFcn', '');
        end

        % Close request function: UIFigureMain
        function UIFigureMainCloseRequest(app, event)
            if isgraphics(app.fig_scatter)
                delete(app.fig_scatter);
            end
            if ~isempty(app.TraceViewerApp)
                delete(app.TraceViewerApp);
            end
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigureMain and hide until all components are created
            app.UIFigureMain = uifigure('Visible', 'off');
            app.UIFigureMain.AutoResizeChildren = 'off';
            app.UIFigureMain.Position = [100 100 998 688];
            app.UIFigureMain.Name = 'MINFLUX Data Plot';
            app.UIFigureMain.CloseRequestFcn = createCallbackFcn(app, @UIFigureMainCloseRequest, true);
            app.UIFigureMain.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.UIFigureMain.WindowButtonUpFcn = createCallbackFcn(app, @UIFigureMainWindowButtonUp, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigureMain);
            app.GridLayout.ColumnWidth = {336, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.Scrollable = 'on';

            % Create PanelScatter
            app.PanelScatter = uipanel(app.LeftPanel);
            app.PanelScatter.TitlePosition = 'centertop';
            app.PanelScatter.Title = 'scatter plot';
            app.PanelScatter.Position = [6 8 325 165];

            % Create scatterPlotButton
            app.scatterPlotButton = uibutton(app.PanelScatter, 'push');
            app.scatterPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ScatterPlotButtonPushed, true);
            app.scatterPlotButton.Position = [14 44 109 56];
            app.scatterPlotButton.Text = 'View Localization';

            % Create zScaleAutoCheckBox
            app.zScaleAutoCheckBox = uicheckbox(app.PanelScatter);
            app.zScaleAutoCheckBox.ValueChangedFcn = createCallbackFcn(app, @zScaleAutoCheckBoxValueChanged, true);
            app.zScaleAutoCheckBox.Text = 'auto';
            app.zScaleAutoCheckBox.Position = [184 112 46 22];

            % Create ZscaleEditFieldLabel
            app.ZscaleEditFieldLabel = uilabel(app.PanelScatter);
            app.ZscaleEditFieldLabel.HorizontalAlignment = 'right';
            app.ZscaleEditFieldLabel.Position = [15 113 45 22];
            app.ZscaleEditFieldLabel.Text = 'Z scale';

            % Create zscaleEditField
            app.zscaleEditField = uieditfield(app.PanelScatter, 'numeric');
            app.zscaleEditField.Limits = [0 Inf];
            app.zscaleEditField.ValueDisplayFormat = '%.3f';
            app.zscaleEditField.ValueChangedFcn = createCallbackFcn(app, @zscaleEditFieldValueChanged, true);
            app.zscaleEditField.Position = [75 113 89 22];
            app.zscaleEditField.Value = 1;

            % Create colorbyDropDownLabel
            app.colorbyDropDownLabel = uilabel(app.PanelScatter);
            app.colorbyDropDownLabel.HorizontalAlignment = 'right';
            app.colorbyDropDownLabel.Position = [138 75 59 22];
            app.colorbyDropDownLabel.Text = 'color by';

            % Create colorByAttributeDropDown_3
            app.colorByAttributeDropDown_3 = uidropdown(app.PanelScatter);
            app.colorByAttributeDropDown_3.Items = {};
            app.colorByAttributeDropDown_3.ValueChangedFcn = createCallbackFcn(app, @colorByAttributeDropDownValueChanged, true);
            app.colorByAttributeDropDown_3.Position = [206 75 105 22];
            app.colorByAttributeDropDown_3.Value = {};

            % Create colormapDropDownLabel
            app.colormapDropDownLabel = uilabel(app.PanelScatter);
            app.colormapDropDownLabel.HorizontalAlignment = 'right';
            app.colormapDropDownLabel.Position = [137 42 60 22];
            app.colormapDropDownLabel.Text = 'color map';

            % Create colormapDropDown
            app.colormapDropDown = uidropdown(app.PanelScatter);
            app.colormapDropDown.Items = {'default', 'glasbey', 'parula', 'jet', 'turbo', 'hsv', 'hot', 'gray', 'bone', 'copper', 'pink', 'white', 'flag', 'lines', 'colorcube', 'vga', 'prism', 'cool', 'autumn', 'spring', 'winter', 'summer'};
            app.colormapDropDown.ValueChangedFcn = createCallbackFcn(app, @colormapDropDownValueChanged, true);
            app.colormapDropDown.Position = [206 42 104 22];
            app.colormapDropDown.Value = 'default';

            % Create ROIButton_scatter
            app.ROIButton_scatter = uibutton(app.PanelScatter, 'push');
            app.ROIButton_scatter.ButtonPushedFcn = createCallbackFcn(app, @ROIButtonPushed, true);
            app.ROIButton_scatter.Position = [14 8 61 23];
            app.ROIButton_scatter.Text = 'ROI';

            % Create ROIcolorButton
            app.ROIcolorButton = uibutton(app.PanelScatter, 'push');
            app.ROIcolorButton.ButtonPushedFcn = createCallbackFcn(app, @ROIcolorButtonPushed, true);
            app.ROIcolorButton.Position = [231 8 70 23];
            app.ROIcolorButton.Text = 'ROI color';

            % Create ROIshapeDropDown
            app.ROIshapeDropDown = uidropdown(app.PanelScatter);
            app.ROIshapeDropDown.Items = {'Box', 'Oval', 'Polygon', 'Freehand'};
            app.ROIshapeDropDown.Position = [100 8 105 23];
            app.ROIshapeDropDown.Value = 'Box';

            % Create LocPrecButton
            app.LocPrecButton = uibutton(app.PanelScatter, 'push');
            app.LocPrecButton.ButtonPushedFcn = createCallbackFcn(app, @LocPrecButtonPushed, true);
            app.LocPrecButton.Position = [238 111 68 24];
            app.LocPrecButton.Text = 'LocPrec';

            % Create PanelVisualization
            app.PanelVisualization = uipanel(app.LeftPanel);
            app.PanelVisualization.AutoResizeChildren = 'off';
            app.PanelVisualization.TitlePosition = 'centertop';
            app.PanelVisualization.Title = 'visualization option';
            app.PanelVisualization.Position = [6 181 327 57];

            % Create attributeDropDownLabel
            app.attributeDropDownLabel = uilabel(app.PanelVisualization);
            app.attributeDropDownLabel.HorizontalAlignment = 'center';
            app.attributeDropDownLabel.Position = [10 5 49 22];
            app.attributeDropDownLabel.Text = 'attribute';

            % Create attributeDropDown_2Label
            app.attributeDropDown_2Label = uilabel(app.PanelVisualization);
            app.attributeDropDown_2Label.HorizontalAlignment = 'center';
            app.attributeDropDown_2Label.Position = [172 5 49 22];
            app.attributeDropDown_2Label.Text = 'attribute';

            % Create attributeDropDown_2
            app.attributeDropDown_2 = uidropdown(app.PanelVisualization);
            app.attributeDropDown_2.Items = {};
            app.attributeDropDown_2.ValueChangedFcn = createCallbackFcn(app, @attributeDropDown2ValueChanged, true);
            app.attributeDropDown_2.Position = [231 5 80 22];
            app.attributeDropDown_2.Value = {};

            % Create attributeDropDown_1
            app.attributeDropDown_1 = uidropdown(app.PanelVisualization);
            app.attributeDropDown_1.Items = {};
            app.attributeDropDown_1.ValueChangedFcn = createCallbackFcn(app, @attributeDropDown1ValueChanged, true);
            app.attributeDropDown_1.Position = [64 5 80 22];
            app.attributeDropDown_1.Value = {};

            % Create PanelData
            app.PanelData = uipanel(app.LeftPanel);
            app.PanelData.TitlePosition = 'centertop';
            app.PanelData.Title = 'data selection';
            app.PanelData.Position = [7 483 325 171];
            
            % Create TextArea
            app.TextArea = uitextarea(app.PanelData);
            app.TextArea.Editable = 'off';
            app.TextArea.HorizontalAlignment = 'center';
            app.TextArea.Position = [70 8 253 140];
            app.TextArea.Value = {'MINFLUX data (.mat) path'};

            % Create LoadDataButton
            app.LoadDataButton = uibutton(app.PanelData, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.Position = [4 111 61 34];
            app.LoadDataButton.Text = {'Load'; 'Data'};

            % Create LoadConfocalButton
            app.LoadConfocalButton = uibutton(app.PanelData, 'push');
            app.LoadConfocalButton.ButtonPushedFcn = createCallbackFcn(app, @LoadConfocalButtonPushed, true);
            app.LoadConfocalButton.WordWrap = 'on';
            app.LoadConfocalButton.Position = [4 61 61 34];
            app.LoadConfocalButton.Text = 'Load Confocal';
            
            % Create SaveDataButton
            app.SaveDataButton = uibutton(app.PanelData, 'push');
            app.SaveDataButton.ButtonPushedFcn = createCallbackFcn(app, @SaveDataButtonPushed, true);
            app.SaveDataButton.WordWrap = 'on';
            app.SaveDataButton.Position = [4 11 61 34];
            app.SaveDataButton.Text = 'Save Data';

            % Create DataLabel
            app.DataLabel = uilabel(app.LeftPanel);
            app.DataLabel.HorizontalAlignment = 'center';
            app.DataLabel.FontSize = 15;
            app.DataLabel.FontWeight = 'bold';
            app.DataLabel.Position = [62 656 267 22];
            app.DataLabel.Text = 'Data';

            % Create filterPanel
            app.filterPanel = uipanel(app.LeftPanel);
            app.filterPanel.TitlePosition = 'centertop';
            app.filterPanel.Title = 'filter';
            app.filterPanel.Position = [6 245 325 231];

            % Create displayFilterButton
            app.displayFilterButton = uibutton(app.filterPanel, 'push');
            app.displayFilterButton.ButtonPushedFcn = createCallbackFcn(app, @displayFilterButtonPushed, true);
            app.displayFilterButton.Position = [157 6 63 23];
            app.displayFilterButton.Text = 'display';

            % Create deleteFilterButton
            app.deleteFilterButton = uibutton(app.filterPanel, 'push');
            app.deleteFilterButton.ButtonPushedFcn = createCallbackFcn(app, @deleteFilterButtonPushed, true);
            app.deleteFilterButton.Position = [123 7 20 20];
            app.deleteFilterButton.Text = '-';

            % Create addFilterButton
            app.addFilterButton = uibutton(app.filterPanel, 'push');
            app.addFilterButton.ButtonPushedFcn = createCallbackFcn(app, @addFilterButtonPushed, true);
            app.addFilterButton.Position = [88 7 20 20];
            app.addFilterButton.Text = {'+'; ''};

            % Create UITableFilter
            app.UITableFilter = uitable(app.filterPanel);
            app.UITableFilter.ColumnName = {'apply'; 'attr'; 'value as'; 'min'; 'max'};
            app.UITableFilter.ColumnWidth = {45, 55, 65, 'auto', 'auto'};
            app.UITableFilter.RowName = {};
            app.UITableFilter.SelectionType = 'row';
            app.UITableFilter.ColumnEditable = [true false false true true];
            app.UITableFilter.CellEditCallback = createCallbackFcn(app, @UITableFilterCellEdit, true);
            app.UITableFilter.CellSelectionCallback = createCallbackFcn(app, @UITableFilterCellSelection, true);
            app.UITableFilter.Multiselect = 'off';
            app.UITableFilter.Position = [2 37 322 169];

            % Create saveFilterButton
            app.saveFilterButton = uibutton(app.filterPanel, 'push');
            app.saveFilterButton.ButtonPushedFcn = createCallbackFcn(app, @saveFilterButtonPushed, true);
            app.saveFilterButton.Position = [262 6 48 23];
            app.saveFilterButton.Text = 'save';

            % Create loadFilterButton
            app.loadFilterButton = uibutton(app.filterPanel, 'push');
            app.loadFilterButton.ButtonPushedFcn = createCallbackFcn(app, @loadFilterButtonPushed, true);
            app.loadFilterButton.Position = [6 6 48 23];
            app.loadFilterButton.Text = 'load';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.RightPanel.Scrollable = 'on';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.RightPanel);
            app.TabGroup.Position = [7 8 645 670];

            % Create OverviewTab
            app.OverviewTab = uitab(app.TabGroup);
            app.OverviewTab.Title = 'Overview';

            % Create UIAxes_overview
            app.UIAxes_overview = uiaxes(app.OverviewTab);
            xlabel(app.UIAxes_overview, 'attr1')
            ylabel(app.UIAxes_overview, 'attr2')
            app.UIAxes_overview.XTickLabelRotation = 0;
            app.UIAxes_overview.YTickLabelRotation = 0;
            app.UIAxes_overview.ZTickLabelRotation = 0;
            app.UIAxes_overview.GridAlpha = 0.15;
            app.UIAxes_overview.MinorGridAlpha = 0.25;
            app.UIAxes_overview.Box = 'on';
            app.UIAxes_overview.Position = [6 10 638 630];

            % Create Image
            app.Image = uiimage(app.OverviewTab);
            app.Image.ScaleMethod = 'stretch';
            app.Image.ImageClickedFcn = createCallbackFcn(app, @ImageClicked, true);
            app.Image.Position = [1 -1 42 44];
            app.Image.ImageSource = 'image_1.png';

            % Create HistogramTab
            app.HistogramTab = uitab(app.TabGroup);
            app.HistogramTab.Title = 'Histogram';

            % Create UIAxes_histogram
            app.UIAxes_histogram = uiaxes(app.HistogramTab);
            xlabel(app.UIAxes_histogram, 'attribute')
            ylabel(app.UIAxes_histogram, 'count')
            zlabel(app.UIAxes_histogram, 'Z')
            app.UIAxes_histogram.Position = [1 84 643 562];

            % Create reverseFilterButton
            app.reverseFilterButton = uibutton(app.HistogramTab, 'push');
            app.reverseFilterButton.ButtonPushedFcn = createCallbackFcn(app, @reverseFilterButtonPushed, true);
            app.reverseFilterButton.Position = [400 11 100 23];
            app.reverseFilterButton.Text = 'reverse';

            % Create minSpinnerLabel
            app.minSpinnerLabel = uilabel(app.HistogramTab);
            app.minSpinnerLabel.HorizontalAlignment = 'right';
            app.minSpinnerLabel.Position = [46 53 26 22];
            app.minSpinnerLabel.Text = 'min';

            % Create binsizeSpinnerLabel
            app.binsizeSpinnerLabel = uilabel(app.HistogramTab);
            app.binsizeSpinnerLabel.HorizontalAlignment = 'right';
            app.binsizeSpinnerLabel.Position = [238 53 47 22];
            app.binsizeSpinnerLabel.Text = 'bin size';

            % Create binsizeSpinner
            app.binsizeSpinner = uispinner(app.HistogramTab);
            app.binsizeSpinner.ValueChangingFcn = createCallbackFcn(app, @binsizeSpinnerValueChanging, true);
            app.binsizeSpinner.ValueChangedFcn = createCallbackFcn(app, @binsizeSpinnerValueChanged, true);
            app.binsizeSpinner.Position = [300 53 100 22];

            % Create maxSpinnerLabel
            app.maxSpinnerLabel = uilabel(app.HistogramTab);
            app.maxSpinnerLabel.HorizontalAlignment = 'right';
            app.maxSpinnerLabel.Position = [444 53 28 22];
            app.maxSpinnerLabel.Text = 'max';

            % Create maxSpinner
            app.maxSpinner = uispinner(app.HistogramTab);
            app.maxSpinner.ValueChangingFcn = createCallbackFcn(app, @maxSpinnerValueChanging, true);
            app.maxSpinner.Position = [487 53 100 22];

            % Create minSpinner
            app.minSpinner = uispinner(app.HistogramTab);
            app.minSpinner.ValueChangingFcn = createCallbackFcn(app, @minSpinnerValueChanging, true);
            app.minSpinner.Position = [87 53 100 22];

            % Create plotVarDropDown
            app.plotVarDropDown = uidropdown(app.HistogramTab);
            app.plotVarDropDown.Items = {'per loc', 'trace mean', 'trace stdev', 'trace median', 'trace mode', 'trace max', 'trace min', 'trace range'};
            app.plotVarDropDown.ValueChangedFcn = createCallbackFcn(app, @plotVarDropDownValueChanged, true);
            app.plotVarDropDown.Position = [291 11 100 22];
            app.plotVarDropDown.Value = 'per loc';

            % Create attributeLabel
            app.attributeLabel = uilabel(app.HistogramTab);
            app.attributeLabel.HorizontalAlignment = 'right';
            app.attributeLabel.Position = [45 10 49 22];
            app.attributeLabel.Text = 'attribute';

            % Create histAttributeDropDown_4
            app.histAttributeDropDown_4 = uidropdown(app.HistogramTab);
            app.histAttributeDropDown_4.Items = {};
            app.histAttributeDropDown_4.ValueChangedFcn = createCallbackFcn(app, @histAttributeDropDown_4ValueChanged, true);
            app.histAttributeDropDown_4.Position = [109 10 100 22];
            app.histAttributeDropDown_4.Value = {};

            % Create valueasDropDownLabel
            app.valueasDropDownLabel = uilabel(app.HistogramTab);
            app.valueasDropDownLabel.HorizontalAlignment = 'right';
            app.valueasDropDownLabel.Position = [225 11 51 22];
            app.valueasDropDownLabel.Text = 'value as';

            % Create addtofilterlistButton
            app.addtofilterlistButton = uibutton(app.HistogramTab, 'push');
            app.addtofilterlistButton.ButtonPushedFcn = createCallbackFcn(app, @addtofilterlistButtonPushed, true);
            app.addtofilterlistButton.Position = [514 11 100 23];
            app.addtofilterlistButton.Text = 'add to filter list';

            % Create TraceViewTab
            app.TraceViewTab = uitab(app.TabGroup);
            app.TraceViewTab.Title = 'Trace View';

            % Create Image2
            app.Image2 = uiimage(app.TraceViewTab);
            app.Image2.ScaleMethod = 'stretch';
            app.Image2.ImageClickedFcn = createCallbackFcn(app, @Image2Clicked, true);
            app.Image2.Position = [395 387 230 235];
            app.Image2.ImageSource = 'image_2.png';

            % Show the figure after all components are created
            app.UIFigureMain.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MINFLUX_data_plot

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigureMain)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigureMain)
        end
    end
end