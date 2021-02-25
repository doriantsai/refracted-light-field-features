%% lf_plot_sift_features
% Purpose: plot sift features given an LF and st_mask
% Inputs: LF, st_mask
% Outputs: specific feature, EPIs?
function [h_fig] = lf_plot_sift_features(LF,F,D,P,varargin)
% [ftr] = lf_plot_sift_features(LF,st_mask)
default_st_mask = true;
default_ftr_selection = 10;
default_plot_n_views_from_centre = 3;
default_fig_name_str = '1111-11-11-1111-i__lf_fig_sift_features.png'; 

% parsing input parameters
p = inputParser;
addRequired(p,'LF',@isnumeric);
addRequired(p,'F',@iscell);
addRequired(p,'D',@iscell);
addRequired(p,'P',@isstruct);
addParameter(p,'st_mask',default_st_mask,@islogical); % sets a default, unsure how to make nSxnT default matrix without knowing size(LF) ahead of time
addParameter(p,'ftr_selection',default_ftr_selection,@isnumeric); % the top number of sift features to display
addParameter(p,'plot_n_views_from_centre',default_plot_n_views_from_centre,@isnumeric);
addParameter(p,'fig_name',default_fig_name_str,@isstr); % datestr for filename

parse(p,LF,F,D,P,varargin{:});
LF = p.Results.LF;
F = p.Results.F;
D = p.Results.D;
P = p.Results.P;

nT = size(LF,1);
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);

st_mask = p.Results.st_mask;
if st_mask == true
    % default st_mask
    st_mask = true(nT,nS);
else
    st_mask = p.Results.st_mask;
end
plot_n_views_from_centre = p.Results.plot_n_views_from_centre;
ftr_selection = p.Results.ftr_selection;
fig_name = p.Results.fig_name;

% TEMP: random feature selection


% create st subplot of all sub-images
% for each sub-image in LF that st_mask == true
% plot sift features

fig_title = ['sift features in sub-aperture images (t=%g:%g,s=%g%g) of LF',...
    tC - plot_n_views_from_centre,...
    tC + plot_n_views_from_centre,...
    sC - plot_n_views_from_centre,...
    sC + plot_n_views_from_centre
    ];

gap1 = 0.01;
% gap2 = 0.1;

if P.PLOT_FIGURES_SHOW_RUNTIME
    h_fig = figure;
else
    h_fig = figure('Visibility','off');
end
hPos = h_fig.Position; % [xPos, yPos of top left corner, xLength, yLength];
scale_fig = 2.5;
h_fig.Position = [hPos(1), hPos(2), scale_fig*hPos(3), scale_fig*hPos(4)];

count = 0;
hold on;
title(fig_title);
for tt = tC - plot_n_views_from_centre : tC + plot_n_views_from_centre % 1:nT
    for ss = sC - plot_n_views_from_centre : sC + plot_n_views_from_centre % 1:nS
%         fprintf('(tt=%g,ss=%g)\n',tt,ss);
        % plot the image
        count = count + 1;
        subtightplot(plot_n_views_from_centre*2+1,plot_n_views_from_centre*2+1,count,[gap1 gap1],[gap1 gap1],[gap1 gap1]);
        h_img = imagesc(squeeze(LF(tt,ss,:,:,:)));
        set(gca,'visible','off');
        axis equal
        
        if st_mask(tt,ss) == false
            
            continue
        end
%         disp('plotting sift features');
        f = F{tt,ss};
        % TODO: ensure that ftr_selection is contained within ftrs
        % Need to compile vlfeat from source to modify/add feature strengh,
        % so that we can sort sift features by strength
%         perm = randperm(size(f,2));
%         sel = perm(1:ftr_selection);
        idx_f = 1:size(f,2);
        sel = idx_f(1:ftr_selection:end);
        h_ftr = vl_plotframe(f(:,sel));
        set(h_ftr,'color','g','linewidth',2);
        
%         d = D{tt,ss};
%         h_ftr_descr = vl_plotsiftdescriptor(d(:,sel),f(:,sel));
%         set(h_ftr_descr,'color','g');
    end
end
saveas(h_fig,fig_name);