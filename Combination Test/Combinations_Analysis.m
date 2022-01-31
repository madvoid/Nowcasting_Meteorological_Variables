%% Combinations_Analysis.m
% Nipun Gunawardena
% Plot results of combinations test, and explore data

clear all, close all, clc


%% Load data
load('CombinationMLR.mat');


% Minimimum is at 
% [c, i] = min(meanR2)
% i is 177
% combi(i, :) is [5, 8, 10]
% Which should correspond to
% LEMS E, H, J

% LEMS I, J, K is combi number 217

%% Plot
numC = 1:length(combi);
meanR2 = mean(rSquared, 2);
minR2 = min(rSquared');
maxR2 = max(rSquared');
X = [numC, fliplr(numC)];
Y = [minR2, fliplr(maxR2)];

figure()
hold on
fill(X, Y, [0 0.4470 0.7410], 'FaceAlpha', 0.25, 'EdgeAlpha', 0.25)
plot(numC, meanR2);
plot([217, 217], [0.75, 1], 'k--')
xlim([0 length(combi)]);
ylim([0.75, 1.0]);
lgd = legend('Range', 'Mean', 'LEMS I, J, K');
lgd.Location = 'SouthWest';
xlabel('Combination Number');
ylabel('R^2');
print('MLR_Combination.eps', '-depsc');
% plot(numC, meanR2)
% errorbar(numC, meanR2, minR2, maxR2)