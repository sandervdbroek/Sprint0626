load('example_data\A220_simple.mat')

%% update Hyper Paramters
ADP.AR = 12;
ADP.HingeEta = 0.8;
ADP.FlareAngle = 15;
ADP.ADR.M_c = 0.8;
ADP.SweepAngle = 25;

%% build the baff
ADP.BuildBaff();

%% run gusts
ld = loads.NastranModel(ADP);
lc = cast.LoadCase.Gust(ADP.ADR.M_c,ADP.ADR.Alt_cruise.*cast.SI.ft);
ld.SetConfiguration(IsLocked=true);
[Lds,BinFolder] = ld.GustLoads(lc,1);

%% plot gust loads
% h5 = mni.result.hdf5(fullfile(BinFolder,'bin','sol146.h5'));
% get time series from gusts from wing root element
EIDs = [ld.fe.Beams([ld.fe.Beams.Tag] == ld.Tags{2}(1)).ID];
gusts = ld.ExtractDynamicLoadsTimeSeries(fullfile(BinFolder,'bin','sol146.h5'),ld.Tags(2),1);

f = fh.pubFig(Num=5,Size=[8,7],Layout=[1,1]);

for i = 2:2:12
    plot(gusts{1}(i).t,gusts{1}(i).My)
end
xlabel('time [s]')
ylabel('Wing root Bending Moment [Nm]')
title('WRBM over multiple gust lengths')








