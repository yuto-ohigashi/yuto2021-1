%% 足部と下腿の質量を決定(論文1の体重を利用)
m_foot = 69.6*1.1/100;
m_low = 69.6*5.1/100;
m_femur = 69.6*11/100;
m_upperarm = 69.6*2.7/100;
m_forearm = 69.6*1.6/100;
m_hand = 69.6*0.6/100;
m_arm = m_upperarm+m_forearm+m_hand;
m_head = 69.6*6.9/100;
m_body = 69.6*48.9/100;
m_upper = 69.6*60.7/100; %頭部・胴体・上腕・前腕・手

%% 足部と下腿の部分長(自分の長さ)
len_foot = 25.5;
len_low = 47.0;
len_femur = 41.0;
len_upperarm = 31.0;
len_forearm = 23.4;
len_hand = 19.6;
len_head = 25.0;
len_body = 52.5;
len_upper = len_head+len_body;
% 問題点：セグメントの長さの決定をどうするか

%% 各セグメントの質量中心(直立時の距骨と脛骨の接合部(くるぶし？自分の長さ)を原点Oとした座標)、質量中心の位置は上端からの比
cen_foot = 0.595;
cen_low = 0.406;
cen_femur = 0.475;
cen_upperarm = 0.529;
cen_forearm = 0.415;
cen_hand = 0.891;
cen_head = 0.821;
cen_body = 0.493;

%% セグメントの質量中心までの距離(直立時の距骨と脛骨の接合部(くるぶし？自分の長さ)を原点Oとした座標)
mc_foot_x = 19-(len_foot*cen_foot); %19はつま先からくるぶしまでの距離
mc_foot_y = 0;
mc_low = len_low*(1-cen_low); %下端から質量中心までの距離
mc_femur = len_femur*(1-cen_femur); %下端から質量中心までの距離
mc_upperarm = len_upperarm*cen_upperarm; %上端から質量中心までの距離
mc_forearm = len_forearm*cen_forearm; %上端から質量中心までの距離
mc_hand = len_hand*cen_hand; %上端から質量中心までの距離
mc_head = len_head*cen_head; %上端から質量中心までの距離
mc_body = len_body*cen_body; %上端から質量中心までの距離

%% 上半身の足から質量中心までの距離
%上半身の質量中心では以下の仮定を置く
%・腕の各セグメントの質量中心は一直線状にある
%・腕の質量中心が腕は左右対称と考えて胴体の中心線上に質量中心がある
%・頭・腕・胴の質量中心が一直線状にある
%→腕の質量中心を出してから、頭と腕と胴の重心を出して腰からそこまでの距離を出す
%以下は腕の質量中心、肩からの距離にしている
mc_arm = (m_upperarm*mc_upperarm + m_forearm*(len_upperarm+mc_forearm) + m_hand*(len_upperarm+len_forearm+cen_hand))/m_arm;  
%頭を原点に下方向が正で重心を出している、胴体と腕の質量中心までの距離は(肩から質量中心までの距離)+(頭の長さ)で出している
mc_upper = len_upper - (m_head*mc_head + m_body*(len_head+mc_body) - m_arm*(len_head+mc_arm))/(m_head+m_body+m_arm); 

%% 関節の可動域
% 関節角度は水平線からセグメントまでの角度
theta_ank = 70:1:90;
theta_knee = 90:1:220;
theta_hip = -35:1:105;

%% 各関節角度に対する各セグメントの質量中心の座標
g_all = zeros(length(theta_ank)*length(theta_knee)*length(theta_hip),9);
% gは順番に(足関節角度 膝関節角度 股関節角度 下腿の質量中心のx座標 下腿の質量中心のy座標 大腿の質量中心のx座標 大腿の質量中心のy座標 上体の質量中心のx座標 上体の質量中心のy座標)
for i = 1:length(theta_ank)
    ank = theta_ank(i)/180*pi;
    x_low = mc_low*cos(ank); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low*sin(ank); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    for j = 1:length(theta_knee)
        knee = theta_knee(j)/180*pi;
        x_femur = len_low*cos(ank) + mc_femur*cos(knee);
        y_femur = len_low*sin(ank) + mc_femur*sin(knee);
        for k = 1:length(theta_hip)
            hip = theta_hip(k)/180*pi;
            x_upper = len_low*cos(ank) + len_femur*cos(knee)+ mc_upper*cos(hip);
            y_upper = len_low*sin(ank) + len_femur*sin(knee)+ mc_upper*sin(hip);
            col = col+1;
            g_all(col,:) = [theta_ank(i) theta_knee(j) theta_hip(k) x_low y_low x_femur y_femur x_upper y_upper];
        end
    end
end

%% 各関節角度に対する重心座標
g = zeros(length(theta_ank)*length(theta_knee)*length(theta_hip),5);
% gは順番に(足関節角度 膝関節角度 股関節角度 重心のx座標 重心のy座標)
for l = 1:length(theta_ank)*length(theta_knee)*length(theta_hip)
    x_g = (m_foot*mc_foot_x + m_low*g_all(l,4) + m_femur*g_all(l,6) + m_upper*g_all(l,8))/(m_foot+m_low+m_femur+m_upper);
    y_g = (m_foot*mc_foot_y + m_low*g_all(l,5) + m_femur*g_all(l,7) + m_upper*g_all(l,9))/(m_foot+m_low+m_femur+m_upper);
    g(l,:) = [g_all(l,1) g_all(l,2) g_all(l,3) x_g y_g];
end 

%% 重心が足関節内にあるかの判定
squat_position = zeros(length(theta_ank)*length(theta_knee)*length(theta_hip),5);
% squat_positionは順番に(足関節角度 膝関節角度 股関節角度 重心のx座標 重心のy座標)
for m = 1:length(theta_ank)*length(theta_knee)*length(theta_hip)
    if g(m,4) < 19 && g(m,4) > -6.5 && g(m,5)> 0
        squat_position(m,:) = g(m,:);
    end
end
for m = length(theta_ank)*length(theta_knee)*length(theta_hip):-1:1
    if squat_position(m,4) == 0 && squat_position(m,5) == 0
        squat_position(m,:) = [];
    end
end