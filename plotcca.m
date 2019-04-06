function plotcca

loadpaths

load([filepath 'cca_results.mat']);

alpha = 0.05;

fontname = 'Helvetica';
fontsize = 16;

num_cc = size(r,1);
num_rand = size(r,2)-1;

r_sig = find(perm_fwer(r) < alpha);
figure('Color','white','Name','Canonical correlations');
hold all
plot(r(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
plot(r_sig,r(r_sig,1),'*','LineWidth',2);
bar(mean(r(:,2:end),2));
errorbar(mean(r(:,2:end),2), ...
    std(r(:,2:end),[],2), '.','LineWidth',2);
xlim([0 size(r,1)+1]);
set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');

% for i = 1:2
%     if i == 1
%         tot_ve = squeeze(sum(eeg_corr.^2,1));
%         figname = 'EEG variance explained';
%     else
%         tot_ve = squeeze(sum(beh_corr.^2,1));
%         figname = 'Behavioural variance explained';
%     end
%     figure('Color','white','Name',figname);
%     hold all
%     plot(tot_ve(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
%     bar(mean(tot_ve(:,2:end),2));
%     errorbar(mean(tot_ve(:,2:end),2), ...
%         std(tot_ve(:,2:end),[],2), '.','LineWidth',2);
%     xlim([0 size(r,1)+1]);
%     set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');
% end

sig_cc = find(stats(1).pF < alpha);

for i = sig_cc
    fig_h = figure('Color','white','Name',sprintf('Canonical variable %d', i));
    set(fig_h,'Position', [fig_h.Position(1) fig_h.Position(2) fig_h.Position(3)*2 fig_h.Position(4)*2]);
    
    for j = 1:2
        if j == 1
            plot_corr = eeg_corr(:,i,1);
            varnames = eeg.Properties.VariableNames;
        else
            plot_corr = beh_corr(:,i,1);
            varnames = beh.Properties.VariableNames;
        end
        
        plot_corr = (plot_corr .^ 2 .* sign(plot_corr));
        [~,sortidx] = sort(abs(plot_corr),'descend');
        subplot(2,1,j);
        hold all
        bar(plot_corr(sortidx));
        xticks(1:length(plot_corr));
        
        varnames = varnames(sortidx);
        xticklabels(varnames(xticks)); xtickangle(45);
        xlim([0 size(plot_corr,1)+1]);
        title({sprintf('r = %.2f, p = %.3f', r(i,1), stats(1).pF(i)),'Canonical to EEG correlation'});
        set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');
    end
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
