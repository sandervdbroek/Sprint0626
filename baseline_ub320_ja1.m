clear all
fclose all;
close all;

bin_folder = 'bin_a320_ja1';

load('bin\UB320_baseline_family.mat')
old_res = res;
clear res
%% build baseline JA1
ADP = old_res(1).ADP.Clone();
ADP.ADR = cast.ADR.A320(180,2450,19280);
ADP.ADR.Alt_cruise = old_res(1).ADP.ADR.Alt_cruise;
ADP.ADR.Range_alternate = old_res(1).ADP.ADR.Range_alternate;

ADP.Engine = cast.config.Engine.CFM_LEAP_1A(1,ADP.ADR.Alt_cruise,ADP.ADR.M_c);
ADP.Engine.T_Static = 1.2e5;
ADP.ThrustToWeightRatio = 0.31;

ADP.isWingAreaFixed = false;
ADP.TargetWingLoading = 67.4e3/122.4; % A320
ADP.WingletHeight = 0;
ADP.EnforcedConnectorFuelMass = nan;
ADP.EnforcedWingFuelMass = nan;

ADP.SizeEmpenage = true;
ADP.V_HT = old_res(2).ADP.V_HT;
ADP.V_VT = old_res(2).ADP.V_VT;
ADP.Size_ldg = true;
ADP.Size_wing = true;
ADP.Size_Eng = true;
ADP.ldg_scale_factor = 0.85;

ADP.SecondaryMethod = "Planform";
ADP.FowlerSlots = 1;
ADP.RefMass = nan;

ADP.BuildBaff('Retracted',false);   

%% sizing Mano
res = [];
SubHarmonic = [16/19.28,6000./cast.SI.km];
% now size with DLM for manouevres gusts and turbulence
fh.printing.title('MGT (DLM)','Length',60,'Symbol','$')
sizeOpts = util.SizingOpts(IncludeGusts=true,IncludeTurb=true,BinFolder=bin_folder,SubHarmonic=SubHarmonic);
[ADP,res_mtom,Lds,time,isError,Cases] = ADP.Aircraft_Sizing(sizeOpts,SizeMethod='size_step');
% get data during cruise
fh.printing.title('Get Cruise Loads','Length',60)
[~,Lds_c] = ADP.cruise_loads(sizeOpts.SetParams( BinFolder='bin_cruise',useDLM=false));
Lds = Lds | Lds_c;
%save data
tmp_stats = SizingScripts.ADP2SizeMeta(ADP,'GFWT','MGT',1.5,Lds,time,isError,Cases,"Opt: A320 Wing Loading, A320 Volume Coeffs, A320 Engine");
res = dcrg.struct.concat(res,tmp_stats);

save('bin\UB320_JA1_b.mat')

%% notify me
util.notify('Complete','fintan.healy@bristol.ac.uk',"JA1 Baseline family Complete");