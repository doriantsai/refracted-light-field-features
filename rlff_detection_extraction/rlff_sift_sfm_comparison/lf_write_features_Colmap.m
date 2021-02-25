function lf_write_features_Colmap(path, imName,Fc,Dc)
% adapted from lffeatures' function writeFeaturesToColMap

% takes list of matlab surf features, image name,
% and writes them to colmap textfile:
% file name must match file text:
%   /path/to/image.jpg with /path/to/image.jpg.txt

% format:

% ftrDescriptors
% ftrPts = ftrSurf;

% fprintf('Writing features to text\n');

% path = cd;
% imName = 'test.jpg';
fName = [path '/' imName '.txt'];

fid = fopen(fName, 'w'); % w - write to file, discard existing contents, if any
% check for valid fid?

nFtr = size(Fc,1);
nFtrDim = 128; % SIFT descriptor length

fprintf(fid,'%d %d\n',nFtr,nFtrDim);
for i = 1:nFtr
    % ftrLoc = Fc(i,1:2); % u v
    % X Y Scale Orientation D_1 D_2 ..... D_128
    fprintf(fid,'%8.4f %8.4f %6.4f %5.4f ',...
        Fc(i,1),Fc(i,2),Fc(i,3),Fc(i,4));
    for j = 1:nFtrDim
        fprintf(fid,'%g ',Dc(i,j));
        
    end
%     if j == nFtrDim
            fprintf(fid,'\n');
%         end
end
fclose(fid);    



