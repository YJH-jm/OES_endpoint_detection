function Y = Dilab_PCA(X)

[time, Wavenum] = size(X);

cov_X = cov(X);

[Evect, Eval] = eig(cov_X);

Evector = Evect(:,Wavenum);

Y = Evector;