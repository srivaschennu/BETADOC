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
    eeg_feat_names);

behaviour = subjlist(:,contains(subjlist.Properties.VariableNames, {...
    'auditory'
    'visual'
    'motor'
    'verbal'
    'communication'
    'arousal'
    'initdiag'
    'male'
    'age'
    'tbi'
    'daysonset'
    }));

behaviour.subjnum = cellfun(@(x) str2num(x(2:3)), subjlist.name);
behaviour.sessnum = cellfun(@(x) str2num(x(end)), subjlist.name);

trilidx = logical(tril(ones(91,91),-1));
eeg = squeeze(allcoh(:,3,trilidx(:)));
eeg = eigdecomp(eeg,50);
eeg = array2table(eeg);

num_cc = min(size(eeg,2),size(behaviour,2));

% if size(eeg,2) > num_cc
%     [~,eeg] = pca(table2array(eeg));
%     eeg = array2table(eeg(:,1:num_cc));
% elseif size(behaviour,2) > num_cc
%     [~,behaviour] = pca(behaviour);
%     behaviour = behaviour(:,1:num_cc);
% end

A = zeros(size(eeg,2),num_cc,num_rand+1);
B = zeros(size(behaviour,2),num_cc,num_rand+1);
r = zeros(num_cc,num_rand+1);
U = zeros(size(eeg,1),num_cc,num_rand+1);
V = zeros(size(behaviour,1),num_cc,num_rand+1);
X_ve = zeros(size(eeg,2),num_cc,num_rand+1);
Y_ve = zeros(size(behaviour,2),num_cc,num_rand+1);

fprintf('Running CCA with %d randomisations...', num_rand);
for n = 1:num_rand+1
    if n > 1
        behaviour = behaviour(randperm(size(behaviour,1)),:);
        eeg = eeg(randperm(size(eeg,1)),:);
    end
    [A(:,:,n),B(:,:,n),r(:,n),U(:,:,n),V(:,:,n)] = canoncorr(table2array(eeg), table2array(behaviour));
    for i = 1:num_cc
        X_ve(:,i,n) = corr(table2array(eeg),U(:,i,n));
        Y_ve(:,i,n) = corr(table2array(behaviour),V(:,i,n));
    end
end

X_ve = X_ve .^ 2;
Y_ve = Y_ve .^ 2;
fprintf(' done.\n');

save cca_results.mat A B r U V X_ve Y_ve eeg behaviour


function score = runpca(X,tvals)
trange = [0.9 0.1];
trange = (tvals <= trange(1) & tvals >= trange(2));

score = mean(X(:,trange),2);

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
