% calibrate LF
% Dorian Tsai
% 2020 May 06

% purpose:
% to run the calibration utilities, given the calibration light field data and white
% images

% set camera calibration
lytro_camera_calibration_folder = '~/Data/CameraCalibration/';
% lytro_camera_calibration_lightfields = '20180130_IllumCal_100mmZoom_40cmFocus/';
lytro_camera_calibration_lightfields = '20200520_rlff_cal/'; % at 75mm zoom, close ~20cm focus
% lytro_camera_calibration_lightfields = '20200616_rlff_cal/'; % on panda arm, 100mm zoom, 40 cm focus
% lytro_camera_calibration_lightfields = '20200618_rlff_cal/'; % on panda arm, 75mm zoom, 40 cm focus


lytro_camera_calibration_run_folder = [lytro_camera_calibration_folder, lytro_camera_calibration_lightfields];


%% white images

lf_camera_name = 'B5143300780'; % serial number of lytro camera
% lytro_camera_white_image_folder = [lytro_camera_calibration_folder, '/', lf_camera_name, '/WhiteImages'];
lytro_camera_white_image_folder = [lytro_camera_calibration_folder, '/caldata-', lf_camera_name, '/unitdata'];

% build white image database (only has to be done once)
% should create WhiteImageDatabase.mat
BUILD_WHITE_IMAGE_DATABASE = false;
if BUILD_WHITE_IMAGE_DATABASE
    FileOptions.ForceRedo = 1;
    LFUtilProcessWhiteImages(lytro_camera_white_image_folder);
end
white_image_database_file = [lytro_camera_white_image_folder '/WhiteImageDatabase.mat'];


%% decode calibration images/light fields

% LF_CALIBRATE = true;
% if LF_CALIBRATE
% run LFUtilDecodeLytroFolder on the example images to decode the
% checkerboard images
FileOptions.ForceRedo = 0;
DecodeOptions.WhiteImageDatabasePath = white_image_database_file;
LFUtilDecodeLytroFolder( lytro_camera_calibration_run_folder, FileOptions,DecodeOptions );


%% calibrate

% run the LF calibrations function, given known checkerboard sizes
CalOptions.ExpectedCheckerSize = [19,19]; % corners in the checkerboard
CalOptions.ExpectedCheckerSpacing_m = 1e-3 * [ 4.0 4.0]; % need to remeasure the checker spacings
CalOptions.LensletBorderSize = 1;
CalOptions.ForceRedoInit = false;
CalOptions.ForceRedoCornerFinding = false;
LFUtilCalLensletCam( lytro_camera_calibration_run_folder , CalOptions); % make sure to delete CalInfo.json, otherwise it doesn't run


%% validate

% how to validate calibration?
% we can rectify the checkboard images:
% use calibrations
% locates and catalogues camera calibrations
% result typically stored in Cameras/CalibrationDatabase.mat
VALIDATE = false;
if VALIDATE == true
    LFUtilProcessCalibrations(lytro_camera_calibration_run_folder); % ???
    
    % TODO: copy calibration LFs to a new folder, done manually
    lytro_camera_calibration_validation_lightfields = ['validation_' lytro_camera_calibration_lightfields];
    validate_camera_calibrations_folder = [lytro_camera_calibration_folder lytro_camera_calibration_validation_lightfields];
    
    DecodeOptions.WhiteImageDatabasePath = white_image_database_file;
    DecodeOptions.OptionalTasks = 'Rectify';
    RectOptions.CalibrationDatabaseFname = '~/Data/CameraCalibration/20180130_IllumCal_100mmZoom_40cmFocus/CalibrationDatabase.mat';
    LFUtilDecodeLytroFolder( validate_camera_calibrations_folder, [],DecodeOptions, RectOptions);
    % examine text output and visually inspect the rectified images (central
    % views), can compare to unrectified images in
    % lytro_camewra_calibration_run_folder
    
    % really hard to tell - maybe by super-imposing the two images, it would be
    % a bit clearer
end

