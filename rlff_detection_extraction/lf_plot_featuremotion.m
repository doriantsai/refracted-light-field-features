% after running lf_process_experimental_results
% load case name - just has the sfm data in it. Need RLFF data/RLFF feature
% info...
% goal is to generate the 
% percent refracted features
% histogram of LF sequences (what order?)
% cumulative histogram (0 - 100)?
% clearvars

addpath('Support_Functions');

FIG = 1;  % figure number

casefolder = 'Output/';
% casename = '201007_permissive_sparse.mat'
% casename = '201007_default_sparse.mat'
casename = '201201d_default_sparse.mat'

casefilename = [casefolder, casename];
C = load(casefilename);

datafolder = '~/Data/';

% grab each exp_name in feature folder:
% find relevant experiment folders:
SearchOptions.IncludeRecursion = false;
SearchOptions.Verbose = false;
SearchOptions.ReportFolders = true;
exp_folders = LFFindFilesRecursive(datafolder,'2020*-*_rlff*',[], SearchOptions);

nexp = length(exp_folders);

nexp = 20
rlff = cell(nexp,1);

%% get feature data from rlff methods

tic
for nn = 2 % 18 % 1:nexp
    exp_name = exp_folders{nn};
    
    fprintf('Exp %g: %s\n', nn, exp_name);
    
    % expected filename (check/make sure exists)
    outfolder = [datafolder, exp_folders{nn}];
    SearchOptions.IncludeRecursion = false;
    SearchOptions.Verbose = false;
    SearchOptions.ReportFolders = false;
    outname = LFFindFilesRecursive(outfolder,'2020*-*_rlff*.mat',[], SearchOptions);
    % assume only one:
    if (size(outname, 1) > 1) || (size(outname, 2) > 1)
        disp('Error: outname size > 1, more than one outname.mat?')
    end
   
    outfilename = [outfolder, '/', outname{1}];
    
    fprintf('outname: %s\n', outfilename);
    if isfile(outfilename)
        % load out:
        out = load(outfilename);
        
        % for now, we just want to set is refracted property:
%         rlff{nn} = out.rlff_lf_in;
        
        % clear out, due to memory limitations:
%         clear out
        
    else
        disp('Error: outname does not exist');
    end
end
toc

%% do the plot

LFS = out.LFS;
stStereo = out.stStereo;
artStereo_LF = out.rlff_synth_stereo_LF;
rlff_lf_in = out.rlff_lf_in;
Fst_in = out.Fst_in;
lf_intermatches = out.lf_intermatches;
Fc_in = out.Fc_in;

% try probably just remove outliers for illustration purposes?

frame1 = 3;
frame2 = 6;
lf_plotfig_vertical_feature_motion(LFS,stStereo,artStereo_LF,rlff_lf_in,Fst_in,lf_intermatches,Fc_in, frame1, frame2)


    