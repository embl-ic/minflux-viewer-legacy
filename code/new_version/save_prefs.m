function save_prefs (Prefs)
    
    try
        

        setpref('mfx_viewer', 'RIMF', Prefs.RIMF);                                   % numeric : z scaling factor

        %setpref('mfx_viewer', 'compute_RIMF', Prefs.on_data_load.compute_RIMF);                % boolean : whether to compute RIMF when data is loaded
        setpref('mfx_viewer', 'load_iter', Prefs.on_data_load.iter);               % string  : 'all', 'last'
        setpref('mfx_viewer', 'load_attr', Prefs.on_data_load.plot_attr);            % boolean : whether create attribute plot when data loaded
        setpref('mfx_viewer', 'load_scatter', Prefs.on_data_load.plot_scatter);     % boolean : whether create scatter plot when data loaded
        setpref('mfx_viewer', 'load_histogram', Prefs.on_data_load.plot_hist);      % boolean : whether create histogram plot when data loaded
        setpref('mfx_viewer', 'load_render', Prefs.on_data_load.render_image);      % boolean : whether create render image when data loaded
        
        
        %setpref('mfx_viewer', 'default_folder', Prefs.default_folder);                 % string  : default folder when open UI get file or folder

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