function report_memory (app)
    
    mem_available_mb = memory().MaxPossibleArrayBytes / (1024^2);
    mem_used_mb = memory().MemUsedMATLAB / (1024^2);
    mem_app_mb = get_obj_size(app) / (1024^2);
    
    disp("memory used by MINFLUX Viewer app: " + mem_app_mb + " MB.");
    disp("memory used by MATLAB total: " + mem_used_mb + " MB.");
    disp("memory avilable to MATLAB: " + mem_available_mb + " MB.");
    

    function size_obj = get_obj_size (obj) 
        props = properties(obj); 
        size_obj = 0; 
        for i = 1 : numel (props) 
            currentProperty = getfield(obj, char(props(i))); %#ok<NASGU,GFLD>
            s = whos('currentProperty'); 
            size_obj = size_obj + s.bytes; 
        end
    end

end