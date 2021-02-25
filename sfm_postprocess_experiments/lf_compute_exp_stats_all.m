function [ftr_stats] = lf_compute_exp_stats_all(sm, ss, rm, rs, n_exp)
% to compare apples to apples
% we only compare the cases where all 4 cases converged

% sm = sift mono
% ss = sift stereo
% rm = rlff mono
% rs = rlff stereo

ftr = cell(4,1);
ftr{1} = sm;
ftr{2} = ss;
ftr{3} = rm;
ftr{4} = rs;


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

% note: we only want to compare those LFs from the largest overlapping set
% of LFs 
ftr_stats = struct;
for jj = 1:4 % ftr type loop
    
    if jj == 1
        ftr_stats(jj).type = 'sift_mono';
    elseif jj == 2
        ftr_stats(jj).type = 'sift_stereo';
    elseif jj == 3
        ftr_stats(jj).type = 'rlff_mono';
    else
        ftr_stats(jj).type = 'rlff_stereo';
    end
    
    for ii = 1:n_exp % sequence loop
        if ftr{jj}.sfm.did_converge == true
            
            ftr_stats(jj).did_converge_seq(ii) = true;
            ftr_stats(jj).nLFs(ii) = ftr{jj}(ii).gt_aligned.n;
        end
            
        if (sm(ii).sfm.did_converge && ss(ii).sfm.did_converge && ...
                rm(ii).sfm.did_converge && rs(ii).sfm.did_converge)
            
            ftr_stats(jj).img_ftr_seq(ii) = (ftr{jj}(ii).sfm.keypoints);
            ftr_stats(jj).put_matches_seq(ii) = (ftr{jj}(ii).sfm.matches_putative);
            ftr_stats(jj).in_matches_seq(ii) = (ftr{jj}(ii).sfm.matches_inlier);
            ftr_stats(jj).match_ratio_seq(ii) = (ftr{jj}(ii).sfm.putative_match_ratio);
            ftr_stats(jj).num3D_seq(ii) = ftr{jj}(ii).sfm.num_points;
            ftr_stats(jj).track_len_seq(ii) = ftr{jj}(ii).sfm.track_length;
            ftr_stats(jj).precision_seq(ii) = ftr{jj}(ii).sfm.precision;
            ftr_stats(jj).matching_score_seq(ii) = ftr{jj}(ii).sfm.matching_score;
        else
            ftr_stats(jj).nLFs(ii) = 0;
        end
    end
    
    % compute stats
    ftr_stats(jj).percent_pass = sum(ftr_stats(jj).did_converge_seq) / n_exp;
    
    ftr_stats(jj).img_ftr = mean(ftr_stats(jj).img_ftr_seq(~isnan(ftr_stats(jj).img_ftr_seq)));
    ftr_stats(jj).put_matches = mean(ftr_stats(jj).put_matches_seq(~isnan(ftr_stats(jj).put_matches_seq)));
    ftr_stats(jj).in_matches = mean(ftr_stats(jj).in_matches_seq(~isnan(ftr_stats(jj).in_matches_seq)));
    ftr_stats(jj).match_ratio = mean(ftr_stats(jj).match_ratio_seq(~isnan(ftr_stats(jj).match_ratio_seq)));
    ftr_stats(jj).num3D = mean(ftr_stats(jj).num3D_seq(~isnan(ftr_stats(jj).num3D_seq)));
    ftr_stats(jj).track_len = mean(ftr_stats(jj).track_len_seq(~isnan(ftr_stats(jj).track_len_seq)));
    ftr_stats(jj).precision = mean(ftr_stats(jj).precision_seq(~isnan(ftr_stats(jj).precision_seq)));
    ftr_stats(jj).matching_score = mean(ftr_stats(jj).matching_score_seq(~isnan(ftr_stats(jj).matching_score_seq)));
    
end