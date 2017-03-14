function [node,nodeL,nodeR] = splitNode(data,node,param)
% Split node

visualise = 0;

% Initilise child nodes
iter = param.splitNum;
nodeL = struct('idx',[],'prob',[],'split_param',struct('split_func', 'leaf'));
nodeR = struct('idx',[],'prob',[],'split_param',struct('split_func', 'leaf'));

if length(node.idx) <= 5 % make this node a leaf if has less than 5 data points
    node.split_param.split_func = 'leaf';
    return;
end

% Make sure that the parameters include a split function
if (not(isfield(param, 'split_func')))
    param.split_func = 'axis-aligned';
end

idx = node.idx;
data = data(idx,:);
[N,D] = size(data);
ig_best = -inf; % Initialise best information gain
idx_best = [];
for n = 1:iter
    if strcmp(param.split_func, 'axis-aligned')
    
        % Split function - Modify here and try other types of split function

        dim = randi(D-1); % Pick one random dimension
        d_min = single(min(data(:,dim))) + eps; % Find the data range of this dimension
        d_max = single(max(data(:,dim))) - eps;
        t = d_min + rand*((d_max-d_min)); % Pick a random value within the range as threshold
        idx_ = data(:,dim) < t;
        
        split_param = struct('split_func', 'axis-aligned', 't', t, 'dim', dim);

        ig = getIG(data,idx_); % Calculate information gain
    
    elseif strcmp(param.split_func, 'x-aligned')
        
        % Same as axis-aligned, but no random axis selection
        d_min = single(min(data(:,1))) + eps;
        d_max = single(max(data(:,1))) - eps;
        t = d_min + rand*((d_max-d_min));
        idx_ = data(:,1) < t;
        
        split_param = struct('split_func', 'axis-aligned', 't', t, 'dim', 1);
        
        ig = getIG(data,idx_);
        
    elseif strcmp(param.split_func, 'y-aligned')
        
        % Same as axis-aligned, but no random axis selection
        d_min = single(min(data(:,2))) + eps;
        d_max = single(max(data(:,2))) - eps;
        t = d_min + rand*((d_max-d_min));
        idx_ = data(:,2) < t;
        
        split_param = struct('split_func', 'axis-aligned', 't', t, 'dim', 2);
        
        ig = getIG(data,idx_);
        
    elseif strcmp(param.split_func, 'two-pixel')
        
        % Check gradient between each sequential pixel pair against pixel
        t = (5 - -5)*rand + -5;
        idx_ = false(N, 1);
        for i=1:N
            t1 = data(i, 1:2);
            if i == N
                t2 = data(1, 1:2);
            else
                t2 = data(i+1, 1:2);
            end
            if ((t2(2)-t1(2)) / (t2(1) - t1(1)) > t)
                idx_(i) = true;
            end
        end
        
        split_param = struct('split_func', 'two-pixel', 't', t);
        
        ig = getIG(data,idx_);
        
    elseif strcmp(param.split_func, 'linear')
        
        % Create a random gradient
        m = (5 - -5)*rand + -5;
        % Create y-intercept from randomly selected point
        any_point = data(randi(N), :);
        c = any_point(2) - m*any_point(1) + eps;
        
        idx_ = false(N, 1);
        for i=1:N
            t1 = data(i, 1:2);
            if t1(2) > (m*t1(1) + c)
                idx_(i) = true;
            end
        end
        
        split_param = struct('split_func', 'linear', 'm', m, 'c', c);
        
        ig = getIG(data,idx_);
        
    elseif strcmp(param.split_func, 'quadratic')
        
        % Create a random pair a, b (y = ax^2 + bx + c)
        a = (5 - -5)*rand + -5;
        b = (5 - -5)*rand + -5;
        % Randomly select point and match c to it
        any_point = data(randi(N), :);
        c = any_point(2) - a*any_point(1)^2 - b*any_point(1) + eps;
        
        idx_ = false(N, 1);
        for i=1:N
            t1 = data(i, 1:2);
            if t1(2) > (a*t1(1)^2 + b*t1(1) + c)
                idx_(i) = true;
            end
        end
        
        split_param = struct('split_func', 'quadratic', 'a', a, 'b', b, 'c', c);
        
        ig = getIG(data,idx_);
        
    end
    
    [node, ig_best, idx_best] = updateIG(node,ig_best,ig,idx_,idx_best,split_param);
    
end

nodeL.idx = idx(idx_best);
nodeR.idx = idx(~idx_best);
% Re-assign to split_param the best version
split_param = node.split_param;

if visualise
    idx_best = data(:,split_param.dim) < split_param.t;
    
    visualise_splitfunc(idx_best,data,ig_best,split_param,0)
%     fprintf('Information gain = %f. \n',ig_best);
    
%     if strcmp(split_param.split_func, 'axis-aligned')
%         fprintf('Axis-aligned with t= %f and dim %d. \n', ...
%                 split_param.t, split_param.dim);
%     elseif strcmp(split_param.split_func, 'two-pixel')
%         fprintf('Two-pixel with t= %f . \n', split_param.t);
%     elseif strcmp(split_param.split_func, 'linear')
%         fprintf('Linear with m= %f and c= %f. \n', split_param.m, ...
%                 split_param.c);
%     elseif strcmp(split_param.split_func, 'quadratic')
%         fprintf('Quadratic with a= %f, b= %f, c =%f. \n', ...
%                 split_param.a, split_param.b, split_param.c);
%     end
end

end

function [node, ig_best, idx_best] = updateIG(node,ig_best,ig,idx,idx_best,split_param) % Update information gain
if ig > ig_best
    ig_best = ig;
    % Copy out the parameters, don't just do an assignment
    for fn = fieldnames(split_param)'
        node.split_param.(fn{1}) = split_param.(fn{1});
    end
    idx_best = idx;
else
    idx_best = idx_best;
end
end