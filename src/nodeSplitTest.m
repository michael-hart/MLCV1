clear all;

% Call init script in subfolder
init_rf2017;

% Load toy spiral data and bagged index list
[data_train, data_test] = getData('Toy_Spiral');
load idx;
current_data = data_train(idx, :);

% Set the random forest parameters
param.num = 5;         % Number of trees
param.depth = 8;        % trees depth
param.splitNum = 50;     % Number of split functions to try
param.split = 'IG';     % Currently support 'information gain' only
param.split_func = 'axis-aligned';

% Create the output csv file
res_path = get_res_path();
csv_path = strjoin({res_path 'results.csv'}, filesep);

%% Split Function Test

% Write in the file headers
% Need split number, split function, and information gain
handle = fopen(csv_path, 'w');
headings = ['Splits Tested,Function,IG,Time Taken', sprintf('\n')];
fwrite(handle, headings);
fclose(handle);

% Set up test parameters
rootNode = struct('idx',idx,'prob',[],'split_param', ...
                  struct('split_func', 'leaf'));
test_attempts = [5, 10, 15, 20, 30, 40, 50, 60, 80, 100];
test_funcs = cellstr(['axis-aligned'; 'x-aligned   '; 'y-aligned   '; 
                      'two-pixel   '; 'linear      '; 'quadratic   ']);

% Try a few different split functions and look at the results

for attempts=test_attempts
    for func=1:length(test_funcs)
        % Set iterating variables into param struct
        param.splitNum = attempts;
        param.split_func = deblank(char(test_funcs(func)));

        % Start the timer
        tic();
        
        % Split the node
        [node, nodeL, nodeR] = splitNode(data_train, rootNode, param);
        
        % Stop the timer
        train_time = toc();
        
        % Work out which indices were allocated to nodeL
        idx_ = false(length(idx), 1);
        for i=1:length(idx)
            if any(nodeL.idx==idx(i))
                idx_(i) = true;
            end
        end
        
        % Get Info Gain
        ig = getIG(data_train, idx_);
        
        % Record into CSV file
        csv_data = [num2str(attempts), ',', param.split_func, ',', ...
                    num2str(ig), ',', num2str(train_time), sprintf('\n')];
        handle = fopen(csv_path, 'a');
        fwrite(handle, csv_data);
        fclose(handle);
        
        % Print results so user has update on progress
        disp(['Function ', param.split_func, ' with ', ...
              num2str(attempts), ' attempts had best IG ', num2str(ig), ...
              ' calculated in ', num2str(train_time), 's.']);
    end
end

%% Test axis-aligned only

% Write in the file headers
% Need rho, information gain, time taken, dimension, and threshold
csv_path = strjoin({res_path 'rho_results.csv'}, filesep);
handle = fopen(csv_path, 'w');
headings = ['Splits Tested,IG,Time Taken,Dimension,Threshold', ...
            sprintf('\n')];
fwrite(handle, headings);
fclose(handle);

% Set up test parameters
[N,D] = size(data_train);
rho = 1:length(idx);
rootNode = struct('idx',idx,'prob',[],'split_param', ...
                  struct('split_func', 'leaf'));

for r=rho
    param.splitNum = r;
    
    % Start the timer
    tic();

    % Split the node
    [node, nodeL, nodeR] = splitNode(data_train, rootNode, param);

    % Stop the timer
    train_time = toc();

    % Work out which indices were allocated to nodeL
    idx_ = current_data(:, node.split_param.dim) < node.split_param.t;
%     idx_ = false(length(idx), 1);
%     for i=1:length(idx)
%         if any(nodeL.idx==idx(i))
%             idx_(i) = true;
%         end
%     end

    % Get Info Gain
    ig = getIG(data_train, idx_);

    % Record into CSV file
    csv_data = [num2str(r), ',', num2str(ig), ',', num2str(train_time), ...
                ',', num2str(node.split_param.dim), ',', ...
                num2str(node.split_param.t), sprintf('\n')];
    handle = fopen(csv_path, 'a');
    fwrite(handle, csv_data);
    fclose(handle);

    % Print results so user has update on progress
    disp(['Rho ', num2str(r), ' had best IG ', num2str(ig), ...
          ' calculated in ', num2str(train_time), 's.']);

end

%% Display the split function
split_param = struct('split_func', 'axis-aligned', 't', -0.065988, ...
                     'dim', 1);
data = data_train(idx,:);
% Want the idx_ of the best indices
idx_ = data(:, split_param.dim) < split_param.t;
visualise_splitfunc(idx_,data,-2.7622,split_param,0);
