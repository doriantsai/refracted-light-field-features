function [sfm_sift_mono, sfm_sift_stereo, sfm_rlff_mono, sfm_rlff_stereo] = lf_process_sfm_from_colmap(exp_name, case_name, SIFT_MONO, SIFT_STEREO,RLFF_MONO,RLFF_STEREO)
% after results have been run in Colmap, and assuming that the results have
% converged/exist in the appropriate folder
% here, we are given the folder name/location of the sfm results
% grab them, as well as the relevant LF data

% plot the 3D model from SfM, scale it
% plot pose history/sequence
% compare it to groundtruth poses from panda arm
% compare it to poses from situation where refractive features are not
% used, so just pure monocular SfM/stereo SfM/no RLFF taken into account

% addpath('Support_Functions/');
% addpath('colmap_scripts/');
% exp_name = '20200624-1922_rlff_cup_fwd_motion';
if ~SIFT_MONO
    sfm_sift_mono = [];
end
if ~SIFT_STEREO
    sfm_sift_stereo = [];
end
if ~RLFF_STEREO
    sfm_rlff_stereo = [];
end
if ~RLFF_MONO
    sfm_rlff_mono = [];
end



PLOT = false;

% data folders: (assume LFs are already decoded)
% data_folder = ['~/Data/' exp_name ];
colmap_folder = ['~/Data/colmap_data/' exp_name];
colmap_sift_mono_folder = [colmap_folder '/sift_mono'];
colmap_sift_stereo_folder = [colmap_folder '/sift_stereo'];
colmap_rlff_mono_folder = [colmap_folder '/rlff_mono'];
colmap_rlff_stereo_folder = [colmap_folder '/rlff_stereo'];

colmap_sift_mono_reconstruction_folder = fullfile([colmap_sift_mono_folder,'/', case_name, '/0']);
colmap_sift_stereo_reconstruction_folder = fullfile([colmap_sift_stereo_folder,'/' case_name '/0']);
colmap_rlff_mono_reconstruction_folder = fullfile([colmap_rlff_mono_folder,'/' case_name '/0']);
colmap_rlff_stereo_reconstruction_folder = fullfile([colmap_rlff_stereo_folder,'/' case_name '/0']);


%% key file names:
% if these files are present, it means that Colmap converged; otherwise,
% Colmap did not converge:
colmap_camera_file = 'cameras.txt';
colmap_images_file = 'images.txt';
colmap_points3D_file = 'points3D.txt';
colmap_keypoints_file = 'KeypointCountsStats.txt';
colmap_matches_inlier_file = 'MatchesInlierStats.txt';
colmap_matches_putative_file = 'MatchesPutativeStats.txt';

colmap_filenames.camera = colmap_camera_file;
colmap_filenames.images = colmap_images_file;
colmap_filenames.points3D = colmap_points3D_file;
colmap_filenames.keypoints = colmap_keypoints_file;
colmap_filenames.matches_inlier = colmap_matches_inlier_file;
colmap_filenames.matches_putative = colmap_matches_putative_file;

%% for LF Synth Data

% get image file names: (all *__Decoded.mat files in data_folder)
% strEndPattern = '__Decoded.mat';
% [lfFilenames] = getFilenamesInFolder(data_folder,strEndPattern);
% nLF = length(lfFilenames);
%
% LFS = cell(nLF,1); % LF Data
% H_cal = nan(5,5,nLF); % calibration matrix (unsure if should be the same for each LF?) Johannsen has 1/LF?
% % GT - how to get ground-truth? known poses from rosbag data?
%
% % load LF data into cells
% fprintf('Loading %g light fields\n',nLF);
% n_border_crop_views = 0; % set to 0 for 15x15 normally,
%
% for ii = 1:nLF
%     fprintf('%g:\t%s\n',ii,lfFilenames{ii});
%     LFS{ii} = InputLightFieldIllum(data_folder,lfFilenames{ii},n_border_crop_views);
%     H_cal(:,:,ii) = LFS{ii}.RectOptions.RectCamIntrinsicsH;
% end

% for LFSynth, we have groundtruth poses from
% LFS{ii}.ScenbeGeoemtry.CamPos, CamRot:
% t_gt = nan(nLF,3);
% rot_gt = nan(nLF,3);
% for ii = 1:nLF
%     t_gt(ii,:) = LFS{ii}.SceneGeometry.CamPos;
%     rot_gt(ii,:) = LFS{ii}.SceneGeometry.CamRot;
% %     H_gt(:,:,ii) = trvec2tform(t_gt(ii,:));
% end

%% extract sfm poses/data

% tThick = 1;
% tLength = 0.2;

[sfm_sift_mono] = sfm_extract_data(colmap_sift_mono_reconstruction_folder,colmap_filenames,'sift_mono');
[sfm_sift_stereo] = sfm_extract_data(colmap_sift_stereo_reconstruction_folder,colmap_filenames,'sift_stereo');
[sfm_rlff_mono] = sfm_extract_data(colmap_rlff_mono_reconstruction_folder,colmap_filenames,'rlff_mono');
[sfm_rlff_stereo] = sfm_extract_data(colmap_rlff_stereo_reconstruction_folder,colmap_filenames,'rlff_stereo');

%% mono sfm




% if TRY_MONO
    
    
    % grab sfm poses/3D points
%     [T_sfm_mono,t_sfm_mono,xyz_mono,c_mono] = findSfMCameraPoses(colmap_mono_reconstruction_folder);
    
%     mono.T = T_sfm_mono;
%     mono.t = t_sfm_mono;
%     mono.xyz = xyz_mono;
%     mono.c = c_mono;    
%     
%     [~,~,nPoseMono] = size(T_sfm_mono);
%     % plot mono
%     if PLOT
%         figure;
%         plot3(t_sfm_mono(:,1),t_sfm_mono(:,2),t_sfm_mono(:,3),'o-');
%         
%         hold on
%         for ii = 1:nPoseMono
%             trplot(squeeze(T_sfm_mono(:,:,ii)),'color','blue','frame',num2str(ii),'length',tLength,'thick',tThick);
%         end
%         axis equal;
%         box on;
%         grid on;
%         hold off
%         xlabel('x');
%         ylabel('y');
%         zlabel('z');
%         title(['mono pose sfm: ' exp_name]);
%         save_mono_sfm = [exp_name '_colmap_mono.png'];
%         saveas(gcf,['Output/' save_mono_sfm]);
%     end
   
% end

%% stereo 
% colmap_stereo_reconstruction_folder = fullfile(colmap_stereo_folder,'/sparse/0');

% if TRY_STEREO
    
%     converged_files = LFFindFilesRecursive(colmap_stereo_reconstruction_folder,[],[], struct('Verbose',false));
    
%     try
%         [T_sfm_stereo,t_sfm_stereo,xyz_stereo,c_stereo] = findSfMCameraPoses(colmap_stereo_reconstruction_folder);
%         stereo.T = T_sfm_stereo;
%         stereo.t = t_sfm_stereo;
%         stereo.xyz = xyz_stereo;
%         stereo.c = c_stereo;
%         
%         % plot stereo
%         if PLOT
%             [~,~,nPoseStereo] = size(T_sfm_stereo);
%             figure;
%             plot3(t_sfm_stereo(:,1),t_sfm_stereo(:,2),t_sfm_stereo(:,3),'o-');
%             hold on
%             for ii = 1:nPoseStereo
%                 trplot(squeeze(T_sfm_stereo(:,:,ii)),'color','blue','frame',num2str(ii),'length',tLength,'thick',tThick);
%             end
%             axis equal;
%             hold off
%             box on;
%             grid on;
%             xlabel('x');
%             ylabel('y');
%             zlabel('z');
%             title(['stereo pose sfm (RLFF): ' exp_name ]);
%             save_stereo_sfm = [exp_name '_colmap_stereo.png'];
%             saveas(gcf,['Output/' save_stereo_sfm]);
%         end
%     catch
%         disp('Error with extracting sfm camera poses. Perhaps colmap_stereo_reconstruction_folder does not exist?');
%     end
    
% end

%%
% tline = fgets(fid);
% while ischar(tline)
%     elems = strsplit(tline);
%
% end
% fclose(fid);




end
