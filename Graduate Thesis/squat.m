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
m_upper = 69.6*65.6/100; %頭部・胴体・上腕・前腕・手

%% 足部と下腿の部分長
height = 1.751;
len_foot = 0.152*height;
len_ank = 0.039*height;
len_low = 0.285*height;
len_femur = 0.245*height;
len_upperarm = 0.188*height;
len_forearm = 0.145*height;
len_hand = 0.108*height;
len_head = 0.130*height;
len_body = 0.345*height;
len_upper = len_head+len_body;
len_toe = len_foot*0.6;
len_heel = len_foot*0.4;
% 問題点：足関節（距骨？）の位置のデータがない

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
mc_foot_x = len_toe-(len_foot*cen_foot); %19はつま先からくるぶしまでの距離
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
theta_ank = deg2rad(70:90);
theta_hip = deg2rad(55:180);
theta_knee = deg2rad(50:180);

%% 各関節角度に対する各セグメントの質量中心の座標
angle1 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),3);
cos1 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),6);
col = 0;
% comは質量中心を表して順番に(下腿質量中心のx 下腿質量中心のy 大腿質量中心のx 大腿質量中心のy 上体質量中心のx 上体質量中心のy)
% angle1は設定した関節角度全ての姿勢における(足関節角度 股関節角度 膝関節角度)
for i = 1:length(theta_ank)
    x_low = mc_low*cos(theta_ank(i)); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low*sin(theta_ank(i)); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    for j = 1:length(theta_knee)
        x_femur = len_low*cos(theta_ank(i)) + mc_femur*cos(pi-theta_knee(j)+theta_ank(i));
        y_femur = len_low*sin(theta_ank(i)) + mc_femur*sin(pi-theta_knee(j)+theta_ank(i));
        for k = 1:length(theta_hip)
           x_upper = len_low*cos(theta_ank(i)) + len_femur*cos(pi-theta_knee(j)+theta_ank(i))+ mc_upper*cos(theta_hip(k)-theta_knee(j)+theta_ank(i));
           y_upper = len_low*sin(theta_ank(i)) + len_femur*sin(pi-theta_knee(j)+theta_ank(i))+ mc_upper*sin(theta_hip(k)-theta_knee(j)+theta_ank(i));
           col = col+1;
           angle1(col,:) = [theta_ank(i) theta_knee(j) theta_hip(k)];
           cos1(col,:) = [x_low y_low x_femur y_femur x_upper y_upper];
        end
    end
end

%% 各関節角度に対する重心座標
cog1 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),2);
% cog1は設定した関節角度全てにおける重心を表して順番に(重心のx座標 重心のy座標)
for l = 1:length(theta_ank)*length(theta_knee)*length(theta_hip)
    x_g = (m_foot*mc_foot_x + m_low*cos1(l,1) + m_femur*cos1(l,3) + m_upper*cos1(l,5))/(m_foot+m_low+m_femur+m_upper);
    y_g = (m_foot*mc_foot_y + m_low*cos1(l,2) + m_femur*cos1(l,4) + m_upper*cos1(l,6))/(m_foot+m_low+m_femur+m_upper);
    cog1(l,:) = [x_g y_g];
end 

%% 重心が足関節内にあるかの判定
cog2 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),2);
angle2 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),2);
cos2 = NaN(length(theta_ank)*length(theta_knee)*length(theta_hip),6);
% cog2は重心が基底面内にある姿勢の重心を表して順番に(重心のx座標 重心のy座標)
% angle2は重心が基底面内にある姿勢の関節角度(足関節角度 膝関節角度 股関節角度)

% cog2は重心が基底面内にある姿勢の重心を表して順番に(重心のx座標 重心のy座標)
% angle2は重心が基底面内にある姿勢の関節角度
% 以下は重心が基底面内にある姿勢の重心(cog)、関節角度(angle)、各セグメントの質量中心座標(com)を出している

out_cog = (cog1(:,1) < len_toe).*(cog1(:,1) > -len_heel).*(cog1(:,2) > 0);
ok_indexes1 = find(out_cog);

cog2 = cog1(ok_indexes1,:);
angle2 = angle1(ok_indexes1,:);
cos2 = cos1(ok_indexes1,:);

out_indexes = find(~out_cog);
out_cog = cog1(out_indexes,:);
out_angle = angle1(out_indexes,:);
out_cos = cos1(ok_indexes1,:);

sz1 = size(angle2);
sz2 = size(out_angle);

% mesh(angle2)
% xlabel('ankle joint angle')
% ylabel('knee joint angle')
% zlabel('hip joint angle')

%% スクワット姿勢として認められた姿勢のプロット用の座標
% pknee,phip,phead は基底面内に重心がある姿勢の膝・股関節・頭の位置座標
pknee = [(len_low.*cos(angle2(:,1))) (len_low.*sin(angle2(:,1)))];
phip = [pknee(:,1)+len_femur*cos(pi-angle2(:,2)+angle2(:,1)) pknee(:,2)+len_femur*sin(pi-angle2(:,2)+angle2(:,1))];
phead = [phip(:,1)+len_upper.*cos(angle2(:,3)-angle2(:,2)+angle2(:,1)) phip(:,2)+len_upper.*sin(angle2(:,3)-angle2(:,2)+angle2(:,1))];

%% スクワット姿勢として認められた姿勢のプロット
for m = 1:sz1(1)
    figure(3)
    hold on
    plot([len_toe -len_heel], [0 0], '-ok');
    plot([0 pknee(m,1)], [0 pknee(m,2)],'-ok');
    plot([pknee(m,1) phip(m,1)], [pknee(m,2) phip(m,2)],'-ok');
    plot([phip(m,1) phead(m,1)], [phip(m,2) phead(m,2)],'-ok');
    plot(cog2(m,1),cog2(m,2),'o');
end

%% スクワット姿勢として排除された姿勢のプロット用の座標
out_pknee = [(len_low.*cos(out_angle(:,1))) (len_low.*sin(out_angle(:,1)))];
out_phip = [out_pknee(:,1)+len_femur*cos(pi-out_angle(:,2)+out_angle(:,1)) out_pknee(:,2)+len_femur*sin(pi-out_angle(:,2)+out_angle(:,1))];
out_phead = [out_phip(:,1)+len_upper.*cos(out_angle(:,3)-out_angle(:,2)+out_angle(:,1)) out_phip(:,2)+len_upper.*sin(out_angle(:,3)-out_angle(:,2)+out_angle(:,1))];

%% スクワット姿勢としてはじかれた姿勢のプロット
for n = 1:sz2(1)
    figure(4)
    hold on
    plot([len_toe -len_heel], [0 0], '-ok');
    plot([0 out_pknee(n,1)], [0 out_pknee(n,2)],'-ok');
    plot([out_pknee(n,1) out_phip(n,1)], [out_pknee(n,2) out_phip(n,2)],'-ok');
    plot([out_phip(n,1) out_phead(n,1)], [out_phip(n,2) out_phead(n,2)],'-ok');
end

%% 関節トルクを求めるにあたっての初期値
g = -9.80;
