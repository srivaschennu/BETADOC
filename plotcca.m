function plotcca

load cca_results

alpha = 0.05;

fontname = 'Helvetica';
fontsize = 16;

num_cc = size(r,1);
num_rand = size(r,2)-1;

figure('Color','white');
hold all
plot(stats(1).F,'-s','LineWidth',2,'MarkerFaceColor','auto');
randF = cell2mat({stats(2:end).F}');
bar(mean(randF,1));
errorbar(mean(randF,1), std(randF,[],1)/sqrt(num_rand), '.','LineWidth',2);
xlim([0 num_cc+1]);
set(gca,'FontSize',fontsize,'FontName',fontname);

sig_cc = find(stats(1).pF < alpha);
sig_eeg = [];
sig_beh = [];
for i = sig_cc
    figure('Color','white','Name',sprintf('Canonical variable %d', i));
    scatter(U(:,i,1), V(:,i,1),'filled');
    legend(sprintf('r = %.2f', r(i,1)));
    set(gca,'FontSize',fontsize,'FontName',fontname);
    title(sprintf('Canonical variable %d', i));
end

Tot_ve = sum(eeg_corr(:,sig_cc,:),2);

figure('Color','white');
hold all
plot(Tot_ve(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
bar(mean(Tot_ve(:,:,2:end),3));
errorbar(mean(Tot_ve(:,:,2:end),3), std(Tot_ve(:,:,2:end),[],3)/sqrt(num_rand), '.','LineWidth',2);
xticklabels(eeg.Properties.VariableNames(xticks+1)); xtickangle(45);
xlim([0 size(Tot_ve,1)+1]);
title('Canonical to EEG correlation');
set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');


Tot_ve = sum(beh_corr(:,sig_cc,:),2);

figure('Color','white');
hold all
plot(Tot_ve(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
bar(mean(Tot_ve(:,:,2:end),3));
errorbar(mean(Tot_ve(:,:,2:end),3), std(Tot_ve(:,:,2:end),[],3)/sqrt(num_rand), '.','LineWidth',2);
xticklabels(behaviour.Properties.VariableNames(xticks+1)); xtickangle(45);
xlim([0 size(Tot_ve,1)+1]);
title('Canonical to EEG correlation');
set(gca,'FontSize',fontsize,'FontName',fontname,'TickLabelInterpreter','none');