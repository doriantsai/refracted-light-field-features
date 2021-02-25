function [h_flow] = lf_plot_feature_inter_match(LFS, ray_ftrs, ray_ftr_descrs, Fc, Dc, rlff_lf,P,lf_intermatches,varargin)
% lf_plot_feature_inter_match plots matches of features from the centre
% view of two inter-LF matches

%% defaults

default_fig_title = 'inter LF feature match';
default_fig_name = 'inter_LF_feature_match.png';
default_var_color = [];
default_var_name = [];


%% parsing inputs

p = inputParser;
addRequired(p,'LFS',@iscell);
addRequired(p,'ray_ftrs',@iscell);
addRequired(p,'ray_ftr_descrs',@iscell);
addRequired(p,'Fc',@iscell);
addRequired(p,'Dc',@iscell);
addRequired(p,'rlff_lf',@iscell);
addRequired(p,'P',@isstruct);
addRequired(p,'lf_intermatches',@isstruct);

addParameter(p,'fig_title',default_fig_title,@isstr);
addParameter(p,'fig_name',default_fig_name,@isstr);
addParameter(p,'var_color',default_var_color,@iscell);
addParameter(p,'var_name',default_var_name,@isstr);

parse(p,LFS,ray_ftrs,ray_ftr_descrs,Fc,Dc,rlff_lf,P,lf_intermatches,varargin{:});
LFS = p.Results.LFS;
ray_ftrs = p.Results.ray_ftrs;
ray_ftr_descrs = p.Results.ray_ftr_descrs;
Fc = p.Results.Fc;
Dc = p.Results.Dc;
rlff_lf = p.Results.rlff_lf;
P = p.Results.P;
lf_intermatches = p.Results.lf_intermatches;

fig_name = p.Results.fig_name;
var_color = p.Results.var_color;
var_name = p.Results.var_name;


%% internal parameters

PLOT_OUTLIERS = false;
nLF = size(LFS,1);
nCombo = size(lf_intermatches,2);
nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);


custom_colours % adds some custom colour definitions for plots
FTR_ANNOTATE = false;

%% plot montage
%     % show matches between centre-view LFs:
%     PLOT_MONTAGE = false;
%     % plot comparison to show features
%     if PLOT_MONTAGE
%         IM1 = rgb2gray(squeeze(LFS{frame1}.LF(tC,sC,:,:,:)));
%         IM2 = rgb2gray(squeeze(LFS{frame2}.LF(tC,sC,:,:,:)));
%
%         h_fig = figure('Visible','on');
%         hPos = h_fig.Position;  % [xPos, yPos of top left corner, xLength, yLength];
%         h_fig.Position = [hPos(1), hPos(2), 2.0*hPos(3), 1*hPos(4)];
%
%         h_img = imagesc(cat(2,IM1,IM2));
%         colormap('gray');
%         axis image off;
%
%         x1 = Fc{frame1}(m1,1);
%         x2 = Fc{frame2}(m2,1) + size(IM1,2);
%         y1 = Fc{frame1}(m1,2);
%         y2 = Fc{frame2}(m2,2);
%
%         n_ftr_match = length(x1);
%         sel = 1:n_ftr_match;
%         hold on;
%         hLines = line([x1(sel) x2(sel)]', [y1(sel) y2(sel)]');
%         set(hLines,'linewidth',1,'color','b');
%         plot(x1,y1,'.r');
%         plot(x2,y2,'.g');
%
%         %         vl_plotframe(Fc{frame_1}(matches(ii).matches_prelim(1,sel),:));
%         %         Fc_temp = Fc;
%         %         Fc_temp{frame_2}(:,1) = Fc_temp{frame_2}(:,1) + size(IM1,2);
%         %         vl_plotframe(Fc_temp{frame_1}(matches(ii).matches_prelim(2,sel),:));
%         hold off;
%         fig_name = ['Output/' 'rlff_interLFmatch_ ' LFS{frame1}.LFName '_to_' LFS{frame2}.LFName '.png'];
%         saveas(gcf,fig_name);
%     end

% plot comparison showing the features in motion
% take 1st image, plot all feautres
% overlaying 1st image, plot corresponding features as vectors going to
% red


    
%% plot optical flow
h_flow = cell(nCombo,1);
for ii = 1:nCombo
    frame1 = lf_intermatches(ii).lf1;
    frame2 = lf_intermatches(ii).lf2;
    m1 = lf_intermatches(ii).matches_prelim(:,1);
    m2 = lf_intermatches(ii).matches_prelim(:,2);
    
    if P.PLOT_OPTICALFLOW
        IM1 = rgb2gray(squeeze(LFS{frame1}.LF(tC,sC,:,:,:)));
        
        if P.PLOT_FIGURES_SHOW_RUNTIME
            h_flow{ii} = figure;
        else
            h_flow{ii} = figure('Visible','off');
        end
        
        hPos = h_flow{ii}.Position;  % [xPos, yPos of top left corner, xLength, yLength];
        scale_fig = 1.5;
        h_flow{ii}.Position = [hPos(1), hPos(2), scale_fig*hPos(3), scale_fig*hPos(4)];
        
        h_img = imagesc(IM1);
        colormap('gray');
        axis image off;
        
        x1 = Fc{frame1}(m1,1);
        y1 = Fc{frame1}(m1,2);
        x2 = Fc{frame2}(m2,1);
        y2 = Fc{frame2}(m2,2);
        
        n_ftr_match = length(x1);
        if PLOT_OUTLIERS
            a = 1:n_ftr_match;
            sel = a(~lf_intermatches(ii).is_outlier == true);
        else
            sel = 1:n_ftr_match;
        end
        
        hold on;
        
        % add colour/borders
        if ~isempty(var_color)
            % define colour map for the LF
            
            % define colourmap based on feature var_color and n_color
            min_var = min(var_color{ii});
            max_var = max(var_color{ii});
            n_color = 40;
            map_of_color = jet(n_color);
            colour_grade = linspace(min_var,max_var,n_color);
            
            if PLOT_OUTLIERS
               
                for jj = 1:n_ftr_match
                    
                    if lf_intermatches(ii).is_outlier(jj) == true % thresholded, vs graded by colour
                        hLines1 = line([x1(jj) x2(jj)]', [y1(jj) y2(jj)]');
                        set(hLines1,'linewidth',3,'color','yellow'); % maybe make alphadata 0.5
                        plot(x1,y1,'.y','markersize',5);
                        plot(x2,y2,'.y','markersize',5);
                    end
                    
%                     if lf_intermatches(ii).uvc_outliers(jj) == true % thresholded, vs graded by colour
%                         hLines1 = line([x1(jj) x2(jj)]', [y1(jj) y2(jj)]');
%                         set(hLines1,'linewidth',3,'color','yellow'); % maybe make alphadata 0.5
%                         plot(x1,y1,'.y','markersize',5);
%                         plot(x2,y2,'.y','markersize',5);
%                     end

%                     if lf_intermatches(ii).uc_outliers(jj) == true % thresholded, vs graded by colour
%                         hLines2 = line([x1(jj) x2(jj)]', [y1(jj) y2(jj)]');
%                         set(hLines2,'linewidth',2,'color','magenta'); % maybe make alphadata 0.5
%                         plot(x1,y1,'.y','markersize',5);
%                         plot(x2,y2,'.y','markersize',5);
%                     end

%                     if lf_intermatches(ii).vc_outliers(jj) == true % thresholded, vs graded by colour
%                         hLines3 = line([x1(jj) x2(jj)]', [y1(jj) y2(jj)]');
%                         set(hLines3,'linewidth',2,'color','cyan'); % maybe make alphadata 0.5
%                         plot(x1,y1,'.y','markersize',5);
%                         plot(x2,y2,'.y','markersize',5);
%                     end
                end
                
            end
            % uvc_inlier = lf_intermatches(ii).uvc_inliers;
            for jj = 1:length(sel)
                if var_color{ii}(sel(jj)) == true  % thresholded, vs graded by colour
                    hLines = line([x1(sel(jj)) x2(sel(jj))]', [y1(sel(jj)) y2(sel(jj))]');
                    set(hLines,'linewidth',3,'color','yellow'); % maybe make alphadata 0.5
                    plot(x1(sel),y1(sel),'.y','markersize',5);
                    plot(x2(sel),y2(sel),'.y','markersize',5);
                end
            end
        end
        
        % plot features and lines going from red to green
        hLines = line([x1(sel) x2(sel)]', [y1(sel) y2(sel)]');
        set(hLines,'linewidth',1,'color','b'); % maybe make alphadata 0.5
        plot(x1,y1,'.r');
        plot(x2,y2,'.g');
        
        
        
        hold off;
        if ~isempty(var_name)
            title(['intermatch frame ' num2str(frame1) ' to frame ' num2str(frame2) ', red to green, ' var_name ' yellow']);
            fig_name = [LFS{frame1}.LFFolder '/rlff_interLFmatch_ ' LFS{frame1}.LFName '_to_' LFS{frame2}.LFName '.png'];
        else
            title(['intermatch frame ' num2str(frame1) ' to frame ' num2str(frame2) ', red to green']);
            fig_name = [LFS{frame1}.LFFolder '/rlff_interLFmatch_ ' LFS{frame1}.LFName '_to_' LFS{frame2}.LFName '.png'];
        end
        saveas(gcf,fig_name);
    end
end

end