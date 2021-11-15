%% 足部と下腿の質量を決定(論文1の体重を利用)
m_foot = 69.6*1.1/100;
m_low = 69.6*5.1/100;

%% 足部と下腿の部分長(自分の長さ)
len_foot = 25.5;
len_low = 47.0;
% 問題点：セグメントの長さの決定をどうするか

%% 足部と下腿の質量中心、質量中心の位置は上端からの比
cen_foot = 0.595;
cen_low = 0.406;

%% セグメントの質量中心のまでの座標(直立時の距骨と脛骨の接合部(くるぶし？自分の長さ)を原点Oとした座標)
mc_foot_x = 19-len_foot*cen_foot; % 19はつま先からくるぶしまでの距離
mc_foot_y = 0; 
mc_low = len_low*(1-cen_low);
% 問題点：原点をどこにするか

%% 足関節の可動域
% 関節角度は水平線からセグメントまでの角度
theta_ank = 7/18*pi:0.01:pi/2;

%% 足関節角度に対する下腿の質量中心の座標
g_low = zeros(length(theta_ank),3);
% g_lowは順番に(足関節角度 下腿の質量中心のx座標 下腿の質量中心のy座標)
for i = 1:length(theta_ank)
    x_low = mc_low * cos(theta_ank(i)); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low * sin(theta_ank(i)); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    g_low(i,:) = [theta_ank(i) x_low y_low];
end

%% 足関節角度に対する下腿と足の重心
g = zeros(length(theta_ank),3);
% gは順番に(足関節角度 重心のx座標 重心のy座標)
for j = 1:length(theta_ank)
    x_g = (m_foot*mc_foot_x + m_low*g_low(j,2))/(m_foot+m_low); %重心のx座標
    y_g = (m_foot*mc_foot_y + m_low*g_low(j,3))/(m_foot+m_low); %重心のy座標
    g(j,:) = [theta_ank(j) x_g y_g];
end

%% 重心が足関節内にあるかの判定
squat_position = zeros(length(theta_ank),3);
% squat_positionは順番に(足関節角度 重心のx座標 重心のy座標)
for k = 1:length(theta_ank)
    if g(k,2) < 19 && g(k,2) > -6.5
        squat_position(k,:) = g(k,:);
    end
end
for k = 1:length(theta_ank)
    if squat_position(k,2:3) == [0 0]
        squat_position(k,:) = [];
    end
end
