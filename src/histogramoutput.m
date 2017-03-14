function [ output ] = histogramoutput( input, N )
%HISTOGRAMOUTPUT Takes input vector, returns N column vector with freq.
    output = zeros(N, 1);
    for index = 1:N
        output(index) = sum(input == index);
    end
end

