function [fileNames] = getFilenamesInFolder(folderName,stringEndPattern)

folderContents = dir(folderName);
[nContents,~] = size(folderContents);

nStrEndPattern = length(stringEndPattern)-1;

% for MAC:
% assuming that the first two items are "." and "..", the rest are relevant 
% nImgExpected = round((nContents-2)/3);

fileNames = cell(1,1); % for the . and .. files
count = 0;
for i = 3:nContents
    if (length(folderContents(i).name) > (nStrEndPattern+1)) && ...
            strcmp(folderContents(i).name(end-nStrEndPattern:end),stringEndPattern)
        count = count+1;
        fileNames{count} = folderContents(i).name;
    end
end