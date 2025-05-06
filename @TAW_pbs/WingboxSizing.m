function [ADP,res_mtom,Lds,time_size,isError] = WingboxSizing(ADP,sizeStepOpts,opts)
arguments
    ADP
    sizeStepOpts.useDLM = false
    sizeStepOpts.IncludeGusts = true;
    sizeStepOpts.IncludeTurb = true;
    sizeStepOpts.Verbose = false;
    sizeStepOpts.Silent = true;
    sizeStepOpts.MaxInnerStep= 15;
    sizeStepOpts.NGoldenSection = 7;
    sizeStepOpts.InnerConverge = 0.1;
    sizeStepOpts.CleanUp = true;
    sizeStepOpts.SafetyFactor = 1.5;
    sizeStepOpts.BinFolder ='';
    opts.SizeMethod = 'size_step';
end

try
    tic;
    optsCell = namedargs2cell(sizeStepOpts);
    [ADP,~,Lds] = ADP.(opts.SizeMethod)(optsCell{:},'isWingAreaFixed',true);
    res_mtom = ADP.MTOM;
    time_size = toc; 
    isError = false;
catch err
    switch err.identifier
        case {'CAST:SizingError','ADS:Nastran'}
            % sizing loop failed return with error flag
            res_mtom = nan;
            Lds = cast.size.Loads.empty;
            time_size = toc;
            isError = true;
            warning(err.message)
        otherwise
            rethrow(err)
    end
end

end

