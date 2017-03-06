% To be run INSTEAD of init.m under RF_2017
% Please run this script under the root folder

clearvars -except N;
close all;

% Add our own folders to path
addpath('./res');
addpath('./lib/RF_2017/internal');

% initialise external libraries
run('lib/RF_2017/external/vlfeat-0.9.18/toolbox/vl_setup.m'); % vlfeat library
cd('lib/RF_2017/external/libsvm-3.18/matlab'); % libsvm library
run('make');
cd('../../../../..');

% tested on Ubuntu 12.04, 64-bit, Intel® Core�?i7-3820 CPU @ 3.60GHz × 8 