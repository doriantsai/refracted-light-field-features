function [img_names,colmap_img_matches_filename] = sfm_write_rlff_mono_colmap(LFS,lf_intermatches,colmap_rlff_mono_folder,rlff_synth_mono_LF)

nLF = size(LFS,1);
nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);

nCombo = size(lf_intermatches,2);

n2DPtsPerFtr = 2; % 2 3D points per feature
ftrLength = 4; % sift feature length
descrLength = 128; % sift descriptor length


img_names = cell(nLF,1);

save_img_location = [colmap_rlff_mono_folder '/images'];
mkdir(save_img_location);



% rlff_synth_mono_LF

%% package features and descriptors into a single array with known indices:

% I suppose, shouldn't it be possible to just print them one at a time?

for ii = 1:nLF
   nFtr = size(rlff_synth_mono_LF{ii}.P01,1);
   nFtrExport = n2DPtsPerFtr * nFtr;
   
   F_rlff_mono{ii} = nan(nFtrExport,ftrLength);
   D_rlff_mono{ii} = nan(nFtrExport,descrLength);
%    F_rlff_mono2{ii} = nan(nFtrExport,ftrLength);
%    D_rlff_mono2{ii} = nan(nFtrExport,ftrLength);
   idx_rlff_mono{ii} = nan(nFtrExport,1);
%    idx_rlff_mono2{ii} = nan(nFtrExport,1);
   
   cnt_idx = 0;
   for jj = 1:nFtr
              
       % first point: (P01)
       cnt_idx = cnt_idx + 1;
       F_rlff_mono{ii}(cnt_idx,:) = rlff_synth_mono_LF{ii}.P01{jj}.f;
       D_rlff_mono{ii}(cnt_idx,:) = rlff_synth_mono_LF{ii}.P01{jj}.D_sift;
       idx_rlff_mono{ii} = cnt_idx;
       
       % second pooint (P02)
       cnt_idx = cnt_idx+1;
       F_rlff_mono{ii}(cnt_idx,:) = rlff_synth_mono_LF{ii}.P02{jj}.f;
       D_rlff_mono{ii}(cnt_idx,:) = rlff_synth_mono_LF{ii}.P02{jj}.D_sift;
       idx_rlff_mono{ii} = cnt_idx;
       
   end
end


%% write features and images to file:

fprintf('Exporting feature files and central views of LFs for Colmap\n');

for ii = 1:nLF
    IM = squeeze(LFS{ii}.LF(tC,sC,:,:,1:3));
      img_names{ii} = [LFS{ii}.LFName '.png'];
    
    imwrite(IM,[save_img_location '/' img_names{ii}],'BitDepth',8,'Mode','lossless','Author','Dorian Tsai');
    
     % write features to text file w matching name to image name for Colmap
    lf_write_features_Colmap(save_img_location, img_names{ii},F_rlff_mono{ii},D_rlff_mono{ii}); % note: sending in SIFT descriptors, instead of rootsift descriptors
end


%% write matches to text file:


% fprintf('Exporting stereo intra-LF matches to Colmap (soft enforcement of stereo triangulation)\n');

% first, we create the matches text file
colmap_img_matches_filename = 'colmap_image_matches_rlff_mono.txt';

filename = [colmap_rlff_mono_folder '/' colmap_img_matches_filename];
fid = fopen(filename,'w');

% for ii = 1:nLF
%     fprintf(fid,'%s %s\n',img_names{ii},img_names{ii});
%     
%     nFtrIntramatch = size(F_rlff_mono{ii},1);
%     for jj = 1:nFtrIntramatch
%         fprintf(fid,'%g %g\n',idx_rlff_mono{ii}(jj)-1, idx_rlff_mono{ii}(jj));
%     end
%     fprintf(fid,'\n');
% end

fprintf('Exporting stereo inter-LF matches to Colmap\n');
% for each lfcombination in lf_intermatches
for ii = 1:nCombo
    frame1 = lf_intermatches(ii).lf1;
    frame2 = lf_intermatches(ii).lf2;
    m1 = lf_intermatches(ii).matches_prelim(:,1);
    m2 = lf_intermatches(ii).matches_prelim(:,2);
    
    % Colmap is zero-indexed:
    idx_m1_to_rlffSynthMono1 = m1*2 - 1; % f1, P01 on frame1
    idx_m1_to_rlffSynthMono2 = m1*2; % f1, P02 on frame1
    idx_m2_to_rlffSynthMono1 = m2*2 - 1; % f1, P01 on frame2
    idx_m2_to_rlffSynthMono2 = m2*2; % f1, P02 on frame2
    
    nFtrMatched = size(m1,1);
    
    % write matches for P01:
     fprintf(fid,'%s %s\n',img_names{frame1},img_names{frame2});
%      idx_in = false(nFtrMatched,1);
     for jj = 1:nFtrMatched
         if ~lf_intermatches(ii).is_outlier(jj)
             fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthMono1(jj)-1, idx_m2_to_rlffSynthMono1(jj)-1);
             fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthMono2(jj)-1, idx_m2_to_rlffSynthMono2(jj)-1);
%              idx_in(jj) = true;
         end
     end
     
     % write matches for P02:
%      fprintf(fid,'%s %s\n',img_names{frame1},img_names{frame2});
%      idx_in = false(nFtrMatched,1);
%      for jj = 1:nFtrMatched
%          if ~lf_intermatches(ii).is_outlier(jj)
%              
% %              idx_in(jj) = true;
%          end
%      end
     
     fprintf(fid,'\n');
    
end

fclose(fid);


