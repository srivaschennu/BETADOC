function fig_h = corrplot(plot_corr, plot_corrp, plot_text, label)


fontname = 'Helvetica';
fontsize = 22;
alpha = 0.01;

fig_h = figure('Color','white');
hold all
fig_h.Position(4) = fig_h.Position(4) * 3;

xmax = max(abs(plot_corr)) * 1.25;
xlim([-xmax  xmax]);
ylim([0,length(plot_text)+1]);
set(gca,'YDir','reverse','YTick',[],'FontName',fontname,'FontSize',fontsize,'YGrid','on');
xlabel(sprintf('Correlation with canonical %s score', label),'FontName',fontname,'FontSize',fontsize);

scatter(plot_corr(plot_corrp < alpha), find(plot_corrp < alpha), 300, 'LineWidth', 2, 'MarkerFaceColor','red', 'MarkerEdgeColor','blue')
scatter(plot_corr(plot_corrp >= alpha), find(plot_corrp >= alpha), 150, 'LineWidth', 2, 'MarkerFaceColor', [0.75 0.75 0.75], 'MarkerEdgeColor', [0.5, 0.5, 0.5])

for t = 1:length(plot_text)
    if plot_corrp(t) < alpha
        txt_plot = text(plot_corr(t),t,plot_text{t},'FontName',fontname,'FontSize',fontsize);
        txt_plot.Position(1) = txt_plot.Position(1)  + (abs(txt_plot.Position(1)) * .4) - txt_plot.Extent(3)/2;
    end
end