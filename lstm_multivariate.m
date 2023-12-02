clc;clearvars;
%% Load data 
load gdas2020(tasikkenyir).mat

%% Filter data based on altitude
for i = 1:size(ExtractedGdas.Fields3D,2)
    variable.(string(ExtractedGdas.Fields3D.Properties.VariableNames(i))) = ExtractedGdas.Fields3D.(i)(ExtractedGdas.Fields3D.HGTS<160,:);
end

%% UTC and cyclic data - Add variable UTC days into "variable"
FirstDay= ExtractedGdas.Fields3D.UTC(1);
variable.UTCdays = days(variable.UTC - FirstDay);
variable.sindays = sin(2.*pi.*(variable.UTCdays)/365.0);
variable.cosdays = cos(2.*pi.*(variable.UTCdays)/365.0);

%% Insert Data
slctvr = questdlg('Select variable to predict', ...
	'Variable', ...
	'Temperature','Wind Direction','Humidity','');

switch slctvr
    case 'Temperature'
        vr = smoothdata(variable.TEMP);
    case 'Wind Direction'
        vr = smoothdata(variable.WDIR);
    case 'Humidity'
        vr = smoothdata(variable.RELH);
end

Data = [variable.cosdays,variable.sindays,vr];

%% Data standaradization
[StandardizedData, PS] = mapminmax(Data');
StandardizedData = StandardizedData';

%% Window division
windowSize = 30;
forecast = windowSize-1;

InputData = {};
OutputData = {};
for i = 1:(height(StandardizedData)-windowSize-forecast-1)
    inputSequence = StandardizedData(i:i+windowSize-1,:);
    outputValue = StandardizedData(windowSize+i:i+windowSize+forecast,end);
    InputData{end+1} = inputSequence';
    OutputData{end+1} = outputValue';
end

% seq2one
% OutputData = cell2mat(OutputData);

%% Divide Data Train and Data Test

answer = questdlg('How do you like to arrange the input data?', ...
	'Training Data and Testing Data', ...
	'In Sequence','Randomly','');

switch answer
    case 'In Sequence'
        Row = numel(InputData);
        numObservation = Row ;
        idxTrain = 1:floor(0.8*numObservation);
        idxVal = floor(0.8*numObservation)+1:floor(0.9*numObservation);
        idxTest = floor(0.9*numObservation)+1:numObservation;
    case 'Randomly'
        numObservation = numel(InputData) ;
        [idxTrain,idxVal,idxTest] = dividerand(numObservation,0.8,0.1,0.1);
end

Xtrain = InputData(idxTrain);
Ytrain = OutputData(idxTrain);

Xval = InputData(idxVal);
Yval = OutputData(idxVal);

Xtest = InputData(idxTest);
Ytest = OutputData(idxTest);

for j= 1:numel(idxTest)
    idxPlotTest{j} = idxTest(j):idxTest(j)+windowSize-1;
end

%% Create a layer
layer = [sequenceInputLayer(size(Xtrain{1},1)),...
    convolution1dLayer(1,64),...
    reluLayer,....
    bilstmLayer(900, 'OutputMode', 'sequence'),...
    fullyConnectedLayer(600),...
    dropoutLayer(0.2),...
    fullyConnectedLayer(size(Ytrain{1},1)),...
    regressionLayer];

options= trainingOptions("adam", ...
    MaxEpochs=500, ...
    InitialLearnRate=0.001, ...
    GradientThreshold=1, ...
    ExecutionEnvironment="gpu", ...
    Plots="training-progress", ...
    MiniBatchSize=256, ...
    LearnRateSchedule="piecewise", ...
    ValidationData={Xval.',Yval.'}, ...
    ValidationFrequency=50, ...
    ValidationPatience=70, ...
    OutputNetwork="best-validation-loss", ...
    Shuffle="every-epoch");

%% Training Data
net = trainNetwork(Xtrain.',Ytrain.',layer,options);

%% Predict Data 
net = resetState(net);
[net,Ypred] = predictAndUpdateState(net,Xtest(1));

%% Predict Data using the first predict data
net = resetState(net);

for i =1:numel(Xtest)
        [net,Ypred(:,i)] = predictAndUpdateState(net,Xtest(i));
end

%% Unstandardize Data predict and Unstadardize Data test
Ypredn = mapminmax('reverse',Ypred,PS);
Ytestn = mapminmax('reverse',Ytest,PS);

for i = 1:numel(Ypred)
    Ypredn{i} = Ypredn{i}(end,:);
    Ytestn{i} = Ytestn{i}(end,:);
end
%% Calculate rmse, MAPE, MAE and CC
clearvars RMSE

%seq2one error analysis
% RMSE = rmse(Ypredn,Ytestn);
% MAPE = mape(Ypredn,Ytestn);
% Rsquare = corrcoef(Ypredn,Ytestn);
% Rsquare = Rsquare(1,2);

%seq2seq error analysis
for r = 1:numel(Ypredn)
    RMSE(r) = rmse(Ypredn{r},Ytestn{r});
    MAPE(r) = mape(Ypredn{r},Ytestn{r});
    RCell = cellfun(@(x, y) corrcoef(x, y), Ypredn, Ytestn, UniformOutput = false);
    RSquare = cellfun(@(x) x(1, 2)^2, RCell);
end

meanRMSE = mean(RMSE);
meanMAPE = mean(MAPE);
meanRSquare = mean(RSquare);
%% Plot forecast
gambo = questdlg('How do you like to present the data?', ...
	'Data Visualization', ...
	'Static','Moving frame','');
figure(Name="Prediction vs Actual")
switch gambo
    case 'Static'
        rowcol = inputdlg({'Insert Row','Insert Column'},...
              'Tilledlayout'); 
        row = str2num(rowcol{1});
        col = str2num(rowcol{2});
        tiledlayout(row,col);
        for i = 1:(row*col)
            nexttile
            plot(windowSize+i:i+windowSize+forecast,Ytestn{i},LineWidth=2)
            hold on
            plot(windowSize+i:i+windowSize+forecast,Ypredn{i},LineWidth=2)
            title("Observation from "+(windowSize+i)+" until "+(i+windowSize+forecast),"RMSE = " +RMSE(i)+" R^2 = "+RSquare(i));
            xlabel("Timesteps");
            ylabel("Temperatrue");
            legend(["Actual" "Predict"])
            xlim([windowSize+i,i+windowSize+forecast])
        end
    case 'Moving frame'
        for i = 1:numel(Ypredn)
            plot(idxPlotTest{i},Ytestn{i},LineWidth=2)
            hold on
            plot(idxPlotTest{i},Ypredn{i},LineWidth=2)
            title("Observation from "+(min(idxPlotTest{i}))+" until "+(max(idxPlotTest{i})),"RMSE = " +RMSE(i)+" R^2 = "+RSquare(i));
            xlabel("Timesteps");
            ylabel("Temperatrue");
            legend(["Actual" "Predict"])
            xlim([min(idxPlotTest{i}),max(idxPlotTest{i})])
            pause(0.6);
            hold off
        end
end

%% Error plotting 
figure(Name="RMSE")
histogram(RMSE);
xlabel("Error");
ylabel("Frequency");
title("Error Analysis RMSE , Mean RMSE =" +meanRMSE);

figure(Name="MAPE")
histogram(MAPE);
xlabel("Error");
ylabel("Frequency");
title("Error Analysis MAPE , Mean MAPE =" +meanMAPE);

%% Forecast random data 
randomday = variable.UTCdays(variable.UTCdays<20);
ransindays = sin(2.*pi.*(randomday(:,1))/365.0);
rancosdays = cos(2.*pi.*(randomday(:,1))/365.0);
ranheight = repmat(80,numel(rancosdays),1);%randi(150,144,1);
rantemp = variable.TEMP(randi(floor(max(variable.TEMP)),numel(ranheight),1),:);
RanData = [rancosdays,ransindays,rantemp];
% ranheight,
[StandardizedRanData, PS2] = mapminmax(RanData');
StandardizedRanData = {StandardizedRanData};
[newnet,TestOlokOlok] = predictAndUpdateState(net,StandardizedRanData);
TestOlokOlokn = mapminmax('reverse',TestOlokOlok,PS2);
TestOlokOlokn = TestOlokOlokn{1}(end,:);

figure(Name="Try boh")
plot(1:height(variable.TEMP),smoothdata(variable.TEMP),LineWidth=2)
hold on 
plot(height(variable.TEMP)+1:height(variable.TEMP)+numel(TestOlokOlokn),TestOlokOlokn,LineWidth=2);
xlabel("Time Steps");
ylabel("Temperature");
title("Forecast Analysis");
legend(["Actual" "Forecast"])
hold off

figure(Name="Try boh2") 
plot(TestOlokOlokn,LineWidth=2);
xlabel("Time Steps");
ylabel("Temperature");
title("Forecast Analysis");