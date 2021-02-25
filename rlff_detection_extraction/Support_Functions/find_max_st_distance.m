function [stReturn,idxReturn,stStereo,idxStereo,col_use] = find_max_st_distance(s,t,sC,tC)
% function find_max_distance finds the maximum Euclidean distance between
% s,t views from the centre view sc,tc

% option 1: along the same axis?
% option 2: over the entire span of s,t
% the ultimate task is to find the longest line that intersects the central
% view
% for now, lets just move along the central cross and take the longest

% input: s and t are vectors 
%%



% figure;
% plot(s,t,'bo',...
%     sC,tC,'rx');
% grid on;
% box on;
% axis equal;
% title('st views');
% xlabel('s');
% ylabel('t');




%%

% calculate length along vertical axis
% find all t == tC
nViews = length(s);
cnt = 0;
for i = 1:nViews
    if s(i) == sC
        cnt=cnt+1;
        tStereoVert(cnt) = t(i);
        sStereoVert(cnt) = s(i);
        idxVert(cnt) = i;
    end
end 
% sort tStereo in ascending order
[tStereoVert_sort,idxVert_sort] = sort(tStereoVert,'ascend');
sStereoVert_sort = sStereoVert(idxVert_sort); % shouldn't actually matter since tStereoVert should all be = tC
maxVertBaseline = tStereoVert_sort(end) - tStereoVert_sort(1);

% calculate length along horizontal axis
cnt = 0;
for i = 1:nViews
    if t(i) == tC
        cnt=cnt+1;
        sStereoHorz(cnt) = s(i);
        tStereoHorz(cnt) = t(i);
        idxHorz(cnt) = i;
    end
end
% sort sStereo
[sStereoHorz_sort,idxHorz_sort] = sort(sStereoHorz,'ascend');
tStereoHorz_sort = tStereoHorz(idxHorz_sort);
maxHorzBaseline = sStereoHorz_sort(end) - sStereoHorz_sort(1);

% take max baseline
% choose one
% if == then take horizontal
if maxHorzBaseline >= maxVertBaseline
    stReturn = [sStereoHorz; tStereoHorz];
    idxReturn = idxHorz;
    stStereo(1:2,1) = [sStereoHorz_sort(1) sStereoHorz_sort(end)]';
    stStereo(1:2,2) = [tStereoHorz_sort(1) tStereoHorz_sort(end)]';
    idxStereo = idxHorz(idxHorz_sort([1,end]));
    col_use = 1;
else
    stReturn = [sStereoVert; tStereoVert];
    idxReturn = idxVert;
    stStereo(1:2,1) = [sStereoVert_sort(1) sStereoVert_sort(end)]';
    stStereo(1:2,2) = [tStereoVert_sort(1) tStereoVert_sort(end)]';
    idxStereo = idxVert(idxVert_sort([1,end]));
    col_use = 2;
end

end