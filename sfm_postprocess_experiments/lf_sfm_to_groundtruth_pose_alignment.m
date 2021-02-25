function [T_sfm_scaled, regParams] = lf_sfm_to_groundtruth_pose_alignment(T_gt,T_sfm)
% scale pose transforms sfm to gt
% in: H_gt, H_sfm, nMatch
% out: scale, t_sfm_scaled, H_sfm_scaled

[~,~,nMatch] = size(T_gt);

[~,~,nGt] = size(T_gt);
[~,~,nSfm] = size(T_sfm);

if (nGt ~= nSfm)
    disp('Error: number of groundtruth poses does not match number of SfM poses');
end

% consider trying to align sfm reconstruction to ground truth via matching the first nMatch poses
% note that this only works for aligning the 3D point positions, and their
% overall orientation (rather than the orientations of each

t_sfm = zeros(nMatch,3);
for ii = 1:nMatch
    t_sfm(ii,:) = tform2trvec(T_sfm(:,:,ii));
end

t_gt = zeros(nMatch,3);
for ii = 1:nGt
    t_gt(ii,:) = tform2trvec(T_gt(:,:,ii));
end

% try Horn's method for scaling/rotating/transforming ground truth points
% to SfM-estimated poses. Note that this does not fix the orientation of
% the poses, only the points! 
[regParams,Bfit,ErrorStats]=absor(t_sfm',t_gt(1:nMatch,:)','doScale','TRUE');

% apply transformation regParams.M to all H_sfm_usc:
T_sfm_scaled = zeros(4,4,nSfm);
T_match = regParams.M; % note that scale is applied here as [s*R,t;[0 0 ... 1]]

for ii = 1:nSfm
    T_sfm_scaled(:,:,ii) = T_match * T_sfm(:,:,ii);
    % make sure H_sfm rotation matrices are orthogonal (take out the scaling
    % component): we do this by dividing R/s
    T_sfm_scaled(1:3,1:3,ii) = T_sfm_scaled(1:3,1:3,ii)/regParams.s;
end