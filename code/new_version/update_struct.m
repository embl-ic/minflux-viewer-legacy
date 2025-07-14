function struct_new = update_struct( struct_old, struct_input )
    
    struct_new = struct_old;
    fnames = fieldnames(struct_input);

    for i = 1 : length( fnames )

        if isstruct ( struct_input.(fnames{i}) ) && isfield(struct_new, fnames{i})
            struct_new.(fnames{i}) = update_struct( struct_new.(fnames{i}), struct_input.(fnames{i}) );
        else
            struct_new.(fnames{i}) = struct_input.(fnames{i});
        end
        
    end

    
end