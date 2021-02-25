function [rlff_lf2,ray_ftrs2,ray_ftr_descrs2,Fc2,Dcr2,Dcs2,Fst2,Dst2] = lf_remove_rejected_rlff(rlff_lf,ray_ftrs,ray_ftr_descrs,Fc,Dc_root,Dc_sift,F_st,Dst)
% remove rejected features (based on reprojection error) from all
% feature structures: rlff_lf, ray_ftrs,Fc,Dc
% if rlff_lf{ii}{jj}.isoutlier == true, get rid of this
nLF = size(rlff_lf,1);


rlff_lf2 = cell(nLF,1);
ray_ftrs2 = cell(nLF,1);
ray_ftr_descrs2 = cell(nLF,1);
Fc2 = cell(nLF,1);
Dcr2 = cell(nLF,1);
Dcs2 = cell(nLF,1);
Fst2 = cell(nLF,1);
Dst2 = cell(nLF,1);

for ii = 1:nLF
    % number of features in the central view of the given LF
    nFtrC = size(rlff_lf{ii},1);
    
    % for each feature, if outlier, don't add; otherwise add
    cnt = 0;
    for jj = 1:nFtrC
        if rlff_lf{ii}{jj}.isoutlier == false
            cnt = cnt+1;
            rlff_lf2{ii}{cnt} = rlff_lf{ii}{jj};
            ray_ftrs2{ii}{cnt} = ray_ftrs{ii}{jj};
            ray_ftr_descrs2{ii}{cnt} = ray_ftr_descrs{ii}{jj};
            Fc2{ii} = cat(1,Fc2{ii},Fc{ii}(jj,:));
            Dcr2{ii} = cat(1,Dcr2{ii},Dc_root{ii}(jj,:));
            Dcs2{ii} = cat(1,Dcs2{ii},Dc_sift{ii}(jj,:));
            Fst2{ii}{cnt} = F_st{ii}{jj};
            Dst2{ii}{cnt} = Dst{ii}{jj};
        end
    end
    rlff_lf2{ii} = rlff_lf2{ii}';
end



end