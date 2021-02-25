function [lf_intermatches,lf_combinations,h_fig] = lf_inter_match_features(LFS, ray_ftrs, ray_ftr_descrs, Fc, Dc, rlff_lf,varargin)
% function lf_inter_match_features matches features between two different
% LF captures
% currently, just 2D matching with vl_ubcmatch
% future work: ransac based on 4D plane model

%% defaults

default_inter_match_threshold = 1.5;
default_fig_name = 'rlff_interLFmatch.png';
default_threshold_uvc_mad = 25;
default_threshold_uc_mad = 5;
default_threshold_vc_mad = 5; % for horizontal imagery
default_do_outlier_rejection_geometric = false;
default_threshold_reprojection_distance = 1.5;

%% parse inputs

p = inputParser;
addRequired(p,'LFS',@iscell);
addRequired(p,'ray_ftrs',@iscell);
addRequired(p,'ray_ftr_descrs',@iscell);
addRequired(p,'Fc',@iscell);
addRequired(p,'Dc',@iscell);
addRequired(p,'rlff_lf',@iscell);

addParameter(p,'inter_match_threshold',default_inter_match_threshold,@isnumeric);
addParameter(p,'fig_name',default_fig_name,@isstr);
addParameter(p,'threshold_uvc_mad',default_threshold_uvc_mad,@isnumeric);
addParameter(p,'threshold_uc_mad',default_threshold_uc_mad,@isnumeric);
addParameter(p,'threshold_vc_mad',default_threshold_vc_mad,@isnumeric);
addParameter(p,'do_outlier_rejection_geometric',default_do_outlier_rejection_geometric,@islogical);
addParameter(p,'threshold_reprojection_distance',default_threshold_reprojection_distance,@isnumeric);

parse(p,LFS,ray_ftrs,ray_ftr_descrs,Fc,Dc,rlff_lf,varargin{:});
LFS = p.Results.LFS;
ray_ftrs = p.Results.ray_ftrs;
ray_ftr_descrs = p.Results.ray_ftr_descrs;
Fc = p.Results.Fc;
Dc = p.Results.Dc;
rlff_lf = p.Results.rlff_lf;
inter_match_thresh = p.Results.inter_match_threshold;
fig_name = p.Results.fig_name;
threshold_uvc_mad = p.Results.threshold_uvc_mad;
threshold_uc_mad = p.Results.threshold_uc_mad;
threshold_vc_mad = p.Results.threshold_vc_mad;
do_outlier_rejection_geometric = p.Results.do_outlier_rejection_geometric;
threshold_reprojection_distance = p.Results.threshold_reprojection_distance;

maxNumOutliers = 10;

%%
DO_EXHAUSTIVE_INTERMATCHING = true;
nLF = size(LFS,1);

nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);

% take one pair of LFs (probably just in sequence)
% take their respective descriptors according to the features within
% ray_ftr -> matches
% run vl_ubcmatch on those descriptor lists
% then we have preliminary matches

% figure out what combinations of LFs to match
% we want sequential LF matches

if DO_EXHAUSTIVE_INTERMATCHING
    % consider exhaustive matching:
    % k = 2;
    % nCombo = factorial(nLF)/(factorial(nLF-k)*factorial(k));
    lf_combinations = combnk(1:nLF,2);
else
    % consider pair-wise incremental matching:
    lf_combinations = [1:nLF-1; 2:nLF]';
end
nCombo = size(lf_combinations,1);
% since everything is run in sequence, let's quick hack: if diff is greater
% than 10, we simply remove the combo (this due to insufficient matches at
% the extremes)
diff_combo = lf_combinations(:,2) - lf_combinations(:,1); % always positive
remove_combo = abs(diff_combo) > 10;
lf_combinations = lf_combinations(remove_combo == false,:);    
nCombo = size(lf_combinations,1);
% for plotting
h_fig = cell(nCombo,1);

% for each combo of LFs, do inter-LF matching, match based on centre views
lf_intermatches = [];
for ii = 1:nCombo
    frame1 = lf_combinations(ii,1);
    frame2 = lf_combinations(ii,2);
    lf_intermatches(ii).matches_prelim = vl_ubcmatch(Dc{frame1}',Dc{frame2}',inter_match_thresh)';
    lf_intermatches(ii).lf1 = frame1;
    lf_intermatches(ii).lf2 = frame2;
    lf_intermatches(ii).lf1_name = LFS{frame1}.LFName;
    lf_intermatches(ii).lf2_name = LFS{frame2}.LFName;
end

max_iter = 1; % was 2


%% OUTLIER REJECTION
% crude disparty-based rejection, because we know we are only moving small amounts
% note that we only mark matches as outliers, rather than remove them
% directly, so that we can see them on the plots and confirm that the
% method is working.
% TODO: ransac based on 4D planar model


% estimateGeometricTransform - basically motion-based ransac for a
% Lambertian scene
if do_outlier_rejection_geometric
    for ii = 1:nCombo
        m1 = lf_intermatches(ii).matches_prelim(:,1);
        m2 = lf_intermatches(ii).matches_prelim(:,2);
        frame1 = lf_intermatches(ii).lf1;
        frame2 = lf_intermatches(ii).lf2;
        
        ftrs1 = Fc{frame1}(m1,1:2);
        ftrs2 = Fc{frame2}(m2,1:2);
        [t_form, inlier1, inlier2] = estimateGeometricTransform(ftrs1,ftrs2,'projective','MaxDistance',threshold_reprojection_distance);
        
%         if PLOT
%             IM1 = rgb2gray(squeeze(LFS{frame1}.LF(tC,sC,:,:,1:3)));
%             IM2 = rgb2gray(squeeze(LFS{frame2}.LF(tC,sC,:,:,1:3)));
%             figure;
%             showMatchedFeatures(IM1,IM2,ftrs1,ftrs2);
%             title('matched features (inc outliers)');
%             
%             figure;
%             showMatchedFeatures(IM1,IM2,inlier1,inlier2);
%             title('matched inliers');
%         end
        
%         nFtrMatched = length(m1);
%         
        % need the indices of the inliers relative to the original feature
        % sets
        inlier1_set = ismember(ftrs1,inlier1,'rows'); % seem to be
%         getting duplicates, higher count of outliers than expected
        inlier2_set = ismember(ftrs2,inlier2,'rows');
%         
%         nFtrMatched = length(m1);
%         projection_inliers = zeros(nFtrMatched,1);
%         size(ftrs1)
%         for jj = 1:nFtrMatched
%             idx_fix = find(ftrs1(jj,1) == inlier1(:,1),1);
%             if ~isempty(idx_fix)
%                 if length(idx_fix) > 1
%                     disp('found idx_fix > 1');
%                     idx_fix
%                 end
%                 projection_inliers(jj) = true;
%             else
%                 projection_inliers(jj) = false;
%             end
%         end
%         size(inlier1)
%         sum(projection_inliers)
        
        % debug: let's check the opposite:
%         proj_in = zeros(length(inlier1(:,1)),1);
%         for jj = 1:length(inlier1(:,1))
%             [idx_find_row,idx_find_col] = find(inlier1(jj,1) == ftrs1(:,1),1);
%             idx_find_row
%             if ~isempty(idx_find_row)
%                 if length(idx_find_row) > 1
%                     disp('found multiple idx_find');
%                     idx_find_row
%                 end
%                 proj_in(jj) = true;
%             else
%                 proj_in(jj) = false;
%             end
%         end
%         sum(proj_in)
        lf_intermatches(ii).projection_outliers1 = ~inlier1_set(:,1);
        lf_intermatches(ii).projection_outliers2 = ~inlier2_set(:,1);
    end
end







% for each combination (pair of sequential LFs)
% crude outlier rejection
for ii = 1:nCombo
    m1 = lf_intermatches(ii).matches_prelim(:,1);
    m2 = lf_intermatches(ii).matches_prelim(:,2);
    frame1 = lf_intermatches(ii).lf1;
    frame2 = lf_intermatches(ii).lf2;
    
    nFtrMatched = length(m1);
    % matched rays - each one is a list of all the correspondences from all
    % stuv observations in the LF frame
    lf_intermatches(ii).rays1 = ray_ftrs{frame1}(m1);
    lf_intermatches(ii).rays2 = ray_ftrs{frame2}(m2);
    
    uvc1 = zeros(nFtrMatched,2);
    uvc2 = zeros(nFtrMatched,2);
    for jj = 1:nFtrMatched
        stuv1 = lf_intermatches(ii).rays1{jj};
        stuv2 = lf_intermatches(ii).rays2{jj};
        
        % find central view of frame1, frame2
        idx_c1 =  find((sC == stuv1(:,1)) .* (tC == stuv1(:,2)) );
        idx_c2 = find( (sC == stuv2(:,1)) .* (tC == stuv2(:,2)) );
        %
        uvc1(jj,:) = lf_intermatches(ii).rays1{jj}(idx_c1,3:4); % all these stuv compared to
        uvc2(jj,:) = lf_intermatches(ii).rays2{jj}(idx_c2,3:4); % all these stuv, can be of different length!
        % therefore, only consider uv0
    end
    
    uvc_out = zeros(nFtrMatched,1); % initialise all as not outliers
    vc_out = zeros(nFtrMatched,1);
    uc_out = zeros(nFtrMatched,1);
    idx_in = cell(max_iter,1);
    idx_all = 1:nFtrMatched;
    uvc_out_save = cell(max_iter,1);
    vc_out_save = cell(max_iter,1);
    uc_out_save = cell(max_iter,1);
    for kk = 1:max_iter
        % find the average feature displayment across all features
        
        idx_in{kk} = idx_all((~uvc_out .* ~vc_out .* ~uc_out) == true);
        
        uvc_diff = sqrt(sum((uvc2(idx_in{kk},:) - uvc1(idx_in{kk},:)).^2,2));
        uc_diff = (uvc2(idx_in{kk},1) - uvc1(idx_in{kk},1)) - mean(uvc2(idx_in{kk},1) - uvc1(idx_in{kk},1),1);
        vc_diff = (uvc2(idx_in{kk},2) - uvc1(idx_in{kk},2)) - mean(uvc2(idx_in{kk},2) - uvc1(idx_in{kk},2),1);

        [n_diff,~] = size(uvc_diff);
        if (n_diff > maxNumOutliers)
            [uvc_out,uvc_low,uvc_up,uvc_mid] = isoutlier(uvc_diff,'gesd','ThresholdFactor',threshold_uvc_mad,'MaxNumOutliers',maxNumOutliers);
            [uc_out,uc_low,uc_up,uc_mid] = isoutlier(uc_diff,'gesd','ThresholdFactor',threshold_uc_mad,'MaxNumOutliers',maxNumOutliers); % use mean instead of mean absolute diff to try and differentiate negative from positive?
            [vc_out,vc_low,vc_up,vc_mid] = isoutlier(vc_diff,'gesd','ThresholdFactor',threshold_vc_mad,'MaxNumOutliers',maxNumOutliers);
        else
            disp('Warning: n_diff <= maxNumOutliers - likely insufficient number of features');
            uvc_out = uvc_diff;
            vc_out = vc_diff;
            uc_out = uc_diff;
        end
        uvc_out_save{kk} = uvc_out;
        vc_out_save{kk} = vc_out;
        uc_out_save{kk} = uc_out;
    end
    % need to "re-expand" uvc_out, uc_out and vc_out to correspond to
    % idx_all indices
    % for each iteration of max_iter, mark down
    uvc_out_f = zeros(nFtrMatched,1);
    vc_out_f = zeros(nFtrMatched,1);
    uc_out_f = zeros(nFtrMatched,1);
    for kk = max_iter:-1:1
        uvc_out_f(idx_in{kk}) = uvc_out_f(idx_in{kk}) + uvc_out_save{kk};
        vc_out_f(idx_in{kk}) = vc_out_f(idx_in{kk}) + vc_out_save{kk};
        uc_out_f(idx_in{kk}) = uc_out_f(idx_in{kk}) + uc_out_save{kk};
    end
    
    lf_intermatches(ii).uvc_outliers = uvc_out_f;
    %     lf_intermatches(ii).uvc_low = uvc_low;
    %     lf_intermatches(ii).uvc_up = uvc_up;
    %     lf_intermatches(ii).uvc_mid = uvc_mid;
    
    lf_intermatches(ii).uc_outliers = uc_out_f;
    %     lf_intermatches(ii).uc_low = uc_low;
    %     lf_intermatches(ii).uc_up = uc_up;
    %     lf_intermatches(ii).uc_mid = uc_mid;
    
    lf_intermatches(ii).vc_outliers = vc_out_f;
    %     lf_intermatches(ii).vc_low = vc_low;
    %     lf_intermatches(ii).vc_up = vc_up;
    %     lf_intermatches(ii).vc_mid = vc_mid;
    
    % plot outliers wrt uvc_distance
    %     figure;
    %     f = 1:nFtrMatched;
    %     plot(f,uc_diff,...
    %         f(uc_out),uc_diff(uc_out),'x',...
    %         f,uc_low*ones(size(f)),...
    %         f,uc_up*ones(size(f)),...
    %         f,uc_mid*ones(size(f)));
    %     legend('original uc','outlier','lower thresh','upper thresh','middle value');
    %
    %     figure;
    %     f = 1:nFtrMatched;
    %     plot(f,vc_diff,...
    %         f(vc_out),vc_diff(vc_out),'x',...
    %         f,vc_low*ones(size(f)),...
    %         f,vc_up*ones(size(f)),...
    %         f,vc_mid*ones(size(f)));
    %     legend('original vc','outlier','lower thresh','upper thresh','middle value');
    
    %     h_fig{ii}.Visible = 'on';
    % reject those features (remove from matches(ii).rays1 and make new set
    % of matches, which are a subset of matches_prelim
    
end

% TODO: on-stop-shop for outlier rejection flag:
for ii = 1:1:nCombo
    m1 = lf_intermatches(ii).matches_prelim(:,1);
    m2 = lf_intermatches(ii).matches_prelim(:,2);
    frame1 = lf_intermatches(ii).lf1;
    frame2 = lf_intermatches(ii).lf2;
    
    nFtrMatched = length(m1);
    lf_intermatches(ii).is_outlier = false(nFtrMatched,1);
    for jj = 1:nFtrMatched
%         
%         outlier_check_pix_disparity = (lf_intermatches(ii).vc_outliers(jj) || ...
%             lf_intermatches(ii).uc_outliers(jj) || ...
%             lf_intermatches(ii).uvc_outliers(jj) );
        
         outlier_check_pix_disparity = (lf_intermatches(ii).uvc_outliers(jj) );
        
        outlier_check_projection = false;
        if isfield(lf_intermatches,'projection_outliers1')
            if lf_intermatches(ii).projection_outliers1(jj)
                outlier_check_projection = true;
            end
        end
        
        if outlier_check_pix_disparity || outlier_check_projection
            lf_intermatches(ii).is_outlier(jj) = true;
        end
        
    end
end

%% temp hack - remove all outlier rejection here: rely completely on Colmap to reject intermatches
for ii = 1:nCombo
    m1 = lf_intermatches(ii).matches_prelim(:,1);
    nFtrMatched = length(m1);
    lf_intermatches(ii).is_outlier = false(nFtrMatched,1);
end

%% 
if false
    ii = 3;
    [lf_intermatches(ii).uc_outliers lf_intermatches(ii).vc_outliers lf_intermatches(ii).uvc_outliers lf_intermatches(ii).projection_outliers1]
    
    
    frame1 = lf_intermatches(ii).lf1;
    frame2 = lf_intermatches(ii).lf2;
    m1 = lf_intermatches(ii).matches_prelim(:,1);
    m2 = lf_intermatches(ii).matches_prelim(:,2);
    disp('debug');
    figure;
    IM1 = rgb2gray(squeeze(LFS{frame1}.LF(tC,sC,:,:,:)));
    h_img = imagesc(IM1);
    colormap('gray');
    axis image off;
    
    x1 = Fc{frame1}(m1,1);
    y1 = Fc{frame1}(m1,2);
    x2 = Fc{frame2}(m2,1);
    y2 = Fc{frame2}(m2,2);
    n_ftr_match = length(x1);
    sel = 1:n_ftr_match;
    hold on;
    
    for jj = 1:n_ftr_match
        
        if lf_intermatches(ii).is_outlier(jj) == true % thresholded, vs graded by colour
            hLines1 = line([x1(jj) x2(jj)]', [y1(jj) y2(jj)]');
            set(hLines1,'linewidth',3,'color','yellow'); % maybe make alphadata 0.5
            plot(x1,y1,'.y','markersize',5);
            plot(x2,y2,'.y','markersize',5);
        end
    end
    for jj = 1:length(sel)
        if  lf_intermatches(ii).is_outlier(sel(jj)) == true  % thresholded, vs graded by colour
            hLines = line([x1(sel(jj)) x2(sel(jj))]', [y1(sel(jj)) y2(sel(jj))]');
            set(hLines,'linewidth',3,'color','yellow'); % maybe make alphadata 0.5
            plot(x1(sel),y1(sel),'.y','markersize',5);
            plot(x2(sel),y2(sel),'.y','markersize',5);
        end
    end% plot features and lines going from red to green
    hLines = line([x1(sel) x2(sel)]', [y1(sel) y2(sel)]');
    set(hLines,'linewidth',1,'color','b'); % maybe make alphadata 0.5
    plot(x1,y1,'.r');
    plot(x2,y2,'.g');
    
    hold off;
end
