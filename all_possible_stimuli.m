% all_possible_stimuli.m

clear all;
close all;

load('inputs.mat');
code = [0 1 0 0 0 0 1 0];
disp(code)
for t = 1:size(inputs, 2)
    test_col = inputs(:,t);
    if isequal(test_col.', code)
        disp('Code is present in data.')
        return
    end
end
disp('Code is absent in data.')