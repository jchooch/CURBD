% plot_curbd_correlations.m

function plot_curbd_correlations(correlation_table, CURBD)
    if size(correlation_table, 1) == size(correlation_table, 2)
        h = heatmap(correlation_table);
        h.Title = 'My Heatmap Title';
        h.XLabel = 'My Label';
        h.YLabel = 'My Label';
    else
        h = heatmap(reshape(correlation_table, [size(CURBD, 1), size(CURBD, 2)]));
        h.Title = 'My Heatmap Title';
        h.XLabel = 'My Label';
        h.YLabel = 'My Label';
    end
end