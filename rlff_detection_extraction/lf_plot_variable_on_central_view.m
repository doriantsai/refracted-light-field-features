function [h_fig] = lf_plot_variable_on_central_view(LFS,rlff,ray_ftr,Fc,P,var_colour,var_name,varargin)
% lf_plot_error_reproj_on_central_view plots the reprojection error from H on
% the LF's central view

% function lf_plot_error_reproj_on_central_view(LFS,ray_ftr,ftr_list,rlff, ray_obs,vargin);
% plot 2D image features on central view of the given LF
% colour each feature according to the degree of their rlff_reproj_error

%% defaults:

default_fig_title = 'SIFT ftrs in central view of LF';


% TODO

%% parsing input parameters:

p = inputParser;

addRequired(p,'LFS',@isstruct);
addRequired(p,'rlff',@iscell);
addRequired(p,'ray_ftr',@iscell);
addRequired(p,'Fc',@isnumeric);
addRequired(p,'P',@isstruct);
addRequired(p,'var_color',@isnumeric);
addRequired(p,'var_name',@isstr);

addParameter(p,'fig_name',@isstr);
addParameter(p,'fig_title',default_fig_title,@isstr);

parse(p,LFS,rlff,ray_ftr,Fc,P,var_colour,var_name,varargin{:});
LFS = p.Results.LFS;
rlff = p.Results.rlff;
ray_ftr = p.Results.ray_ftr;
Fc = p.Results.Fc;
P = p.Results.P;
var_color = p.Results.var_color;
var_name = p.Results.var_name;
fig_name = p.Results.fig_name;
fig_title = p.Results.fig_title;

%% 
custom_colours % adds some custom colour definitions for plots

FTR_ANNOTATE = false;

LF = LFS.LF;
nT = size(LF,1); % potential confusion between stuv and ijkl notation
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);

% put all rlff into a single set matrix - need to do this outside of the
% plot now
nFtr = size(rlff,1);
% var_color = zeros(nFtr,1);
% for jj = 1:nFtr
%     var_color(jj) = rlff{jj}.var_color;
% end

% define colourmap based on feature rel slope diff and n_color
min_var = min(var_color);
max_var = max(var_color);
n_color = 40;
map_of_color = jet(n_color);
colour_grade = linspace(min_var,max_var,n_color);


%% plot histogram of the relative slope differences from the rlff
% nBins = 100;
% figure;
% hist(var_color,nBins);
% title([var_name 'for LF ']);

%% check outliers

% ootlier = isoutlier(var_color,'percentiles',[0 98]);


%% plot and colour features

% plot the central view
if P.PLOT_FIGURES_SHOW_RUNTIME
    h_fig = figure;
else
    h_fig = figure('Visible','off');
end
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
    i_less_than_color = find(var_color(jj) >= colour_grade);
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

        %     plot(uc,vc,'.','color',color_of_ftr,'MarkerSize',7,'Linewidth',2);
        if rlff{jj}.isoutlier == true
            % make it extra noticeable
            vl_plotframe(Fc(jj,:)','color','yellow','linewidth',5);
        end
%         if rlff{jj}.error_reproj_sym > 0.016 % this parameter also seems to work well
%             % make it extra noticeable
%             vl_plotframe(Fc(jj,:)','color','magenta','linewidth',3);
%         end
        vl_plotframe(Fc(jj,:)','color',color_of_ftr,'linewidth',1);        

        if FTR_ANNOTATE
            buf = 3;
                    uc = Fc(jj,1);
        vc = Fc(jj,2);
            text(uc+buf, vc+buf, num2str(jj),'Color','yellow');
        end
    end
    
    
end



scale_of_bar = 1; % what percentage of the height of the figure;
shift_of_bar = 0.015;
colorLim = [min(floor(var_color)), max(ceil(var_color))]; % note: recently changed to min/max
if floor(var_color) == ceil(var_color) % when slopesimilarity is all very close together
    colorLim(1) = colorLim(1)-1;
    
end
[hAxHyp,~] = PlotColorbar(h_img,scale_of_bar,shift_of_bar,colorLim,map_of_color);


hold off;

saveas(gcf,fig_name);

end
