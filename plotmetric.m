function plotmetric(basename,measure,bandidx,varargin)

listname = 'allsubj';
conntype = 'ftdwpli';

loadpaths

param = finputcheck(varargin, {
    'ylim', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'on'; ...
    'plotinfo', 'string', {'on','off'}, 'on'; ...
    'plotticks', 'string', {'on','off'}, 'on'; ...
    'ylabel', 'string', {}, measure; ...
    'randratio', 'string', {'on','off'}, 'off'; ...
    'legendposition', 'string', {}, 'NorthEast'; ...
    });

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

% merge MCS- and MCS+
grp(grp == 2) = 1;

groups = [0 1 5];
groupnames = {
    'VS'
    'MCS'
    'CTRL'
    };

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

selpatidx = ismember(grp,groups);

if strcmp(measure,'modules')
    groupvals = squeeze(mean(max(graph{m,weiorbin}(selpatidx,bandidx,trange,:),[],4),3));
    patvals = squeeze(mean(max(graphdata{m,weiorbin}(bandidx,:,:),[],3),2));
elseif strcmp(measure,'mutual information')
    groupvals = squeeze(mean(mean(graph{m,weiorbin}(selpatidx,grp == groups(g),bandidx,trange),4),2));
    patvals = squeeze(mean(mean(graphdata{m,weiorbin}(grp == groups(g),bandidx,trange),4),2));
elseif strcmp(measure,'participation coefficient')
    groupvals = squeeze(mean(std(graph{m,weiorbin}(selpatidx,bandidx,trange,:),[],4),3));
    patvals = squeeze(mean(std(graphdata{m,weiorbin}(bandidx,trange,:),[],3),2));
elseif strcmp(measure,'median')
    groupvals = nanmedian(allcoh(selpatidx,bandidx,:),3);
    patvals = nanmedian(matrix(bandidx,:),2);
else
    groupvals = squeeze(mean(mean(graph{m,weiorbin}(selpatidx,bandidx,trange,:),4),3));
    patvals = squeeze(mean(mean(graphdata{m,weiorbin}(bandidx,trange,:),3),2));
end

plotvals = cat(1,groupvals,patvals);
groupnames = cat(1,groupnames,{'Patient'});

figure('Color','white','Name',basename)
% boxplot(plotvals,[grp(selpatidx); max(grp(selpatidx))+1],'labels',groupnames,'symbol','r');
plotgroups = [grp(selpatidx); max(grp(selpatidx))+1];
[plotgroups,~,uniqgroups] = unique(plotgroups);
boxh = notBoxPlot(plotvals,uniqgroups,0.5,'patch',ones(length(plotvals),1));
for h = 1:length(boxh)
    set(boxh(h).data,'Color',colorlist(h,:),'MarkerFaceColor',facecolorlist(h,:))
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

