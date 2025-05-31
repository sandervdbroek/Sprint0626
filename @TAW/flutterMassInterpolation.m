function [masses, eta, massId, isInnerWing] = flutterMassInterpolation(obj)
    
%required hyper parameters....
AR_req = obj.AR;
HingeEta_req = obj.HingeEta;
FlareAngle_req = obj.FlareAngle;
M_c_req = obj.ADR.M_c;
sweep_req = obj.SweepAngle;

%saved data......
Dat = open('flutterMasses.mat');
data = Dat.data;

%take these out and pass as they are.....
massId = data.massId;
eta = data.eta;
isInnerWing = data.isInnerWing;


%% INTERPOLATION 

%the below are data for interpolation....
HP_data = data.HPs; %values 
HP_id = data.HP_id; %this should clarify what's in HP_data

%for now pass some zero masses... 
masses = zeros(length(eta),1);

%NOTE: ONLY MASSES ARE TO BE INTERPOLATED!!!!!

end