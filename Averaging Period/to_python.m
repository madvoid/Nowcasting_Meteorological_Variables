%% to_python.m
% Nipun Gunawardena
% convert data for use in python

clear all, close all, clc


%% Load data
load('LEMS_Avg_Latest.mat')


%% Convert dates
datesstrings = datestr(dates);
csvwrite('dates.csv', datesstrings);


%% Convert data
for i = 1:numFiles
    lname = lemsNames(i);
    lmat = lemsAvgData{i};
    writetable(lmat, char(strcat(lname, '.csv')))
end