function [A,B,r,U,V,stats,eeg_rho,eeg_p,beh_rho,beh_p] = runcca(listname)

loadpaths
loadsubj

subjlist = eval(listname);

load(sprintf('%s/ftdwpli/alldata_%s_ftdwpli.mat', filepath, listname));
load(sprintf('%s/ftdwpli/graphdata_%s_ftdwpli.mat', filepath, listname));

for bandidx = 1:3
    bpower_mean(:,bandidx) = mean(bandpower(:,bandidx,:),3);
    bpower_std(:,bandidx) = std(bandpower(:,bandidx,:),[],3);
    wpli_med(:,bandidx) = nanmedian(allcoh(:,bandidx,:),3);
    wpli_std(:,bandidx) = nanstd(allcoh(:,bandidx,:),[],3);
    
    clustering_mean(:,bandidx) = runpca(squeeze(mean(graph{1,3}(:,bandidx,:,:),4)));
    clustering_std(:,bandidx) = runpca(squeeze(std(graph{1,3}(:,bandidx,:,:),[],4)));
    
    pathlen(:,bandidx) = runpca(squeeze(graph{2,3}(:,bandidx,:)));
    globaleff(:,bandidx) = runpca(squeeze(graph{3,3}(:,bandidx,:)));
    modular(:,bandidx) = runpca(squeeze(graph{4,3}(:,bandidx,:)));
    
    central_mean(:,bandidx) = runpca(squeeze(mean(graph{6,3}(:,bandidx,:,:),4)));
    central_std(:,bandidx) = runpca(squeeze(std(graph{6,3}(:,bandidx,:,:),[],4)));
    
    mspan(:,bandidx) = runpca(squeeze(graph{7,3}(:,bandidx,:)));
    
    pcoeff_mean(:,bandidx) = runpca(squeeze(mean(graph{8,3}(:,bandidx,:,:),4)));
    pcoeff_std(:,bandidx) = runpca(squeeze(std(graph{8,3}(:,bandidx,:,:),[],4)));
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

load('behaviour.mat')

subjnum = cellfun(@(x) str2num(x(2:3)), betadoc(:,1));
behaviour = cat(2, behaviour, subjnum);

[A,B,r,U,V,stats] = canoncorr(eeg, behaviour);

figure;
scatter(U(:,1), V(:,1));

[beh_rho, beh_p] = corr(U(:,1),behaviour);
[beh_rho, beh_p, behaviour] = sortcorr(beh_rho, beh_p, behaviour);

[eeg_rho, eeg_p] = corr(V(:,1),eeg);
[eeg_rho, eeg_p, eeg] = sortcorr(eeg_rho, eeg_p, eeg);


function score = runpca(X)
[~,score] = pca(X);
score = score(:,1);

function [rhosq, pval, data] = sortcorr(rho, pval, data)
rhosq = rho.^2;
[rhosq,sortidx] = sort(rhosq,'descend');
pval = pval(sortidx);
data = data(:,sortidx);
