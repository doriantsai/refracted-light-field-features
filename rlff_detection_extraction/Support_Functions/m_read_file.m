function [txtFileContents] = m_read_file(filepath)
% function m_read_file reads a filename given by filepath and returns a
% cell structure of all the text file contents
fid = fopen(filepath,'r');
cnt=1;
tline = fgetl(fid);
txtFileContents{cnt} = tline;
while ischar(tline)
    cnt=cnt+1;
    tline = fgetl(fid);
    txtFileContents{cnt} = tline;
end
fclose(fid);