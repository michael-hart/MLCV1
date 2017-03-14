function [ index ] = nearest_neighbour( test_point, ...
                                      training_set )
% NEAREST_NEIGHBOUR_ Find nearest training point of test point
%   Obtains L2 distance of test point to each training point.
%   Returns the class of the closest training point.
%   L2 is square root of difference in each dimension squared

    % Data is in a column
    N = size(training_set, 2);
    difference = training_set(:, :) - double(test_point(:, ones(N, 1)));
    l2_distance = sum((difference .^ 2));

    [~, index] = min(l2_distance);
end