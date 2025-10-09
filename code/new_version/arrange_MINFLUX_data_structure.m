function [raw_data, attributes, num_loc, num_itr] = arrange_MINFLUX_data_structure (raw_data, load_all_iteration, load_effective_cfr)
    
    if nargin < 3
        load_effective_cfr = true;
    end
    if nargin < 2
        load_all_iteration = false;
    end

    attributes = raw_data;
    num_loc = 0;            % number of localization, only count valid data
    num_itr = 0;            % number of iteration (of MINFLUX acquisition)
    
    if ~isfield(raw_data, 'itr') % itr should always present in raw data
        errordlg('Cannot find iteration (itr) attribute!', 'Wrong format!');
        %warning("MINFLUX data format wrong, cannot find iteration (itr) attribute!");
        attributes = [];
        return
    end

    % Abberrior Imspector format, unwrap attr contained in 'itr'
    if ~isfield(raw_data, 'loc')
        names_1 = fieldnames(attributes.itr);
        cells_1 = struct2cell(attributes.itr);
        attributes = rmfield(attributes, 'itr');
        names_2 = fieldnames(attributes);
        cells_2 = struct2cell(attributes);
        attributes = cell2struct([cells_1; cells_2], [names_1; names_2]);
    end
    raw_data = attributes;  % update raw data after unwrap "itr"

    % remove reference point attribute, keep it in raw data
    if isfield(attributes, 'mbm')
        attributes = rmfield(attributes, 'mbm');
    end

    % check if localization data exist (It should be always true)
    if ~isfield(attributes, 'loc')
        errordlg('Cannot find localization data!', 'Wrong format!');
        %warning("MINFLUX data format wrong, cannot find localization data!");
        attributes = [];
        return
    end
    
    % get complete data attribute name list, store it in property
    attr_names = fieldnames(attributes);

    % get N(loc) and N(itr)

    % itr, num_loc, num_itr, vld, 
    itr = attributes.itr;
    [num_loc, num_itr] = size(itr);

    %if any(itr~=(itr(1))) % m2410 new data format

        %end


    % arrange format and dimension of nLoc and nItr
    if num_loc == 1
        num_loc = num_itr;    % swap to get the correct number of localizations
        itr = itr';
        if num_loc == 1    % data with only 1 localization, invalid
            errordlg('MINFLUX data appear to have only 1 localization data point, abort import!', 'Wrong format!');
            %warning("MINFLUX data appear to have only 1 localization data point, abort import!")
            attributes = [];
            return
        end
        
        num_itr = 1;       % only 1 iteration
    end

    if num_itr == 1 && all(itr==(itr(1)))
        warning('off', 'backtrace');
        warning("MINFLUX data appear to have only 1 iteration!");
        warning('on', 'backtrace');
    end

    vld = true(num_loc, 1);
    if isfield(attributes, 'vld')
        vld = attributes.vld;
    end

    num_loc = size(attributes.loc(vld, :), 1); % only load valid data into app.data



    % arrange attribute values to be: num_loc by 1 (num_loc row, 1 column)
    % check pref if load all iteration, added iter sub field to data: iter: 1, 2, 3, ..., num_itr, all
    % check effective cfr, efc, dcr iteration and so on

    iter_first = 1; iter_last = num_itr;
    if ~load_all_iteration
        iter_first = iter_last;     % only take last iteration if not loading all iterations
    end

    for i = 1 : length(attr_names)

        % check attr dimension
        attrName = attr_names{i};
        value = attributes.(attrName);
        
        % unify value to num_loc by num_itr
        if (size(value, 1) == 1)
            value = repmat(value', [1, num_itr]);   % for value that not related to iterations, duplicate value for the number of iterations
        elseif (size(value, 1) == num_itr)  % data has structure num_itr by num_loc, never seen so far with any format of MINFLUX raw data, but keep it here for cautious
            value = value';
        end

        % separate localization related attribute that has 3 dimensions to _x, _y, _z attribute,
        % always take last iteration value regardless preference setup
        if any(matches(attrName, ["loc", "lnc", "ext"]))   %ndims(value) == 3   % loc, lnc, ext
            attributes = rmfield(attributes, attrName); % remove original xyz attribute
            attributes.([attrName, '_x']) = squeeze(value(vld, iter_first : iter_last, 1));
            attributes.([attrName, '_y']) = squeeze(value(vld, iter_first : iter_last, 2));
            attributes.([attrName, '_z']) = squeeze(value(vld, iter_first : iter_last, 3));
            continue;
        end

        
        if ~load_all_iteration
            if load_effective_cfr && ( strcmp(attrName, 'cfr') || strcmp(attrName, 'efc') ) % check which iteration 'cfr' and 'efc' store reasonable values
                [~, idx] = max( sum( abs(value), "omitnan" ) ); % take value from iteration that store the max sum of values
                fprintf('reading %s from iteration %d (%d / %d).\n', attrName, 1 + itr(1, idx), idx, num_itr);
                value = value(vld, idx);

            % elseif load_all_dcr && strcmp(attrName, 'dcr')  % check if all iteration of dcr needed
                %value = value;             % if so, keep original dcr value format that contain all interations in different columns

                % all dcr value only needed for two color MINFLUX, so moved to app.data.channel.dcr

            else
                value = value(vld, end);    % only take value from last iteration
            end
        else        %TODO: check how to arrange data if loading all iteration

        end

        % store re-arranged value back to attribute
        attributes.(attrName) = value;

    end



end


%TODO: just switch case to different .mat version of minflux raw data:
%   1: m2205: 
%       1, 15 fields nested within itr: (all nLoc x nItr): loc, lnc, ext: nLoc x nItr x 3
%       2, data shape: 1 x nLoc
%       2, for data with only 1 iteration: 1 x nLoc; loc nLoc x 3; ext is 1 x nLoc

                    % Field Name	Meaning
                    %         act	Activation 1, when efo < fbg, 0 otherwise 
                    %         dos	Digital Output
                    %         gri	Grid Index
                    %         itr	Iteration
                    %         sky	Maximum number of repetitions to localize an emitter
                    %         sqi	Sequence index
                    %         tid	Trace ID
                    %         tim	Time of localization of last iteration
                    %         vld	Is valid localization
                    %
                    %         Iteration specific fields nested within 'itr'
                    %         tic	Time stamp for every iteration (FPGA ticks 40 MHz = 25 ns)
                    %         loc	Localizations (corrected if active MBM)
                    %         lnc	Final localizations (no applied corrections)
                    %         eco	Effective counts at offset
                    %         ecc	Effective counts at center
                    %         efo	Effective Frequency at offset
                    %         efc	Effective frequency at center
                    %         sta	New status (number that encodes abort criteria)
                    %         cfr	Center frequency ratio (efc/efo)
                    %         dcr	Detection channel ratio
                    %         ext	Beampattern diameter
                    %         gvy	Galvo center position in y
                    %         gvx	Galvo center position in x
                    %         eoy	EOD position relative to galvo center in y
                    %         eox	EOD position relative to galvo center in x
                    %         dmz	Deformable mirror position in z
                    %         lcy	Localization position relative to beam in y
                    %         lcx	Localization position relative to beam in x
                    %         lcz	Localization position relative to beam in z
                    %         fbg	Estimated background frequency value
%
%   2: m2410: 
%       1, no nested field;
%       2, itr contains all iteration in order: 0, 1, 2, 3...
%       3, data shape 1xN, Nx3 (loc, lnc), Nx2 or Nx1 (dcr)
%   
%
                    % Field Name	Class	Meaning
                    %         bot	logical	Begin of a trace
                    %         cfr	double	Center frequency ratio (efc/efo)
                    %         dcr	double	Detection channel ratio (now reports two values)
                    %         ecc	uint32	Effective counts at offsets
                    %         eco	int32	Effective counts at center
                    %         efc	double	Effective Frequency at center
                    %         efo	double	Effective frequency at offset
                    %         eot	logical	End of trace
                    %         fbg	double	Estimated background frequency value
                    %         fnl	logical	Is final iteration (N.B. does not directly correlate to valid final)
                    %         gri	int32	Grid index
                    %         itr	int32	Iteration index
                    %         loc	double	Localizations (potentially corrected)
                    %         lnc	double	Localizations (no applied corrections)
                    %         sqi	int32	Sequence index
                    %         sta	int32	Status (number that encodes abort criteria)
                    %         thi	int32	Thread index
                    %         tid	int32	Trace ID
                    %         tim	double	Time stamp for every iteration
                    %         vld	logical	Is valid iteration
%
%
                    % Field Name	Class	Meaning
                    %         act	logical	Activation 1, when efo < fbg, 0 otherwise 
                    %         dos	int32	Digital Output
                    %         gri	int32	Grid Index
                    %         itr	structure	Iteration
                    %         sky	int32	Maximum number of repetitions to localize an emitter
                    %         sqi	int32	Sequence index
                    %         tid	int32	Trace ID
                    %         tim	double	Time of localization of last iteration
                    %         vld	logical	Is valid iteration
                    %         nested structure within iteration
                    %         tic	int64	Time stamp for every iteration (FPGA ticks 40 MHz = 25 ns)
                    %         loc	double	Localizations (potentially corrected)
                    %         lnc	double	Final localizations (no applied corrections)
                    %         eco	int32	Effective counts at offsets
                    %         ecc	int32	Effective counts at center
                    %         efo	double	Effective Frequency at offset
                    %         efc	double	Effective frequency at center
                    %         sta	int32	Status (number that encodes abort criteria)
                    %         cfr	double	Center frequency ratio (efc/efo)
                    %         dcr	double	Detection channel ratio
                    %         ext	double	Beampattern diameter
                    %         gvy	double	Galvo center position in y
                    %         gvx	double	Galvo center position in x
                    %         eoy	double	EOD position relative to galvo center in y
                    %         eox	double	EOD position relative to galvo center in x
                    %         dmz	double	Deformable mirror position in z
                    %         lcy	double	Localization position relative to beam in y
                    %         lcx	double	Localization position relative to beam in x
                    %         lcz	double	Localization position relative to beam in z
                    %         fbg	double	Estimated background frequency value
%
%
%
%   4: m2205-ries: unwrapped itr, shape kept same (loc, lnc, ext has nLoc x nItr x 3)
%
%   5: m2205-huang: unwrapped itr, shape all to nLoc x nItr x 1,2,3(loc, lnc, ext); could have mbm field
%
%   6: m2410-huang
%
%