function val = getHistPlotValue (app, attr, plotVar, applyFilter)
    val = [];
    if isempty(app.data)
        return;
    end
    
    if nargin < 4
        applyFilter = true;
    end

    if nargin == 1
        attr = app.histAttributeDropDown_4.Value;
        plotVar = app.plotVarDropDown.Value;
    end

    attrValue = getAttrValue(app, attr);
    if applyFilter
        attrValue = attrValue(app.ftr, :);
    end
    if strcmp('per loc', plotVar)
        val = attrValue;
        return;
    end
    tid = app.data.tid;
    if applyFilter
        tid = tid(app.ftr);
    end
    tid(isnan(attrValue)) = []; attrValue(isnan(attrValue)) = [];
    trace_ID = unique(tid);
    switch plotVar
        case 'per loc'
            val = attrValue;
        case 'trace mean'
            val = arrayfun(@(x) mean(attrValue(tid==x, :)), trace_ID);
        case 'trace stdev'
            val = arrayfun(@(x) std(attrValue(tid==x, :)), trace_ID);
        case 'trace median'
            val = arrayfun(@(x) median(attrValue(tid==x, :)), trace_ID);
        case 'trace mode'
            val = arrayfun(@(x) mode(attrValue(tid==x, :)), trace_ID);
        case 'trace max'
            val = arrayfun(@(x) max(attrValue(tid==x, :)), trace_ID);
        case 'trace min'
            val = arrayfun(@(x) min(attrValue(tid==x, :)), trace_ID);
        case 'trace range'
            val = arrayfun(@(x) range(attrValue(tid==x, :)), trace_ID);
        otherwise
            val = attrValue;
    end
end