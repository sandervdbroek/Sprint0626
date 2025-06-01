function SetConfiguration(obj,opts)
%SETCONFIGURATION Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj
    opts.FuelMass = obj.Taw.MTOM*obj.Taw.Mf_Fuel;
    opts.PayloadFraction = 1;
    opts.IsLocked = true;
end
optsCell = namedargs2cell(opts);
obj.Taw.SetConfiguration(optsCell{:},Rebuild=false);
end

