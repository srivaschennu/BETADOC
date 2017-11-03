function calcmi(listname,conntype,varargin)

loadpaths
loadsubj

subjlist = eval(listname);
crsdiag = cell2mat(subjlist(:,3));

param = finputcheck(varargin, {
    'randratio', 'string', {'on','off'}, 'off'; ...
    });

load(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype),'graph','tvals');
if strcmp(param.randratio,'on')
    if exist(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype),'file')
        randgraph = load(sprintf('%s/%s/graphdata_%s_rand_%s.mat',filepath,conntype,listname,conntype));
    else
        error('%s/%s/graphdata_%s_rand_%s.mat not found!');
    end
end

weiorbin = 3;

if any(strcmp('mutual information',graph(:,1)))
    midx = find(strcmp('mutual information',graph(:,1)));
else
    graph{end+1,1} = 'mutual information';
    midx = size(graph,1);
end



modinfo = graph{strcmp('participation coefficient',graph(:,1)),weiorbin};
mutinfo = zeros(size(modinfo,1),size(modinfo,2),size(modinfo,3));

meanctrl = squeeze(mean(modinfo(crsdiag == 5,:,:,:),1));

for bandidx = 1:size(modinfo,2)
    for t = 1:size(modinfo,3)
        for s1 = 1:size(modinfo,1)
            mutinfo(s1,bandidx,t) = ...
                corr(squeeze(modinfo(s1,bandidx,t,:)),squeeze(meanctrl(bandidx,t,:)));
            %                     [~, mutinfo(s1,s2,bandidx,t)] = ...
            %                         partition_distance(zscore(squeeze(modinfo(s1,bandidx,t,:))),zscore(squeeze(modinfo(s2,bandidx,t,:))));
        end
    end
end

graph{midx,weiorbin} = mutinfo;
fprintf('Appending mutual information to %s/%s/graphdata_%s_%s.mat.\n',filepath,conntype,listname,conntype);
save(sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype), 'graph','-append');
