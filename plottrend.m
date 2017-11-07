function [scores,group,stats,pet] = plottrend(listname,conntype,measure,bandidx,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'traj', 'integer', [1 2 3], []; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS'}; ...
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
fontsize = 28;


loadpaths
loadsubj
changroups

subjlist = eval(listname);

loadcovariates

load sortedlocs

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


bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

[testdata,groupvar] = plotmeasure(listname,conntype,measure,bandidx,'noplot','on','group',param.group,'groupnames',param.groupnames);
groups = unique(groupvar(~isnan(groupvar)));

if ~isempty(param.traj)
    subjlist = subjlist(trajectory == param.traj,:);
    testdata = testdata(trajectory == param.traj,:);
    groupvar = groupvar(trajectory == param.traj);
end

subjnum = cellfun(@(x) str2num(x(2:3)), subjlist(:,1));
uniqsubj = unique(subjnum);
sessnum = cellfun(@(x) str2num(x(end)), subjlist(:,1));

testdata = mean(testdata,2);
figure('Color','white');
hold all

alldata = {};
for s = 1:length(uniqsubj)
    plotdata = testdata(subjnum == uniqsubj(s));
%     plotdata = plotdata - plotdata(1);
%     testdata(subjnum == uniqsubj(s)) = plotdata;
    legendoff(plot(sessnum(subjnum == uniqsubj(s)),plotdata,'LineWidth',1));
    alldata(s,sessnum(subjnum == uniqsubj(s))) = num2cell(plotdata);
end

alldata = cellfun(@checkval, alldata);
legendoff(plot(1:size(alldata,2),nanmedian(alldata,1),'LineWidth',3,'Color','black'));

for g = groups'
    scatter(sessnum(groupvar == g),testdata(groupvar == g),150,...
        'MarkerFaceColor',facecolorlist(g+1,:),'MarkerEdgeColor',colorlist(g+1,:));
end

set(gca,'XTick',unique(sessnum),'FontName',fontname,'FontSize',fontsize);
[~,icons,~,~] = legend(param.groupnames(1:length(groups)),'Location','SouthEast');
for i = 1:4
    icons(i).FontSize = 22;
    icons(i+4).Children.MarkerSize = 12;
end
ylabel(param.ylabel);

function x = checkval(x)
if isempty(x)
    x = NaN;
end