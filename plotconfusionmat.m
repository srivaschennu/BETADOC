function plotconfusionmat(confmat,groupnames,varargin)

param = finputcheck(varargin, {
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], ''; ...
    'clim', 'real', [], [0 100]; ...
    });

fontname = 'Helvetica';
fontsize = 30;

rowsum = sum(confmat,2);
confmat = confmat*100 ./ repmat(rowsum,1,size(confmat,2));

figure('Color','white');
himage = imshow(confmat,jet,'DisplayRange',[0 100],'InitialMagnification',3000);
himage.CDataMapping = 'scaled';

figpos = get(gcf,'Position');
figpos(3:4) = 1000;
set(gcf,'Position',figpos);
set(gca,'YDir','normal','Visible','on',...
    'XTick',1:size(confmat,2),'XTickLabel',groupnames,...
    'YTick',1:size(confmat,1),'YTickLabel',cell(size(groupnames)),...
    'FontName',fontname,'FontSize',fontsize-2);

colorbar('EastOutside','FontSize',fontsize-2);
caxis(param.clim);

for c1 = 1:size(confmat,1)
    for c2 = 1:size(confmat,2)
        h_txt = text(c2-0.25,c1,sprintf('%d%%',round(confmat(c1,c2))),'FontName',fontname,'FontSize',fontsize);
        if confmat(c1,c2) > 30 && confmat(c1,c2) < 70
            set(h_txt,'Color','black');
        else
            set(h_txt,'Color','white');
        end
    end
end

xlimits = xlim;
maxext = 0;
for r = 1:length(rowsum)
    h_txt(r) = text(xlimits(1)-0.1,r,sprintf('%s\n(%d)',groupnames{r},rowsum(r)),'FontName',fontname,'FontSize',fontsize-2);
    textext = get(h_txt(r),'Extent');
    maxext = max(maxext,textext(3));
end

for t = 1:length(h_txt)
    set(h_txt(t),'Position',[xlimits(1)-0.1-maxext,t]);
end

for s = 1:size(confmat,1)-1
    line(s+[0.5 0.5],[0.5 size(confmat,1)+0.5],'LineWidth',1,'Color','black');
    line([0.5 size(confmat,2)+0.5],s+[0.5 0.5],[1.5 1.5],'LineWidth',1,'Color','black');
end

if ~isempty(param.xlabel)
    xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize-2);
else
    xlabel('EEG prediction','FontName',fontname,'FontSize',fontsize-2);
end
if ~isempty(param.ylabel)
    h_lab = ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize-2);
else
    h_lab = ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize-2);
end
labpos = get(h_lab,'Position');
set(h_lab,'Position',[labpos(1)-0.1-maxext,labpos(2)]);