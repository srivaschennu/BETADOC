function plotsess

loadsubj

betadoc = betadoc(2:end,:);

subjnum = cellfun(@(x) str2num(x(2:3)), betadoc(:,1));
uniqsubj = unique(subjnum);
sessnum = cellfun(@(x) str2num(x(end)), betadoc(:,1));
sessdates = cellfun(@makedate, betadoc(:,end));

fontname = 'Helvetica';
fontsize = 28;

figure('Color','white');
figpos = get(gcf,'Position');
figpos(3) = figpos(3) * 2;
figpos(4) = figpos(4) * 2;
set(gcf,'Position',figpos);
hold all

firstdate = sessdates(1);
for subjidx = 1:length(uniqsubj)
    subjdates = sessdates(subjnum == uniqsubj(subjidx));
    plot(days(subjdates - firstdate), ...
        repmat(uniqsubj(subjidx),1,length(subjdates)), ...
        'Marker','o','MarkerFaceColor', [0.75 1 0.75], 'LineWidth', 3, ...
        'MarkerSize', 15, 'Color', [0.5  0 0.5]);
end

set(gca,'FontName',fontname,'FontSize',fontsize);
set(gca,'YDir','reverse','YMinorGrid','on','YLim',[1 length(uniqsubj)],'MinorGridLineStyle','-');
xlabel('Days since start of data collection');
ylabel('Patient');
legend('Assessment','location','Best');
print(gcf,'figures/plotsess.tif','-dtiff','-r300');
close(gcf);

function sessdate = makedate(x)
x = num2str(x);

if length(x) == 7 
    dateformat = 'dMMyyyy';
elseif length(x) == 8
    dateformat = 'ddMMyyyy';
end

sessdate = datetime(x,'InputFormat',dateformat);