function [node,nodeL,nodeR] = splitNode(data,node,param)
% Split node

visualise = 1;

% Initilise child nodes
iter = param.splitNum;
nodeL = struct('idx',[],'t',nan,'dim',0,'prob',[]);
nodeR = struct('idx',[],'t',nan,'dim',0,'prob',[]);

if length(node.idx) <= 5 % make this node a leaf if has less than 5 data points
    node.t = nan;
    node.dim = 0;
    return;
end

% Make sure that the parameters include a split function
if (not(isfield(param, 'splitfunc')))
    param.splitfunc = 'axis-aligned';
end

idx = node.idx;
data = data(idx,:);
[N,D] = size(data);
ig_best = -inf; % Initialise best information gain
idx_best = [];
for n = 1:iter
    dim = 3;
    t = 1;
    if strcmp(param.splitfunc, 'axis-aligned')
    
        % Split function - Modify here and try other types of split function

        dim = randi(D-1); % Pick one random dimension
        d_min = single(min(data(:,dim))) + eps; % Find the data range of this dimension
        d_max = single(max(data(:,dim))) - eps;
        t = d_min + rand*((d_max-d_min)); % Pick a random value within the range as threshold
        idx_ = data(:,dim) < t;

        ig = getIG(data,idx_); % Calculate information gain

        if visualise
            visualise_splitfunc(idx_,data,dim,t,ig,n);
            pause();
        end
    
    elseif strcmp(param.splitfunc, 'x-aligned')
        
        dim = 1;
        % Same as axis-aligned, but no random axis selection
        d_min = single(min(data(:,1))) + eps;
        d_max = single(max(data(:,dim))) - eps;
        t = d_min + rand*((d_max-d_min));
        idx_ = data(:,1) < t;
        
        ig = getIG(data,idx_);
        
        if visualise
            visualise_splitfunc(idx_,data,1,t,ig,n);
            pause();
        end
        
    elseif strcmp(param.splitfunc, 'y-aligned')
        
        dim = 2;
        % Same as axis-aligned, but no random axis selection
        d_min = single(min(data(:,2))) + eps;
        d_max = single(max(data(:,dim))) - eps;
        t = d_min + rand*((d_max-d_min));
        idx_ = data(:,2) < t;
        
        ig = getIG(data,idx_);
        
        if visualise
            visualise_splitfunc(idx_,data,2,t,ig,n);
            pause();
        end
        
    elseif strcmp(param.splitfunc, 'two-pixel')
        
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
        
        ig = getIG(data,idx_);
        
    elseif strcmp(param.splitfunc, 'linear')
        
        % Create a random gradient
        m = (5 - -5)*rand + -5;
        % Create y-intercept from randomly selected point
        any_point = data(randi(N), :);
        c = any_point(2) - m*any_point(1);
        
        idx_ = false(N, 1);
        for i=1:N
            t1 = data(i, 1:2);
            if t1(2) > (m*t1(1) + c)
                idx_(i) = true;
            end
        end
        
        ig = getIG(data,idx_);
        
%     elseif strcmp(param.splitfunc, 'quadratic')
        
    end
    
    [node, ig_best, idx_best] = updateIG(node,ig_best,ig,t,idx_,dim,idx_best);
    
end

nodeL.idx = idx(idx_best);
nodeR.idx = idx(~idx_best);

if visualise
    visualise_splitfunc(idx_best,data,dim,t,ig_best,0)
    fprintf('Information gain = %f. \n',ig_best);
    pause();
end

end

function ig = getIG(data,idx) % Information Gain - the 'purity' of data labels in both child nodes after split. The higher the purer.
L = data(idx);
R = data(~idx);
H = getE(data);
HL = getE(L);
HR = getE(R);
ig = H - sum(idx)/length(idx)*HL - sum(~idx)/length(idx)*HR;
end

function H = getE(X) % Entropy
cdist= histc(X(:,1:end), unique(X(:,end))) + 1;
cdist= cdist/sum(cdist);
cdist= cdist .* log(cdist);
H = -sum(cdist);
end

function [node, ig_best, idx_best] = updateIG(node,ig_best,ig,t,idx,dim,idx_best) % Update information gain
if ig > ig_best
    ig_best = ig;
    node.t = t;
    node.dim = dim;
    idx_best = idx;
else
    idx_best = idx_best;
end
end