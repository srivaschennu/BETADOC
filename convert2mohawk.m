function convert2mohawk(listname)

loadsubj
loadpaths

load sortedlocs.mat

outpath = '/Users/chennu/Data/MOHAWK/';

subjlist = eval(listname);
loadcovariates

for s = 1:size(subjlist,1)
    basename = subjlist{s,1};
    betadoc = load(sprintf('%s%s_betadoc.mat',filepath,basename));
    [sortedchan,sortidx] = sort({betadoc.chanlocs.labels});
    if ~strcmp(chanlist,cell2mat(sortedchan))
        error('Channel names do not match!');
    end
    betadoc.spectra = betadoc.spectra(sortidx,:);
    betadoc.chanlocs = betadoc.chanlocs(sortidx);
    
    betadoc.matrix = betadoc.matrix(:,sortidx,sortidx);
    betadoc.graphdata = betadoc.graphdata(:,[1 3]);
    
    save(sprintf('%s%s_mohawk.mat',outpath,basename),'-struct','betadoc');
end