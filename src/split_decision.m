function decision = split_decision( data, point, split_param )
%SPLIT_DECISION Make a decision on which split to use based on function
%   point is a 3d point with x, y, class
%   split_param is a struct containing function information
%   RETURN: decision - logical true if greater than threshold

    % Point is a variable with x, y, class. Only want x,y
    p = point(1:2);
    
    % split_param is a parameter structure containing parameters
    if strcmp(split_param.split_func, 'axis-aligned')
        dim = split_param.dim;
        t = split_param.t;
        decision = p(dim) > t;
    elseif strcmp(split_param.split_func, 'two-pixel')
        % Get the next point after thing
        % Data to search is data(:, 1:2)
        idx = 0;
        next_p = [0 0];
        for i=1:length(data)
            if all(p == data(i, 1:2))
                idx = i;
                break;
            end
        end
        % Get the succeeding data point for gradient
        if idx == length(data)
            next_p = data(1, 1:2);
        else
            next_p = data(idx+1, 1:2);
        end
        
        % Compare to threshold
        t = split_param.t;
        decision = ((next_p(2)-p(2)) / (next_p(1) - p(1)) > t);

    elseif strcmp(split_param.split_func, 'linear')
        m = split_param.m;
        c = split_param.c;
        decision = p(2) > m*p(1) + c;
    elseif strcmp(split_param.split_func, 'quadratic')
        a = split_param.a;
        b = split_param.b;
        c = split_param.c;
        decision = p(2) > a*p(1)^2 + b*p(1) + c;
    end

end

