%% lf_intra_match_sift_features
% Inputs: LF, SIFT settings
% Outputs: structs F, containing matching sift features for each
% sub-image of the LF, indexed in the same manner as the LF probably
% (tsvu)?
% Dorian Tsai
% 2020 May 06
% dorian.tsai@gmail.com
function [ray_ftr_2,ray_ftr_descr_2,ftr_st_2,ftr_centre,descr_centre,descr_centre_sift,Dsift_st_2] = lf_intra_match_features(LF,F,D_root,D_sift,varargin)
vec = @(i) i(:); % vectorize function

default_st_mask = true;
% default_ftr_selection = 20;
% default_plot_n_views_from_centre = 2;
default_min_num_views = 4;
default_threshold_descriptor_distance = 1.5; % was 1.2
default_threshold_centre_view_disparity = 20; % pixels
default_threshold_st_linear_fit = 0.65;

% partsing input paraemters
p = inputParser;
addRequired(p,'LF',@isnumeric);
addRequired(p,'F',@iscell);
addRequired(p,'D_root',@iscell);
addRequired(p,'D_sift',@iscell);
addParameter(p,'st_mask',default_st_mask,@islogical); % sets a default, unsure how to make nSxnT default matrix without knowing size(LF) ahead of time
% addParameter(p,'ftr_selection',default_ftr_selection,@isnumeric); % the top number of sift features to display
% addParameter(p,'plot_n_views_from_centre',default_plot_n_views_from_centre,@isnumeric);
addParameter(p,'min_num_views',default_min_num_views,@isnumeric);
addParameter(p,'threshold_descriptor_distance',default_threshold_descriptor_distance,@isnumeric);
addParameter(p,'threshold_centre_view_disparity',default_threshold_centre_view_disparity,@isnumeric);
addParameter(p,'threshold_st_linear_fit',default_threshold_st_linear_fit,@isnumeric);

parse(p,LF,F,D_root,D_sift,varargin{:});
LF = p.Results.LF;
F = p.Results.F;
D_root = p.Results.D_root;
D_sift = p.Results.D_sift;

nT = size(LF,1);
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);

st_mask = p.Results.st_mask;
if st_mask == true
    % default st_mask
    st_mask = ones(nT,nS);
else
    st_mask = p.Results.st_mask;
end

% plot_n_views_from_centre = p.Results.plot_n_views_from_centre;
% ftr_selection = p.Results.ftr_selection;
min_num_views = p.Results.min_num_views;
threshold_descriptor_distance = p.Results.threshold_descriptor_distance;
threshold_centre_view_disparity = p.Results.threshold_centre_view_disparity;
threshold_st_linear_fit = p.Results.threshold_st_linear_fit;

%% match centre view features with other sub-images
Fc = F{tC,sC}; % centre view features
Dc_root = D_root{tC,sC}; % centre view descriptors
Dc_sift = D_sift{tC,sC};
nfc = size(Fc,2); % number of features in centre view

% run vl_ubcmatch from centre view to another sub-image
% wonder if I can match refracted features fairly reliably?
% or are we screwed by the Lambertian portions of the scene?

PLOT = false;
rayFeatures = cell(nfc,1); % a cell structure of 2D feature characteristics
rayFeatures_descr = cell(nfc,1); 
ftr_st = cell(nfc,1);
Dsift_st = cell(nfc,1);
% F_match = cell(nT,nS);
% Ftr2D.disp
% Ftr2D.nSupAp
% Ftr2D.feature
% Ftr2D.descriptor
% Ftr2D.ray (stuv)
% Ftr2D.number or ID?
% Ftr2D.score?
% Ftr2D.centre ID?
cnt = 0;
for tt = 1:nT
    for ss = 1:nS
        
        cnt = cnt+1;
        
        % skip centre view
        if ss == sC && tt == tC || isempty(D_root{tt,ss})
            continue
        end
        Dst = D_root{tt,ss};
        
        % match current view to centre view
        % threshold for descriptor distance, 1.5 default, lower means fewer
        % matches/a more stringent matching
        [matches,scores] = vl_ubcmatch(Dc_root,Dst,threshold_descriptor_distance);
        
        Fst = F{tt,ss};
        
        % sort matches according to their scores
%         [~, perm] = sort(scores,'descend');
%         matches = matches(:,perm);
%         scores = scores(perm);
        
        % plot comparison to show features
        if PLOT
            IM_centre = squeeze(LF(tC,sC,:,:,:));
            IM = squeeze(LF(tt,ss,:,:,:));
        
            h_fig = figure('Visible','on');
            h_img = imagesc(cat(2,IM_centre,IM));
            axis image off;
            
            xc = Fc(1,matches(1,:));
            x = Fst(1,matches(2,:)) + size(IM_centre,2);
            yc = Fc(2,matches(1,:));
            y = Fst(2,matches(2,:));
            
            sel = 1:100;
            hold on;
            hLines = line([xc(sel); x(sel)], [yc(sel); y(sel)]);
            set(hLines,'linewidth',1,'color','b');
            plot(xc,yc,'.r');
            plot(x,y,'.g');
            vl_plotframe(Fc(:,matches(1,sel)));
            Fst(1,:) = Fst(1,:) + size(IM_centre,2);
            vl_plotframe(Fst(:,matches(2,sel)));
        end
        
        % for each matched feature to the central view, we want to compile
        % a list of all the rayfeatures (in all other sub-aperture images ss,tt)
        for ii = 1:size(matches,2)
            
            i_match_centre = matches(1,ii);
            i_match_subap = matches(2,ii);
            
            % add central view ray feature, if hasn't already been done
            if isempty(rayFeatures{i_match_centre})
                uc = Fc(1,i_match_centre);
                vc = Fc(2,i_match_centre);
                rayFeatures{i_match_centre} = [sC tC  uc vc];
                rayFeatures_descr{i_match_centre} = Dc_root(:,i_match_centre)';
                ftr_st{i_match_centre} = Fc(:,i_match_centre)';
                Dsift_st{i_match_centre} = Dc_sift(:,i_match_centre)';
            end
            
            % set corresponding stuv
            
            r = [ss tt F{tt,ss}(1,i_match_subap), F{tt,ss}(2,i_match_subap)]; % stuv
            rayFeatures{i_match_centre} = cat(1, rayFeatures{i_match_centre}, r);
            rayFeatures_descr{i_match_centre} = cat(1, rayFeatures_descr{i_match_centre}, D_root{tt,ss}(:,i_match_subap)' );
            ftr_st{i_match_centre} = cat(1, ftr_st{i_match_centre}, F{tt,ss}(:,i_match_subap)'); % save the whole feature
            Dsift_st{i_match_centre} = cat(1,Dsift_st{i_match_centre},D_sift{tt,ss}(:,i_match_subap)');
            
        end
        
        % save F that has been matched for each sub-image. The only issue
        % here is that in subsequent steps in the code, we cull the
        % features, but don't yet keep track of those cullings in F_match
%         F_match{tt,ss} = Fst(:,matches(2,:));
        
    end
end

% so what we should be left with is, for every 2D image feature in the
% central view, we have a list of all the possible matches (from
% vl_ubcmatch (which is just based on Euclidean distance of the sift
% descriptor)), from all the other sub-aperture views



% calculate rough disparity, and remove those features which have an overly large disparity
% note that this could be dangerous, as this might remove refracted LF
% features, though... we would not expect extremely dramatic feature
% movement within a single LF, so maybe there's an argument there - more
% movement than a Lambertian feature, but still not across-the-image

%% remove empty rays and might as well do min_num_views, initial
% not every single ftr is matched to another sub-image
% if so, rayFeatures is empty, so we remove it from the list of
% rayFeatures, and all the other corresponding cell arrays

% need to keep the empties to keep Fc and rayFeatures synced index-wise
% cnt = 0;
% rayFeatures_0 = [];
% rayFeatures_descr_0 = [];
% ftr_st_0 = [];
% for ii = 1:length(rayFeatures)
%     if size(rayFeatures{ii} ,1) >= min_num_views
%        cnt = cnt + 1;
%        rayFeatures_0{cnt} = rayFeatures{ii};
%        rayFeatures_descr_0{cnt} = rayFeatures_descr{ii};
%        ftr_st_0{cnt} = ftr_st{ii};
%     end
% end



%% disparity-based rejection

% we chose to remove features that have an obviously large disparity 
% there's a higher change that the outside views are incorrectly matched,
% but it seems reasonable to "trust" the views nearest the central view, as
% they would be the most similar
% this approach could be dangerous, because if we do have a refracted
% feature, the most disparity changes would be observed at the outer views

% TODO: arbitrary threshold for inter-LF - we don't expect any disparities
% larger than say... 10 pixels? 20 pixels? in Euclidean distance wrt pixels

% for each feature
% find centre view uv
% find all other sub-image correspondences uv
% eliminate if distance is greater than disparity_threshold
for ii = 1:length(rayFeatures)
    if ~isempty(rayFeatures{ii})
        idx_centre = find( (sC == rayFeatures{ii}(:,1)) .* (tC == rayFeatures{ii}(:,2)) );
        ray_ftr_centre = rayFeatures{ii}(idx_centre,:);
        uv0 = ray_ftr_centre(3:4);
        uv = rayFeatures{ii}(:,3:4);
        duv = sqrt(sum((uv - uv0).^2,2));
        idx_keep = find(duv <= threshold_centre_view_disparity);
        
        rayFeatures{ii} = rayFeatures{ii}(idx_keep,:);
        rayFeatures_descr{ii} = rayFeatures_descr{ii}(idx_keep,:);
        ftr_st{ii} = ftr_st{ii}(idx_keep,:);
        Dsift_st{ii} = Dsift_st{ii}(idx_keep,:);
    end
end



%% outlier rejection
% reject through standard deviation of uv coordinates (quick & dirty)
% TODO: ideally, do RANSAC based on planar manifold (4D), but that takes a
% bit more time

% std deviation approach works on the assumption that all the uv
% coordinates should be roughly similar, since the baseline of Illum is
% very small

% for each feature
% take u, compute std dev 
% compute the difference of u - u_std 
% if this is larger than some thresholded multiple of the std deviation of
% u, then reject it
% do the same for v
% need to make new list of ray_ftrs


OUTLIER_REJECT_DIRTYHACK = true;
if OUTLIER_REJECT_DIRTYHACK
    
    std_threshold = 2;
    max_iter = 4;
    [idx_inlier, ray_ftr_inlier,idx_iter,ray_ftr_iter] = reject_outliers_std(rayFeatures,LF,std_threshold,max_iter,min_num_views);
    ray_ftr_1 = ray_ftr_inlier;
    for ii = 1:length(ray_ftr_inlier)
        if ~isempty(ray_ftr_inlier{ii})
            ray_ftr_descr_1{ii} = rayFeatures_descr{ii}(idx_inlier{ii},:);
            ftr_st_1{ii} = ftr_st{ii}(idx_inlier{ii},:);
            Dsift_st_1{ii} = Dsift_st{ii}(idx_inlier{ii},:);
        end
    end
else
    ray_ftr_1 = rayFeatures;
    ray_ftr_descr_1 = rayFeatures_descr;
    ftr_st_1 = ftr_st;
    Dsift_st_1 = Dsift_st;
end

% plot uv histogram:
% figure;
% hist(uv); % blue = u, yellow = v


% disp('outliers rejected?');


%% elimate features who don't have enough sub-aperture views
% min_num_views

% also, eliminate features that don't have enough diversity of views, for
% example, 8 views but all in one row does not yield a stable solution,
% because there is not enough information for the other axis

% thus, for feature ii, if the variance/spread of s,t is greater than some
% threshold, also keep it.


cnt = 0;
ftr_centre = [];
descr_centre = [];
ftr_st_2 = [];
ray_ftr_2 = [];
ray_ftr_descr_2 = [];
Dsift_st_2 = [];
descr_centre_sift = [];


Rsq_st = nan(length(ray_ftr_1),1); % default to automatically fail
Rsq_ts = nan(length(ray_ftr_1),1);
good_st_sampling = false(length(ray_ftr_1),1);
for ii = 1:length(ray_ftr_1) 
    
    good_st_sampling(ii) = false; % reset for each feature
    
    % do linear regression on st values
    % calculate r-squared (coefficient of determination)
    % should fall in -1,1, so we take the absolute value of Rsq
    % threshold it some small value
    % if sufficiently small -> we have good spread
    if ~isempty(ray_ftr_1{ii})
        % check horizontal lines
        s = ray_ftr_1{ii}(:,1);
        t = ray_ftr_1{ii}(:,2);
        S = [ones(length(s),1), s];
        linear_fit_coeff_st = S\t;
        t_calc = S * linear_fit_coeff_st;
        Rsq_st(ii) = 1 - sum((t - t_calc).^2 ) / sum((t - mean(t)).^2);
        
        % check vertical lines
        T = [ones(length(t),1),t];
        linear_fit_coeff_ts = T\s;
        s_calc = T * linear_fit_coeff_ts;
        Rsq_ts(ii) = 1 - sum((s - s_calc).^2)/sum((s-mean(s)).^2);
        
    end
    % note: possible to get NaN, but logical expression takes care of this
    % basically, st-sampling must not form a line vertically or
    % horizontally
    if (abs(Rsq_st(ii)) < threshold_st_linear_fit)  && (abs(Rsq_ts(ii)) < threshold_st_linear_fit)
        good_st_sampling(ii) = true;
    end
    
    if (size(ray_ftr_1{ii} ,1) >= min_num_views) && (good_st_sampling(ii) == true)
       cnt = cnt + 1;
       ray_ftr_2{cnt} = ray_ftr_1{ii};
       ray_ftr_descr_2{cnt} = ray_ftr_descr_1{ii};
       ftr_st_2{cnt} = ftr_st_1{ii};
       Dsift_st_2{cnt} = Dsift_st_1{ii};
%        ftr{cnt} = Fc(:,ii);
       ftr_centre = cat(1,ftr_centre,Fc(:,ii)');
       descr_centre = cat(1,descr_centre,Dc_root(:,ii)');
       descr_centre_sift = cat(1,descr_centre_sift,Dc_sift(:,ii)');
    end
    
end
% script to find the max Rsq and check the s,t:
% [maxRsq,idxRsq] = max(Rsq);
% ii = idxRsq;
%  s = ray_ftr_1{ii}(:,1);
%  t = ray_ftr_1{ii}(:,2);
% [(1:length(ray_ftr_1))' Rsq good_st_sampling]
% disp('intra_feature_match');




end