function runcca(listname)

rng('default');
num_rand = 2000;

loadpaths
loadsubj

load(sprintf('%s/ftdwpli/alldata_%s_ftdwpli.mat', filepath, listname));
load(sprintf('%s/ftdwpli/graphdata_%s_ftdwpli.mat', filepath, listname));

subjlist = eval(listname);
subjlist = cell2table(subjlist(2:end,:),'VariableNames',subjlist(1,:));

bands = {
    'delta'
    'theta'
    'alpha'
    };

eeg_feat_names = {};
for bandidx = 1:3
    featidx = 1;
    
    bpower_mean(:,bandidx) = mean(bandpower(:,bandidx,:),3);
    eeg_feat_names{featidx,bandidx} = 'mean_power';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    bpower_std(:,bandidx) = std(bandpower(:,bandidx,:),[],3);
    eeg_feat_names{featidx,bandidx} = 'std_power';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    wpli_med(:,bandidx) = nanmedian(allcoh(:,bandidx,:),3);
    eeg_feat_names{featidx,bandidx} = 'med_wpli';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    wpli_std(:,bandidx) = nanstd(allcoh(:,bandidx,:),[],3);
    eeg_feat_names{featidx,bandidx} = 'std_wpli';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    clustering_mean(:,bandidx) = runpca(squeeze(mean(graph{1,3}(:,bandidx,:,:),4)),tvals);
    eeg_feat_names{featidx,bandidx} = 'mean_clust';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    clustering_std(:,bandidx) = runpca(squeeze(std(graph{1,3}(:,bandidx,:,:),[],4)),tvals);
    eeg_feat_names{featidx,bandidx} = 'std_clust';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    pathlen(:,bandidx) = runpca(squeeze(graph{2,3}(:,bandidx,:)),tvals);
    eeg_feat_names{featidx,bandidx} = 'path_len';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    globaleff(:,bandidx) = runpca(squeeze(graph{3,3}(:,bandidx,:)),tvals);
    eeg_feat_names{featidx,bandidx} = 'global_eff';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    modular(:,bandidx) = runpca(squeeze(graph{4,3}(:,bandidx,:)),tvals);
    eeg_feat_names{featidx,bandidx} = 'modularity';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    central_mean(:,bandidx) = runpca(squeeze(mean(graph{6,3}(:,bandidx,:,:),4)),tvals);
    eeg_feat_names{featidx,bandidx} = 'mean_centr';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    central_std(:,bandidx) = runpca(squeeze(std(graph{6,3}(:,bandidx,:,:),[],4)),tvals);
    eeg_feat_names{featidx,bandidx} = 'std_centr';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    mspan(:,bandidx) = runpca(squeeze(graph{7,3}(:,bandidx,:)),tvals);
    eeg_feat_names{featidx,bandidx} = 'mod_span';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    pcoeff_mean(:,bandidx) = runpca(squeeze(mean(graph{8,3}(:,bandidx,:,:),4)),tvals);
    eeg_feat_names{featidx,bandidx} = 'mean_pcoeff';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
    
    pcoeff_std(:,bandidx) = runpca(squeeze(std(graph{8,3}(:,bandidx,:,:),[],4)),tvals);
    eeg_feat_names{featidx,bandidx} = 'std_pcoeff';
    eeg_feat_names{featidx,bandidx} = sprintf('%s_%s', eeg_feat_names{featidx,bandidx}, bands{bandidx});
    featidx = featidx+1;
end


eeg = cat(2, ...
    bpower_mean, ...
    bpower_std, ...
    wpli_med, ...
    wpli_std, ...
    clustering_mean, ...
    clustering_std, ...
    pathlen, ...
    globaleff, ...
    modular, ...
    central_mean, ...
    central_std, ...
    mspan, ...
    pcoeff_mean, ...
    pcoeff_std ...
    );

eeg_feat_names = eeg_feat_names';
eeg = array2table(eeg, ...
    'VariableNames', ...
    eeg_feat_names(:));

beh = subjlist(:,contains(subjlist.Properties.VariableNames, {...
    'initdiag'
    'crsdiag'
    'auditory'
    'visual'
    'motor'
    'verbal'
    'communication'
    'arousal'
    'male'
    'age'
    'tbi'
    'daysonset'
    }));

beh.subjnum = cellfun(@(x) str2num(x(2:3)), subjlist.name);
beh.sessnum = cellfun(@(x) str2num(x(end)), subjlist.name);
subjnum = beh.subjnum;

% trilidx = logical(tril(ones(91,91),-1));
% eeg = squeeze(allcoh(:,3,trilidx(:)));
% eeg = eigdecomp(eeg,50);
% eeg = array2table(eeg);

eeg_norm = palm_inormal(table2array(eeg));
beh_norm = palm_inormal(table2array(beh));

% num_keep = 8;
% eeg_norm = eigdecomp(eeg_norm,num_keep);
% beh_norm = eigdecomp(beh_norm,num_keep);

num_cc = min(size(eeg_norm,2),size(beh_norm,2));

A = zeros(size(eeg_norm,2),num_cc,num_rand+1);
B = zeros(size(beh_norm,2),num_cc,num_rand+1);
r = zeros(num_cc,num_rand+1);
U = zeros(size(eeg_norm,1),num_cc,num_rand+1);
V = zeros(size(beh_norm,1),num_cc,num_rand+1);

eeg_corr = zeros(size(eeg,2),num_cc,num_rand+1);
eeg_corrp = zeros(size(eeg,2),num_cc,num_rand+1);
beh_corr = zeros(size(beh,2),num_cc,num_rand+1);
beh_corrp = zeros(size(beh,2),num_cc,num_rand+1);

fprintf('Running CCA with %d randomisations...', num_rand);

for n = 1:num_rand+1
    if n == 1
        eeg_rand = eeg_norm;
        beh_rand = beh_norm;
    elseif n > 1
        eeg_rand = randomise(eeg_norm,subjnum);
        beh_rand = randomise(beh_norm,subjnum);
    end
    [A(:,:,n),B(:,:,n),r(:,n),U(:,:,n),V(:,:,n),stats(n)] = canoncorr(eeg_rand, beh_rand);
    for c = 1:num_cc
        [eeg_corr(:,c,n),eeg_corrp(:,c,n)] = corr(table2array(eeg),U(:,c,n));
        [beh_corr(:,c,n),beh_corrp(:,c,n)] = corr(table2array(beh),V(:,c,n));
    end
end

fprintf(' done.\n');

save([filepath 'cca_results.mat'], 'A', 'B', 'r', 'U', 'V', 'eeg_corr', ...
    'eeg_corrp', 'beh_corr', 'beh_corrp', 'stats', 'eeg', 'beh');


function score = runpca(X,tvals)
trange = [0.9 0.1];
trange = (tvals <= trange(1) & tvals >= trange(2));

% score = mean(X(:,trange),2);

[~,score] = pca(X(:,trange));
score = score(:,1);

function eigvec = eigdecomp(data,num_keep)

eigvec = zeros(size(data,1));
for i=1:size(data,1) % estimate "pairwise" covariance, ignoring missing data
    for j=1:size(data,1)
        grot=data([i j],:);
        grot=cov(grot');
        eigvec(i,j)=grot(1,2);
    end
end
[~,p] = chol(eigvec);
if p
    eigvec = nearestSPD(eigvec);
end
[eigvec,~] = eigs(eigvec,num_keep);

function data = randomise(data,subjnum)
uniqsubj = unique(subjnum)';

randsubj = uniqsubj(randperm(length(uniqsubj)));
rand_order = zeros(size(data,1),1);
i = 1;
for s = randsubj
    numsess = sum(subjnum == s);
    rand_order(i:i + numsess - 1) = find(subjnum == s);
    i = i + numsess;
end
data = data(rand_order,:);