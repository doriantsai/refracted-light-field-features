function lf_plot_experimental_results_combined(gt,sift_mono,sift_stereo,rlff_mono,rlff_stereo,colors)
% lf_plot_experimental_results_combined
% assuming that all 4 methods converged, plot all 4 methods together on the
% same plots
% TODO: could do an if converged, then plot

%% parameters

custom_colours

% number of LFs for experiment
nImg = gt.n;

% filenames:
combined_str = 'combined';
% filenames.sparse = [ gt.exp_name '_' combined_str '_sfmSparse.pdf'];
filenames.trajectory = [ gt.exp_name '_' combined_str '_sfmPoseTrajectory.pdf'];
filenames.posError = [ gt.exp_name '_' combined_str '_sfmPositionError.pdf'];
filenames.oriError = [ gt.exp_name '_' combined_str '_sfmOrientationError.pdf'];

% for variable legend length/names, create a vector:
% 1 = sift_mono, 2 = sift_stereo, 3 = rlff_mono, 4 = rlff_stereo
method_conv = false(4,1);
if sift_mono.sfm.did_converge == true
    SIFT_MONO = true;
    method_conv(1) = true;
else
    SIFT_MONO = false;
end
if sift_stereo.sfm.did_converge == true
    SIFT_STEREO = true;
    method_conv(2) = true;
else
    SIFT_STEREO = false;
end
if rlff_mono.sfm.did_converge == true
    RLFF_MONO = true;
    method_conv(3) = true;
else
    RLFF_MONO = false;
end
if rlff_stereo.sfm.did_converge == true
    RLFF_STEREO = true;
    method_conv(4) = true;
else
    RLFF_STEREO = false;
end
nConv = sum(method_conv);

% create legend str:
method_str{1} = sift_mono.str_name;
method_str{2} = sift_stereo.str_name;
method_str{3} = rlff_mono.str_name;
method_str{4} = rlff_stereo.str_name;

leg_str = cell(1);
iLeg = 1;
for ii = 1:length(method_str)
    if method_conv(ii) == true
        leg_str{iLeg} = method_str{ii};
        iLeg = iLeg + 1;
    end
end


%% sparse reconstruction plot:
% skip - not useful to combine sparse reconstruction plots with given tools

%% trajectory/pose sequence plot:

tLength = 0.0025;
th = 3;
PLOT_CAM_FRUSTUM = true;
camSize = 0.001;

figure;
hold on;
% plot trajectory positions:
% plot groundtruth
groundtruthgreen = [0.47,0.67,0.19];
plot3(gt.t(:,1),gt.t(:,2),gt.t(:,3),':', 'color',groundtruthgreen,'Linewidth',2);

if SIFT_MONO
    plot3(sift_mono.gt_aligned.t(:,1),sift_mono.gt_aligned.t(:,2),sift_mono.gt_aligned.t(:,3),':','color',colors.sift_mono,'LineWidth',2);
end
if SIFT_STEREO
   plot3(sift_stereo.gt_aligned.t(:,1),sift_stereo.gt_aligned.t(:,2),sift_stereo.gt_aligned.t(:,3),':','color',colors.sift_stereo,'LineWidth',2);
end 
if RLFF_MONO
   plot3(rlff_mono.gt_aligned.t(:,1),rlff_mono.gt_aligned.t(:,2),rlff_mono.gt_aligned.t(:,3),':','color',colors.rlff_mono,'LineWidth',2);
end 
if RLFF_STEREO
   plot3(rlff_stereo.gt_aligned.t(:,1),rlff_stereo.gt_aligned.t(:,2),rlff_stereo.gt_aligned.t(:,3),':','color',colors.rlff_stereo,'LineWidth',2);
end 



% plot camera frustums/coordinate frames
for ii=1:nImg
    if PLOT_CAM_FRUSTUM
        camRotate = eul2rotm([0 pi 0]);
        cam_gt = plotCamera('Location',gt.t(ii,:),'Orientation',camRotate * tform2rotm(gt.T(:,:,ii)),...
            'Size',camSize,'Color',groundtruthgreen);
        
        if SIFT_MONO
            absPose_meth = rigid3d(camRotate * eul2rotm(tform2eul(sift_mono.gt_aligned.T_togt(:,:,ii))),sift_mono.gt_aligned.t(ii,:));
            cam_sift_mono = plotCamera('AbsolutePose',absPose_meth,...
                'Size',camSize,'Color',colors.sift_mono);
        end
        if SIFT_STEREO
            absPose_meth = rigid3d(camRotate * eul2rotm(tform2eul(sift_stereo.gt_aligned.T_togt(:,:,ii))),sift_stereo.gt_aligned.t(ii,:));
            cam_sift_stereo = plotCamera('AbsolutePose',absPose_meth,...
                'Size',camSize,'Color',colors.sift_stereo);
        end
        if RLFF_MONO
            absPose_meth = rigid3d(camRotate * eul2rotm(tform2eul(rlff_mono.gt_aligned.T_togt(:,:,ii))),rlff_mono.gt_aligned.t(ii,:));
            cam_rlff_mono = plotCamera('AbsolutePose',absPose_meth,...
                'Size',camSize,'Color',colors.rlff_mono);
        end
        if RLFF_STEREO
            absPose_meth = rigid3d(camRotate * eul2rotm(tform2eul(rlff_stereo.gt_aligned.T_togt(:,:,ii))),rlff_stereo.gt_aligned.t(ii,:));
            cam_rlff_stereo = plotCamera('AbsolutePose',absPose_meth,...
                'Size',camSize,'Color',colors.rlff_stereo);
        end
        
    else
        % plot coordinate frames instead of camera frustums
        trplot(squeeze(gt.T(:,:,ii)),'color',groundtruthgreen,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
        
        if SIFT_MONO
            trplot(squeeze(sift_mono.gt_aligned.T_togt(:,:,ii)),'color',colors.sift_mono,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
        end
        if SIFT_STEREO
            trplot(squeeze(sift_stereo.gt_aligned.T_togt(:,:,ii)),'color',colors.sift_stereo,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
        end
        if RLFF_MONO
            trplot(squeeze(rlff_mono.gt_aligned.T_togt(:,:,ii)),'color',colors.rlff_mono,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
        end
        if RLFF_STEREO
            trplot(squeeze(rlff_stereo.gt_aligned.T_togt(:,:,ii)),'color',colors.rlff_stereo,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
        end
    end
end

% legendZ
legTrajStr = cell(nConv+1,1);
legTrajStr{1} = 'groundtruth';
legTrajStr(2:nConv+1) = leg_str;
hLeg = legend(legTrajStr,'Location','best');
hLeg.FontSize = 10;
rect = [0.10, 0.65, 0.18, 0.12]; % I think this hardcodes the position wrt the figure
hLeg.Position = rect;

hold off;
grid on;
box on;
axis equal
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
viewAngle1 = -35;
viewAngle2 = 40;
view(viewAngle1,viewAngle2);
axis tight;
[ax1] = figureTightBorders(gca);
% zticks([zt(start), zt(round(length(zt)/2)), zt(end)]);
zticks([0.126, 0.13, 0.134]);
yticks([0.275, 0.285, 0.295]);

drawnow;
save2pdf(filenames.trajectory,gcf,300);
% plotFigAsPdf(gcf,filenames.trajectory);

%% time history of pose errors:

% instantaneous position errors
fig_PE = figure;
hPos = fig_PE.Position;
set(gcf,'Position',[hPos(1), hPos(2), hPos(3)*0.5, 0.55*hPos(4)]);
hold on;
if SIFT_MONO
    plot(1:(nImg-1),sift_mono.gt_aligned.err_t_inst_total' * 10^3,'-','color',colors.sift_mono,'LineWidth',2);
end
if SIFT_STEREO
    plot(1:(nImg-1),sift_stereo.gt_aligned.err_t_inst_total' * 10^3,'-','color',colors.sift_stereo,'LineWidth',2);
end
if RLFF_MONO
    plot(1:(nImg-1),rlff_mono.gt_aligned.err_t_inst_total' * 10^3,'-','color',colors.rlff_mono,'LineWidth',2);
end
if RLFF_STEREO
    plot(1:(nImg-1),rlff_stereo.gt_aligned.err_t_inst_total' * 10^3,'-','color',colors.rlff_stereo,'LineWidth',2);
end
hold off;
grid on;
box on;
axis tight
xlabel('frame #');
ylabel('position error [mm]');
% do we need to have all combinations for the legend?
% hLeg = legend(leg_str,'Location','northwest', 'NumColumns', 2);
% hLeg.FontSize = 10;


[ax1] = figureTightBorders(gca);
% saveError = ['Output/' exp_name '_pose_trajectory_error.pdf'];
% plotFigAsPdf(fig_PE,filenames.posError);
save2pdf(filenames.posError,fig_PE,300);

% instantaneous orientation errors
fig_OE = figure;
hPos = fig_OE.Position;
set(gcf,'Position',[hPos(1), hPos(2), hPos(3)*0.5, 0.55*hPos(4)]);
hold on;
if SIFT_MONO
    plot(1:(nImg-1), rad2deg(sift_mono.gt_aligned.err_o_inst_total'),'-','color',colors.sift_mono,'LineWidth',2);
end
if SIFT_STEREO
    plot(1:(nImg-1), rad2deg(sift_stereo.gt_aligned.err_o_inst_total'),'-','color',colors.sift_stereo,'LineWidth',2);
end
if RLFF_MONO
    plot(1:(nImg-1), rad2deg(rlff_mono.gt_aligned.err_o_inst_total'),'-','color',colors.rlff_mono,'LineWidth',2);
end
if RLFF_STEREO
    plot(1:(nImg-1),rad2deg(rlff_stereo.gt_aligned.err_o_inst_total'),'-','color',colors.rlff_stereo,'LineWidth',2);
end
hold off;
grid on;
box on;
axis tight
xlabel('frame #');
ylabel('orientation error [deg]');
% do we need to have all combinations for the legend?
% hLeg = legend(leg_str,'Location','east', 'NumColumns', 2);
hLeg = legend(leg_str,'Location','east');
hLeg.FontSize = 10;

[ax1] = figureTightBorders(gca);
% saveError = ['Output/' exp_name '_pose_trajectory_error.pdf'];
% plotFigAsPdf(fig_OE,filenames.oriError);
save2pdf(filenames.oriError,fig_OE,300);


end