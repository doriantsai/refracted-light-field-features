function [img_names,colmap_img_matches_filename] = sfm_write_sift_mono_colmap(LFS,sift_mono_intermatches,colmap_folder,Fc,Dc)
% sfm_write_sift_mono_colmap writes the image features and image files from the
% central view of the LF to the colmap folder for monocular SfM comparison

% export feature files to run in Colmap
% note that since Colmap does not accept rootsift, we have to give normal
% sift descriptors

fprintf('Exporting centre-view feature files and central views of LFs to do 2D SIFT monocular SfM using Colmap\n');

nLF = size(LFS,1);
nCombo = size(sift_mono_intermatches,2);
nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);

img_names = cell(nLF,1);

save_img_location = [colmap_folder '/images'];
mkdir(save_img_location);

for ii = 1:nLF
    IM = squeeze(LFS{ii}.LF(tC,sC,:,:,1:3));
    img_names{ii} = [LFS{ii}.LFName '.png'];
    
    imwrite(IM,[save_img_location '/' img_names{ii}],'BitDepth',8,'Mode','lossless','Author','Dorian Tsai');
    
    % write features to text file w matching name to image name for Colmap
    lf_write_features_Colmap(save_img_location, img_names{ii},Fc{ii},Dc{ii}); % note: sending in SIFT descriptors, instead of rootsift descriptors
end

% export inter-LF matches to Colmap
fprintf('Exporting inter-LF matches to Colmap\n');
% first, we create the matches text file
colmap_img_matches_filename = 'colmap_image_matches_sift_mono.txt';
% lf_write_match_file_Colmap(colmap_folder,colmap_img_matches_filename,sift_mono_intermatches,img_names)

filename = [colmap_folder '/' colmap_img_matches_filename];
fid = fopen(filename, 'w');

for ii = 1:nCombo
    frame1 = sift_mono_intermatches(ii).f1;
    frame2 = sift_mono_intermatches(ii).f2;
    
    % write matches for f1_f2:
    m1 = sift_mono_intermatches(ii).f1_f2(:,1);
    m2 = sift_mono_intermatches(ii).f1_f2(:,2);
    nFtr = size(m1, 1);
    fprintf(fid, '%s %s\n', img_names{frame1}, img_names{frame2});
    for jj = 1:nFtr
        fprintf(fid,'%g %g\n',m1(jj)-1, m2(jj)-1);
    end
    fprintf(fid,'\n');
    
end

fclose(fid);






end