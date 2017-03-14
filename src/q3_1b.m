%% Preamble
clear;
close all;

% addpaths
addpath('../rf2017/internal');
addpath('../rf2017/external');
addpath('../rf2017/external/libsvm-3.18/matlab');

% Data creation
[data_train, sift_features, data_test, train_index_output, test_index_output]...
    = getCalTechData();
% 10 Classes, 15 each class.
save('q3.mat', 'data_train', 'sift_features', 'data_test', 'train_index_output', 'test_index_output');

%% Codebook creation
% Size of vocabulary, each centroid is one codeword. To be varied.
k = [64, 128, 256, 512];

% 128 rows of 1000000 columns. i.e. 128 pixels per sample, 100 000 descriptors

for kidx = k
    tic;
    % K-means, requires n samples (rows) of p dimensions (columns)
    [centroids, ~] = vl_kmeans(sift_features, kidx, 'verbose', 'distance', 'l2', 'algorithm', 'ann');
    time_taken = toc;
    
    %Vector Quantisation
    histogram_output = vec_quant(centroids, data_train);
    
    % Save Data
    filename = strcat('kmeans', num2str(kidx));
    save(filename, 'centroids', 'histogram_output', 'time_taken');
end

%% Preamble
clear;
close all;

% addpaths
addpath('../rf2017/internal');
addpath('../rf2017/external');
addpath('../rf2017/external/libsvm-3.18/matlab');

% Load data
load('q3.mat');
load('kmeans64.mat');
centroids64 = centroids;
time_taken64 = time_taken;
load('kmeans128.mat');
centroids128 = centroids;
time_taken128 = time_taken;
load('kmeans256.mat');
centroids256 = centroids;
time_taken256 = time_taken;
load('kmeans512.mat');
centroids512 = centroids;
time_taken512 = time_taken;
clear centroids histogram_output time_taken;

%% Training Histogram Generation
histogram_output_train64 = vec_quant(centroids64, data_train);
histogram_output_train128 = vec_quant(centroids128, data_train);
histogram_output_train256 = vec_quant(centroids256, data_train);
histogram_output_train512 = vec_quant(centroids512, data_train);

%% Testing Histogram Generation
histogram_testing64 = vec_quant(centroids64, data_test);
histogram_testing128 = vec_quant(centroids128, data_test);
histogram_testing256 = vec_quant(centroids256, data_test);
histogram_testing512 = vec_quant(centroids512, data_test);


%% Get codewords example picture
picture = zeros(8*8, 8*16);
for index2 = 1:8
    outer = index2 - 1;
    start2 = 8*(index2-1)+1;
    for index = 1:8
        disp(8 * outer+index);
        mini = vec2mat(centroids64(:, (8 * outer)+index), 16);
        start = 16*(index-1)+1;
        picture(start2:start2+7, start:start+15) = mini;
    end
end

imshow(mat2gray(picture), 'InitialMagnification', 500)

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

%%

histogram_meng(histogram_output_train256(1,1,:), 'tick3_256', 'Tick 3 Histogram, 256 Codewords', 256);
histogram_meng(histogram_output_train256(1,2,:), 'tick39_256', 'Tick 39 Histogram, 256 Codewords', 256);
histogram_meng(histogram_testing256(1,1,:), 'tick24_256', 'Tick 24 Histogram, 256 Codewords', 256);
histogram_meng(histogram_output_train256(4,1,:), 'watch83_256', 'Watch 83 Histogram, 256 Codewords', 256);
histogram_meng(histogram_output_train256(7,1,:), 'willdcat23_256', 'Wildcat 23 Histogram, 256 Codewords', 256);
histogram_meng(histogram_output_train256(10,1,:), 'yy58_256', 'Yin-Yang 58 Histogram, 256 Codewords', 256);
histogram_meng(histogram_output_train64(1,1,:), 'tick3_64', 'Tick 3 Histogram, 64 Codewords', 64);
histogram_meng(histogram_output_train128(1,1,:), 'tick3_128', 'Tick 3 Histogram, 128 Codewords', 128);
histogram_meng(histogram_output_train512(1,1,:), 'tick3_512', 'Tick 3 Histogram, 512 Codewords', 512);

