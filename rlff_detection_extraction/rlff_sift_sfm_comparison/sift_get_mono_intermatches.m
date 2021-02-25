function [sift_mono_intermatches] = sift_get_mono_intermatches(lf_combinations, F_sift, D_root, inter_match_threshold)
% function does intermatches for 2D sift mono based on lf_combinations
% exhaustive matching

% uses vlc_ubcmatch to find nearest Euclidean descriptors (see vl_ubcmatch)

nLF = numel(F_sift);
nCombo = size(lf_combinations,1);
for ii = 1:nCombo
    frame1 = lf_combinations(ii,1);
    frame2 = lf_combinations(ii,2);
    sift_mono_intermatches(ii).f1 = frame1;
    sift_mono_intermatches(ii).f2 = frame2;
    
    sift_mono_intermatches(ii).f1_f2 = vl_ubcmatch(D_root{frame1}', D_root{frame2}', inter_match_threshold)';
    
    % TODO - in order to reuse lf_write_match_file_Colmap.m, we put in some
    % dummy variables
%     sift_mono_intermatches(ii). uvc_outliers = zeros(size(sift_mono_intermatches(ii).f1_f2,2));
    
end

% note: no outlier rejection - we rely on Colmap's outlier rejection