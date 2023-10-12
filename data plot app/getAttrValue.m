function value = getAttrValue (app, attrName)
    if ~isempty(app.data)
        value = getfield(app.data, attrName);
        %value = value(app.ftr, :);     % apply filter
    else
        value = [];
    end
end