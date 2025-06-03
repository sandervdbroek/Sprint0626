

fuel_price = 0.64995; % USD/kg
oil_price = 30.0; % USD/kg
range_mission = 3000./(cast.SI.Nmile*1000); % range of mission [km]
N_pax = 140; % Number of passengers
N_eng = 2; % Number of engines

%% ========================= Set Hyper-parameters =========================
% nSamplesvec = [100, 250, 500, 1000, 2500 10000];
nSamplesvec = [1 3 5];
inputScaled = lhsdesign(nSamples,5);
% type = 'test';
types = {'train','test'};
for i = 1:length(nSamples)
    for j = 1:2
        nSamples = nSamplesvec(i);
        type = types{j};
        if strcmp(type,'test')
            inputScaled = rand(nSamples,5);
        else
            inputScaled = lhsdesign(nSamples,5);
        end
        inputs = [12 22; ... %AR
            0.5 1; ... %Norm SAH pos
            5 35;... % SAH Flare angle
            0.5 0.85;... % Cruise speed (mach)
            0 40]; %Qtr-Chord sweep angle
        inScale = inputs(:,1)-inputs(:,2);
        inputUnscaled = inputScaled*diag(inScale)+ones(size(inputScaled))*diag(inputs(:,2));

        printoutput = false;
        saveMat = false;

        outArray = zeros(nSamples,4);
        tic
        parfor i = 1:nSamples
            try
                sampleOut = sizeSample(inputUnscaled(i,:),saveMat,printoutput);
                outArray(i,:) = sampleOut;
            catch ME
                % Store error message and identifier
                errors{i} = struct('index', i, 'message', ME.message, 'identifier', ME.identifier);
                fprintf('Error in sample %d: %s\n', i, ME.message);

            end
        end
        toc
        if strcmp(type,'test')
            TrainingSet = [inputUnscaled outArray];
            filename = ['Testset_' num2str(nSamples) '.mat'];
            save(filename, 'TrainingSet');

            % Save as .csv
            filename_csv = ['Testset_' num2str(nSamples) '.csv'];
            writematrix(TrainingSet, filename_csv);  % Use csvwrite if using older MATLAB
        else
            TrainingSet = [inputUnscaled outArray];
            filename = ['Trainingset_' num2str(nSamples) '.mat'];
            save(filename, 'TrainingSet');

            % Save as .csv
            filename_csv = ['Trainingset_' num2str(nSamples) '.csv'];
            writematrix(TrainingSet, filename_csv);  % Use csvwrite if using older MATLAB
        end

    end
end