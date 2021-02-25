% after running lf_process_experimental_results
% load case name - just has the sfm data in it. Need RLFF data/RLFF feature
% info...
% goal is to generate the 
% percent refracted features
% histogram of LF sequences (what order?)
% cumulative histogram (0 - 100)?
% clearvars

FIG = 1;  % figure number

addpath('Support_Functions');
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

fs = 14;

%% get feature data from rlff methods

tic
for nn = 1:nexp
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
        out = load(outfilename, 'rlff_lf_in');
        
        % for now, we just want to set is refracted property:
        rlff{nn} = out.rlff_lf_in;
        
        % clear out, due to memory limitations:
%         clear out
        
    else
        disp('Error: outname does not exist');
    end
end
toc
    
    
%% rlff - decide what is refractive and what is not:

% refractive threshold - some function of distance/background distance?
% slope_rel_diff? 
refr_thresh = 0.1;  % TODO consider Otsu's method?

iexp = 1;
ilf = 1;
iftr = 1;
rlff{iexp}{ilf}{iftr};

% init sequence-wide vectors
slope_rel_diff = [];
slope_abs_diff = [];
% slope_norm_diff = [];
isrlff = [];

rlff_ratio_per_LFLF = cell(nexp,1);
rlff_ratio_per_LF = [];

% for each experimence
for nn = 1:nexp

    nlf = size(rlff{nn}, 1);
    % for each LF
    for ii = 1:nlf
        nftr = size(rlff{nn}{ii}, 1);
        
        isrlff_per_LF = [];
        % for each RLFF 
        for jj = 1:nftr
            % set isrefractive/not:
            if rlff{nn}{ii}{jj}.slope_rel_diff > refr_thresh
                rlff{nn}{ii}{jj}.isrefr = true;
            else
                rlff{nn}{ii}{jj}.isrefr = false;
            end
            
            % concatenate slope variables into single vector:
            slope_rel_diff = cat(1, slope_rel_diff, rlff{nn}{ii}{jj}.slope_rel_diff);
            slope_abs_diff = cat(1, slope_abs_diff, rlff{nn}{ii}{jj}.slope_abs_diff); % abs_diff is just L2-norm
%             slope_norm_diff = cat(1, slope_norm_diff, rlff{nn}{ii}{jj}.slope_norm_diff);
            isrlff = cat(1, isrlff, rlff{nn}{ii}{jj}.isrefr);
            
            isrlff_per_LF = cat(1, isrlff_per_LF, rlff{nn}{ii}{jj}.isrefr);
        end
        
        % number of islrff / total number of features
        rlff_ratio_per_LFLF{nn}{ii} = sum(isrlff_per_LF) / nftr;
        rlff_ratio_per_LF = cat(1, rlff_ratio_per_LF, rlff_ratio_per_LFLF{nn}{ii});
    end
end

% concatenate rlff_ratio_per_LFLF
% try and get some stats on these measurements:

% show me the histogram of slope_rel_diff across the entire experiment 
fprintf('max slope rel diff = %g\n', max(slope_rel_diff));
fprintf('min slope rel diff = %g\n', min(slope_rel_diff));
fprintf('mean slope rel diff = %g\n', mean(slope_rel_diff));

figure(FIG);
FIG = FIG + 1;

h1 = histogram(slope_rel_diff);
title(['slope rel diff: ', exp_folders{nn}], 'Interpreter', 'none'); 
% title(['slope rel diff'], 'Interpreter', 'none'); 
xlabel('relative difference between slopes');
ylabel('count');
grid on;
saveas(gcf, ['Output/rlff_slope_rel_diff_', exp_folders{nn}, '.png']);

fprintf('max slope abs diff = %g\n', max(slope_abs_diff));
fprintf('min slope abs diff = %g\n', min(slope_abs_diff));
fprintf('mean slope abs diff = %g\n', mean(slope_abs_diff));

% figure(FIG);
% FIG = FIG + 1;
% 
% h2 = histogram(slope_abs_diff);
% title(['slope difference L2-norm: ', exp_folders{nn}], 'Interpreter', 'none'); 
% % title(['slope difference L2-norm'], 'Interpreter', 'none'); 
% xlabel('L2-norm between slopes');
% ylabel('count');
% grid on;
% saveas(gcf, ['Output/rlff_slope_abs_diff_', exp_folders{nn}, '.png']);


%

% now, I want to see percentage of refracted features for each image
% see rlff_ratio_per_LF

% now I want to count for a given binning of rlff_ratio_per_LF, how many
% LFs were "successful"?

% this means connecting SfM data (from C.sift_mono

% for rlff:
% C.rlff_mono_all(iexp).sfm - all of them are 1
rm_conv = [];
sm_conv = [];
ss_conv = [];
rs_conv = [];
for nn = 1:nexp
    nLF = C.nLF(nn);
    % sift mono
    if C.sift_mono_all(nn).sfm.did_converge
        sm_res_per_exp = ones(nLF, 1);
    else
        sm_res_per_exp = zeros(nLF, 1);
    end
    sm_conv = cat(1, sm_conv, sm_res_per_exp);
        
    % sift stereo
    if C.sift_stereo_all(nn).sfm.did_converge
        ss_res_per_exp = ones(nLF, 1);
    else
        ss_res_per_exp = zeros(nLF, 1);
    end
    ss_conv = cat(1, ss_conv, ss_res_per_exp);
%     size(ss_conv)
    
    % rlff mono
    if C.rlff_mono_all(nn).sfm.did_converge
        % set all perLF to true
        rm_res_per_exp = ones(nLF, 1);
    else
        % set all perLF to false
        rm_res_per_exp = zeros(nLF, 1);
    end
    rm_conv = cat(1, rm_conv, rm_res_per_exp);
    
    % rlff stereo
    if C.rlff_stereo_all(nn).sfm.did_converge
        % set all perLF to true
        rs_res_per_exp = ones(nLF, 1);
    else
        % set all perLF to false
        rs_res_per_exp = zeros(nLF, 1);
    end
    rs_conv = cat(1, rs_conv, rs_res_per_exp);
end

% figure;

% nbins_ratio = linspace(min(rlff_ratio_per_LF), max(rlff_ratio_per_LF), nbins);

% histogram(rlff_ratio_per_LF(rm_conv==true), nbins, 'FaceColor', 'red', 'FaceAlpha', 0.5)
% title('rlff mono converged');
% xlabel('refracted feature ratio');
% ylabel('LF count');
% grid on;
% 
% hold on; 
% histogram(rlff_ratio_per_LF(sm_conv==true), nbins, 'FaceColor', 'blue','FaceAlpha', 0.5)
% title('LF converged in approaching refracted object sequences');
% xlabel('refracted feature ratio');
% ylabel('LF count');
% grid on;
% legend('rlff mono', 'sift mono');


%% 
% try side-by-side bar-graph style:
nbins = 10;
[h_rm, edges_rm] = histcounts(rlff_ratio_per_LF(rm_conv==true), nbins);
centres_rm = edges_rm(1) + (1:length(edges_rm) - 1).*diff(edges_rm);

[h_sm, edges_sm] = histcounts(rlff_ratio_per_LF(sm_conv==true), nbins);
[h_ss, edges_ss] = histcounts(rlff_ratio_per_LF(ss_conv==true), nbins);
[h_rs, edges_rs] = histcounts(rlff_ratio_per_LF(rs_conv==true), nbins);

figure(FIG);
FIG=FIG+1;

bar(centres_rm, [h_sm; h_ss; h_rm; h_rs]')
title('Histogram: LFs converged approaching refractive objects');
xlabel('refracted feature ratio');
ylabel('LF count');
grid on;
legend('sift mono', 'sift stereo', 'rlff mono', 'rlff stereo');
save_histogram_name = [ 'Output/histogram_lfsconverged_', casename(1:end-4) '.png'];
saveas(gcf, save_histogram_name);

% try line plot style
figure(FIG);
FIG=FIG+1;

x_rf = linspace(min(rlff_ratio_per_LF), max(rlff_ratio_per_LF), nbins);
plot(x_rf, h_sm, 'LineWidth', 2);
hold on;
plot(x_rf, h_ss, 'LineWidth', 2);
plot(x_rf, h_rm, 'LineWidth', 2);
plot(x_rf, h_rs, 'LineWidth', 2);
xlabel('refracted feature ratio / image');
ylabel('convergence count');
legend('SIFT mono', 'SIFT stereo', 'RLFF mono', 'RLFF stereo', 'max images','Location', 'northwest');
grid on;
title('Histogram: LFs converged approaching ROs');
save_cumhist_name = ['Output/hist_lfsconverged_', casename(1:end-4), '.png'];
saveas(gcf, save_cumhist_name);
set(gca, 'XLimSpec', 'Tight');


% showing as a histogram:
% figure(FIG);
% FIG=FIG+1;
% 
% h1 = histogram(rlff_ratio_per_LF(sm_conv==true), nbins);
% hold on;
% h2 = histogram(rlff_ratio_per_LF(ss_conv==true), nbins);
% h3 = histogram(rlff_ratio_per_LF(rm_conv==true), nbins);
% h4 = histogram(rlff_ratio_per_LF(rs_conv==true), nbins);
% hold off;
% ylabel('LF count');
% xlabel('refracted feature ratio');
% grid on;
% legend('sift mono', 'sift stereo', 'rlff mono', 'rlff stereo');


%% cumulative histograms:

ch_rm = cumsum(h_rm);
ch_rs = cumsum(h_rs);
ch_sm = cumsum(h_sm);
ch_ss = cumsum(h_ss);

figure(FIG);
FIG=FIG+1;

bar(centres_rm, [ch_sm; ch_ss; ch_rm; ch_rs]')
title('Cumulative histogram: LFs converged approaching ROs');
xlabel('refracted feature ratio');
ylabel('LF count');
grid on;
legend('sift mono', 'sift stereo', 'rlff mono', 'rlff stereo', 'Location', 'northwest');
save_cumhist_name = ['Output/cumhist_lfsconverged_', casename(1:end-4), '.png'];
saveas(gcf, save_cumhist_name);

%% 

x_rf = linspace(min(rlff_ratio_per_LF), max(rlff_ratio_per_LF), nbins);
% show line-histogram version:
figure(FIG);
FIG=FIG+1;

maxLF = C.nLF_all;
% plot centres
plot(x_rf, ch_sm, 'LineWidth', 2);
hold on;
plot(x_rf, ch_ss, 'LineWidth', 2);
plot(x_rf, ch_rm, 'LineWidth', 2);
plot(x_rf, ch_rs, 'LineWidth', 2);
plot(x_rf, ones(size(x_rf))*maxLF, 'LineWidth', 2);
hold off;
xlabel('refracted feature ratio / image');
ylabel('converged image count');
legend('SIFT mono', 'SIFT stereo', 'RLFF mono', 'RLFF stereo', 'max images','Location', 'southeast');
grid on;
% title('Cumulative histogram: LFs converged approaching ROs');
save_cumhist_name = ['Output/cumhist_lfsconverged_', casename(1:end-4), '.pdf'];
set(gca, 'XLimSpec', 'Tight');
[ax1] = figureTightBorders(gca);
% saveas(gcf,saveMono2DSIF);
plotFigAsPdf(gcf,save_cumhist_name);

% saveas(gcf, save_cumhist_name);

%% do as percent


x_rf = linspace(min(rlff_ratio_per_LF), max(rlff_ratio_per_LF), nbins);
% show line-histogram version:

hFig = figure(FIG);
FIG=FIG+1;
hPos = hFig.Position;
% x y width height
set(gcf,'Position',[hPos(1), hPos(2), hPos(3)*1.0, 0.6*hPos(4)]);
% figure(FIG);


maxLF = C.nLF_all;

ch_sm_p = ch_sm ./ maxLF;

% plot centres
plot(x_rf, ch_sm ./ maxLF * 100, 'LineWidth', 2);
hold on;
plot(x_rf, ch_ss ./ maxLF * 100, 'LineWidth', 2);
plot(x_rf, ch_rm ./ maxLF * 100, 'LineWidth', 2);
plot(x_rf, ch_rs ./ maxLF * 100, 'LineWidth', 2);
plot(x_rf, ones(size(x_rf))*maxLF ./ maxLF * 100 , 'LineWidth', 2);
hold off;
xlabel('refracted feature ratio / image');
ylabel('converged image count %');
legend('SIFT MONO', 'SIFT STEREO', 'RLFF MONO', 'RLFF STEREO', 'max images','Location', 'northwest');
grid on;
% title('Cumulative histogram: LFs converged approaching ROs');
save_cumhist_name = ['Output/cumhist_lfsconverged_', casename(1:end-4), '_percent.pdf'];
set(gca, 'XLimSpec', 'Tight');
[ax1] = figureTightBorders(gca);
% saveas(gcf,saveMono2DSIF);
plotFigAsPdf(gcf,save_cumhist_name);

%% 



% fprintf('max slope norm diff = %g\n', max(slope_norm_diff))
% fprintf('min slope norm diff = %g\n', min(slope_norm_diff))
% fprintf('mean slope norm diff = %g\n', mean(slope_norm_diff))
% h1 = histogram(slope_norm_diff);
% title(['slope norm diff: ', exp_folders{nn}], 'Interpreter', 'none'); 
% xlabel('norm of two slopes');
% ylabel('count');
% grid on;
% saveas(gcf, ['Output/rlff_slope_rel_diff_', exp_folders{nn}, '.png']);

% plot features in central view, colour-coded according to the relative
% slope difference
%     if P.PLOT && (P.PLOT_RLFF_SLOPE_REL_DIFF || P.PLOT_RLFF_SLOPE_ABS_DIFF || P.PLOT_RLFF_SLOPE_NORM_DIFF)
%         nFtr = size(rlff_lf_in{ii},1);
%         slope_rel_diff = zeros(nFtr,1);
%         slope_abs_diff = zeros(nFtr,1);
%         slope_norm_diff = zeros(nFtr,1);
%         for jj = 1:nFtr
%             slope_rel_diff(jj) = rlff_lf_in{ii}{jj}.slope_rel_diff;
%             slope_abs_diff(jj) = rlff_lf_in{ii}{jj}.slope_abs_diff;
%             slope_norm_diff(jj) = rlff_lf_in{ii}{jj}.slope_norm_diff;
%         end
%     end
%     
%     if P.PLOT && P.PLOT_RLFF_SLOPE_REL_DIFF
%         fig_name = [data_folder '/' LFS{ii}.LFName '_slope_rel_diff.png'];
%         fig_title = 'SIFT features coloured by relative slope difference';
%         
%         [h_slopes{ii}] = lf_plot_variable_on_central_view(LFS{ii},rlff_lf_in{ii},ray_ftrs_in{ii},Fc_in{ii},P,slope_rel_diff,'slope relative difference',...
%             'fig_name',fig_name,'fig_title',fig_title);
%     end
%     if P.PLOT && P.PLOT_RLFF_SLOPE_ABS_DIFF
%         fig_name = [data_folder '/' LFS{ii}.LFName '_slope_abs_diff.png'];
%         fig_title = 'SIFT features coloured by absolute slope difference';
%         
%         [h_slopes{ii}] = lf_plot_variable_on_central_view(LFS{ii},rlff_lf_in{ii},ray_ftrs_in{ii},Fc_in{ii},P,slope_abs_diff,'slope abs difference',...
%             'fig_name',fig_name,'fig_title',fig_title);
%     end
%     if P.PLOT && P.PLOT_RLFF_SLOPE_NORM_DIFF
%         fig_name = [data_folder '/' LFS{ii}.LFName '_slope_norm_diff.png'];
%         fig_title = 'SIFT features coloured by normalised slope difference';
%         
%         [h_slopes{ii}] = lf_plot_variable_on_central_view(LFS{ii},rlff_lf_in{ii},ray_ftrs_in{ii},Fc_in{ii},P,slope_norm_diff,'slope norm difference',...
%             'fig_name',fig_name,'fig_title',fig_title);
%     end