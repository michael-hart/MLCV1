%% Preamble
clear;
close all;

% addpaths
% Mike, remove whatever you don't need. This script only needs the trees
% functions.
addpath('../rf2017/internal');
addpath('../rf2017/external');
addpath('../rf2017/external/libsvm-3.18/matlab');


% Load data
load('testing_hist.mat');
load('training_hist.mat');

%% Training data, takes data, makes it usable.
% Change this K when needed.
k = 256;
classes = 10;
perclass = 15;
data_trees_train = zeros(classes * perclass, k + 1);
data_idx = 1;
for class_idx = 1:classes
    for image_idx = 1:perclass
        histogram_output = histogram_output_train256(class_idx, image_idx, :);
        % Change 256 to 64, 128, 512.
        data_trees_train(data_idx, 1:k) = permute( histogram_output, [1 3 2]);
        data_trees_train(data_idx, k+1) = class_idx;
        data_idx = data_idx + 1;
    end
end

%% Test data
data_trees_test = zeros(classes * perclass, k+1);
data_idx = 1;
for class_idx = 1:classes
    for image_idx = 1:perclass
        histogram_output = histogram_testing256(class_idx, image_idx, :);
        % Change 256 to 64, 128, 512.
        data_trees_test(data_idx, 1:k) = permute( histogram_output, [1 3 2]);
        data_idx = data_idx + 1;
    end
end

%% Grow Trees

% Set the random forest parameters

param.num = 3;         % Number of trees
param.depth = 13;        % trees depth
param.splitNum = 50;     % Number of split functions to try
param.split = 'IG';     % Currently support 'information gain' only
param.split_func = 'axis-aligned';

trees = growTrees(data_trees_train, param);

%% Testing
for n=1:size(data_trees_test,1)
    leaves = testTrees(data_trees_test(n,:), trees);
    p_rf = trees(1).prob(leaves,:);
    p_rf_sum = sum(p_rf)/length(trees);
    [~, guess] = max(p_rf_sum);
    data_trees_test(n, k+1) = guess;
end

%% Confusion matrix. 
% Save the image file (edit title) and outputs.
[indices, class_actual, class_guesses, percentage] = results(data_trees_test(:, k+1), data_trees_train(:, k+1), 'Title', 'filename');
