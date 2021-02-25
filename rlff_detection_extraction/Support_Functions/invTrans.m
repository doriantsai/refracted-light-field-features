function invT = invTrans(T)
% assume T is a homogeneous transform

if isobject(T) && ismatrix(T)
    invT = [T.R', -T.R'*T.t;
    0 0 0 1];
elseif ismatrix(T) && (sum(size(T)==[4,4]) ==2)
R = T(1:3,1:3);
t = T(1:3,4);
invT = [R', -R'*t;
    0 0 0 1];
else
    disp('ERROR: invTrans, input not matrix/object of correct size');
end