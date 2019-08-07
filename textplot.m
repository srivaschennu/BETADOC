function fig_h = textplot(plot_corr, plot_corrp, plot_text, label)


fontname = 'Helvetica';
fontsize = 18;
alpha = 0.01;

fig_h = figure('Color','white');
fig_h.Position(4) = fig_h.Position(4) * 3;

xmax = max(abs(plot_corr)) * 1.25;
xlim([-xmax  xmax]);
ylim([0,length(plot_text)+1]);
set(gca,'YDir','reverse','YTick',[],'FontName',fontname,'FontSize',fontsize,'YGrid','on');
xlabel(sprintf('Correlation with canonical %s score', label),'FontName',fontname,'FontSize',fontsize);

for t = 1:length(plot_text)
    txt_plot = text(plot_corr(t),t,plot_text{t},'FontName',fontname,'FontSize',fontsize);
    txt_plot.Position(1) = txt_plot.Position(1) - txt_plot.Extent(3)/2;
    if plot_corrp(t) < alpha
        txt_plot.Color = 'red';
        txt_plot.FontWeight = 'bold';
    end
end