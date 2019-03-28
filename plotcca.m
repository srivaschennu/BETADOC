function plotcca

loadpaths

load([filepath 'cca_results.mat']);

alpha = 0.05;

fontname = 'Helvetica';
fontsize = 16;

num_cc = size(r,1);
num_rand = size(r,2)-1;

% eeg_corr = (eeg_corr .^ 2);% .* sign(eeg_corr);
% beh_corr = (beh_corr .^ 2);% .* sign(beh_corr);

figure('Color','white');
hold all
plot(r(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
bar(mean(r(:,2:end),2));
errorbar(mean(r(:,2:end),2), ...
    std(r(:,2:end),[],2), '.','LineWidth',2);
xlim([0 size(r,1)+1]);
set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');

sig_cc = find(stats(1).pF < alpha);

eeg_corr = eeg_corr .^2;
eeg_corr = sum(eeg_corr(:,1:3,:),2);

for i = 1%sig_cc
    fig_h = figure('Color','white','Name',sprintf('Canonical variable %d', i));
    set(fig_h,'Position', [fig_h.Position(1) fig_h.Position(2) fig_h.Position(3)*2 fig_h.Position(4)*2]);

    %     subplot(2,2,1);
    %     scatter(U(:,i,1), V(:,i,1),'filled');
    %     legend(sprintf('r = %.2f', r(i,1)));
    %     set(gca,'FontSize',fontsize,'FontName',fontname);
    %     title(sprintf('Canonical variable %d', i));
    
    plot_corr = squeeze(eeg_corr(:,i,:));
    plot_corrp = find(perm_fwer(squeeze(eeg_corr(:,i,:))) < alpha);
    
    subplot(2,1,1);
    hold all
    plot(plot_corr(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
    plot(plot_corrp,plot_corr(plot_corrp,1),'*','LineWidth',2);
    boxplot(plot_corr(:,2:end)','PlotStyle','compact','Symbol','');
%     bar(mean(plot_corr(:,2:end),2));
%     errorbar(mean(plot_corr(:,2:end),2), ...
%         std(plot_corr(:,2:end),[],2), '.','LineWidth',2);
    xticks(1:size(plot_corr,1));
    xticklabels(eeg.Properties.VariableNames(xticks)); xtickangle(45);
    xlim([0 size(plot_corr,1)+1]);
    title({sprintf('r = %.2f, p = %.3f', r(i,1), stats(1).pF(i)),'Canonical to EEG correlation'});
    set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');
    
    plot_corr = squeeze(beh_corr(:,i,:));
    plot_corrp = find(perm_fwer(squeeze(beh_corr(:,i,:))) < alpha);
    
    subplot(2,1,2);
    hold all
    plot(plot_corr(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
    plot(plot_corrp,plot_corr(plot_corrp,1),'*','LineWidth',2);
    boxplot(plot_corr(:,2:end)','PlotStyle','compact','Symbol','');
    %     bar(mean(plot_corr(:,2:end),2));
%     errorbar(mean(plot_corr(:,2:end),2), ...
%         std(plot_corr(:,2:end),[],2), '.','LineWidth',2);
    xticks(1:size(plot_corr,1));
    xticklabels(behaviour.Properties.VariableNames(xticks)); xtickangle(45);
    xlim([0 size(plot_corr,1)+1]);
    title('Canonical to Behaviour correlation');
    set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');
end

function fwer_pval = perm_fwer(stat)
fwer_pval = zeros(size(stat,1),1);
for i = 1:size(stat,1)  % get FWE-corrected pvalues
    if stat(i,1) >= 0
        fwer_pval(i) = (1+sum(stat(i,2:end)>=stat(i,1)))/(size(stat,2)-1);
    elseif stat(i,1) < 0
        fwer_pval(i) = (1+sum(stat(i,2:end)<=stat(i,1)))/(size(stat,2)-1);
    end
end
