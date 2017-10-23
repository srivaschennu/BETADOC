function keepidx = findnearchan(chanlocs,chanlocs2,varargin)

param = finputcheck(varargin, {
    'type', 'string', {'euclidean','geodesic'}, 'euclidean'; ...
    });

chanlocs = cat(2,cell2mat({chanlocs.X})',cell2mat({chanlocs.Y})',cell2mat({chanlocs.Z})');
if strcmp(param.type,'geodesic')
    [THETA, PHI] = cart2sph(chanlocs(:,1),chanlocs(:,2),chanlocs(:,3));
    chanlocs = radtodeg([PHI THETA]);
end

chanlocs2 = cat(2,cell2mat({chanlocs2.X})',cell2mat({chanlocs2.Y})',cell2mat({chanlocs2.Z})');
if strcmp(param.type,'geodesic')
    [THETA, PHI] = cart2sph(chanlocs2(:,1),chanlocs2(:,2),chanlocs2(:,3));
    chanlocs2 = radtodeg([PHI THETA]);
end

chandist = zeros(size(chanlocs,1),size(chanlocs2,1));
keepidx = zeros(length(chanlocs),1);
for c1 = 1:size(chanlocs,1)
    for c2 = 1:size(chanlocs2,1)
        if strcmp(param.type,'geodesic')
            chandist(c1,c2) = distance(chanlocs(c1,:),chanlocs2(c2,:));
        elseif strcmp(param.type,'euclidean')
            chandist(c1,c2) = pdist(cat(1,chanlocs(c1,:),chanlocs2(c2,:)));
        end
    end
    [~,sortidx] = sort(chandist(c1,:));
    for c2 = 1:size(chanlocs2,1)
        if ~any(sortidx(c2) == keepidx(1:c1-1))
            keepidx(c1) = sortidx(c2);
            break
        end
    end
end
