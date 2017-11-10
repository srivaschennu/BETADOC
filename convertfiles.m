function convertfiles(basename,conntype)

loadpaths
oldpath = '/Users/chennu/Data/Liege-RestingState/';
load(sprintf('%s/%sspectra.mat',oldpath,basename));
load(sprintf('%s/%s/%s%s.mat',oldpath,conntype,basename,conntype));
load(sprintf('%s/%s/%s%sgraph.mat',filepath,conntype,basename,conntype));
