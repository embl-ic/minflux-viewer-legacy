function [valid, attributes, property, file] = validate_raw_data (~, folder, file_name)

    valid = false;
    attributes = struct();
    file = struct();

    file.raw_data = load(fullfile(folder, file_name), '-mat');
    if isempty(file.raw_data) || ~isfield(file.raw_data, 'itr')
        warning("MINFLUX data file not valid!");
        return
    end
    
    file.folder = folder;
    file.name = file_name;
    attributes = file.raw_data;
    property = struct;

    % remove reference point attribute
    if isfield(file.raw_data, 'mbm')
        attributes = rmfield(attributes, 'mbm');
    end
    
    % Abberrior Imspector format, unwrap attr contained in 'itr'
    if ~isfield(file.raw_data, 'loc')
        names_1 = fieldnames(attributes.itr);
        cells_1 = struct2cell(attributes.itr);
        attributes = rmfield(attributes, 'itr');
        names_2 = fieldnames(attributes);
        cells_2 = struct2cell(attributes);
        attributes = cell2struct([cells_1; cells_2], [names_1; names_2]);
        file.raw_data = attributes;
    end
    
    % check if localization data exist
    if ~isfield(attributes, 'loc')
        return
    end
    

    % get complete data attribute name list
    property.attr_names = fieldnames(attributes);

    % get N(loc) and N(itr)
    itr = attributes.itr;
    [property.num_loc, property.num_itr] = size(itr);
    vld = true(property.num_loc, 1);
    if isfield(attributes, 'vld')
        vld = attributes.vld;
    end
    % arrange format and dimension of nLoc and nItr
    if property.num_loc == 1
        property.num_loc = property.num_itr;    % swap to get the correct number of localizations
        itr = itr';
        if property.num_loc == 1    % data with only 1 localization, invalid
            return
        end
        property.num_itr = 1;   % only 1 iteration
    end
    property.num_loc = size(attributes.loc(vld, :), 1); % only load valid data into app.data

    % arrange attribute values to be: num_loc by 1
    % check pref if load all iteration
    for i = 1 : length(property.attr_names)

        % check attr dimension
        attrName = property.attr_names{i};
        value = attributes.(attrName);

        % squeeze attribute that more than 2 dimension
        if ndims(value) == 3   % loc, lnc, ext
            attributes = rmfield(attributes, attrName);
            value = squeeze(value(vld, end, :));   % only take last iteration for 3D data
            attributes.([attrName, '_x']) = value(:, 1);
            attributes.([attrName, '_y']) = value(:, 2);
            attributes.([attrName, '_z']) = value(:, 3);
            continue;
        end

        % swap value to N by 1
        if (size(value, 1) == 1)
            value = value';
        end

        % check which iteration 'cfr' and 'efc' might has valid values
        if strcmp(attrName, 'cfr') || strcmp(attrName, 'efc')
            [~, idx] = max( sum( abs(value), "omitnan" ) ); % take value from iteration that store the max sum of values
            if idx ~= property.num_itr
                fprintf('reading %s from iteration %d (%d / %d).\n', ...
                    attrName, 1 + itr(1, idx), idx, property.num_itr);
            end
            value = value(vld, idx);
        else
            value = value(vld, end);
        end
        
        % store re-arranged value back to attribute
        attributes.(attrName) = value;

    end
    
    valid = true;


end
