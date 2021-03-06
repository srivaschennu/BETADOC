function plotmeangraph(listname,conntype,bandidx,varargin)

loadpaths
param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS','LIS','CTR'}; ...
    });

load(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype));
load sortedlocs

refdiag = cell2mat(subjlist(:,2));
refaware = double(cell2mat(subjlist(:,2)) > 0);
refaware(isnan(refdiag)) = NaN;
crsdiag = cell2mat(subjlist(:,3));
crsaware = double(cell2mat(subjlist(:,3)) > 0);
petdiag = cell2mat(subjlist(:,4));
tennis = cell2mat(subjlist(:,5));
etiology = cell2mat(subjlist(:,6));
daysonset = cell2mat(subjlist(:,9));
outcome = double(cell2mat(subjlist(:,10)) > 2);
outcome(isnan(cell2mat(subjlist(:,10)))) = NaN;
mcstennis = tennis .* crsdiag;
mcstennis(crsdiag == 0) = NaN;
crs = cell2mat(subjlist(:,11));

admvscrs = NaN(size(refdiag));
admvscrs(refaware == 0) = 0;
admvscrs(refaware == 0 & crsaware == 0) = 0;
admvscrs(refaware > 0 & crsaware > 0) = 1;
admvscrs(refaware == 0 & crsaware > 0) = 2;

groupvar = eval(param.group);
groups = unique(groupvar(~isnan(groupvar)));

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

plotqt = 0.7;

for g = 1:length(groups)
    groupcoh(g,:,:) = squeeze(mean(allcoh(groupvar == groups(g),bandidx,:,:),1));
    threshcoh(g,:,:) = threshold_proportional(squeeze(groupcoh(g,:,:)),1-plotqt);
    for c = 1:size(threshcoh,2)
        groupdeg(g,c) = sum(threshcoh(g,c,:))/(size(threshcoh,2)-1);
    end
end

erange = [0 0.4];
vrange = [0 0.4];

plotgroups = 1:length(groups);
for g = plotgroups
    while true
        minfo(g,:) = plotgraph3d(squeeze(groupcoh(g,:,:)),sortedlocs,'plotqt',plotqt,...
            'escale',erange,'vscale',vrange,'cshift',0.4,'numcolors',5,'arcs','strength');
        if strcmp(questdlg('Save figure?',mfilename,'Yes','No','Yes'), 'Yes')
            break
        end
        close(gcf);
    end
    
    camva(8);
    camtarget([-9.7975  -28.8277   41.8981]);
    campos([-1.7547    1.7161    1.4666]*1000);
    camzoom(1.25);
    fprintf('%s %s - number of modules: %d\n',param.groupnames{g},bands{bandidx},length(unique(minfo(g,:))));
    set(gcf,'Name',sprintf('%s %s',param.groupnames{g},bands{bandidx}));
    set(gcf,'InvertHardCopy','off');
    print(gcf,sprintf('figures/meangraph_%s_%s.tif',param.groupnames{g},bands{bandidx}),'-dtiff','-r150');
    close(gcf);
end