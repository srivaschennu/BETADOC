function calcftspec(basename)

loadpaths

load freqlist.mat

EEG = pop_loadset([filepath basename '.set']);
chanlocs = EEG.chanlocs;

mintrials = 50;
if EEG.trials < mintrials
    error('Need at least %d trials for analysis, only found %d.',mintrials,EEG.trials);
end

EEG = convertoft(EEG);

cfg = [];
cfg.output     = 'pow';
cfg.method     = 'mtmfft';
cfg.foilim        = [0.5 45];
cfg.taper = 'dpss';
cfg.tapsmofrq = 0.3;
cfg.keeptrials = 'yes';
cfg.pad='nextpow2';

EEG = ft_freqanalysis(cfg,EEG);
spectra = EEG.powspctrm;
freqs = EEG.freq;

savefile = sprintf('%s%s_betadoc.mat',filepath,basename);

if exist(savefile,'file')
    save(savefile, 'chanlocs', 'freqs', 'spectra', 'freqlist', '-append');
else
    save(savefile, 'chanlocs', 'freqs', 'spectra', 'freqlist');
end
    
