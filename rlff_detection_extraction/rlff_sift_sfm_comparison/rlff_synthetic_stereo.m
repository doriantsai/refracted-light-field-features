function [rlffSynthStereo_LF,stStereo] = rlff_synthetic_stereo(LFS,rlff_lf_in,Fst_in,Dst_in,H_cal,stStereo)
% inputs: LFS,
% for details, see lf_artificial_stereo_post_inter_match.m

% for each LF
% for every RLFF inside each LF
% set stStereo
% compute artificial stereo for each pt


nLF = size(LFS,1);

nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);
D = LFS{1}.D; % same D for all LFs




%% new approach - given 3D point(s), define 4D plane(s), use plane(s) to yield
% more consistent features/views

rlffSynthStereo_LF = cell(nLF,1);

for ii = 1:nLF
    nFtr = size(rlff_lf_in{ii},1);
    rlff_synth_stereo_P01 = cell(nFtr,1);
    rlff_synth_stereo_P02 = cell(nFtr,1);
    for jj = 1:nFtr
        rlff = rlff_lf_in{ii}{jj};
        rlff_rays = rlff.ijkl; % all rays in units of views/pixels
        P01 = rlff.P01;
        P02 = rlff.P02;
        % for P01, define 4D plane:
        %         M = [D/P01(3) 0 1 0;
        %             0 D/P01(3) 0 1];
        %         M0 = [D*P01(1)/P0(3);
        %             D*P01(2)/P0(3)];
        
        % convert stStereo (st) in discrete units
        %         [uv1] = lf_4D_plane(P01,D,stStereo(1,:));
        %
        %         [uv2] = lf_4D_plane(P02,D,stStereo(2,:));
        % find central view
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
        
        [rlff_synth_stereo_P01{jj}] = rlff_generate_synthetic_stereo_pairs(P01,H_cal(:,:,ii),D,stStereo,fc,Dc);
        [rlff_synth_stereo_P02{jj}] = rlff_generate_synthetic_stereo_pairs(P02,H_cal(:,:,ii),D,stStereo,fc,Dc_mirror);
        
        clear idx_c
    end
    
    % save artificial stereo for each LF:
    rlffSynthStereo_LF{ii}.P01 = rlff_synth_stereo_P01;
    rlffSynthStereo_LF{ii}.P02 = rlff_synth_stereo_P02;
end


%% old approach - find/make new if doesn't exist
% for ii = 1:nLF
%
%     nFtr = size(rlff_lf_in{ii},1);
%
%     artStereo_P01 = cell(nFtr,1);
%     artStereo_P02 = cell(nFtr,1);
%
%     for jj = 1:nFtr
%         rlff = rlff_lf_in{ii}{jj};
%         rlff_rays = rlff.ijkl; % all rays in units of views/pixels
%         P01 = rlff.P01;
%         P02 = rlff.P02;
%         rlff_F = Fst_in{ii}{jj}; % all features
%         rlff_D = Dst_in{ii}{jj}; % all feature descriptors
%         s = rlff_rays(:,1); % views
%         t = rlff_rays(:,2);
%
%         % find stereo pair indices, feature and descriptor
%         [idx1,~,f1,~,Dst1,~] = find_stereo_pair(s,t,stStereo,rlff_F,rlff_D);
%
%         % find central view
%         idx_c =  find((sC == s) .* (tC == t));
%         fc = rlff_F(idx_c,:);
%         Dc = rlff_D(idx_c,:);
%
%         % run artificial stereo for P01
%         [artStereo_P01{jj}] = generate_artificial_stereo(P01,...
%             H_cal(:,:,ii),...
%             D, stStereo,...
%             fc,Dc,...
%             f1,Dst1, jj);
%
%         % for P02
%         [artStereo_P02{jj}] = generate_artificial_stereo(P02,...
%             H_cal(:,:,ii),...
%             D, stStereo,...
%             fc,Dc,...
%             f1,Dst1, jj);
%     end
%
%     % save artificial stereo for each LF:
%     artStereo_LF{ii}.P01 = artStereo_P01;
%     artStereo_LF{ii}.P02 = artStereo_P02;
%
% end