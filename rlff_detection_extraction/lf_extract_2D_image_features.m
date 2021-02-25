%% lf_extract_sift_features
% Inputs: LF, SIFT settings
% Outputs: structs F, containing sift features and descriptors for each
% sub-image of the LF, indexed in the same manner as the LF probably
% (tsvu)?
% Dorian Tsai
% 2020 May 06
% dorian.tsai@gmail.com
function [F,D_root,D_sift] = lf_extract_2D_image_features(LF,varargin)
peak_threshold_default = .0066; % default from Nousias using vl_covdet

% parsing input parameters
p = inputParser;
addRequired(p,'LF',@isnumeric);
addParameter(p,'st_mask',true,@islogical); % sets a default, unsure how to make nSxnT default matrix without knowing size(LF) ahead of time
addParameter(p,'peak_threshold',peak_threshold_default,@isnumeric);
parse(p,LF,varargin{:});
LF = p.Results.LF;


nT = size(LF,1);
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);

st_mask = p.Results.st_mask;
if st_mask == true
    % default st_mask
    st_mask = ones(nT,nS);
else
    st_mask = p.Results.st_mask;
end
peak_threshold = p.Results.peak_threshold;

F = cell(nT,nS); % feature
D_root = cell(nT,nS); % descriptor
D_sift = cell(nT,nS); % descriptor
% F_info = cell(nT,nS); % feature info (peak scores/edge scores, etc)

% for a given LF
% for each sub-image
% find SIFT features 
for tt = 1:nT
    for ss = 1:nS
        % fprintf('(tt=%g,ss=%g)\n',tt,ss);
        if st_mask(tt,ss) == false
            % disp('continue');
            continue
        end
        % disp('sifting for features');
        I = im2single(rgb2gray(squeeze(LF(tt,ss,:,:,:))));
        % vl_sift vs vl_covdet, vl_covdet looks much more general/flexible,
        % but basically just finds sift features with its current default
        % settings, except slightly more dense than sift (we need more
        % candidates)
        %         [F{tt,ss},D{tt,ss},F_info{tt,ss}] = vl_covdet(I,'peakThreshold',peak_threshold,'MaxNumOrientations',4); % could set options for vl_sift
        
        
        % SIFT thresholds:
        % peakthresh (0,10,20,30) larger = fewer features
        % edtethresh (3.5 - 10), larger = more edge-like features 
        
        [F{tt,ss},D_sift{tt,ss}] = vl_sift(I,'PeakThresh',peak_threshold); % could set options for vl_sift
        
        % use rootsift
        D_root{tt,ss} = convert_descriptor_to_rootSift(D_sift{tt,ss});
        
        
        % TODO: also, might be possible to get info.peakScores or some sort
        % of feature strength measure -> can then sort features according
        % to their strength
        
       % FAME has 6 components. 
       % FRAME(1:2) are the coordiantes T=[x;y] of the center. 
       % FRAME(3:6) is the column-wise stacking of a 2x2 matrix A. 
       % The oriented ellipse is obtained by applying the affine transformation (A,T) to the standard oriented frame (see below).
       % A standard unoriented frame is a circle of unit radius centered at
       %        the origin; a standard oriented frame is the same, but marked with
       %        a radius pointing towards the positive Y axis (i.e. downwards
       %        according to the standard MATLAB image reference frame) to
       %        represent the frame orientation. All other frames can be obtained
       %        as affine transformations of these two. In the case of unoriented
       %        frames, this transformation is ambiguous up to a rotation.
       
       % from a computation perspective, we don't want too many features
       
       
    end
end


end