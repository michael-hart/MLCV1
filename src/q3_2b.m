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
% Set the random forest parameters
param.num = 5;         % Number of trees
param.depth = 8;        % trees depth
param.splitNum = 50;     % Number of split functions to try
param.split = 'IG';     % Currently support 'information gain' only
param.split_func = 'axis-aligned';

%%
% Create the output csv file
res_path = get_res_path();
csv_path = strjoin({res_path 'param_results.csv'}, filesep);

% Track times during creation, but more important are the images
handle = fopen(csv_path, 'w');
headings = ['Tree Number,Depth,Rho,Bag Frac,Train Time,Dense Test,Sparse Test', sprintf('\n')];
fwrite(handle, headings);
fclose(handle);

% Create arrays to iterate over the possibilities
% treeNum = [1,2,4,6,8];
treeNum = [6];
% treeDepth = [2, 4, 6, 8, 10,];
treeDepth = [12,14];
treeSplits = 5:5:50;
bagFracs = 0.1:0.2:1.0;
totalTests = length(treeNum) * length(treeDepth) * length(treeSplits) * ...
             length(bagFracs);
numDone = 0;

continue_var = false;

for tn=treeNum
    for td=treeDepth
        for ts=treeSplits
            for bf=bagFracs
                % Set parameters
                param.num = tn;
                param.depth = td;
                param.splitNum = ts;
                param.frac = bf;
                
                % Grow tree
                tic();
                trees = growTrees(data_train, param);
                train_time = toc();
                
                % Test dense grid
                tic();
                for n=1:length(data_test)
                    try
                        leaves = testTrees([data_test(n,1:2) 0], trees);
                        p_rf = trees(1).prob(leaves,:);
                        p_rf_sum = sum(p_rf)/length(trees);
                        [~, guess] = max(p_rf_sum);
                        data_test(n, 3) = guess;
                        continue_var = true;
                    catch
                        continue_var = false;
                    end
                end
                dense_time = toc();

                % Save dense figure
                if continue_var
                    h1 = figure();set(gcf,'Visible', 'off');
                    plot_toydata(data_train);
                    plot_toydata(data_test);
                    saveas(gcf, ['img/params/tree_dense_', num2str(tn), ...
                                 '_', num2str(td), '_', num2str(ts), '_', ...
                                 num2str(bf*10), '.png']);
                    close all;
                end
                
                % Test sparse grid
                tic();
                for n=1:length(data_sparse)
                    try
                        leaves = testTrees([data_sparse(n,1:2) 0], trees);
                        p_rf = trees(1).prob(leaves,:);
                        p_rf_sum = sum(p_rf)/length(trees);
                        [~, guess] = max(p_rf_sum);
                        data_sparse(n, 3) = guess;
                        continue_var = true;
                    catch
                        continue_var = false;
                    end
                end
                sparse_time = toc();
                
                % Save sparse figure
                if continue_var
                    h1 = figure();set(gcf,'Visible', 'off');
                    plot_toydata(data_train);
                    plot_toydata(data_sparse);
                    saveas(gcf, ['img/params/tree_sparse_', num2str(tn), '_', ...
                                 num2str(td), '_', num2str(ts), '_', ...
                                 num2str(bf*10), '.png']);
                    close all;
                end
                
                % Save times to file
                handle = fopen(csv_path, 'a');
                csv_data = [num2str(tn), ',', num2str(td), ',', ...
                            num2str(ts), ',', num2str(bf), ',', ...
                            num2str(train_time), ',', ...
                            num2str(dense_time), ',', ...
                            num2str(sparse_time), sprintf('\n')];
                fwrite(handle, csv_data);
                fclose(handle);
                
                % Update user as to progress
                numDone = numDone + 1;
                disp([num2str(numDone), '/', num2str(totalTests), '=', ...
                      num2str(100*numDone/totalTests), ...
                      '% tests completed.']);
                
            end
        end
    end
end

                

