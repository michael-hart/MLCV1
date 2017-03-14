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

%%  Begin tree growth
clear tree;
cnt_total = 1;
data = data_train;
[labels,~] = unique(data(:,end));
prior = histc(data(idx,end),labels)/length(idx);

disp('hello');
% Initialise base node
tree.node(1) = struct('idx',idx,'prob',[],'split_param',struct('split_func', 'leaf'));
disp('hello2');

% Split Nodes
for n = 1:2^(param.depth-1)-1
    [tree.node(n),tree.node(n*2),tree.node(n*2+1)] = ...
        splitNode(data_train,tree.node(n),param);
end

% Leaf Nodes
cnt = 1;
for n = 1:2^param.depth-1
    if ~isempty(tree.node(n).idx)
        % Percentage of observations of each class label
        tree.node(n).prob = histc(data(tree.node(n).idx,end),labels) / ...
                                  length(tree.node(n).idx);

        % if this is a leaf node
        if strcmp(tree.node(n).split_param.split_func, 'leaf')
            tree.node(n).leaf_idx = cnt;
            tree.leaf(cnt).label = cnt_total;
            prob = reshape(histc(data(tree.node(n).idx,end),labels),[],1);

            tree.leaf(cnt).prob = prob; %.*prior; % Multiply by the prior probability of bootstrapped sub-training-set
            tree.leaf(cnt).prob = tree.leaf(cnt).prob./sum(tree.leaf(cnt).prob); % Normalisation

            if strcmp(param.split,'Var')
                tree.cc(cnt_total,:) = mean(data(tree.node(n).idx,1:end-1),1); % For RF clustering, unfinished
            else
                tree.prob(cnt_total,:) = tree.node(n).prob';
            end

            cnt = cnt+1;
            cnt_total = cnt_total + 1;
        end
    end
end

disp('Tree grown successfully');

%% Data visualisation time

disp('Visualising tree');
trees(1) = tree;
visualise_leaf;
disp('Visualisation complete');
