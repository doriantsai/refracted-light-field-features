function [img1_names,img2_names,Fstereo1,Fstereo2,colmap_img_matches_filename] = sfm_write_rlff_stereo_colmap(LFS,lf_intermatches,rlffSynthStereo_LF,colmap_folder,stStereo)
% code to write artificial stereo to text files and image files for Colmap

% 1) Colmap needs the images
% 2) Colmap needs a list of the features for each image
% 3) Colmap needs an exhaustive match of the features between each image
% pair

% input: artStereo_LF, lf_intermatches, LFS

%% load defaults

%% parse inputs


%% internal parameters
% nS = LFS{1}.SSize;
% nT = LFS{1}.TSize;
% nU = LFS{1}.USize;
% nV = LFS{1}.VSize;
% sC = round(nS/2);
% tC = round(nT/2);

nLF = size(LFS,1);
nCombo = size(lf_intermatches,2);

%% compile Fst and Dst from artificial stereo

% for each feature in lfmatches
% for both F1_P01 and F1_P02
% save to Fst and Dst
% while keeping track of the indices, because these will correspond to
% the matches later on


% update:
% 1) for combo, run through then and make a list of all the features that are
% matched for each and every LF individually

% 2) for each

Fstereo1 = cell(nLF,1);
Dstereo1 = cell(nLF,1);
Fstereo2 = cell(nLF,1);
Dstereo2 = cell(nLF,1);
idx_stereo1 = cell(nLF,1);
idx_stereo2 = cell(nLF,2);

n2DPtsPerFtr = 2; % 2 3D points per feature
ftrLength = 4; % sift feature length
descrLength = 128; % sift descriptor length


%% export features and descriptors, images to text/png

% for each LF, compile list of features and descriptors for each artificial stereo
% image
for ii = 1:nLF
    nFtr = size(rlffSynthStereo_LF{ii}.P01,1);
    nFtrExport = n2DPtsPerFtr*nFtr;
    Fstereo1{ii} = nan(nFtrExport,ftrLength);
    Dstereo1{ii} = nan(nFtrExport,descrLength);
    Fstereo2{ii} = nan(nFtrExport,ftrLength);
    Dstereo2{ii} = nan(nFtrExport,descrLength);
    idx_stereo1{ii} = nan(nFtrExport,1);
    idx_stereo2{ii} = nan(nFtrExport,1);
    
    cnt_idx = 0;
    for jj = 1:nFtr
        cnt_idx = cnt_idx+1;
        % first point P01
        Fstereo1{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P01{jj}.f1;
        Dstereo1{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P01{jj}.D1_sift;
        idx_stereo1{ii}(cnt_idx) = cnt_idx;
        
        Fstereo2{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P01{jj}.f2;
        Dstereo2{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P01{jj}.D2_sift;
        idx_stereo2{ii}(cnt_idx) = cnt_idx;
        
        % second point P02
        cnt_idx = cnt_idx+1;
        Fstereo1{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P02{jj}.f1;
        Dstereo1{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P02{jj}.D1_sift;
        idx_stereo1{ii}(cnt_idx) = cnt_idx;
        
        Fstereo2{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P02{jj}.f2;
        Dstereo2{ii}(cnt_idx,:) = rlffSynthStereo_LF{ii}.P02{jj}.D2_sift;
        idx_stereo2{ii}(cnt_idx) = cnt_idx;
    end
end

% can now write Fstereo1, Fstereo2, Dstereo1, Dstereo2 and img_names1 and 2
% to file

fprintf('Exporting feature files and central views of LFs for Colmap\n');
% img_names = cell(nLF,1);
save_img_location = [colmap_folder '/images'];
mkdir(save_img_location);


img1_names = cell(nLF,1);
img2_names = cell(nLF,1);

for ii=1:nLF
    %     frame1 = lf_intermatches(ii).lf1;
    %     frame2 = lf_intermatches(ii).lf2;
    % t1, s1 - first stereo pair
    % t2, s2 - second stereo pair
    % the issue is that with the find_st_max_distance function, I will have
    % so many pairs of images being stored, which could get big/cumbersome
    % fast.
    % I can't directly just use a set st pair because I don't necessarily
    % have features/descriptors from the appropriate sub-image. I know that
    % I have said feature for the centre view, so could I simply
    % approximate the Fst with a Lambertian assumption?
    
    IM1 = squeeze(LFS{ii}.LF(stStereo(1,2),stStereo(1,1),:,:,1:3));
    IM2 = squeeze(LFS{ii}.LF(stStereo(2,1),stStereo(2,2),:,:,1:3));
    
    % opt for overwriting image files, as opposed to making new ones, if
    % parameters/stStereo settings change
    rlffSynthStereo1_str = ['_rlffSter_(' num2str(stStereo(1,1)) ',' num2str(stStereo(1,2)) ')']; % left
    rlffSynthStereo2_str = ['_rlffSter_(' num2str(stStereo(2,1)) ',' num2str(stStereo(2,2)) ')']; % right
    
    img1_names{ii} = [LFS{ii}.LFName '_left' '.png']; % in subsequent iterations, this gets overwritten
    img2_names{ii} = [LFS{ii}.LFName '_right' '.png'];
    
    % save stereo image pairs
    imwrite(IM1,[save_img_location '/' img1_names{ii}],'BitDepth',8,'Mode','lossless','Author','Dorian Tsai');
    imwrite(IM2,[save_img_location '/' img2_names{ii}],'BitDepth',8,'Mode','lossless','Author','Dorian Tsai');
    
    % write features to text file w matching name to image name for Colmap
    lf_write_features_Colmap(save_img_location, img1_names{ii},Fstereo1{ii},Dstereo1{ii}); % note: sending in SIFT descriptors, instead of rootsift descriptors
    lf_write_features_Colmap(save_img_location, img2_names{ii},Fstereo2{ii},Dstereo2{ii});
end


%% export feature matches (inter-LF)

% all to the same file!!

fprintf('Exporting stereo intra-LF matches to Colmap (soft enforcement of stereo triangulation)\n');
% first, we create the matches text file
colmap_img_matches_filename = 'colmap_image_matches_rlff_stereo.txt';

filename = [colmap_folder '/' colmap_img_matches_filename];
fid = fopen(filename,'w');
% first, we take care of stereo matches:
% stereo_intermatches
% for nLF: Fstereo1{ii} -> Fstereo2{ii}
for ii = 1:nLF
    fprintf(fid,'%s %s\n',img1_names{ii},img2_names{ii});
    
    nFtrIntramatch = size(Fstereo1{ii},1);
    for jj = 1:nFtrIntramatch
        fprintf(fid,'%g %g\n',idx_stereo1{ii}(jj)-1, idx_stereo2{ii}(jj)-1);
    end
    fprintf(fid,'\n');
end
% fclose(fid);

%%

fprintf('Exporting stereo inter-LF matches to Colmap\n');
% then, we take care of inter-LF matches:
for ii = 1:nCombo
    
    frame1 = lf_intermatches(ii).lf1;
    frame2 = lf_intermatches(ii).lf2;
    m1 = lf_intermatches(ii).matches_prelim(:,1);
    m2 = lf_intermatches(ii).matches_prelim(:,2);
    
    % note: Colmap is zero-indexed, so actually, it should be -2 and -1,
    % rather than -1 and -0!
    idx_m1_to_rlffSynthStereo1 = m1*2 - 1; % f1, P01 on frame1
    idx_m1_to_rlffSynthStereo2 = m1*2; % f1, P02 on frame1
    idx_m2_to_rlffSynthStereo1 = m2*2 - 1; % f1, P01 on frame2
    idx_m2_to_rlffSynthStereo2 = m2*2; % f1, P02 on frame2
    
    nFtrMatched = size(m1,1);
    % for nCombo: Fstereo1{frame1} -> Fstereo1{frame2}, as well as
    fprintf(fid,'%s %s\n',img1_names{frame1},img1_names{frame2});
    idx_in = false(nFtrMatched,1);
    for jj = 1:nFtrMatched
        % if not an outlier, then print
        if ~lf_intermatches(ii).is_outlier(jj)
            % should just be a 1:2 mapping, so we just x2(-1?) all the indices,
            % and we should be good
            
            % -1 because of zero-indexing of Colmap
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo1(jj)-1, idx_m2_to_rlffSynthStereo1(jj)-1);
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo2(jj)-1, idx_m2_to_rlffSynthStereo2(jj)-1);
            idx_in(jj) = true;
        end
    end
    fprintf(fid,'\n');
    % in order to check this is the correct set of matches, print a figure
    % here
    DEBUG = false;
    if DEBUG
        IM1 = squeeze(LFS{frame1}.LF(stStereo(1,2),stStereo(1,1),:,:,1:3));
        IM2 = squeeze(LFS{frame2}.LF(stStereo(1,2),stStereo(1,1),:,:,1:3));
       figure; showMatchedFeatures(IM1,IM2,Fstereo1{frame1}(idx_m1_to_rlffSynthStereo1(idx_in==true),1:2),Fstereo1{frame2}(idx_m2_to_rlffSynthStereo1(idx_in==true),1:2));
       figure; showMatchedFeatures(IM1,IM2,Fstereo1{frame1}(idx_m1_to_rlffSynthStereo2(idx_in==true),1:2),Fstereo1{frame2}(idx_m2_to_rlffSynthStereo2(idx_in==true),1:2));
    end

    % for nCombo: Fstereo2{frame1} -> Fstereo2{frame2}
    fprintf(fid,'%s %s\n',img2_names{frame1},img2_names{frame2});
    idx_in = false(nFtrMatched,1);
    for jj = 1:nFtrMatched
        % if not an outlier, then print
        if ~lf_intermatches(ii).is_outlier(jj)
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo1(jj)-1, idx_m2_to_rlffSynthStereo1(jj)-1);
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo2(jj)-1, idx_m2_to_rlffSynthStereo2(jj)-1);
            idx_in(jj) = true;
        end
    end
    fprintf(fid,'\n');
    
    DEBUG = false;
    if DEBUG
        IM1 = squeeze(LFS{frame1}.LF(stStereo(2,2),stStereo(2,1),:,:,1:3));
        IM2 = squeeze(LFS{frame2}.LF(stStereo(2,2),stStereo(2,1),:,:,1:3));
       figure; showMatchedFeatures(IM1,IM2,Fstereo2{frame1}(idx_m1_to_rlffSynthStereo1(idx_in==true),1:2),Fstereo2{frame2}(idx_m2_to_rlffSynthStereo1(idx_in==true),1:2));
       figure; showMatchedFeatures(IM1,IM2,Fstereo2{frame1}(idx_m1_to_rlffSynthStereo2(idx_in==true),1:2),Fstereo2{frame2}(idx_m2_to_rlffSynthStereo2(idx_in==true),1:2));
    end
    
    % for nCombo: Fstereo1{frame1} -> Fstereo2{frame2}
    fprintf(fid,'%s %s\n',img1_names{frame1},img2_names{frame2});
    for jj = 1:nFtrMatched
        % if not an outlier, then print
        if ~lf_intermatches(ii).is_outlier(jj)
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo1(jj)-1, idx_m2_to_rlffSynthStereo1(jj)-1);
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo2(jj)-1, idx_m2_to_rlffSynthStereo2(jj)-1);
        end
    end
    fprintf(fid,'\n');
    DEBUG = false;
    if DEBUG
        IM1 = squeeze(LFS{frame1}.LF(stStereo(1,2),stStereo(1,1),:,:,1:3));
        IM2 = squeeze(LFS{frame2}.LF(stStereo(2,2),stStereo(2,1),:,:,1:3));
       figure; showMatchedFeatures(IM1,IM2,Fstereo1{frame1}(idx_m1_to_rlffSynthStereo1(idx_in==true),1:2),Fstereo2{frame2}(idx_m2_to_rlffSynthStereo1(idx_in==true),1:2));
       figure; showMatchedFeatures(IM1,IM2,Fstereo1{frame1}(idx_m1_to_rlffSynthStereo2(idx_in==true),1:2),Fstereo2{frame2}(idx_m2_to_rlffSynthStereo2(idx_in==true),1:2));
    end
    
    % for nCombo: Fstereo2{frame1} -> Fstereo1{frame2}
    fprintf(fid,'%s %s\n',img2_names{frame1},img1_names{frame2});
    for jj = 1:nFtrMatched
        % if not an outlier, then print
        if ~lf_intermatches(ii).is_outlier(jj)
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo1(jj)-1, idx_m2_to_rlffSynthStereo1(jj)-1);
            fprintf(fid,'%g %g\n',idx_m1_to_rlffSynthStereo2(jj)-1, idx_m2_to_rlffSynthStereo2(jj)-1);
        end
    end
    fprintf(fid,'\n');
    DEBUG = false;
    if DEBUG
        IM1 = squeeze(LFS{frame1}.LF(stStereo(2,2),stStereo(2,1),:,:,1:3));
        IM2 = squeeze(LFS{frame2}.LF(stStereo(1,2),stStereo(1,1),:,:,1:3));
       figure; showMatchedFeatures(IM1,IM2,Fstereo2{frame1}(idx_m1_to_rlffSynthStereo1(idx_in==true),1:2),Fstereo1{frame2}(idx_m2_to_rlffSynthStereo1(idx_in==true),1:2));
       figure; showMatchedFeatures(IM1,IM2,Fstereo2{frame1}(idx_m1_to_rlffSynthStereo2(idx_in==true),1:2),Fstereo1{frame2}(idx_m2_to_rlffSynthStereo2(idx_in==true),1:2));
    end
end

fclose(fid);












