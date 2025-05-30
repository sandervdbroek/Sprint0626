load('C:\git\Sprint0626\example_data\UB321_simple.mat')

%% update Hyper Paramters
ADP.AR = 12;
ADP.HingeEta = 0.8;
ADP.FlareAngle = 15;
ADP.ADR.M_c = 0.8;
ADP.SweepAngle = 25;

%% build the baff
ADP.BuildBaff();

%% run Jig Twist Sizing
ld = loads.NastranModel(ADP);
ld.BinFolder = 'bin_jig';
ld.GetLoads(cast.LoadCase.empty);

%% plot jig twist
f = fh.pubFig(Num=5,Size=[8,6],Layout=[1,1]);
plot(ADP.InterpEtas,-ADP.InterpTwists);
ylabel('Jig Twist [deg]')
xlabel('norm. wing pos')