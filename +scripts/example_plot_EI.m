load('C:\git\Sprint0626\example_data\UB321_simple.mat')
ADP.BuildBaff();

% extract correct wing elements (could do something clever with name lookup...)
if ADP.HingeEta==1
    Wings = ADP.Baff.Wing(2);
else
    Wings = ADP.Baff.Wing(2:3);
end


f = figure(1);
clf;

% get number of beam stations on each wing
Ns = arrayfun(@(x)length(x.Stations),Wings);
% preallocate global pos and EI
Xs = zeros(3,sum(Ns));
EI = zeros(1,sum(Ns));
% get idx fro each wing to fill
idx = [1,cumsum(Ns)];
idx = sort([idx(1),idx(2:end-1),idx(2:end-1)+1,idx(end)]);
idx = reshape(idx,2,[])';
%iterate over wings
for i = 1:length(Wings)
    Xs(:,idx(i,1):idx(i,2)) = Wings(i).GetGlobalPos([Wings(i).Stations.Eta],[0;0;0]);
    EI(idx(i,1):idx(i,2)) = Wings(i).Stations(1).Mat.E .* arrayfun(@(x)x.I(2,2),Wings(i).Stations);
end


% plot distribution
plot(abs(Xs(2,:)),EI)
xlabel('span [m]')
ylabel('EI')
grid on