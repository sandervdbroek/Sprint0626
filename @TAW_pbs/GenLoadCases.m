function Cases = GenLoadCases(obj,config,opts,ExtraOpts)
arguments
    obj
    config
    opts util.SizingOpts
    
    ExtraOpts.IdxOffset = 0;
end

Cases = cast.LoadCase.empty;
% add ground loads
if opts.IncludeGround
    Cases(end+1) = cast.LoadCase.Ground(Config=config,Name='grd_loads',SafetyFactor=opts.SafetyFactor,Idx=9+ExtraOpts.IdxOffset);
end
if opts.IncludePosG
    % add Positive G Manoeuvre
    Cases(end+1) = cast.LoadCase.Manoeuvre(obj.ADR.M_c,obj.ADR.Alt_cruise.*cast.SI.ft,opts.PosManoG,config=config,...
        SafetyFactor=opts.SafetyFactor,Idx=1+ExtraOpts.IdxOffset);
    % add Positive G Zero Fuel Manoeuvre
    if opts.IncludeZeroFuel
        tmp = config;
        tmp.FuelMass = 0;
        Cases(end+1) = cast.LoadCase.Manoeuvre(obj.ADR.M_c,obj.ADR.Alt_cruise.*cast.SI.ft,2.5,config=tmp,...
            SafetyFactor=opts.SafetyFactor,Idx=2+ExtraOpts.IdxOffset);
    end
end
% add negative G manuoevre
if opts.IncludeNegG
    Cases(end+1) = cast.LoadCase.Manoeuvre(obj.ADR.M_c,obj.ADR.Alt_cruise.*cast.SI.ft,opts.NegManoG,config=config,...
        SafetyFactor=opts.SafetyFactor,Idx=3+ExtraOpts.IdxOffset);
end
% add gusts/turb at Vc MC Corner
[~,~,~,~,h] = ads.util.get_flight_condition(obj.ADR.M_c,CAS=obj.ADR.V_climb);
Alt = convlength(h,'m','ft'); % alt of Vc MC corner
if opts.IncludeGusts
    Cases(end+1) = cast.LoadCase.Gust(obj.ADR.M_c,Alt,Config=config,SafetyFactor=opts.SafetyFactor,Idx=4+ExtraOpts.IdxOffset);
end
if opts.IncludeTurb
    Cases(end+1) = cast.LoadCase.Turbulence(obj.ADR.M_c,Alt,Config=config,SafetyFactor=opts.SafetyFactor,Idx=5+ExtraOpts.IdxOffset);
end

end

