function report_memory (app)
    
    %mem_available_mb = memory().MaxPossibleArrayBytes / (1024^2);
    mem_used_mb = memory().MemUsedMATLAB / (1024^2);

    disp("memory used: " + mem_used_mb + " MB.");
    %disp("memory avilable: " + mem_available_mb + " MB.");

end