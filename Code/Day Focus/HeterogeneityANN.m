function [ net, tr ] = HeterogeneityANN(inputs, targets, randomSeed, hiddenLayerSize)
% Trains and returns a neural network for heterogeneity testing

rng(randomSeed);    % randomSeed can be set to 'default' if needed

% Fix NaNs
% inputs = fixunknowns(inputs);


%% Neural network - auto generated
x = inputs;
t = targets;

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Fitting Network
net = fitnet(hiddenLayerSize,trainFcn);

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
net.divideFcn = 'dividerand';  % Divide data. dividerand, divideint, divideblock
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 75/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 5/100;

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean Squared Error

% Train the Network
[net,tr] = train(net,x,t);


end

