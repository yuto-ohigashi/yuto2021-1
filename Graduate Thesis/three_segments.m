%% 足部と下腿の質量を決定(論文1の体重を利用)
m_foot = 69.6*1.1/100;
m_low = 69.6*5.1/100;
m_femur = 69.6*11/100;

%% 足部と下腿の部分長(自分の長さ)
len_foot = 25.5;
len_low = 47.0;
len_femur = 41.0;
% 問題点：セグメントの長さの決定をどうするか

%% 足部と下腿の質量中心(直立時の距骨と脛骨の接合部(くるぶし？自分の長さ)を原点Oとした座標)、質量中心(cf,cl,cfe)の位置は上端からの比
cen_foot = 0.595;
cen_low = 0.406;
cen_femur = 0.475;

%% セグメントの質量中心までの距離(直立時の距骨と脛骨の接合部(くるぶし？自分の長さ)を原点Oとした座標)
mc_foot_x = 19-len_foot*cen_foot; %19はつま先からくるぶしまでの距離
mc_foot_y = 0;
mc_low = len_low*(1-cen_low); %くるぶしから質量中心までの距離
mc_femur = len_femur*(1-cen_femur); %膝から質量中心までの距離
% 問題点：原点をどこにするか

%% 関節の可動域
% 関節角度は水平線からセグメントまでの角度
theta_ank = 7/18*pi:0.01:pi/2;
theta_knee = pi/2:0.01:23/18*pi;

%% 各関節角度に対する各セグメントの質量中心の座標
g_low_femur = zeros(length(theta_ank)*length(theta_knee),6);
col = 0;
% gは順番に(足関節角度 膝関節角度 下腿の質量中心のx座標 下腿の質量中心のy座標 大腿の質量中心のx座標 大腿の質量中心のy座標)
for i = 1:length(theta_ank)
    x_low = mc_low * sin(theta_ank(i)); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low * cos(theta_ank(i)); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    for j = 1:length(theta_knee)
        x_femur = len_low*cos(theta_ank(i)) + mc_femur*cos(theta_knee(j));
        y_femur = len_low*sin(theta_ank(i)) + mc_femur*sin(theta_knee(j));
        col = col+1;
        g_low_femur(col,:) = [theta_ank(i) theta_knee(j) x_low y_low x_femur y_femur];
    end
end

%% 各関節角度に対する重心座標
g = zeros(length(theta_ank)*length(theta_knee),4);
% gは順番に(足関節角度 膝関節角度 重心のx座標 重心のy座標)
for k = 1:length(theta_ank)*length(theta_knee)
    x_g = (m_foot*mc_foot_x + m_low*g_low_femur(k,3) + m_femur*g_low_femur(k,5))/(m_foot+m_low+m_femur);
    y_g = (m_foot*mc_foot_y + m_low*g_low_femur(k,4) + m_femur*g_low_femur(k,6))/(m_foot+m_low+m_femur);
    g(k,:) = [g_low_femur(k,1) g_low_femur(k,2) x_g y_g];
end 

%% 重心が足関節内にあるかの判定
squat_position = zeros(length(theta_ank)*length(theta_knee),4);
% squat_positionは順番に(足関節角度 膝関節角度 重心のx座標 重心のy座標)
for l = 1:length(theta_ank)*length(theta_knee)
    if g(l,3) < 19 && g(l,3) > -6.5
        squat_position(l,:) = g(l,:);
    end
end
for l = 1:length(theta_ank)*length(theta_knee)
    if squat_position(l,3) == 0 && squat_position(l,4) ==0
        squat_position(l,:) = [];
    end
end
