function plotftwpli(basename)

loadpaths

bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
    'gamma'
    };

fontname = 'Helvetica';
fontsize = 28;
xlim = [0.01 40];

% fileprefix = sprintf('%s_S%d',basename);
% if exist('freqlist','var') && ~isempty(freqlist)
%     %save([filepath basename '/' fileprefix 'spectra.mat'],'freqlist','-append');
% else
%     specinfo = load([filepath 'betadoc.mat', spectra]);
%     fprintf('freqlist = %s\n',mat2str(specinfo.freqlist));
% end

specinfo = load([filepath basename '_betadoc.mat']);
fprintf('freqlist = %s\n',mat2str(specinfo.freqlist));
    
figure('Name',basename,'Color','white'); hold all
plot(specinfo.freq,mean(specinfo.wpli,1),'LineWidth',1);
set(gca,'XLim',xlim,'YLim',ylim,'FontSize',fontsize,'FontName',fontname);
xlabel('Frequency (Hz)','FontSize',fontsize,'FontName',fontname);
ylabel('WPLI','FontSize',fontsize,'FontName',fontname);
ylimits = ylim;
for f = 1:size(specinfo.freqlist,1)
    line([specinfo.freqlist(f,1) specinfo.freqlist(f,1)],ylim,'LineWidth',1,...
        'LineStyle','-.','Color','black');
    line([specinfo.freqlist(f,2) specinfo.freqlist(f,2)],ylim,'LineWidth',1,...
        'LineStyle','-.','Color','black');
    text(specinfo.freqlist(f,1),ylimits(2),...
        sprintf('\\%s',bands{f}),'FontName',fontname,'FontSize',fontsize);
    
    %print(gcf,sprintf('figures/spectraplot_%s.tif',basename),'-dtiff');
end
box on