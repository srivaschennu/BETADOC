function plotmetric(basename,measure,bandidx,varargin)

listname = 'allsubj';
conntype = 'ftdwpli';

loadpaths

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTRL'}; ...
    'ylim', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'on'; ...
    'plotinfo', 'string', {'on','off'}, 'on'; ...
    'plotticks', 'string', {'on','off'}, 'on'; ...
    'ylabel', 'string', {}, measure; ...
    'randratio', 'string', {'on','off'}, 'off'; ...
    'legendposition', 'string', {}, 'NorthEast'; ...
    });

loadsubj
subjlist = eval(listname);
loadcovariates

groupvar = eval(param.group);
groups = unique(groupvar(~isnan(groupvar)));
groupnames = param.groupnames;

fontname = 'Helvetica';
fontsize = 28;

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

load(sprintf('%s/%s_betadoc.mat',filepath,basename));
load(sprintf('%s/%s_betadoc.mat',filepath,basename),'freqs');
bpower = zeros(size(freqlist,1),length(chanlocs));
for f = 1:size(freqlist,1)
    [~, bstart] = min(abs(freqs-freqlist(f,1)));
    [~, bstop] = min(abs(freqs-freqlist(f,2)));
    [~,peakindex] = max(mean(spectra(:,bstart:bstop),1),[],2);
    bpower(f,:) = spectra(:,bstart+peakindex-1);
end
for c = 1:size(bpower,2)
    bpower(:,c) = bpower(:,c)./sum(bpower(:,c));
end

load(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype));
load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));

weiorbin = 3;

if strcmpi(measure,'small-worldness') || strcmp(param.randratio,'on')
    if exist(sprintf('%s/%s/%s%srandgraph.mat',filepath,conntype,basename,conntype),'file')
        randgraphdata = load(sprintf('%s/%s/%s%srandgraph.mat',filepath,conntype,basename,conntype));
    else
        error('%s/%s/%s%srandgraph.mat not found!',filepath,conntype,basename,conntype);
    end
    if exist(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype),'file')
        randgraph = load(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype));
    else
        error('%s/%s/graphdata_%s_rand_%s.mat not found!',filepath,conntype,listname,conntype);
    end
end

if strcmpi(measure,'small-worldness')
    graphdata{end+1,1} = 'small-worldness';
    graphdata{end,2} = ( mean(graphdata{1,2},3) ./ mean(mean(randgraphdata.graphdata{1,2},4),3) ) ./ ( graphdata{2,2} ./ mean(randgraphdata.graphdata{2,2},3) ) ;
    graph{end+1,1} = 'small-worldness';
    graph{end,2} = ( mean(graph{1,2},4) ./ mean(mean(randgraph.graph{1,2},5),4) ) ./ ( graph{2,2} ./ mean(randgraph.graph{2,2},4) ) ;
elseif strcmp(param.randratio,'on')
    m = find(strcmpi(measure,graphdata(:,1)));
    graphdata{m,2} = graphdata{m,2} ./ mean(randgraphdata.graph{m,2},ndims(randgraphdata.graph{m,2}));
    m = find(strcmpi(measure,graph(:,1)));
    graph{m,2} = graph{m,2} ./ mean(randgraph.graph{m,2},ndims(randgraph.graph{m,2}));
end

if strcmp(param.group, 'crsdiag')
    % merge MCS- and MCS+
    groupvar(groupvar == 2) = 1;
    groups = [0 1 5];
    groupnames = {'VS', 'MCS', 'CTRL'};
end

bands = {
    'Delta'
    'Theta'
    'Alpha'
    'Beta'
    'Gamma'
    };

trange = [0.9 0.1];
precision = 3;
tvals = floor(tvals * 10^precision)/10^precision;
trange = (tvals <= trange(1) & tvals >= trange(2));

m = find(strcmpi(measure,graph(:,1)));

barvals = zeros(3,length(groups));
errvals = zeros(3,length(groups));

selpatidx = ismember(groupvar,groups);

if strcmp(measure,'modules')
    groupvals = squeeze(mean(max(graph{m,weiorbin}(selpatidx,bandidx,trange,:),[],4),3));
    patvals = squeeze(mean(max(graphdata{m,weiorbin}(bandidx,:,:),[],3),2));
elseif strcmp(measure,'mutual information')
    groupvals = squeeze(mean(mean(graph{m,weiorbin}(selpatidx,groupvar == groups(g),bandidx,trange),4),2));
    patvals = squeeze(mean(mean(graphdata{m,weiorbin}(groupvar == groups(g),bandidx,trange),4),2));
elseif strcmp(measure,'participation coefficient')
    groupvals = squeeze(mean(std(graph{m,weiorbin}(selpatidx,bandidx,trange,:),[],4),3));
    patvals = squeeze(mean(std(graphdata{m,weiorbin}(bandidx,trange,:),[],3),2));
elseif strcmp(measure,'median')
    groupvals = nanmedian(allcoh(selpatidx,bandidx,:),3);
    patvals = nanmedian(matrix(bandidx,:),2);
elseif strcmpi(measure,'power')
    groupvals = nanmedian(bandpower(selpatidx,bandidx,:),3) * 100;
    patvals = nanmedian(bpower(bandidx,:),2) * 100;
else
    groupvals = squeeze(mean(mean(graph{m,weiorbin}(selpatidx,bandidx,trange,:),4),3));
    patvals = squeeze(mean(mean(graphdata{m,weiorbin}(bandidx,trange,:),3),2));
end

plotvals = cat(1,groupvals,patvals);
groupnames = cat(2,groupnames,{'Patient'});

figure('Color','white','Name',basename)
% boxplot(plotvals,[groupvar(selpatidx); max(groupvar(selpatidx))+1],'labels',groupnames,'symbol','r');
plotgroups = [groupvar(selpatidx); max(groupvar(selpatidx))+1];
[plotgroups,~,uniqgroups] = unique(plotgroups);
boxh = notBoxPlot(plotvals,uniqgroups,0.5,'patch',ones(length(plotvals),1));
for h = 1:length(boxh)
    set(boxh(h).data,'Color',colorlist(h,:),'MarkerSize',10,'MarkerFaceColor',facecolorlist(h,:))
end
set(gca,'XLim',[0.5 length(plotgroups)+0.5],'XTick',1:length(plotgroups),...
    'XTickLabel',groupnames,'FontName',fontname,'FontSize',fontsize);

if strcmp(param.plotticks,'on')
    set(gca,'FontName',fontname,'FontSize',fontsize);
    ylabel(param.ylabel,'FontName',fontname,'FontSize',fontsize);
end

if ~isempty(param.ylim)
    ylim(param.ylim);
end

print(sprintf('figures/%s_%s_%s.tif',basename,measure,bands{bandidx}),'-dtiff','-r150');
close(gcf);

