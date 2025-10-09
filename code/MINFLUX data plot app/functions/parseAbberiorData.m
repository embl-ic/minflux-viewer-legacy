%% Automatic parse Abberior MINLFUX data from MATLAB data format
%   Because of the changes and updates introduced by Abberior on the data
%   format and organization, it is neccessary to have a generic data parser
%   that extract faithfully the value of attributes.
%
%   This parser script first flatten the data struct, so there's no sub-struct
%   data within the flattened data.
%
%   It then retrives the number of localization, and number of iterations: 
%   nLoc, nItr.
%
%   For different attribute, extract the meaningful value from different
%   iterations:
%   - for most attribute, value are taken from the last iteration;
%   - for 'cfr', 'efc', value are taken from the effective iteration;
%   - for 'loc', 'lnc', 'ext', value consist of x,y,z coordinates;
%   - for 2024.02.19 Aberrior update, not all iteration are exported.
%
%   <Ziqiang.Huang@embl.de>
%   date: 2024.03.19
%%


function parseAbberiorData (app)
    if isempty(app.data)
        return;
    end

    % account for a custom data format included the mbm info field
    if isfield(app.data, 'mbm')     
        app.data = rmfield(app.data, 'mbm');
    end

    % account for iMSPECTOR version m2205 data format
    if isstruct(app.data.itr) 
        data1 = app.data.itr;
        data2 = rmfield(app.data, 'itr');
        cell1 = [fieldnames(data1) struct2cell(data1)];
        cell2 = [fieldnames(data2) cellfun(@(el) el', struct2cell(data2), 'uni', 0)];
        cell3 = [reshape(cell1.',1,[]) reshape(cell2.',1,[])];
        app.data = struct(cell3{:});
    end
    
    % extract iteration information, and deduce data format, nLoc, nItr
    minLocNum = 100;    maxItrNum = 20;     % valid data criterion > 100 nLoc and < 20 iteration
    itr = app.data.itr; % nLoc x nItr; 1 x N
    if numel(itr) < minLocNum   % wrong iteration of data, abort
        return;
    end
    m2410 = size(itr, 1) == 1;  % check data format: m2205 or m2410
    nItr = 1 + max(itr(:));     % itr is 0-based, to get number of iteration, add 1 on max value
    if (nItr > maxItrNum) 
        return; 
    end
    take = itr == nItr-1;       % prepare to extract only value from last iteration
    nLoc = sum(take);           % number of localizations (include invalid ones)
    if (nLoc < minLocNum) 
        return; 
    end
    app.nLoc = nLoc; app.nItr = nItr;
    if isempty(app.nLoc) || isempty(app.nItr)
        error('number of localization and/or iteration wrong!');
    end


    % reconstruct app.data to keep only the last iteration of attribute value
    shape_struct = structfun(@(fd) size(fd), app.data, 'uni', 0);
    fnames = fieldnames(shape_struct);
    %shapes = struct2cell(shape_struct);
    %numAttrs = numel(fnames);
    %values = cell(numAttrs, 1);
    
    % get value from the corresponding iteration
    values = {}; names = {};
    split_xyz = true;
    
    for i = 1 : numel(fnames)

        attrName = fnames{i};
        attrValue = app.data.( attrName );
        
        if m2410    %  iMSPECTOR version m2410

            if size(attrValue, 1) == 1  % 1 by N
                attrValue = attrValue(take)';
            elseif any(matches( attrName, ["loc", "lnc", "ext"] )) % N by 3

                if split_xyz

                    names = [ names; 
                        strcat(attrName,'_x'); 
                        strcat(attrName,'_y'); 
                        strcat(attrName,'_z') ]; %#ok<AGROW>
                    values = [ values; 
                        { attrValue(take, 1) }; 
                        { attrValue(take, 2) }; 
                        { attrValue(take, 3) } ]; %#ok<AGROW>
                    continue;

                else
                    attrValue = attrValue(take, :); %#ok<UNRCH>
                end

            elseif strcmp(attrName, 'dcr') % N by 2 or 1                             % any(matches( attrName, "dcr" ))
                attrValue = attrValue(take, 1); % only take the 1st channel dcr value
            end

        else        %  iMSPECTOR version m2205, if there's only 1 iteration, this won't work!!!

            if any(matches( attrName, ["loc", "lnc", "ext"] ))    % nLoc by nItr by 3
                
                if split_xyz

                    names = [ names; 
                        strcat(attrName,'_x'); 
                        strcat(attrName,'_y'); 
                        strcat(attrName,'_z') ]; %#ok<AGROW>
                    values = [ values; 
                        { squeeze( attrValue(:, end, 1) ) }; 
                        { squeeze( attrValue(:, end, 2) ) }; 
                        { squeeze( attrValue(:, end, 3) ) } ]; %#ok<AGROW>
                    continue;

                else
                    attrValue = squeeze( attrValue(:, end, :) ); %#ok<UNRCH>
                end

            elseif any(matches( attrName, ["cfr", "efc"] )) % cfr and efc value might not be in the last iteration for m2205
                [~, itr_effective] = max(nansum(attrValue{i}));   %#ok<NANSUM>
                attrValue = attrValue(:, itr_effective);
                fprintf('reading %s from %d / %d iteration.\n', attrName, idx, nItr);
            else
                attrValue = attrValue(:, end);
            end

        end
        
        names  = [names; attrName];         %#ok<AGROW>
        values = [values; {attrValue}];         %#ok<AGROW>
    end

    app.data = cell2struct(values, names);

    %app.data = getAttrValue (value, name, app.nLoc, app.nItr, dim_sorted, split_xyz);

    
end

    
    % reshape data to N by 1 in name : value pair; name kept unchanged,
    % value should all be unified to N by 1
    % function [value, name] = flatten (data_struct, fieldname, value, name)
    %     %value = {}; name = {};
    %     if any(ismember(name, fieldname))   % skip already processed attribute
    %         return
    %     end
    %     if isstruct(data_struct.(fieldname)) % for data version wrap attributes in itr
    %         sub_names = fieldnames(data_struct.(fieldname));
    %         for i = 1 : numel(sub_names)
    %             [value, name] = flatten(data_struct.(fieldname), sub_names{i}, value, name);
    %         end
    %     else
    %         value =  vertcat(value, data_struct.(fieldname));
    %         name = vertcat(name, fieldname);
    %     end
    % end


    % retrieve the number of: 1, Localizations; 2, iterations; 3, sort with descending dimensions?

    %     if isstruct(data_struct.(fieldname)) % for data version wrap attributes in itr
    %         attrnames = fieldnames(data_struct.(fieldname));
    %         for i = 1 : numel(attrnames)
    %             [value, name] = flatten(data_struct.(fieldname), attrnames{i}, value, name);
    %         end
    %     else
    % 
    % 
    % 
    % 
    % 
    %     [dim1, dim2] = size(itr);
    %     if dim1 > dim2
    %         nLoc = dim1;
    %         nItr = itr(1, dim2);
    %     else
    %         nItr = max(itr);
    %         nLoc = sum(itr == nItr);
    %     end
    %     if nLoc < minLocNum || nItr > maxItrNum
    %         nLoc = []; nItr = [];
    %         return;
    %     end
    % end
    % function [nLoc, nItr, dim_sorted] = getDimension (data)
    %     nLoc = [];   nItr = [];
    %     if isempty(data)
    %         return;
    %     end
    %     % minimum number of localization expected: 100
    %     % maximum number of iteration expected: 50
    %     minLocNum = 100;    maxItrNum = 50;
    %     % get dimensions of each attribute
    %     dim(:, 1) = structfun(@(x) size(x, 1), data);
    %     dim(:, 2) = structfun(@(x) size(x, 2), data);
    %     dim(:, 3) = structfun(@(x) size(x, 3), data);
    %     % sort each attribute with descending dimensions
    %     [dim_sorted, ~] = sort(dim, 2, 'descend');
    %     nDimMax = max(dim_sorted);
    %     % find number of loc from the max sorted data dimension
    %     nLoc = nDimMax(:, 1);
    %     if (nLoc < minLocNum)
    %         nLoc = [];
    %         return;
    %     end
    %     % find number of iteration as the dimension with value other than 3
    %     idx_three = find(nDimMax(:,2:3)==3);
    %     nItr = nDimMax(4 - idx_three);
    %     if (nItr > maxItrNum)
    %             nItr = [];
    %         return;
    %     end
    % end

    % get 
    % function data = getAttrValue (value, name, nLoc, nItr, dim_sorted, splitXYZ)
    %     specialAttr1 = {'cfr', 'efc'};          % value not residue in the last iteration
    %     specialAttr2 = {'loc', 'lnc', 'ext'};   % with x,y,z coordinates info.
    %     specialAttr3 = {'mbm'};                 % attribute containing reference point info.
    %     % retrieve from which iteration to get the value
    %     whichItr = guessWhichIteration (value, name, nLoc, nItr, dim_sorted, specialAttr3, specialAttr1);
    %     value_itr = {}; name_itr = {};
    % 
    %     for i = 1 : numel(whichItr)
    %         itr = whichItr{i};
    %         if (itr == 0)
    %             continue;
    %         end
    % 
    %         val = squeeze(reshape(value{i}, dim_sorted(i,:)));
    %         % attribute has x, y, z coordinates info.
    %         if find(strcmp(specialAttr2, name{i}))
    %             idx = find(dim_sorted(i, 2:3)==3);  % find dimension == 3
    %             if (idx==2)                         % dim: [nLoc, nItr, 3]
    %                 val = squeeze(val(:, itr, :));
    %             else                                % dim: [nLoc, 3, nItr]
    %                 val = squeeze(val(:, :, itr));
    %             end
    %             if splitXYZ
    %                 name_itr = [ name_itr; strcat(name(i),'_x'); strcat(name(i),'_y'); strcat(name(i),'_z') ]; %#ok<AGROW>
    %                 value_itr = [ value_itr; {val(:,1)}; {val(:,2)}; {val(:,3)} ]; %#ok<AGROW>
    %                 continue;
    %             end
    %         else
    %             val = val(:, itr);
    %         end
    %         name_itr = [name_itr; name(i)];         %#ok<AGROW>
    %         value_itr = [value_itr; {val}];         %#ok<AGROW>
    %     end
    % 
    %     data = cell2struct(value_itr, name_itr);
    % 
    % end
    % 
    % 
    % % generate a list of from which iteration each attribute should retrieve its value
    % function whichItr = guessWhichIteration (value, name, nLoc, nItr, dim_sorted, attrExclude, specialAttr)
    %     nAttr = length(name);
    %     whichItr = cell(nAttr, 1);
    %     whichItr(:) = {1};
    %     if (nItr == 1)
    %         return;
    %     end
    %     for i = 1 : length(name)
    %         % attribute in the exclusion list, remove
    %         if find(strcmp(attrExclude, name{i}))
    %             whichItr{i} = 0;
    %             continue;
    %         end
    %         % attribute don't correspond to each localization, remove
    %         if (dim_sorted(i, 1) ~= nLoc)
    %             whichItr{i} = 0;
    %             continue;
    %         end
    %         % attributes dimension is nLoc by 1, take the only value
    %         if (dim_sorted(i,2) == 1 && dim_sorted(i,3) == 1)
    %             whichItr{i} = 1;
    %             continue;
    %         end
    %         % special attribute stores value not in the last iteration
    %         if find(strcmp(specialAttr, name{i}))
    %             itr = value{cellfun(@(x) strcmp(x, 'itr'), name)};
    %             [~, idx] = max(nansum(value{i})); %#ok<NANSUM>
    % 
    %             if idx ~= nItr
    %             nthItr = 1 + itr(1, idx);
    %             nthText = 'th';
    %             if     1 == nthItr
    %                 nthText = 'st';
    %             elseif 2 == nthItr
    %                 nthText = 'nd';
    %             elseif 3 == nthItr
    %                 nthText = 'rd';
    %             end
    %             fprintf('reading %s from %d%s iteration (%d / %d).\n', ...
    %                 name{i}, nthItr, nthText, idx, nItr);
    %             end
    % 
    % 
    %             whichItr{i} = idx;
    %         else % by default, attribute take value from last iteration
    %             whichItr{i} = nItr;
    %         end
    %     end
    % end

