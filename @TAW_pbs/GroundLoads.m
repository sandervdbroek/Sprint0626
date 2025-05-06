function [Lds,BinFolder] = GroundLoads(obj,Case,idx,opts)
arguments
    obj
    Case cast.LoadCase
    idx double
    opts.BinFolder string = "";
    opts.Verbose logical = true;
end
if string(opts.BinFolder) == ''
    BinFolder = Case.Name;
else
    BinFolder = opts.BinFolder;
end
obj.Sol101(BinFolder=BinFolder, TruelySilent=~opts.Verbose,GravVector=obj.GravVector,g=obj.g);
filename = fullfile(BinFolder,'bin','sol101.h5');
Lds = obj.ExtractStaticLoads(filename,obj.Tags).abs() .* Case.SafetyFactor;
Lds = Lds.SetIdx(idx);
end