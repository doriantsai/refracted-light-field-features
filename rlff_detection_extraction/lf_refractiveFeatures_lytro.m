function [out] = lf_refractiveFeatures_lytro(exp_name, case_name, LOAD_ALL)

% LFRefractiveFeatures
% Dorian Tsai
% dorian.tsai@gmail.com
% 2020 May 06
%
% purpose:
% - to read in a set of LF sequences (decoded or undecoded)
% - to receive relevant parameters/initialisations
% - to find the relevant features from each LF
% - to run some form of SfM (Colmap or LF-SfM)
% - to provide relevant plots and data (saved to text)

% requires:
% Matlab version R2020a
% Signal Processing Toolbox
% Robotics Toolbox
% ROS Toolbox
% Don's LF Toolbox v0.5

% clearvars


% addpath('Support_Functions/');

% formatOut = 'yyyy-mm-dd-HHMM'; % format for filenames (txt/fig) saved
% now_str = datestr(datetime('now'),formatOut);


%% INPUT

% calibrate LFs with lf_calibrate_lytro.m
% decode LFs with lf_decode_lytro.m

% exp_name = '20200520_rlff_bottle_vert';
% exp_name = '20200520_rlff_bottle_diag';
% exp_name = '20200523_rlff_bottle_vert';
% exp_name = '20200523_rlff_bottle_diag';
% exp_name = '20200523_rlff_lambertian';
% exp_name = 'LFSynthRenders/20200606_rlff_lambertian_synthrobot';
% exp_name = 'LFSynthRenders/20200608_rlff_lambertian_snowflakes';
% exp_name = 'LFSynthRenders/20200610_rlff_lambertian_synthrobot';
% exp_name = '20200611_rlff_lambertian_synthrobot';
% exp_name = '20200616_rlff_lambertian_synthrobot';


% exp_name = '20200619-1432_rlff_lambertian_cyl';
% exp_name = '20200619-1440_rlff_cyl_diag'; % run this!
% exp_name = '20200619-1448_rlff_bottle_diag';
% exp_name = '20200619-1454_rlff_bottle_vert';
% exp_name = '20200619-1506_rlff_big_cup';
% exp_name = '20200619-1524_rlff_many_glasses';

% exp_name = '20200624-1914_rlff_cup_diag_motion'; % kinda shit - removed a number of the trailing images that miss the cup
% exp_name = '20200624-1922_rlff_cup_fwd_motion';
% exp_name = '20200624-1926_rlff_cup_manual1';
% exp_name = '20200624-1932_rlff_cup_manual_arc';
% exp_name = '20200624-1941_rlff_snowrobot';
% exp_name = '20200624-1945_rlff_snowrobot';
% exp_name = '20200624-1948_rlff_snowrobot';
% exp_name = '20200624-1956_rlff_cube';

% exp_name = '20200626-1344_rlff_cyl_vert';
% exp_name = '20200626-1356_rlff_cyl_vert_diagMtn';
% exp_name = '20200626-1406_rlff_cyl_diag_diagMtn';

% exp_name = '20200802-1628_rlff_cyl_vert_arc';
% exp_name = '20200802-2314_rlff_cyl_vert_zigzag';
% exp_name = '20200802-2320_rlff_cyl_vert_zigzag';
% exp_name = '20200802-2323_rlff_cyl_vert_zigzag';
% exp_name = '20200802-2326_rlff_cyl_vert_zigzag';
% exp_name = '20200802-2334_rlff_bottle_vert_zigzag';
% exp_name = '20200802-2340_rlff_wineglass_zigzag';
% exp_name = '20200802-2344_rlff_sphere_zigzag';
% exp_name = '20200802-2348_rlff_snowbot_zigzag';
% exp_name = '20200802-2353_rlff_miniglasses_zigzag';
% exp_name = '20200803-0000_rlff_many_zigzag';
% exp_name = '20200803-0004_rlff_many_horz'; % error with MaxNumOutliers
% exp_name = '20200803-0008_rlff_many_arc'; % error with MaxNumOutliers
% exp_name = '20200803-0021_rlff_nonplanar_arc'; % error w MaxNumOutliers
% exp_name = '20200803-0024_rlff_nonplanar_horz'; % same
% exp_name = '20200803-0027_rlff_nonplanar_zigzag'; % same

% LOAD_ALL = false;

% location of light fields in .mat form (already decoded, and ideally,
% rectified from calibration via lf_decode_lytro.m
data_folder = ['~/Data/' exp_name ];

% location of where to store the colmap image and feature data/files
colmap_folder = ['~/Data/colmap_data/' exp_name];

% get image file names: (all *__Decoded.mat files in data_folder)
strEndPattern = '__Decoded.mat';
[lfFilenames] = getFilenamesInFolder(data_folder,strEndPattern);
nLF = length(lfFilenames);

LFS = cell(nLF,1); % LF Data
H_cal = nan(5,5,nLF); % intrinsic calibration matrix

% load LF data into cells
% fprintf('Loading %g light fields\n',nLF);
n_border_crop_views = 2; % set to 0 for 15x15 normally,
% set to 1 for 13x13
% set to 2 for 11x11
% set to 3 for 9x9
% set to 4 for 7x7
% set to 5 for 5x5

for ii = 1:nLF
    % fprintf('%g:\t%s\n',ii,lfFilenames{ii});
    LFS{ii} = InputLightFieldIllum(data_folder,lfFilenames{ii},n_border_crop_views);
    H_cal(:,:,ii) = LFS{ii}.RectOptions.RectCamIntrinsicsH;
end


%% PARAMETERS

% for loading, if true, the associated ftr_X_filename must exist, and this
% code must have been run before to generate the appropriate file
% TODO: check if file exists, if doesn't exist, just run automatically
LOAD_2D_FEATURES = LOAD_ALL;
LOAD_INTRAMATCHED_FEATURES = LOAD_ALL;

% boolean for controlling plots
P.PLOT = false;
P.SHOW_FIGURES = false;
P.PLOT_FIGURES_SHOW_RUNTIME = false; % set false, otherwise figures pop up and steal window focus while running, make figures visible at end
P.PLOT_2D_SIFT = false;
P.PLOT_RLFF_SLOPE_REL_DIFF = true;
P.PLOT_RLFF_SLOPE_ABS_DIFF = true;
P.PLOT_RLFF_SLOPE_NORM_DIFF = true;
P.PLOT_RLFF_REPROJ_ERROR = false;
P.PLOT_OPTICALFLOW = true;

% load 1 LF to get nS, nT:
nS = LFS{1}.SSize;
nT = LFS{1}.TSize;
nU = LFS{1}.USize;
nV = LFS{1}.VSize;
sC = round(nS/2);
tC = round(nT/2);
% st_mask = binary mask to identify which s,t to sample from
st_mask = true(nT,nS);  % all s,t
% st_mask = logical(generate_central_cross(nT,nS));  % central cross views of s,t
plot_n_views_from_centre = 2;
% plot_mask = false(nT,nS);
% plot_mask(tC-plot_n_views:tC+plot_n_views, sC-plot_n_views:sC+plot_n_views) = 1;
min_num_views = 12; % 12 (June 11) % was 8 for ILlum, JUne09
manual_feature_selection = true;
peak_threshold = 0.02;
threshold_descriptor_distance = 1.5;% 1.2;
threshold_error_reproj = 0.01;
do_outlier_rejection_geometric = true; % was set to false, relying on Colmap's RANSAC; however, set true for illustration purposes
threshold_reprojection_distance = 40; % pixels, point reprojection error
inter_match_threshold = 1.5;
threshold_uvc_mad = 0.005; % 15 worked for lambertian
threshold_uc_mad = 0.005; % 10 worked for lambertian
threshold_vc_mad = 0.005; % 5 worked for lambertian


%% define stStereo pair within the LF

% defined for both rlff_synthetic_stereo and sift_stereo methods
dS = nS - sC;
dT = nT - tC;
leftStereo = sC-dS+1; % set the left to just 1 view shy of the extreme limits of the lf camera baseline
% leftStereo = sC - 3;
if leftStereo < 1
    leftStereo = 1;
end
rightStereo = sC+dS-1; % set right view to 1 view shy of the limits
% rightStereo = sC + 3;
if rightStereo > nS
    rightStereo = nS;
end
stStereo = [leftStereo tC;
    rightStereo tC];


%% FEATURE EXTRACTION & MATCHING

% call lf_extract_matches
% which calls lf_extract_features
% find all the SIFT features in each LF, and each sub-image of each LF
% consider being able to show central view and select a SIFT feature and
% show its EPIs -> will help us get an idea of what we are looking for

ray_ftrs = cell(nLF,1);
ray_ftr_descrs = cell(nLF,1);
Fc = cell(nLF,1);
Fst = cell(nLF,1);
Dc = cell(nLF,1);
rlff_lf = cell(nLF,1);
ray_obs_lf = cell(nLF,1);

rlff_lf_in = cell(nLF,1);
ray_ftrs_in = cell(nLF,1);
ray_ftr_descrs_in = cell(nLF,1);
Fc_in = cell(nLF,1); 
Dc_root_in = cell(nLF,1);
Dc_sift_in = cell(nLF,1);
Fst_in = cell(nLF,1);
Dst_in = cell(nLF,1);

F_sift_stereo = cell(nLF,1);
D_sift_stereo = cell(nLF,1);
D_root_sift_stereo = cell(nLF,1);


F_sift_mono = cell(nLF,1);
D_sift_mono = cell(nLF,1);
D_root_sift_mono = cell(nLF,1);

% figure handles
h_2Dftr = cell(nLF,1);
h_slopes = cell(nLF,1);
h_reproj_error = cell(nLF,1);

tic
for ii = 1: nLF
    
    
    %%
    fprintf('Extract 2D features, ii=%g\n',ii);
    
    % 2D feature filename:
    ftr_2D_filename = [data_folder '/' LFS{ii}.LFName '_2D_Features.mat'];
    ftr_intra_filename = [data_folder '/' LFS{ii}.LFName '_Intra_Features.mat'];
    
    % extract 2D image features as primitives/candidates for intra-feature
    % matching
    if LOAD_2D_FEATURES
        % check if feature files exist
        if exist(ftr_2D_filename,'file')==2
            % load mat file
            fprintf('Skip 2D feature detection/extractuib - Loading: %s\n',ftr_2D_filename);
            ftr_2D_workspace = load(ftr_2D_filename);
            F = ftr_2D_workspace.F;
            D_root = ftr_2D_workspace.D_root;
            D_sift = ftr_2D_workspace.D_sift;
            % F_info = ftr_2D_workspace.F_info;
            ftr_2D_workspace = []; % delete
        else
            disp('Error: 2D feature filename does not exist');
        end
    else
        % extract
        [F, D_root,D_sift] = lf_extract_2D_image_features(LFS{ii}.LF,'st_mask',st_mask,'peak_threshold',peak_threshold);
        % save 2D features
        save(ftr_2D_filename,'F','D_root','D_sift','-v7.3');
    end
   
    if P.PLOT && P.PLOT_2D_SIFT
        fig_name = [data_folder '/' LFS{ii}.LFName '_sift_features.png'];
        ftr_selection = 1;
        [h_2Dftr{ii}] = lf_plot_sift_features(LFS{ii}.LF, F, D_root,P,'st_mask',st_mask,'plot_n_views_from_centre',plot_n_views_from_centre,'ftr_selection',ftr_selection,'fig_name',fig_name);
    end
    
    %%
    % do intra-feature match
    % TODO: attempt RANSAC setup for more robust intra-feature matching, based
    % on H-matrix projection model! Maybe later, as it might not be totally
    % necessary in order to get this thing to work.
    fprintf('Intra-match 2D features in LF, ii=%g\n',ii);
    if LOAD_INTRAMATCHED_FEATURES
        % check if the file exists
        if exist(ftr_intra_filename,'file')==2
            fprintf('Skip Intra-LF feature matching - loading: %s\n',ftr_intra_filename);
            ftr_intra_workspace = load(ftr_intra_filename);
            ray_ftrs{ii} = ftr_intra_workspace.ray_ftrs{ii};
            ray_ftr_descrs{ii} = ftr_intra_workspace.ray_ftr_descrs{ii};
            Fst{ii} = ftr_intra_workspace.Fst{ii};
            Dst{ii} = ftr_intra_workspace.Dst{ii};
            Fc{ii} = ftr_intra_workspace.Fc{ii};
            Dc_root{ii} = ftr_intra_workspace.Dc_root{ii};
            Dc_sift{ii} = ftr_intra_workspace.Dc_sift{ii};
            ftr_intra_workspace = []; % delete
        else
            disp('Error: Intramatch features filename does not exist');
        end
    else
        % do intramatch of features
        [ray_ftrs{ii},ray_ftr_descrs{ii},Fst{ii},Fc{ii},Dc_root{ii},Dc_sift{ii},Dst{ii}] = lf_intra_match_features(LFS{ii}.LF, F, D_root,D_sift,...
            'st_mask',st_mask,'min_num_views',min_num_views,'threshold_descriptor_distance',threshold_descriptor_distance);
        % save intramatch features
        save(ftr_intra_filename,'ray_ftrs','ray_ftr_descrs','Fst','Fc','Dc_root','Dc_sift','Dst','-v7.3');
    end
    
    %%
    % next is feature extraction
    fprintf('RLFF extraction  LF, ii=%g\n',ii);
    [rlff_lf{ii}] = lf_extract_RLFF(LFS{ii},ray_ftrs{ii},Fc{ii},'threshold_error_reproj',threshold_error_reproj);
    
    if P.PLOT && P.PLOT_RLFF_REPROJ_ERROR
        % plot reprojection error sym (symmetric matrix enforced)
        fig_name = [data_folder '/' LFS{ii}.LFName '_error_reproj_sym.png'];
        fig_title = 'SIFT features coloured by reprojection error of lens model';
        nFtr = size(rlff_lf{ii},1);
        error_reproj_sym = zeros(nFtr,1);
        for jj = 1:nFtr
            error_reproj_sym(jj) = rlff_lf{ii}{jj}.error_reproj_sym;
        end
        [h_reproj_error{ii}] = lf_plot_variable_on_central_view(LFS{ii},rlff_lf{ii},ray_ftrs{ii},Fc{ii},P,error_reproj_sym,'error reproj sym',...
            'fig_name',fig_name,'fig_title',fig_title);
    end
    
    
    
    
    
    % for sift_mono, grab relevant feeature-set
    F_sift_mono{ii} = F{tC, sC}';
    D_sift_mono{ii} = D_sift{tC, sC}';
    D_root_sift_mono{ii} = D_root{tC, sC}';
    
    % for sift_stereo, grab the relevant feature-set and descriptor-set:
    [F_sift_stereo{ii},D_sift_stereo{ii},D_root_sift_stereo{ii}] = sift_get_stereo_features(F,D_root,D_sift, stStereo);
    
   
end
toc

% remove rejected features (based on reprojection error) from all
% feature structures: rlff_lf, ray_ftrs,Fc,Dc
[rlff_lf_in, ray_ftrs_in, ray_ftr_descrs_in, Fc_in, Dc_root_in,Dc_sift_in ,Fst_in, Dst_in] = lf_remove_rejected_rlff(rlff_lf,ray_ftrs,ray_ftr_descrs,Fc,Dc_root,Dc_sift,Fst,Dst);

% plot features in central view, colour-coded according to the relative
% slope difference
%     if P.PLOT && (P.PLOT_RLFF_SLOPE_REL_DIFF || P.PLOT_RLFF_SLOPE_ABS_DIFF || P.PLOT_RLFF_SLOPE_NORM_DIFF)
%         nFtr = size(rlff_lf_in{ii},1);
%         slope_rel_diff = zeros(nFtr,1);
%         slope_abs_diff = zeros(nFtr,1);
%         slope_norm_diff = zeros(nFtr,1);
%         for jj = 1:nFtr
%             slope_rel_diff(jj) = rlff_lf_in{ii}{jj}.slope_rel_diff;
%             slope_abs_diff(jj) = rlff_lf_in{ii}{jj}.slope_abs_diff;
%             slope_norm_diff(jj) = rlff_lf_in{ii}{jj}.slope_norm_diff;
%         end
%     end
%     
%     if P.PLOT && P.PLOT_RLFF_SLOPE_REL_DIFF
%         fig_name = [data_folder '/' LFS{ii}.LFName '_slope_rel_diff.png'];
%         fig_title = 'SIFT features coloured by relative slope difference';
%         
%         [h_slopes{ii}] = lf_plot_variable_on_central_view(LFS{ii},rlff_lf_in{ii},ray_ftrs_in{ii},Fc_in{ii},P,slope_rel_diff,'slope relative difference',...
%             'fig_name',fig_name,'fig_title',fig_title);
%     end
%     if P.PLOT && P.PLOT_RLFF_SLOPE_ABS_DIFF
%         fig_name = [data_folder '/' LFS{ii}.LFName '_slope_abs_diff.png'];
%         fig_title = 'SIFT features coloured by absolute slope difference';
%         
%         [h_slopes{ii}] = lf_plot_variable_on_central_view(LFS{ii},rlff_lf_in{ii},ray_ftrs_in{ii},Fc_in{ii},P,slope_abs_diff,'slope abs difference',...
%             'fig_name',fig_name,'fig_title',fig_title);
%     end
%     if P.PLOT && P.PLOT_RLFF_SLOPE_NORM_DIFF
%         fig_name = [data_folder '/' LFS{ii}.LFName '_slope_norm_diff.png'];
%         fig_title = 'SIFT features coloured by normalised slope difference';
%         
%         [h_slopes{ii}] = lf_plot_variable_on_central_view(LFS{ii},rlff_lf_in{ii},ray_ftrs_in{ii},Fc_in{ii},P,slope_norm_diff,'slope norm difference',...
%             'fig_name',fig_name,'fig_title',fig_title);
%     end
%     

% to save memory...
clear F D_root D_sift Fst Dst

% TODO: plot depths
% see x_plot_RLFF_3D_single_LF.m

%% RLFF synthetic stereo for Colmap

% try artificial stereo for Colmap
fprintf('RLFF synthetic stereo: generating features from RLFF\n');
[rlffSynthStereo_LF,stStereo] = rlff_synthetic_stereo(LFS,rlff_lf_in,Fst_in,Dst_in,H_cal,stStereo);

% lf_plotfig_vertical_feature_motion(LFS,stStereo,artStereo_LF,rlff_lf_in,Fst_in,lf_intermatches,Fc_in)
% verify artStereo reprojections:
% plot artStereo on central view?
% plot each stereo view:
% if false
%     for ii = 6
%         savename_centre = [data_folder '/' LFS{ii}.LFName '_centre_features.png'];
%         savename_left = [data_folder '/' LFS{ii}.LFName '_rlff_stereo_left.png'];
%         savename_right = [data_folder '/' LFS{ii}.LFName '_rlff_stereo_right.png'];
%         savename_flow = [data_folder '/' LFS{ii}.LFName '_rlff_flow.png'];
%         [h_centre,h_left,h_right,h_st_flow] = rlff_plot_synthetic_stereo(LFS,rlff_lf_in,rlffSynthStereo_LF,stStereo,Fst_in,ii,...
%             'savename_centre',savename_centre,...
%             'savename_left',savename_left,'savename_right',savename_right,'savename_flow',savename_flow);
%     end
% end


%% INTER-FEATURE MATCHING

fprintf('intermatching LF pairs by sequence\n');

[lf_intermatches,lf_combinations] = lf_inter_match_features(LFS, ray_ftrs_in, ray_ftr_descrs_in, Fc_in, Dc_root_in, rlff_lf_in,...
    'inter_match_threshold',inter_match_threshold,...
    'do_outlier_rejection_geometric',do_outlier_rejection_geometric,'threshold_reprojection_distance',threshold_reprojection_distance,...
    'threshold_uvc_mad',threshold_uvc_mad,'threshold_uc_mad',threshold_uc_mad,'threshold_vc_mad',threshold_vc_mad);

% [lf_intermatches,~] = lf_find_vertical_feature_motion(LFS,ray_ftrs_in,rlff_lf_in,lf_intermatches);

nCombo = size(lf_intermatches,2);
is_outlier = cell(nCombo,1);
% proj_outliers = cell(nCombo,1);
for ii = 1:nCombo
    %     for jj = 1:size(lf_intermatches(ii).matches_prelim,1)
    is_outliers{ii} = lf_intermatches(ii).is_outlier;
    % proj_outliers{ii} = lf_intermatches(ii).projection_outliers1;
end

if P.PLOT
    fprintf('plotting LF intermatching\n');
    % [h_intermatch] = lf_plot_feature_inter_match(LFS,ray_ftrs_in,ray_ftr_descrs_in,Fc_in,Dc_root_in,rlff_lf_in,P,lf_intermatches);
    [h_intermatch] = lf_plot_feature_inter_match(LFS,ray_ftrs_in,ray_ftr_descrs_in,Fc_in,Dc_root_in,rlff_lf_in,P,lf_intermatches,...
        'var_color',is_outliers,'var_name','outlier');
    % [h_intermatch] = lf_plot_feature_inter_match(LFS,ray_ftrs_in,ray_ftr_descrs_in,Fc_in,Dc_root_in,rlff_lf_in,P,lf_intermatches,...
    %     'var_color',proj_outliers,'var_name','projection inliers');
end
% make feature list of central view features for exporting (so outliers are removed)
% ftr_list_c = cell(nLF,1);
% for ii = 1:nCombo
%     % for each LF, take in the list of features from matches_prelim that
%     % belong to the central view (each ray in ray_ftrs is a single 2D ftr
%     % in the central view)
%
%     match_inliers = ~lf_intermatches(ii).uvc_outliers;
%     Fc{ii}(lf_intermatches(ii).matches_prelim(match_inliers==true,1));
%     % find central view
% %     idx_c = find( (sC
% end

%% 2D sift mono for Colmap

[sift_mono_intermatches] = sift_get_mono_intermatches(lf_combinations, F_sift_mono, D_root_sift_mono, inter_match_threshold);
% lf_plotfig_vertical_feature_motion(LFS,stStereo,rlffSynthStereo_LF,rlff_lf_in,Fst_in,lf_intermatches,Fc_in)
%% 2D sift stereo for Colmap

% create a function that uses the same stStereo sub-views, but just take
% the SIFT features from those views, do the inter-lf matching for each
% sub-view pair (exhaustively...)
[sift_stereo_intermatches] = sift_get_stereo_intermatches(lf_combinations,F_sift_stereo,D_root_sift_stereo,inter_match_threshold);

%% check stereo matches quickly: just check in Colmap
% PLOT = true;
% if PLOT
%
%     sel = 3;
%     for ii = sel
%     frame1 = lf_combinations(ii,1);
%     frame2 = lf_combinations(ii,2);
%
%
%     IM_left = rgb2gray(squeeze(LFS{frame1}.LF(tC,sC,:,:,:)));
%         IM_right = rgb2gray(squeeze(LFS{frame2}.LF(tC,sC,:,:,:)));
%     end
% end

%% RLFF mono for Colmap

% project pair of 3D points from RLFF onto centre vi% case_name = [now_str '_default'];ew and send just these
% to colmap
[rlff_synth_mono_LF] = rlff_synthetic_mono(LFS,rlff_lf_in,Fst_in,Dst_in,H_cal);
% TODO: plot rlff_synth_mono!


%% STRUCTURE FROM MOTION

colmap_sift_mono_folder = [colmap_folder '/sift_mono'];
colmap_sift_stereo_folder = [colmap_folder '/sift_stereo'];
colmap_rlff_mono_folder = [colmap_folder '/rlff_mono'];
colmap_rlff_stereo_folder = [colmap_folder '/rlff_stereo'];

% this section is supposed to delete/remove existing folders to prevent
% overlap of files in the colmap_folder
[status,msg,msgID] = mkdir(colmap_folder);
if strcmp(msg,'Directory already exists')
    % remove directory
    rmdir(colmap_folder);
    % make anew
    [status,msg,msgID] = mkdir(colmap_folder); % I don't think this is working
    % this ensures that we are not overlapping our experiments run with
    % different parameters (eg, different n_border_crop_views)
    % we do this for each and every colmap folder
end
% refresh sift_mono folder
[status,msg,msgID] = mkdir(colmap_sift_mono_folder);
if strcmp(msg,'Directory already exists')
    rmdir(colmap_sift_mono_folder);
    [status,msg,msgID] = mkdir(colmap_sift_mono_folder);
end
% refresh sift_stereo folder
[status,msg,msgID] = mkdir(colmap_sift_stereo_folder);
if strcmp(msg,'Directory already exists')
    rmdir(colmap_sift_stereo_folder);
    [status,msg,msgID] = mkdir(colmap_sift_stereo_folder);
end
% refresh rlff_mono folder
[status,msg,msgID] = mkdir(colmap_rlff_mono_folder);
if strcmp(msg,'Directory already exists')
    rmdir(colmap_rlff_mono_folder);
    [status,msg,msgID] = mkdir(colmap_rlff_mono_folder);
end
% refresh rlff_stereo folder
[status,msg,msgID] = mkdir(colmap_rlff_stereo_folder);
if strcmp(msg,'Directory already exists')
    rmdir(colmap_rlff_stereo_folder);
    [status,msg,msgID] = mkdir(colmap_rlff_stereo_folder);
end

%% 
% write centre view to Colmap for 2D SIFT mono:
[sift_mono_img_names,sift_mono_matches_fname] = sfm_write_sift_mono_colmap(LFS,sift_mono_intermatches,colmap_sift_mono_folder,F_sift_mono,D_sift_mono);

% write 2D sift stereo:
[sift_stereo_img_names1, sift_stereo_img_names2,sift_stereo_matches_fname] = sfm_write_sift_stereo_colmap(LFS,sift_stereo_intermatches,colmap_sift_stereo_folder,F_sift_stereo,D_sift_stereo,stStereo);
%%
% write rlff mono:
[rlff_mono_img_names,rlff_mono_matches_fname] = sfm_write_rlff_mono_colmap(LFS,lf_intermatches,colmap_rlff_mono_folder,rlff_synth_mono_LF);
%%
% export artStereo_LF to text, including both the images and the feature files
[rlff_stereo_img_names1,rlff_stereo_img_names2,~,~,rlff_stereo_matches_fname] = sfm_write_rlff_stereo_colmap(LFS,lf_intermatches,rlffSynthStereo_LF,colmap_rlff_stereo_folder,stStereo);

% commands to run Colmap:
% copy images and files into appropriate sub-folders? I  don't think I need
% to, because I am not doing incremental steps

% instead, just edit runAll.sh
%%
% copies appropriate images, textfiles and scripts into the appropriate
% folders/files, but still need to run Colmap from command line
% 
if contains(case_name, 'permissive')
    disp('colmap run files to permissive settings');
    sfm_set_colmap_runfiles_permissive(colmap_folder,nLF,exp_name, case_name)
else
    disp('colmap run files to default settings');
    sfm_set_colmap_runfiles_default(colmap_folder,nLF,exp_name, case_name)
end


%% PLOTS & TABLES

% make them visible, but note that we would have to run for-loop for all
% LFs, but also save the figure handles for each LF
if P.PLOT && (P.PLOT_FIGURES_SHOW_RUNTIME == false)
    
    if P.SHOW_FIGURES == true
        for ii = 1:nLF
            if exist('h_2Dftr','var'), h_2Dftr{ii}.Visible = 'on'; end
            if exist('h_slopes','var'), h_slopes{ii}.Visible = 'on'; end
            if exist('h_reproj_error','var'), h_reproj_error{ii}.Visible = 'on'; end
        end
        %%
        for ii = 1:size(lf_intermatches,2)
            if exist('h_intermatch','var'), h_intermatch{ii}.Visible = 'on'; end
        end
    end
end


%% save data

% clearvars to free up memory?
% clearvars

% variables that we want:
out = struct;

% the LF sequence:
out.casename = case_name;
out.expname = exp_name;
out.LFS = LFS;

% sift features:
out.F_sift_mono = F_sift_mono;
% out.D_sift_mono % maybe
out.sift_mono_intermatches = sift_mono_intermatches;

out.F_sift_stereo = F_sift_stereo;
% out.D_sift_stereo
out.sift_stereo_intermatches = sift_stereo_intermatches;

% rlff features:
out.rlff_synth_mono_LF = rlff_synth_mono_LF;
% out.rlffSynthStereo_LF = rlffSynthStereo_LF;
rlff_synth_stereo_LF = rlffSynthStereo_LF;
out.rlff_synth_stereo_LF = rlff_synth_stereo_LF;

% out.lf_intermatches = lf_intermatches;
out.ray_ftrs_in = ray_ftrs_in;
out.rlff_lf_in = rlff_lf_in;

% unfortunately, out.X system means that the end-user can only load the
% ENTIRE out file for future reference, which is very slow. It is better to
% just save each variable name


save_out_filename = [data_folder '/' exp_name '.mat'];
fprintf('Saving feature data as: %s\n', save_out_filename);
save(save_out_filename, 'LFS', ...
                        'case_name', ...
                        'exp_name', ...
                        'F_sift_mono', ...
                        'sift_mono_intermatches', ...
                        'F_sift_stereo', ...
                        'sift_stereo_intermatches', ...
                        'rlff_synth_mono_LF', ...
                        'rlff_synth_stereo_LF', ...
                        'lf_intermatches', ...
                        'ray_ftrs_in', ...
                        'rlff_lf_in', ...
                        'stStereo',...
                        'Fst_in',...
                        'Fc_in',...
                        '-v7.3');

clearvars -except out case_name exp_name

end
