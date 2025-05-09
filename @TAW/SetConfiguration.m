function SetConfiguration(obj,opts)
%SETCONFIGURATION Summary of this function goes here
%   Detailed explanation goes here
arguments
    obj
    opts.FuelMass = obj.MTOM*obj.Mf_Fuel;
    opts.PayloadFraction = 1;
    opts.IsLocked = true;
    opts.Rebuild = true;
end

if opts.Rebuild
    obj.BuildBaff(Retracted=false);
end

for i = 1:length(obj.Baff.Payload)
obj.Baff.Payload(i).FillingLevel = opts.PayloadFraction;
end

FuelFraction = opts.FuelMass/sum([obj.Baff.Fuel.Capacity]);
for i = 1:length(obj.Baff.Fuel)
obj.Baff.Fuel(i).FillingLevel = FuelFraction;
end
obj.WingEta = obj.Baff.Wing(1).Eta;
% distribute Artifical forces
obj.g = 9.81;
% obj.g = 0;
obj.GravVector = [0;0;-1];
obj.UpdateAeroEstimates();
end

