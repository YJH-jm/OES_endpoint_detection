clear
clc

%%%%%%%%%% single layer�� PCA & HMM EPD system %%%%%%%%%%
OES_p_end = 130;                                %���� endpoint ���� (etch rate�� ���� ���� ����)
snr_interval = 10;                            % SNR�� ���� ������ �����̴�. (�̰��� ����ڰ� ���� �Է��ϸ� ������ ����)
SNR_score = 2;                              % ���⼭ ������ SNR �̻��� ������ �����ϰ� �ȴ�.

% �� �ڵ�� 2 ��Ʈ�� �����͸� Ʈ���̴����� �̿��� �𵨸��� �ϰ� �ǰ� 3��° �����͸� �̿��ؼ� ������ �ϰԵ˴ϴ�.
oes_data1 = xlsread('run2.csv');            % Ʈ���̴��� ���� OES �� ������
oes_data2 = xlsread('run2.csv');            % Ʈ���̴��� ���� OES �� ������
oes_data3 = xlsread('run1.csv');            % �ǽð��̶�� �����Ͽ� �Է��ϴ� OES ������

%%%%%%%%%% data size ���߱� %%%%%%%%%%
data1 = oes_data1(5:OES_p_end+60,:);
data2 = oes_data2(5:OES_p_end+60,:);
data3 = oes_data3(5:OES_p_end+60,:);

%%%%%%%%%% Select Wavelength %%%%%%%%%%
[w_time, wavelength] = size(data1);         % ���Ŀ� ����� matrix�� ũ�⸦ �����Ѵ�.
SNR = zeros(wavelength,1);                  % ��� wavelength�� ���Ͽ� SNR���� �ֱ����� wavelength ũ�⸸ŭ zero(0)�� ������ matrix�� �����.
j=1;                                        % SNR�� ������ ������ ������ count�ϱ� ���� j�� �ʱⰪ�̴�.
data_model = (data1+data2)/2;
for i = 1 : wavelength
    before= data_model(20:20+snr_interval-1,i);      % 2���� SNR_window�� ũ����� �ð� �����͸� Before ������ �ִ´�
    after= data_model(OES_p_end+1:OES_p_end+1+snr_interval-1,i);   % ���� EPD �������� SNR_window�� ũ����� �ð� �����͸� After ������ �ִ´�
    mean_B= mean2(before);                  % mean2 �Լ��� �̿��Ͽ� ����� ���Ѵ�.
    mean_A= mean2(after);                   % mean2 �Լ��� �̿��Ͽ� ����� ���Ѵ�.
    sd = std2(data_model(:,i));                  % std2 �Լ��� �̿��Ͽ� standard deviation(ǥ������)�� ���Ѵ�.
    SNR(i)= (mean_B - mean_A) / sd;         % SNR �����̴�.
    
    if SNR(i) > SNR_score                   % SNR���� 2 �̻��� byproduct ���� ��󳻱����� if ���� ����Ͽ���, ���õ� wavelength��θ� �����͸� ���� ������ݴϴ�.
        wave_Num(j)=i;                      % ���° wavelength�� ���õǾ����� Ȯ���ϱ����� ���õ� wavelength�� ��ȣ�� �������ݴϴ�.
        X_model(:,j)=data_model(:,i);       % X_model = selected data model
        X_real(:,j)=data3(:,i);             % X_real = selected data3
        j=j+1;                              % j�� �ϳ��� ����� �� ���� X_1,X_2,X_3�� ����� ���� ��ġ�� �̵��Ѵ�.
    end
    yplot(:,i) = SNR_score;
end
w_num = j-1;                                % ���õ� wavelength�� ������ �� �� �ִ�.

%%%%%%%%%% PCA ���(OES) %%%%%%%%%%
nX = DIL_Normalize(X_model);
loading_vector = Dilab_PCA(nX);
OES_PCA_model = X_model*loading_vector;
OES_PCA_real = X_real*loading_vector;

%%%%%%%%%% Modeling (OES) %%%%%%%%%%
[ intercept_OES ] = Dilab_regression_OES(OES_PCA_model, OES_p_end);

for i = 1 : w_time
    
	OES_state_transition(i,1) = (intercept_OES(1,1)*(i))+intercept_OES(1,2);
	OES_state_transition(i,2) = (intercept_OES(2,1)*(i))+intercept_OES(2,2);
    OES_state_transition(i,3) = (intercept_OES(1,4)*(i^3))+(intercept_OES(1,5)*(i^2))+(intercept_OES(1,6)*(i))+intercept_OES(1,7);
    OES_state_transition(i,4) = (intercept_OES(2,4)*(i^3))+(intercept_OES(2,5)*(i^2))+(intercept_OES(2,6)*(i))+intercept_OES(2,7);
    
end

%%%%%%%%%% HMM(OES) %%%%%%%%%%
OES_EPD(1,1) = Dilab_HMM(OES_PCA_real,OES_PCA_model,OES_p_end,OES_state_transition(:,1:2));

%%%%%%%% plots%%%%%%%%
figure(1)
plot(OES_PCA_model);    grid on, title('OES data');

figure(2)
subplot(211),plot(X_real), grid on, set(gcf,'Color',[1,1,1]), title('Selected OES data(using SNR)')
subplot(212),plot(SNR),hold on, plot(yplot), grid on, title('SNR')

figure(3)
plot(OES_PCA_real),hold on, plot(OES_state_transition(:,1:2)),hold on, plot(OES_EPD(1,1),OES_PCA_real(OES_EPD(1,1),1),'+r'), grid on, set(gcf,'Color',[1,1,1])
title('Result');

fprintf('���õ� Wavelength ���� : %d\n', w_num);
fprintf('������ End Point : %d\n', OES_p_end);
fprintf('���� End Point : %d\n', OES_EPD);