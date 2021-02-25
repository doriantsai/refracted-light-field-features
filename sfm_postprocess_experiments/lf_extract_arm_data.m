function [T_ee,T_goal,T_base] = lf_extract_arm_data(data_folder,exp_name, save_poses_filename,MANUAL_MODE)
% given exp_name, extract relevant arm data from rosbag file

% fprintf('Extracting arm data\n');

% addpath('/home/dt-venus/Dropbox/PhD/2020-LFRefractiveFeatures/lfrefractivefeatures/Code/rlffExtractIllum/matlab_ros_custom_messages/matlab_gen/msggen')
% rosgenmsg(ros_msg_path);
% addpath('Support_Functions/');

PLOT = false;

% exp_name = '20200619-1432_rlff_lambertian_cyl';

% find .bag file in exp_name folder:
exp_folder = fullfile(data_folder,exp_name);
[bag_name] = getFilenamesInFolder(exp_folder,'.bag');
nBags = size(bag_name);
if nBags ~= 1
    disp('Warning, nBags ~=1');
end
rosbagPath = fullfile(exp_folder,bag_name{1});

% from findCameraPoses.m in lffeatures project:
bag = rosbag(rosbagPath);

startTime = bag.StartTime;
endTime = bag.EndTime;

nMsg = bag.NumMessages;

%% read bag file messages

% bag_tf = select(bag,'Topic','/tf','Time',[startTime endTime]);
% msg_tf = readMessages(bag_tf);

% bag_franka_state_controller = select(bag,'Topic','/franka_state_controller/joint_states','Time',[startTime endTime]);
% msg_franka_states = readMessages(bag_franka_state_controller);

% if this doesn't exist, then we probably are running a manual case:
% quick hack: get size of table, if 3x3, then pose/goal is probably
% missing, so we're in manual mode. Default should be 4x3.

[nTopics,~] = size(bag.AvailableTopics);
% MANUAL_MODE = false;
if nTopics == 3
    disp('nTopics == 3, manual_mode on');
    MANUAL_MODE = true;
end


bag_arm = select(bag,'Topic','/arm/state');
msg_arm_state = readMessages(bag_arm,'DataFormat','struct');

if ~MANUAL_MODE
    bag_goal = select(bag,'Topic','/arm/cartesian/pose/goal');
    msg_goal = readMessages(bag_goal,'DataFormat','struct');
end


%% get all arm state

nArmState = length(msg_arm_state);
eePosePos = zeros(nArmState,3);
eePoseXyzw = zeros(nArmState,4);
jtPositions = zeros(nArmState,7);
tEeSec = zeros(nArmState,1);
tEeNsec = zeros(nArmState,1);
for ii = 1:nArmState
    eePose = msg_arm_state{ii}.EePose.Pose;
    eePosePos(ii,:) = [eePose.Position.X, eePose.Position.Y, eePose.Position.Z];
    eePoseXyzw(ii,:) = [eePose.Orientation.X, eePose.Orientation.Y, eePose.Orientation.Z, eePose.Orientation.W];
    jtPositions(ii,:) = msg_arm_state{ii}.JointPoses; % rad
    tEeSec(ii) = msg_arm_state{ii}.EePose.Header.Stamp.Sec;
    tEeNsec(ii) = (msg_arm_state{ii}.EePose.Header.Stamp.Nsec);
end

eePoseWxyz = quaternion([eePoseXyzw(:,4), eePoseXyzw(:,1:3)]);
eePoseEulXyz = eulerd(eePoseWxyz,'XYZ','frame'); % or ZYX?

% zero the seconds:
tEeSec0 = tEeSec - tEeSec(1); % not sure if this part is truly necessary, but maybe due to max int size
% nanoseconds to seconds:
tEeNsec_Sec = tEeNsec * 10^-9;

% combine times:
tEe = tEeSec0 + tEeNsec_Sec;
tInit = tEe(1);
% tEe = tEe - tInit;

if ~MANUAL_MODE
    nGoal = length(msg_goal);
    eeGoalPos = zeros(nGoal,3);
    eeGoalXyzw = zeros(nGoal,4);
    tGoalSec = zeros(nGoal,1);
    tGoalNSec = zeros(nGoal,1);
    for ii = 1:nGoal
        eeGoal = msg_goal{ii}.Goal.GoalPose.Pose;
        eeGoalPos(ii,:) = [eeGoal.Position.X, eeGoal.Position.Y, eeGoal.Position.Z];
        eeGoalXyzw(ii,:) = [eeGoal.Orientation.X, eeGoal.Orientation.Y, eeGoal.Orientation.Z, eeGoal.Orientation.W];
        tGoalSec(ii) = msg_goal{ii}.Header.Stamp.Sec;
        tGoalNSec(ii) = msg_goal{ii}.Header.Stamp.Nsec;
    end
    
    tGoalSec0 = tGoalSec - tEeSec(1); % note: since on same time scale as tEe, init with tEeSec
    tGoalNSec_Sec = tGoalNSec*10^-9;
    tGoal = tGoalSec0 + tGoalNSec_Sec;
    tGoalInit = tGoal(1);
    % tGoal = tGoal - tInit;
    
    % note that tGoalPose should also include the starting pose, since we take
    % a picture from the start: (we start from the same initial poses)
    tGoal = [0 tGoal']';
    eeGoalPos = [eePosePos(1,:); eeGoalPos];
    eeGoalXyzw = [eePoseXyzw(1,:); eeGoalXyzw];
    
    % convert quaternions to Euler angles XYZ for ease of visualisation
    eeGoalWxyz = quaternion([eeGoalXyzw(:,4), eeGoalXyzw(:,1:3)]);
    eeGoalEulXyz = eulerd(eeGoalWxyz,'XYZ','frame'); % or ZYX?
end





%% find steady-state times in armstate corresponding to goal state

tDiff1 = tEe - tEe(1);
[idxOneSec] = find((tEe > 1.0) .* (tEe <= 2.0));
sampleRate = length(idxOneSec); % 30 Hz for /arm/state

timeWindowArmStill = 3; % seconds, represents the time the arm was still, which is the window that we will use to sample the mean pose during that time
timeToSteady = 5; % seconds, includes time to send command, which is ~0.5 seconds, we are only dealing with small motions in this case

% smooth the poses from eePose
eePosePosSmooth = smoothdata(eePosePos,1,'gaussian',14);
eePoseXyzwSmooth = smoothdata(eePoseXyzw,1,'gaussian',14);



% set camStill(i) = 1
% iterate over the pose sequence, when we increment over the next tGoal(i),
%   after timeToSteady, then set camStill(i) = 1, or index/mark all the
%   indices until timeWindowArmStill is over
%   then take mean of timeWindowArmStill for all pose profiles
% show still areas
% compare tGoal to tEe

maxSampleCount = timeWindowArmStill*sampleRate;
sampleTimeToSteady = timeToSteady*sampleRate;
sampleCamPose = false(nArmState,1);

if MANUAL_MODE
    armDist = zeros(nArmState,1);
    for ii = 1:nArmState
        armDist(ii) = sqrt(sum(eePosePosSmooth(ii,:).^2));
    end
    armDiff = diff(armDist);
    armDiff = [0; armDiff]; % make initial difference 0
    
    absArmDiff = smoothdata(abs(armDiff),'gaussian',10);
    meanAbsArmDiff = mean(absArmDiff); % use mean arm diff as threshold
    
    %     figure;
    % plot(tEe,absArmDiff,tEe,meanAbsArmDiff*ones(size(tEe)),'-r');
    % grid on;
    % box on;
    % title('arm diff');
    
    halfSampleWindow = round(sampleTimeToSteady/2);
    for ii = halfSampleWindow : (nArmState - halfSampleWindow - 1)
        camMovement = absArmDiff(ii-halfSampleWindow+1 : ii+halfSampleWindow+1);
        camThresh = camMovement > meanAbsArmDiff; % threshold for movement
        if sum(camThresh) < 1
            sampleCamPose(ii) = true;
        end
    end
    
    % figure;
    % plot(tEe,absArmDiff,tEe,meanAbsArmDiff*ones(size(tEe)),'-r',...
    %     tEe(sampleCamPose==true),absArmDiff(sampleCamPose==true),'*r');
    % grid on;
    % box on;
    % title('arm diff');
    
else
    
    
    idxGoal = 1;
    steadyCount = 0;
    sampleCount = 0;
    for ii = 1:nArmState
        
        if tEe(ii) >= tGoal(idxGoal)
            steadyCount=steadyCount+1;
            % count to time steady:
            if steadyCount >= sampleTimeToSteady
                % begin sampleCount
                if sampleCount <= maxSampleCount
                    sampleCamPose(ii) = true;
                    sampleCount = sampleCount+1;
                else
                    % once we reach the end of the sampleCount
                    sampleCount = 0;
                    steadyCount=0;
                    if idxGoal < length(tGoal)
                        idxGoal = idxGoal+1;
                    else
                        % we need to stop...
                        break
                        
                    end
                end
                
                
                
            else
                % do nothing, but keep on counting
                
            end % end if: steadyCount increment
            
        end % end if tEe vs tGoal
    end
    % conversions
end


% eulerAnglesDegrees = eulerd(quat,'ZYX','frame')

% pose time history
% 2D figure/time histories
% samp = 1:nArmState;
% figure;
% plot(tEe,eePosePos(:,1),'r',tEe,eePosePos(:,2),'g',tEe,eePosePos(:,3),'b',...
%     tGoal,eeGoalPos(:,1),'o--r',tGoal,eeGoalPos(:,2),'o--g',tGoal,eeGoalPos(:,3),'o--b');
% legend('xee','yee','zee','xg','yg','zg','location','best');
% xlabel('sample');
% ylabel('xyz in base frame [m]');
% box on;
% grid on;

% split them up into 3 different sub-figures with linked axes:

if MANUAL_MODE
    
    if PLOT
    figure;
    hAxPos(1) = subplot(3,1,1);
    plot(tEe,eePosePos(:,1),'r',tEe,eePosePosSmooth(:,1),'-k',...
        tEe(sampleCamPose==true),eePosePosSmooth(sampleCamPose==true,1),'r*');
    ylabel('x [m]');
    box on; grid on;
    hAxPos(2) = subplot(3,1,2);
    plot(tEe,eePosePos(:,2),'g',tEe,eePosePosSmooth(:,2),'-k',...
        tEe(sampleCamPose==true),eePosePosSmooth(sampleCamPose==true,2),'g*');
    ylabel('y [m]');
    box on; grid on;
    hAxPos(3) = subplot(3,1,3);
    plot(tEe,eePosePos(:,3),'b',tEe,eePosePosSmooth(:,3),'-k',...
        tEe(sampleCamPose==true),eePosePosSmooth(sampleCamPose==true,3),'b*');
    ylabel('z [m]');
    box on;
    grid on;
    linkaxes(hAxPos,'x');
    
    figure;
    hAxPos(1) = subplot(3,1,1);
    plot(tEe,eePoseEulXyz(:,1),'r',...
        tEe(sampleCamPose==true),eePoseEulXyz(sampleCamPose==true,1),'r*');
    ylabel('roll [deg]');
    box on; grid on;
    hAxPos(2) = subplot(3,1,2);
    plot(tEe,eePoseEulXyz(:,2),'g',...
        tEe(sampleCamPose==true),eePoseEulXyz(sampleCamPose==true,2),'g*');
    ylabel('pitch [deg]');
    box on; grid on;
    hAxPos(3) = subplot(3,1,3);
    plot(tEe,eePoseEulXyz(:,3),'b',...
        tEe(sampleCamPose==true),eePoseEulXyz(sampleCamPose==true,3),'b*');
    ylabel('yaw [deg]');
    box on;
    grid on;
    linkaxes(hAxPos,'x');
    end
    
else
    if PLOT
    figure;
    hAxPos(1) = subplot(3,1,1);
    plot(tEe,eePosePos(:,1),'r',tGoal,eeGoalPos(:,1),'--or',tEe,eePosePosSmooth(:,1),'-k',...
        tEe(sampleCamPose==true),eePosePosSmooth(sampleCamPose==true,1),'r*');
    ylabel('x [m]');
    box on; grid on;
    hAxPos(2) = subplot(3,1,2);
    plot(tEe,eePosePos(:,2),'g',tGoal,eeGoalPos(:,2),'--og',tEe,eePosePosSmooth(:,2),'-k',...
        tEe(sampleCamPose==true),eePosePosSmooth(sampleCamPose==true,2),'g*');
    ylabel('y [m]');
    box on; grid on;
    hAxPos(3) = subplot(3,1,3);
    plot(tEe,eePosePos(:,3),'b',tGoal,eeGoalPos(:,3),'--ob',tEe,eePosePosSmooth(:,3),'-k',...
        tEe(sampleCamPose==true),eePosePosSmooth(sampleCamPose==true,3),'b*');
    ylabel('z [m]');
    box on;
    grid on;
    linkaxes(hAxPos,'x');
    
    figure;
    hAxPos(1) = subplot(3,1,1);
    plot(tEe,eePoseEulXyz(:,1),'r',tGoal,eeGoalEulXyz(:,1),'--or',...
        tEe(sampleCamPose==true),eePoseEulXyz(sampleCamPose==true,1),'r*');
    ylabel('roll [deg]');
    box on; grid on;
    hAxPos(2) = subplot(3,1,2);
    plot(tEe,eePoseEulXyz(:,2),'g',tGoal,eeGoalEulXyz(:,2),'--og',...
        tEe(sampleCamPose==true),eePoseEulXyz(sampleCamPose==true,2),'g*');
    ylabel('pitch [deg]');
    box on; grid on;
    hAxPos(3) = subplot(3,1,3);
    plot(tEe,eePoseEulXyz(:,3),'b',tGoal,eeGoalEulXyz(:,3),'--ob',...
        tEe(sampleCamPose==true),eePoseEulXyz(sampleCamPose==true,3),'b*');
    ylabel('yaw [deg]');
    box on;
    grid on;
    linkaxes(hAxPos,'x');
    
    end
end




%%

% average over the camStill window:
CC = bwconncomp(sampleCamPose);
keyIdx = cell(CC.NumObjects,1);
tEeAvg = zeros(CC.NumObjects);
eePosePosAvg = zeros(CC.NumObjects,3);
eePoseQuatWxyzAvg = zeros(CC.NumObjects,4);
eePoseEulXyzAvg = zeros(CC.NumObjects,3);
for ii = 1:CC.NumObjects
    [r,c] = ind2sub(size(sampleCamPose),CC.PixelIdxList{ii});
    keyIdx{ii}= r;
    
    tEeAvg(ii) = mean(tEe(r));
    eePosePosAvg(ii,:) = mean(eePosePos(r,:),1);
    eePoseQuatWxyzAvg(ii,:) = mean(compact(eePoseWxyz(r)),1);
    eePoseEulXyzAvg(ii,:) = mean(eePoseEulXyz(r,:),1);
end

% should now be able to compare tEe and tGoal:

% tGoal
% tEeAvg
% eePosePosAvg - eeGoalPos % command error on the order of mm
% eePoseEulXyzAvg - eeGoalEulXyz % order of a fifth of a degree



%% show transforms


% these should be the same, but might be different due to certain parameter
% settings
if MANUAL_MODE
    nPoses = length(tEeAvg);
else
    nPoses = length(tGoal);
end

T_base = trvec2tform([0 0 0]) * rotm2tform(eye(3));


% convert poses to H-transforms:

if ~MANUAL_MODE
    T_goal = zeros(4,4,nPoses);
end
T_ee = zeros(4,4,nPoses);
for ii = 1:nPoses
    if ~MANUAL_MODE
        T_goal_trans = trvec2tform(eeGoalPos(ii,:));
        T_goal_rot = quat2tform(compact(eeGoalWxyz(ii)));
        T_goal(:,:,ii) = T_goal_trans * T_goal_rot;
    end
    
    T_ee_trans = trvec2tform(eePosePosAvg(ii,:));
    T_ee_rot = quat2tform(eePoseQuatWxyzAvg(ii,:));
    T_ee(:,:,ii) = T_ee_trans * T_ee_rot;
end

% for both Tgoal and Tee, it seems that there's an unknown 90 degree
% rotation about the z-axis that can't be explained. TODO: investigate
% further, but for now, apply and run with it!
for ii = 1:nPoses
    eulz = [0 0 -pi];
    T_fix = eul2tform(eulz,'XYZ');
    if ~MANUAL_MODE
        T_goal(:,:,ii) = T_goal(:,:,ii) * T_fix;
    end
    T_ee(:,:,ii) = T_ee(:,:,ii) * T_fix;
end

if PLOT
figure;
plot3(eePosePosAvg(:,1),eePosePosAvg(:,2),eePosePosAvg(:,3),'.-b');
% plot3(eeGoalPos(:,1),eeGoalPos(:,2),eeGoalPos(:,3),'.-r');
% axis square
axis equal
hold on;

% plot homogeneous transforms to show coordinate frames
tThick = 1;
tLength = 0.002;
for ii = 1:nPoses
    %     trplot(squeeze(T_goal(:,:,ii)),'color','red','frame',num2str(ii),'length',tLength,'thick',tThick);
    trplot(squeeze(T_ee(:,:,ii)),'color','blue','frame',num2str(ii),'length',tLength,'thick',tThick);
end
% trplot(T_base,'color','green','frame','base','length',tLength,'thick',tThick);

xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
title('Sequence of camera poses goal in panda arm base frame');
grid on;
box on;
hold off;
end

% output:
if MANUAL_MODE
    T_goal = nan(4,4,nPoses);
end
% T_ee
% T_goal (if manual, else empty)
%     T_base
% eePosePosAvg

if ~isempty(save_poses_filename)
    save(save_poses_filename,'T_ee','-v7.3');
end

%%

% makes sense these are equivalent: axes are just in opposite directions
% and they rotate about negative degree from each otherr -thus the same
% orientation
% q1 = quaternion([1.000, 0.002, 0.000, -0.006]);
% q2 =  quaternion([-1.000, -0.002, -0.000, 0.006]);
% T1 = quat2tform(q1);
% T2 = quat2tform(q2);
%
% figure;
% hold on;
%  trplot(T1,'color','red','frame',num2str(ii),'length',tLength,'thick',tThick);
%     trplot(T2,'color','blue','frame',num2str(ii),'length',tLength,'thick',tThick);
%    xlabel('x [m]');
% ylabel('y [m]');
% zlabel('z [m]');
% title('Sequence of camera poses goal in panda arm base frame');
% grid on;
% box on;
% hold off;
% TODO: import Panda model from Peter's toolbox?

