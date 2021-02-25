function [uv] = lf_4D_plane(P,D,st)
% 4D plane equation of a Lambertian point
% given P (3D point), D (reference plane distance) and s,t
% output uv 
% note: relative frame of reference, continuous units

uv = (D/P(3)) * [P(1) - st(1); P(2) - st(2)];
end
