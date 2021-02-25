% lf_plot_single_rlff(LFS{ii},ray_ftr,ftr_list,idx_ftr,rlff);
function lf_plot_single_rlff(LFS,ray_ftr,ftr_list,idx_ftr,rlff,varargin)

%% defaults

default_fig_name_2D = 'lf_fig_single_rlff_2D.png';
default_fig_title_2D = 'rlff: projection from st to uv';
default_fig_name_3D = 'lf_fig_single_rlff_3D.pdf';
default_fig_title_3D = 'rlff: rlff in 3D';

%% parse input

p = inputParser;
addRequired(p,'LFS',@isstruct);
addRequired(p,'ray_ftr',@iscell);
addRequired(p,'ftr_list',@isnumeric);
addRequired(p,'idx_ftr',@isnumeric);
addRequired(p,'rlff',@isstruct);

addParameter(p,'fig_name_2D',default_fig_name_2D,@isstr);
addParameter(p,'fig_title_2D',default_fig_title_2D,@isstr);
addParameter(p,'fig_name_3D',default_fig_name_3D,@isstr);
addParameter(p,'fig_title_3D',default_fig_title_3D,@isstr);

parse(p,LFS,ray_ftr,ftr_list,idx_ftr,rlff,varargin{:});
LFS = p.Results.LFS;
ray_ftr = p.Results.ray_ftr;
ftr_list = p.Results.ftr_list;
idx_ftr = p.Results.idx_ftr;
rlff = p.Results.rlff;

fig_name_2D = p.Results.fig_name_2D;
fig_title_2D = p.Results.fig_title_2D;
fig_name_3D = p.Results.fig_name_3D;
fig_title_3D = p.Results.fig_title_3D;

fs = 14; % font size for plots

%% 
custom_colours % add custom colours for plots

SMALL_NUMBER = 10e-6;
range_smaller_factor = 0.75; % extend depth of rays, both forwards and backwards by some range factors
range_larger_factor = 1.25;

LF = LFS.LF;
D = LFS.D;
nT = size(LF,1); % potential confusion between stuv and ijkl notation
nS = size(LF,2);
sC = round(nS/2);
tC = round(nT/2);

st = rlff.st_h(1:2,:);
uv = rlff.uv;

nPts = size(st,2);

%% 2D plot
% show same 2D plot like in simulation
h_2D = figure;
hold on;
for jj = 1:size(st,2)
    plot([st(1,jj) uv(1,jj)],[st(2,jj) uv(2,jj)],'r-'); 
end

plot(uv(1,:),uv(2,:),'.','color','black','MarkerSize',10);
plot(uv(1,:),uv(2,:),'.','color','cyan','MarkerSize',5);

plot(st(1,:),st(2,:),'b.');
hold off;
axis equal
grid on;
box on;
xlabel('x');
ylabel('y');

% plot axes from ED on h_2D
r1Axes = rlff.eig_vec(:,1) .* [-1 1];
r2Axes = rlff.eig_vec(:,2) .* [-1 1];

% scale the axes according to the max distance from centre view wrt uv
uv_c = rlff.stuv0(3:4);
dist_from_centre_view = sqrt(sum( (uv - uv_c').^2,1));
max_uvdist_from_centre = max( dist_from_centre_view );
axes_scale = max_uvdist_from_centre*0.75;

H_offset = rlff.H(:,3);

% for the purposes of plotting, normalise eigenvalues to 1
eig_val = rlff.eig_val; 
eig_val_n = eig_val / norm(eig_val);

% x,y values of the lines that will illustrate the axes, scaled to fit
x_ev1_slope = H_offset(1) + axes_scale * eig_val_n(1) * r1Axes(1,:);
y_ev1_slope = H_offset(2) + axes_scale * eig_val_n(1) * r1Axes(2,:);
x_ev2_slope = H_offset(1) + axes_scale * eig_val_n(2) * r2Axes(1,:);
y_ev2_slope = H_offset(2) + axes_scale * eig_val_n(2) * r2Axes(2,:);

hold on;
plot(x_ev1_slope,y_ev1_slope,'.-','color',darkPurple,'linewidth',3);
plot(x_ev2_slope,y_ev2_slope,'.-','color',purple,'linewidth',3);
hold off;

saveas(gcf,fig_name_2D);

%% 3D plot
% show same 3D plot like in simulation

% choose the smaller z, make it even smaller, then choose the larger z and
% make it even bigger (reversed for negatives)
if abs(eig_val(1)) > SMALL_NUMBER
    z1 = -D/eig_val(1);
else
    z1 = 0; 
    disp('warning: eig_val(1) < SMALL_NUMBER');
end
if abs(eig_val(2)) > SMALL_NUMBER
    z2 = -D/eig_val(2);
else
    z2 = 1;
    disp('warning: eigenValues_ED(2) < SMALL_NUMBER')
end

if abs(z1) > abs(z2)
    z1Range = z1 * range_larger_factor;
    if z2 > 0
        z2Range = z2 * range_smaller_factor;
    else
        z2Range = z2 * range_larger_factor;
    end
else
    if z1 > 0
        z1Range = z1 * range_smaller_factor;
    else
        z1Range = z1 * range_larger_factor;
    end
    z2Range = z2 * range_larger_factor;
end

% set z1Range to 0, so rays go all the way?
z1Range = -0.1;
z1Range_v = z1Range * ones(1,nPts);
z2Range_v = z2Range * ones(1,nPts);

x1 = z1Range_v .* uv(1,:)/D + st(1,:);
y1 = z1Range_v .* uv(2,:)/D + st(2,:);
x2 = z2Range_v .* uv(1,:)/D + st(1,:);
y2 = z2Range_v .* uv(2,:)/D + st(2,:);


h_3D = figure;
hold on;
ax_3D = gca;
p3 = plot3(ax_3D, [x1; x2], [y1; y2], [z1Range_v; z2Range_v],'-','color',lightGray);
nlines = size(p3);
nlines = nlines(1);

for i = 1:nlines
    p3(i).Color(4) = 0.25;
end
% alpha(ax_3D, 0.1)


plot3(ax_3D, st(1,:),st(2,:),zeros(size(st(2,:))),'.b','linewidth',1, 'MarkerSize',6); % camera positions

% hold off;
% axis equal
% axis square
box on;
grid on;


% try to scale z, such that we get roughly a cube...
% d = ax_3D.DataAspectRatio;
% find the max xy-distance between views
% find the max xy-distance between rays
% scale z-data accordingly, such that z-data/max_xy = 1
% hopefully, this will form more of a box/cubed plot, which shows up much
% better in matlab then 1 really long axis
st_c = rlff.stuv0(1:2);
st_dist_from_centre_view = sqrt(sum( (st - st_c').^2,1));
max_st_dist_from_centre = max(st_dist_from_centre_view);

s0 = rlff.stuv0(1);
t0 = rlff.stuv0(2);
u0 = rlff.stuv0(3);
v0 = rlff.stuv0(4);

% add second plane uv:
D2 = 0.1;
x_uv = D2 * uv(1,:)/D + st(1,:);
y_uv = D2 * uv(2,:)/D + st(2,:);
plot3(ax_3D,x_uv,y_uv,D2*ones(size(x_uv)),'.','color',darkGreen, 'linewidth', 1, 'MarkerSize', 6);

% take farther (from st-plane) distance for max_xy_dist
if abs(z1Range) > abs(z2Range)
    % take x1,y1
    x_c = z1Range * u0/D + s0;
    y_c = z1Range * v0/D + t0;
    xy = [x1; y1];
    zFar = z1Range;
else
    % take x2,y2
    x_c = z2Range * u0/D + s0;
    y_c = z2Range * v0/D + t0;
    xy = [x2; y2];
    zFar = z2Range;
end
xy_c = [x_c y_c]';
xy_dist_from_centreray = sqrt(sum( (xy - xy_c).^2,1));
max_xy_dist_from_centreray = max(xy_dist_from_centreray);

xy_dist = 1*max([max_st_dist_from_centre, max_xy_dist_from_centreray]);
z_scale_factor = xy_dist/zFar;




% plot 3D intersections of points onto 3D plot:
% hold on;
% plot3(ax_3D,rlff.P01(1,:),rlff.P01(2,:),rlff.P01(3,:),'o','color',darkCyan,'LineWidth',4); % should be all the same pt along the principal ray
plot3(ax_3D,rlff.P1(1,:),rlff.P1(2,:),rlff.P1(3,:),'.c','LineWidth',2); % should form a line

% plot3(ax_3D,rlff.P02(1,:),rlff.P02(2,:),rlff.P02(3,:),'o','color',darkPurple,'LineWidth',4); 
plot3(ax_3D,rlff.P2(1,:),rlff.P2(2,:),rlff.P2(3,:),'.','color',purple,'LineWidth',2);
hold off;

% plot RLFF
% see plot interval of sturm!
nPts_ray = 100;

% central ray, that runs from s0t0u0v0 through the interval of Sturm
zMin = ax_3D.ZLim(1);
zMax = ax_3D.ZLim(2);
central_ray = zeros(3,nPts_ray);
central_ray(3,:) = linspace(zMin,zMax,nPts_ray);
central_ray(1,:) = u0 .* central_ray(3,:)/D + s0;
central_ray(2,:) = v0 .* central_ray(3,:)/D + t0;

P01_mean = mean(rlff.P01,2);
P02_mean = mean(rlff.P02,2);


interval_Sturm = zeros(3,nPts_ray);
interval_Sturm(3,:) = linspace(P01_mean(3),P02_mean(3),nPts_ray);
interval_Sturm(1,:) = u0 .* interval_Sturm(3,:) / D + s0; 
interval_Sturm(2,:) = v0 .* interval_Sturm(3,:) / D + t0;

hold(ax_3D,'on');
plot3(ax_3D,central_ray(1,:),central_ray(2,:),central_ray(3,:),'--','color','black','linewidth',2);
plot3(ax_3D,interval_Sturm(1,:),interval_Sturm(2,:),interval_Sturm(3,:),'-','color','red','LineWidth',3);
plot3(ax_3D,interval_Sturm(1,[1,end]),interval_Sturm(2,[1,end]),interval_Sturm(3,[1,end]),'o','color','black','LineWidth',6);
plot3(ax_3D,interval_Sturm(1,[1,end]),interval_Sturm(2,[1,end]),interval_Sturm(3,[1,end]),'o','color','yellow','LineWidth',4);
hold(ax_3D,'off');

xlabel('x [m]', 'FontSize', fs);
ylabel('y [m]', 'FontSize', fs);
zlabel('z [m]','FontSize', fs);

% axis square % this adjusts pbaspect such that the figure appears as a square in the figure!


axis tight
axis square
% pbaspect manual

% pbaspect manual
% pbaspect([1 1 z_scale_factor]);
% pbaspect([1, 1, 0.5]);

% axis square
% da = daspect;
% da

% daspect manual
% daspect([2, 1, 44])
% da = daspect;
% da

% 
% pb = pbaspect;
% pb
% pbaspect([1 1 1]);

% view(-90, 0);
view(50, 9);


% dtheta = 0; % horizontal viewing axis
% dphi = 90; % vertical viewing axis
% direction = [0, 0, 1];
% coordsys = [0, 0, 0];
% camorbit(dtheta, dphi, coordsys ,direction);


% saveas(gcf,fig_name_3D);

[ax1] = figureTightBorders(gca);
% saveas(gcf,savefilename);
% plotFigAsPdf(gcf,fig_name_3D);
save2pdf(fig_name_3D,gcf,300)

% take a second image:
disp('taking second image');
view(125, 9);
axis tight;
axis square;
% [ax2] = figureTightBorders(gca);

fig_name_3D2 = fig_name_3D(1:end-4);
fig_name_3D2 = strcat(fig_name_3D2, '-2.pdf'); 
save2pdf(fig_name_3D2, gcf, 300);

% take a second image:
disp('taking second image');
view(125, 9);
axis tight;
axis square;
% [ax2] = figureTightBorders(gca);

% take third/general iamge:
disp('taking third image');
view(10, 20);
fig_name_3D3 = fig_name_3D(1:end-4);
fig_name_3D3 = strcat(fig_name_3D3, '-1020.pdf'); 
save2pdf(fig_name_3D3, gcf, 300);

end









