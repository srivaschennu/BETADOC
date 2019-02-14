function plotsess

loadsubj

groupnames = {'UWS','MCS-','MCS+','EMCS'};

edgecolor = [0.5  0 0.5];

facecolorlist = [
    0.75  0.75 1
    0.25 1 0.25
    1 0.75 0.75
    0.75 1 1
    1 0.75 1
    1 1 0.5
    ];

betadoc = betadoc(2:end,:);

subjnum = cellfun(@(x) str2num(x(2:3)), betadoc(:,1));
uniqsubj = unique(subjnum);
sessnum = cellfun(@(x) str2num(x(end)), betadoc(:,1));
sessdates = cellfun(@makedate, betadoc(:,end));
crsdiag = cell2mat(betadoc(:,3));

fontname = 'Helvetica';
fontsize = 28;

figure('Color','white');
figpos = get(gcf,'Position');
figpos(3) = figpos(3) * 2;
figpos(4) = figpos(4) * 2;
set(gcf,'Position',figpos);
hold all

firstdate = sessdates(1);
sessdays = zeros(size(sessdates));
for subjidx = 1:length(uniqsubj)
    firstdate = sessdates(find(subjnum == uniqsubj(subjidx),1));
    sessdays(subjnum == uniqsubj(subjidx)) = ...
        days(sessdates(subjnum == uniqsubj(subjidx)) - firstdate);
    legendoff(plot(sessdays(subjnum == uniqsubj(subjidx)), ...
        repmat(uniqsubj(subjidx),1,sum(subjnum == uniqsubj(subjidx))), ...
        'LineWidth', 3, 'Color', edgecolor));
        %'Marker','o','MarkerFaceColor', [0.75 1 0.75],
end

uniqcrs = unique(crsdiag);
for crsidx = 1:length(uniqcrs)
    scatter(sessdays(crsdiag == uniqcrs(crsidx)), ...
        subjnum(crsdiag == uniqcrs(crsidx)), ...
        250, 'LineWidth', 1, ...
        'MarkerEdgeColor',edgecolor,'MarkerFaceColor',facecolorlist(crsidx,:));
end

set(gca,'FontName',fontname,'FontSize',fontsize);
set(gca,'YDir','reverse','YMinorGrid','on','YLim',[1 length(uniqsubj)],'MinorGridLineStyle','-');
box on
xlabel({'Times of CRS-R assessments relative to','recruitment into study (days)'});
%ylabel('Patient');
set(gca,'YTickLabel',[]);
[~,icons] = legend('UWS','MCS-','MCS+','EMCS','location','Best');
for g = 1:length(groupnames)
    set(icons(g+length(groupnames)).Children,'MarkerSize',16);
end

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