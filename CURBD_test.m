% CURBD_test.m

clear all;
close all;
clc;

% Should use CURBD in the following mode: out = computeCURBD(RNN, J, regions, params)

load('/Users/joechoo-choy/Documents/github_jchooch/zfish_pretectum_rnn/matlab/current/ensemble/output_1.mat');
test_RNN = R;
test_J = J;
test_N = N;

load('curbd_example_workspace.mat');
A_neuron_indices = 1:test_N/5;
B_neuron_indices = (test_N/5)+1 : 2*test_N/5;
C_neuron_indices = (2*test_N/5)+1 : 3*test_N/5;
D_neuron_indices = (3*test_N/5)+1 : 4*test_N/5;
E_neuron_indices = (4*test_N/5)+1 : N;
test_regions = {'Selectivity A', A_neuron_indices; 
                'Selectivity B', B_neuron_indices; 
                'Selectivity C', C_neuron_indices;
                'Selectivity D', D_neuron_indices;
                'Selectivity E', E_neuron_indices};
test_params = model.params;

test_CURBD = computeCURBD(test_RNN, test_J, test_regions, test_params);

% plot heatmaps of currents
figure('Position',[100 100 900 900]);
count = 1;
for iTarget = 1:size(test_CURBD,1)
    for iSource = 1:size(test_CURBD,2)
        subplot(size(test_CURBD,1),size(test_CURBD,2),count); hold all; count = count + 1;
        imagesc(model.tRNN,1:sim.params.Na,test_CURBD{iTarget,iSource});
        axis tight;
        set(gca,'Box','off','TickDir','out','FontSIze',14,'CLim',[-1 1]);
        xlabel('Time (s)');
        ylabel(['Neurons in ' test_regions{iTarget,1}]);
        title([test_regions{iSource,1} ' to ' test_regions{iTarget,1}]);
    end
end
%colormap winter;