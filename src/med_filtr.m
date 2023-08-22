function output = med_filtr(input, med_shift, med_window, med_center)
%-----------------------------------------------------------------------
% Median filtering
% This fn works with columns.
%-----------------------------------------------------------------------
% for wrong inputs:
if med_window < med_center
    disp('Error! med_filtr: med_window < med_center')
    med_window = med_center;
    disp('Correction: med_window = med_center')
end
% median filtering
output = zeros(size(input, 1) - med_window + 1, 1);
for i = 1 : med_shift : size(input, 1) - med_window + 1
    sorted = sort(input(i : i + med_window - 1, :), 1, 'ascend');
    output(i, :) = sorted(med_center, :);
end
% alternative implementation:
% Built-in 'median' in for loop:
% output(i, :) = median(input(i : i + med_window - 1, :));
%-----------------------------------------------------------------------
