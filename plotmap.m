function plotmap(basename,measure,bandidx,varargin)

param = finputcheck(varargin, {
    'pmask', 'string', [], ''; ...
    'clim', 'real', [], [-1 1]; ...
    });

fontname = 'Helvetica';
fontsize = 22;

loadpaths

weiorbin = 3;

load(sprintf('%s/%s_betadoc.mat',filepath,basename));

if ~isempty(param.pmask)
    pmaskidx = ismember({chanlocs.labels},cat(1,eval(param.pmask)));
end

if strcmpi(measure,'power')
    for f = 1:size(freqlist,1)
        %collate spectral info
        [~, bstart] = min(abs(freqs-freqlist(f,1)));
        [~, bstop] = min(abs(freqs-freqlist(f,2)));
        plotdata(f,:) = mean(spectra(:,bstart:bstop),2);
    end
    for c = 1:size(plotdata,2)
        plotdata(:,c) = plotdata(:,c)./sum(plotdata(:,c));
    end
else
    trange = [0.9 0.1];
    trange = (tvals <= trange(1) & tvals >= trange(2));
    
    m = find(strcmpi(measure,graphdata(:,1)));
    if strcmpi(measure,'centrality') || strcmpi(measure,'participation coefficient')
        plotdata = zscore(graphdata{m,weiorbin}(bandidx,trange,:),0,3);
        plotdata = squeeze(mean(plotdata,2));
    end
end

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

    figure;
    figpos = get(gcf,'Position');
    figpos(3) = figpos(3)/2;
    set(gcf,'Position',figpos);
    if ~isempty(param.pmask)
        topoplot(plotdata,chanlocs,'maplimits',param.clim,'gridscale',150,...
            'pmask',pmaskidx);
    else
        topoplot(plotdata,chanlocs,'maplimits',param.clim,'gridscale',150,...
            'style','map');
    end
    colormap(jet);
    %colorbar
    figname = sprintf('figures/map_%s_%s_%s',basename,measure,bands{bandidx});
    set(gcf,'Name',figname,'Color','white');
    set(gca,'FontName',fontname,'FontSize',fontsize);
    export_fig(gcf,[figname '.tif'],'-r300');
    close(gcf);
end