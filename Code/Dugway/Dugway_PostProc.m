%% Dugway_PostProc.m
% Nipun Gunawardena
% Post process Dugway ANN output

clear all, close all, clc


%% Load Data
load('DugwayANNOut.mat');


%% Plot
figure()
hold on
plot(datesTest, mmOut, 'b:', 'LineWidth', 2);
plot(datesTest, mmTarg, 'r-');
plot(datesTest, stdOut, 'm:', 'LineWidth', 2);
plot(datesTest, stdTarg, 'k-');
legend('Min - Max output','Min - Max Target','StdDev Output','StdDev Target');
dynamicDateTicks(); 
xlabel('Date');
ylabel('Relative Humidity (%)');

figure()
