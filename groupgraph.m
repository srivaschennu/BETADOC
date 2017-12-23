function groupgraph(listname,conntype,varargin)

loadpaths
loadsubj

param = finputcheck(varargin, {
    'randomise', 'string', {'on','off'}, 'off'; ...
    'latticise', 'string', {'on','off'}, 'off'; ...
    });

subjlist = eval(listname);
subjlist = subjlist(2:end,:);

savename = sprintf('%s/%s/graphdata_%s_%s.mat',filepath,conntype,listname,conntype);

for s = 1:size(subjlist,1)
    basename = subjlist{s,1};
    grp(s,1) = subjlist{s,3};
    
    fprintf('Processing %s.\n',basename);
    
    loadname = sprintf('%s/%s_betadoc.mat',filepath,basename);
    load(loadname);
    
    if s == 1
        graph = graphdata(:,1);
        for m = 1:size(graph,1)
            graph{m,2} = zeros([size(subjlist,1) size(graphdata{m,2})]);
            graph{m,3} = zeros([size(subjlist,1) size(graphdata{m,3})]);
        end
    end
    
    for m = 1:size(graph,1)
        graph{m,2}(s,:) = graphdata{m,2}(:);
        graph{m,3}(s,:) = graphdata{m,3}(:);
    end
end

save(savename, 'graph', 'grp', 'tvals', 'subjlist');