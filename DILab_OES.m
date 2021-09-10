clear
clc

%%%%%%%%%% single layer의 PCA & HMM EPD system %%%%%%%%%%
OES_p_end = 130;                                %예상 endpoint 지점 (etch rate에 계산된 예상 지점)
snr_interval = 10;                            % SNR을 비교할 구간의 범위이다. (이값은 사용자가 직접 입력하며 변경이 가능)
SNR_score = 2;                              % 여기서 설정한 SNR 이상의 파장을 선택하게 된다.

% 본 코드는 2 세트의 데이터를 트레이닝으로 이용해 모델링을 하게 되고 3번째 데이터를 이용해서 검증을 하게됩니다.
oes_data1 = xlsread('run2.csv');            % 트레이닝을 위한 OES 모델 데이터
oes_data2 = xlsread('run2.csv');            % 트레이닝을 위한 OES 모델 데이터
oes_data3 = xlsread('run1.csv');            % 실시간이라고 가정하여 입력하는 OES 데이터

%%%%%%%%%% data size 맞추기 %%%%%%%%%%
data1 = oes_data1(5:OES_p_end+60,:);
data2 = oes_data2(5:OES_p_end+60,:);
data3 = oes_data3(5:OES_p_end+60,:);

%%%%%%%%%% Select Wavelength %%%%%%%%%%
[w_time, wavelength] = size(data1);         % 이후에 사용할 matrix의 크기를 측정한다.
SNR = zeros(wavelength,1);                  % 모든 wavelength에 대하여 SNR값을 넣기위해 wavelength 크기만큼 zero(0)로 구성된 matrix를 만든다.
j=1;                                        % SNR로 선별할 파장의 갯수를 count하기 위한 j의 초기값이다.
data_model = (data1+data2)/2;
for i = 1 : wavelength
    before= data_model(20:20+snr_interval-1,i);      % 2에서 SNR_window의 크기까지 시간 데이터를 Before 변수에 넣는다
    after= data_model(OES_p_end+1:OES_p_end+1+snr_interval-1,i);   % 예상 EPD 지점에서 SNR_window의 크기까지 시간 데이터를 After 변수에 넣는다
    mean_B= mean2(before);                  % mean2 함수를 이용하여 평균을 구한다.
    mean_A= mean2(after);                   % mean2 함수를 이용하여 평균을 구한다.
    sd = std2(data_model(:,i));                  % std2 함수를 이용하여 standard deviation(표준편차)를 구한다.
    SNR(i)= (mean_B - mean_A) / sd;         % SNR 공식이다.
    
    if SNR(i) > SNR_score                   % SNR값이 2 이상인 byproduct 값을 골라내기위해 if 문을 사용하였고, 선택된 wavelength들로만 데이터를 새로 만들어줍니다.
        wave_Num(j)=i;                      % 몇번째 wavelength가 선택되었는지 확인하기위해 선택된 wavelength의 번호를 저장해줍니다.
        X_model(:,j)=data_model(:,i);       % X_model = selected data model
        X_real(:,j)=data3(:,i);             % X_real = selected data3
        j=j+1;                              % j가 하나씩 상승할 때 마다 X_1,X_2,X_3의 저장될 값의 위치가 이동한다.
    end
    yplot(:,i) = SNR_score;
end
w_num = j-1;                                % 선택된 wavelength의 갯수를 알 수 있다.

%%%%%%%%%% PCA 결과(OES) %%%%%%%%%%
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

fprintf('선택된 Wavelength 개수 : %d\n', w_num);
fprintf('예상한 End Point : %d\n', OES_p_end);
fprintf('계산된 End Point : %d\n', OES_EPD);