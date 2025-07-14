function load_Prefs (app)


    try
        app.Prefs = getpref('mfx_viewer', 'Prefs', create_default_prefs());
    catch Exception
        rethrow(Exception);
    end


    function Prefs = create_default_prefs ()

        file = struct();
        file.num_file_history = 5;
        file.keep_last_folder = true;
        file.default_folder = pwd;
        file.recent_files = {};
        
        data = struct();
        data.iter_load = "last";
        data.load_efc_cfr = true;
        data.load_all_dcr = true;

        data.compute_rimf = false;
        data.compute_locPrec = false;
        data.compute_local_density = false;
        data.local_density_radius = 100;

        data.show_data_info = true;
        data.shw_attr_plot = true;
        data.show_scatter = false;
        data.show_histogram = false;
        data.show_render = false;

        plot = struct();
        plot.rimf_value = 0.67;
        plot.render_pixel_size = 2;
        plot.render_cmap = "Hot";
        plot.plot_cmap = "single color";
        plot.roi_color = "Yellow";

        Prefs = struct("file", file, "data", data, "plot", plot);

    end

end