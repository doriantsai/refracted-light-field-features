% lf_plot_feature_intra_match.m
% function plots a given feature
% first, show the central view
% then, if GUI option is given, asks user to pick a feature from the
% central view. Nearest feature in uv-space is found, and then the
% intra-LF matches are shown (from lf_intra_match_features.m)
% EPIs also given, horizontal and vertical
% figures saved for given filename
function [idx_ftr] = lf_plot_feature_intra_match(LF,Fst,ray_ftr,Fc,varargin)


%% defaults:
default_st_mask = true;
default_manual_feature_selection = true;
default_manual_view_selection = false;
default_s = [];
default_t = [];
default_u = [];
default_v = [];
default_fig_name_str = '1111-11-11-1111-i_lf_fig_intra_match_features.png'; 
default_plot_n_views_from_centre = 1;
default_ray_ftr_descr = zeros(1,128);
default_fig_title = 'lf fig intra-match features';
default_idx_ftr_to_plot = [];
default_colour_slope_diff = false;
default_rlff = cell(1);
default_rlff{1} = [];
default_D = 1;

%% parsing input parameters:
p = inputParser;
addRequired(p,'LF',@isnumeric);
addRequired(p,'Fst',@iscell);
addRequired(p,'ray_ftr',@iscell);
addRequired(p,'Fc',@isnumeric);

addParameter(p,'rlff',default_rlff,@iscell);
addParameter(p,'ray_ftr_descr',default_ray_ftr_descr,@iscell);
addParameter(p,'st_mask',default_st_mask,@islogical);
addParameter(p,'plot_n_views_from_centre',default_plot_n_views_from_centre,@isnumeric);
addParameter(p,'fig_name',default_fig_name_str,@isstr);
addParameter(p,'fig_title',default_fig_title,@isstr);
addParameter(p,'s',default_s,@isnumeric);
addParameter(p,'t',default_t,@isnumeric);
addParameter(p,'u',default_u,@isnumeric);
addParameter(p,'v',default_v,@isnumeric);
addParameter(p,'manual_feature_selection',default_manual_feature_selection',@islogical);
addParameter(p,'manual_view_selection',default_manual_view_selection',@islogical);
addParameter(p,'idx_ftr_to_plot',default_idx_ftr_to_plot,@isnumeric);
addParameter(p,'colour_slope_diff',default_colour_slope_diff,@islogical);
addParameter(p,'D',default_D,@isnumeric);

parse(p,LF,Fst,ray_ftr,Fc,varargin{:});
LF = p.Results.LF;
Fst = p.Results.Fst;
ray_ftr = p.Results.ray_ftr;
Fc = p.Results.Fc;
ray_ftr_descr = p.Results.ray_ftr_descr;
D = p.Results.D;

rlff = p.Results.rlff;


nT = size(LF,1);
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);
uMax = size(LF,4);
vMax = size(LF,3);

st_mask = p.Results.st_mask;
if st_mask == true
    % default st_mask
    st_mask = true(nT,nS);
else
    st_mask = p.Results.st_mask;
end
plot_n_views_from_centre = p.Results.plot_n_views_from_centre;
fig_name = p.Results.fig_name;
s_specified = p.Results.s;
t_specified = p.Results.t;
u_specified = p.Results.u;
v_specified = p.Results.v;


manual_feature_selection = p.Results.manual_feature_selection;
manual_view_selection = p.Results.manual_view_selection;
fig_title = p.Results.fig_title;
idx_ftr_to_plot = p.Results.idx_ftr_to_plot;
colour_slope_diff = p.Results.colour_slope_diff;


%% internal parameters:
gap1 = 0.01; % gap between LF-view plot
scale_fig = 2.5;

nFtr = size(ray_ftr,2);
if colour_slope_diff
    % put all rlff into a single set matrix
    
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
end


%% choose which sub-aperture image:

if manual_view_selection == true
    % manually select view via keyboard input?
    s = input('Enter "s" for manual sub-aperture image selection: ');
    t = input('Enter "t" for manual sub-aperture image selection: ');

else
    if ~isempty(s_specified) && ~isempty(t_specified)
        s = s_specified;
        t = t_specified;
    else
        disp('Default to central view');
        s = sC;
        t = tC;
    end
end


%% decide what to do:


% if we don't have an asigned feature index to plot, then probably we do
% manual selection, otherwise we just take the centre of the image
if isempty(idx_ftr_to_plot)
    
    if manual_feature_selection == true
        h = figure;
        hPos = h.Position; % [xPos, yPos of top left corner, xLength, yLength];
        h.Position = [hPos(1), hPos(2), scale_fig*hPos(3), scale_fig*hPos(4)];
        
        imagesc(rgb2gray(squeeze(LF(t,s,:,:,:))));
        h_img = gca;
        colormap('gray');
        hold on;
        
        %     set(gca,'visible','off');
        % NEED TO USE F INSTEAD OF FTR_LIST, but also need to find all ftr_list (centre-frame) that appears on the given st
        if colour_slope_diff == true
            
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
%                     uc = Fc(jj,1);
%                     vc = Fc(jj,2);
%                     plot(uc,vc,'.','color',color_of_ftr,'MarkerSize',7,'Linewidth',2);
                    vl_plotframe(Fc(jj,:)','color',color_of_ftr);
%                     if FTR_ANNOTATE
%                         buf = 3;
%                         text(uc+buf, vc+buf, num2str(jj),'Color','yellow');
%                     end
                end
            end
            
            scale_of_bar = 1; % what percentage of the height of the figure;
            shift_of_bar = -0.005;
            colorLim = [floor(slope_rel_diff), ceil(slope_rel_diff)];
            if floor(slope_rel_diff) == ceil(slope_rel_diff) % when slopesimilarity is all very close together
                colorLim(1) = colorLim(1)-1;
                
            end
            [hAxHyp,~] = PlotColorbar(h_img,scale_of_bar,shift_of_bar,colorLim,map_of_color);
            
        else
            h_ftr = vl_plotframe(Fc');
            set(h_ftr,'color','g','linewidth',2);
        end
        axis equal;
        hold off;
        
        % wait for user manual input/click
        % click only once (ginput set to one)
        [u,v] = ginput(1);
        
    elseif ~isempty(u_specified) && ~isempty(v_specified)
        % use specified u,v
        u = u_specified;
        v = v_specified;
    else
        % otherwise, use centre of image
        
        u = round(uMax/2);
        v = round(vMax/2);
    end
    
    % find feature nearest
    [idx_ftr,ftr_match] = FindFeatureFromUV(Fc,u,v);
    if isempty(idx_ftr) % should be a try-catch
        fprintf('Warning: did not find any nearest feature to (u,v) = (%g,%g)\n',u,v);
    end
    
else
    % just used the specified feature index
    idx_ftr = idx_ftr_to_plot;
    
end
    
% show selected feature from centre view:

h_ftr_centreview = figure;
hPos = h_ftr_centreview.Position; % [xPos, yPos of top left corner, xLength, yLength];
h.Position = [hPos(1), hPos(2), scale_fig*hPos(3), scale_fig*hPos(4)];

h_img = imagesc(rgb2gray(squeeze(LF(tC,sC,:,:,:))));
colormap('gray');

titleStr = ['feature: i=' num2str(idx_ftr) ', (u,v)=(' num2str(Fc(idx_ftr,1),'%5.1f') ',' num2str(Fc(idx_ftr,2),'%5.1f') ')'];
title(titleStr);
hold on;



h_ftr_all = vl_plotframe(Fc');
set(h_ftr_all,'color','g','linewidth',2);

h_ftr = vl_plotframe(Fc(idx_ftr,:)');
set(h_ftr,'color','r','linewidth',2);

axis equal;
hold off;




%% plot all sub-aperture views




h_fig = figure;
hPos = h_fig.Position; % [xPos, yPos of top left corner, xLength, yLength];
h_fig.Position = [hPos(1), hPos(2), scale_fig*hPos(3), scale_fig*hPos(4)];

count = 0;
hold on;
title(fig_title);

% sub-sample views based on plot_n_views_from_centre because it can be hard
% to see/visualise when there are 13x13 views
% TODO consider adding an ROI
for tt = tC - plot_n_views_from_centre : tC + plot_n_views_from_centre % 1:nT
    for ss = sC - plot_n_views_from_centre : sC + plot_n_views_from_centre % 1:nS
%         fprintf('(tt=%g,ss=%g)\n',tt,ss);

        % plot the image
        count = count + 1;
        hAxSub(count) = subtightplot(plot_n_views_from_centre*2+1,plot_n_views_from_centre*2+1,count,[gap1 gap1],[gap1 gap1],[gap1 gap1]);
        IM = rgb2gray(squeeze(LF(tt,ss,:,:,:)));
        % reduce intensity of colours to make it easier to see features
        h_img = imagesc(IM);
        colormap('gray');
        set(gca,'visible','off');
        axis equal
        
        if st_mask(tt,ss) == false
            continue
        end
        
        % for the specified feature, if it exists/we can find a match in
        % ray_ftr{spec}, then plot it
        
        % for the given sub-image view (ss,tt) find the matching row in
        % ray_ftr (if it exists) for each idx specified by idx_ftr
        for jj = 1:length(idx_ftr)            

            % logical find
            idx_view = find( [ss == ray_ftr{idx_ftr(jj)}(:,1)] .* [tt == ray_ftr{idx_ftr(jj)}(:,2)] );
            
            if ~isempty(idx_view)
                % if we do have a hit, (we should not have multiple
                % hits...)
                % plot this feature. Note, we have to plot the feature
                % relative to the  (tt,ss) sub-image view, not Fc (the
                % centre view) feature
                h_ftr = vl_plotframe(Fst{idx_ftr(jj)}(idx_view,:));
                set(h_ftr,'color','g','linewidth',2);
                
                %% also, plot rlff reprojection:
                if ~isempty(rlff{1})
                    % find relevant index based on rlff.ijkl:
                    idx_rlff = find([ss == rlff{idx_ftr(jj)}.ijkl(:,1)] .* [tt == rlff{idx_ftr(jj)}.ijkl(:,2)]);
                    
                    % test rlff projection using H:
                    % if we have rlff, then we test H by plotting all uv_est given st:
                    st = [rlff{idx_ftr(jj)}.stuv(idx_rlff,1:2) 1]';
                    uv_est = rlff{idx_ftr(jj)}.H * st;
                    % convert stuv to ijkl:
                    ijkl = inv(rlff{idx_ftr(jj)}.H_cal) * [st(1) st(2) uv_est(1) uv_est(2) 1]';
                    % plot uv_est as red dots in every sub-image
                    hold on;
                    plot(ijkl(3),ijkl(4),'.r','MarkerSize',4);
                    hold off;
                    
                    % test rlff projection using P:
                    % using the right st:
                    [kk1, ll1, uu1, vv1, ss1, tt1] = lf_4D_plane_using_P(ss,tt,rlff{idx_ftr(jj)}.P01,D,rlff{idx_ftr(jj)}.H_cal);
                    [kk2, ll2, uu2, vv2, ss2, tt2] = lf_4D_plane_using_P(ss,tt,rlff{idx_ftr(jj)}.P02,D,rlff{idx_ftr(jj)}.H_cal);
                    
                    hold on;
                    
                    plot(kk1,ll1,'+b');
                    plot(kk2,ll2,'oc');
                    hold off;
                    
                end
            else
                % fprintf('Warning: could not find matching idx_view in ray_ftr(%g) for view (ss=%g,tt=%g)\n',idx_ftr(jj),ss,tt);
            end
        end
        
%         d = D{tt,ss};
%         h_ftr_descr = vl_plotsiftdescriptor(d(:,sel),f(:,sel));
%         set(h_ftr_descr,'color','g');
    end
end
linkaxes(hAxSub,'xy');
hold off
saveas(h_fig,fig_name);


%% plot EPIs

fig_name_epi = 'lf_epi.png'; % TODO: add to p/defaults, etc
fig_title_epi = 'EPIs for selected figure';

% for given feature found, show horizontal and vertical EPIs
% note: feature may not have been found along given axes
% also, will be drawing on full LF, not just sub-sampled LF shown

% how to put them into a similar scale, with the feature centered
% find the maximum pixel length (vMax vs uMax)
% set axes limits to that
% shift the smaller axis to the centre of the figure
jj = 1; % assume we take the first one only
idx_centre = find( [sC == ray_ftr{idx_ftr(jj)}(:,1)] .* [tC == ray_ftr{idx_ftr(jj)}(:,2)] );
uFtr = ray_ftr{idx_ftr(jj)}(idx_centre,3);
vFtr = ray_ftr{idx_ftr(jj)}(idx_centre,4);


% horizontal EPI
EPI_horz = rgb2gray(squeeze(LF(tC,:,round(vFtr),:,:)));
xStr_horz = 'u [pix]';
yStr_horz = 's [views]';

% vertical EPI
EPI_vert = rgb2gray(squeeze(LF(:,sC,:,round(uFtr),:)));
xStr_vert = 'v [pix]';
yStr_vert = 't [views]';

% probably have the two as a sub-plot to each, as it will make it easier
% for comparison (equal vs not equal):
h_epi_horz = figure;
hPos = h_epi_horz.Position;  % [xPos, yPos of top left corner, xLength, yLength];
h_epi_horz.Position = [hPos(1), hPos(2), 1.5*hPos(3), 1*hPos(4)];

% plot horizontal  EPI
hAx(1) = subplot(2,1,1);
title(fig_title_epi);
imagesc(EPI_horz);
colormap('gray');
% plot feature on EPI
hold on;
plot(uFtr,sC,'o','color','red','linewidth',2);
hold off;
xlabel(xStr_horz);
ylabel(yStr_horz);

% plot vertical EPI
hAx(2) = subplot(2,1,2);
imagesc(EPI_vert);
colormap('gray');
% plot feature on EPI
hold on;
plot(vFtr,tC,'o','color','red','linewidth',2);
hold off;
xlabel(xStr_vert);
ylabel(yStr_vert);

% link axes so that adjusting one axes adjusts the other, I think
linkaxes(hAx,'x');
% pix_max = max([uMax vMax]);
% set(hAx,'ylim',[0 pix_max]);

saveas(h_epi_horz,fig_name_epi);

result = true;
end