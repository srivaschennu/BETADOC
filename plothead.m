function plothead(basename,bandidx)

conntype = 'ftdwpli';

loadpaths

load sortedlocs

load([filepath filesep basename '_betadoc.mat']);
[sortedchan,sortidx] = sort({chanlocs.labels});
if ~strcmp(chanlist,cell2mat(sortedchan))
    error('Channel names do not match!');
end
matrix = matrix(:,sortidx,sortidx);

plotqt = 0.7;

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

cohmat = squeeze(matrix(bandidx,:,:));

erange = [0 1];
vrange = [0 0.6]; % changes the plot scaling (colours)

minfo = plotgraph3d(cohmat,sortedlocs,'plotqt',plotqt,'escale',erange,'vscale',vrange,'cshift',0.4,'numcolors',5,'arcs','module');
fprintf('%s: %s band - number of modules: %d\n',basename,bands{bandidx},length(unique(minfo)));
set(gcf,'Name',sprintf('group %s: %s band',basename,bands{bandidx}));
camva(8);
camtarget([-9.7975  -28.8277   41.8981]);
campos([-1.7547    1.7161    1.4666]*1000);
camzoom(1.25);
set(gcf,'InvertHardCopy','off');
print(gcf,sprintf('figures/plotgraph3d_%s_%s.tif',basename,bands{bandidx}),'-dtiff','-r300');
% close(gcf);
end
