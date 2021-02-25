function [artStereo_LF,stStereo] = lf_artificial_stereo_post_inter_match(lf_intermatches,LFS,Fst_in,Dst_in,rlff_lf_in,H_cal)
% script to try artificial stereo for Colmap
% run lf_refractiveFeatures_lytro.m first

% for each LF
% for every RLFF inside each LF
% find (s,t) view that is farthest away from centre view,
% find corresponding st view that is farthest away from (s,t) as (s',t')
% for simplicity, (s',t') must be on same axis of either s or t
% given this feature f (from s,t), we want to create f' for (s',t')
% calculate two disparities,
% given H_cal and P01(z), and calculate another P02(z)
% d = f b / Pz, where f = focal length (units?), b = baseline between st
% views, and Pz is depth
% f' set by u'v' given uv + disparity along the appropriate axis of
% st-views
% duplicate scale, orientation and sift descriptor to make f' (two of them)
% return this fprime for every single RLFF...

% have to do this for both matched LF frames

%% defaults


%% parse inputs

%%

% nLF = size(LFS,1);

nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);
D = LFS{1}.D; % same D for all LFs

dS = nS - sC;
dT = nT - tC;
stStereo = [sC-dS tC;
    sC+dS tC];


nCombo = size(lf_intermatches,2);
artStereo_LF = cell(nCombo,1);

%%
for ii = 1:nCombo
    m1 = lf_intermatches(ii).matches_prelim(:,1); % matches wrt Dc_root_in indices
    m2 = lf_intermatches(ii).matches_prelim(:,2);
    frame1 = lf_intermatches(ii).lf1;
    frame2 = lf_intermatches(ii).lf2;
    
    nFtrMatched = length(m1);
    artStereo_F1_P01 = cell(nFtrMatched,1);
    artStereo_F1_P02 = cell(nFtrMatched,1);
    artStereo_F2_P01 = cell(nFtrMatched,1);
    artStereo_F2_P02 = cell(nFtrMatched,1);
    for jj = 1:nFtrMatched
        % matrix of al the rays (intra-LF matches) for a given feature
        % each correspondence per row, each column: s,t,u,v
        rays_lf1 = lf_intermatches(ii).rays1{jj}; % same as rays_lf1
        rays_lf2 = lf_intermatches(ii).rays2{jj};
        
        % the corresponding features: (u,v,scale,orientation)
        f_lf1 = Fst_in{frame1}{m1(jj)};
        f_lf2 = Fst_in{frame2}{m2(jj)};
        D_lf1 = Dst_in{frame1}{m1(jj)};
        D_lf2 = Dst_in{frame2}{m2(jj)};
        % find the st view that is farthest away from the centre?
        % alternatively, find the farthest apart st-views for the given
        % feature? But for simplicity - must be max distance apart along the same s or t axis
        % This is to maximise the baseline, but just stick to using one
        % baseline change? or can we use baseline change for both horz(s)
        % and vert(t) axes?
        
        % TODO: alternatively, we can calculate what the feature/descriptor
        % should be since the 3D point is "Lambertian" and thus easily
        % predictable as to where it should be in any other st-sub image
        % so we set st-Stereo, and then we take the central feature and
        % take it directly if we have it, but otherwise project it onto both st-stereo views
        
        s = rays_lf1(:,1); % stuv, but technically ijkl
        t = rays_lf1(:,2);
        %%
        % given stStereo, and the s, t values, as well as sC and tC, find
        % the indices to return, or alternatively, create new one?
        [idx1,~,f1,~,Dst1,~] = find_stereo_pair(s,t,stStereo,f_lf1,D_lf1);
        % note: (idx1,f1,Dst1) and (idx2,f2,Dst2) can be empty if we could not find
        
        % find central feature and descriptor
        idx_c =  find((sC == s) .* (tC == t));
        fc = f_lf1(idx_c,:);
        Dc = D_lf1(idx_c,:);
        
        %         [stReturn,idxReturn,stStereo1,idxStereo1,col_use1] = find_max_st_distance(s,t,sC,tC);
        % idxStereo1 returns empty if we cannot find matching feature for
        % stStereo
        
        % run artificial stereo for P01
        [artStereo_F1_P01{jj}] = generate_artificial_stereo(rlff_lf_in{frame1}{m1(jj)}.P01,...
            H_cal(:,:,frame1),...
            D, stStereo,...
            fc,Dc,...
            f1,Dst1, jj);
        
        % for P02
        [artStereo_F1_P02{jj}] = generate_artificial_stereo(rlff_lf_in{frame1}{m1(jj)}.P02,...
            H_cal(:,:,frame1),...
            D, stStereo,...
            fc,Dc,...
            f1,Dst1, jj);
        
        s = rays_lf2(:,1); % stuv, but technically ijkl
        t = rays_lf2(:,2);
        [idx2,~,f2,~,Dst2,~] = find_stereo_pair(s,t,stStereo,f_lf2,D_lf2);
        %         [stReturn,idxReturn,stStereo2,idxStereo2,col_use2] = find_max_st_distance(s,t,sC,tC);
        idx_c =  find((sC == s) .* (tC == t));
        fc = f_lf2(idx_c,:);
        Dc = D_lf2(idx_c,:);
        
        % run artificial stereo for P01
        [artStereo_F2_P01{jj}] = generate_artificial_stereo(rlff_lf_in{frame2}{m2(jj)}.P01,...
            H_cal(:,:,frame2),...
            D, stStereo,...
            fc,Dc,...
            f2,Dst2, jj);
        
        % for P02
        [artStereo_F2_P02{jj}] = generate_artificial_stereo(rlff_lf_in{frame2}{m2(jj)}.P02,...
            H_cal(:,:,frame2),...
            D, stStereo,...
            fc,Dc,...
            f2,Dst2, jj);
        
        % Q: how to make sure P01's x and y are satisfied? - assume that
        % since intra-LF-match is correct, then taking any one of the
        % matching st views satisfies the x,y?
        % TODO: also have to do this for the matching point! Thus, for one
        % match, there are 4 pairs of image features that need to be
        % generated
        
    end
    % save artificial stereo for each LF matched pair
    artStereo_LF{ii}.F1_P01 = artStereo_F1_P01;
    artStereo_LF{ii}.F1_P02 = artStereo_F1_P02;
    artStereo_LF{ii}.F2_P01 = artStereo_F2_P01;
    artStereo_LF{ii}.F2_P02 = artStereo_F2_P02;
    
end