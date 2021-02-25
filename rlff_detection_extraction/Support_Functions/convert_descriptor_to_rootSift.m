function [descriptorsOut] = convert_descriptor_to_rootSift(descriptorsIn)
% https://www.pyimagesearch.com/2015/04/13/implementing-rootsift-in-python-and-opencv/
% It is well known that when comparing histograms the Euclidean distance 
% often yields inferior performance than when using the chi-squared distance
% or the Hellinger kernel [Arandjelovic et al. 2012]

%  to compute RootSIFT is:
% Step 1: Compute SIFT descriptors using your favorite SIFT library.
% Step 2: L1-normalize each SIFT vector.
% Step 3: Take the square root of each element in the SIFT vector. Then the vectors are L2 normalized

x = double(descriptorsIn); % norm doesn't work on uint8 input

x=x'; 
for i=1:size(x,2)
    x(:,i)=sqrt(x(:,i)/norm(x(:,i),1)); 
end
x=x';
descriptorsOut = x;

end

