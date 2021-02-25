function sfm_set_colmap_runfiles_default(colmap_folder,nLF,exp_name, case_name)
% a function to edit the script files that ultimately run colmap
% system(cmd_run); had library dependency issues, which I am circumeventing
% by running colmap via command line interface 


% Dorian Tsai
% June 14 2020

% input: possibly the run filename, file location
% nTests, nTotalImg, exp_name,new location for the runAll.sh file


%% parameters for mapper:

% put into a struct to form the default values for the colmap mapper (
Mapper_default_options.min_num_matches = 15;
Mapper_default_options.ignore_watermarks = 0;
Mapper_default_options.multiple_models = 1;
Mapper_default_options.max_num_models = 50;
Mapper_default_options.max_model_overlap = 20;
Mapper_default_options.min_model_size = 10;
Mapper_default_options.init_image_id1 = -1;
Mapper_default_options.init_image_id2 = -1;
Mapper_default_options.init_num_trials = 200;
Mapper_default_options.extract_colors = 1;
Mapper_default_options.num_threads = -1;
Mapper_default_options.min_focal_length_ratio = 0.10000000000000001;
Mapper_default_options.max_focal_length_ratio = 10;
Mapper_default_options.max_extra_param = 1;
Mapper_default_options.ba_refine_focal_length = 1;
Mapper_default_options.ba_refine_principal_point = 0;
Mapper_default_options.ba_refine_extra_params = 1;
Mapper_default_options.ba_min_num_residuals_for_multi_threading = 50000;
Mapper_default_options.ba_local_num_images = 6;
Mapper_default_options.ba_local_max_num_iterations = 25;
Mapper_default_options.ba_global_use_pba = 0;
Mapper_default_options.ba_global_pba_gpu_index = -1;
Mapper_default_options.ba_global_images_ratio = 1.1000000000000001;
Mapper_default_options.ba_global_points_ratio = 1.1000000000000001;
Mapper_default_options.ba_global_images_freq = 500;
Mapper_default_options.ba_global_points_freq = 250000;
Mapper_default_options.ba_global_max_num_iterations = 50;
Mapper_default_options.ba_global_max_refinements = 5;
Mapper_default_options.ba_global_max_refinement_change = 0.00050000000000000001;
Mapper_default_options.ba_local_max_refinements = 2;
Mapper_default_options.ba_local_max_refinement_change = 0.001;
Mapper_default_options.snapshot_images_freq = 0;
Mapper_default_options.fix_existing_images = 0;
Mapper_default_options.init_min_num_inliers = 100;
Mapper_default_options.init_max_error = 4;
Mapper_default_options.init_max_forward_motion = 0.94999999999999996;
Mapper_default_options.init_min_tri_angle = 16;
Mapper_default_options.init_max_reg_trials = 2;
Mapper_default_options.abs_pose_max_error = 12;
Mapper_default_options.abs_pose_min_num_inliers = 30;
Mapper_default_options.abs_pose_min_inlier_ratio = 0.25;
Mapper_default_options.filter_max_reproj_error = 4;
Mapper_default_options.filter_min_tri_angle = 1.5;
Mapper_default_options.max_reg_trials = 3;
Mapper_default_options.tri_max_transitivity = 1;
Mapper_default_options.tri_create_max_angle_error = 2;
Mapper_default_options.tri_continue_max_angle_error = 2;
Mapper_default_options.tri_merge_max_reproj_error = 4;
Mapper_default_options.tri_complete_max_reproj_error = 4;
Mapper_default_options.tri_complete_max_transitivity = 5;
Mapper_default_options.tri_re_max_angle_error = 5;
Mapper_default_options.tri_re_min_ratio = 0.20000000000000001;
Mapper_default_options.tri_re_max_trials = 1;
Mapper_default_options.tri_min_angle = 1.5;
Mapper_default_options.tri_ignore_two_view_tracks = 1;



%% parameters for 2D SIFT Mono:

ftr_sift_mono = 'sift_mono';
run_sift_mono_filename = 'runSiftMono.sh';
run_colmap_sift_mono_filename = 'runColmapCLI_SiftMono.sh';
ftr_matches_sift_mono = 'colmap_image_matches_sift_mono.txt';
% colmap_sift_mono_folder = fullfile(colmap_folder,colmap_ftr_type);

sift_mono_options = Mapper_default_options;
sift_mono_options.min_model_size =  nLF;
sift_mono_options.abs_pose_min_num_inliers = 15;

%% parameters for 2D SIFT stereo:

ftr_sift_stereo = 'sift_stereo';
run_sift_stereo_filename = 'runSiftStereo.sh';
run_colmap_sift_stereo_filename = 'runColmapCLI_SiftStereo.sh';
ftr_matches_sift_stereo = 'colmap_image_matches_sift_stereo.txt';

sift_stereo_options = Mapper_default_options;
sift_stereo_options.min_model_size = 2*nLF;
sift_stereo_options.abs_pose_min_num_inliers = 15;
sift_stereo_options.tri_ignore_two_view_tracks = 0;

%% parameters for RLFF synthetic mono:

ftr_rlff_mono = 'rlff_mono';
run_rlff_mono_filename = 'runRlffMono.sh';
run_colmap_rlff_mono_filename = 'runColmapCLI_RlffMono.sh';
ftr_matches_rlff_mono_filename = 'colmap_image_matches_rlff_mono.txt';

rlff_mono_options = Mapper_default_options;
rlff_mono_options.min_model_size = nLF;
rlff_mono_options.abs_pose_min_num_inliers = 15;


%% parameters for RLFF synthetic stereo:

ftr_rlff_stereo = 'rlff_stereo';
run_rlff_stereo_filename = 'runRlffStereo.sh';
run_colmap_rlff_stereo_filename = 'runColmapCLI_RlffStereo.sh';
% colmap_rlff_stereo_folder = [colmap_folder '/rlff_stereo'];
ftr_matches_rlff_stereo_filename = 'colmap_image_matches_rlff_stereo.txt';

rlff_stereo_options = Mapper_default_options;
rlff_stereo_options.min_model_size = 2*nLF;
rlff_stereo_options.abs_pose_min_num_inliers = 15;
rlff_stereo_options.tri_ignore_two_view_tracks = 0;


%% generate colmap runscripts for each feature method:

% 2D sift mono:
 sfm_generate_colmap_featurefiles(exp_name,case_name, colmap_folder,ftr_sift_mono,...
     ftr_matches_sift_mono, ...
     run_sift_mono_filename,...
     run_colmap_sift_mono_filename,...
     sift_mono_options);
 
 % 2D sift stereo:
  sfm_generate_colmap_featurefiles(exp_name,case_name, colmap_folder,ftr_sift_stereo,...
     ftr_matches_sift_stereo, ...
     run_sift_stereo_filename,...
     run_colmap_sift_stereo_filename,...
     sift_stereo_options);

 % RLFF mono:
  sfm_generate_colmap_featurefiles(exp_name,case_name,colmap_folder,ftr_rlff_mono,...
     ftr_matches_rlff_mono_filename,...
     run_rlff_mono_filename,...
     run_colmap_rlff_mono_filename,...
     rlff_mono_options);

 
% RLFF stereo .sh
 sfm_generate_colmap_featurefiles(exp_name,case_name,colmap_folder,ftr_rlff_stereo,...
     ftr_matches_rlff_stereo_filename,...
     run_rlff_stereo_filename,...
     run_colmap_rlff_stereo_filename,...
     rlff_stereo_options);


%% 
% to use the system shell environment and not the Matlab shell environment,
% use env:
% now run the runX.sh file from matlab:
% cmd_run = ['env  LD_LIBRARY_PATH='''' ' colmap_mono_folder '/runMono.sh'];
% system(cmd_run);

% now we just wait for Colmap to run/converge
