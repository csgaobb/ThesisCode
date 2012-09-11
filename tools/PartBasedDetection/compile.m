mex -O resize.cc
mex -O dt.cc
mex -O features.cc
mex -O getdetections.cc
mex -O features_hog.cc
mex -O features_lbpmex.cc
% use one of the following depending on your setup
% 1 is fastest, 3 is slowest 

% 1) multithreaded convolution using blas
% mex -O fconvblas.cc -lmwblas -o fconv
% 2) mulththreaded convolution without blas
% mex -O fconvMT.cc -o fconv
% 3) basic convolution, very compatible
mex -O fconv.cc -o fconv
unix('g++ -m64 learn.cc -o learn.out');
