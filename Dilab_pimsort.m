function [ Voltage Current Power Impedance ] = Dilab_pimsort(x)

Voltage = [x(:,2),x(:,3),x(:,4),x(:,5),x(:,6)];
Current = [x(:,7),x(:,8),x(:,9),x(:,10),x(:,11)];
Phase = [x(:,12),x(:,13),x(:,14),x(:,15),x(:,16)];

pi = 3.141592;

radian = Phase .* (pi/180);
Power = Voltage.*Current.*cos(radian);

Resistance = abs(Voltage)./abs(Current);
Zr = Resistance.*cos(radian);
Zi = Resistance.*sin(-(radian));
Impedance = sqrt((Zr.^2).*(Zi.^2));