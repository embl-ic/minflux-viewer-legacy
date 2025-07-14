function load_tif (app, file_name, folder)
    
    if isequal(file_name, 0) || isequal(folder, 0)
        return;
    end
    
    app.StatusTextArea.Value = "Loading TIF image...";

    path = fullfile(folder, file_name);

    imshow( imread(path, 1) ); 

    %info = tiffreadVolume(path);
    % Size_Tiff = size(info);
    % numberOfPages = Size_Tiff(4);
    % for k = 1 : numberOfPages
    %     thisPage = imread(filename, k);            
    %     imshow(imadjust(thisPage),'Parent', app.UIAxes);   %-show the kth image in this multipage tiff file
    % end  



end