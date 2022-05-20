% CURBD_test.m

clear all;
close all;
clc;

Forward_indices = [1:37];
Backward_indices = [203:249];
Right_lateral_indices = [55:76];
Right_medial_indices = [119:130, 133:138, 142:143, 145:147, 149, 151:165];
Right_binocular_indices = [78:86, 166:185];
Left_lateral_indices = [351:402];
Left_medial_indices = [269:318];
Left_binocular_indices = [344:348, 408:410];
Outward_indices = [103:109, 407, 409];
Inward_indices = [196:199, 319:323];
Monocular_indices = [Right_lateral_indices, Right_medial_indices, Left_lateral_indices, Left_medial_indices];
Monocular_indices = unique(Monocular_indices, 'stable');
Monocular_indices = sort(Monocular_indices);
Binocular_indices = [Right_binocular_indices, Left_binocular_indices, Outward_indices, Inward_indices];
Binocular_indices = unique(Binocular_indices, 'stable');
Binocular_indices = sort(Binocular_indices);

number_of_neurons = length(Monocular_indices) + length(Binocular_indices);

% Should use CURBD in the following mode: out = computeCURBD(RNN, J, regions, params)

correlation_table = [];

for ensemble_index = 1:5
    load(sprintf('~/Documents/github_jchooch/zfish_pretectum_rnn/matlab/current/ensemble/output_%d.mat', ensemble_index));
    fprintf('Ensemble index: %d \n Data file: output_%d.mat \n', ensemble_index, ensemble_index);
    test_RNN = R(:, 1:end-2);
    test_J = J;
    test_N = N;
    load('curbd_example_workspace.mat');
    test_regions = {'Monocular', Monocular_indices; 
                    'Binocular', Binocular_indices};
    test_params = model.params;
    test_CURBD = computeCURBD(test_RNN, test_J, test_regions, test_params);
    % plot heatmaps of currents
    figure('Position',[100 100 900 900]);
    plot_index = reshape(1:size(test_CURBD,1) * (size(test_CURBD,2)+1), size(test_CURBD,1), size(test_CURBD,2)+1).';
    count = 1;
    average_correlations = [];
    for iTarget = 1:size(test_CURBD,1)
        target_activities = [];
        for id = 1:length(test_regions{iTarget, 2})
            target_activities = [target_activities; test_RNN(test_regions{iTarget, 2}(id), :)];
        end
        subplot(size(test_CURBD,1)+1, size(test_CURBD,2), plot_index(count));
        hold all;
        count = count + 1;
        imagesc(1:size(test_RNN, 2), 1:length(test_regions{iTarget, 2}), target_activities);
        axis tight;
        set(gca,'Box','off','TickDir','out','FontSIze',14,'CLim',[-1 1]);
        xlabel('Frames');
        ylabel(['Neurons in ' test_regions{iTarget,1}]);
        title(['Activity in ' test_regions{iTarget,1}]);
        for iSource = 1:size(test_CURBD,2)
            subplot(size(test_CURBD,1)+1,size(test_CURBD,2), plot_index(count)); hold all; count = count + 1;
            imagesc(1:size(test_RNN, 2), 1:length(test_regions{iTarget, 2}), test_CURBD{iTarget,iSource});
            axis tight;
            set(gca,'Box','off','TickDir','out','FontSIze',14,'CLim',[-1 1]);
            xlabel('Frames');
            ylabel(['Neurons in ' test_regions{iTarget,1}]);
            title([test_regions{iSource,1} ' to ' test_regions{iTarget,1}]);
            summed_correlations = 0;
            for neuron = 1:length(test_regions{iTarget, 2})
                summed_correlations = summed_correlations + corr2(test_CURBD{iTarget, iSource}(neuron, :), target_activities(neuron, :));
            end
            average_correlation = summed_correlations / size(test_CURBD{iTarget,iSource}, 1);
            fprintf('Average correlation between target %d and source %d: %d \n', iTarget, iSource, average_correlation);
            average_correlations = [average_correlations; average_correlation];
        end
    end
    colormap redblue(100);
    saveas(gcf, sprintf('/CURBD_figures/CURBD_fig_%d.png', ensemble_index));
    display(average_correlations);
    correlation_table = [correlation_table; ensemble_index, reshape(average_correlations', 1, numel(average_correlations))];
end
display(correlation_table)