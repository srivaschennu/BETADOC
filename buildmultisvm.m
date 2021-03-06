function bestcls = buildmultisvm(features,groupvar,varargin)

param = finputcheck(varargin, {
    'runpca', 'string', {'true','false'}, 'false'; ...
    });

features = permute(features,[1 3 2]);

clsyfyrparams = {'Standardize',true,'KernelFunction','RBF'};
cvoption = {'KFold',4};

% PCA - Keep enough components to explain the desired amount of variance.
explainedVarianceToKeepAsFraction = 95/100;

Cvals = unique(sort(cat(2, 10.^(-3:3), 5.^(-3:3), 2.^(-5:5))));
Kvals = unique(sort(cat(2, 10.^(-3:3), 5.^(-3:3), 2.^(-5:5))));

trainfeatures = features;
trainlabels = groupvar;

%% search through parameters for best cross-validated classifier
for d = 1:size(features,3)
    rng('default');
    warning('off','stats:glmfit:IterationLimit');
    thisfeat = trainfeatures(:,:,d);
    
    if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
        [~, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
        numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
        thisfeat = pcaScores(:,1:numPCAComponentsToKeep);
    end
    
    for c = 1:length(Cvals)
        for k = 1:length(Kvals)
            rng('default');
            model = fitcecoc(thisfeat,trainlabels,cvoption{:},...
                'Learners',templateSVM(clsyfyrparams{:},'BoxConstraint',Cvals(c),'KernelScale',Kvals(k)));
            
            predlabels = kfoldPredict(model);
            cm = confusionmat(trainlabels,predlabels);
            cm = cm ./ repmat(sum(cm,2),1,size(cm,2));
            perf{d}(c,k) = sum(diag(cm)) - (size(cm,1)/2);
        end
    end
    warning('on','stats:glmfit:IterationLimit');
end
perf = permute(cat(3,perf{:}),[3 1 2]);

[bestcls.perf,maxidx] = max(perf(:));
[bestD,bestC,bestK] = ind2sub(size(perf),maxidx);

bestcls.D = bestD;
bestcls.C = Cvals(bestC);
bestcls.K = Kvals(bestK);

thisfeat = trainfeatures(:,:,bestcls.D);
if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
    [~, pcaScores, ~, ~, explained] = pca(thisfeat,'Centered',true);
    numPCAComponentsToKeep = find(cumsum(explained)/sum(explained) >= explainedVarianceToKeepAsFraction, 1);
    thisfeat = pcaScores(:,1:numPCAComponentsToKeep);
end

rng('default');
model = fitcecoc(thisfeat,trainlabels,cvoption{:},...
    'Learners',templateSVM(clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K));
bestcls.predlabels = kfoldPredict(model);
[bestcls.confmat,bestcls.chi2,bestcls.chi2pval] = crosstab(trainlabels,bestcls.predlabels);

rng('default');
bestcls.model = fitcecoc(thisfeat,trainlabels,...
    'Learners',templateSVM(clsyfyrparams{:},'BoxConstraint',bestcls.C,'KernelScale',bestcls.K));

% %% test best classifier on test data in locked cupboard
% 
% thisfeat = testfeatures(:,:,bestD);
% if size(thisfeat,2) > 1 && strcmp(param.runpca,'true')
%     pcaScores = thisfeat * bestcls.pcaCoeff;
%     thisfeat = pcaScores(:,1:bestcls.numPCAComponentsToKeep);
% end
% 
% [~,postProb] = predict(fitSVMPosterior(bestcls.model),thisfeat);
% predlabels = NaN(size(groupvar));
% predlabels(cvp.test(1)) = double(postProb(:,2) > bestcls.bestthresh);
% 
% [~,bestcls.testchi2,bestcls.testchi2pval] = crosstab(testlabels,predlabels(~isnan(predlabels)));
% bestcls.testaccu = round(sum(testlabels==predlabels(~isnan(predlabels)))*100/length(testlabels));
% bestcls.predlabels = predlabels;

bestcls.clsyfyrparams = clsyfyrparams;
bestcls.cvoption = cvoption;
end