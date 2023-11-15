classdef MINFLUX_data_plot_trace_viewer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        Panel_scatter       matlab.ui.container.Panel
        headaverageLabel    matlab.ui.control.Label
        headRangeSpinner    matlab.ui.control.Spinner
        tailsizeLabel       matlab.ui.control.Label
        tailRangeSpinner    matlab.ui.control.Spinner
        ax_scatter          matlab.ui.control.UIAxes
        Panel_timePlot      matlab.ui.container.Panel
        playButton          matlab.ui.control.StateButton
        timeSlider          matlab.ui.control.Slider
        ax_eco              matlab.ui.control.UIAxes
        ax_efo              matlab.ui.control.UIAxes
        ax_v                matlab.ui.control.UIAxes
        ax_dt               matlab.ui.control.UIAxes
        Panel_table         matlab.ui.container.Panel
        ExportButton        matlab.ui.control.Button
        removetailCheckBox  matlab.ui.control.CheckBox
        OverlayButton       matlab.ui.control.Button
        TileViewButton      matlab.ui.control.Button
        tidLabel            matlab.ui.control.Label
        tidDropDown         matlab.ui.control.DropDown
        UITable             matlab.ui.control.Table
    end


    properties (Access = private) 
        CallingApp   % Main app object
        
        data
        xyz

        tid
        trace_ID
        trace_length
        trace_cfr
        trace_efo
        trace_dcr
        trace_dt
        trace_V
        trace_S
        trace_size
        trace_ch1
        trace_ch2
        
        dataTable
        dataTableHeader
        dataTableSelectedRow
        
        selected_trace
        tim_trace
        xyz_trace
        
        scatterPlot
        plot_dt
        plot_v
        plot_eco
        plot_efo
        
        vis_pos
        vis_rng
        head_size
        highlight_trace
        highlight_head
        bar_dt
        bar_v
        bar_eco
        bar_efo
        
    end
    
    methods (Access = private)
        
        function initData (app)
            app.data = getData(app.CallingApp);    % load main app data
            app.xyz = 1e9 * getLoc(app.CallingApp);      % load localization (after Z correction)
            
            app.tid = app.data.tid;
            
            initData2(app);
             
        end
        
        function initData2 (app)
            app.trace_ID = unique(app.tid);
            app.trace_ID(app.trace_ID==0) = [];
            app.trace_length = arrayfun(@(x) sum(app.tid==x), app.trace_ID);
            singleLoc = app.trace_length==1;
            
            %app.trace_cfr = arrayfun(@(x) mean(app.data.cfr(tid==x,:)), app.trace_ID);
            app.trace_efo = arrayfun(@(x) mean(app.data.efo(app.tid==x,:)), app.trace_ID);
            app.trace_dcr = arrayfun(@(x) mean(app.data.dcr(app.tid==x,:)), app.trace_ID);
            

            ch1_exist = false;
            if isfield(app.data, 'conf_ch1')
                app.trace_ch1 = arrayfun(@(x) mean(app.data.conf_ch1(app.tid==x,:)), app.trace_ID);
                ch1_exist = true;
            end
            
            ch2_exist = false;
            if isfield(app.data, 'conf_ch2')
                app.trace_ch2 = arrayfun(@(x) mean(app.data.conf_ch2(app.tid==x,:)), app.trace_ID);
                ch2_exist = true;
            end

            app.trace_dt = arrayfun(@(x) 1e3* mean(app.data.dt(app.tid==x)), app.trace_ID);
            app.trace_V = arrayfun(@(x) 1e6* nanmean(app.data.spd(app.tid==x)), app.trace_ID); %#ok<NANMEAN> 
            %app.trace_S = arrayfun(@(x) 1e6* sum(app.data.dst(tid==x)), app.trace_ID);
            app.trace_size = arrayfun(@(x) vecnorm(range(app.xyz(app.tid==x,:))), app.trace_ID);
            
            app.trace_dt(singleLoc) = NaN;
            app.trace_size(singleLoc) = 0;
            
            if ch1_exist && ch2_exist
                app.dataTable = table(app.trace_ID, app.trace_length, ...
                app.trace_efo, app.trace_ch1, app.trace_ch2, app.trace_dcr, ...
                app.trace_dt, app.trace_V, app.trace_size);
                app.dataTableHeader = {'trace ID', 'N loc', 'efo', 'ch1', 'ch2', 'dcr', 'dt (ms)', 'velocity (um/s)', 'size (nm)'};
            elseif ch1_exist
                app.dataTable = table(app.trace_ID, app.trace_length, ...
                app.trace_efo, app.trace_ch1, app.trace_dcr, ...
                app.trace_dt, app.trace_V, app.trace_size);
                app.dataTableHeader = {'trace ID', 'N loc', 'efo', 'ch1', 'dcr', 'dt (ms)', 'velocity (um/s)', 'size (nm)'};
            elseif ch2_exist
                app.dataTable = table(app.trace_ID, app.trace_length, ...
                app.trace_efo, app.trace_ch2, app.trace_dcr, ...
                app.trace_dt, app.trace_V, app.trace_size);
                app.dataTableHeader = {'trace ID', 'N loc', 'efo', 'ch2', 'dcr', 'dt (ms)', 'velocity (um/s)', 'size (nm)'};
            else
                app.dataTable = table(app.trace_ID, app.trace_length, ...
                app.trace_efo, app.trace_dcr, ...
                app.trace_dt, app.trace_V, app.trace_size);
                app.dataTableHeader = {'trace ID', 'N loc', 'efo', 'dcr', 'dt (ms)', 'velocity (um/s)', 'size (nm)'};
            end
            %app.dataTableHeader = {'trace ID', 'N loc', 'cfr', 'efo', 'dcr', 'dt (ms)', 'velocity (um/s)', 'travel length (um)', 'size (nm)'};
            %app.dataTableHeader = {'trace ID', 'N loc', 'efo', 'ch1', 'ch2', 'dcr', 'dt (ms)', 'velocity (um/s)', 'size (nm)'};
            app.dataTable = sortrows(app.dataTable, 2, 'descend');
        end
        
        function initUI (app)
            if isempty(app.data)
                return;
            end

            app.tidDropDown.Items = arrayfun(@(x) num2str(x), app.trace_ID, 'UniformOutput', false);
            selectedCell = app.dataTable(1, 1);
            app.selected_trace = selectedCell.Variables;
            app.tidDropDown.Value = num2str(app.selected_trace);
            idx_selected = app.tid==app.selected_trace;
            app.tim_trace = app.data.tim(idx_selected);
            app.tim_trace = app.tim_trace - app.tim_trace(1);
            app.timeSlider.Limits = [1, numel(app.tim_trace)];
            
            app.xyz_trace = app.xyz(idx_selected, :);
            app.xyz_trace = app.xyz_trace - mean(app.xyz_trace);
            
            % remove the 1st data point for time plots
            idx_selected(find(idx_selected, 1)) = 0;
            cla(app.ax_scatter); cla(app.ax_dt); cla(app.ax_v); cla(app.ax_eco); cla(app.ax_efo);
            app.scatterPlot = scatter3(app.ax_scatter, app.xyz_trace(:, 1), app.xyz_trace(:, 2), app.xyz_trace(:, 3), '.');
            app.ax_scatter.Title.String = strcat('tid: ', num2str(app.selected_trace));
            view(app.ax_scatter, 2);
            axis(app.ax_scatter, 'equal');
            
            app.plot_dt = plot(app.ax_dt, app.tim_trace(2:end), 1e3*app.data.dt(idx_selected), '.');
            
            velocity_rms = sqrt( movmean(app.data.spd(idx_selected).^2, 10) );
            app.plot_v = plot(app.ax_v, app.tim_trace(2:end), 1e6*velocity_rms);
            app.plot_eco = plot(app.ax_eco, app.tim_trace(2:end), app.data.eco(idx_selected));
            app.plot_efo = plot(app.ax_efo, app.tim_trace(2:end), app.data.efo(idx_selected));
            
            
            %axis(app.ax_dt, 'auto x');
            ytickformat([app.ax_dt, app.ax_v, app.ax_eco, app.ax_efo], '#%5.1g');
            %app.ax_dt.PositionConstraint = "innerposition";
            %app.ax_v.PositionConstraint = "innerposition";
            %app.ax_efo.PositionConstraint = "innerposition";
            %linkprop([app.ax_dt, app.ax_v, app.ax_efo, app.timeSlider], 'InnerPosition');
            linkaxes([app.ax_dt, app.ax_v, app.ax_eco, app.ax_efo, app.timeSlider], 'x');
            
            
            app.vis_pos = 1;
            app.vis_rng = 0;
            
            
            set(app.ax_scatter, 'NextPlot', 'add');
            app.highlight_trace = plot3(app.ax_scatter, app.xyz_trace(1,1), app.xyz_trace(1,2), app.xyz_trace(1,3), '-m');
            app.highlight_head = plot3(app.ax_scatter, app.xyz_trace(1,1), app.xyz_trace(1,2), app.xyz_trace(1,3), '-pentagram');
            app.highlight_trace.LineWidth = 2;
            app.highlight_head.MarkerSize = 12;
            app.highlight_head.MarkerFaceColor = 'y';
            app.highlight_trace.Visible = 'off';
            app.highlight_head.Visible = 'off';
            %set(app.ax_scatter, 'NextPlot', 'replaceChildren');
            
            set(app.ax_dt, 'NextPlot', 'add');
            set(app.ax_v, 'NextPlot', 'add');
            set(app.ax_eco, 'NextPlot', 'add');
            set(app.ax_efo, 'NextPlot', 'add');
            app.bar_dt = bar(app.ax_dt, 0, app.ax_dt.YLim(2), 'BarWidth', 0, 'FaceColor', 'm', 'FaceAlpha', .6, 'EdgeColor', 'none');
            app.bar_dt.Visible = 'off';
            app.bar_v = bar(app.ax_v, 0, app.ax_v.YLim(2), 'BarWidth', 0, 'FaceColor', 'm', 'FaceAlpha', .6, 'EdgeColor', 'none');
            app.bar_v.Visible = 'off';
            app.bar_eco = bar(app.ax_eco, 0, app.ax_eco.YLim(2), 'BarWidth', 0, 'FaceColor', 'm', 'FaceAlpha', .6, 'EdgeColor', 'none');
            app.bar_eco.Visible = 'off';
            app.bar_efo = bar(app.ax_efo, 0, app.ax_efo.YLim(2), 'BarWidth', 0, 'FaceColor', 'm', 'FaceAlpha', .6, 'EdgeColor', 'none');
            app.bar_efo.Visible = 'off';
            set(app.ax_dt, 'NextPlot', 'replaceChildren');
            set(app.ax_v, 'NextPlot', 'replaceChildren');
            set(app.ax_eco, 'NextPlot', 'replaceChildren');
            set(app.ax_efo, 'NextPlot', 'replaceChildren');
            % populate table
            app.UITable.Data = table2cell(app.dataTable);
            app.UITable.ColumnName = app.dataTableHeader;
            app.UITable.ColumnFormat = {[], [], [], 'bank', 'bank', 'bank', 'bank'};
            app.UITable.ColumnSortable = true;
            app.UITable.RowName = 'numbered';
            app.UITable.SelectionType = 'row';
        end
        
        function plotSelectedTrace (app)
            idx_selected = app.tid==app.selected_trace;
            app.tim_trace = app.data.tim(idx_selected);
            app.tim_trace = app.tim_trace - app.tim_trace(1);
            app.xyz_trace = app.xyz(idx_selected, :);
            app.xyz_trace = app.xyz_trace - mean(app.xyz_trace);
            % update scatter plot
            app.ax_scatter.Title.String = strcat('tid: ', num2str(app.selected_trace));
            app.scatterPlot.XData = app.xyz_trace(:, 1);
            app.scatterPlot.YData = app.xyz_trace(:, 2);
            app.scatterPlot.ZData = app.xyz_trace(:, 3);            
            % update dt, V, S plot
            if sum(idx_selected) <= 1 % not enough data point
                app.plot_dt.XData = 0;
                app.plot_dt.YData = 0;
                app.plot_v.XData = 0;
                app.plot_v.YData = 0;
                app.plot_eco.XData = 0;
                app.plot_eco.YData = 0;
                app.plot_efo.XData = 0;
                app.plot_efo.YData = 0;
                app.ax_efo.XLim = [0, 1e-3];
                app.timeSlider.Limits = [1, 1];
            else
                idx_selected(find(idx_selected, 1)) = 0;
                app.plot_dt.XData = app.tim_trace(2:end);
                app.plot_dt.YData = 1e3 * app.data.dt(idx_selected);
                app.plot_v.XData = app.tim_trace(2:end);
                app.plot_v.YData = 1e6 * sqrt( movmean(app.data.spd(idx_selected).^2, 10) );
                app.plot_eco.XData = app.tim_trace(2:end);
                app.plot_eco.YData = app.data.eco(idx_selected);
                app.plot_efo.XData = app.tim_trace(2:end);
                app.plot_efo.YData = app.data.efo(idx_selected);
                app.ax_efo.XLim = [0, max(app.tim_trace)];
                app.timeSlider.Limits = [1, numel(app.tim_trace)];
            end
            % update highlighted item
            app.timeSlider.Value = 1;
            app.highlight_trace.Visible = 'off';
            app.highlight_head.Visible = 'off';
            app.bar_dt.Visible = 'off';
            app.bar_v.Visible = 'off';
            app.bar_eco.Visible = 'off';
            app.bar_efo.Visible = 'off';
            app.highlight_head.XData = 0;
            app.highlight_head.YData = 0;
            app.highlight_head.ZData = 0;
            app.bar_dt.XData = 1e-3; app.bar_dt.YData = app.ax_dt.YLim(2); app.bar_dt.BaseValue = app.ax_dt.YLim(1); app.bar_dt.BarWidth = 0;
            app.bar_v.XData = 1e-3; app.bar_v.YData = app.ax_v.YLim(2); app.bar_v.BaseValue = app.ax_v.YLim(1); app.bar_v.BarWidth = 0;
            app.bar_eco.XData = 1e-3; app.bar_eco.YData = app.ax_eco.YLim(2); app.bar_eco.BaseValue = app.ax_eco.YLim(1); app.bar_eco.BarWidth = 0;
            app.bar_efo.XData = 1e-3; app.bar_efo.YData = app.ax_efo.YLim(2); app.bar_efo.BaseValue = app.ax_efo.YLim(1); app.bar_efo.BarWidth = 0;
  
        end
        
        function plotTraceOveray (app, indices)
            %cla(app.ax_scatter);
            %set(app.ax_scatter, 'NextPlot', 'add');
            figure; hold on;
            for i = 1 : numel(indices)
                idx_selected = app.tid==indices(i);
                cor = app.xyz(idx_selected, :);
                cor = cor - mean(cor);
                sc = scatter3(cor(:, 1), cor(:, 2), cor(:, 3), '.');
                sc.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow("tid",  num2cell(app.tid(idx_selected)));
            end
            xlabel('X (nm)'); ylabel('Y (nm)'); zlabel('Z (nm)');
            hold off;
            %view(2);
            axis equal;
        end
        
        function frameUpdate (app)

            pos = round(app.vis_pos); % integer [1 100] denote slider position
            rng = app.vis_rng; % integer of number of frames
            t = app.tim_trace;
            
            if rng == 0 || numel(t) <= 1 % delete head and track
                app.highlight_trace.Visible = 'off';
                app.highlight_head.Visible = 'off';
                app.bar_dt.Visible = 'off';
                app.bar_v.Visible = 'off';
                app.bar_eco.Visible = 'off';
                app.bar_efo.Visible = 'off';
                return;
            else
                app.highlight_trace.Visible = 'on';
                app.highlight_head.Visible = 'on';
                app.bar_dt.Visible = 'on';
                app.bar_v.Visible = 'on';
                app.bar_eco.Visible = 'on';
                app.bar_efo.Visible = 'on';
            end

            
            rng_t = range(t) / (numel(t)-1) * rng;
            pos_t = range(t) / (numel(t)-1) * pos;
            
            head_begin = max(1, pos-app.head_size);
            head_end = min(numel(t), pos+app.head_size);
            
            % update head position in scatter plot
            app.highlight_head.XData = mean(app.xyz_trace(head_begin:head_end, 1));
            app.highlight_head.YData = mean(app.xyz_trace(head_begin:head_end, 2));
            app.highlight_head.ZData = mean(app.xyz_trace(head_begin:head_end, 3));



            % update track range
            pos_left = max(1, pos - rng);
            % update scatter plot curve
            points = fnplt( cscvn( app.xyz_trace(pos_left:pos, :)' ) );
            app.highlight_trace.XData = points(1, :);
            app.highlight_trace.YData = points(2, :);
            app.highlight_trace.ZData = points(3, :);
            
            
            [box_mid, box_width] = convertBox(app, pos_t, rng_t);
            % update displacement, velocity, and time interval plot bar
            app.bar_dt.XData = box_mid; app.bar_dt.BarWidth = box_width; %app.bar_dt.YData = app.ax_dt.YLim(2); 
            app.bar_v.XData = box_mid; app.bar_v.BarWidth = box_width; %app.bar_v.YData = app.ax_v.YLim(2); 
            app.bar_eco.XData = box_mid; app.bar_eco.BarWidth = box_width; %app.bar_v.YData = app.ax_v.YLim(2); 
            app.bar_efo.XData = box_mid; app.bar_efo.BarWidth = box_width; %app.bar_s.YData = app.ax_efo.YLim(2); 
            
        end
        
        function [mid, width] = convertBox (~, pos, rng)
            width = rng;
            mid = pos - 0.5 * rng;
            if pos-rng < 0
                width = pos;
                mid = 0.5 * width;
            end   
        end
        
        function tid = removeTraceTail (app)
            tid = [];
            if isempty(app.data)
                return;
            end
%             if isempty(app.tid) || isempty(app.trace_V)
%                 initData(app);
%                 initData2(app);
%             end
            tid = app.tid;
            for i = 1 : numel(app.trace_ID)
                idx_selected = tid==app.trace_ID(i);
                first_idx = find(idx_selected, 1);
                V_RMS = 1e6 * sqrt( movmean(app.data.spd(idx_selected).^2, 10) );
                % first cut based on velocity
                first_cut = find(diff(V_RMS)>0, 1);
                if isempty(first_cut) 
                    first_cut = 0; 
                end
                % second cut based on global distance to neighbours
                loc = app.xyz(idx_selected, :);
                D = mean(pdist2(loc, loc));
                second_cut = find(D(first_cut+1:end)<20, 1);
                if isempty(second_cut)
                    second_cut = 0;
                end
                % remove tid for data inside cut range
                final_cut = first_cut + second_cut;
                if final_cut == 0
                    continue;
                end
                tid(first_idx : first_idx + final_cut-1) = 0;
            end
        end

        function exportTraceData (app, indices)
            if isempty(indices)
                return;
            end
            trace_data = struct();
            for i = 1 : numel(indices)
                % trace ID, loc, tim, efo, eco, dcr, ch1, ch2
                trace_data(i).tid = indices(i);
                idx = app.tid == trace_data(i).tid;
                trace_data(i).loc = 1e-9 * app.xyz(idx, :);
                trace_data(i).tim = app.data.tim(idx, :);
                trace_data(i).efo = app.data.efo(idx, :);
                trace_data(i).eco = app.data.eco(idx, :);
                trace_data(i).dcr = app.data.dcr(idx, :);
                if isfield(app.data, 'conf_ch1')
                    trace_data(i).conf_ch1 = app.data.conf_ch1(idx, :);
                end
                if isfield(app.data, 'conf_ch2')
                    trace_data(i).conf_ch2 = app.data.conf_ch2(idx, :);
                end
            end
            assignin('base', 'exported_trace_data', trace_data);
        end

    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function StartupFcn(app, mainapp)
            % Store main app in property for CloseRequestFcn to use
            app.CallingApp = mainapp;
            app.CallingApp.Image2.Enable = 'off';
            initData (app);
            initUI (app);
            
            % Update UI with input values
 
        end

        % Value changed function: tidDropDown
        function tidDropDownValueChanged(app, event)
            app.selected_trace = str2double(app.tidDropDown.Value);
            plotSelectedTrace (app);
        end

        % Value changing function: timeSlider
        function timeSliderValueChanging(app, event)
            app.vis_pos = event.Value;
            app.head_size = app.headRangeSpinner.Value;
            if app.vis_rng == 0
                app.vis_rng = 10;
                app.tailRangeSpinner.Value = 10;
            end
            frameUpdate(app);
        end

        % Value changed function: playButton
        function playButtonValueChanged(app, event)
            if app.timeSlider.Value == app.timeSlider.Limits(2)
                app.playButton.Value = 0;
                app.playButton.Text = "▷";
                return;
            end

            if app.playButton.Value
                app.playButton.Text = "▶";
                app.head_size = app.headRangeSpinner.Value;
                if app.vis_rng == 0
                    app.vis_rng = 10;
                    app.tailRangeSpinner.Value = 10;
                end
            else
                app.playButton.Text = "▷";
            end
            
            %maxCount = 1e3; count = 0;
            while app.playButton.Value <= app.timeSlider.Limits(2) % auto-play the time slider to the right
                if ~app.playButton.Value %|| count>maxCount
                    break;
                end
                app.vis_pos = app.timeSlider.Value + 1;
                app.timeSlider.Value = app.vis_pos;
                frameUpdate(app);
                drawnow;
                %count = count + 1;
            end
        end

        % Value changing function: headRangeSpinner
        function headRangeSpinnerValueChanging(app, event)
            app.head_size = event.Value;
            frameUpdate(app);
        end

        % Value changing function: tailRangeSpinner
        function tailRangeSpinnerValueChanging(app, event)
            app.vis_rng = event.Value;
            app.head_size = app.headRangeSpinner.Value;
            frameUpdate(app);
        end

        % Cell selection callback: UITable
        function UITableCellSelection(app, event)
            app.dataTableSelectedRow = unique(event.DisplayIndices(:, 1));
            % added function to update plotted trace with each table
            % selection change
            %selectedCell = app.UITable.Data{app.dataTableSelectedRow(1), 1};
            app.selected_trace = app.UITable.DisplayData{app.dataTableSelectedRow(1), 1};
            app.tidDropDown.Value = num2str(app.selected_trace);
            plotSelectedTrace(app);
        end

        % Button pushed function: TileViewButton
        function TileViewButtonPushed(app, event)
            
            prompt = {'Show trace:', 'Layout (Row x Column):'};
            dlgtitle = 'Tile Layout';
            fieldsize = [1 45; 1 45];
            definput = {'1-20','4x5'};
            answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
            if isempty(answer)
                return;
            end
            
            trace_idx_selected = answer{1};
            layout = answer{2};
            
            trace_idx_begin = str2double(extractBefore(trace_idx_selected, "-"));
            trace_idx_end = str2double(extractAfter(trace_idx_selected, "-"));
            nRow = str2double(extractBefore(layout, "x"));
            nCol = str2double(extractAfter(layout, "x"));
            
            % control subplot number and layout
            trace_begin = max(trace_idx_begin, 1);
            trace_end = min(trace_idx_end, size(app.UITable.DisplayData, 1));
            nPlot = trace_end - trace_begin + 1;
            if nRow * nCol < nPlot
                nRow = ceil(nPlot/nCol);
            end
            
            hFig = figure('Name', 'Trace Tile View', 'position',[25, 25, nCol*200, nRow*200]);
            set(0,'CurrentFigure', hFig);
            %set(hFig, 'ButtonDownFcn',@(~,~)disp('figure'),'HitTest','off');
            
            idx_plot = 1;
            for i = trace_begin : trace_end
                ax = subplot(nRow, nCol, idx_plot); idx_plot = idx_plot + 1;
                trace_to_plot = app.UITable.DisplayData{i, 1};
                idx_selected = app.tid==trace_to_plot;
                loc = app.xyz(idx_selected, :);
                loc = loc - mean(loc);
                p = plot(ax, loc(:,1), loc(:,2), '.');
                set(p, 'hittest', 'off');
                title(ax, strcat('tid: ', num2str(trace_to_plot))); 
                %axis(ax, 'tight');
                axis(ax, 'equal');
                set(ax,'ButtonDownFcn', {@btnDownFcn, app});
                %set(ax,'ButtonDownFcn', 'disp(ax.Title.String)', 'HitTest','on');
            end
            function btnDownFcn(src, ~, app)
                app.tidDropDown.Value = extractAfter(src.Title.String, 'tid:');
                app.selected_trace = str2double(app.tidDropDown.Value);
                plotSelectedTrace(app);
            end
            
        end

        % Button pushed function: OverlayButton
        function OverlayButtonPushed(app, event)
            if numel(app.dataTableSelectedRow) <= 1
                return;
            end
            overlay_traces = cell2mat(app.UITable.DisplayData(app.dataTableSelectedRow, 1));
            plotTraceOveray(app, overlay_traces);
        end

        % Close request function: UIFigure
        function DialogAppCloseRequest(app, event)
            % Enable the Plot Opions button in main app
            %app.CallingApp.OptionsButton.Enable = 'on';
            app.CallingApp.Image2.Enable = 'on';
            % Delete the dialog box 
            delete(app)
            
        end

        % Value changed function: removetailCheckBox
        function removetailCheckBoxValueChanged(app, event)
            if app.removetailCheckBox.Value % remove the tail of each trace
                app.tid = removeTraceTail(app);
            else
                app.tid = app.data.tid;
            end
            initData2(app);
            app.UITable.Data = table2cell(app.dataTable);
            plotSelectedTrace(app);
        end

        % Button pushed function: ExportButton
        function ExportButtonPushed(app, event)
            trace_ID_export = []; %#ok<NASGU> 
            if numel(app.dataTableSelectedRow) <= 1
                trace_ID_export = cell2mat(app.UITable.DisplayData(:, 1));
            else
                trace_ID_export = cell2mat(app.UITable.DisplayData(app.dataTableSelectedRow, 1));
            end
            % save trace data
            exportTraceData(app, trace_ID_export);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [600 100 892 840];
            app.UIFigure.Name = 'Trace Viewer';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @DialogAppCloseRequest, true);

            % Create Panel_table
            app.Panel_table = uipanel(app.UIFigure);
            app.Panel_table.Position = [9 15 872 244];

            % Create UITable
            app.UITable = uitable(app.Panel_table);
            app.UITable.ColumnName = {'trace ID'; 'N loc'; 'efo'; 'dcr'; 'dt (ms)'; 'velocity (um/s)'; 'travel length (um)'; 'size (um)'};
            app.UITable.RowName = {};
            app.UITable.CellSelectionCallback = createCallbackFcn(app, @UITableCellSelection, true);
            app.UITable.Position = [119 9 752 236];

            % Create tidDropDown
            app.tidDropDown = uidropdown(app.Panel_table);
            app.tidDropDown.Items = {};
            app.tidDropDown.ValueChangedFcn = createCallbackFcn(app, @tidDropDownValueChanged, true);
            app.tidDropDown.FontWeight = 'bold';
            app.tidDropDown.Position = [9 192 100 24];
            app.tidDropDown.Value = {};

            % Create tidLabel
            app.tidLabel = uilabel(app.Panel_table);
            app.tidLabel.HorizontalAlignment = 'center';
            app.tidLabel.FontWeight = 'bold';
            app.tidLabel.Position = [12 217 92 22];
            app.tidLabel.Text = 'tid';

            % Create TileViewButton
            app.TileViewButton = uibutton(app.Panel_table, 'push');
            app.TileViewButton.ButtonPushedFcn = createCallbackFcn(app, @TileViewButtonPushed, true);
            app.TileViewButton.Position = [9 149 102 25];
            app.TileViewButton.Text = 'Tile View';

            % Create OverlayButton
            app.OverlayButton = uibutton(app.Panel_table, 'push');
            app.OverlayButton.ButtonPushedFcn = createCallbackFcn(app, @OverlayButtonPushed, true);
            app.OverlayButton.Position = [9 108 102 25];
            app.OverlayButton.Text = 'Overlay';

            % Create removetailCheckBox
            app.removetailCheckBox = uicheckbox(app.Panel_table);
            app.removetailCheckBox.ValueChangedFcn = createCallbackFcn(app, @removetailCheckBoxValueChanged, true);
            app.removetailCheckBox.Text = 'remove tail';
            app.removetailCheckBox.Position = [13 69 82 22];

            % Create ExportButton
            app.ExportButton = uibutton(app.Panel_table, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.Position = [9 28 102 23];
            app.ExportButton.Text = 'Export';

            % Create Panel_timePlot
            app.Panel_timePlot = uipanel(app.UIFigure);
            app.Panel_timePlot.TitlePosition = 'centertop';
            app.Panel_timePlot.Position = [409 268 472 565];

            % Create ax_dt
            app.ax_dt = uiaxes(app.Panel_timePlot);
            ylabel(app.ax_dt, 'dt (ms)')
            zlabel(app.ax_dt, 'Z')
            app.ax_dt.FontWeight = 'bold';
            app.ax_dt.Position = [4 429 465 135];

            % Create ax_v
            app.ax_v = uiaxes(app.Panel_timePlot);
            ylabel(app.ax_v, 'V (um/s)')
            zlabel(app.ax_v, 'Z')
            app.ax_v.FontWeight = 'bold';
            app.ax_v.Position = [4 291 465 135];

            % Create ax_efo
            app.ax_efo = uiaxes(app.Panel_timePlot);
            xlabel(app.ax_efo, 't (second)')
            ylabel(app.ax_efo, 'efo')
            zlabel(app.ax_efo, 'Z')
            app.ax_efo.FontWeight = 'bold';
            app.ax_efo.Position = [4 28 465 135];

            % Create ax_eco
            app.ax_eco = uiaxes(app.Panel_timePlot);
            ylabel(app.ax_eco, 'eco')
            zlabel(app.ax_eco, 'Z')
            app.ax_eco.FontWeight = 'bold';
            app.ax_eco.Position = [4 151 465 135];

            % Create timeSlider
            app.timeSlider = uislider(app.Panel_timePlot);
            app.timeSlider.Limits = [1 100];
            app.timeSlider.MajorTicks = [];
            app.timeSlider.MajorTickLabels = {};
            app.timeSlider.ValueChangingFcn = createCallbackFcn(app, @timeSliderValueChanging, true);
            app.timeSlider.MinorTicks = [];
            app.timeSlider.Position = [46 9 418 3];
            app.timeSlider.Value = 1;

            % Create playButton
            app.playButton = uibutton(app.Panel_timePlot, 'state');
            app.playButton.ValueChangedFcn = createCallbackFcn(app, @playButtonValueChanged, true);
            app.playButton.IconAlignment = 'center';
            app.playButton.Text = '▷';
            app.playButton.Position = [9 4 20 20];

            % Create Panel_scatter
            app.Panel_scatter = uipanel(app.UIFigure);
            app.Panel_scatter.TitlePosition = 'centertop';
            app.Panel_scatter.Position = [9 272 393 561];

            % Create ax_scatter
            app.ax_scatter = uiaxes(app.Panel_scatter);
            title(app.ax_scatter, 'tid: ')
            xlabel(app.ax_scatter, 'X (nm)')
            ylabel(app.ax_scatter, 'Y (nm)')
            zlabel(app.ax_scatter, 'Z (nm)')
            app.ax_scatter.FontWeight = 'bold';
            app.ax_scatter.Position = [2 57 385 499];

            % Create tailRangeSpinner
            app.tailRangeSpinner = uispinner(app.Panel_scatter);
            app.tailRangeSpinner.ValueChangingFcn = createCallbackFcn(app, @tailRangeSpinnerValueChanging, true);
            app.tailRangeSpinner.Limits = [0 Inf];
            app.tailRangeSpinner.Position = [281 15 75 22];

            % Create tailsizeLabel
            app.tailsizeLabel = uilabel(app.Panel_scatter);
            app.tailsizeLabel.HorizontalAlignment = 'right';
            app.tailsizeLabel.Position = [231 15 46 22];
            app.tailsizeLabel.Text = 'tail size';

            % Create headRangeSpinner
            app.headRangeSpinner = uispinner(app.Panel_scatter);
            app.headRangeSpinner.ValueChangingFcn = createCallbackFcn(app, @headRangeSpinnerValueChanging, true);
            app.headRangeSpinner.Limits = [0 Inf];
            app.headRangeSpinner.Position = [136 15 75 22];
            app.headRangeSpinner.Value = 2;

            % Create headaverageLabel
            app.headaverageLabel = uilabel(app.Panel_scatter);
            app.headaverageLabel.HorizontalAlignment = 'right';
            app.headaverageLabel.Position = [42 18 89 22];
            app.headaverageLabel.Text = 'head average ±';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MINFLUX_data_plot_trace_viewer(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)StartupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end