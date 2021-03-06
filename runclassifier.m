function runclassifier(listname,varargin)

param = finputcheck(varargin, {
    'changroup', 'string', [], 'all'; ...
    'changroup2', 'string', [], 'all'; ...
    'group', 'string', [], 'crsdiag'; ...
    'groupnames', 'cell', {}, {'UWS','MCS-','MCS+','EMCS'}; ...
    'runpca', 'string', {'true','false'}, 'false'; ...
    });


loadpaths
loadsubj

subjlist = eval(listname);

loadcovariates

groupvar = eval(param.group);

bands = {
    'delta'
    'theta'
    'alpha'
    };

grouppairs = [
    0     1
%     0     2
%     0     3
%     1     2
%     1     3
%     2     3
    ];

pairlist = [1 2 3 6 7 10];
pairlist = 1;
load(sprintf('stats_%s_%s.mat',listname,param.group),'stats','featlist');

etioselect = (etiology == 1);
    
selfeat = {};
for g = 1:size(grouppairs,1)
    groups = grouppairs(g,:);
    [~,bestfeat] = max(cell2mat({stats(:,pairlist(g)).auc}));
    bestfeat = 18;
    
    selgroupidx = ismember(groupvar,groups);
    thisgroupvar = groupvar(selgroupidx & etioselect);
    [~,~,thisgroupvar] = unique(thisgroupvar);
    thisgroupvar = thisgroupvar-1;
    
    selfeat = cat(1,selfeat,featlist(bestfeat,:));
    fprintf('Group %d vs %d feature set: ', groups(1), groups(2));
    disp(featlist(bestfeat,:));
    conntype = featlist{bestfeat,1};
    measure = featlist{bestfeat,2};
    bandidx = featlist{bestfeat,3};
    
    features = getfeatures(listname,conntype,measure,bandidx);
    features = features(selgroupidx & etioselect,:,:);
    
    clsyfyr(g) = buildsvm(features,thisgroupvar,'runpca','false');
    
    %         fprintf('%s vs %s: AUC = %.2f, p = %.5f, Chi2 = %.2f, Chi2 p = %.4f, accu = %d%%.\n',...
    %             param.groupnames{groups(1)+1},param.groupnames{groups(2)+1},...
    %             clsyfyr(f).auc,clsyfyr(f).pval,clsyfyr(f).chi2,clsyfyr(f).chi2pval,clsyfyr(f).accu);
    
end

groupnames = param.groupnames;
save(sprintf('clsyfyr_%s_%s.mat',listname,param.group),'clsyfyr','grouppairs','groupnames','featlist','selfeat');

