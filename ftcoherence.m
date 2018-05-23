function ftcoherence(basename)

loadpaths

filename = [filepath  basename '_betadoc.mat'];
load(filename,'freqlist');

EEG = pop_loadset('filename',[basename '.set'],'filepath',filepath);

chanlocs = EEG.chanlocs;

EEG = convertoft(EEG);
cfg = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim        = [0.5 45];
cfg.taper = 'dpss';
cfg.tapsmofrq = 0.3;
cfg.keeptrials = 'yes';
numrand = 25;

fprintf('Estimating spectrum and cross-spectrum.\n');
EEG = ft_freqanalysis(cfg,EEG);
% abscrsspctrm = abs(EEG.crsspctrm);
matrix = zeros(size(freqlist,1),length(chanlocs),length(chanlocs));
bootmat = zeros(size(freqlist,1),length(chanlocs),length(chanlocs),numrand);
coh = zeros(length(chanlocs),length(chanlocs));

fprintf('Running %d randomisations...',numrand);
for r = 0:numrand
    if r > 0
        if mod(r,5) == 0
            fprintf('%d',r);
        else
            fprintf('.');
        end
%         randangles = (2*rand(size(EEG.crsspctrm))-1) .* pi;
%         EEG.crsspctrm = complex(abscrsspctrm.*cos(randangles),abscrsspctrm.*sin(randangles));
        keeptrials = randperm(size(EEG.crsspctrm,1));
        keeptrials = keeptrials(1:round(0.8 * size(EEG.crsspctrm,1)));
    else
        keeptrials = 1:size(EEG.crsspctrm,1);
    end
    
    wpli = ft_connectivity_wpli(EEG.crsspctrm(keeptrials,:,:),'debias',true,'dojack',false);
    
    for f = 1:size(freqlist,1)
        [~, bstart] = min(abs(EEG.freq-freqlist(f,1)));
        [~, bend] = min(abs(EEG.freq-freqlist(f,2)));
        [~,freqidx] = max(mean(wpli(:,bstart:bend),1));
        
        coh(:) = 0;
        coh(logical(tril(ones(size(coh)),-1))) = wpli(:,bstart+freqidx-1);
        coh = tril(coh,1)+tril(coh,1)';
        
        if r > 0
            bootmat(f,:,:,r) = coh;
        else
            matrix(f,:,:) = coh;
        end
    end
end
fprintf('\n');
save(filename,'matrix','bootmat','chanlocs','-append');
fprintf('\nDone.\n');
