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