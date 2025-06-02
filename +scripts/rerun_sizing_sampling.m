

fuel_price = 0.64995; % USD/kg
oil_price = 30.0; % USD/kg
range_mission = 3000./(cast.SI.Nmile*1000); % range of mission [km]
N_pax = 140; % Number of passengers
N_eng = 2; % Number of engines

%% ========================= Set Hyper-parameters =========================
nSamples = 100;
inputScaled = lhsdesign(nSamples,5);
inputs = [8 22; ... %AR
    0.5 1; ... %Norm SAH pos
    5 35;... % SAH Flare angle
    0.5 0.85;... % Cruise speed (mach)
    0 40]; %Qtr-Chord sweep angle
inScale = inputs(:,1)-inputs(:,2);
inputUnscaled = inputScaled*diag(inScale)+ones(size(inputScaled))*diag(inputs(:,2));

printoutput = false;
saveMat = false;

outArray = zeros(nSamples,2);
parfor i = 1:nSamples
    sampleOut = sizeSample(inputUnscaled(i,:),saveMat,printoutput);
    outArray(i,:) = sampleOut;
end

TrainingSet = [inputUnscaled outArray];
filename = ['Trainingset_' num2str(nSamples) '.mat'];
save(filename, 'TrainingSet');

% Save as .csv
filename_csv = ['Trainingset_' num2str(nSamples) '.csv'];
writematrix(TrainingSet, filename_csv);  % Use csvwrite if using older MATLAB

