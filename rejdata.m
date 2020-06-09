subjlist = betadoc;
subjlist = subjlist(2:end,:);
filepath = '/Users/chennu/BigData/BETADOC/';
for s = 1:size(subjlist,1)
    try
        EEG = pop_loadset('filepath', filepath,'filename', [subjlist{s,1} '_epochs.set'], 'loadmode', 'info');
    catch
        continue
    end
    
    if isfield(EEG, 'rejchan')
        rejchan{s} = length(EEG.rejchan);
    end
    
    if isfield(EEG, 'rejepoch')
        rejepoch{s} = length(EEG.rejepoch);
    end

    if isfield(EEG, 'reject')
        rejica{s} = sum(EEG.reject.gcompreject);
    end

end