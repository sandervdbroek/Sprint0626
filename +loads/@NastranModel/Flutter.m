function [flut_res,BinFolder] = Flutter(obj,Mach,opts)
arguments
    obj
    Mach
    opts.Verbose = true;
    opts.IsLocked = true;
    opts.EV = false;
    opts.Alts = 60e3:-1e3:0;
end
obj.SetConfiguration(FuelMass=obj.MTOM*obj.Mf_Fuel*obj.Mf_TOC,IsLocked=opts.IsLocked)
[BinFolder,flut_res] = obj.ISO145(Mach,BinFolder=obj.BinFolder,TruelySilent=~opts.Verbose,GetEigenVectors=opts.EV,Alts=opts.Alts);
end