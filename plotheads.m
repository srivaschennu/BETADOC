function plotheads(patname,bandidx)

listname = 'betadoc';

loadsubj

subjlist = eval(listname);


plotnames = subjlist(strncmp(patname,subjlist(:,1),length(patname)),1);

for p = 1:length(plotnames)
    plothead(plotnames{p},bandidx); 
end

end
