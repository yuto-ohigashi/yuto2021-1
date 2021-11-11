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
mc_foot_x = 19-len_foot*cen_foot; % 19はつま先からくるぶしまでの距離
mc_foot_y = 0;
mc_low_x = 0;
mc_low_y = len_low*(1-cen_low);
mc_femur_x = 0;
mc_femur_y = len_low + len_femur*(1-cen_femur);
% 問題点：原点をどこにするか

%% 関節の可動域
% 足関節角度は直立時の下腿の線と屈曲した時の下腿の線の間の角度
% 膝関節角度は屈曲前の膝が真っ直ぐになっている時の大腿の線と屈曲した時の大腿の線の間の角度
theta_ank = 0:0.01:pi/6;
theta_knee = 0:0.01:13*pi/18;

%% 各関節角度に対する各セグメントの質量中心の座標
g_low_femur = zeros(length(theta_ank)*length(theta_knee),6);
% gは順番に(足関節角度 膝関節角度 下腿の質量中心のx座標 下腿の質量中心のy座標 大腿の質量中心のx座標 大腿の質量中心のy座標)
for i = 1:length(theta_ank)
    x_low = mc_low_y * sin(theta_ank(i)); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low_y * cos(theta_ank(i)); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    for j = 1:length(theta_knee)
        femur
        x_femur = ;
        y_femur = ;
        g_low_femur(j*(i-1)+j,:) = [theta_ank(i) theta_ank(j) x_low y_low x_femur y_femur];
    end
end

%% 各関節角度に対する重心座標
g = zeros(length(theta_ank)*length(theta_knee),4);
% gは順番に(足関節角度 膝関節角度 重心のx座標 重心のy座標)


%% 重心が足関節内にあるかの判定
squat_position = zeros(length(theta_ank),4);
% squat_positionは順番に(足関節角度 膝関節角度 重心のx座標 重心のy座標)

