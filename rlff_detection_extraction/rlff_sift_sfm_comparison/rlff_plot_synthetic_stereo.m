function [h_centre, h_left, h_right, h_st_flow] = rlff_plot_synthetic_stereo(LFS,rlff_lf_in,rlffSynthStereo_LF,stStereo,Fst_in,ii,varargin)
% function lf_plot_artificial_stereo plots the stereo for each LF frame
% defined by stStereo and artStereo_LF:

%% defaults

default_figname_centre = 'Output/stereo_centre.png';
default_figname_left = 'Output/stereo_left.png';
default_figname_right = 'Output/stereo_right.png';
default_figname_flow = 'Output/stereo_flow.png';

%% parsing input parameters
p = inputParser;
addRequired(p,'LFS',@iscell);
addRequired(p,'rlff_lf_in',@iscell);
addRequired(p,'artStereo_LF',@iscell);
addRequired(p,'stStereo',@isnumeric);
addRequired(p,'Fst_in',@iscell);
addRequired(p,'ii',@isnumeric);

addParameter(p,'savename_centre',default_figname_centre,@isstr);
addParameter(p,'savename_left',default_figname_left,@isstr);
addParameter(p,'savename_right',default_figname_right,@isstr);
addParameter(p,'savename_flow',default_figname_flow,@isstr);

parse(p,LFS,rlff_lf_in,rlffSynthStereo_LF,stStereo,Fst_in,ii,varargin{:});
LFS = p.Results.LFS;
rlff_lf_in = p.Results.rlff_lf_in;
rlffSynthStereo_LF = p.Results.artStereo_LF;
stStereo = p.Results.stStereo;
Fst_in = p.Results.Fst_in;
ii = p.Results.ii;

savename_centre = p.Results.savename_centre;
savename_left = p.Results.savename_left;
savename_right = p.Results.savename_right;
savename_flow = p.Results.savename_flow;

%% internal parameters

nLF = size(LFS,1);
% nCombo = size(lf_intermatches,2);
nT = size(LFS{1}.LF,1);
nS = size(LFS{1}.LF,2);
sC = round(nS/2);
tC = round(nT/2);

PLOT = true;
%% plot
if PLOT
    %     for ii = 5
    IMC = squeeze(LFS{ii}.LF(tC,sC,:,:,1:3));
    IM1 = squeeze(LFS{ii}.LF(stStereo(1,2),stStereo(1,1),:,:,1:3));
    IM2 = squeeze(LFS{ii}.LF(stStereo(2,1),stStereo(2,2),:,:,1:3));
    img1_names{ii} = [LFS{ii}.LFName '_left' '.png']; % in subsequent iterations, this gets overwritten
    img2_names{ii} = [LFS{ii}.LFName '_right' '.png'];
    
    
    nFtr = size(rlffSynthStereo_LF{ii}.P01,1);
    p1f1{ii} = nan(nFtr,4);
    p1f2{ii} = nan(nFtr,4);
    p2f1{ii} = nan(nFtr,4);
    p2f2{ii} = nan(nFtr,4);
    fc{ii} = nan(nFtr,4);
    f_rlff{ii} = nan(nFtr,2);
    
    for jj = 1:nFtr
        % first point P01
        p1f1{ii}(jj,:) = rlffSynthStereo_LF{ii}.P01{jj}.f1;
        
        p1f2{ii}(jj,:) = rlffSynthStereo_LF{ii}.P01{jj}.f2;
        
        % second point P02
        p2f1{ii}(jj,:) = rlffSynthStereo_LF{ii}.P02{jj}.f1;
        p2f2{ii}(jj,:) = rlffSynthStereo_LF{ii}.P02{jj}.f2;
        
        % find centre view:
        idx_c = find((sC == rlff_lf_in{ii}{jj}.ijkl(:,1)) .* (tC == rlff_lf_in{ii}{jj}.ijkl(:,2)));
        fc{ii}(jj,:) = Fst_in{ii}{jj}(idx_c,:);
        
        % also, create reprojection using RLFF's H matrix:
        H = rlff_lf_in{ii}{jj}.H;
        %     st_h = [1 1]';
        %     uv_est = H * st_h;
        
        %     f_rlff{ii}(jj,:);
    end
    
    % TODO: turn into a plot function: lf_plot_artificial_stereo:
    % want to show stereo pairs in the same image:
    
    imscale = 1.5;
    % show central view of 3D points
    h_centre{ii} = figure('Visible','on');
    hPos = h_centre{ii}.Position;  % [xPos, yPos of top left corner, xLength, yLength];
    h_centre{ii}.Position = [hPos(1), hPos(2), imscale*hPos(3), imscale*hPos(4)];
    h_imgc = imagesc(IMC);
    colormap('gray');
    axis image off;
    hold on;
    plot(fc{ii}(:,1),fc{ii}(:,2),'or');
    title('centre view');
    saveas(gcf,savename_centre);
    
    % in IM1:
    % show all P01.f1
    % show all P02.f1
    h_left{ii} = figure('Visible','on');
    hPos = h_left{ii}.Position;  % [xPos, yPos of top left corner, xLength, yLength];
    h_left{ii}.Position = [hPos(1), hPos(2), imscale*hPos(3), imscale*hPos(4)];
    h_img1 = imagesc(IM1);
%     ax = axes;
    colormap('gray');
    axis image off;
    hold on;
    plot([p1f1{ii}(:,1) p2f1{ii}(:,1)]', ...
        [p1f1{ii}(:,2) p2f1{ii}(:,2)]','-y');
    plot(p1f1{ii}(:,1),p1f1{ii}(:,2),'or',...
        p2f1{ii}(:,1),p2f1{ii}(:,2),'+b');
    hold off;
    title('stereo left');
%     axis(ax);
    saveas(gcf,savename_left);
    
    
    % in IM2:
    % show all P01.f2
    % show all P02.f2
    h_right{ii} = figure('Visible','on');
    hPos = h_right{ii}.Position;  % [xPos, yPos of top left corner, xLength, yLength];
    h_right{ii}.Position = [hPos(1), hPos(2), imscale*hPos(3), imscale*hPos(4)];
    h_img2 = imagesc(IM2);
    colormap('gray');
    axis image off;
%     ax = axes;
    hold on;
    plot([p1f2{ii}(:,1) p2f2{ii}(:,1)]', ...
        [p1f2{ii}(:,2) p2f2{ii}(:,2)]','-y');
    plot(p1f2{ii}(:,1),p1f2{ii}(:,2),'or',...
        p2f2{ii}(:,1),p2f2{ii}(:,2),'+b');
    hold off;
    %         axis(ax);
    title('stereo right');
    saveas(gcf,savename_right);
    
    % show optical flow-style image:
    % show IM1 with all P01.f1 -> P01.f2, and P02.f1 -> P02.f2
    h_st_flow{ii} = figure('Visible','on');
    hPose = h_st_flow{ii}.Position;
    h_st_flow{ii}.Position = [hPos(1), hPos(2), imscale*hPos(3), imscale*hPos(4)];
    h_imgFlow = imagesc(IM1);
    colormap('gray');
    axis image off;
    %         ax = axes;
    hold on;
    % xp1 = p1f1{ii}(:,1) - p1f2{ii}(:,1);
    % yp1 = p1f1{ii}(:,2) - p1f2{ii}(:,2);
    % xp2 = p2f1{ii}(:,1) - p2f2{ii}(:,1);
    % yp2 = p2f1{ii}(:,2) - p2f2{ii}(:,2);
    hLines_p1 = line([p1f1{ii}(:,1) p1f2{ii}(:,1)]', [p1f1{ii}(:,2) p1f2{ii}(:,2)]');
    set(hLines_p1,'linewidth',2,'color','yellow');
    hLines_p2 = line([p2f1{ii}(:,1) p2f2{ii}(:,1)]', [p2f1{ii}(:,2) p2f2{ii}(:,2)]');
    set(hLines_p2,'linewidth',2,'color','green');
    plot(p1f1{ii}(:,1),p1f1{ii}(:,2),'or');
    plot(p2f1{ii}(:,1),p2f1{ii}(:,2),'om');
    plot(p1f2{ii}(:,1),p1f2{ii}(:,2),'xr');
    plot(p2f2{ii}(:,1),p2f2{ii}(:,2),'xm');
    hold off;
    title('im left: stereo flow left to right');
    %         axis(ax);
    saveas(gcf,savename_flow);
    %     end
    
end

end