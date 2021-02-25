function [H_sfm,t_sfm,xyz,c] = findSfMCameraPoses(modelPath)
% in: modelPath
% out: sequence of H for image, t - positions, xyz - 3D points of the
% scene, c = colour of said 3D points  (rgb values)
PLOT = false;

% read models
% fprintf('reading model path\n');
[cam, img, p3D] = read_model(modelPath);

% visualize model
if PLOT
    figure;
    plot_model(cam, img, p3D);
    title('Sparse model reconstruction (unscaled)');
    hold on;
    grid on;
    axis equal;
    box on;
    hold off;
end

% get point info (should be functions!)
nPts = p3D.Count;
keys = p3D.keys;
c = zeros(nPts,3);
xyz = zeros(nPts,3);
for i = 1:nPts
    ptId = keys{i};
    p(i) = p3D(ptId);
    xyz(i,:) = p(i).xyz;
    c(i,:) = single(p(i).rgb)./255;
end

% get camera centre info
keys = img.keys;
camera_centers = zeros(img.length, 3);
view_dirs = zeros(3 * img.length, 3);
for i = 1:img.length
    image_id = keys{i};
    image(i) = img(image_id);
    camera_centers(i,:) = -image(i).R' * image(i).t;
    view_dirs(3 * i - 2,:) = camera_centers(i,:);
    view_dirs(3 * i - 1,:) = camera_centers(i,:)' + image(i).R' * [0; 0; 0.3];
    view_dirs(3 * i,:) = nan;
end

% ideally, convert to homoegeneous transforms
H_img = zeros(4,4,img.length);
t_img = zeros(img.length,3);
for i = 1:img.length
    t_img(i,:) = -image(i).R' * image(i).t;
    H_img(:,:,i) = trvec2tform(t_img(i,:)) * rotm2tform(image(i).R'); % note the transpose
end

if PLOT
    % plot all frames of reference:
    figure
    plot3(camera_centers(:,1),camera_centers(:,2),camera_centers(:,3),'-.r');
    % axis equal
    hold on;
    % plot all 3D points!
    for i = 1:nPts
        plot3(xyz(i,1),xyz(i,2),xyz(i,3),'.','Color',c(i,:));
    end
    tLength = 0.5;
    for i = 1:img.length
        trplot(squeeze(H_img(:,:,i)),'color','blue','frame',num2str(i),'length',tLength);
    end
    
    hold off;
    grid on;
    box on;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title('Sequence of camera poses in Colmap frame (unfixed/unscaled)');
    axis square
end

% % check to see what we get just by plotting image.t:
% t = zeros(img.length,3);
% for i = 1:img.length
%     t(i,:) = image(i).t;
% end
% 
% figure;
% plot3(t(:,1),t(:,2),t(:,3),'-b');
% hold on;
% plot3(t(:,1),t(:,2),t(:,3),'ob');
% plot3(t_img(:,1),t_img(:,2),t_img(:,3),'or');
% plot3(t_img(:,1),t_img(:,2),t_img(:,3),'-r');
% xlabel('x');
% ylabel('y');
% zlabel('z');
% axis equal;
% box on;
% grid on;
% hold off;
% title('compare t vs timg');


%% manual scaling (false)
% DO_MANUAL_SCALING = false;
% if DO_MANUAL_SCALING
%     % show xyz point cloud, look for object width, find current distance,
%     % compare to known distance, scale. obviously, not very accurate, but
%     % it's all I've got at the moment!
%     figure;
%     pcshow(xyz,'MarkerSize',50);
%     title('refractive 3d points with pcshow');
%     xlabel('x');
%     ylabel('y');
%     zlabel('z');
%     box on;
%     grid on;
%     hold on;
%     
%     figure;
%     pcshow(xyzNonRefr,'MarkerSize',50);
%     title('nonRefractive 3d points with pcshow');
%     xlabel('x');
%     ylabel('y');
%     zlabel('z');
%     box on;
%     grid on;
%     hold on;
% 
%     switch expNum
%         case 1
%             scaleFactor = 1;
%         case 2
%             p1 = [1.355, 0.6507,19.62];
%             p2 = [0.4824,0.09918,19.53];
%             cylDiam = 0.04; % [m]
%             scaleFactor = cylDiam/sum((p1-p2).^2);
%     end
%     
%     % apply scale factor:
%     xyzSc = xyz.* scaleFactor;
%     
%     figure;
%     pcshow(xyzSc,'MarkerSize',50);
%     title('refractive 3d points with pcshow, scaled');
%     xlabel('x');
%     ylabel('y');
%     zlabel('z');
%     box on;
%     grid on;
%     hold on;
% end

H_sfm = H_img;
t_sfm = t_img;
%%