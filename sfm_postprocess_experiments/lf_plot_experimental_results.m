% lf_plot_experimental_results

% TODO load specific case name first
% eg, Output/201007_default_sparse.mat

PLOT = true;

% input:
RLFF_MONO = true;
RLFF_STEREO = true;
SIFT_MONO = true;
SIFT_STEREO = true;


 %% plotting:
    
    if PLOT
        
        if true
            figure;
            %     ptCloud = pointCloud(xyz_stereo_sc(:,1:3),'color',stereo.c);
            %     pcshow(ptCloud);
            %     plot3(xyz_stereo_sc(:,1), xyz_stereo_sc(:,2), xyz_stereo_sc(:,3),'.');
            h_scatter = scatter3(rlff_stereo.xyz(:,1),rlff_stereo.xyz(:,2),rlff_stereo.xyz(:,3),4,sfm_rlff_stereo.xyz_colour,'o');
            
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
            saveRlffStereoReconstructionFilename = ['Output/' exp_name '_rlffStereo_sfm_reconstruction.pdf'];
            plotFigAsPdf(gcf,saveRlffStereoReconstructionFilename);
            
        end
        
        %% plot pose sequences
        saveTrajectory = ['Output/' exp_name '_pose_trajectory.pdf'];
        % saveas(gcf,'Output/poseReconstructionsCompared.png');
        
        % import custom colours
        custom_colours
        tLength = 0.0025;
        th = 3;
        PLOT_CAM_FRUSTUM = true;
        camSize = 0.003;
         
        figure;
        hold on;
        if SIFT_MONO && RLFF_STEREO
            if (sfm_sift_mono.did_converge == true) && (sfm_rlff_stereo.did_converge == true)
                plot3(t_gt(:,1),t_gt(:,2),t_gt(:,3),':b',...
                    sift_mono.t(:,1),sift_mono.t(:,2),sift_mono.t(:,3),':g',...
                    rlff_stereo.t(:,1),rlff_stereo.t(:,2),rlff_stereo.t(:,3),':r','LineWidth',2);
                hLeg = legend('groundtruth','2D SIFT','synthetic stereo RLFF','Location','best');
            elseif (sfm_rlff_stereo.did_converge == true)
                plot3(t_gt(:,1),t_gt(:,2),t_gt(:,3),':b',...
                    rlff_stereo.t(:,1),rlff_stereo.t(:,2),rlff_stereo.t(:,3),':r','LineWidth',2);
                hLeg = legend('groundtruth','synthetic stereo RLFF','Location','best');
            elseif (sfm_sift_mono.did_converge == true)
                plot3(t_gt(:,1),t_gt(:,2),t_gt(:,3),':b',...
                     sift_mono.t(:,1), sift_mono.t(:,2), sift_mono.t(:,3),':g','LineWidth',2);
                hLeg = legend('groundtruth','2D SIFT','Location','best');
                
            end
            hLeg.FontSize = 10;
            rect = [0.10, 0.10, 0.18, 0.12];
            hLeg.Position = rect;
            
            for ii=1:nImg
                if PLOT_CAM_FRUSTUM
                    camRotate = eul2rotm([0 pi 0]);
                    cam_gt = plotCamera('Location',t_gt(ii,:),'Orientation',camRotate * tform2rotm(T_gt(:,:,ii)),...
                        'Size',camSize,'Color','blue');
                    absPose_mono = rigid3d(camRotate * eul2rotm(tform2eul(sift_mono.T_togt(:,:,ii))),sift_mono.t(ii,:));
                    cam_mono = plotCamera('AbsolutePose',absPose_mono,...
                        'Size',camSize,'Color',darkGreen);
                    cam_stereo = plotCamera('Location',rlff_stereo.t(ii,:),'Orientation',camRotate * tform2rotm(rlff_stereo.T_togt(:,:,ii)),...
                        'Size',camSize,'Color','red');
                else
                    trplot(squeeze(T_gt(:,:,ii)),'color','blue','frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
                    trplot(squeeze(sift_mono.T_togt(:,:,ii)),'color',darkGreen,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
                    trplot(squeeze(rlff_stereo.T_togt(:,:,ii)),'color','red','frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
                end
            end
            
        elseif SIFT_MONO && ~RLFF_STEREO
            % just rpint stereo
            plot3(t_gt(:,1),t_gt(:,2),t_gt(:,3),'-ob',...
                sift_mono.t(:,1),sift_mono.t(:,2),sift_mono.t(:,3),'-o','color',darkGreen);
            for ii=1:nImg
                trplot(squeeze(T_gt(:,:,ii)),'color','blue','frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
                trplot(squeeze(sift_mono.T_togt(:,:,ii)),'color',darkGreen,'frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
            end
            
        else
            % plot to check scales
            plot3(t_gt(:,1),t_gt(:,2),t_gt(:,3),'-ob');
            plot3(rlff_stereo.t(:,1),rlff_stereo.t(:,2),rlff_stereo.t(:,3),'-or');
            for ii = 1:nImg
                trplot(squeeze(rlff_stereo.T_togt(:,:,ii)),'color','red','frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
                trplot(squeeze(T_gt(:,:,ii)),'color','blue','frame',num2str(ii),'length',tLength,'thick',th,'text_opts',{'FontSize',7});
            end
            title('stereo sfm (centre) scaled to GT');
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
        plotFigAsPdf(gcf,saveTrajectory);
        
       
        
        if false
            % plot time history of pose
            
            figure;
            subplot(3,1,1)
            if TRY_MONO && TRY_STEREO
                plot(x_img,rel_t_gt(:,1),'-ob',x_img,rel_t_sc(:,1),'-or',x_img,rel_t_mono(:,1),'-og');
            elseif TRY_MONO && ~TRY_STEREO
                plot(x_img,rel_t_gt(:,1),'-ob',x_img,rel_t_mono(:,1),'-og');
            else % just stereo
                plot(x_img,rel_t_gt(:,1),'-ob',x_img,rel_t_sc(:,1),'-or');
            end
            
            ylabel('x [m]');
            title('time histories of relative positions');
            legend('gt','synth stereo RLFF');
            grid on; box on;
            
            subplot(3,1,2)
            if TRY_MONO && TRY_STEREO
                plot(x_img,rel_t_gt(:,2),'-ob',x_img,rel_t_sc(:,2),'-or',x_img,rel_t_mono(:,2),'-og');
            elseif TRY_MONO && ~TRY_STEREO
                plot(x_img,rel_t_gt(:,2),'-ob',x_img,rel_t_mono(:,2),'-og');
            else
                plot(x_img,rel_t_gt(:,2),'-ob',x_img,rel_t_sc(:,2),'-or');
            end
            ylabel('y [m]');
            grid on; box on;
            
            subplot(3,1,3)
            if TRY_MONO && TRY_STEREO
                plot(x_img,rel_t_gt(:,3),'-ob',x_img,rel_t_sc(:,3),'-or',x_img,rel_t_mono(:,3),'-og');
            elseif TRY_MONO && ~TRY_STEREO
                plot(x_img,rel_t_gt(:,3),'-ob',x_img,rel_t_mono(:,3),'-og');
            else
                plot(x_img,rel_t_gt(:,3),'-ob',x_img,rel_t_sc(:,3),'-or');
            end
            ylabel('z [m]');
            grid on; box on;
            xlabel('frame #');
        end
        
        %%
        
        % plot time history of pose errors:
        hFig = figure;
        hPos = hFig.Position;
        % x y width height
        set(gcf,'Position',[hPos(1), hPos(2), hPos(3)*1.0, 0.5*hPos(4)]);
        hold on;
        if SIFT_MONO && RLFF_STEREO
            plot(x_img,rlff_stereo.err_t_inst_total','-r','LineWidth',2);
            plot(x_img,sift_mono.err_t_inst_total',':','color',darkGreen,'LineWidth',2);
            legend('synth stereo','2D sift','location','north');
        elseif SIFT_MONO && ~RLFF_STEREO
            plot(x_img,sift_mono.err_t_inst_total','-g','LineWidth',2);
        else
            plot(x_img,rlff_stereo.err_t_inst_total','-r','LineWidth',2);
        end
        hold off;
        grid on;
        box on;
        xlabel('frame #');
        ylabel('inst pos error [m]');
        [ax1] = figureTightBorders(gca);
        saveError = ['Output/' exp_name '_pose_trajectory_error.pdf'];
        plotFigAsPdf(gcf,saveError);
        
        
    end