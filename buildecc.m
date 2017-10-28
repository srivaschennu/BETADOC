function clsyfyr = buildecc(listname,varargin)

param = finputcheck(varargin, {
    'group', 'string', [], 'crsdiag'; ...    
    'mode', 'string', {'eval','test'}, 'eval'; ...
    'groups', 'real', [], [0 1 2 3]; ...
    });

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

groupvar = eval(param.group);
groups = param.groups;

etioselect = (etiology == 1);
selgroupidx = ismember(groupvar,groups);
groupvar = groupvar(selgroupidx & etioselect);

load(sprintf('clsyfyr_ecc_%s.mat',param.group));

predlabels = NaN(size(groupvar,1),size(clsyfyr,1));
ecccode = zeros(length(param.groups),size(clsyfyr,1));

for c = 1:size(clsyfyr,1)
    if strcmp(param.mode,'eval')
        predlabels(groupvar == clsyfyrparam{c,4} | groupvar == clsyfyrparam{c,5},c) = clsyfyr(c).predlabels;
    elseif strcmp(param.mode,'test')
        disp(clsyfyrparam(c,1:3));
        features = getfeatures(listname,clsyfyrparam{c,1:3});
        features = features(selgroupidx & etioselect,:,:);
        rng('default');
        [~,postProb] = predict(fitSVMPosterior(clsyfyr(c).model),squeeze(features(:,clsyfyr(c).D,:)));
        predlabels(:,c) = double(postProb(:,2) >= clsyfyr(c).bestthresh);
    end
    ecccode(clsyfyrparam{c,4}+1,c) = -1;
    ecccode(clsyfyrparam{c,5}+1,c) = 1;
end

predlabels(predlabels == 0) = -1;
predlabels(isnan(predlabels)) = 0;
ecclabels = NaN(size(groupvar));

%loss weighted decoding with an exponential loss function, Allwein et al.
%(2000)
for g = 1:size(groupvar,1)
    dist = zeros(size(ecccode,1),1);
    for k = 1:size(ecccode,1)
        for l = 1:size(ecccode,2)
            dist(k) = dist(k) + (abs(ecccode(k,l)) * lossfunc(ecccode(k,l),predlabels(g,l)));
        end
%         dist(k) = dist(k) / sum(abs(ecccode(k,:)));
    end
    [~,ecclabels(g)] = min(dist);
end

ecclabels = ecclabels - 1;

if strcmp(param.mode,'eval')
    clear clsyfyr
    clsyfyr.trainlabels = groupvar;
    clsyfyr.predlabels = ecclabels;
    [clsyfyr.confmat,clsyfyr.chi2,clsyfyr.chi2pval] = crosstab(groupvar,ecclabels);
    save('clsyfyr_ecc.mat','clsyfyr','groups');
elseif strcmp(param.mode,'test')
    results.trainlabels = groupvar;
    results.predlabels = ecclabels;
    [results.confmat,results.chi2,results.chi2pval] = crosstab(groupvar,ecclabels);
    save('results_ecc.mat','results','groups');    
end

function loss = lossfunc(y,s)
% loss = (1 - sign(y*s))/2;
loss = exp(-y*s)/2;
