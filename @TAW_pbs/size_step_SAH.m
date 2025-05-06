function [obj,delta,Lds,Cases] = size_step_SAH(obj,opts)
arguments
    obj
    opts util.SizingOpts
end
initial_MTOM = obj.MTOM;
% size Aircraft
if obj.Size_wing
    if ~opts.useDLM
        config = struct();
        config.FuelMass = obj.MTOM*obj.Mf_Fuel;
        config.PayloadFraction = opts.PayloadFraction;
        config.ArtForceFactor = 2.5;
        config.IsLocked = true;
        Cases = cast.LoadCase.Ground(Config=config,Name='mano_failure',SafetyFactor=1,Idx=11);
        config.IsLocked = false;
        Cases(end+1) = cast.LoadCase.Ground(Config=config,Name='mano_free',SafetyFactor=opts.SafetyFactor,idx=1);
        config.ArtForceFactor = 0;
        config.IsLocked = true;
        Cases(end+1) = cast.LoadCase.Ground(Config=config,Name='grd_loads',SafetyFactor=opts.SafetyFactor,Idx=9);
    else
        config = struct();
        config.FuelMass = obj.MTOM*obj.Mf_Fuel;
        config.PayloadFraction = opts.PayloadFraction;
        config.IsLocked = true;
        Cases = cast.LoadCase.empty;
        % add jig twist load case if requeired
        if opts.IncludeJigTwistOpt
            Cases(end+1) = util.JigTwistSizingCase(obj.ADR.M_c,obj.ADR.Alt_cruise.*cast.SI.ft,Config=config,SafetyFactor=opts.SafetyFactor,Idx=99);
        end
        % add wingtip 'free' load cases
        config.IsLocked = false;
        Cases = [Cases,GenLoadCases(obj,config,opts.excludeGround())];
        % add wingtip 'locked' Failure cases
        config.IsLocked = true;
        tmpOpts = opts;
        tmpOpts.SafetyFactor = 1;
        Cases = [Cases,GenLoadCases(obj,config,opts.failureCase(),IdxOffset=10)];
    end
    [~,~,Lds]=obj.Sizing(Cases,opts);
    obj.ApplyWingParams();
    % check on convergence
    obj.WingEta = obj.Baff.Wing(1).Eta;
    obj.OEM = obj.Baff.GetOEM();
    obj.MTOM = obj.OEM + obj.ADR.Payload + obj.MTOM * obj.Mf_Fuel;
    delta = obj.MTOM - initial_MTOM;
else
    % do nothing
    delta = 0;
    Lds = cast.size.Loads.empty;
    Cases = cast.LoadCase.empty;
end

end

