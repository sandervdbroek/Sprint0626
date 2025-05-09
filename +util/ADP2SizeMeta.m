function stats = ADP2SizeMeta(ADP,Config,SizingType,SafetyFactor,Loads,runTime,isError,Cases,Comment)
arguments
    ADP 
    Config string
    SizingType string
    SafetyFactor double
    Loads 
    runTime 
    isError 
    Cases 
    Comment string = ""
end
warning('off','MATLAB:structOnObject')
stats = struct(ADP.ToMeta);
warning('on','MATLAB:structOnObject')
stats.Type = string(Config);
stats.IsError = isError;
stats.SizingType = string(SizingType);
if isfield(ADP,'PoddedFraction')
    stats.PodFraction = ADP.PoddedFraction;
else
    stats.PodFraction = 0;
end
if isfield(ADP,'pTank_Eta')
    stats.PodEta = ADP.pTank_Eta;
else
    stats.PodEta = 0;
end
stats.NominalSafetyFactor = SafetyFactor;
stats.HingeEta = ADP.HingeEta;
stats.IsLightHinge = ADP.IsLightHinge;
stats.FuelFactor = 1;
stats.Masses = ADP.Masses;
stats.Loads = Loads;
stats.Eles = ADP.WingBeamElements;
stats.RunTime = runTime;
stats.WingBoxParams = ADP.WingBoxParams;
stats.ADP = ADP.Clone();
stats.Cases = Cases;
if exist('Comment','var')
    stats.Comment = string(Comment);
else
    stats.Comment = "";
end
end

