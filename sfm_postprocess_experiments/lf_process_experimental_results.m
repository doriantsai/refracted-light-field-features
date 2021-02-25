% script to combine sfm and groundtruth data
% sfm - results come from colmap (see lf_process_sfm_from_colmap.m)
% groundtruth - data comes from panda/rosbag files (see
% x_rosbag_get_poses/x_rosbag_get_poses_manual.m)

% need to scale the sfm data to the groundtruth data
% need to put the sfm data into the same frame (baselink frame)
% plot all poses/methods together
% show histories of error
clearvars

% get exp_name
% thus have colmap folder
% thus have .bag file
% run functions to get these data

% make sure to add path to the custom ros messages, so that we can read
% them in
addpath('/home/dt-venus/Dropbox/PhD/2020-LFRefractiveFeatures/lfrefractivefeatures/Code/rlffExtractIllum/matlab_ros_custom_messages/matlab_gen/msggen')
addpath('Support_Functions/');
addpath('colmap_scripts/');

PLOT = false;

% suppress plot warning too large:
warning_identifier =  'MATLAB:print:FigureTooLargeForPage';
warning('off',warning_identifier);

%% list of experiments

% make sure that rlff extraction and colmap have all run on these sequences
% before running this code

% need to run this over several experiments!
data_folder = '~/Data';
test_colmap_folder = '~/Data/colmap_data';

SearchOptions.IncludeRecursion = false;
SearchOptions.Verbose = false;
SearchOptions.ReportFolders = true;
exp_folders = LFFindFilesRecursive(test_colmap_folder,[],[], SearchOptions);

exp_list_all = exp_folders(3:end-1);

disp('Experiment folder list');
exp_list_all
n_exp_all = length(exp_list_all);
% for now, we will process experiments, based on their alphabetical/numerical order
% in the colmap_data folder
% select_exp = [2,4:6,8,11:13];
% select_exp = [4:6,12:13];
select_exp = [2:n_exp_all];
% select_exp = 12;
exp_list = exp_list_all(select_exp);

exp_list
% exp_name = '20200619-1432_rlff_lambertian_cyl'; % works!
% exp_name = '20200619-1440_rlff_cyl_diag'; %  could not get this case to converge on either stereo or mono
% exp_name = '20200619-1448_rlff_bottle_diag'; % stereo crap
% exp_name = '20200619-1454_rlff_bottle_vert'; % stereo is crap - currently running
% exp_name = '20200619-1506_rlff_big_cup';  % stereo crap
% exp_name = '20200619-1524_rlff_many_glasses'; % stereo not converging
% exp_name = '20200624-1914_rlff_cup_diag_motion'; % stereo does not
% converge!
% exp_name = '20200624-1922_rlff_cup_fwd_motion';
% exp_name = '20200624-1926_rlff_cup_manual1'; % can't converge either
% exp_name = '20200624-1932_rlff_cup_manual_arc'; % stereo not converging
% exp_name = '20200624-1941_rlff_snowrobot';
% exp_name = '20200624-1945_rlff_snowrobot';
% exp_name = '20200624-1948_rlff_snowrobot'; % stereo crap
% exp_name = '20200624-1956_rlff_cube'; % runs, but stereo is crap

% case_name = '200926_default_sparse';
% case_name = '200926_permissive_sparse';

% case_name = '201004_permissive_sparse'; % do this one - should be with proper sift features
% case_name = '201004_default_sparse';

% fixed bugs!
% case_name = '201006_default_sparse';
% case_name = '201006_permissive_sparse';

% case_name = '201006_default_sparse';
% case_name = '201007_permissive_sparse';
% case_name = '201007_default_sparse';
% case_name = '201201_default_sparse';
% case_name = '201201b_default_sparse';
% case_name = '201201c_default_sparse';
case_name = '201201d_default_sparse';
% case_name = '201201b_permissive_sparse';

RLFF_MONO = true;
RLFF_STEREO = true;
SIFT_MONO = true;
SIFT_STEREO = true;


%% TODO: now iterate through loop of exp_list in big for loop

n_exp = length(exp_list);
% groundtruth =
% sift_mono
% rlff_stereo
for ii_exp = 1:n_exp
    
    % just to prevent writing over variables in the loop:
    sfm.n = [];
    sfm.scale = [];
    sfm.t = [];
    sfm.xyz = [];
    sfm.T = [];
    sfm.T_togt = [];
    
    sift_mono = sfm;
    sift_stereo = sfm;
    rlff_mono = sfm;
    rlff_stereo = sfm;
    
    % old variable names:
    %     T_sfm_scaled_mono = [];
    %     scale_mono = [];
    %     t_mono = [];
    %     xyz_mono_sc = [];
    %     T_mono_to_gt = [];
    
    exp_name = exp_list{ii_exp};
    %% get groundtruth/arm data
    
    % note: must be able to handle manual/auto cases, and be able to remove
    % certain poses on a case-by-case basis
    % do pose removal here on a switch-case statement
    save_poses_filename = [];
    
    if contains(exp_name, 'manual') || contains(exp_name, 'MANUAL')
        MANUAL_MODE = true;
    else
        MANUAL_MODE = false;
    end
    [T_ee,T_goal,T_base] = lf_extract_arm_data(data_folder, exp_name, save_poses_filename,MANUAL_MODE);
    
    T_gt = T_ee; % we ignore the transform between the camera and the
    [~,~,nGt] = size(T_gt);
    
    T_gt1 = T_gt(:,:,1);
    t_gt = zeros(nGt,3);
    o_gt = zeros(nGt,3);
    for ii = 1:nGt
        t_gt(ii,:) = tform2trvec(T_gt(:,:,ii));
        o_gt(ii,:) = tform2eul(T_gt(:,:,ii),'XYZ');
    end
    
    %% get sfm data
    
    
    % colmap_folder = ['~/Data/colmap_data/' exp_name];
    
    [sfm_sift_mono,sfm_sift_stereo,sfm_rlff_mono,sfm_rlff_stereo] = lf_process_sfm_from_colmap(exp_name, case_name, SIFT_MONO, SIFT_STEREO,RLFF_MONO,RLFF_STEREO);
    
    % in lf_process_sfm_from_colmap
    % run the "get extra stats" to grab info on outliers, inliers, etc from the
    % process - is Colmap getting screwed up by the shit outliers that we feed
    % it in stereo? Seems to be doing fine with everything in the monocular
    % case
    % is it a matter of tuning a few parameters, eg stereo triangulation, etc?
    
    % see compareSfMPoseEstimates.m from lffeatures
    
    
    
    %% scale mono:
    %% TODO: refactor this as a method-agnostic section, with maybe an if-statement for the stereo cases
    %% much more compact!
    
    % scale sfm reconstructions
    if SIFT_MONO
        if sfm_sift_mono.did_converge == false
            sift_mono.T = [];
            sift_mono.scale = [];
            sift_mono.t = [];
            sift_mono.o = [];
            sift_mono.xyz = [];
            sift_mono.n = [];
            sift_mono.T_togt = [];
        else
            [sift_mono.T, regParams_mono] = lf_sfm_to_groundtruth_pose_alignment(T_gt,sfm_sift_mono.T);
            sift_mono.scale = regParams_mono.s;
            [~,~,sift_mono.n] = size(sift_mono.T);
            
            % shift pose sfm trajectory to match 1st groundtruth pose
            T_siftmono1_gt1 = T_gt1 * invTrans(sift_mono.T(:,:,1));
            sift_mono.T_togt = zeros(4,4,sift_mono.n);
            for ii = 1:sift_mono.n
                sift_mono.T_togt(:,:,ii) = T_siftmono1_gt1 * sift_mono.T(:,:,ii);
            end
            
            sift_mono.t = zeros(sift_mono.n,3);
            sift_mono.o = zeros(sift_mono.n,3);
            for ii = 1:sift_mono.n
                sift_mono.t(ii,:) = tform2trvec(sift_mono.T_togt(:,:,ii));
                sift_mono.o(ii,:) = tform2eul(sift_mono.T_togt(:,:,ii),'XYZ');
            end
            
            %   apply same scale changes and transformations to all the 3D points/the sparse 3D reconstruction from SfM
            % convert to base frame of reference
            [sift_mono.xyz] = sfm_scale_xyz_to_gt(sfm_sift_mono.xyz,sift_mono.scale,sift_mono.T_togt,T_siftmono1_gt1);
        end
    end
    
    %%
    % scale sfm reconstructions
    if RLFF_MONO
        if sfm_rlff_mono.did_converge == false
            rlff_mono.T = [];
            rlff_mono.scale = [];
            rlff_mono.t = [];
            rlff_mono.xyz = [];
            rlff_mono.n = [];
            rlff_mono.o = [];
            rlff_mono.T_togt = [];
        else
            [rlff_mono.T, regParams_mono] = lf_sfm_to_groundtruth_pose_alignment(T_gt,sfm_rlff_mono.T);
            rlff_mono.scale = regParams_mono.s;
            [~,~,rlff_mono.n] = size(rlff_mono.T);
            
            % shift pose sfm trajectory to match 1st groundtruth pose
            T_rlffmono1_gt1 = T_gt1 * invTrans(rlff_mono.T(:,:,1));
            rlff_mono.T_togt = zeros(4,4,rlff_mono.n);
            for ii = 1:rlff_mono.n
                rlff_mono.T_togt(:,:,ii) = T_rlffmono1_gt1 * rlff_mono.T(:,:,ii);
            end
            
            rlff_mono.t = zeros(rlff_mono.n,3);
            rlff_mono.o = zeros(rlff_mono.n,3);
            for ii = 1:rlff_mono.n
                rlff_mono.t(ii,:) = tform2trvec(rlff_mono.T_togt(:,:,ii));
                rlff_mono.o(ii,:) = tform2eul(rlff_mono.T_togt(:,:,ii),'XYZ');
            end
            
            %   apply same scale changes and transformations to all the 3D points/the sparse 3D reconstruction from SfM
            % convert to base frame of reference
            [rlff_mono.xyz] = sfm_scale_xyz_to_gt(sfm_rlff_mono.xyz,rlff_mono.scale,rlff_mono.T_togt,T_rlffmono1_gt1);
        end
    end
    
    %% try stereo
    % scale stereo: (which technically shouldn't need scaling, but colmap
    % doesn't do stereo, so it's kinda bust
    
    if SIFT_STEREO
        if sfm_sift_stereo.did_converge == false
            sift_stereo.scale = [];
            sift_stereo.T = [];
            T_centre_stereo = [];
            sift_stereo.t = [];
            sift_stereo.o = [];
            sift_stereo.xyz = [];
            sift_stereo.n = [];
            sift_stereo.T_togt = [];
        else
            % note that stereo has two poses, not one per LF frame, so we take the
            % middle of the two stereo poses:
            sift_stereo.n = round(size(sfm_sift_stereo.t,1)/2); % an assumption that all stereo images were used in the reconstruction
            % here, we also assume sequential ordering of the stereo images/poses
            T_centre_stereo = zeros(4,4,sift_stereo.n);
            for ii = 1:sift_stereo.n
                
                iStereo1 = 2*(ii-1)+1;
                iStereo2 = 2*(ii-1)+2;
                
                % get translation
                % interpolate/take average between two translations
                t_left = sfm_sift_stereo.t(iStereo1,:);
                t_right = sfm_sift_stereo.t(iStereo2,:);
                t_centre = mean([t_left; t_right]);
                T_trans = trvec2tform(t_centre);
                
                % get orientation
                % slerp/interpolate between two orientations
                q_left = quaternion(quatnormalize(tform2quat(sfm_sift_stereo.T(:,:,iStereo1))));
                q_right = quaternion(quatnormalize(tform2quat(sfm_sift_stereo.T(:,:,iStereo2))));
                q_centre = slerp(q_left,q_right,0.5); % 0.5 is the interpolation coeff from 0,1, where 0 = all q_left, 1 = all q_right, thus 0.5 is middle
                T_rot = quat2tform(q_centre);
                
                % reform into single homogeneous transformation matrix
                T_centre_stereo(:,:,ii) = T_trans * T_rot;
            end
            
            [sift_stereo.T, regParams_stereo] = lf_sfm_to_groundtruth_pose_alignment(T_gt,T_centre_stereo);
            sift_stereo.scale = regParams_stereo.s;
            
            % shift pose sfm trajectory to match 1st groundtruth pose
            T_centre_stereo1_gt1 = T_gt1 * invTrans(sift_stereo.T(:,:,1));
            sift_stereo.T_togt = zeros(4,4,sift_stereo.n);
            for ii = 1:sift_stereo.n
                sift_stereo.T_togt(:,:,ii) = T_centre_stereo1_gt1 * sift_stereo.T(:,:,ii);
            end
            
            sift_stereo.t = zeros(sift_stereo.n,3);
            sift_stereo.o = zeros(sift_stereo.n,3);
            for ii = 1:sift_stereo.n
                sift_stereo.t(ii,:) = tform2trvec(sift_stereo.T_togt(:,:,ii));
                sift_stereo.o(ii,:) = tform2eul(sift_stereo.T_togt(:,:,ii),'XYZ');
            end
            
            % apply same scale changes and transformations to all the 3D points/the sparse 3D reconstruction from SfM
            
            % convert to base frame of reference
            [sift_stereo.xyz] = sfm_scale_xyz_to_gt(sfm_sift_stereo.xyz,sift_stereo.scale,sift_stereo.T_togt,T_centre_stereo1_gt1);
            
            
        end
    end
    
    %% try stereo
    % scale stereo: (which technically shouldn't need scaling, but colmap
    % doesn't do stereo, so it's kinda bust
    if RLFF_STEREO
        if sfm_rlff_stereo.did_converge == false
            rlff_stereo.scale = [];
            rlff_stereo.T = [];
            T_centre_stereo = [];
            rlff_stereo.t = [];
            rlff_stereo.o = [];
            rlff_stereo.xyz = [];
            rlff_stereo.n = [];
            rlff_stereo.T_togt = [];
        else
            % note that stereo has two poses, not one per LF frame, so we take the
            % middle of the two stereo poses:
            rlff_stereo.n = round(size(sfm_rlff_stereo.t,1)/2); % an assumption that all stereo images were used in the reconstruction
            % here, we also assume sequential ordering of the stereo images/poses
            T_centre_stereo = zeros(4,4,rlff_stereo.n);
            for ii = 1:rlff_stereo.n % 1:10
                
                iStereo1 = 2*(ii-1)+1;
                iStereo2 = 2*(ii-1)+2;
                % get translation
                % interpolate/take average between two translations
                t_left = sfm_rlff_stereo.t(iStereo1,:);
                t_right = sfm_rlff_stereo.t(iStereo2,:);
                t_centre = mean([t_left; t_right]);
                T_trans = trvec2tform(t_centre);
                
                % get orientation
                % slerp/interpolate between two orientations
                q_left = quaternion(quatnormalize(tform2quat(sfm_rlff_stereo.T(:,:,iStereo1))));
                q_right = quaternion(quatnormalize(tform2quat(sfm_rlff_stereo.T(:,:,iStereo2))));
                q_centre = slerp(q_left,q_right,0.5); % 0.5 is the interpolation coeff from 0,1, where 0 = all q_left, 1 = all q_right, thus 0.5 is middle
                T_rot = quat2tform(q_centre);
                
                % reform into single homogeneous transformation matrix
                T_centre_stereo(:,:,ii) = T_trans * T_rot;
            end
            
            [rlff_stereo.T, regParams_stereo] = lf_sfm_to_groundtruth_pose_alignment(T_gt,T_centre_stereo);
            rlff_stereo.scale = regParams_stereo.s;
            
            % shift pose sfm trajectory to match 1st groundtruth pose
            T_centre_stereo1_gt1 = T_gt1 * invTrans(rlff_stereo.T(:,:,1));
            rlff_stereo.T_togt = zeros(4,4,rlff_stereo.n);
            for ii = 1:rlff_stereo.n
                rlff_stereo.T_togt(:,:,ii) = T_centre_stereo1_gt1 * rlff_stereo.T(:,:,ii);
            end
            
            rlff_stereo.t = zeros(rlff_stereo.n,3);
            rlff_stereo.o = zeros(rlff_stereo.n,3);
            for ii = 1:rlff_stereo.n
                rlff_stereo.t(ii,:) = tform2trvec(rlff_stereo.T_togt(:,:,ii));
                rlff_stereo.o(ii,:) = tform2eul(rlff_stereo.T_togt(:,:,ii),'XYZ');
            end
            
            % apply same scale changes and transformations to all the 3D points/the sparse 3D reconstruction from SfM
            
            % convert to base frame of reference
            [rlff_stereo.xyz] = sfm_scale_xyz_to_gt(sfm_rlff_stereo.xyz,rlff_stereo.scale,rlff_stereo.T_togt,T_centre_stereo1_gt1);
            
            
        end
    end
    
    %% incremental pose errors:
    
    % ideally, these should all be the same!
    if RLFF_STEREO && sfm_rlff_stereo.did_converge
        nImg = rlff_stereo.n;
    elseif RLFF_MONO && sfm_rlff_mono.did_converge
        nImg = rlff_mono.n;
    elseif SIFT_STEREO && sfm_sift_stereo.did_converge
        nImg = sift_stereo.n;
    else
        nImg = sift_mono.n;
    end
    x_img = 1:nImg-1;
    
    
    sift_mono.rel_t = zeros(nImg-1,3);
    sift_mono.err_t_inst = zeros(nImg-1,3);
    sift_mono.err_t_inst_total = zeros(nImg-1,1);
    sift_mono.rel_o = zeros(nImg-1,3);
    sift_mono.err_o_inst = zeros(nImg-1,3);
    sift_mono.err_o_inst_total = zeros(nImg-1,1);
    
    rlff_mono.rel_t = zeros(nImg-1,3);
    rlff_mono.err_t_inst = zeros(nImg-1,3);
    rlff_mono.err_t_inst_total = zeros(nImg-1,1);
    rlff_mono.rel_o = zeros(nImg-1,3);
    rlff_mono.err_o_inst = zeros(nImg-1,3);
    rlff_mono.err_o_inst_total = zeros(nImg-1,1);
    
    sift_stereo.rel_t = zeros(nImg-1,3);
    sift_stereo.err_t_inst = zeros(nImg-1,3);
    sift_stereo.err_t_inst_total = zeros(nImg-1,1);
    sift_stereo.rel_o = zeros(nImg-1,3);
    sift_stereo.err_o_inst = zeros(nImg-1,3);
    sift_stereo.err_o_inst_total = zeros(nImg-1,1);
    
    rlff_stereo.rel_t = zeros(nImg-1,3);
    rlff_stereo.err_t_inst = zeros(nImg-1,3);
    rlff_stereo.err_t_inst_total = zeros(nImg-1,1);
    rlff_stereo.rel_o = zeros(nImg-1,3);
    rlff_stereo.err_o_inst = zeros(nImg-1,3);
    rlff_stereo.err_o_inst_total = zeros(nImg-1,1);
    
    rel_t_gt = zeros(nImg-1,3);
    rel_o_gt = zeros(nImg-1,3);
    for ii = 2:nImg
        rel_t_gt(ii-1,:) = t_gt(ii,:) - t_gt(ii-1,:);
        rel_o_gt(ii-1,:) = o_gt(ii,:) - o_gt(ii-1,:);
        
        if SIFT_MONO
            if sfm_sift_mono.did_converge == false
                sift_mono.rel_t = [];
                sift_mono.rel_o = [];
                sift_mono.err_t_inst = [];
                sift_mono.err_t_inst_total = [];
                sift_mono.err_o_inst = [];
                sift_mono.err_o_inst_total = [];
            else
                sift_mono.rel_t(ii-1,:) = sift_mono.t(ii,:) - sift_mono.t(ii-1,:);
                sift_mono.rel_o(ii-1,:) = sift_mono.o(ii,:) - sift_mono.o(ii-1,:);
                sift_mono.err_t_inst(ii-1,:) = sift_mono.rel_t(ii-1,:) - rel_t_gt(ii-1,:);
                sift_mono.err_t_inst_total(ii-1) = norm(sift_mono.err_t_inst(ii-1,:));
                sift_mono.err_o_inst(ii-1,:) = sift_mono.rel_o(ii-1,:) - rel_o_gt(ii-1,:);
                sift_mono.err_o_inst_total(ii-1) = norm(sift_mono.err_o_inst(ii-1,:));
            end
        end
        if RLFF_MONO
            if sfm_rlff_mono.did_converge == false
                rlff_mono.rel_t = [];
                rlff_mono.rel_o = [];
                rlff_mono.err_t_inst = [];
                rlff_mono.err_t_inst_total = [];
                rlff_mono.err_o_inst = [];
                rlff_mono.err_o_inst_total = [];
            else
                rlff_mono.rel_t(ii-1,:) = rlff_mono.t(ii,:) - rlff_mono.t(ii-1,:);
                rlff_mono.err_t_inst(ii-1,:) = rlff_mono.rel_t(ii-1,:) - rel_t_gt(ii-1,:);
                rlff_mono.err_t_inst_total(ii-1) = norm(rlff_mono.err_t_inst(ii-1,:));
                
                rlff_mono.rel_o(ii-1,:) = rlff_mono.o(ii,:) - rlff_mono.o(ii-1,:);
                rlff_mono.err_o_inst(ii-1,:) = rlff_mono.rel_o(ii-1,:) - rel_o_gt(ii-1,:);
                rlff_mono.err_o_inst_total(ii-1) = norm(rlff_mono.err_o_inst(ii-1,:));
            end
        end
        
        
        if SIFT_STEREO
            if sfm_sift_stereo.did_converge == false
                sift_stereo.rel_t = [];
                sift_stereo.err_t_inst = [];
                sift_stereo.err_t_inst_total = [];
                sift_stereo.rel_o = [];
                sift_stereo.err_o_inst = [];
                sift_stereo.err_o_inst_total = [];
            else
                sift_stereo.rel_t(ii-1,:) = sift_stereo.t(ii,:) - sift_stereo.t(ii-1,:);
                sift_stereo.err_t_inst(ii-1,:) = sift_stereo.rel_t(ii-1,:) - rel_t_gt(ii-1,:);
                sift_stereo.err_t_inst_total(ii-1) = norm(sift_stereo.err_t_inst(ii-1,:));
                sift_stereo.rel_o(ii-1,:) = sift_stereo.o(ii,:) - sift_stereo.o(ii-1,:);
                sift_stereo.err_o_inst(ii-1,:) = sift_stereo.rel_o(ii-1,:) - rel_o_gt(ii-1,:);
                sift_stereo.err_o_inst_total(ii-1) = norm(sift_stereo.err_o_inst(ii-1,:));
            end
        end
        
        if RLFF_STEREO
            if sfm_rlff_stereo.did_converge == false
                rlff_stereo.rel_t = [];
                rlff_stereo.err_t_inst = [];
                rlff_stereo.err_t_inst_total = [];
                rlff_stereo.rel_o = [];
                rlff_stereo.err_o_inst = [];
                rlff_stereo.err_o_inst_total = [];
            else
                rlff_stereo.rel_t(ii-1,:) = rlff_stereo.t(ii,:) - rlff_stereo.t(ii-1,:);
                rlff_stereo.err_t_inst(ii-1,:) = rlff_stereo.rel_t(ii-1,:) - rel_t_gt(ii-1,:);
                rlff_stereo.err_t_inst_total(ii-1) = norm(rlff_stereo.err_t_inst(ii-1,:));
                rlff_stereo.rel_o(ii-1,:) = rlff_stereo.o(ii,:) - rlff_stereo.o(ii-1,:);
                rlff_stereo.err_o_inst(ii-1,:) = rlff_stereo.rel_o(ii-1,:) - rel_o_gt(ii-1,:);
                rlff_stereo.err_o_inst_total(ii-1) = norm(rlff_stereo.err_o_inst(ii-1,:));
            end
        end
        
        % TODO: orientation error later
    end
    
    
    
    
    
    %% package into structs for each experiment:
    groundtruth(ii_exp).n = nGt;
    groundtruth(ii_exp).T = T_gt;
    groundtruth(ii_exp).T_goal = T_goal;
    groundtruth(ii_exp).T_base = T_base;
    groundtruth(ii_exp).rel_t = rel_t_gt;
    groundtruth(ii_exp).t = t_gt;
    groundtruth(ii_exp).o = o_gt;
    groundtruth(ii_exp).exp_name = exp_name;
    
    
    % 2D monocular SIFT:
    sift_mono_all(ii_exp).sfm = sfm_sift_mono;
    sift_mono_all(ii_exp).gt_aligned = sift_mono;
    sift_mono_all(ii_exp).exp_name = exp_name;
    sift_mono_all(ii_exp).method_name = 'sift_mono';
    sift_mono_all(ii_exp).str_name = 'SIFT MONO';
    
    %         sift_mono_all(ii_exp).scale = sift_mono.scale;
    %         sift_mono_all(ii_exp).nImg = nMono;
    %         sift_mono_all(ii_exp).T_scaled = T_sfm_scaled_mono;
    %         sift_mono_all(ii_exp).T_gt_ref = T_mono_to_gt;
    %         sift_mono_all(ii_exp).t_gt_ref = t_mono;
    %         sift_mono_all(ii_exp).xyz_sc = xyz_mono_sc;
    %         sift_mono_all(ii_exp).err_t_inst = err_t_mono_inst;
    %         sift_mono_all(ii_exp).err_t_inst_total = err_t_mono_inst_total;
    % end
    
    %     if RLFF_STEREO
    % 4D RLFF synthetic stereo:
    rlff_stereo_all(ii_exp).sfm = sfm_rlff_stereo;
    rlff_stereo_all(ii_exp).gt_aligned = rlff_stereo;
    rlff_stereo_all(ii_exp).exp_name = exp_name;
    rlff_stereo_all(ii_exp).method_name = 'rlff_stereo';
    rlff_stereo_all(ii_exp).str_name = 'RLFF STEREO';
    
    %         rlff_stereo_all(ii_exp).scale = scale_stereo;
    %         rlff_stereo_all(ii_exp).nImg = nStereo;
    %         rlff_stereo_all(ii_exp).T_centre = T_centre_stereo;
    %         rlff_stereo_all(ii_exp).T_scaled = T_sfm_scaled_centre_stereo;
    %         rlff_stereo_all(ii_exp).T_gt_ref = T_centre_stereo_to_gt;
    %         rlff_stereo_all(ii_exp).t_gt_ref = t_stereo_centre;
    %         rlff_stereo_all(ii_exp).xyz_sc = xyz_stereo_sc;
    %         rlff_stereo_all(ii_exp).err_t_inst = err_t_sc_inst;
    %         rlff_stereo_all(ii_exp).err_t_inst_total = err_t_sc_inst_total;
    %     end
    
    %     if RLFF_MONO
    rlff_mono_all(ii_exp).sfm = sfm_rlff_mono;
    rlff_mono_all(ii_exp).gt_aligned = rlff_mono;
    rlff_mono_all(ii_exp).exp_name = exp_name;
    rlff_mono_all(ii_exp).method_name = 'rlff_mono';
    rlff_mono_all(ii_exp).str_name = 'RLFF MONO';
    %     end
    
    %     if SIFT_STEREO
    sift_stereo_all(ii_exp).sfm = sfm_sift_stereo;
    sift_stereo_all(ii_exp).gt_aligned = sift_stereo;
    sift_stereo_all(ii_exp).exp_name = exp_name;
    sift_stereo_all(ii_exp).method_name = 'sift_stereo';
    sift_stereo_all(ii_exp).str_name = 'SIFT STEREO';
    %     end
    
    clear sfm_sift_mono sfm_sift_stereo sfm_rlff_mono sfm_rlff_stereo
end


%% print table of stats for Table 1: feature stats

% percent pass
% img features/image
% putative matches/image
% inliner matches/image
% match ratio
% 3D points
% track length
isrlff = false;
stats_sift_mono = lf_compute_exp_stats(sift_mono_all,n_exp,false,isrlff);
stats_sift_stereo = lf_compute_exp_stats(sift_stereo_all,n_exp,true,isrlff);
isrlff = true;
stats_rlff_mono = lf_compute_exp_stats(rlff_mono_all,n_exp,false,isrlff);
stats_rlff_stereo = lf_compute_exp_stats(rlff_stereo_all,n_exp,true,isrlff);

% compute stats for all:
% ftr_stats = lf_compute_exp_stats_all(sift_mono_all, sift_stereo_all, rlff_mono_all, rlff_stereo_all, n_exp);

stats_sift_mono
stats_sift_stereo
stats_rlff_mono
stats_rlff_stereo

ism = stats_sift_mono.did_converge_seq;
iss = stats_sift_stereo.did_converge_seq;
irm = stats_rlff_mono.did_converge_seq;
irs = stats_rlff_stereo.did_converge_seq;
iconv = ism .* iss .* irm .* irs;


% apples to apples:
nftr = 4;
ftr = cell(nftr,1);
ftr{1} = stats_sift_mono;
ftr{2} = stats_sift_stereo;
ftr{3} = stats_rlff_mono;
ftr{4} = stats_rlff_stereo;

ftr{1}.type = 'sift_mono';
ftr{2}.type = 'sift_stereo';
ftr{3}.type = 'rlff_mono';
ftr{4}.type = 'rlff_stereo';

% recalculate stats for iconv (all cases where all 4 converged)
for ii = 1:nftr
    notnan = ~isnan(ftr{ii}.img_ftr_seq);
    sel = logical(iconv .* notnan); 
    
    ftr{ii}.nLFs_conv = sum(ftr{ii}.nLFs(sel));
    ftr{ii}.img_ftr_conv = mean(ftr{ii}.img_ftr_seq(sel));
    ftr{ii}.put_matches_conv = mean(ftr{ii}.put_matches_seq(sel));
    ftr{ii}.in_matches_conv = mean(ftr{ii}.in_matches_seq(sel));
    ftr{ii}.match_ratio_conv = mean(ftr{ii}.match_ratio_seq(sel));
    ftr{ii}.num3D_conv = mean(ftr{ii}.num3D_seq(sel));
    ftr{ii}.track_len_conv = mean(ftr{ii}.track_len_seq(sel));
    ftr{ii}.precision_conv = mean(ftr{ii}.precision_seq(sel));
    ftr{ii}.matching_score_conv = mean(ftr{ii}.matching_score_seq(sel));
end

% put into Table 1:

for ii = 1:4
    tbl_type{ii} = ftr{ii}.type;
    tbl_nlf(ii) = ftr{ii}.nLFs_conv;
    tbl_nlfall(ii) = ftr{ii}.nLFs_all;
    tbl_percentpass(ii) = ftr{ii}.percent_pass;
    tbl_imgftr(ii) = ftr{ii}.img_ftr_conv;
    tbl_putative(ii) = ftr{ii}.put_matches;
    tbl_inlier(ii) = ftr{ii}.in_matches;
    tbl_matchratio(ii) = ftr{ii}.match_ratio;
    tbl_num3D(ii) = ftr{ii}.num3D;
    tbl_track_len(ii) = ftr{ii}.track_len;
    tbl_precision(ii) = ftr{ii}.precision;
    tbl_matchingscore(ii) = ftr{ii}.matching_score;
end

Table0 = table(tbl_type', tbl_nlfall', tbl_percentpass');
Table0.Properties.VariableNames = {'Method', '#LF', '%Pass'};

Table1 = table(tbl_type',tbl_nlf', tbl_imgftr', tbl_putative',...
    tbl_inlier', tbl_matchratio', tbl_num3D', tbl_track_len', tbl_precision', tbl_matchingscore');

Table1.Properties.VariableNames = {'Method', '#LF','ImgFtr','PutMatches','InMatches',...
    'MatchRatio','Num3D','TrackLen','Precision','MatchScore'};

case_name
Table0
Table1


%% Table 2  stats:
err_t_rlff_stereo = zeros(n_exp,1);
err_t_sift_mono = zeros(n_exp,1);
err_t_rlff_mono = zeros(n_exp,1);
err_t_sift_stereo = zeros(n_exp,1);
err_o_sift_mono = zeros(n_exp,1);
err_o_sift_stereo = zeros(n_exp,1);
err_o_rlff_mono = zeros(n_exp,1);
err_o_rlff_stereo = zeros(n_exp,1);

% notnan = ~isnan(ftr{ii}.img_ftr_seq);
% sel = logical(iconv .* notnan); 
    
for ii = 1:n_exp
    err_t_rlff_stereo(ii) = mean(rlff_stereo_all(ii).gt_aligned.err_t_inst_total);
    err_t_sift_mono(ii) = mean(sift_mono_all(ii).gt_aligned.err_t_inst_total);
    err_t_rlff_mono(ii) = mean(rlff_mono_all(ii).gt_aligned.err_t_inst_total);
    err_t_sift_stereo(ii) = mean(sift_stereo_all(ii).gt_aligned.err_t_inst_total);
    
    err_o_rlff_stereo(ii) = mean(rlff_stereo_all(ii).gt_aligned.err_o_inst_total);
    err_o_sift_mono(ii) = mean(sift_mono_all(ii).gt_aligned.err_o_inst_total);
    err_o_rlff_mono(ii) = mean(rlff_mono_all(ii).gt_aligned.err_o_inst_total);
    err_o_sift_stereo(ii) = mean(sift_stereo_all(ii).gt_aligned.err_o_inst_total);
    
    nLF(ii) = groundtruth(ii).n;
end
num = (1:n_exp)';



Table2_Sfm_T = table(num,exp_list,nLF',err_t_sift_mono,err_t_sift_stereo,err_t_rlff_mono,err_t_rlff_stereo)

Table2_Sfm_O = table(num,exp_list,nLF',err_o_sift_mono,err_o_sift_stereo,err_o_rlff_mono,err_o_rlff_stereo)

% try removing exp 3 - 5, 8, 10
% sel = [1, 6,7,9, 11:20] 
sel = [1:20];
err_t_sift_mono = err_t_sift_mono(sel);
err_t_sift_stereo = err_t_sift_stereo(sel);
err_t_rlff_mono = err_t_rlff_mono(sel);
err_t_rlff_stereo = err_t_rlff_stereo(sel);

err_o_sift_mono = err_o_sift_mono(sel);
err_o_sift_stereo = err_o_sift_stereo(sel);
err_o_rlff_mono = err_o_rlff_mono(sel);
err_o_rlff_stereo = err_o_rlff_stereo(sel);



% sort wrt ic:
% sort into ascending order with nans at end
% ideally, choose method with most NaNs
[et_ss, ic] = sort(err_t_sift_stereo);
et_sm = err_t_sift_mono(ic);
et_rm = err_t_rlff_mono(ic);
et_rs = err_t_rlff_stereo(ic);

eo_sm = err_o_sift_mono(ic);
eo_ss = err_o_sift_stereo(ic);
eo_rm = err_o_rlff_mono(ic);
eo_rs = err_o_rlff_stereo(ic);

numic = num(ic);



% summary table:
% apples to apples:

% selection for those sequences that converged
% note that iconv is wrt original ordering
isel = iconv(sel);
sm_sel = logical(isel(ic) .* ~isnan(et_sm));
ss_sel = logical(isel(ic) .* ~isnan(et_ss));
rm_sel = logical(isel(ic) .* ~isnan(et_rm));
rs_sel = logical(isel(ic) .* ~isnan(et_rs));

errt_sm = mean(et_sm(sm_sel));
errt_ss = mean(et_ss(ss_sel));
errt_rm = mean(et_rm(rm_sel));
errt_rs = mean(et_rs(rs_sel));

erro_sm = mean(eo_sm(sm_sel));
erro_ss = mean(eo_ss(ss_sel));
erro_rm = mean(eo_rm(rm_sel));
erro_rs = mean(eo_rs(rs_sel));

errt = [errt_sm, errt_ss, errt_rm, errt_rs];
erro = [erro_sm, erro_ss, erro_rm, erro_rs];

Table2_sum = table(tbl_type', tbl_nlfall', tbl_percentpass',errt', erro');
Table2_sum.Properties.VariableNames = {'Method', '#LF', '%Pass','Translational Error','Rotational Error'};

rad2pi = 180/pi;

case_name
Table2_sum

Table2_top = table(numic, nLF(ic)', et_sm*10^3, eo_sm*rad2pi, ...
    et_ss*10^3, eo_ss*rad2pi, ...
    et_rm*10^3, eo_rm*rad2pi,...
    et_rs*10^3, eo_rs*rad2pi);

Table2_top.Properties.VariableNames = {'Trial','#LF','et_sm','eo_sm',...
    'et_ss','eo_ss',...
    'et_rm','eo_rm',...
    'et_rs','et_ro'};

case_name
Table2_top

selnlf = sum(nLF(logical(iconv(sel))))
% nLF_allconv = sum(nLF(isel(ic)));
allconvstr = {'allconv'};

Table2_bot = table(allconvstr, selnlf, errt(1)*10^3, erro(1)*rad2pi, ...
    errt(2)*10^3, erro(2)*rad2pi, ...
    errt(3)*10^3, erro(3)*rad2pi, ...
    errt(4)*10^3, erro(4)*rad2pi);
Table2_bot.Properties.VariableNames = {'Trial','#LF','et_sm','eo_sm',...
    'et_ss','eo_ss',...
    'et_rm','eo_rm',...
    'et_rs','eo_rs'};

Table2_bot
%%
% print out names of runs and whether or not they passed:

% max name length:
% max_char_len = 0;
% for ii = 1:n_exp
%     char_len = length(exp_list{ii});
%     if char_len > max_char_len
%         max_char_len = char_len;
%     end
% end
%
% fprintf('\nExperiment name\t\t\t\t\tConverged\n');
% for ii = 1:n_exp
%     fprintf('%'s\t%g\n',exp_list{ii},1);
% end

sift_mono_converge = false(n_exp,1);
sift_stereo_converge = false(n_exp,1);
rlff_mono_converge = false(n_exp,1);
rlff_stereo_converge = false(n_exp,1);
for ii = 1:n_exp
    sift_mono_converge(ii) = sift_mono_all(ii).sfm.did_converge;
    sift_stereo_converge(ii) = sift_stereo_all(ii).sfm.did_converge;
    rlff_mono_converge(ii) = rlff_mono_all(ii).sfm.did_converge;
    rlff_stereo_converge(ii) = rlff_stereo_all(ii).sfm.did_converge;
    nLF(ii) = groundtruth(ii).n;
end
num = (1:n_exp)';
T_exp = table(num,exp_list,sift_mono_converge,sift_stereo_converge,rlff_mono_converge,rlff_stereo_converge)

nLF_all = sum(nLF)

%% TODO: make table for table 2!

%% print

custom_colours
ii_exp = 9;

% colors from lf_plot_convergence_histogram.m
colors.sift_mono = [0.00,0.45,0.74];
colors.sift_stereo = [0.85,0.33,0.10];
colors.rlff_mono = [0.93,0.69,0.13];
colors.rlff_stereo = [0.49, 0.18, 0.56];
PLOT = true;
PLOT_INDIVIDUAL = false;
if PLOT_INDIVIDUAL && PLOT
    if RLFF_MONO
        [fig_handles] = lf_plot_experimental_results_method(groundtruth(ii_exp),rlff_mono_all(ii_exp),colors.rlff_mono,[]);
    end
    
    if RLFF_STEREO
        [fig_handles] = lf_plot_experimental_results_method(groundtruth(ii_exp),rlff_stereo_all(ii_exp),colors.rlff_stereo,[]);
    end
    
    if SIFT_MONO
        [fig_handles] = lf_plot_experimental_results_method(groundtruth(ii_exp),sift_mono_all(ii_exp),colors.sift_mono,[]);
    end
    
    if SIFT_STEREO
        [fig_handles] = lf_plot_experimental_results_method(groundtruth(ii_exp),sift_stereo_all(ii_exp),colors.sift_stereo,[]);
    end
end

% clear leg_str
%
% A(1) = false;
% A(2) = true;
% % test variable legend script:
% figure;
% hold on;
% plot(num,1*num);
% if A(1)
% plot(num,2*num);
% end
% if A(2)
% plot(num,2.5*num);
% end
% hold off;
% grid on; box on;
% xlabel('x');
% ylabel('y');
%
% basestr = 'gt';
% Astr{1} = 'A1';
% Astr{2} = 'A2';
% leg_str = cell(1);
% leg_str{1} = basestr;
% iLeg = 1;
% for ii = 1:length(A)
%     if A(ii) == true
%         iLeg = iLeg+1;
%         leg_str{iLeg} = Astr{ii};
%     end
% end
% legend(leg_str);

%% 

% if RLFF_MONO && RLFF_STEREO && SIFT_MONO && SIFT_STEREO
%     PRINT_COMBINED = true;
% end
PLOT_COMBINED = true;
% ii_exp = 7;
if PLOT_COMBINED &&  PLOT
    lf_plot_experimental_results_combined(groundtruth(ii_exp),...
        sift_mono_all(ii_exp),...
        sift_stereo_all(ii_exp),...
        rlff_mono_all(ii_exp),...
        rlff_stereo_all(ii_exp),...
        colors);
end

%% save data

% save intramatch features
disp('saving data in:')
casename_filename = ['Output/' case_name '.mat']
save(casename_filename,'-v7.3');
