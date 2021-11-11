%% 足部と下腿の質量を決定(論文1の体重を利用)
m_foot = 69.6*1.1/100;
m_low = 69.6*5.1/100;
m_femur = 69.6*11.0/100;
%% 足部と下腿の部分長(自分の長さ)
len_foot = 25.5;
len_low = 47.0;
len_femur = 41.0;
% 問題点：セグメントの部分長の決定をどうするか
%% 足部と下腿の質量中心(直立時の距骨と脛骨の接合部(くるぶし？自分の長さ)を原点Oとした座標)、質量中心(cf,cl)の位置は上端からの比
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
theta_ank = 0:0.01:pi/6;
theta_ank = 0:0.01:13*pi/18;
%% 関節角度に対する各セグメントの質量重心
g_low = zeros(length(theta_ank)*;length,2);
for i = 1:length(theta_ank)
    x_low = mc_low_y * sin(theta_ank(i));
    g_low(i,1) = x_low;
end
for i = 1:length(theta_ank)
    y_low = mc_low_y * cos(theta_ank(i));
    g_low(i,2) = y_low;
end
%% 足関節と膝関節角度に対する