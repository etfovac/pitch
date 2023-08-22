function input_padd = padding(input, med_window, med_center, padding_type)
%-----------------------------------------------------------------------
% input is a vector M1 x A
% izlaz is a vector M2 x B
% padding is extending the vector 
% to get M1 = M2 after med_filtr OR filter fn
% padding_type - a char variable
% This fn works with columns.
%-----------------------------------------------------------------------
[dim1, dim2] = size(input); 
offset = abs(med_center - med_window);
% padding (extension) at the ends of input vector
switch padding_type
    case 'mirror'
        padd_begin = input(offset : -1 : 1, :);
        padd_end = input(dim1 : -1 : dim1 - offset + 1, :);                
    case 'same'
        padd_begin = zeros(offset,1);
        padd_begin(1 : offset) = input(1, :);
        padd_end = zeros(offset,1);
        padd_end(1 : offset) = input(dim1, :);
    case 'zeros'
        padd_begin = zeros(offset, dim2);
        padd_end = zeros(offset, dim2);
    otherwise
        padd_begin = [];
        padd_end = [];
end
input_padd = [padd_begin; input; padd_end];
%-----------------------------------------------------------------------
