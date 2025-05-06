
data = [];
files = dir('C:\Users\qe19391\OneDrive - University of Bristol\Bristol_Documents\Projects\TAH_RA_2023\Flight data\*.csv');
for i = 1:length(files)
    tmp = readtable(fullfile(files(i).folder,files(i).name));
    data = [data;tmp];
end
tt = data;
% d201906 = readtable("C:\Users\qe19391\OneDrive - University of Bristol\Bristol_Documents\Projects\TAH_RA_2023\Flight data\Flights_20190601_20190630.csv");
% d201912 = readtable("C:\Users\qe19391\OneDrive - University of Bristol\Bristol_Documents\Projects\TAH_RA_2023\Flight data\Flights_20191201_20191231.csv");
% d202106 = readtable("C:\Users\qe19391\OneDrive - University of Bristol\Bristol_Documents\Projects\TAH_RA_2023\Flight data\Flights_20210601_20210630.csv");

% data = zeros(3,2);

%% make plot
f = figure(1);clf;
f.Units = "centimeters";
f.Position = [25 5 10 6];
hold on;

% tt = [d201906; d201912;d202106];
idx_a319 = tt.ACType == "A319" & tt.STATFORMarketSegment ~= "Charter";
idx_a320 = tt.ACType == "A320" & tt.STATFORMarketSegment ~= "Charter";
idx_a321 = tt.ACType == "A321" & tt.STATFORMarketSegment ~= "Charter";
idx_a19N = tt.ACType == "A19N" & tt.STATFORMarketSegment ~= "Charter";
idx_a20N = tt.ACType == "A20N" & tt.STATFORMarketSegment ~= "Charter";
idx_a21N = tt.ACType == "A21N" & tt.STATFORMarketSegment ~= "Charter";
idx = idx_a319 | idx_a320 | idx_a321 | idx_a19N | idx_a20N | idx_a21N;
% idx = tt.ACType == "B38M" & tt.STATFORMarketSegment ~= "Charter";
A320neo = tt(idx,:);
A320neo = flipud(sortrows(A320neo,'ActualDistanceFlown_nm_'));
save('A320neo.mat',"A320neo");


%% generate histogram
clf;
A320neo = A320neo(A320neo.ActualDistanceFlown_nm_<10000,:);
distFlown = A320neo.ActualDistanceFlown_nm_*1/cast.SI.Nmile/1e3;
h1 =histogram(distFlown,0:50:8000);
% h1.Normalization = "pdf";
h1.FaceAlpha = 0.25;
h1.DisplayName = 'Number of Flights';
h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
% h1.DisplayName = '06-2019';
[mean(distFlown),median(distFlown)]

% rs = [r1;r2;r3];
xs = 0:10:3500;
% pd = fitdist(A320neo.ActualDistanceFlown_nm_,'Lognormal');
% y = pdf(pd,xs);
% plot(xs,y,'DisplayName','LogNormal Dist.');
% plot(xs,vals)


% h1.Values = h1.Values./max(h1.Values);

lg = legend();
lg.Location = "southeast";
ylabel('PDF')
ax = gca;
ax.FontSize = 10;
ylabel('Number of Flights')



yyaxis right

% 
c = fh.colors.colorspecer(3,"qual","HighCon");
% plot([0 2720 3645 4420],[17.75 17.75 14 0],'-o',DisplayName='A319',Color=cs(1,:),LineWidth=1.5,MarkerFaceColor='w')
plot([0 2450 3417 4295]*1/cast.SI.Nmile/1e3,[19.3 19.3 15.12 0],'-s',DisplayName='A320',Color='r',LineWidth=1,MarkerFaceColor='w')
% plot([0 2500 2690 3750],[25 25 24.3 0],'-d',DisplayName='A321',Color=cs(3,:),LineWidth=1.5,MarkerFaceColor='w')

% plot([0,2456,4005,4773],[18.6,18.6,12.2,0],'r--',Color=c(2,:),LineWidth=1.5,DisplayName='A320-WV051 (1 ACT)')
p = plot([2450 2450]*1/cast.SI.Nmile/1e3,[0 25],'k-','Color',[1 1 1]*0.6);
p.Annotation.LegendInformation.IconDisplayStyle = "off"; 
xlabel('Range [Nautical miles]')
ylabel('Payload [Tonnes]')
xlim([0 5000])
xticks([0 2000 3000 4500 6000])
% title('A320Neo Scheduled flights by distance (EU airspace)')
ax = gca;
ax.FontSize = 10;

copygraphics(gcf);

%% save data
ranges = (h1.BinEdges(2:end)+h1.BinEdges(1:end-1))/2;
flights = h1.Values;
save('flightData.mat',"ranges","flights")