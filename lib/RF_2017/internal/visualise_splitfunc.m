function visualise_splitfunc(idx_best,data,ig_best,split_param,iter) % Draw the split line
r = [-1.5 1.5]; % Data range

subplot(2,2,1);

% Plot a line based on the split parameters
if strcmp(split_param.split_func, 'axis-aligned')
    if split_param.dim == 1
        plot([split_param.t split_param.t],[r(1),r(2)],'r');
    else
        plot([r(1),r(2)],[split_param.t split_param.t],'r');
    end
% Note lack of 2-pixel as it is difficult to visualise    
elseif strcmp(split_param.split_func, 'linear')
    plot(r(1):0.01:r(2) * split_param.m + split_param.c);
elseif strcmp(split_param.split_func, 'quadratic')
    a = split_param.a;
    b = split_param.b;
    c = split_param.c;
    nums = r(1):0.01:r(2);
    plot(a*(nums.^2) + b*(nums) + c);
end
hold on;
plot(data(~idx_best,1), data(~idx_best,2), '*', 'MarkerEdgeColor', [.8 .6 .6], 'MarkerSize', 10);
hold on;
plot(data(idx_best,1), data(idx_best,2), '+', 'MarkerEdgeColor', [.6 .6 .8], 'MarkerSize', 10);

hold on;
plot(data(data(:,end)==1,1), data(data(:,end)==1,2), 'o', 'MarkerFaceColor', [.9 .3 .3], 'MarkerEdgeColor','k');
hold on;
plot(data(data(:,end)==2,1), data(data(:,end)==2,2), 'o', 'MarkerFaceColor', [.3 .9 .3], 'MarkerEdgeColor','k');
hold on;
plot(data(data(:,end)==3,1), data(data(:,end)==3,2), 'o', 'MarkerFaceColor', [.3 .3 .9], 'MarkerEdgeColor','k');

if strcmp(split_param.split_func, 'axis-aligned')
    dim = split_param.dim;
    if ~iter
        title(sprintf('BEST Split [%i]. IG = %4.2f',dim,ig_best));
    else
        title(sprintf('Trial %i - Split [%i]. IG = %4.2f',iter,dim,ig_best));
    end
end
axis([r(1) r(2) r(1) r(2)]);
hold off;

% histogram of base node
subplot(2,2,2);
tmp = hist(data(:,end), unique(data(:,end)));
bar(tmp);
axis([0.5 3.5 0 max(tmp)]);
title('Class histogram of parent node');
subplot(2,2,3);
bar(hist(data(idx_best,end), unique(data(:,end))));
axis([0.5 3.5 0 max(tmp)]);
title('Class histogram of left child node');
subplot(2,2,4);
bar(hist(data(~idx_best,end), unique(data(:,end))));
axis([0.5 3.5 0 max(tmp)]);
title('Class histogram of right child node');
hold off;
end