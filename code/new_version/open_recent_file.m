function open_recent_file (src, ~, app)
    %app.StatusTextArea.Value = "Opening recent file: " + src.Text;
    parse_file_path (app, src.Text);
end