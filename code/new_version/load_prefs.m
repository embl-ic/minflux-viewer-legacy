function Prefs = load_prefs ()
    % 
    % try
    %     %Prefs = getpref('mfx_viewer', 'Prefs');
    % 
    % 
    % catch Exception
    %     rethrow(Exception);
    % end
    
    RIMF_default = 0.67;

    compute_RIMF_default = false;

    load_iter_default = 'last';

    plot_attribute_on_load = true;
    
    plot_histogram_on_load = false;

    plot_scatter_on_load = false;

    render_image_on_load = false;

    base_folder_default = pwd;


    try
        Prefs.RIMF = getpref('mfx_viewer', 'RIMF', RIMF_default);                                   % numeric : z scaling factor

        on_data_load = struct;
        on_data_load.compute_RIMF = getpref('mfx_viewer', 'compute_RIMF', compute_RIMF_default);                % boolean : whether to compute RIMF when data is loaded
        on_data_load.iter = getpref('mfx_viewer', 'load_iter', load_iter_default);               % string  : 'all', 'last'
        on_data_load.plot_attr = getpref('mfx_viewer', 'load_attr', plot_attribute_on_load);            % boolean : whether create attribute plot when data loaded
        on_data_load.plot_scatter = getpref('mfx_viewer', 'load_scatter', plot_scatter_on_load);     % boolean : whether create scatter plot when data loaded
        on_data_load.plot_hist = getpref('mfx_viewer', 'load_histogram', plot_histogram_on_load);      % boolean : whether create histogram plot when data loaded
        on_data_load.render_image = getpref('mfx_viewer', 'load_render', render_image_on_load);      % boolean : whether create render image when data loaded

        Prefs.on_data_load = on_data_load;

        Prefs.default_folder = getpref('mfx_viewer', 'default_folder', base_folder_default);                 % string  : default folder when open UI get file or folder

    catch Exception

        % if (strcmp(Exception.identifier,'MATLAB:catenate:dimensionMismatch'))
        %     msg = ['Dimension mismatch occurred: First argument has ', ...
        %         num2str(size(A,2)),' columns while second has ', ...
        %         num2str(size(B,2)),' columns.'];
        %     causeException = MException('MATLAB:myCode:dimensions', msg);
        %     Exception = addCause(Exception,causeException);
        % end

        rethrow(Exception);

    end

end