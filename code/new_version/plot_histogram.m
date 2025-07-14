function fig_histogram = plot_histogram (app)
    
    % get active data from app
    idx = get_active_data_index (app);
    if isempty(idx)
        return;
    end
    data = app.data{idx};
    
    % histogram input variable type: either per localization, or per trace:
    % for trace, the value could be: mean, stdDev, max, min, or range       % removed median and mode
    var_types = {'per loc', 'trace mean', 'trace stdev', 'trace max', 'trace min', 'trace range'};

    
    attr_names = data.prop.attr_names;
    attrs = data.attr;
    
    ftr = attrs.ftr;
    
    % update trace_ID, and trace_idx
    tid = data.attr.tid(ftr);
    [~, ia, ~] = unique(tid);
    trace_idx = [ia, [ ia(2:end)-1; length(tid) ] ];
    %num_loc_per_trace = data.prop.num_loc_per_trace;

    % histogram figure with UI componenets:
    % min value spinner; bin size spinner; max value spinner;
    % attribute dropdown, value as drop down; add to filter button
    % for Gaussian or similar distribution, bin size ≈ 2 * iqr(val) * N(unique val)^(-1/3)
    % the bin number is then range(val) / bin size
    % for uniform value or binary, bin number is 1 or 2, bin size is then
    % range(val) / bin number
    % min bin size is range(val) / N(unique val)
    % max bin size is range(val) / 2
    % bin step spinner is in logarithmic scale, roughly 100 values between
    % min and max:
    % log(min) : log(max/min)/100 : log(max)

    fig_name = strcat("Attribute Histogram : ", data.file.name);

    fig_histogram = findall(0, 'Type', 'figure', 'Name', fig_name);


    if isempty(fig_histogram)

        fig_histogram = uifigure('Name', fig_name, 'NumberTitle', 'off', 'Tag', "figure_histogram", 'DeleteFcn', {@close_child_figure, app});
        ax = axes (fig_histogram);

        val_hist = attrs.efo(ftr, :);

        hist_plot = histogram(ax, val_hist);
        
        xlim(ax, 'auto');
        ylim(ax, 'auto');
        xlabel(ax, 'efo : per loc', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel(ax, 'count', 'FontSize', 12, 'FontWeight', 'bold');
        hist_plot.BinMethod = 'auto';
        %ax.YLimMode = 'auto';
        ax.Position(2) = 0.2;
    
        attr_list = uidropdown( ...
                        'Parent', fig_histogram, 'Tag', "attr_list", ...
                        'Position' , [60 5 70 30], ...
                        'Fontsize' , 15, ...
                        'Items', attr_names, ...
                        'Value', 'efo', ...
                        'ValueChangedFcn', @hist_data_change);

        var_type = uidropdown( ...
                        'Parent', fig_histogram, 'Tag', "var_type", ...
                        'Position', [140 5 110 30], ...
                        'Fontsize', 15, ...
                        'Items', var_types, ...
                        'ValueChangedFcn', @hist_data_change);
         
                uilabel( ...
                        'Parent', fig_histogram, ...
                        'Position', [260 5 60 30], ...
                        'Fontsize', 15, ...
                        'Text', 'bin size');
        bin_size = uispinner( ...
                        'Parent', fig_histogram, ...
                        'Position', [320 5 90 30], ...
                        'Fontsize', 15, ...
                        'HorizontalAlignment', 'left', ... 
                        'Value', hist_plot.BinWidth, ...
                        'AllowEmpty', 'on', ...
                        'Step', sqrt(numel(val_hist))/10, ...
                        'ValueChangedFcn', @bin_size_change, ...
                        'ValueChangingFcn', @bin_size_change);
    
        remove_zero = uicheckbox( ...
                        'Parent', fig_histogram, ...
                        'Position', [420 5 80 30], ...
                        'Fontsize', 15, ...
                        'Text', 'remove 0', ...
                        'Value', 0, ...
                        'ValueChangedFcn', @remove_zero_value);



    else
        
        hist_plot = findobj(fig_histogram, 'Type', 'histogram');

        attr_list = findobj(fig_histogram, 'Type', 'uidropdown', 'Tag', 'attr_list');
        var_type = findobj(fig_histogram, 'Type', 'uidropdown', 'Tag', 'var_type');


        val_hist = get_hist_value(attrs.(attr_list.Value)(ftr, :), var_type.Value);
        hist_plot.Data = val_hist;
        hist_plot.BinMethod = 'auto';

    end


    function hist_data_change (~, ~)
        % update histogram data, plot, and reset bin size (automatic calculated)
        val_hist = get_hist_value(attrs.(attr_list.Value)(ftr, :), var_type.Value);
        hist_plot.Data = val_hist;
        hist_plot.BinMethod = 'auto';
        ax.XLabel.String = strcat(attr_list.Value, " : ", var_type.Value);

        filter_min = findobj(fig_histogram, 'Tag', 'filter_min');
        if ~isempty(filter_min)
            filter_min.Value = hist_plot.BinLimits(1);
        end
        filter_max = findobj(fig_histogram, 'Tag', 'filter_max');
        if ~isempty(filter_max)
            filter_max.Value = hist_plot.BinLimits(2);
        end

        
        remove_zero.Value = 0;
        % update bin size spinner limits, value, and step size
        rng_hist = range(val_hist);
        uni_hist = sort( unique(val_hist) );
        first_hist = double( val_hist(1) );

        if isnan(rng_hist)
            bin_size.Value = [];
            bin_size.Enable = 'off';
            remove_zero.Enable = 'off';
        elseif rng_hist == 0
            bin_size.Limits = [first_hist, first_hist];
            bin_size.Value = first_hist;
            bin_size.Enable = 'off';
            remove_zero.Enable = 'off';
        else
            try
                bin_size.Enable = 'on';
                remove_zero.Enable = 'on';
                increment = [diff( double(uni_hist) ); hist_plot.BinWidth/10];
                %increment(increment==0) = [];
                bin_size_min = min(increment, [], 'omitnan');
                if isnan(bin_size_min)
                    bin_size_min = rng_hist / numel( uni_hist );
                end
                bin_size_max = rng_hist / 2;
                bin_size.Limits = [double(bin_size_min), double(bin_size_max)];
                bin_size_init = 2 * iqr(double(val_hist), 'all') * numel( uni_hist )^(-1/3);
                if bin_size_init == 0
                    bin_size_init = double( hist_plot.BinWidth );
                end
                
                bin_size.Value = double( hist_plot.BinWidth );

                % !!! For very small values (e.g.: ext), MATLAB default BinMethod will ignore variance and treat as one uniform value
                % if hist_plot.BinWidth < bin_size_min || hist_plot.BinWidth > bin_size_max
                %     hist_plot.BinLimitsMode = 'manual';
                %     hist_plot.BinWidth = bin_size_init;
                % else
                %     bin_size.Value = double( hist_plot.BinWidth );
                % end
                
                bin_size.Step = bin_size_init / 10;
            catch Exception
                disp("default histogram bin method cannot catch small value flutation in attribute!");
                bin_size.Limits = [first_hist, first_hist];
                bin_size.Value = first_hist;
                bin_size.Enable = 'off';
                remove_zero.Enable = 'off';
            end

        end
    end
    

    function bin_size_change (src, evt)
        % change histogram bin size
        if evt.Value <= 0
            src.Value = evt.PreviousValue;
        else
            hist_plot.BinWidth = evt.Value;
        end
    end


    function remove_zero_value (~, evt)
        if evt.Value
            hist_plot.Data = val_hist(val_hist~=0);
        else
            val_hist = get_hist_value(attrs.(attr_list.Value), var_type.Value);
            hist_plot.Data = val_hist;
        end
    end


    function val = get_hist_value (attr_value, var_type)
            
        switch var_type
            case 'per loc'
                val = attr_value;

            case 'trace mean'
                val = arrayfun(@(id) mean( double(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :)), 1, 'omitnan'), (1:length(trace_idx))');

            case 'trace stdev'
                val = arrayfun(@(id) std( double(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :)), 1, 'omitnan'), (1:length(trace_idx))');

            %case 'trace median'
            %    val = arrayfun(@(id) median(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), 'omitnan'), (1:length(trace_idx))');

            %case 'trace mode'
            %    val = arrayfun(@(id) mode(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :)), (1:length(trace_idx))');

            case 'trace max'
                val = arrayfun(@(id) max(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), [], 'all', 'omitnan'), (1:length(trace_idx))');

            case 'trace min'
                val = arrayfun(@(id) min(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), [], 'all', 'omitnan'), (1:length(trace_idx))');

            case 'trace range'
                val = arrayfun(@(id) range(attr_value(trace_idx(id, 1) : trace_idx(id, 2), :), 'all'), (1:length(trace_idx))');

            otherwise
                val = attr_value;
        end
        
        if size(val, 1) == 1
            val = val';
        end

    end

end