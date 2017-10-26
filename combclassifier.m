function results = combclassifier(listname,varargin)

param = finputcheck(varargin, {
    'groups', 'integer', [], []; ...
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS'}; ...
    'runpca', 'string', {'true','false'}, 'false'; ...
    });

loadpaths
loadsubj

subjlist = eval(listname);

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

etioselect = (etiology == 1);

groupvar = eval(param.group);

if isempty(param.groups)
    groups = unique(groupvar);
else
    groups = param.groups;
end

selgroupidx = ismember(groupvar,groups);
groupvar = groupvar(selgroupidx & etioselect);
[~,~,groupvar] = unique(groupvar);
groupvar = groupvar-1;

load(sprintf('clsyfyr_multiclass_%s.mat',param.group));

for c = 1:length(clsyfyr)
    if size(clsyfyr(c).confmat,2) < length(groups)
        clsyfyr(c).confmat = cat(2,clsyfyr(c).confmat,zeros(size(clsyfyr(c).confmat,1),length(groups)-size(clsyfyr(c).confmat,2)));
    end
    clsyfyr(c).confmat = clsyfyr(c).confmat ./ repmat(sum(clsyfyr(c).confmat,2),1,size(clsyfyr(c).confmat,2));
    clsyfyr(c).confmat = clsyfyr(c).confmat + 0.5;
    clsyfyr(c).confmat = clsyfyr(c).confmat ./ repmat(sum(clsyfyr(c).confmat,1),size(clsyfyr(c).confmat,1),1);
    
    features = getfeatures(listname,clsyfyrparam{c,1:3});
    features = features(selgroupidx & etioselect,:,:);
    rng('default');
    clsyfyr(c).predlabels = predict(clsyfyr(c).model,squeeze(features(:,clsyfyr(c).D,:)));
    clsyfyr(c).predlabels = clsyfyr(c).predlabels+1;
end

bel = zeros(length(clsyfyr(1).predlabels),length(groups));
for x = 1:length(clsyfyr(1).predlabels)
    for i = 1:length(groups)
        bel(x,i) = clsyfyr(1).confmat(i,clsyfyr(1).predlabels(x));
        for k = 2:length(clsyfyr)
            bel(x,i) = bel(x,i) * clsyfyr(k).confmat(i,clsyfyr(k).predlabels(x));
        end
    end
end

bel = bel ./ repmat(sum(bel,2),1,size(bel,2));
[~,predlabels] = max(bel,[],2);
predlabels = predlabels-1;
[results.confmat,results.chi2,results.chi2pval] = crosstab(groupvar,predlabels);