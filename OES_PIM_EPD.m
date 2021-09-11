clear
clc

%%%%%%%%%% single layer�� PCA & HMM EPD system %%%%%%%%%%
OES_p_end = 270;                                %���� endpoint ���� (etch rate�� ���� ���� ����)
snr_interval = 10;                            % SNR�� ���� ������ �����̴�. (�̰��� ����ڰ� ���� �Է��ϸ� ������ ����)
SNR_score = 2.5;                              % ���⼭ ������ SNR �̻��� ������ �����ϰ� �ȴ�.

% �� �ڵ�� 2 ��Ʈ�� �����͸� Ʈ���̴����� �̿��� �𵨸��� �ϰ� �ǰ� 3��° �����͸� �̿��ؼ� ������ �ϰԵ˴ϴ�.
oes_data1 = xlsread('run2.csv');            % Ʈ���̴��� ���� OES �� ������
oes_data2 = xlsread('run2.csv');            % Ʈ���̴��� ���� OES �� ������
oes_data3 = xlsread('run2.csv');            % �ǽð��̶�� �����Ͽ� �Է��ϴ� OES ������

pim_data1 = load('run2.txt');               % Ʈ���̴��� ���� PIM �� ������
pim_data2 = load('run2.txt');               % Ʈ���̴��� ���� PIM �� ������
pim_data3 = load('run2.txt');               % �ǽð��̶�� �����Ͽ� �Է��ϴ� PIM ������

%%%%%%%%%% data size ���߱� %%%%%%%%%%
data1 = oes_data1(5:OES_p_end+60,:);
data2 = oes_data2(5:OES_p_end+60,:);
data3 = oes_data3(5:OES_p_end+60,:);
data4 = pim_data1(5:OES_p_end+60,:);
data5 = pim_data2(5:OES_p_end+60,:);
data6 = pim_data3(5:OES_p_end+60,:);

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
OES_EPD(2,1) = Dilab_HMM(OES_PCA_real,OES_PCA_model,OES_p_end,OES_state_transition(:,3:4));

PIM_p_end = OES_EPD(2,1);                  %% PIM�� ���� EPD�� �Է��� �Ǵ� �κ�

%%%%%%%%%% PIM data arrange %%%%%%%%%%
[ voltage1 current1 power1 impedance1 ] = Dilab_pimsort(data4);
[ voltage2 current2 power2 impedance2 ] = Dilab_pimsort(data5);
fundamental_PIM1 = [ voltage1(:,1), current1(:,1), power1(:,1), impedance1(:,1) ];
fundamental_PIM2 = [ voltage2(:,1), current2(:,1), power2(:,1), impedance2(:,1) ];
fundamental_PIM_model = (fundamental_PIM1+fundamental_PIM2)/2;

[ voltage3 current3 power3 impedance3 ] = Dilab_pimsort(data6);
fundamental_PIM_real = [ voltage3(:,1), current3(:,1), power3(:,1), impedance3(:,1) ];

%%%%%%%%%% Modeling (PIM) %%%%%%%%%%
[ intercept_PIM ] = Dilab_regression_PIM( fundamental_PIM_model, PIM_p_end);

for i = 1 : 100
    
    PIM_state_transition(i,1) = (intercept_PIM(1,1)*(i))+intercept_PIM(1,2);
    PIM_state_transition(i,2) = (intercept_PIM(2,1)*(i))+intercept_PIM(2,2);
    
    PIM_state_transition(i,3) = (intercept_PIM(3,1)*(i))+intercept_PIM(3,2);
    PIM_state_transition(i,4) = (intercept_PIM(4,1)*(i))+intercept_PIM(4,2);
    
    PIM_state_transition(i,5) = (intercept_PIM(5,1)*(i))+intercept_PIM(5,2);
    PIM_state_transition(i,6) = (intercept_PIM(6,1)*(i))+intercept_PIM(6,2);
    
    PIM_state_transition(i,7) = (intercept_PIM(7,1)*(i))+intercept_PIM(7,2);
    PIM_state_transition(i,8) = (intercept_PIM(8,1)*(i))+intercept_PIM(8,2);
    
    PIM_state_transition(i,9) = (intercept_PIM(1,4)*(i^3))+(intercept_PIM(1,5)*(i^2))+(intercept_PIM(1,6)*(i))+intercept_PIM(1,7);
    PIM_state_transition(i,10) = (intercept_PIM(2,4)*(i^3))+(intercept_PIM(2,5)*(i^2))+(intercept_PIM(2,6)*(i))+intercept_PIM(2,7);
    
    PIM_state_transition(i,11) = (intercept_PIM(3,4)*(i^3))+(intercept_PIM(3,5)*(i^2))+(intercept_PIM(3,6)*(i))+intercept_PIM(3,7);
    PIM_state_transition(i,12) = (intercept_PIM(4,4)*(i^3))+(intercept_PIM(4,5)*(i^2))+(intercept_PIM(4,6)*(i))+intercept_PIM(4,7);
    
    PIM_state_transition(i,13) = (intercept_PIM(5,4)*(i^3))+(intercept_PIM(5,5)*(i^2))+(intercept_PIM(5,6)*(i))+intercept_PIM(5,7);
    PIM_state_transition(i,14) = (intercept_PIM(6,4)*(i^3))+(intercept_PIM(6,5)*(i^2))+(intercept_PIM(6,6)*(i))+intercept_PIM(6,7);
    
    PIM_state_transition(i,15) = (intercept_PIM(7,4)*(i^3))+(intercept_PIM(7,5)*(i^2))+(intercept_PIM(7,6)*(i))+intercept_PIM(7,7);
    PIM_state_transition(i,16) = (intercept_PIM(8,4)*(i^3))+(intercept_PIM(8,5)*(i^2))+(intercept_PIM(8,6)*(i))+intercept_PIM(8,7);
    
end

%%%%%%%%%% HMM(PIM) %%%%%%%%%% 
PIM_model = fundamental_PIM_model(PIM_p_end-49:PIM_p_end+50,:);
PIM_real = fundamental_PIM_real(PIM_p_end-49:PIM_p_end+50,:);

PIM_EPD(1,1) = Dilab_HMM(PIM_real(:,1),PIM_model(:,1),50,PIM_state_transition(:,1:2));
PIM_EPD(1,2) = Dilab_HMM(PIM_real(:,2),PIM_model(:,2),50,PIM_state_transition(:,3:4));
PIM_EPD(1,3) = Dilab_HMM(PIM_real(:,3),PIM_model(:,3),50,PIM_state_transition(:,5:6));
PIM_EPD(1,4) = Dilab_HMM(PIM_real(:,4),PIM_model(:,4),50,PIM_state_transition(:,7:8));

PIM_EPD(2,1) = Dilab_HMM(PIM_real(:,1),PIM_model(:,1),50,PIM_state_transition(:,9:10));
PIM_EPD(2,2) = Dilab_HMM(PIM_real(:,2),PIM_model(:,2),50,PIM_state_transition(:,11:12));
PIM_EPD(2,3) = Dilab_HMM(PIM_real(:,3),PIM_model(:,3),50,PIM_state_transition(:,13:14));
PIM_EPD(2,4) = Dilab_HMM(PIM_real(:,4),PIM_model(:,4),50,PIM_state_transition(:,15:16));

EPD = [OES_EPD,PIM_EPD-50+PIM_p_end];

%%%%%%%% plots%%%%%%%%
figure(1)
subplot(211),plot(SNR),hold on, plot(yplot), grid on
subplot(212),plot(X_real), grid on, set(gcf,'Color',[1,1,1])

figure(2)
subplot(211),plot(OES_PCA_real),hold on, plot(OES_state_transition(:,1:2)),hold on, plot(OES_EPD(1,1),OES_PCA_real(OES_EPD(1,1),1),'+r'), grid on, set(gcf,'Color',[1,1,1])
subplot(212),plot(OES_PCA_real),hold on, plot(OES_state_transition(:,3:4)),hold on, plot(OES_EPD(2,1),OES_PCA_real(OES_EPD(2,1),1),'+r'), grid on, set(gcf,'Color',[1,1,1])

figure(3)
subplot(221),plot(PIM_real(:,1)),hold on, plot(PIM_state_transition(:,1:2)),hold on, plot(PIM_EPD(1,1),PIM_real(PIM_EPD(1,1),1),'+r'), grid on
subplot(222),plot(PIM_real(:,2)),hold on, plot(PIM_state_transition(:,3:4)),hold on, plot(PIM_EPD(1,2),PIM_real(PIM_EPD(1,2),2),'+r'), grid on
subplot(223),plot(PIM_real(:,3)),hold on, plot(PIM_state_transition(:,5:6)),hold on, plot(PIM_EPD(1,3),PIM_real(PIM_EPD(1,3),3),'+r'), grid on
subplot(224),plot(PIM_real(:,4)),hold on, plot(PIM_state_transition(:,7:8)),hold on, plot(PIM_EPD(1,4),PIM_real(PIM_EPD(1,4),4),'+r'), grid on, set(gcf,'Color',[1,1,1])

figure(4)
subplot(221),plot(PIM_real(:,1)),hold on, plot(PIM_state_transition(:,9:10)),hold on, plot(PIM_EPD(2,1),PIM_real(PIM_EPD(2,1),1),'+r'), grid on
subplot(222),plot(PIM_real(:,2)),hold on, plot(PIM_state_transition(:,11:12)),hold on, plot(PIM_EPD(2,2),PIM_real(PIM_EPD(2,2),2),'+r'), grid on
subplot(223),plot(PIM_real(:,3)),hold on, plot(PIM_state_transition(:,13:14)),hold on, plot(PIM_EPD(2,3),PIM_real(PIM_EPD(2,3),3),'+r'), grid on
subplot(224),plot(PIM_real(:,4)),hold on, plot(PIM_state_transition(:,15:16)),hold on, plot(PIM_EPD(2,4),PIM_real(PIM_EPD(2,4),4),'+r'), grid on, set(gcf,'Color',[1,1,1])


