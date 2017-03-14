function [ histogram_output ] = vec_quant( centroids, data )
%VEC_QUANT Vector Quantisation using NN
%   Detailed explanation goes here

    classnumber = size(data, 1);
    perclass = size(data, 2);
    centroid_num = size(centroids, 2);

    % NN from an image
    histogram_data = zeros(classnumber, perclass, 4000);
    histogram_output = zeros(classnumber, perclass, centroid_num);
    
    % Iterate through each class
    for class_idx = 1:classnumber
        % Iterate through images
        for image_idx = 1:perclass
            % Feature per column
            image_features = data{class_idx, image_idx};
            for feature_idx = 1:size(image_features,2)
                % Find nearest neighbour codeword from centroids
                histogram_data(class_idx, image_idx, feature_idx) = ...
                    nearest_neighbour(image_features(:, feature_idx), centroids);
            end
                % Create histogram by counting instance of each centroid
                histogram_output(class_idx, image_idx, :) = ... 
                    histogramoutput(histogram_data(class_idx, image_idx, :), centroid_num);
        end
    end
end

