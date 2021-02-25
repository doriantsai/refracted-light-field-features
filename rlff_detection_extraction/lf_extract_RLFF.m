% function lf_extract_RLFF takes in the LF, feature list and intra-match of
% features within the LF, and extracts RLFF for every single feature in
% ray_ftr, and returns the RLFF and ray observations, index corresponding
% to ray_ftr
function [rlff] = lf_extract_RLFF(LFS,ray_ftr,Fc,varargin)

%% defaults
default_threshold_error_reproj = 0.016;

%% parsing input parameters
p = inputParser;
addRequired(p,'LFS',@isstruct);
addRequired(p,'ray_ftr',@iscell);
addRequired(p,'ftr_list',@isnumeric);
addParameter(p,'threshold_error_reproj',default_threshold_error_reproj,@isnumeric);

parse(p,LFS,ray_ftr,Fc,varargin{:});
LFS = p.Results.LFS;
ray_ftr = p.Results.ray_ftr;
Fc = p.Results.ftr_list;

LF = LFS.LF;
D = LFS.D;
threshold_error_reproj = p.Results.threshold_error_reproj;

nT = size(LF,1); % potential confusion between stuv and ijkl notation
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);

% run single_rlff over entire LFvec
nFtr = size(ray_ftr,2);
rlff = cell(nFtr,1); % index to length of 
error_reproj_sym = zeros(nFtr,1);
for ii = 1:nFtr
    [rlff{ii}] = lf_extract_single_RLFF(LFS,ray_ftr,Fc,ii);
    error_reproj_sym(ii) = rlff{ii}.error_reproj_sym;
end

% check for rlff that are not well-described by H, the projection transform
% this is indicated by the reprojection error, high reprojection error
% means H does not well-describe the data
% this can sometimes be because the intra-LF match did not do a good job in
% correspondence
% we choose to take the 98 percentile features, with the top/largest being
% removed as outliers
% outlier_reproj = isoutlier(error_reproj_sym,'percentiles',[0 98]);
outlier_reproj = error_reproj_sym > threshold_error_reproj;
% alternatively, simply threshold at err < 0.016
for ii = 1:nFtr
    if outlier_reproj(ii) == true
        rlff{ii}.isoutlier = true;
    else
        rlff{ii}.isoutlier = false;
    end
end

% note: simply flagged, because to remove it completely would require to
% syncronise ray_ftr, Fc as well, which we do do later