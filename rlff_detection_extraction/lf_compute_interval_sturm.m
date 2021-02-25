% function lf_compute_interval_sturm.m
% given the eigenvalues, eigenvectors and stuv observations, find the 2 3D
% points that define the interval of sturm
function [P01, P1, P02, P2] = lf_compute_interval_sturm(H,stuv0,stuv,eig_vec,eig_val,D)

% eigenvectors, eig_vec1 = [a1 b1 c1];
%               eig_vec2 = [a2 b2 c2];
% eigenvalues eig_val1, eig_val2
% r0 = [s0 t0 u0 v0] the principal ray, the ray pointing to our
% image feature from the central view of the LF
% r = [s t u v] the other rays from all the other sub-aperture
% images in the LF
% let the lines in 3D corresponding to the astigmatic lens
% feature axes be defined by: (this is the general equation for
% a line defined by 2 points, a direction vector and a scalar)
% P1 = P01 + eig_vec1 * k
% where
% P1 = some point on line 1, which will be set to the
% intersection with r
% P01 = the point on line 1 that intersects with the principal
% ray r0
% where k is some scalar that belongs to the reals

% with the slopes (eigenvalues), we can compute the depth of
% the point relative to the LF camera

% solve for P1(x,y,z),P2(x,y,z), given all stuv observations
% and s0,t0,u0,v0

%% parameters

SMALL_NUMBER = 10e-6;


%% unpack variables
% rename them explicitly for ease of reading

s0 = stuv0(1)';
t0 = stuv0(2)';
u0 = stuv0(3)';
v0 = stuv0(4)';
s = stuv(:,1)';
t = stuv(:,2)';
u = stuv(:,3)';
v = stuv(:,4)';
eig_vec1 = eig_vec(:,1);
eig_vec2 = eig_vec(:,2);
eig_val1 = eig_val(1);
eig_val2 = eig_val(2);

nPts = length(s);


%% solve for P1, P01
% for z1 = z01, we assume the axes are parallel with the st- and uv-planes
% though it might be interesting to put an angle on this. I
% think the system of equations would still be solvable, and
% would enable us to handle axes that are not perpendicular to
% r0
z01 = -D/eig_val1 * ones(1,nPts);
z1 = z01;
x1 = u .* z1 / D + s;
y1 = v .* z1 / D + t;
P1 = [x1; y1; z1];

% solve for k:
% due to the possibility of divide by zero, we choose to divide
% by the largest in absolute magnitude from the eigenvector
% elements
% what do we do if there is only 1 non-zero eigenvalue? k or m
% will be infinity...?

% if abs(eig_vec2(1)) > abs(eig_vec2(2))
%     if abs(eig_vec2(1)) > SMALL_NUMBER
%         k = ( (u - u0) .* z01 ./ D + s - s0) ./ eig_vec2(1); % both equations should yield the same k
%     else
%         k = zeros(1,app.nPts);
%     end
% else
%     if abs(eig_vec2(2)) > SMALL_NUMBER
%         k = ( (v - v0) .* z01 ./ D + t - t0) ./ eig_vec2(2);
%     else
%         k = zeros(1,nPts);
%     end
% end

% P01 from the central view:
z01c = -D/eig_val1;
x01c = (u0 * z01c / D) + s0;
y01c = (v0 * z01c / D) + t0;
P01c = [x01c; y01c; z01c];

% one of the goals though is to find P01 using all stuv observations
% we would have to travel from P1 along line1 (P01c + eig_vec1 *k) using k
% solve for P01:
% x01 = x1 - ( x01c + eig_vec2(1) .* k );
% y01 = y1 - ( y01c + eig_vec2(2) .* k);
% z01 = z1 + ( 0 + zeros(1) .* k );
% P01_rays = [x01; y01; z01];

%% solve for P2, P02
z02 = -D/eig_val2 * ones(1,nPts);
z2 = z02;
x2 = u .* z2 / D + s;
y2 = v .* z2 / D + t;
P2 = [x2; y2; z2];

% solve for m
% if abs(eig_vec1(1)) > abs(eig_vec1(2))
%     if abs(eig_vec1(1)) > SMALL_NUMBER
%         m = ((u - u0) .* z02 / D + s) ./ eig_vec1(1);
%     else
%         m = zeros(1,nPts);
%     end
% else
%     if abs(eig_vec1(2)) > SMALL_NUMBER
%         m = ((v - v0) .* z02 / D + t) ./ eig_vec1(2);
%     else
%         m = zeros(1,nPts);
%     end
% end

% P02 from the central view:
z02c = -D/eig_val2;
x02c = (u0 * z02c / D) + s0;
y02c = (v0 * z02c / D) + t0;
P02c = [x02c; y02c; z02c];

% solve for P2:
% x02 = x2 - (x02c + eig_vec1(1) .* m);
% y02 = y2 - (y02c + eig_vec1(2) .* m);
% z02 = z2 - (0 + zeros(1) .* m);
% P02_rays = [x02; y02; z02];

% consider averaging P01 and P02?
% P01_mean = P01_rays; % mean(P01,1);
% P02_mean = P02_rays; % mean(P02,1);



%% solve directly for P01 and P02

% Get the correct XY location for the feature
% ---Derivation---
% 	[uv]' = (v*d*v^-1) * [st]'; % without translation, relative 2pp
% 	[uv]' = (v*d*v^-1) * [1,0,-Px;0,1,-Py] * [st1]'; % with translation: move s,t; u,v are relative only
% 	[uv]' = (v*d*v^-1) * X * [st1]'; % with translation: move s,t; u,v are relative only
% 	Hest = (v*d*v^-1)*X;
% 	X = (v*d*v^-1)^-1*Hest
% 	Pxy = -X(1:2,3);
% or just compute the translation part
% 	Pxy = -Hest(1:2,1:2)^-1 * Hest(:,3)
% 	Pxy = -(v*d*v^-1)^-1 * Hest(:,3)
% ---end derivation---

% this is the most accurate approach, because using the offset from H
% H(:,3) is using the best-fit v,d result to reduce noise
% and this is only one calculation (from calculations that we've already
% done) over redoing ray-tracing calculations all over again

% following Don's derivation from xVisAstig.m

eig_val_matrix = diag(eig_val);
Pxy = -inv(eig_vec * eig_val_matrix * inv(eig_vec)) * H(:,3);
Pz12 = -D./eig_val;

P01 = [Pxy(1:2); Pz12(1)];
P02 = [Pxy(1:2); Pz12(2)];



end