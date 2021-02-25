function [kk, ll, uu, vv, ss, tt] = lf_4D_plane_using_P(ii,jj,P,D,H)

h11 = H(1,1);
h13 = H(1,3);
h15 = H(1,5);
h22 = H(2,2);
h24 = H(2,4);
h25 = H(2,5);
h31 = H(3,1);
h33 = H(3,3);
h35 = H(3,5);
h42 = H(4,2);
h44 = H(4,4);
h45 = H(4,5);

% if H operates on absolute coordinates, not relative, then...
% U = u + s;
% V = v + t;

Px = P(1);
Py = P(2);
Pz = P(3);

% relative coordinates
kk = -(D*h15 + Pz*h35 - D*Px + D*h11*ii + Pz*h31*ii)/(D*h13 + Pz*h33);
ll = -(D*h25 + Pz*h45 - D*Py + D*h22*jj + Pz*h42*jj)/(D*h24 + Pz*h44);
uu = (D*(Px*h33 + h13*h35 - h15*h33 - h11*h33*ii + h13*h31*ii))/(D*h13 + Pz*h33);
vv = (D*(Py*h44 + h24*h45 - h25*h44 - h22*h44*jj + h24*h42*jj))/(D*h24 + Pz*h44);

% absolute coordinates?
% kk = -(D*h15 - 2*Pz*h15 + Pz*h35 - D*Px + D*h11*ii - 2*Pz*h11*ii + Pz*h31*ii)/(D*h13 - 2*Pz*h13 + Pz*h33);
% ll = -(D*h25 - 2*Pz*h25 + Pz*h45 - D*Py + D*h22*jj - 2*Pz*h22*jj + Pz*h42*jj)/(D*h24 - 2*Pz*h24 + Pz*h44);
% uu = -(D*Px*h13 - D*Px*h33 - D*h13*h35 + D*h15*h33 + Pz*h13*h35 - Pz*h15*h33 + D*h11*h33*ii - D*h13*h31*ii - Pz*h11*h33*ii + Pz*h13*h31*ii)/(D*h13 - 2*Pz*h13 + Pz*h33);
% vv = -(D*Py*h24 - D*Py*h44 - D*h24*h45 + D*h25*h44 + Pz*h24*h45 - Pz*h25*h44 + D*h22*h44*jj - D*h24*h42*jj - Pz*h22*h44*jj + Pz*h24*h42*jj)/(D*h24 - 2*Pz*h24 + Pz*h44);

ss = -(Pz*uu - D*Px)/D;
tt = -(Pz*vv - D*Py)/D;

end