function label = testTrees(data,tree)
% Slow version - pass data point one-by-one

cc = [];
for T = 1:length(tree)
    for m = 1:size(data,1)
        idx = 1;
        
        while ~strcmp(tree(T).node(idx).split_param.split_func, 'leaf')
            
            if split_decision(data, data(m,:), tree(T).node(idx).split_param)
                % Pass data right
                idx = idx*2+1;
            else
                % Pass data left
                idx = idx*2;
            end
            
        end
        leaf_idx = tree(T).node(idx).leaf_idx;
        
        if ~isempty(tree(T).leaf(leaf_idx))
            p(m,:,T) = tree(T).leaf(leaf_idx).prob;
            label(m,T) = tree(T).leaf(leaf_idx).label;
            
%             if isfield(tree(T).leaf(leaf_idx),'cc') % for clustering forest
%                 cc(m,:,T) = tree(T).leaf(leaf_idx).cc;
%             end
        end
    end
end

end

