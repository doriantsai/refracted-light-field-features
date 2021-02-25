function [exp_stats] = lf_compute_exp_stats(sfm_ftr_type,n_exp,IS_STEREO,IS_RLFF)

img_ftr_seq = nan(n_exp,1);
did_converge_seq = false(n_exp,1);
put_matches_seq = nan(n_exp,1);
in_matches_seq = nan(n_exp,1);
match_ratio_seq = nan(n_exp,1);
num3D_seq = nan(n_exp,1);
track_len_seq = nan(n_exp,1);
precision_seq = nan(n_exp,1);
matching_score_seq = nan(n_exp,1);
nLFs = nan(n_exp,1);



for ii = 1:n_exp
    if sfm_ftr_type(ii).sfm.did_converge == true
        did_converge_seq(ii) = true;
        nLFs(ii) = sfm_ftr_type(ii).gt_aligned.n;
        img_ftr_seq(ii) = (sfm_ftr_type(ii).sfm.keypoints);
        put_matches_seq(ii) = (sfm_ftr_type(ii).sfm.matches_putative);
        in_matches_seq(ii) = (sfm_ftr_type(ii).sfm.matches_inlier);
        match_ratio_seq(ii) = (sfm_ftr_type(ii).sfm.putative_match_ratio);
        num3D_seq(ii) = sfm_ftr_type(ii).sfm.num_points;
        track_len_seq(ii) = sfm_ftr_type(ii).sfm.track_length;
        precision_seq(ii) = sfm_ftr_type(ii).sfm.precision;
        matching_score_seq(ii) = sfm_ftr_type(ii).sfm.matching_score;
    else
        nLFs(ii) = 0;
    end
end

percent_pass = sum(did_converge_seq) / n_exp;
img_ftr = mean(img_ftr_seq(~isnan(img_ftr_seq)));
put_matches = mean(put_matches_seq(~isnan(put_matches_seq)));
in_matches = mean(in_matches_seq(~isnan(in_matches_seq)));
match_ratio = mean(match_ratio_seq(~isnan(match_ratio_seq)));
num3D = mean(num3D_seq(~isnan(num3D_seq)));
track_len = mean(track_len_seq(~isnan(track_len_seq)));
precision = mean(precision_seq(~isnan(precision_seq)));
matching_score = mean(matching_score_seq(~isnan(matching_score_seq)));

% if rlff_mono
% if IS_RLFF && ~IS_STEREO
%     img_ftr = img_ftr/2;
%     put_matches = put_matches/2;
%     in_matches = in_matches/2;
%     num3D = num3D/2;
% end
% 
% % if rlff_stereo:
% if IS_RLFF && IS_STEREO
%     img_ftr = img_ftr/2;
%     put_matches = put_matches/2;
%     in_matches = in_matches/2;
%     num3D = num3D/2;
%     track_len = track_len/2;
% end
% 
% % if sift_stereo
% if IS_STEREO && ~IS_RLFF
%     %img_ftr = img_ftr/2;
%     %put_matches = put_matches;
%     %in_matches = in_matches/2;
%     %num3D = num3D/2;
%     %track_len = track_len/2;
%     
%     track_len = track_len/2;
% end

nLFs_all = sum(nLFs);

exp_stats.nLFs = nLFs;
exp_stats.nLFs_all = nLFs_all;
exp_stats.percent_pass = percent_pass;
exp_stats.img_ftr = img_ftr;
exp_stats.put_matches = put_matches; 
exp_stats.in_matches = in_matches;
exp_stats.match_ratio = match_ratio;
exp_stats.num3D = num3D;
exp_stats.track_len = track_len;
exp_stats.precision = precision;
exp_stats.matching_score = matching_score;

% added in for future re-calc
exp_stats.did_converge_seq = did_converge_seq;
exp_stats.img_ftr_seq = img_ftr_seq;
exp_stats.put_matches_seq = put_matches_seq;
exp_stats.in_matches_seq = in_matches_seq;
exp_stats.match_ratio_seq = match_ratio_seq;
exp_stats.num3D_seq = num3D_seq;
exp_stats.track_len_seq = track_len_seq;
exp_stats.precision_seq = precision_seq;
exp_stats.matching_score_seq = matching_score_seq;

