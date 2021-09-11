function [ intercept_PIM ] = Dilab_regression_PIM( X, p_end)
Y = X(p_end-49:p_end+50,:);
[t,n] = size(Y);

before_time = [1:1:50-2]';
after_time = [50+2:1:t]';
before_y = Y(1:50-2,:);
after_y = Y(50+2:t,:);

intercept_PIM(1,:) = polyfit(before_time,before_y(:,1),1);
intercept_PIM(2,:) = polyfit(after_time,after_y(:,1),1);
intercept_PIM(3,:) = polyfit(before_time,before_y(:,2),1);
intercept_PIM(4,:) = polyfit(after_time,after_y(:,2),1);
intercept_PIM(5,:) = polyfit(before_time,before_y(:,3),1);
intercept_PIM(6,:) = polyfit(after_time,after_y(:,3),1);
intercept_PIM(7,:) = polyfit(before_time,before_y(:,4),1);
intercept_PIM(8,:) = polyfit(after_time,after_y(:,4),1);



intercept_PIM(1,4:7) = polyfit(before_time,before_y(:,1),3);
intercept_PIM(2,4:7) = polyfit(after_time,after_y(:,1),3);
intercept_PIM(3,4:7) = polyfit(before_time,before_y(:,2),3);
intercept_PIM(4,4:7) = polyfit(after_time,after_y(:,2),3);
intercept_PIM(5,4:7) = polyfit(before_time,before_y(:,3),3);
intercept_PIM(6,4:7) = polyfit(after_time,after_y(:,3),3);
intercept_PIM(7,4:7) = polyfit(before_time,before_y(:,4),3);
intercept_PIM(8,4:7) = polyfit(after_time,after_y(:,4),3);