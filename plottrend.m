function [scores,group,stats,pet] = plottrend(listname,conntype,measures,bandidx,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'traj', 'integer', [1 2 3], []; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS'}; ...
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'xlabel', 'string', [], 'Assessment'; ...
    'ylabel', 'string', [], measures{1}; ...
    'xlim', 'real', [], []; ...
    'ylim', 'real', [], []; ...
    'xtick', 'real', [], []; ...
    'ytick', 'real', [], []; ...
    'legend', 'string', {'on','off'}, 'off'; ...
    'legendlocation', 'string', [], 'Best'; ...
    'noplot', 'string', {'on','off'}, 'off'; ...
    'plotcm', 'string', {'on','off'}, 'off'; ...
    'patient', 'string', {}, ''; ...
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
    0.5 0 0
    0  0.5 0
    0  0 0.5
    0.5 0.5 0.5
    ];

facecolorlist = [
    0.75  0.75 1
    0.25 1 0.25
    1 0.75 0.75
    0.75 1 1
    1 0.75 1
    1 1 0.5
    1 0 0
    0 1 0
    0 0 1
    0.25 0.25 0.25
    ];

markerlist = {
    '^'
    'v'
    '<'
    '>'
    'square'
    'diamond'
    };

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

h_fig = figure('Color','white');
% h_fig.Position(3) = h_fig.Position(3) * 2/3;

hold all

for m = 1:length(measures)
    measure = measures{m};
    [testdata,groupvar] = plotmeasure(listname,conntype,measure,bandidx,'noplot','on','group',param.group,'groupnames',param.groupnames);
    groups = unique(groupvar(~isnan(groupvar)));
    
    if ~isempty(param.traj)
        thissubjlist = subjlist(trajectory == param.traj,:);
        testdata = testdata(trajectory == param.traj,:);
        groupvar = groupvar(trajectory == param.traj);
    end
    
    if ~isempty(param.patient)
        patidx = strncmp(param.patient,subjlist(:,1),length(param.patient));
        thissubjlist = subjlist(patidx,:);
        testdata = testdata(patidx,:);
        groupvar = groupvar(patidx,:);
    end
    
    subjnum = cellfun(@(x) str2num(x(2:3)), thissubjlist(:,1));
    uniqsubj = unique(subjnum);
    sessnum = cellfun(@(x) str2num(x(end)), thissubjlist(:,1));
    
    testdata = mean(testdata,2);
    
    alldata = {};
    for s = 1:length(uniqsubj)
        plotdata = testdata(subjnum == uniqsubj(s));
        %         plotdata = (plotdata - plotdata(1))*100/plotdata(1);
        %         testdata(subjnum == uniqsubj(s)) = plotdata;
        if m == 1
            legendoff(plot(sessnum(subjnum == uniqsubj(s)),plotdata,'LineWidth',1,'Color','black'));
            scores = plotdata;
        elseif m > 1
            plot(sessnum(subjnum == uniqsubj(s)),plotdata,'LineWidth',1,'Color',[0.5 0.5 0.5],...
                'LineStyle','none','Marker',markerlist{m-1},'MarkerSize',15,'DisplayName',measures{m},...
                'MarkerFaceColor',facecolorlist(end-m+2,:),'MarkerEdgeColor',colorlist(end-m+2,:));
        end
    end
    
    if m == 1
        for g = groups'
            scatter(sessnum(groupvar == g),testdata(groupvar == g),250,...
                'MarkerFaceColor',facecolorlist(g+1,:),'MarkerEdgeColor',colorlist(g+1,:),'DisplayName',param.groupnames{g+1});
        end
    end
end

set(gca,'XLim',[0.5 sessnum(end)+0.5],'XTick',unique(sessnum),'FontName',fontname,'FontSize',fontsize);

if strcmp(param.legend,'on')
    [~,icons,~,~] = legend('show','Location',param.legendlocation);
    for i = 1:length(icons)
        if isa(icons(i),'matlab.graphics.primitive.Group')
            icons(i).Children.MarkerSize = 15;
        elseif isa(icons(i),'matlab.graphics.primitive.Text')
            icons(i).FontSize = 22;
        end
    end
end

xlabel(param.xlabel);
ylabel(param.ylabel);

if ~isempty(param.ylim)
    ylim(param.ylim);
end

if ~isempty(param.patient)
    print(gcf,sprintf('figures/trend_%s_%s_%s.tif',param.patient,measures{1},bands{bandidx}),'-dtiff','-r300');
end

close(gcf);