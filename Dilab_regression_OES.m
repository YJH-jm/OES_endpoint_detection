function [ intercept_OES ] = Dilab_regression_OES(X, p_end)
[t_OES,n_OES] = size(X);

before_time_OES = [1:1:p_end-2]';
after_time_OES = [p_end+2:1:t_OES]';
before_x_OES = X(1:p_end-2);
after_x_OES = X(p_end+2:t_OES);

intercept_OES(1,:) = polyfit(before_time_OES,before_x_OES,1);
intercept_OES(2,:) = polyfit(after_time_OES,after_x_OES,1);

intercept_OES(1,4:7) = polyfit(before_time_OES,before_x_OES,3);
intercept_OES(2,4:7) = polyfit(after_time_OES,after_x_OES,3);