%% Preamble
clear;
close all;

% addpaths
addpath('../rf2017/internal');
addpath('../rf2017/external');
addpath('../rf2017/external/libsvm-3.18/matlab');

% Load data
load('q3.mat');
load('testing_hist.mat');
load('training_hist.mat');