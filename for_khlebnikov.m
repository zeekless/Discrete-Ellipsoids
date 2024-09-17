clear all; close all;

gamma = 0.2;

A =  [0.9950  0.0050 0.0998 0.0002;
      0.0050  0.9950 0.0002 0.0998;
     -0.0997  0.0997 0.9950 0.0050;
      0.0997 -0.0997 0.0050 0.9950];

B =  [0.0050;
      0.0000;
      0.0998;
      0.0002];

C1 = [1 0 0 0;
      0 1 0 0]; 

C2 = [0 0 1 0;
      0 0 0 1];

% Исходные матрицы D и D1 умножены на гамма с целью нормировки |w|<=1

D =  [0.0050 0      0;
      0      0.0050 0;
      0.0998 0.0002 0;
      0.0002 0.0998 0]*gamma; 

D1 = [0 0 0;
      0 0 1]*gamma; 

D2 = [0; 0];

n=size(A,1);

alpha_all = []; trace_all = [];

% Одномерная оптимизация по параметру альфа на промежутке (0,1)
for a = 0.002 : 0.001 : 0.999

    % Наилучший регулятор для каждого значения альфа
    Q = idare(A,B,a/(1-a)*C2'*C2,a/(1-a)*D2'*D2,0,sqrt(a)*eye(n));
    P = idare(A',C1',a/(1-a)*D*D',a/(1-a)*D1*D1',0,sqrt(a)*eye(n));
    K = -inv(B'*Q*B+a/(1-a)*D2'*D2)*B'*Q*A;
    L = A*P*C1'*inv(C1*P*C1'+a/(1-a)*D1*D1');
    
    % Размер соответствующего ограничивающего эллипсоида
    % (Для оптимального регулятора эта величина совпадает с tr_opt,
    % вычисленной ниже)
    tr = trace(D'*Q*D)+trace(K*P*K'*((1-a)/a*B'*Q*B + D2'*D2));

    alpha_all = [alpha_all a]; 
    trace_all = [trace_all tr];
end

% Выбираем наилучшее альфа (дающее наименьший размер эллипсоида)
[~, idx] = min(trace_all);
a = alpha_all(idx);

% Наилучший регулятор для наилучшего альфа
Q = idare(A,B,a/(1-a)*C2'*C2,a/(1-a)*D2'*D2,0,sqrt(a)*eye(n));
P = idare(A',C1',a/(1-a)*D*D',a/(1-a)*D1*D1',0,sqrt(a)*eye(n));
K = -inv(B'*Q*B+a/(1-a)*D2'*D2)*B'*Q*A;
L = A*P*C1'*inv(C1*P*C1'+a/(1-a)*D1*D1');

% Замкнутая система
CC = [C2+D2*K -D2*K];
DD = [D; D+L*D1];
AA = [A+B*K, -B*K; zeros(n,n), A-L*C1];

% Матрица оптимального эллипсоида
P = dlyap(AA,a/(1-a)*DD*DD',[],sqrt(a)*eye(2*n)); 

% Размер оптимального эллипсоида
tr_opt = trace(CC*P*CC') 

