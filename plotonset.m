function plotonset

loadsubj

betadoc = betadoc(2:end,:);

subjnum = cellfun(@(x) str2num(x(2:3)), betadoc(:,1));
uniqsubj = unique(subjnum);
sessnum = cellfun(@(x) str2num(x(end)), betadoc(:,1));
daysonset = cell2mat(betadoc(:,8));
fontname = 'Helvetica';
fontsize = 28;

figure('Color','white');
figpos = get(gcf,'Position');
%figpos(3) = figpos(3) * 2;
figpos(4) = figpos(4) * 2;
set(gcf,'Position',figpos);
hold all

for subjidx = 1:length(uniqsubj)
    firstdate = find(subjnum == uniqsubj(subjidx),1);
    plot([0 daysonset(firstdate)/365], ...
        repmat(uniqsubj(subjidx),1,2), ...
        'LineWidth', 3, 'Color', [0 0.5 0.5]);
    scatter(daysonset(firstdate)/365, uniqsubj(subjidx), 250, ...
        'MarkerFaceColor', [0.75 0.75 0.75], 'LineWidth',1,'MarkerEdgeColor', [0 0.5 0.5]);
end

set(gca,'FontName',fontname,'FontSize',fontsize);
set(gca,'YDir','reverse','XDir','reverse','YMinorGrid','on','YLim',[1 length(uniqsubj)],'MinorGridLineStyle','-');
set(gca,'XTick',0:2:10,'YAxisLocation','right');
xlim([0 10]);
box on
xlabel({'Time since injury onset until','recruitment into study (years)'});
print(gcf,'figures/plotonset.tif','-dtiff','-r300');
close(gcf);

function sessdate = makedate(x)
x = num2str(x);

if length(x) == 7 
    dateformat = 'dMMyyyy';
elseif length(x) == 8
    dateformat = 'ddMMyyyy';
end

sessdate = datetime(x,'InputFormat',dateformat);