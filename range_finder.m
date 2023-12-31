% Find location of initial data set rows
% after importing csv

function [data_start, dimensions] = range_finder(data)

[data_rows, data_cols] = size(data);

zeros_pos = find(data(:, 1) == 0)';

data_start = zeros_pos(end) + 1;

non_zeros = nnz(data(:,1));

test_start = data_rows - non_zeros + 1;

dimensions = [non_zeros, data_rows, data_cols];




