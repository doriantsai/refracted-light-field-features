function [fig_handles] = lf_plot_experimental_results_method(gt,meth_all,colors,filenames)
% lf_plot_experimental_results_single
% plot for groundtruth and method (general), with color options

fig_handles = [];

%% parameters
custom_colours
% colors = darkGreen; % from custom_colours

% number of images for exp_name
nImg = gt.n;

% filenames:
filenames.sparse = [ meth_all.exp_name '_' meth_all.method_name '_sfmSparse.pdf'];
filenames.trajectory = [ meth_all.exp_name '_' meth_all.method_name '_sfmPoseTrajectory.pdf'];
filenames.posError = [ meth_all.exp_name '_' meth_all.method_name '_sfmPositionError.pdf'];
filenames.oriError = [ meth_all.exp_name '_' meth_all.method_name '_sfmOrientationError.pdf'];


%% sparse reconstruction plot

if meth_all.sfm.did_converge == true
    fig_handles.sparse = figure;
    h_sparse = scatter3(meth_all.gt_aligned.xyz(:,1),meth_all.gt_aligned.xyz(:,2),meth_all.gt_aligned.xyz(:,3),4,meth_all.sfm.xyz_colour,'o');
    grid on;
    box on;
    axis equal;
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    % title('3D points from synthetic stereo RLFF');
    view(0,-75)
    camorbit(20,0,'camera');
    % axis tight;
    % [ax1] = figureTightBorders(gca);
    plotFigAsPdf(fig_handles.sparse,filenames.sparse);
    
    
    %% pose sequence plot
    
    tLength = 0.0025;
    th = 3;
    PLOT_CAM_FRUSTUM = true;
    camSize = 0.003;
    
    fig_handles.trajectory = figure;
    hold on;
    % plot trajectory positions:
    plot3(gt.t(:,1),gt.t(:,2),gt.t(:,3),':b','Linewidth',2);
    plot3(meth_all.gt_aligned.t(:,1),meth_all.gt_aligned.t(:,2),meth_all.gt_aligned.t(:,3),':','color',colors,'LineWidth',2);
    hLeg = legend('groundtruth',meth_all.str_name,'Location','best');
    hLeg.FontSize = 10;
    rect = [0.10, 0.10, 0.18, 0.12]; % I think this hardcodes the position wrt the figure
    hLeg.Position = rect;
    
    for ii=1:nImg
        if PLOT_CAM_FRUSTUM
            camRotate = eul2rotm([0 pi 0]);
            cam_gt = plotCamera('Location',gt.t(ii,:),'Orientation',camRotate * tform2rotm(gt.T_togt(:,:,ii)),...
                'Size',camSize,'Color','blue');
            absPose_meth = rigid3d(camRotate * eul2rotm(tform2eul(meth_all.gt_aligned.T_togt(:,:,ii))),meth_all.gt_aligned.t(ii,:));
            cam_meth = plotCamera('AbsolutePose',absPose_meth,...
                'Size',camSize,'Color',colors);
        else
            trplot(squeeze(gt.T(:,:,ii)),'color','blue','frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
            trplot(squeeze(meth_all.gt_aligned.T_togt(:,:,ii)),'color',colors,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
        end
    end
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
    drawnow;
    axis tight;
    [ax1] = figureTightBorders(gca);
    plotFigAsPdf(gcf,filenames.trajectory);
    
    
    %% time history of pose errors:
    
    % instantaneous position errors
    fig_handles.posError = figure;
    hPos = fig_handles.posError.Position;
    % x y width height
    set(gcf,'Position',[hPos(1), hPos(2), hPos(3)*1.0, 0.5*hPos(4)]);
    hold on;
    plot(1:(nImg-1),meth_all.gt_aligned.err_t_inst_total','-','color',colors,'LineWidth',2);
    hold off;
    grid on;
    box on;
    xlabel('frame #');
    ylabel('inst pos error [m]');
    [ax1] = figureTightBorders(gca);
    % saveError = ['Output/' exp_name '_pose_trajectory_error.pdf'];
    plotFigAsPdf(fig_handles.posError,filenames.posError);
    
    % instantaneous orientation errors
    
else
    print(['exp_name = ' meth_all.exp_name ', method = ' meth_all.method_name ', did not converge.']);
end

end