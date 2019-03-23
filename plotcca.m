function plotcca

load cca_results

fontname = 'Helvetica';
fontsize = 16;

figure('Color','white');
scatter(U(:,1,1), V(:,1,1),'filled');
legend(sprintf('r = %.2f', r(1,1)));
set(gca,'FontSize',fontsize,'FontName',fontname);

figure('Color','white');
hold all
plot(r(:,1),'-s','LineWidth',2,'MarkerFaceColor','auto');
bar(mean(r(:,2:end),2));
errorbar(mean(r(:,2:end),2), std(r(:,2:end),[],2), '.','LineWidth',2);
xlim([0 size(r,1)+1]);
set(gca,'FontSize',fontsize,'FontName',fontname);