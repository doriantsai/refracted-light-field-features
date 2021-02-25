function [LFS] = InputLightFieldIllum(lfFolder, lfFilename,n_border_crop_views)
% input LF location/saveFilename, decode (boolean)
% output light field structure


LFS   = load([lfFolder '/' lfFilename]);
LFS.LFName = lfFilename(1:end-4); % -4 to remove the '.mat' extension

[TSize, SSize, VSize, USize,~] = size(LFS.LF);

% properties:

% throw away top/bottom S,T views, due to extreme vignetting and
% lack of calibration/rectification:
% LFS.LF = LFS.LF(2:TSize-1,2:SSize-1,:,:,1:3);
% n_border_crop_views must be at least 1, but less than
% (TSize-n_border_crop_views)
LFS.LF = LFS.LF(n_border_crop_views+1 : TSize-n_border_crop_views,...
    n_border_crop_views+1 : SSize-n_border_crop_views,:,:,1:3);


[LFS.TSize, LFS.SSize, LFS.VSize, LFS.USize,~] = size(LFS.LF);
LFS.TCent = round(LFS.TSize/2);
LFS.SCent = round(LFS.SSize/2);
LFS.UCent = round(LFS.USize/2);
LFS.VCent = round(LFS.VSize/2);
LFS.D = 1;

LFS.LFFolder = lfFolder;