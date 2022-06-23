% plot_PCA_activities.m

% activities should have shape T x N for PCA

function plot_PCA_activities(varargin)
    activities = varargin{1};
    if nargin == 2
        stoptime = varargin{2};
    else
        stoptime = size(activities, 1);
        fprintf('Plotting all timepoints. Provide a stoptime to plot subset.\n')
    end
    display('Shape of activities (T x N): ')
    display(size(activities))
    [coeff,score,latent,tsquared,explained,mu] = pca(activities);
    reduced_activities = activities * coeff;
    reduced_activities = reduced_activities.';
    x = reduced_activities(1,:);
    y = reduced_activities(2,:);
    z = reduced_activities(3,:);
    figure()
    plot3(x(1:stoptime), y(1:stoptime), z(1:stoptime), 'r', 'LineWidth', 2)
    hold on
    set(gca,'Color','[.8 .8 .8]')
    grid on
    set(gca, 'GridColor', 'k')
    hold off
end
