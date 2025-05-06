function [Lds,BinFolder] = StaticLoads(obj,Case,idx,opts)
arguments
    obj
    Case cast.LoadCase
    idx double
    opts.BinFolder string = "";
    opts.Verbose = true;
end
if string(opts.BinFolder) == ''
    BinFolder = Case.Name;
else
    BinFolder = opts.BinFolder;
end
obj.Sol144(Case.Mach,Case.Alt,Case.LoadFactor,...
    BinFolder=BinFolder, TruelySilent=~opts.Verbose);
filename = fullfile(BinFolder,'bin','sol144.h5');
Lds = obj.ExtractStaticLoads(filename,obj.Tags).abs() .* Case.SafetyFactor;
Lds = Lds.SetIdx(idx);
end

