% write new code that processes lf_refractiveFeatures_lytro.m for all
% experiments - all folders - found within given folder:

% use LFFindFilesRecursive to string-match relevant folders within the Data
% folder

% iterate over this forloop



clearvars

addpath('Support_Functions/');
formatOut = 'yymmdd'; % format for filenames (txt/fig) saved
now_str = datestr(datetime('now'),formatOut);

%% parameters

% where data is
main_folder = '~/Data';
% where to store data


% settings:
LOAD_ALL = true; % set true if features have already been extracted, and we just want to rerun the matching (progress has been saved as .mat files)


tStart = tic;

% find relevant experiment folders:
SearchOptions.IncludeRecursion = false;
SearchOptions.Verbose = false;
SearchOptions.ReportFolders = true;
exp_folders = LFFindFilesRecursive(main_folder,'2020*-*_rlff*',[], SearchOptions);

nexp = length(exp_folders);

case_name = [now_str 'd_default'];
% case_name = [now_str '_permissive'];

%% 
% out = cell(2,1);
% do experiment loop
% for nn = 1:nexp
for nn = 2
    exp_name = exp_folders{nn};
    fprintf('Exp %g: %s\n', nn, exp_name);
    try
        x_regenerate_colmap_runfiles(exp_name, case_name, LOAD_ALL)
        out = lf_refractiveFeatures_lytro(exp_name, case_name, LOAD_ALL); % each out is ~ 2.5 GB!
        clear out

    catch
        fprintf('ERROR: exp %s failed. Moving on...\n', exp_name);
    end
end

tEnd = toc(tStart);
tEnd


% save SIFT, RLFF data?

