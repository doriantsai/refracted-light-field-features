function [idx1,idx2,f1,f2,D1,D2] = find_stereo_pair(s,t,stStereo,f,D)
% input: stStereo, f, s, t
% given stStereo [s1 t1; s2 t2];
% find corresponding row indices from s and t so that we can find f
% if not, then we return empty index and f
% output: idxStereo, fStereo



s1 = stStereo(1,1);
t1  = stStereo(1,2);
s2 = stStereo(2,1);
t2 = stStereo(2,2);

% idx1 = [];
% idx2 = [];
% nViews = length(s);
% for ii = 1:nViews
%     if s1 == s(ii) && t1 == t(ii)
%         idx1 = ii;
%     end
%     if s2 == s(ii) && t2 == t(ii)
%         idx2 = ii;
%     end
% end
idx1 = find( (s1==s) .* (t1==t) );
idx2 = find( (s2==s) .* (t2==t) );

if isempty(idx1)
    f1 = [];
    D1 = [];
else
    f1 = f(idx1,:);
    D1 = D(idx1,:);
end

if isempty(idx2)
    f2 = [];
    D2 = [];
else
    f2 = f(idx2,:);
    D2 = D(idx2,:);
end



end