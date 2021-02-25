function m_write_file(txtFileContents,filepath)
% function m_write_file writes txtFileContents to file defined by filepath
fid = fopen(filepath,'w');
for i = 1:numel(txtFileContents)
    if (txtFileContents{i+1} == -1)
        fprintf(fid,'%s',txtFileContents{i});
        break
    else
        fprintf(fid,'%s\n',txtFileContents{i});
    end
end
fclose(fid);