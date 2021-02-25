function [img_left_names, img_right_names,colmap_img_matches_filename] = sfm_write_sift_stereo_colmap(LFS,sift_stereo_intermatches,colmap_sift_stereo_folder,F_sift_stereo,D_sift_stereo,stStereo)
% function writes sift stereo to text files and image files for Colmap

%% internal parameters


nLF = size(LFS,1);
nCombo = size(sift_stereo_intermatches,2);

ftrLength = 4; % sift feature length
descrLength = 128; % sift descriptor length

save_img_location = [colmap_sift_stereo_folder '/images'];
mkdir(save_img_location);


%% export features, descriptors, images to text/png


img_left_names = cell(nLF,1);
img_right_names = cell(nLF,1);
% for each LF frame (nLF)
% compile features and descriptors and images, write to
% colmap_sift_stereo_folder
for ii = 1:nLF
    % for left image
%     nFtrLeft = size(F_sift_stereo{ii}.left,2);


%        siftStereo_left_str = ['_rlffSter_(' num2str(stStereo(1,1)) ',' num2str(stStereo(1,2)) ')']; % left
%     siftStereo_right_str = ['_rlffSter_(' num2str(stStereo(2,1)) ',' num2str(stStereo(2,2)) ')']; % right

    left = 1;
    right = 2;
    IM_left = squeeze(LFS{ii}.LF(stStereo(left,2),stStereo(left,1),:,:,1:3));
    IM_right = squeeze(LFS{ii}.LF(stStereo(right,1),stStereo(right,2),:,:,1:3));

    img_left_names{ii} = [LFS{ii}.LFName '_left.png'];
    img_right_names{ii} = [LFS{ii}.LFName '_right.png'];
    
    % save stereo image pairs
    imwrite(IM_left,[save_img_location '/' img_left_names{ii}],'BitDepth',8,'Mode','lossless','Author','Dorian Tsai');
    imwrite(IM_right,[save_img_location '/' img_right_names{ii}],'BitDepth',8,'Mode','lossless','Author','Dorian Tsai');
    
    % write features to text file w matching name to image name for Colmap
    lf_write_features_Colmap(save_img_location, img_left_names{ii},F_sift_stereo{ii}.left',D_sift_stereo{ii}.left'); % note: sending in SIFT descriptors, instead of rootsift descriptors
    lf_write_features_Colmap(save_img_location, img_right_names{ii},F_sift_stereo{ii}.right',D_sift_stereo{ii}.right');
    
end

%% export feature matches to txt

colmap_img_matches_filename = 'colmap_image_matches_sift_stereo.txt';
filename = [colmap_sift_stereo_folder '/' colmap_img_matches_filename];
fid = fopen(filename,'w');

% for each lfcombo, 
% write matches to text file
for ii = 1:nCombo
    frame1 = sift_stereo_intermatches(ii).f1;
    frame2 = sift_stereo_intermatches(ii).f2;
    
    
    % write matches for f1l_f1r
    m1 = sift_stereo_intermatches(ii).f1l_f1r(:,1);
    m2 = sift_stereo_intermatches(ii).f1l_f1r(:,2);
    nFtr  = size(m1,1);
    fprintf(fid,'%s %s\n',img_left_names{frame1},img_right_names{frame1});
    for jj = 1:nFtr
        fprintf(fid,'%g %g\n',m1(jj)-1, m2(jj)-1);
    end
    fprintf(fid,'\n');
    
    % write matches for f1l_f2l
    m1 = sift_stereo_intermatches(ii).f1l_f2l(:,1);
    m2 = sift_stereo_intermatches(ii).f1l_f2l(:,2);
    nFtr  = size(m1,1);
    fprintf(fid,'%s %s\n',img_left_names{frame1},img_left_names{frame2});
    for jj = 1:nFtr
        fprintf(fid,'%g %g\n',m1(jj)-1, m2(jj)-1);
    end
    fprintf(fid,'\n');
    
    % write matches for f1r_f2l
    m1 = sift_stereo_intermatches(ii).f1r_f2l(:,1);
    m2 = sift_stereo_intermatches(ii).f1r_f2l(:,2);
    nFtr  = size(m1,1);
    fprintf(fid,'%s %s\n',img_right_names{frame1},img_left_names{frame2});
    for jj = 1:nFtr
        fprintf(fid,'%g %g\n',m1(jj)-1, m2(jj)-1);
    end
    fprintf(fid,'\n');
    
    % write matches for f1r_f2r
    m1 = sift_stereo_intermatches(ii).f1r_f2r(:,1);
    m2 = sift_stereo_intermatches(ii).f1r_f2r(:,2);
    nFtr  = size(m1,1);
    fprintf(fid,'%s %s\n',img_right_names{frame1},img_right_names{frame2});
    for jj = 1:nFtr
        fprintf(fid,'%g %g\n',m1(jj)-1, m2(jj)-1);
    end
    fprintf(fid,'\n');
    
end

fclose(fid);

