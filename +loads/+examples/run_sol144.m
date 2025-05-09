load('C:\git\Sprint0626\example_data\UB321_simple.mat')

% rebuild baff
ADP.BuildBaff();

% set aircraft configuration
ld = loads.NastranModel(ADP);
ld.SetConfiguration();
ld.CleanUp = false;

% make a manouvre load case (see LoadCaseFactory)
M = 0.75;
Alt = 32000; %ft
Load_factor = 2.5; %G
LoadCase = cast.LoadCase.Manoeuvre(M,Alt,2.5,SafetyFactor=1);

% run analysis (assumes nastran 2023 or later)
[Lds,BinFolder] = ld.StaticLoads(LoadCase,1);

% plot Bending Moment
f = figure(1);
clf;
grid on
Lds.plot("My",ADP.WingBoxParams);

% plot deflecton (you can pan the figure by clicking and dragging the mouse)
ads.nast.plot.sol144(BinFolder);









