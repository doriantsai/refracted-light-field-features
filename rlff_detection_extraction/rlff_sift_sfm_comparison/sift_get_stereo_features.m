function [F_sift_stereo, D_sift_stereo,D_root_sift_stereo] = sift_get_stereo_features(F,D_root,D_sift, stStereo)

% need F_in for each LF for the given stStereo views
% need corresponding D_root/D_sifts
% 
% nLF = size(LFS,1);
% 
% nT = size(LFS{1}.LF,1);
% nS = size(LFS{1}.LF,2);
% sC = round(nS/2);
% tC = round(nT/2);

% for each stStereo index pair (left and right)
% package the F, save them
% package the D_sift_stereo
% package the D_root_sift_stereo


%% left sub-view:


% F(t,s)
left = 1;
F_sift_stereo.left = F{stStereo(left,2),stStereo(left,1)};
D_sift_stereo.left = D_sift{stStereo(left,2),stStereo(left,1)};
D_root_sift_stereo.left = D_root{stStereo(left,2),stStereo(left,1)};

%% right sub-view:
right = 2;
F_sift_stereo.right = F{stStereo(right,2),stStereo(right,1)};
D_sift_stereo.right = D_sift{stStereo(right,2),stStereo(right,1)};
D_root_sift_stereo.right = D_root{stStereo(right,2),stStereo(right,1)};
