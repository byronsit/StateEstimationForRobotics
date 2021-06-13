clc
clear all

p0=[ 0.131696158563955        0.0489861322989466
        0.0489861322989466         0.038082413891165];      % 起点的协方差
x_init = mvnrnd([0,0], p0, 1); % 起点位置

%假设车沿着y=10*sin(x)方向走，100个时刻.轨迹

t=[0:0.1:10]';

%随着时间变化的100个真值。
x_gt = 10*sin(t);  
x_gt = [x_gt 10*t];
 T=[1 0.3
    0.7 0.5];
x_gt = (T*x_gt')';


%% 初始化一些参数
%预估方差 process noise
Qk = [0.229343002339173         0.265716902218622
         0.265716902218622         0.309181125798839];
     
%观测方差 measurement noise
Rk = [0.113178900124737        0.0433648339106839
        0.0433648339106839        0.0999370559197836];

Q=zeros(200,200);
for i = 1 : 100
    for o = 1 : 2
        for p = 1 : 2
            nx = 2 * i - 1 + o - 1;
            ny = 2 * i - 1 + p - 1;
            Q(nx,ny) = Qk(o,p);
            R(nx,ny) = Rk(o,p);
        end
    end
end
for o = 1 : 2
    for p = 1 : 2
        Q(o,p) = p0(o,p);
        R(o,p) = Rk(o,p);
    end
end
    

N = 101; %100组数据
y_measure = x_gt + mvnrnd([0,0], Rk, N); %观测是有方差的
y=zeros(200,1) % y是构建符合要求的向量
for i = 1: 100
    y(i*2-1) = y_measure(i,1);
    y(i*2) = y_measure(i,2);
end


%构造v，很复杂很累。就是每个时刻的速度向量
v=zeros(200,1);
for i = 1 : 99
    tmp = x_gt(i+1,:) - x_gt(i,:)  %输入信号v没有方差
    
    t=((i-0.75)/10);
    xx=[10*sin(t)
        10*t]';
    xx = (T*xx')';

    tmp = (xx- x_gt(i,:))*4;
    v(2*i+1) = tmp(1);
    v(2*i+2) = tmp(2);
end
v(1) = x_init(1);
v(2) = x_init(2);

plot(y_measure(:,1), y_measure(:,2),'-*','color',[1,0,0])
hold on;

%% 显然开始模拟书上代码
% 显然在这样的模型中，所有的A小矩阵都完全一样，都是单位矩阵，那么整个大A矩阵就是一个下三角都是1的矩阵
A=tril(ones(200,200));
for i = 1 : 200
    for j = 1 : 200
        if xor(mod(i,2), mod(j,2)) == 1
            A(i,j)=0;
        end
    end
end
C=eye(200,200);          %每个小c都是单位矩阵，拼在一起还是单位矩阵
x_check = A*v;

for i = 1 : 200
    if mod( i,2) == 0
        yy(i/2) = x_check(i);
    else
        xx((i+1)/2) = x_check(i);
    end
end
plot(xx,yy,'-x','color',[0,0,1])
hold on
plot(x_gt(:,1), x_gt(:,2),'-v','color',[0,1,0])


P_check = A*Q*A';







%% 协方差(3.28)到(3.29) 协方差部分相等
a=inv(inv(P_check) + C'*inv(R)*C);
b=P_check-P_check*C'*inv(C*P_check*C'+R)*C*P_check
max(max(a-b)') %约等于0，两个式子相等

%% 
x_hat=x_check + P_check*C'*(C*P_check*C' + R)^-1 * (y-C*x_check)
for i = 1 : 200
    if mod( i,2) == 0
        x_hat_y(i/2) = x_hat(i);
    else
        x_hat_x((i+1)/2) = x_hat(i);
    end
end
plot(x_hat_x,x_hat_y,'-O','color',[0,0,0])

legend('观测结果(有噪音)','用输入v估算的先验','原始轨迹','估算的后验轨迹')



return

%


