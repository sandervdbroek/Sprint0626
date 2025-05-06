function [Lds,BinFolder] = TurbLoads(obj,Case,idx,opts)
arguments
    obj
    Case cast.LoadCase
    idx double
    opts.BinFolder string = Case.Name;
    opts.Verbose = true;
end
BinFolder = opts.BinFolder;

%get 1g cruise loads
if Case.Nonlinear
    obj.Sol144nonlin(Case.Mach,Case.Alt,1, BinFolder=BinFolder, TruelySilent=~opts.Verbose);          
else
    obj.Sol144(Case.Mach,Case.Alt,1, BinFolder=BinFolder, TruelySilent=~opts.Verbose);
end
filename = fullfile(BinFolder,'bin','sol144.h5');
Loads_1g = obj.ExtractStaticLoads(filename,obj.Tags).SetIdx(idx);

%get incremental gust loads
obj.Sol146(Case.Mach,Case.Alt,BinFolder=BinFolder, DispIDs=nan, TruelySilent=~opts.Verbose,Type='Turb');
filename = fullfile(BinFolder,'bin','sol146.h5');
Loads_turb = obj.ExtractTurbLoads(filename,obj.Tags);

Lds_min = (Loads_1g - Loads_turb);
Lds_max = (Loads_1g + Loads_turb);
Lds = Lds_min.abs() | Lds_max.abs();
Lds = Lds.max() .* Case.SafetyFactor;
end