function plotmaps(patname,measure,bandidx,varargin)

listname = 'betadoc';

loadsubj

subjlist = eval(listname);


plotnames = subjlist(strncmp(patname,subjlist(:,1),length(patname)),1);

for p = 1:length(plotnames)
    plotmap(plotnames{p},measure,bandidx,varargin{:}); 
end

end
