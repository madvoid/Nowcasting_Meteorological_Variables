%% Hidden_Node_Combined_Plot.m
% Nipun Gunawardena
% Plot hidden nodes for all variables 

clear all, close all, clc


%% Load Data
load('../LEMS_Avg_Latest.mat');
files = {'Hidden_Nodes_specHum.mat','Hidden_Nodes_thetaV.mat','Hidden_Nodes_windU.mat','Hidden_Nodes_windV.mat'};
labs = {'q', '\theta_v', 'U', 'V'};
numVars = length(files);
load(files{1});
numNodes = length(nodeRes);
rmseArr = zeros(numNodes, numVars);
for i = 1:numVars
    load(files{i})
    rmseArr(:, i) = nodeRes;
end


%% Calculate specific humidity
eso = 6.11;         % hPa - Reference saturation vapor pressure
lv = 2.5e6;         % (J/kg) - Latent heat of vaporization of water
Rv = 461.5;         % (J*K)/kg - Gas constant for water vapor
T0 = 273.15;        % K - Reference temperature
for i = 1:numFiles
    T = lemsAvgData{i}.SHT_Amb_C + 273.15;  % Convert to K
    P = lemsAvgData{i}.Pressure / 100;      % Convert to hPa
    RH = lemsAvgData{i}.SHT_Hum_Pct;        % percentage, no conversion
    es = eso * exp( (lv/Rv) * (1/T0 - 1./T) );  % Saturated vapor pressure
    e = (RH / 100) .* es;                   % Vapor pressure
    lemsAvgData{i}.specHum = 0.622 * (e./P);            % Specific humidity
    
    % Clean
    lemsAvgData{i}.specHum(lemsAvgData{i}.specHum > 0.2) = NaN;
end


%% Normalize all RMSE values
% Wasn't done during hidden node analysis, should have
% LEMS E is target so get range of those values
rangeArr = zeros(1, numVars);
rangeArr(1) = range(lemsAvgData{5}.specHum(:));
rangeArr(2) = range(lemsAvgData{5}.thetaV(:));
rangeArr(3) = range(lemsAvgData{5}.windU(:));
rangeArr(4) = range(lemsAvgData{5}.windV(:));
nrmseArr = rmseArr ./ rangeArr;


%% Plot
fig1 = figure();
set(fig1, 'Units', 'normalized', 'Position', [0,0,1,1]);
plot(nrmseArr, 'o-');
xlabel('Number of Nodes');
ylabel('Normalized RMSE');
legend(labs);
print('ANN_Hidden_Nodes_Combined', '-depsc');