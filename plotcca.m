function plotcca

loadpaths

load([filepath 'cca_results.mat']);

alpha = 0.05;

fontname = 'Helvetica';
fontsize = 16;

eeg_varlabels = {
    '\mu(\delta power)'
    '\mu(\theta power)'
    '\mu(\alpha power)'
    '\sigma(\delta power)'
    '\sigma(\theta power)'
    '\sigma(\alpha power)'
    '\nu(\delta dwPLI)'
    '\nu(\theta dwPLI)'
    '\nu(\alpha dwPLI)'
    '\sigma(\delta dwPLI)'
    '\sigma(\theta dwPLI)'
    '\sigma(\alpha dwPLI)'
    '\mu(\delta clustering coeff.)'
    '\mu(\theta clustering coeff.)'
    '\mu(\alpha clustering coeff.)'
    '\sigma(\delta clustering coeff.)'
    '\sigma(\theta clustering coeff.)'
    '\sigma(\alpha clustering coeff.)'
    '\delta char. path length'
    '\theta char. path length'
    '\alpha char. path length'
    '\delta global eff.'
    '\theta global eff.'
    '\alpha global eff.'
    '\delta modularity'
    '\theta modularity'
    '\alpha modularity'
    '\mu(\delta centrality)'
    '\mu(\theta centrality)'
    '\mu(\alpha centrality)'
    '\sigma(\delta centrality)'
    '\sigma(\theta centrality)'
    '\sigma(\alpha centrality)'
    '\delta modular span'
    '\theta modular span'
    '\alpha modular span'
    '\mu(\delta participation coeff.)'
    '\mu(\theta participation coeff.)'
    '\mu(\alpha participation coeff.)'
    '\sigma(\delta participation coeff.)'
    '\sigma(\theta participation coeff.)'
    '\sigma(\alpha participation coeff.)'
    };

beh_varlabels = {
    'CRS-R diagnosis'
    'Initial Diagnosis'
    'Traumatic etiology?'
    'Age'
    'Male?'
    'Days since injury onset'
    'CRS-R auditory'
    'CRS-R visual'
    'CRS-R motor'
    'CRS-R verbal'
    'CRS-R communication'
    'CRS-R arousal'
    'Patient number'
    'Assessment number'
    };

[all_corr, all_p] = corr(table2array(beh), table2array(eeg));
[~, max_idx] = max(all_corr(:));
[beh_idx, eeg_idx] = ind2sub(size(all_corr),max_idx);

figure('Color','white','Name','Best pairwise correlation');
hold all
legendoff(scatter(table2array(beh(:,beh_idx)),table2array(eeg(:,eeg_idx)),50,'filled','MarkerEdgeColor','black'));
Fit = polyfit(table2array(beh(:,beh_idx)),table2array(eeg(:,eeg_idx)),1);
plot(sort(table2array(beh(:,beh_idx))), polyval(Fit,sort(table2array(beh(:,beh_idx)))), ...
    'LineStyle', '-.', 'Color', 'black', 'LineWidth', 2, ...
    'DisplayName',sprintf('r = %.2f, p = %.4f', all_corr(beh_idx,eeg_idx),all_p(beh_idx,eeg_idx)));
legend toggle
legend boxoff
set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');
xlabel(beh.Properties.VariableNames(beh_idx));
ylabel(eeg.Properties.VariableNames(eeg_idx));

[cca_corr, cca_p] = corr(U(:,:,1),V(:,:,1));
figure('Color','white','Name','Canonical covariate correlation');
hold all

legendoff(scatter(U(:,1,1),V(:,1,1),50,'filled','MarkerEdgeColor','black'));
Fit = polyfit(U(:,1,1),V(:,1,1),1);
plot(sort(U(:,1,1)), polyval(Fit,sort(U(:,1,1))), ...
    'LineStyle', '-.', 'Color', 'black', 'LineWidth', 2, ...
    'DisplayName',sprintf('r = %.2f, p = %.4f', cca_corr(1,1),cca_p(1,1)));
legend toggle
legend boxoff
set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');
xlabel('Behavioural canonical variate');
ylabel('EEG canonical variate');

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

siglevels = {
    0.001   'o'
    0.01    '+'
    0.05    '*'
    };
    
for i = sig_cc
%     fig_h = figure('Color','white','Name',sprintf('Canonical variable %d', i));
%     set(fig_h,'Position', [fig_h.Position(1) fig_h.Position(2) fig_h.Position(3)*2 fig_h.Position(4)*2]);
    
    for j = 1:2
        if j == 1
            plot_corr = eeg_corr(:,i,1);
            plot_corrp = eeg_corrp(:,i,1);
            varlabels = eeg_varlabels;
            title_text = 'clinical';
        else
            plot_corr = beh_corr(:,i,1);
            plot_corrp = beh_corrp(:,i,1);
            varlabels = beh_varlabels;
            title_text = 'EEG';
        end
        
        plot_corr = (plot_corr .^ 2 .* sign(plot_corr));
        [~,sortidx] = sort(abs(plot_corr),'descend');
%         subplot(2,1,j);
%         hold all
%         bar(plot_corr(sortidx));
%         xticks(1:length(plot_corr));
%         
%         if j == 1
%             fprintf('Canonical covariate %d to EEG correlation p-values (in sorted order):\n', i);
%         else
%             fprintf('Canonical covariate %d to behaviour correlation p-values (in sorted order):\n', i);
%         end
%         
%         disp(plot_corrp(sortidx));
%         
%         varlabels = varlabels(sortidx);
%         xticklabels(varlabels(xticks)); xtickangle(45);
%         xlim([0 size(plot_corr,1)+1]);
%         title({sprintf('r = %.2f, p = %.3f', r(i,1), stats(1).pF(i)), sprintf('Canonical to %s correlation', title_text)});
%         set(gca,'FontSize',fontsize,'FontName',fontname);
        
        textplot(plot_corr(sortidx), plot_corrp(sortidx), varlabels(sortidx), title_text);
        title({sprintf('Canonical variable %d', i), sprintf('r = %.2f, p = %.3f', r(i,1), stats(1).pF(i))});
        set(gcf,'Name', sprintf('Canonical variable %d', i))
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
