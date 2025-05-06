function [obj,delta,Lds,Cases] = size_step(obj,opts)
arguments
    obj
    opts util.SizingOpts
end
initial_MTOM = obj.MTOM;
% size Aircraft
if obj.Size_wing
    if ~opts.useDLM
        % If not using DLM create a 2.5G Manoevre
        config = struct();
        config.FuelMass = obj.MTOM*obj.Mf_Fuel;
        config.PayloadFraction = opts.PayloadFraction;
        config.ArtForceFactor = 2.5;
        config.IsLocked = true;
        Cases = cast.LoadCase.Ground(Config=config,Name='2d5_FF10',SafetyFactor=opts.SafetyFactor,Idx=2);
    else
        % define configuration
        config = struct();
        config.FuelMass = obj.MTOM*obj.Mf_Fuel;
        config.PayloadFraction = opts.PayloadFraction;
        config.IsLocked = true;
        Cases = cast.LoadCase.empty;
        % add jig twist load acase if reqeuired
        if opts.IncludeJigTwistOpt
            Cases(end+1) = util.JigTwistSizingCase(obj.ADR.M_c,obj.ADR.Alt_cruise.*cast.SI.ft,Config=config,SafetyFactor=1,Idx=99);
        end
        Cases = [Cases,GenLoadCases(obj,config,opts)];
    end
    [~,~,Lds]=obj.Sizing(Cases,opts);
    obj.ApplyWingParams();
    % check on convergence
    obj.WingEta = obj.Baff.Wing(1).Eta;
    obj.OEM = obj.Baff.GetOEM();
    obj.MTOM = obj.OEM + obj.ADR.Payload + obj.MTOM * obj.Mf_Fuel;
    delta = obj.MTOM - initial_MTOM;
else
    delta = 0;
    Lds = cast.size.Loads.empty;
    Cases = cast.LoadCase.empty;
end
end

