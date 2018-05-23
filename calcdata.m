function calcdata(listname,conntype)

loadpaths
loadsubj

subjlist = eval(listname);
loadcovariates

load sortedlocs.mat

numrand = 25;

for s = 1:size(subjlist,1)
    basename = subjlist{s,1};
    fprintf('Processing %s.\n',basename);
    
    subjinfo = load([filepath basename '_betadoc.mat']);
    [sortedchan,sortidx] = sort({subjinfo.chanlocs.labels});
    if ~strcmp(chanlist,cell2mat(sortedchan))
        error('Channel names do not match!');
    end
    subjinfo.spectra = subjinfo.spectra(:,sortidx,:);
    subjinfo.chanlocs = subjinfo.chanlocs(sortidx);
    subjinfo.matrix = subjinfo.matrix(:,sortidx,sortidx);
    subjinfo.bootmat = subjinfo.bootmat(:,sortidx,sortidx,:);

    if s == 1
        freqbins = subjinfo.freqs;
        spectra = zeros(size(subjlist,1),length(subjinfo.chanlocs),length(subjinfo.freqs));
        bandpower = zeros(size(subjlist,1),size(subjinfo.matrix,1),length(subjinfo.chanlocs));
        randband = zeros(size(subjlist,1),size(subjinfo.matrix,1),length(subjinfo.chanlocs),numrand);
        specent = zeros(size(subjlist,1),length(subjinfo.chanlocs));
        bandpeak = zeros(size(subjlist,1),size(subjinfo.matrix,1));
        allcoh = zeros(size(subjlist,1),size(subjinfo.matrix,1),length(subjinfo.chanlocs),length(subjinfo.chanlocs));
    end
    
    subjinfo.matrix(isnan(subjinfo.matrix)) = 0;
    subjinfo.matrix = abs(subjinfo.matrix);
    allcoh(s,:,:,:) = subjinfo.matrix;
    
    spectra(s,:,:) = squeeze(mean(subjinfo.spectra,1));
    for f = 1:size(subjinfo.freqlist,1)
        %collate spectral info
        [~, bstart] = min(abs(subjinfo.freqs-subjinfo.freqlist(f,1)));
        [~, bstop] = min(abs(subjinfo.freqs-subjinfo.freqlist(f,2)));
        bandpower(s,f,:) = mean(mean(subjinfo.spectra(:,:,bstart:bstop),3),1);
        
        for n = 1:numrand
            keeptrials = randperm(size(subjinfo.spectra,1));
            keeptrials = keeptrials(1:round(0.8*length(keeptrials)));
            randband(s,f,:,n) = mean(mean(subjinfo.spectra(keeptrials,:,bstart:bstop),3),1);
        end
        
        maxpeakheight = 0;
        for c = 1:size(subjinfo.spectra,2)
            [peakheight, peakfreq] = findpeaks(squeeze(mean(subjinfo.spectra(:,c,bstart:bstop),1)),'npeaks',1);
            if ~isempty(peakheight) && peakheight > maxpeakheight
                bandpeak(s,f) = subjinfo.freqs(bstart-1+peakfreq);
                maxpeakheight = peakheight;
            end
        end
    end
    
    for c = 1:size(bandpower,3)
        bandpower(s,:,c) = bandpower(s,:,c)./sum(bandpower(s,:,c));
        specent(s,c) = -sum(bandpower(s,:,c) .* log(bandpower(s,:,c)));
        for n = 1:size(randband,4)
            randband(s,:,c,n) = randband(s,:,c,n)./sum(randband(s,:,c,n));
        end
    end
    grp(s,1) = subjlist{s,3};
end
save(sprintf('%s/%s/alldata_%s_%s.mat',filepath,conntype,listname,conntype), 'grp', 'spectra', 'freqbins', 'bandpower', 'randband', 'specent', 'bandpeak', 'allcoh', 'subjlist');