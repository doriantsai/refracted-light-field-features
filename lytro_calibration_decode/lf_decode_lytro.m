% decode LF script
% Dorian Tsai
% 2020 May 06
%
% purpose:
% given a folder of raw LF sequences from the Illum, yield decoded LFs in
% .mat format based on Don's LF toolbox\
% TODO: incorporate Illum calibration as part of the decode


% select name of folder with LFs that require decoding
% lf_folder_num = 6;
% switch lf_folder_num
%     case 1
%         lf_folder = '~/Data/Illum_Kinova_Dataset/20180220-1448_bottle/';
%     case 2
%         lf_folder = '~/Data/Illum_Kinova_Dataset/20180220-1004_bugaboos/';
%     case 3
%         lf_folder = '~/Data/20200523_rlff_bottle_vert/';
%     case 4
%         lf_folder = '~/Data/20200520_rlff_bottle_diag/';
%     case 5
%         lf_folder = '~/Data/20200520_rlff_sphere/';
%     case 6
%         lf_folder = '~/Data/20200523_rlff_unsorted/';
% end

% set camera calibration
lytro_camera_calibration_folder = '~/Data/CameraCalibration/';
lf_camera_name = 'B5143300780'; % serial number of lytro camera

lytro_camera_white_image_folder = [lytro_camera_calibration_folder, '/caldata-', lf_camera_name, '/unitdata'];
white_image_database_file = [lytro_camera_white_image_folder '/WhiteImageDatabase.mat'];

% lytro_camera_calibration_run_folder = [lytro_camera_calibration_folder '20200520_rlff_cal/'];

% lf_folder = '~/Data/20200523_rlff_lambertian/';
% lf_folder = '~/Data/20200523_rlff_bottle_vert/';
% lf_folder = '~/Data/20200520_rlff_bottle_diag/';

lytro_camera_calibration_run_folder = [lytro_camera_calibration_folder '20200618_rlff_cal/']; % 75mm zoom, 40cm focus?

% select folder to decode;
% lf_folder = '~/Data/20200619-1412_handeye_calibration/';
% lf_folder = '~/Data/20200619-1432_rlff_lambertian_cyl/';
% lf_folder = '~/Data/20200619-1440_rlff_cyl_diag/';
% lf_folder = '~/Data/20200619-1448_rlff_bottle_diag/';
% lf_folder = '~/Data/20200619-1454_rlff_bottle_diag/';
% lf_folder = '~/Data/20200619-1506_rlff_big_cup/';
% lf_folder = '~/Data/20200619-1524_rlff_many_glasses/';

% lf_folder = '~/Data/20200624-1852_handeye_calibration_asym';
% lf_folder = '~/Data/20200624-1914_rlff_cup_diag_motion';
% lf_folder = '~/Data/20200624-1922_rlff_cup_fwd_motion';
% lf_folder = '~/Data/20200624-1926_rlff_cup_manual1';
% lf_folder = '~/Data/20200624-1932_rlff_cup_manual_arc';
% lf_folder = '~/Data/20200624-1941_rlff_snowrobot';
% lf_folder = '~/Data/20200624-1945_rlff_snowrobot';
% lf_folder = '~/Data/20200624-1948_rlff_snowrobot';
% lf_folder = '~/Data/20200624-1956_rlff_cube';
% lf_folder = '~/Data/20200626-1344_rlff_cyl_vert';
% lf_folder = '~/Data/20200626-1356_rlff_cyl_vert_diagMtn';
% lf_folder = '~/Data/20200626-1406_rlff_cyl_diag_diagMtn';
% lf_folder = '~/Data/20200727/20200728-0055_rlff_wineglass_arc';
lf_folder = '~/Data/20200802';

% lytro_camera_calibration_run_folder = [lytro_camera_calibration_folder '20180130_IllumCal_100mmZoom_40cmFocus/'];

% lytro_camera_calibration_run_folder = [lytro_camera_calibration_folder '20200616_rlff_cal/']; % 100mm zoom, 40cm focus
% 

% decode light fields, apply calibration
LF_DECODE = true;
LF_APPLY_CALIBRATIONS = true;
if LF_DECODE
    disp('Decoding light fields:');
    disp(['Folder: ' lf_folder ]);
    FileOptions.ForceRedo = 1;
    DecodeOptions.WhiteImageDatabasePath = white_image_database_file;
    RectOptions = [];
    if LF_APPLY_CALIBRATIONS
        LFUtilProcessCalibrations(lytro_camera_calibration_run_folder); % should be  a CalibrationDatabase.mat file
        DecodeOptions.OptionalTasks = 'Rectify';
        RectOptions.CalibrationDatabaseFname = [lytro_camera_calibration_run_folder '/CalibrationDatabase.mat'];
    end
    LFUtilDecodeLytroFolder(lf_folder,FileOptions,DecodeOptions,RectOptions);
end
    

    

