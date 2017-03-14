%% Preamble
clear;
close all;

% addpaths
% Mike, remove whatever you don't need. This script only needs the trees
% functions.
addpath('RF_2017/internal');
addpath('RF_2017/external');
addpath('RF_2017/external/libsvm-3.18/matlab');


% Load data
load('testing_hist.mat');
load('training_hist.mat');

k_params = [64, 128, 256, 512];
tree_params = [1,2,4,6,8];
d_params = 2:2:10;
split_params = [2, 5, 10, 25];
numDone = 0;
numTotal = length(k_params) * length(tree_params) * length(d_params) ...
           * length(split_params);

% Write headers into CSV
% Create the output csv file
res_path = get_res_path();
csv_path = strjoin({res_path 'q32_results.csv'}, filesep);

handle = fopen(csv_path, 'w');
headings = ['k,Number of Trees,Depth,Rho,Classification Accuracy,'...
            'Train Time,Test Time', sprintf('\n')];
fwrite(handle, headings);
fclose(handle);

for k=k_params
    for t=tree_params
        for d=d_params
            for s=split_params

%% Training data, takes data, makes it usable.

                classes = 10;
                perclass = 15;
                data_trees_train = zeros(classes * perclass, k + 1);
                data_idx = 1;
                for class_idx = 1:classes
                    for image_idx = 1:perclass
                        if k==64
                            histogram_output = histogram_output_train64(class_idx, image_idx, :);
                        elseif k==128
                            histogram_output = histogram_output_train128(class_idx, image_idx, :);
                        elseif k==256
                            histogram_output = histogram_output_train256(class_idx, image_idx, :);
                        else
                            histogram_output = histogram_output_train512(class_idx, image_idx, :);
                        end
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
                        if k==64
                            histogram_output = histogram_testing64(class_idx, image_idx, :);
                        elseif k==128
                            histogram_output = histogram_testing128(class_idx, image_idx, :);
                        elseif k==256
                            histogram_output = histogram_testing256(class_idx, image_idx, :);
                        else
                            histogram_output = histogram_testing512(class_idx, image_idx, :);
                        end
                        % Change 256 to 64, 128, 512.
                        data_trees_test(data_idx, 1:k) = permute( histogram_output, [1 3 2]);
                        data_idx = data_idx + 1;
                    end
                end

                %% Grow Trees

                % Set the random forest parameters

                param.num = t;         % Number of trees
                param.depth = d;        % trees depth
                param.splitNum = 50;     % Number of split functions to try
                param.split = 'IG';     % Currently support 'information gain' only

                tic();
                trees = growTrees(data_trees_train, param);
                train_time = toc();

                %% Testing
                tic();
                for n=1:size(data_trees_test,1)
                    try
                        leaves = testTrees(data_trees_test(n,:), trees);
                        p_rf = trees(1).prob(leaves,:);
                        p_rf_sum = sum(p_rf)/length(trees);
                        [~, guess] = max(p_rf_sum);
                        data_trees_test(n, k+1) = guess;
                    catch
                    end
                end
                test_time = toc();

                %% Confusion matrix. 
                % Save the image file (edit title) and outputs.
                [indices, class_actual, class_guesses, percentage] = results(data_trees_test(:, k+1), data_trees_train(:, k+1), 'Title', 'filename');

                % Save to csv
                handle = fopen(csv_path, 'a');
                csv_data = [num2str(k), ',', num2str(t), ',', ...
                            num2str(d), ',', num2str(s), ',', ...
                            num2str(percentage), ',', ...
                            num2str(train_time), ',', ...
                            num2str(test_time), ...
                            sprintf('\n')];
                fwrite(handle, csv_data);
                fclose(handle);

                % Display progress to user
                numDone = numDone + 1;
                disp([num2str(numDone), '/', num2str(numTotal), '=', ...
                      num2str(100*numDone/numTotal), '% tests completed.']);
            end
        end
    end
end