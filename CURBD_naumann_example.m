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

%{
% USE THESE INDICES FOR JUST SUBDIVIDING INTO MONOCULAR AND BINOCULAR
Monocular_indices = [Right_lateral_indices, Right_medial_indices, Left_lateral_indices, Left_medial_indices];
Monocular_indices = unique(Monocular_indices, 'stable');
Monocular_indices = sort(Monocular_indices);
Binocular_indices = [Right_binocular_indices, Left_binocular_indices, Outward_indices, Inward_indices];
Binocular_indices = unique(Binocular_indices, 'stable');
Binocular_indices = sort(Binocular_indices);
%}

%{ USE THESE INDICES FOR SUBDIVIDING LEFT MONO, RIGHT MONO, LEFT BINO,
%RIGHT BINO
Left_monocular_indices = [Left_lateral_indices, Left_medial_indices];
Right_monocular_indices = [Right_lateral_indices, Right_medial_indices];
Left_binocular_indices = [Left_binocular_indices];
Right_binocular_indices = [Right_binocular_indices];
%}

number_of_neurons = length(Left_monocular_indices) + length(Right_monocular_indices) + length(Left_binocular_indices) + length(Right_binocular_indices);

% Using CURBD in the following mode: out = computeCURBD(RNN, J, regions, params)

correlation_table = [];

for ensemble_index = 1:1
    data{ensemble_index} = load(sprintf('~/Documents/github_jchooch/zfish_pretectum_rnn/matlab/current/ensemble/output_%d.mat', ensemble_index));
    fprintf('Data index (from ensemble): %d \n Data file: output_%d.mat \n', ensemble_index, ensemble_index);
    test_RNN = data{1, ensemble_index}.R(:, 1:end-2);
    test_J = data{1, ensemble_index}.J;
    test_N = data{1, ensemble_index}.N;
    load('curbd_example_workspace.mat');
    %test_regions = {'Monocular', Monocular_indices; 'Binocular', Binocular_indices};
    test_regions = {
        'LM', Left_monocular_indices;
        'RM', Right_monocular_indices;
        'LB', Left_binocular_indices;
        'RB', Right_binocular_indices};
    test_params = model.params;
    test_CURBD = computeCURBD(test_RNN, test_J, test_regions, test_params);
    % plot heatmaps of currents
    current_figure = figure('Position', [100 100 900 900], 'Visible', 'on');
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
        imagesc(1:size(test_RNN, 2), 1:length(test_regions{iTarget, 2}), target_activities); colorbar;
        axis tight;
        set(gca,'Box','off','TickDir','out','FontSIze',14,'CLim',[-1 1]);
        xlabel('Time');
        ylabel(['Neurons in ' test_regions{iTarget,1}]);
        title(['Activity in ' test_regions{iTarget,1}]);
        for iSource = 1:size(test_CURBD,2)
            subplot(size(test_CURBD,1)+1,size(test_CURBD,2), plot_index(count)); hold all; count = count + 1;
            imagesc(1:size(test_RNN, 2), 1:length(test_regions{iTarget, 2}), test_CURBD{iTarget,iSource}); colorbar;
            axis tight;
            set(gca,'Box','off','TickDir','out','FontSIze',14,'CLim',[-1 1]);
            xlabel('Time');
            ylabel(['Neurons in ' test_regions{iTarget,1}]);
            title([test_regions{iSource,1} ' to ' test_regions{iTarget,1} ' Currents']);
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
    saveas(current_figure, sprintf('CURBD_figures/CURBD_fig_%d.png', ensemble_index));
    disp('Average correlations:')
    disp(average_correlations)
    correlation_table = [correlation_table; reshape(average_correlations', 1, numel(average_correlations))];
    %correlation_table = [correlation_table; ensemble_index, reshape(average_correlations', 1, numel(average_correlations))];
end
display(correlation_table)

figure()
%plot_curbd_correlations(correlation_table, test_CURBD)
h = heatmap(reshape(correlation_table, [size(test_CURBD, 1), size(test_CURBD, 2)]));
h.Title = 'Correlations Between Target Activities and Source-Target Currents';
h.XLabel = 'Source Region';
h.YLabel = 'Target Region';
region_names = [];
for i=1:size(test_regions, 1)
    region_names = [region_names, string(test_regions{i,1})];
end
h.XDisplayLabels = num2cell(region_names);
h.YDisplayLabels = num2cell(region_names);

% want to create a pca cell with pca coeff matrices for all curbd matrices
% want to create a reduced_activities for all curbd matrices (multiply
% relevant curbd matrix by relevant pca coeff matrix)
% create time vectors for: 
% - stimulus on vs off
% - stimulus right vs left vs off
% - stimulus binocular vs monocular
% - etc
% MEASURE DEVIATIONS OF DYNAMICS BY MAHALANOBIS DISTANCE FROM SOME NULL
% DISTRIBUTION (CAN DO THIS FOR VOLTAGES AND CURRENTS)
% USE WHOLE FIELD MOTION / BINOCULAR MOTION

[coeff,score,latent,tsquared,explained,mu] = pca(test_CURBD{1, 1}.');

figure()
reduced_activities = test_CURBD{1, 1}.' * coeff;
reduced_activities = reduced_activities.';
time_col = linspace(0,2*pi,size(reduced_activities,2));
x = reduced_activities(1,:);
y = reduced_activities(2,:);

plot3(reduced_activities(1,1:500), reduced_activities(2,1:500), reduced_activities(3,1:500))

% color code line plot with stimuli or dots (e.g. L,R)
%{
x = 0:.05:2*pi;
y = sin(x);
z = zeros(size(x));
col = z;  % This is the color, vary with x in this case.
surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',2);
%}

%{
for iTarget = 1:size(test_CURBD,1)
    for iSource = 1:size(test_CURBD,2)
        CURBD_PCs = pca(test_CURBD{iTarget, iSource}.');
        CURBD_PCs
    end
end
%}

%{
figure('Position', [100 100 900 900], 'Visible', 'on');
subplot(1, 2, 1); 
hold all; 
swarmchart([1, 2], [correlation_table(:, 2), correlation_table(:, 3)]); 
xlabel('source region'); 
title('source correlations for target 1 (mono)'); 
subplot(1, 2, 2); 
hold all; 
swarmchart([1, 2], [correlation_table(:, 4), correlation_table(:, 5)]); 
xlabel('source region'); 
title('source correlations for target 2 (bino)');
%}
