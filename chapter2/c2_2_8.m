clc
clear all
syms x1 x2 y1 y2
format long g
xx=[x1 x2];
cov_x=[0.0157284669979442        0.0165651539873162
        0.0165651539873162        0.0177064713942392];
yy=[y1 y2];

yy= [1 0.3
     0 1] *[10*x1; exp(x2)];
 
G=[diff(yy(1),x1), diff(yy(1),x2)
 diff(yy(2),x1), diff(yy(2),x2)]  %G就是雅克比矩阵

%% 测试雅克比矩阵和泰勒一次展开的近似关系
dx=[0.001 0.001]';
x =[3 7]';
x1 = x(1);
x2 = x(2);

eval(G) * dx + eval(yy)

x = x + dx;
x1 = x(1);
x2 = x(2);

eval(yy)

%% 测试方差
R = [0.00151299278170381      0.000588889642618076
      0.000588889642618076      0.000729434523088569];

%理论新方差应该是
cov_y_gt = R + eval(G) * cov_x * eval(G)';

%实际方差需要估
%随机一些x的分布，计算一下，然后合并一下看看.
N = 10000; % 样本的数量
x =[3 7]';
mean_gt = eval(yy);
measurement = mvnrnd(x, cov_x, N);
y=ones(N,2);
for i = 1 : N
    tmp_x = measurement(i,:)';
    x1 = tmp_x(1);
    x2 = tmp_x(2);
    y(i,:)=eval(yy)'; % + mvnrnd([0,0], R, 1)'; %y也自带方差
end

%% 比较理论的均值，和我们求出来的均值
mean_gt
res=mean(y)'

%% 比较理论的协方差，和我们求出来结果的协方差
cov_y_gt
cov(y)
