function [sift_stereo_intermatches] = sift_get_stereo_intermatches(lf_combinations,F_sift_stereo,D_root_sift_stereo,inter_match_threshold)
% function does intermatches for 2D sift stereo based on lf_combinations
% exhaustive matching

% for each combo from lf_combinations
% do 4 matches, for each, do vlc_ubcmatch"
% first: frame1_left to frame1_right
% second: frame1_left to frame2_left
% third: frame1_right to frame2_left
% fourth: frame1_right to frame2_right


nLF = numel(F_sift_stereo);
nCombo = size(lf_combinations,1);
for ii = 1:nCombo
    frame1 = lf_combinations(ii,1);
    frame2 = lf_combinations(ii,2);
    
    sift_stereo_intermatches(ii).f1 = frame1;
    sift_stereo_intermatches(ii).f2 = frame2;
    
    % first: frame1_left to frame1_right
    sift_stereo_intermatches(ii).f1l_f1r = vl_ubcmatch(D_root_sift_stereo{frame1}.left,D_root_sift_stereo{frame1}.right,inter_match_threshold)';
    
    % second: frame1_left to frame2_left
    sift_stereo_intermatches(ii).f1l_f2l = vl_ubcmatch(D_root_sift_stereo{frame1}.left,D_root_sift_stereo{frame2}.left,inter_match_threshold)';
    
    % third: frame1_right to frame2_left
    sift_stereo_intermatches(ii).f1r_f2l = vl_ubcmatch(D_root_sift_stereo{frame1}.right,D_root_sift_stereo{frame2}.left,inter_match_threshold)';
    
    % fourth: frame1_right to frame2_right
    sift_stereo_intermatches(ii).f1r_f2r = vl_ubcmatch(D_root_sift_stereo{frame1}.right,D_root_sift_stereo{frame2}.right,inter_match_threshold)';
end

% note: no outlier rejection - we rely on Colmap's outlier rejection

