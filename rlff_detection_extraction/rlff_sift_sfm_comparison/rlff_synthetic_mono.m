function [rlff_synth_mono_LF] = rlff_synthetic_mono(LFS,rlff_lf_in,Fst_in,Dst_in,H_cal)

% following rlff_synthetic stereo, do for monocular case to show gains
% relative to monocular SfM:

nLF = size(LFS,1);

nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);
D = LFS{1}.D; % same D for all LFs

% given 3D points, define 4D plane and use plane to field 2D image features
% for SfM/Colmap:

rlff_synth_mono_LF = cell(nLF,1);
cv = [sC, tC];

for ii = 1:nLF
    
    nFtr = size(rlff_lf_in{ii},1);
    rlff_synth_mono_P01 = cell(nFtr,1);
    rlff_synth_mono_P02 = cell(nFtr,1);
    for jj = 1:nFtr
        rlff = rlff_lf_in{ii}{jj};
        rlff_rays = rlff.ijkl; % all rays in units of views/pixels
        P01 = rlff.P01;
        P02 = rlff.P02;
        
        allS = rlff_rays(:,1); % views
        allT = rlff_rays(:,2);
        idx_c =  find((sC == allS) .* (tC == allT));
        if length(idx_c) > 1
            fprintf('Warning: idx_c > 1\n');
        end
        if length(idx_c) < 1
            fprintf('Warning: idx_c < 1\n');
        end
        
        rlff_F = Fst_in{ii}{jj}; % for a given central view image feature, all image features from all sub-images
        rlff_D = Dst_in{ii}{jj}; % all feature descriptors
        fc = rlff_F(idx_c,:);
        Dc = rlff_D(idx_c,:);
        Dc_mirror = flip(Dc);
        
        [rlff_synth_mono_P01{jj}] = rlff_generate_synthetic_mono(P01,H_cal(:,:,ii),D,cv,fc,Dc);
        [rlff_synth_mono_P02{jj}] = rlff_generate_synthetic_mono(P02,H_cal(:,:,ii),D,cv,fc,Dc_mirror);
    end
    
    % save synthetic mono for each LF:
    rlff_synth_mono_LF{ii}.P01 = rlff_synth_mono_P01;
    rlff_synth_mono_LF{ii}.P02 = rlff_synth_mono_P02;
    
end