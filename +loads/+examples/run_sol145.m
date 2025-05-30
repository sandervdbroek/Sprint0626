load('C:\git\Sprint0626\example_data\UB321_simple.mat')

%% update Hyper Paramters
ADP.AR = 12;
ADP.HingeEta = 0.8;
ADP.FlareAngle = 15;
ADP.ADR.M_c = 0.8;
ADP.SweepAngle = 25;

%% build the baff
ADP.BuildBaff();

%% run flutter (ISO-Mach)
ld = loads.NastranModel(ADP);
ld.BinFolder = 'bin_flut';
Mach = 0.8*1.15;
[res,BinFolder] = ld.Flutter(Mach,IsLocked = false);

%% plot flutter
f = fh.pubFig(Num=5,Size=[8,10],Layout=[2,1]);
nexttile(1);
ads.nast.plot.flutter(res,XAxis='CAS',YAxis='F',NModes=30)
xlabel('Velocity [m/s]')
ylabel('Frequency [Hz]')
ylim([0 20])
nexttile(2);
ads.nast.plot.flutter(res,XAxis='CAS',YAxis='D',NModes=30)
xlabel('Velocity [m/s]')
ylabel('G')
ylim([-0.2,0.2])

copygraphics(gcf)









