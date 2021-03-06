function calcgraph(basename,varargin)

loadpaths

param = finputcheck(varargin, {
    'randomise', 'string', {'on','off'}, 'off'; ...
    'latticise', 'string', {'on','off'}, 'off'; ...
    'numrand', 'integer', [], 25; ...
    'rewire', 'integer', [], 50; ...
    'heuristic', 'integer', [], 50; ...
    });

load sortedlocs
chandist = chandist / max(chandist(:));

tvals = 1:-0.025:0.1;

filename = sprintf('%s%s_betadoc.mat',filepath,basename);
load(filename,'matrix','bootmat','chanlocs');

if strcmp(param.randomise,'on')
    numruns = param.numrand;
elseif strcmp(param.latticise,'on')
    distdiag = repmat(1:length(sortedlocs),[length(sortedlocs) 1]);
    for d = 1:size(distdiag,1)
        distdiag(d,:) = abs(distdiag(d,:) - d);
    end
    distdiag = distdiag ./ max(distdiag(:));
    numruns = param.numrand;
else
    numruns = 1;
end

graphdata{1,1} = 'clustering';
graphdata{2,1} = 'characteristic path length';
graphdata{3,1} = 'global efficiency';
graphdata{4,1} = 'modularity';
graphdata{5,1} = 'modules';
graphdata{6,1} = 'centrality';
graphdata{7,1} = 'modular span';
graphdata{8,1} = 'participation coefficient';
graphdata{9,1} = 'degree';
graphdata{10,1} = 'mutual information';

fprintf('Processing %s',basename);

[sortedchan,sortidx] = sort({chanlocs.labels});
if ~strcmp(chanlist,cell2mat(sortedchan))
    error('Channel names do not match!');
end
matrix = matrix(:,sortidx,sortidx);
bootmat = bootmat(:,sortidx,sortidx,:);
chanlocs = chanlocs(sortidx);

for f = 1:size(matrix,1)
    fprintf('\nBand %d iteration',f);
    for iter = 1:numruns
        fprintf(' %d',iter);
        if strcmp(param.randomise,'on')
            %randomisation
            cohmat = squeeze(bootmat(f,:,:,iter));
        else
            cohmat = squeeze(matrix(f,:,:));
        end
        cohmat(isnan(cohmat)) = 0;
        cohmat = abs(cohmat);
        
        for thresh = 1:length(tvals)
            weicoh = threshold_proportional(cohmat,tvals(thresh));
            bincoh = double(threshold_proportional(cohmat,tvals(thresh)) ~= 0);
            
            %%%%%%  WEIGHTED %%%%%%%%%
            
            allcc{iter,1}(thresh,:) = clustering_coef_wu(weicoh);
            allcp{iter,1}(thresh) = charpath(distance_wei(weight_conversion(weicoh,'lengths')),0,0);
            alleff{iter,1}(thresh) = efficiency_wei(weicoh);
            allbet{iter,1}(thresh,:) = betweenness_wei(weight_conversion(weicoh,'lengths'));
            alldeg{iter,1}(thresh,:) = degrees_und(weicoh);
            
            for i = 1:param.heuristic
                [Ci, allQ{iter,1}(thresh,i)] = community_louvain(weicoh);
                
                allCi{iter,1}(thresh,i,:) = Ci;
                
                modspan = zeros(1,max(Ci));
                for m = 1:max(Ci)
                    if sum(Ci == m) > 1
                        distmat = chandist(Ci == m,Ci == m) .* weicoh(Ci == m,Ci == m);
                        distmat = nonzeros(triu(distmat,1));
                        modspan(m) = sum(distmat)/sum(Ci == m);
                    end
                end
                allms{iter,1}(thresh,i) = max(nonzeros(modspan));
                
                allpc{iter,1}(thresh,i,:) = participation_coef(weicoh,Ci);
            end
            
            %%%%%%  BINARY %%%%%%%%%
            
            allcc{iter,2}(thresh,:) = clustering_coef_bu(bincoh);
            allcp{iter,2}(thresh) = charpath(distance_bin(bincoh),0,0);
            alleff{iter,2}(thresh) = efficiency_bin(bincoh);
            allbet{iter,2}(thresh,:) = betweenness_bin(bincoh);
            alldeg{iter,2}(thresh,:) = degrees_und(bincoh);
            
            for i = 1:param.heuristic
                [Ci, allQ{iter,2}(thresh,i)] = community_louvain(bincoh);
                
                allCi{iter,2}(thresh,i,:) = Ci;
                
                modspan = zeros(1,max(Ci));
                for m = 1:max(Ci)
                    if sum(Ci == m) > 1
                        distmat = chandist(Ci == m,Ci == m) .* bincoh(Ci == m,Ci == m);
                        distmat = nonzeros(triu(distmat,1));
                        modspan(m) = sum(distmat)/sum(Ci == m);
                    end
                end
                allms{iter,2}(thresh,i) = max(nonzeros(modspan));
                
                allpc{iter,2}(thresh,i,:) = participation_coef(bincoh,Ci);
            end
        end
    end
    
    for iter = 1:numruns
        for thresh = 1:length(tvals)
            %clustering coeffcient
            graphdata{1,2}(f,thresh,1:length(chanlocs),iter) = allcc{iter,1}(thresh,:);
            graphdata{1,3}(f,thresh,1:length(chanlocs),iter) = allcc{iter,2}(thresh,:);
            
            %characteristic path length
            graphdata{2,2}(f,thresh,iter) = allcp{iter,1}(thresh);
            graphdata{2,3}(f,thresh,iter) = allcp{iter,2}(thresh);
            
            %global efficiency
            graphdata{3,2}(f,thresh,iter) = alleff{iter,1}(thresh);
            graphdata{3,3}(f,thresh,iter) = alleff{iter,2}(thresh);
            
            % modularity
            graphdata{4,2}(f,thresh,iter) = mean(allQ{iter,1}(thresh,:));
            graphdata{4,3}(f,thresh,iter) = mean(allQ{iter,2}(thresh,:));
            
            % community structure
            graphdata{5,2}(f,thresh,1:length(chanlocs),iter) = squeeze(allCi{iter,1}(thresh,1,:));
            graphdata{5,3}(f,thresh,1:length(chanlocs),iter) = squeeze(allCi{iter,2}(thresh,1,:));
            
            %betweenness centrality
            graphdata{6,2}(f,thresh,1:length(chanlocs),iter) = allbet{iter,1}(thresh,:);
            graphdata{6,3}(f,thresh,1:length(chanlocs),iter) = allbet{iter,2}(thresh,:);
            
            %modular span
            graphdata{7,2}(f,thresh,iter) = mean(allms{iter,1}(thresh,:));
            graphdata{7,3}(f,thresh,iter) = mean(allms{iter,2}(thresh,:));
            
            %participation coefficient
            graphdata{8,2}(f,thresh,1:length(chanlocs),iter) = mean(squeeze(allpc{iter,1}(thresh,:,:)));
            graphdata{8,3}(f,thresh,1:length(chanlocs),iter) = mean(squeeze(allpc{iter,2}(thresh,:,:)));
            
            %degree
            graphdata{9,2}(f,thresh,1:length(chanlocs),iter) = alldeg{iter,1}(thresh,:);
            graphdata{9,3}(f,thresh,1:length(chanlocs),iter) = alldeg{iter,2}(thresh,:);
        end
    end
end
fprintf('\n');

if strcmp(param.randomise,'on')
    graphdata_rand = graphdata;
    save(filename, 'graphdata_rand', 'tvals', '-append');
else
    save(filename, 'graphdata', 'tvals', '-append');
end