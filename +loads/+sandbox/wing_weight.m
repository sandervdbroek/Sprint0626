

%% ========================= Set Hyper-parameters =========================
load('C:\git\Sprint0626\example_data\UB321_simple.mat')
ADP.AR = 12;
ADP.HingeEta = 0.8;
ADP.FlareAngle = 15;
ADP.ADR.M_c = 0.8;
ADP.SweepAngle = 25;
ADP.BuildBaff;

ADP.MTOM


%% ============================ Run Load Case =============================
% set aircraft configuration
ld = loads.EnforcedLiftDist(ADP);
ld.SetConfiguration();
% ld.CleanUp = false;

% make a manouvre load case (see LoadCaseFactory)
M = 0.75;
Alt = 32000; %ft
Load_factor = 1; %G
LoadCase = cast.LoadCase.Manoeuvre(M,Alt,Load_factor,SafetyFactor=1);

% run analysis (assumes nastran 2023 or later)
Lds = ld.StaticLoads(LoadCase,1);






% % plot Bending Moment
% f = figure(1);
% clf;
% grid on
% Lds.plot("My",ADP.WingBoxParams);
% 
% % plot deflecton (you can pan the figure by clicking and dragging the mouse)
% ads.nast.plot.sol144(BinFolder);