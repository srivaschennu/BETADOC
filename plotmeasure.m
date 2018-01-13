function [scores,group,stats] = plotmeasure(listname,conntype,measure,bandidx,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'xlabel', 'string', [], ''; ...
    'ylabel', 'string', [], measure; ...
    'xlim', 'real', [], []; ...
    'ylim', 'real', [], []; ...
    'xtick', 'real', [], []; ...
    'ytick', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'legendlocation', 'string', [], 'Best'; ...
    'noplot', 'string', {'on','off'}, 'off'; ...
    'plotcm', 'string', {'on','off'}, 'off'; ...
    });

fontname = 'Helvetica';
fontsize = 24;

loadpaths
loadsubj
changroups

subjlist = eval(listname);

loadcovariates

load sortedlocs

groupvar = eval(param.group);

% disable non-tbi
% groupvar(etiology == 0) = NaN;

groups = unique(groupvar(~isnan(groupvar)));

colorlist = [
    0 0.0 0.5
    0 0.5 0
    0.5 0.0 0
    0   0.5 0.5
    0.5 0   0.5
    0.5 0.5 0
    ];

facecolorlist = [
    0.75  0.75 1
    0.25 1 0.25
    1 0.75 0.75
    0.75 1 1
    1 0.75 1
    1 1 0.5
    ];

groupnames = param.groupnames;

weiorbin = 3;
plottvals = [];

if strcmpi(measure,'power')
    %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'bandpower');
    testdata = mean(bandpower(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup))),3) * 100;
elseif strcmpi(measure,'specent')
    %     load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'specent');
    testdata = mean(specent(:,ismember({sortedlocs.labels},eval(param.changroup))),2);
elseif strcmpi(measure,'median')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
    testdata = median(median(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'mean')
    load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype),'allcoh');
    testdata = mean(mean(allcoh(:,bandidx,ismember({sortedlocs.labels},eval(param.changroup)),ismember({sortedlocs.labels},eval(param.changroup2))),4),3);
elseif strcmpi(measure,'refdiag') || strcmpi(measure,'crs') || strcmpi(measure,'auditory') || strcmpi(measure,'visual') || strcmpi(measure,'motor') || ...
        strcmpi(measure,'verbal') || strcmpi(measure,'communication') || strcmpi(measure,'arousal') || strcmpi(measure,'etiology')
    testdata = eval(lower(measure));
else
    trange = [0.9 0.1];
    load(sprintf('%s%s//graphdata_%s_%s.mat',filepath,conntype,listname,conntype),'graph','tvals');
    trange = (tvals <= trange(1) & tvals >= trange(2));
    plottvals = tvals(trange);
    
    if strcmpi(measure,'small-worldness')
        randgraph = load(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype));
        graph{end+1,1} = 'small-worldness';
        graph{end,2} = ( mean(graph{1,2},4) ./ mean(randgraph.graph{1,2},4) ) ./ ( graph{2,2} ./ randgraph.graph{2,2} ) ;
        graph{end,3} = ( mean(graph{1,3},4) ./ mean(randgraph.graph{1,3},4) ) ./ ( graph{2,3} ./ randgraph.graph{2,3} ) ;
    end
    
    %     if ~strcmpi(measure,'small-worldness')
    %         m = find(strcmpi(measure,graph(:,1)));
    %         graph{m,2} = graph{m,2} ./ randgraph.graph{m,2};
    %         graph{m,3} = graph{m,3} ./ randgraph.graph{m,3};
    %     end
    
    m = find(strcmpi(measure,graph(:,1)));
    if strcmpi(measure,'modules')
        testdata = squeeze(max(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
    elseif strcmpi(measure,'centrality')
        testdata = squeeze(std(graph{m,weiorbin}(:,bandidx,trange,:),[],4));
    elseif strcmpi(measure,'mutual information')
        testdata = squeeze(mean(graph{m,weiorbin}(:,:,bandidx,trange),2));
    elseif strcmpi(measure,'participation coefficient') || strcmpi(measure,'degree')
%         testdata = squeeze(zscore(graph{m,weiorbin}(:,bandidx,trange,:),0,4));
%         testdata = mean(testdata(:,:,ismember({sortedlocs.labels},eval(param.changroup))),3);
        
        testdata = squeeze(std(graph{m,weiorbin}(:,bandidx,trange,ismember({sortedlocs.labels},eval(param.changroup))),[],4));

        %         testdata = squeeze(graph{m,weiorbin}(:,bandidx,trange,:));
        %         testdata = testdata - repmat(quantile(testdata,0.75,3),1,1,size(testdata,3));
        %         testdata(testdata < 0) = NaN;
        %         testdata = nanmean(testdata,3);
%         testdata = squeeze(graph{m,weiorbin}(:,bandidx,trange,:));
    elseif strcmpi(measure,'characteristic path length')
        testdata = round(squeeze(mean(graph{m,weiorbin}(:,bandidx,trange,:),4)));
    else
        testdata = squeeze(mean(graph{m,weiorbin}(:,bandidx,trange,:),4));
    end
end

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

if strcmp(param.noplot,'off')
    for g = 1:length(groups)
        plotdata = mean(testdata(groupvar == groups(g),:,:),3);
        groupmean(g,:) = nanmean(plotdata);
        groupste(g,:) = nanstd(plotdata)./sqrt(sum(~isnan(plotdata),1));
    end
    
    if ~isempty(plottvals)
        %% plot graph across connection densities
        
        figure('Color','white');
        hold all
        set(gca,'XDir','reverse');
        for g = 1:length(groups)
            errorbar(plottvals,groupmean(g,:),groupste(g,:),'LineWidth',1,'Color',colorlist(g,:));
        end
        set(gca,'XLim',[plottvals(end)-0.01 plottvals(1)+0.01],'FontName',fontname,'FontSize',fontsize);
        xlabel('Graph connection density','FontName',fontname,'FontSize',fontsize);
        ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
        if ~isempty(param.ylim)
            set(gca,'YLim',param.ylim);
        end
        legend(groupnames,'Location',param.legendlocation);
        export_fig(gcf,sprintf('figures/%s_%s_%s_%s.eps',conntype,measure,bands{bandidx},param.group),'-r300','-p0.01');
        close(gcf);
    end
end

groups = unique(groupvar(~isnan(groupvar)));
grouppairs = nchoosek(groups,2);

for g = 1:size(grouppairs,1)
    grouppairnames{g} = sprintf('%s-%s',groupnames{groups == grouppairs(g,1)},groupnames{groups == grouppairs(g,2)});
    thisgroupvar = groupvar(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2));
    [~,~,thisgroupvar] = unique(thisgroupvar);
    thisgroupvar = thisgroupvar-1;
    thistestdata = testdata(groupvar == grouppairs(g,1) | groupvar == grouppairs(g,2),:,:);
    
    for d = 1:size(thistestdata,2)
        thistestdata2 = squeeze(thistestdata(:,d,:));
        
        [x,y,t,auc(g,d)] = perfcurve(thisgroupvar, thistestdata2,1);
        if auc(g,d) < 0.5
            auc(g,d) = 1-auc(g,d);
        end
        
        [~,bestthresh] = max(abs(y + (1-x) - 1));
        %         [~,bestthresh] = min(sqrt((0-x).^2 + (1-y).^2));
        thisconfmat = confusionmat(thisgroupvar,double(thistestdata(:,d) > t(bestthresh)));
        [~,chi2(g,d),chi2pval(g,d)] = crosstab(thisgroupvar,double(thistestdata(:,d) > t(bestthresh)));
        accu(g,d) = sum(thisgroupvar == double(thistestdata(:,d) > t(bestthresh)))*100/length(thisgroupvar);
        confmat(g,d,:,:) = thisconfmat;
        [pval(g,d),~,stat] = ranksum(thistestdata(thisgroupvar == 0,d),thistestdata(thisgroupvar == 1,d));
        n0 = sum(thisgroupvar == 0); n1 = sum(thisgroupvar == 1);
        U(g,d) = (n0*n1)+(n0*(n0+1))/2-stat.ranksum;
        U(g,d) = min(U(g,d),(n0*n1) - U(g,d));
    end
    
    [~,maxaucidx] = max(auc(g,:));
    stats(g).U = U(g,maxaucidx);
    stats(g).auc = auc(g,maxaucidx);
    stats(g).pval = pval(g,maxaucidx);
    stats(g).confmat = squeeze(confmat(g,maxaucidx,:,:));
    stats(g).maxaucidx = maxaucidx;
    stats(g).chi2 = chi2(g,maxaucidx);
    stats(g).chi2pval = chi2pval(g,maxaucidx);
    stats(g).accu = accu(g,maxaucidx);
    
    if strcmp(param.noplot,'off')
        fprintf('%s %s: %s vs %s AUC = %.2f, J = %.2f, p = %.4f.\n',measure,bands{bandidx},...
            param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},...
            auc(g,maxaucidx),(thisconfmat(2,2) + thisconfmat(1,1))/100 - 1, pval(g,maxaucidx));
        if strcmp(param.plotcm,'on')
            plotconfusionmat(squeeze(confmat(g,maxaucidx,:,:)),{param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1}});
            set(gca,'FontName',fontname,'FontSize',fontsize);
            if ~isempty(param.xlabel)
                xlabel(param.xlabel,'FontName',fontname,'FontSize',fontsize);
            else
                xlabel('EEG diagnosis','FontName',fontname,'FontSize',fontsize);
            end
            if ~strcmp(param.ylabel,measure)
                ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
            else
                ylabel('CRS-R diagnosis','FontName',fontname,'FontSize',fontsize);
            end
            export_fig(gcf,sprintf('figures/%s_vs_%s_%s_cm.tiff',param.groupnames{grouppairs(g,1)+1},param.groupnames{grouppairs(g,2)+1},measure));
            close(gcf);
        end
    end
end

if strcmp(param.noplot,'off')
    %% plot mean graph
    figure('Color','white');
        figpos = get(gcf,'Position');
    if length(groups) == 2
        figpos(3) = figpos(3)*1/2;
    elseif length(groups) == 3
        figpos(3) = figpos(3)*2/3;
    end
    set(gcf,'Position',figpos);
    
    hold all
    
    boxh = notBoxPlot(nanmean(testdata,2),groupvar+1,0.5,'patch',ones(size(testdata,1),1));
    
    if length(groups) > 2
        jttestdata = nanmean(testdata(groupvar < 5,:),2);
        jtgroupvar = groupvar(groupvar < 5) + 1;
        [jtgroupvar,sortidx] = sort(jtgroupvar);
        jttestdata = jttestdata(sortidx);
        [~,JT,pval] = evalc('jttrend([jttestdata jtgroupvar])');
        if pval < 0.0001
            fprintf('\nJonckheere-Terpstra JT = %.2f, p = %.1e.\n',JT,pval);
        else
            fprintf('\nJonckheere-Terpstra JT = %.2f, p = %.4f.\n',JT,pval);
        end
    end
    
    for h = 1:length(boxh)
        set(boxh(h).data,'Color',colorlist(h,:),'MarkerFaceColor',facecolorlist(h,:))
    end
    set(gca,'XLim',[0.5 length(groups)+0.5],'XTick',1:length(groups),...
        'XTickLabel',groupnames','FontName',fontname,'FontSize',fontsize);
    ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
    if ~isempty(param.ylim)
        set(gca,'YLim',param.ylim);
    end
    if ~isempty(param.ytick)
        set(gca,'YTick',param.ytick);
    end
    set(gcf,'Color','white');
    if ~isempty(param.ylim)
        ylim(param.ylim);
    end
    if strcmp(param.legend,'off')
        legend('hide');
    end
    box off
    export_fig(gcf,sprintf('figures/%s_avg_%s_%s_%s.tiff',conntype,measure,bands{bandidx},param.group),'-r300','-p0.01');
    close(gcf);
    
    %% plot auc
    figure('Color','white');
    hold all
    if ~isempty(plottvals)
        set(gca,'XDir','reverse');
        for g = 1:size(grouppairs,1)
            plot(plottvals,auc(g,:),'LineWidth',2);
        end
        set(gca,'XLim',[plottvals(end) plottvals(1)]);
        xlabel('Graph connection density','FontName',fontname,'FontSize',fontsize);
        legend(grouppairnames,'Location',param.legendlocation);
        ylabel('AUC','FontName',fontname,'FontSize',fontsize);
        if ~isempty(param.ylim)
            set(gca,'YLim',param.ylim);
        else
            set(gca,'YLim',[0 1]);
        end
    else
        barh(auc(:,maxaucidx));
        ylim([0.5 size(auc,1)+0.5]);
        set(gca,'YTick',1:length(grouppairnames),'YTickLabels',grouppairnames);
        if ~isempty(param.xlim)
            set(gca,'XLim',param.ylim);
        else
            set(gca,'XLim',[0 1]);
        end
        xlabel('AUC','FontName',fontname,'FontSize',fontsize);
        xlimits = xlim;
        set(gca,'XTick',xlimits(1):0.1:xlimits(2),'YDir','reverse');
    end
    set(gca,'FontName',fontname,'FontSize',fontsize);
    
    export_fig(gcf,sprintf('figures/%s_auc_%s_%s_%s.tiff',conntype,measure,bands{bandidx},param.group),'-r300','-p0.01');
    close(gcf);
    
end

% %% correlate with days since onset
% [rho,pval] = corr(testdata(~isnan(daysonset)),daysonset(~isnan(daysonset)),'type','Spearman');
% fprintf('Correlation with days since onset = %.2f, p = %.4f.\n',rho,pval);
%
scores = testdata;
group = groupvar;