%% 足部と下腿の質量を決定(論文1の体重を利用)
m_foot = 69.6*1.1/100;
m_low = 69.6*5.1/100;
%% 足部と下腿の部分長(自分の長さ)
len_foot = 25.5;
len_low = 47.0;
%% 足部と下腿の質量中心(直立時の距骨と脛骨の接合部(くるぶし？自分の長さ)を原点Oとした座標)、質量中心(cf,cl)の位置は上端からの比
cen_foot = 0.595;
cen_low = 0.406;
mc_foot_x = 19-len_foot*cen_foot; %% 19はつま先からくるぶしまでの距離
mc_foot_y = 0; 
mc_lowleg_x = 0;
mc_lowleg_y = len_low*(1-cen_low);
%% 足関節の可動域
theta_ank = 1:1:30;
%% 足関節角度に対する下腿の質量中心の座標
g_lowleg = zeros(size(theta_ank),2);
for i = 1:size(theta_ank)
    x_lowleg = mc_lowleg_x * sin(theta_ank);
    g_lowleg(i,1) = x_lowleg;
end
for i = 1:size(theta_ank)
    y_low = mc_lowleg_x(2) * cos(theta_ank);
    g_lowleg(i,2) = y_low;
end
%% 足関節角度に対する下腿と足の質量重心
g = [];
for j = 1:30
    x_g = (m_foot*mc_lowleg_x(1)+m_lowleg*j(1))/(m_foot+m_low);
    y_g = (m_foot*mc_lowleg_x(2)+m_lowleg*j(2))/(m_foot+m_low);
    g = [g;x_g, y_g];
end