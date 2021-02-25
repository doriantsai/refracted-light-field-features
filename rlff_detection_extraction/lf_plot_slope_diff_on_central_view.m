function lf_plot_slope_diff_on_central_view(LFS,rlff,ray_ftr,Fc,varargin)
% lf_plot_slope_diff_on_central_view plots the relative slope difference on
% the LF's central view

% function lf_plot_slope_diff_on_central_view(LFS,ray_ftr,ftr_list,rlff, ray_obs,vargin);
% plot 2D image features on central view of the given LF
% colour each feature according to the degree of their rlff_rel_slope_diff

%% defaults:

default_fig_title = 'SIFT ftrs coloured by relative slope difference';

% TODO

%% parsing input parameters:

p = inputParser;

addRequired(p,'LFS',@isstruct);
addRequired(p,'rlff',@iscell);
addRequired(p,'ray_ftr',@iscell);
addRequired(p,'ftr_list',@isnumeric);
addParameter(p,'fig_name',@isstr);
addParameter(p,'fig_title',default_fig_title,@isstr);

parse(p,LFS,rlff,ray_ftr,Fc,varargin{:});
LFS = p.Results.LFS;
rlff = p.Results.rlff;
ray_ftr = p.Results.ray_ftr;
Fc = p.Results.ftr_list;
fig_name = p.Results.fig_name;
fig_title = p.Results.fig_title;

%% 
custom_colours; % adds some custom colour definitions for plots

FTR_ANNOTATE = false;

LF = LFS.LF;
nT = size(LF,1); % potential confusion between stuv and ijkl notation
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);

% put all rlff into a single set matrix
nFtr = size(rlff,1);
slope_rel_diff = zeros(nFtr,1);
for jj = 1:nFtr
    slope_rel_diff(jj) = rlff{jj}.slope_rel_diff;
end


% define colourmap based on feature rel slope diff and n_color
min_slope_diff = min(slope_rel_diff);
max_slope_diff = max(slope_rel_diff);
n_color = 40;
map_of_color = jet(n_color);
colour_grade = linspace(min_slope_diff,max_slope_diff,n_color);

%% plot histogram of the relative slope differences from the rlff
% nBins = 100;
% figure;
% hist(slope_rel_diff,nBins);
% title(['slope rel diff for LF ' num2str(ii)]);

%%


% plot the central view
h_slope_rel_diff = figure;
IM = rgb2gray(squeeze(LF(tC,sC,:,:,:)));
imagesc(IM);
h_img = gca;
colormap(gray);
hold on
axis equal
title(fig_title);



% for each feature
% plot image feature location
% assign colour based on magnitude of relative slope difference

for jj = 1:nFtr
    % first, find the color index appropriate for the magnitude of
    % slope_rel_diff
    i_less_than_color = find(rlff{jj}.slope_rel_diff >= colour_grade);
    if isempty(i_less_than_color)
        fprintf('warning: ftr idx %g empty\n',jj);
    else
    i_color = i_less_than_color(end);
     
    % apply bounds
    if i_color >= n_color
        i_color = n_color;
    elseif i_color <= 1
        i_color = 1;
    end
    color_of_ftr = map_of_color(i_color,:);
    
    % then plot feature
    uc = Fc(jj,1);
    vc = Fc(jj,2);
    %     plot(uc,vc,'.','color',color_of_ftr,'MarkerSize',7,'Linewidth',2);
    vl_plotframe(Fc(jj,:)','color',color_of_ftr,'linewidth',1);
    
    if FTR_ANNOTATE
        buf = 3;
        text(uc+buf, vc+buf, num2str(jj),'Color','yellow');
    end
    end
    
    
end

scale_of_bar = 1; % what percentage of the height of the figure;
shift_of_bar = 0.015;
colorLim = [floor(slope_rel_diff), ceil(slope_rel_diff)];
if floor(slope_rel_diff) == ceil(slope_rel_diff) % when slopesimilarity is all very close together
    colorLim(1) = colorLim(1)-1;
    
end
[hAxHyp,~] = PlotColorbar(h_img,scale_of_bar,shift_of_bar,colorLim,map_of_color);

hold off;

saveas(gcf,fig_name);

