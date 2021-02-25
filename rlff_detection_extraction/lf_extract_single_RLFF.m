% lf_extract_single_RLFF.m

% function extracts a single RLFF given a set of feature observations stuv
% from the Illum
function [rlff] = lf_extract_single_RLFF(LFS,ray_ftr,ftr_list,idx_ftr,varargin)

%% defaults


%% parsing input parameters
p = inputParser;
addRequired(p,'LFS',@isstruct);
addRequired(p,'ray_ftr',@iscell);
addRequired(p,'ftr_list',@isnumeric);
addRequired(p,'idx_ftr',@isnumeric);

parse(p,LFS,ray_ftr,ftr_list,idx_ftr,varargin{:});
LFS = p.Results.LFS;
ray_ftr = p.Results.ray_ftr;
ftr_list = p.Results.ftr_list;
idx_ftr = p.Results.idx_ftr;

LF = LFS.LF;
D = LFS.D;

nT = size(LF,1); % potential confusion between stuv and ijkl notation
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);


%% stuv preparation (discrete -> continuous domains)

% convert ijkl (discrete units of pixels and views) to 
% stuv (continuous units of meters)
ijkl = ray_ftr{idx_ftr};
ijkl_h = [ijkl, ones(size(ijkl,1),1)]; % homogeneous

H_cal = LFS.RectOptions.RectCamIntrinsicsH;

stuv_h = (H_cal * ijkl_h')';
stuv = stuv_h(:,1:4);
% for LFSynth, ijkl or H_cal is in absolute coordinates
% temp fix, we'll see:
% stuv(:,3:4) = stuv(:,3:4) - stuv(:,1:2);

% zero stuv_h wrt the central view by subtracting the principal ray from stuv:
% find index of central view:
idx_centre = find( [sC == ray_ftr{idx_ftr}(:,1)] .* [tC == ray_ftr{idx_ftr}(:,2)] );
% u_ftr = ray_ftr{idx_ftr}(idx_centre,3);
% v_ftr = ray_ftr{idx_ftr}(idx_centre,4);

stuv0 = stuv(idx_centre,:);
stuv_c = stuv - ones(size(stuv,1),1)*stuv0; % not sure if this is 100% necessary
% stuv_c0 = stuv_c(idx_centre,:);

% compute projective transformation, H from the observation data:
% note, this is different from the intrinsic calibration matrix H_cal
st = stuv(:,1:2)'; % used to be stuv_c
uv = stuv(:,3:4)'; % here, could subtract st
% make st, uv homogeneous:
st_h = [st; ones(1,size(st,2))];


%% estimate projective transform from observations (stuv)

H_raw = uv/st_h; 

uv_raw_est = H_raw * st_h;
error_reproj_raw = sqrt( sum( (uv_raw_est(:) - uv(:)).^2 ) ); % gives a rough measure of how good H_raw describes the stuv observations (lower is better)
offset_raw = H_raw(:,3);

% perform matrix conditioning to enforce symmetric matrix in H(2x2)
% justified for toric lenses; however, it is not certain if this is a valid
% approach for astigmatic lenses

% consider the following setup (from xComplexEig.m)
% syms theta real
% R = rotz(theta);
% R = R(1:2,1:2);
% R(2,1) = R(2,1)-1;
% 
% syms v11 v12 v21 v22 d1 d2 real
% v = R; % enforcing toric lens
% v = ?; % TODO: there should be a general astigmatic lens form, which might be
% inferred from the astigmatic lens tool (ED for H, then rotated and
% merged)
% v = [v11,v12; v21,v22]; % most general 2x2
% d=[d1,0;0,d2];
% H = (v*d*v^-1);
% 
% simplify(H-H',20)
% 
% H2 = 0.5 * (H + H');
% simplify(H2-H2',20)
H_just_rot_scale = H_raw(1:2,1:2);
H_symmetric = 0.5 * ( H_just_rot_scale + H_just_rot_scale');

% use eigenvalue decomposition to reform H, although I think H is just
% H_symmetric with the offset
[eig_vec,eig_val] = eig(H_symmetric(1:2,1:2)); 

H = H_symmetric; 
H(:,3) = offset_raw;

uv_est = H * st_h;
% error should be zero, could use this as a measure of how good
            % our fit was
error_reproj_sym = sqrt(sum( (uv_est(:) - uv(:)).^2));
% fprintf('reprojection Error = %g [uv units]\n',error_reproj);

offset = H(:,3);

% D is not returned sorted, so we sort in descending order
            %             [~,indd] = sort(diag(eigVal),'descend');
            %             eigVal_sort = eigVal(indd,indd);
            %             eigVec_sort = eigVec(:,indd);
            % maybe not an issue if sorted or not
            
% disp('Eigenvalues and eigenvectors, respectively:')
eig_val = diag(eig_val);
% eig_vec

% from Don:
            % works only if H can be decomposed into the form:
            % H = (R)^-1 * S * R
            % D = the scaling factors, i.e the slopes
            % v contains two axes along which to apply the scaling factors
            % V(:,1) and V(:,2), also known as the right eigenvectors:
            % A*V = V*D for [V,D] = eig(A)
            % the 2-norm of the eigenvectors is set to 1
            % only if A is real symmetric, is V orthonormal

%% compute likeliness of refracted feature vs Lambertian

% relative change and difference metrics
% https://en.wikipedia.org/wiki/Relative_change_and_difference

% similarity of the two eigenvalues
% if they are the same, they should be Lambertian; otherwise, refracted

% could use old refractive feature measure:
% sim = 1 - sqrt( (a-b)^2 / (a+b+eps)^2 );
% eps in denom to prevent inf

% alternatively, consider the:
% absolute difference of relative change
% denom: ((abs(x) + abs(y))/2 as the absolute mean of the two values -
% or use max(abs(x,y))
% numerator: absolute difference = abs(x - y)
slope_rel_diff = abs(diff(eig_val)) / ( sum(abs(eig_val))/2 ); % note: this is relative difference

% max(|x|, |y|), % useful in comparing floating point values in programming
% max(x, y),
% min(|x|, |y|),
% min (x, y),
% (x + y)/2, and
% (|x| + |y|)/2.

% alternatively, compare absolute difference:
slope_abs_diff = norm(eig_val(1) - eig_val(2),2);
EPSILON = 1e-6;
slope_norm_diff = sqrt( diff(eig_val)^2 / (eig_val(1) + eig_val(2) + EPSILON)^2 );
slope_norm_diff(slope_norm_diff<0) = 0;
            
%% compute rlff give eigenvectors, values from ED

% make a function -> computerayintersectionswithfeatureaxes
% given the eigenvalues, eigenvectors and stuv observations, find the 2 3D
% points that define the interval of sturm

[P01, P1, P02, P2] = lf_compute_interval_sturm(H,stuv0,stuv,eig_vec,eig_val,LFS.D);

rlff.error_reproj_raw = error_reproj_raw;
rlff.error_reproj_sym = error_reproj_sym;
rlff.P01 = P01;
rlff.P1 = P1;
rlff.P02 = P02;
rlff.P2 = P2;
rlff.eig_val = eig_val;
rlff.eig_vec = eig_vec;
rlff.slope_rel_diff = slope_rel_diff;
rlff.slope_abs_diff = slope_abs_diff;
rlff.slope_norm_diff = slope_norm_diff;

rlff.stuv = stuv;
% rlff.stuv_c = stuv_c;
rlff.stuv0 = stuv0;
rlff.ijkl = ijkl;
rlff.ijkl_h = ijkl_h;
rlff.st_h = st_h;
rlff.uv = uv;
rlff.H_cal = H_cal;
rlff.H = H;
rlff.H_raw = H_raw;

% P01: [3×1 double] % sturm point 1
%                 P1: [3×35 double] % line of intersecting rays from eig1
%                P02: [3×1 double] % sturm point 2
%                 P2: [3×35 double] % line of intersecting rays from eig2
%            eig_val: [2×1 double] % eigenvalues from ED
%            eig_vec: [2×2 double] % eigenvectors from ED
%     slope_rel_diff: 0.3979 % the relative difference between slopes = abs(diff(eig_val)) / ( sum(abs(eig_val))/2 );
%               stuv: [35×4 double] % all the stuv observations converted to continuous domain using H_cal
%             stuv_c: [35×4 double] % centred stuv according to stuv0 (central ray/view) before being centreed
%            stuv_c0: [0 0 0 0] % ignore
%               ijkl: [35×4 double] % "raw" ray correspondences in discrete coordinates for a given feature in the central view
%             ijkl_h: [35×5 double] % homogeneous
%               st_h: [3×35 double] % st homogeneous from stuv_c
%                 uv: [2×35 double] % uv from stuv_c
%              H_cal: [5×5 double] % intrinsic calibration matrix
%                  H: [2×3 double] % estimated astigmatic projection matrix

end