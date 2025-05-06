function obj = JigTwistSizingCase(Mach,alt,opts)
arguments
    Mach
    alt
    opts.Name = "";
    opts.SafetyFactor = 1.5;
    opts.Config = struct();
    opts.NonLinear = false;
    opts.Idx = nan;
end
obj = cast.LoadCase();
obj.Type = "JigTwistSizing";
obj.Name = sprintf('JigTwist');
if opts.Name ~= ""
    obj.Name = obj.Name + "_" + opts.Name;
end
obj.LoadFactor = 1;
obj.Mach = Mach;
obj.Alt = alt;
obj.SafetyFactor = opts.SafetyFactor;
obj.ConfigParams = opts.Config;
obj.Nonlinear = opts.NonLinear;
obj.IdxOverride = opts.Idx;
end

