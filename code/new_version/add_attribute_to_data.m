function data = add_attribute_to_data (data, name, value, idx)

    if isempty(data) 
        return
    end
    
    attr_names = fieldnames(data.attr);
    if nargin < 4
        idx = numel(attr_names) + 1;
    end
    
    data.attr.(name) = value;

    if (idx <= 1)
        attr_names = [name; attr_names];
    elseif (idx > numel(attr_names))
        attr_names = [attr_names; name];
    else
        attr_names = [attr_names(1 : idx-1); name; attr_names(idx : end)];
    end

    data.prop.attr_names = attr_names;

end