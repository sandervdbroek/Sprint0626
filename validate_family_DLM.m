clear all
fclose all;
close all;
cruise_alt = 34e3./cast.SI.ft;
alternate_dist = 325e3;

bin_folder = 'bin_a320_ja1';
%% load A321
% set parameters
% ADP.WingBoxParams = cast.size.WingBoxSizing.empty;

%misson settings
ADP = TAW_pbs();
ADP.ADR = cast.ADR.A320(235,2500,25e3);
ADP.ADR.Alt_cruise = cruise_alt;
ADP.ADR.Range_alternate = alternate_dist;

ADP.Engine = cast.config.Engine.CFM_LEAP_1A(1,cruise_alt,ADP.ADR.M_c);

%wing settings
ADP.RibPitch = 0.8;
ADP.WingBeamElements = 60;
ADP.WingletHeight = 2.4;
ADP.Span = 35.8;

%hinge setting
ADP.HingeEta = 1;
ADP.IsLightHinge = false;

%Empenage Settings
ADP.HTPArea = 31;
ADP.VTPArea = 21.72;
ADP.HTP_TCR_root = 0.15;
ADP.SizeEmpenage = false;
ADP.WingArea = 122.4;
ADP.isWingAreaFixed = true;
ADP.ldg_scale_factor = 0.85;
ADP.HTP_TCR_root = 0.15;


ADP.ThrustToWeightRatio = 0.31;
ADP.ProturbanceDrag = 0.019;
ADP.FowlerSlots = 2;
ADP.SecondaryMethod = "Planform";

% fuel settings
ADP.ExtraFuel = 0;
ADP.EnforcedConnectorFuelMass = 3238;
ADP.EnforcedWingFuelMass = 6126;




%% inital mass estimate
%initial mission analysis to estimate MTOM
mission = cast.Mission.StandardWithAlternate(ADP.ADR);
[EWF,fs] = cast.weight.MissionFraction(mission.Segments,ADP);
val = @(x) 1.1166 - 0.0516*log(x)+(ADP.ADR.Payload+ADP.ADR.CrewMass)/x-EWF; % from database
ADP.MTOM = fminsearch(@(x)val(x)^2,0);
ADP = ADP.MissionAnalysis(OverideLD=false);

fprintf('\n\n%.0f kg\n',ADP.MTOM);
fprintf('Block Fuel: %.1f Tn\n',(1-prod(fs))*93.5);
fprintf('Trip Fuel: %.1f Tn\n',(1-prod(fs([1:5,10,11])))*93.5);

%% sizing enforced
% ADP.WingBoxParams = cast.size.WingBoxSizing.empty;
% load('a321_adp.mat','ADP');
% iniitally size with an enforced lift distribution to get close...
ads.util.printing.title('Enforced Lift Dist','Length',60,'Symbol','$')
sizeOpts = util.SizingOpts(useDLM=false,BinFolder=bin_folder);
ADP = ADP.Aircraft_Sizing(sizeOpts);

[EWF,fs] = cast.weight.MissionFraction(mission.Segments,ADP);
fprintf('\n\n%.0f kg\n',ADP.MTOM);
fprintf('Block Fuel: %.1f Tn\n',(1-prod(fs))*93.5);
fprintf('Trip Fuel: %.1f Tn\n',(1-prod(fs([1:5,10,11])))*93.5);

%% sizing Mano
res = [];
% now size with DLM for manouevres only
ads.util.printing.title('Mano (DLM)','Length',60,'Symbol','$')
sizeOpts = util.SizingOpts(IncludeGusts=false,IncludeTurb=false,BinFolder=bin_folder);
[ADP,res_mtom,Lds,time,isError,Cases] = ADP.Aircraft_Sizing(sizeOpts);
% get data during cruise
fh.printing.title('Get Cruise Loads','Length',60)
[~,Lds_c] = ADP.cruise_loads(sizeOpts.SetParams( BinFolder='bin_cruise',useDLM=false));
Lds = Lds | Lds_c;
%save data
tmp_stats = SizingScripts.ADP2SizeMeta(ADP,'GFWT','Mano',1.5,Lds,time,isError,Cases);
res = dcrg.struct.concat(res,tmp_stats);

% save('UB321_baseline','ADP');

%% a320
ADP.ADR = cast.ADR.A320(180,2450,19280);
ADP.ADR.Alt_cruise = cruise_alt;
ADP.ADR.Range_alternate = alternate_dist;
ADP.SizeEmpenage = false;
ADP.Size_ldg = true;
ADP.Size_wing = false;
ADP.Size_Eng = false;
ADP.isWingAreaFixed = false;
ADP.ldg_scale_factor = 0.85;

ADP.RefMass = res(1).MTOM;
ADP.FowlerSlots = 1;

ADP.ToMeta.PrintInfo;
ADP.BuildBaff('Retracted',false);                   
ADP.Baff.draw;axis equal
% ADP.UpdateAeroEstimates();
% ADP.MissionAnalysis(PayloadFraction=opts.PayloadFraction,Range=opts.Range);

% now size with DLM for manouevres only
ads.util.printing.title('Mano (DLM)','Length',60,'Symbol','$')
sizeOpts = util.SizingOpts(IncludeGusts=false,IncludeTurb=false,BinFolder=bin_folder);
[ADP,res_mtom,Lds,time,isError,Cases] = ADP.Aircraft_Sizing(sizeOpts,SizeMethod='size_step_family');
% get data during cruise
fh.printing.title('Get Cruise Loads','Length',60)
[~,Lds_c] = ADP.cruise_loads(sizeOpts.SetParams( BinFolder='bin_cruise',useDLM=false));
Lds = Lds | Lds_c;
%save data
tmp_stats = SizingScripts.ADP2SizeMeta(ADP,'GFWT','Mano',1.5,Lds,time,isError,Cases);
res = dcrg.struct.concat(res,tmp_stats);


%% a319
ADP.ADR = cast.ADR.A320(156,2720,17750);
ADP.ADR.Alt_cruise = cruise_alt;
ADP.ADR.Range_alternate = alternate_dist;
ADP.SizeEmpenage = false;
ADP.Size_ldg = true;
ADP.Size_wing = false;
ADP.Size_Eng = false;
ADP.isWingAreaFixed = false;
ADP.ldg_scale_factor = 0.85;

ADP.ToMeta.PrintInfo;
ADP.BuildBaff('Retracted',false);
ADP.Baff.draw;axis equal

% now size with DLM for manouevres only
fh.printing.title('Mano (DLM)','Length',60,'Symbol','$')
sizeOpts = util.SizingOpts(IncludeGusts=false,IncludeTurb=false,BinFolder=bin_folder);
[ADP,res_mtom,Lds,time,isError,Cases] = ADP.Aircraft_Sizing(sizeOpts,SizeMethod='size_step_family');
% get data during cruise
fh.printing.title('Get Cruise Loads','Length',60)
[~,Lds_c] = ADP.cruise_loads(sizeOpts.SetParams( BinFolder='bin_cruise',useDLM=false));
Lds = Lds | Lds_c;
%save data
tmp_stats = SizingScripts.ADP2SizeMeta(ADP,'GFWT','Mano',1.5,Lds,time,isError,Cases);
res = dcrg.struct.concat(res,tmp_stats);

save('bin\UB320_baseline_family','res')


%% copy Masses
data = [];
idx = [3,2,1];
% idx = [3,2,1];
for i = 1:length(idx)
    m = res(idx(i)).ADP.PrintMass;
    data(:,i) = m';
end
num2clip(data);

%% copy meta
data = [];
idx = [3,2,1];
% idx = [3,2,1];
for i = 1:length(idx)
    m = res(idx(i)).ADP.ToMeta.PrintInfo;
    data(:,i) = m';
end
num2clip(data);

%% notify me
util.notify('Complete','fintan.healy@bristol.ac.uk',"JA1 Baseline family Complete");

