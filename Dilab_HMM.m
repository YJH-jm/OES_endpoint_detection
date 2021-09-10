function endpoint = Dilab_HMM(X,model,p_end,Est)
[w_time , n ] = size(X);
%%%%%%%%%% Hidden Markov Model %%%%%%%%%%
delay = 5;
PI = 3.141592;
Sum_Prob1 = 0.0;
Sum_Prob2 = 0.0;

%%%%%%%%%% CALCULATE SIGMA and OBSERVATION MODEL%%%%%%%%%%
Prob_1 = zeros(w_time,1);
Prob_2 = zeros(w_time,1);
sigma1 = 0.0; sigma2 = 0.0;

%%%%%%%%%% Real-Time Process %%%%%%%%%%
Y = model;

for i = 1 : w_time
    if i < p_end
		sigma1 = sigma1 + power(Est(i,1) - Y(i,1), 2);
    else
		sigma2 = sigma2 + power(Est(i,2) - Y(i,1), 2);
    end
end

sigma_1 = sigma1 / p_end;
sigma_2 = sigma2 / (w_time - p_end);

%%%%%%%%%% Real-Time Process %%%%%%%%%%
Y_1 = X;                                  %real-time으로 PCA를 한 결과입니다.

%%%%%%%%%% CALCULATE VITERBI %%%%%%%%%%
flag = 0;
Viterbi_1 = zeros(w_time);
Viterbi_2 = zeros(w_time, w_time-1);

duration_sigma = power(p_end * 0.2 / 3 , 2);            % normal distribution 의 center 값의 20%인 3sigma로 duration sigma를 만들어줍니다.

for i = 1 : w_time
	Prob_1(i) = (-0.5 * log(2 * PI * sigma_1)) - (power(Y_1(i,1) - Est(i,1), 2) / (2 * sigma_1));
	Prob_2(i) = (-0.5 * log(2 * PI * sigma_2)) - (power(Y_1(i,1) - Est(i,2), 2) / (2 * sigma_2));

	Sum_Prob1 = Sum_Prob1 + Prob_1(i);
	Viterbi_1(i) = (-0.5 * log(2 * PI * duration_sigma)) - (power(i + 1 - p_end, 2)/(2 * duration_sigma)) + Sum_Prob1;

	if i == 1
		Viterbi_2(i,1) = -10000;
    else
		l = 1;
		for j = 1 : i
			Viterbi_2(i,j) = Viterbi_1(j);
			
			for k = i : -1 : l
				Viterbi_2(i,j) = Viterbi_2(i,j) + Prob_2(k);
            end
            l = l + 1;
        end
        
        
        %%%%%%%%%% Detecting %%%%%%%%%%
		if (i > delay && Viterbi_2(i, l-delay) > Viterbi_2(i, l-1))
            if flag == 0
				endpoint = i;
                flag = 1;
            end
        end
    end
end