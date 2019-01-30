%% Combinations_Analysis.m
% Nipun Gunawardena
% Plot results of combinations test, and explore data

clear all, close all, clc


%% Load data
load('CombinationStatisticsDefault.mat');


%% Plot
numC = length(combi);
medR2 = median(rSquared, 2);
meanR2 = mean(rSquared, 2);

figure()
subplot(3,1,1)
hold on
plot(1:numC, mmRmse, 'r');
plot(1:numC, stdRmse, 'b');
xlabel('Combination number');
ylabel('RMSE');
title('(a)');
legend('Min-Max', 'Std Dev');

subplot(3,1,2);
hold on
plot(1:numC, meanR2);
xlabel('Combination number');
ylabel('Mean R^2');
title('(b)');
ylim([0 1]);

subplot(3,1,3);
hold on
plot(1:numC, medR2);
xlabel('Combination number');
ylabel('Median R^2');
title('(c)');



print('ANN_Combo_1.eps', '-depsc');

figure()
[sortmm, sortmmIdx] = sort(mmRmse);
subplot(2,1,1);
plot(sortmm);
xlabel('Combination Number (Out of Order)');
ylabel('Min-Max RMSE');
subplot(2,1,2);
plot(sortmmIdx);
ylabel('Combination Number');
% disp(combiNums(sortmmIdx));




%% Filter bad measurements
x = 1:numC;
bad = mmRmse > 10;
badIdx = x(bad);
badCombi = combi(bad, :);
badNums = reshape(badCombi, [], 1);
disp(badCombi)

% Names
lemsNames = {'LEMS A', 'LEMS B', 'LEMS C', 'LEMS D', 'LEMS E', 'LEMS F', 'LEMS G', 'LEMS H', 'LEMS I', 'LEMS J', 'LEMS K', 'LEMS L'};

figure()
histogram(badNums, 12);

for i = 1:length(badCombi)
    disp(lemsNames(badCombi(i, :)));
end