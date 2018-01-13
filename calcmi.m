function calcmi(listname,conntype,varargin)

loadpaths
loadsubj

measure = 'participation coefficient';

subjlist = eval(listname);
allsubjlist = eval('allsubj');
loadcovariates
crsdiag = cell2mat(allsubjlist(2:end,strcmp('crsdiag',covariatenames)));

param = finputcheck(varargin, {
    'randratio', 'string', {'on','off'}, 'off'; ...
    });

load(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype),'graph','tvals');
ctrlgraph = load(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,'allsubj',conntype),'graph','tvals');

weiorbin = 3;

if any(strcmp('mutual information',graph(:,1)))
    midx = find(strcmp('mutual information',graph(:,1)));
else
    graph{end+1,1} = 'mutual information';
    midx = size(graph,1);
end

modinfo = graph{strcmp(measure,graph(:,1)),weiorbin};

allctrl = ctrlgraph.graph{strcmp(measure,graph(:,1)),weiorbin}(crsdiag == 5,:,:,:);
% meanctrl = squeeze(mean(ctrlgraph.graph{strcmp(measure,graph(:,1)),weiorbin}(crsdiag == 5,:,:,:),1));

mutinfo = zeros(size(modinfo,1),size(allctrl,1),size(modinfo,2),size(modinfo,3));

for bandidx = 1:size(modinfo,2)
    for t = 1:size(modinfo,3)
        for s1 = 1:size(modinfo,1)
            for s2 = 1:size(allctrl,1)
                mutinfo(s1,s2,bandidx,t) = ...
                    corr(squeeze(modinfo(s1,bandidx,t,:)),squeeze(allctrl(s2,bandidx,t,:)));
            %                     [~, mutinfo(s1,s2,bandidx,t)] = ...
            %                         partition_distance(zscore(squeeze(modinfo(s1,bandidx,t,:))),zscore(squeeze(modinfo(s2,bandidx,t,:))));
            end
        end
    end
end

graph{midx,weiorbin} = mutinfo;
fprintf('Appending mutual information to %s/%s/graphdata_%s_%s.mat.\n',filepath,conntype,listname,conntype);
save(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype), 'graph','-append');
