function lf_write_match_file_Colmap(path,txtName,intermatches,img1_names,varargin)
% write text file that describes the image-image matches
% for Colmap

% default_img2_names = cell(1,1);

p = inputParser;
addRequired(p,'path',@isstr);
addRequired(p,'txtName',@isstr);
addRequired(p,'intermatches',@isstruct);
addRequired(p,'img1_names',@iscell);

% addParameter(p,'img2_names',default_img2_names,@iscell);

parse(p,path,txtName,intermatches,img1_names,varargin{:});
path = p.Results.path;
txtName = p.Results.txtName;
intermatches = p.Results.intermatches;
img1_names = p.Results.img1_names;

% img2_names = p.Results.img2_names;

%%
fprintf('Writing inter-LF matches to text\n');

fName = [path '/' txtName];
fid = fopen(fName,'w');

nCombo = size(intermatches,2);
% nLF = size(img1_names,1);

for ii = 1:nCombo
    % print one image pair per line
    %     image1.jpg image2.jpg
    %     image1.jpg image3.jpg
    %     ...
    % where image1.jpg is the relative path in the image folder
    im1 = img1_names{intermatches(ii).lf1};
    im2 = img1_names{intermatches(ii).lf2};
    
    fprintf(fid,'%s %s\n',im1,im2);
    
    % matches, only print if not an outlier
    n_ftr_matches = length(intermatches(ii).uvc_outliers);
    m1 = intermatches(ii).matches_prelim(:,1);
    m2 = intermatches(ii).matches_prelim(:,2);
    for jj = 1:n_ftr_matches
        if ~intermatches(ii).is_outlier(jj)
            fprintf(fid,'%g %g\n',m1(jj)-1,m2(jj)-1);
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);

% expected format:
% image1.jpg image2.jpg
% 0 1
% 1 2
% 3 4
% <empty-line>
% image1.jpg image3.jpg
% 0 1
% 1 2
% 3 4
% 4 5
% <empty-line>
% ...