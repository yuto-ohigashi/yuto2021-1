close all;
clear;
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
% 疑問点：質量比を足して100%にならない

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
% 問題点：原点をどこにするか

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
theta_ank = deg2rad(70:90);
theta_knee = deg2rad(50:180);
theta_hip = deg2rad(-35:90);

%% 各関節角度に対する各セグメントの質量中心の座標
angle1 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),3);
com = NaN(length(theta_ank)*length(theta_hip),6);
col = 0;
% comは質量中心を表して順番に(下腿質量中心のx 下腿質量中心のy 大腿質量中心のx 大腿質量中心のy 上体質量中心のx 上体質量中心のy)
% angle1は設定した関節角度全ての姿勢における(足関節角度 股関節角度 膝関節角度)
for i = 1:length(theta_ank)
    x_low = mc_low*cos(theta_ank(i)); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low*sin(theta_ank(i)); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    for j = 1:length(theta_knee)
        x_femur = len_low*cos(theta_ank(i)) + mc_femur*cos(theta_knee(j));
        y_femur = len_low*sin(theta_ank(i)) + mc_femur*sin(theta_knee(j));
        for k = 1:length(theta_hip)
           x_upper = len_low*cos(theta_ank(i)) + len_femur*cos(theta_knee(j))+ mc_upper*cos(theta_hip(k));
           y_upper = len_low*sin(theta_ank(i)) + len_femur*sin(theta_knee(j))+ mc_upper*sin(theta_hip(k));
          col = col+1;
          angle1(col,:) = [theta_ank(i) theta_knee(j) theta_hip(k)];
          com(col,:) = [x_low y_low x_femur y_femur x_upper y_upper];
        end
    end
end

%% 各関節角度に対する重心座標
cog1 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),2);
% cog1は設定した関節角度全てにおける重心を表して順番に(重心のx座標 重心のy座標)
for m = 1:length(theta_ank)*length(theta_knee)*length(theta_hip)
    x_g = (m_foot*mc_foot_x + m_low*com(m,1) + m_femur*com(m,3) + m_upper*com(m,5))/(m_foot+m_low+m_femur+m_upper);
    y_g = (m_foot*mc_foot_y + m_low*com(m,2) + m_femur*com(m,4) + m_upper*com(m,6))/(m_foot+m_low+m_femur+m_upper);
    cog1(m,:) = [x_g y_g];
end 

%% 重心が足関節内にあるかの判定
cog2 = NaN(length(theta_ank)*length(theta_hip),2);
angle2 = NaN(length(theta_ank)*length(theta_hip),2);
% cog2は重心が基底面内にある姿勢の重心を表して順番に(重心のx座標 重心のy座標)
% angle2は重心が基底面内にある姿勢の関節角度(足関節角度 股関節角度 膝関節角度)

out_cog1 = (cog1(:,1) < 19).*(cog1(:,1) > -6.5);
ok_indexes1 = find(out_cog1);
cog2 = cog1(ok_indexes1,:);
angle2 = angle1(ok_indexes1,:);

mesh(angle2)
xlabel('ankle joint angle')
ylabel('knee joint angle')
zlabel('hip joint angle')

%% 関節トルクを求めるにあたっての初期値
m_body = 69.6;
g = -9.80;
