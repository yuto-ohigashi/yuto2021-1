close all;
clear;
%% 変数表
% theta_ank：足関節角度の範囲（床から下腿までの間の角度）
% theta_hip：股関節角度の範囲（水平面から上体までの間の角度）
% angle1：全姿勢の関節角度
% com1：全姿勢における各関節角度でのセグメントの質量中心の座標
% cog1：全姿勢における各関節角度での重心の座標
% angle2：スクワット姿勢として成立する姿勢の関節角度
% com2：スクワット姿勢として成立する姿勢のセグメントの質量中心の座標
% cog2：スクワット姿勢として成立する姿勢の重心の座標
% squat_plot_x：スクワットとして成立する姿勢のかかと・つま先・足関節・膝関節・股関節・頭のx座標
% squat_plot_y：スクワットとして成立する姿勢のかかと・つま先・足関節・膝関節・股関節・頭のy座標
% squat_out_plot_x：スクワットとして排除された姿勢のかかと・つま先・足関節・膝関節・股関節・頭のx座標
% squat_out_plot_y：スクワットとして排除された姿勢のかかと・つま先・足関節・膝関節・股関節・頭のy座標

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
% 関節角度は水平線からセグメントまでの角度
theta_ank = deg2rad(70:90);
theta_hip = deg2rad(55:180);

%% 各関節角度に対する各セグメントの質量中心の座標
angle1 = NaN(length(theta_ank)*length(theta_hip),3);
cos1 = NaN(length(theta_ank)*length(theta_hip),6);
col = 0;
% cos1は質量中心を表して順番に(下腿質量中心のx 下腿質量中心のy 大腿質量中心のx 大腿質量中心のy 上体質量中心のx 上体質量中心のy)
% angle1は設定した関節角度全ての姿勢における(足関節角度 股関節角度 膝関節角度)
for i = 1:length(theta_ank)
    x_low = mc_low*cos(theta_ank(i)); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low*sin(theta_ank(i)); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    x_femur = len_low*cos(theta_ank(i)) + mc_femur*cos(pi);
    y_femur = len_low*sin(theta_ank(i)) + mc_femur*sin(pi);
    for j = 1:length(theta_hip)
        x_upper = len_low*cos(theta_ank(i)) + len_femur*cos(pi)+ mc_upper*cos(theta_hip(j));
        y_upper = len_low*sin(theta_ank(i)) + len_femur*sin(pi)+ mc_upper*sin(theta_hip(j));
        col = col+1;
        angle1(col,:) = [theta_ank(i) theta_ank(i) theta_hip(j)];
        cos1(col,:) = [x_low y_low x_femur y_femur x_upper y_upper];
    end
end

%% 各関節角度に対する重心座標
cog1 = NaN(length(theta_ank)*length(theta_hip),2);
% cog1は設定した関節角度全てにおける重心を表して順番に(重心のx座標 重心のy座標)
for l = 1:length(theta_ank)*length(theta_hip)
    x_g = (m_foot*mc_foot_x + m_low*cos1(l,1) + m_femur*cos1(l,3) + m_upper*cos1(l,5))/(m_foot+m_low+m_femur+m_upper);
    y_g = (m_foot*mc_foot_y + m_low*cos1(l,2) + m_femur*cos1(l,4) + m_upper*cos1(l,6))/(m_foot+m_low+m_femur+m_upper);
    cog1(l,:) = [x_g y_g];
end 

%% 重心が足関節内にあるかの判定
cog2 = NaN(length(theta_ank)*length(theta_hip),2);
angle2 = NaN(length(theta_ank)*length(theta_hip),2);
cos2 = NaN(length(theta_ank)*length(theta_hip),2);
% cog2は重心が基底面内にある姿勢の重心を表して順番に(重心のx座標 重心のy座標)
% angle2は重心が基底面内にある姿勢の関節角度
% 以下は重心が基底面内にある姿勢の重心(cog)、関節角度(angle)、各セグメントの質量中心座標(com)を出している

out_cog = (cog1(:,1) < len_toe).*(cog1(:,1) > -len_heel);
ok_indexes1 = find(out_cog);

cog2 = cog1(ok_indexes1,:);
angle2 = angle1(ok_indexes1,:);
cos2 = cos1(ok_indexes1,:);

out_indexes1 = find(~out_cog);
out_cog = cog1(out_indexes1,:);
out_angle = angle1(out_indexes1,:);
out_cos = cos1(ok_indexes1,:);

% scatter(rad2deg(angle2(:,1)), rad2deg(angle2(:,3)))
% xlabel('ankle joint angle')
% ylabel('hip joint angle')

sz1 = size(angle2);
sz2 = size(out_angle);

%% スクワット姿勢として認められた姿勢のプロット用の座標
% pknee,phip,phead は基底面内に重心がある姿勢の膝・股関節・頭の位置座標
pknee = [(len_low.*cos(angle2(:,1))) (len_low.*sin(angle2(:,1)))];
phip = [pknee(:,1)+len_femur*cos(pi) pknee(:,2)+len_femur*sin(pi)];
phead = [phip(:,1)+len_upper.*cos(angle2(:,3)) phip(:,2)+len_upper.*sin(angle2(:,3))];

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
out_phip = [out_pknee(:,1)+len_femur*cos(pi) out_pknee(:,2)+len_femur*sin(pi)];
out_phead = [out_phip(:,1)+len_upper.*cos(out_angle(:,3)) out_phip(:,2)+len_upper.*sin(out_angle(:,3))];

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
m_all = 69.6;
g = -9.80;

%% 各姿勢における足関節トルクの計算
fground = [0 -m_all*g];
% fground は順番に(床反力のx成分 床反力のy成分)
fankle1 = [-fground(1) -fground(2)-m_foot*g];
% fankle1 は順番に(足関節間力のx成分　足関節間力のy成分)
% 足関節間力のx成分は (-床反力のx成分) で計算
% 足関節間力のy成分は (-床反力のy成分-足部にかかる重力) で計算
pre_momenta1 = NaN(sz1(1),6);
pre_momenta1(:,1) = fground(1);
pre_momenta1(:,2) = fground(2);
pre_momenta1(:,3) = 0;
pre_momenta1(:,4) = mc_foot_x-cog2(:,1);
pre_momenta1(:,5) = mc_foot_y;
pre_momenta1(:,6) = 0;
% pre_momenta1 は床反力のモーメントの力、セグメント重心からの距離のx,y,z成分を順番に並べたもの
pre_momenta2 = NaN(sz1(1),6);
pre_momenta2(:,1) = fankle1(1);
pre_momenta2(:,2) = fankle1(2);
pre_momenta2(:,3) = 0;
pre_momenta2(:,4) = mc_foot_x;
pre_momenta2(:,5) = mc_foot_y;
pre_momenta2(:,6) = 0;
% pre_momenta2 は足部にかかる足関節間力のモーメントの力、セグメント重心からの距離のx,y,z成分を順番に並べたもの
momenta1 = cross(pre_momenta1(:,1:3), pre_momenta1(:,4:6));
momenta2 = cross(pre_momenta2(:,1:3), pre_momenta2(:,4:6));
torque_ankle = -(momenta1(:,3)+momenta2(:,3));
% momenta1 は床反力のモーメント、momenta2 は足関節間力のモーメント
% mesh([angle2(:,1) angle2(:,3) torque_ankle])

%% 各姿勢における膝関節トルクの計算
fankle2 = -fankle1;
% fankel2 は足部にかかる足関節間力と大きさは一緒で逆方向の力 = 下腿にかかる足関節間力
fknee1 = NaN(sz1(1),2);
fknee1(:,1) = -fankle2(1);
fknee1(:,2) = -fankle2(:,2)-m_low*g;
% fknee1 膝関節間力を表しては順番に(膝関節間力のx成分　膝関節間力のy成分)
% 膝関節間力のx成分は (-下腿への足関節間力のx成分) で計算
% 膝関節間力のy成分は (-下腿への足関節間力のy成分-下腿にかかる重力) で計算
pre_momentk1 = NaN(sz1(1),6);
pre_momentk1(:,1) = fankle2(:,1);
pre_momentk1(:,2) = fankle2(:,2);
pre_momentk1(:,3) = 0;
pre_momentk1(:,4) = cos2(:,1);
pre_momentk1(:,5) = cos2(:,2);
pre_momentk1(:,6) = 0;
% pre_momentk1 は下腿にかかる足関節間力のモーメントの力、下腿重心からの距離のx,y,z成分を順番に並べたもの
pre_momentk2 = NaN(sz1(1),6);
pre_momentk2(:,1) = fknee1(:,1);
pre_momentk2(:,2) = fknee1(:,2);
pre_momentk2(:,3) = 0;
pre_momentk2(:,4) = cos2(:,1)-pknee(:,1);
pre_momentk2(:,5) = cos2(:,2)-pknee(:,2);
pre_momentk2(:,6) = 0;
% pre_momentk2 は下腿にかかる膝関節間力のモーメントの力、下腿重心からの距離のx,y,z成分を順番に並べたもの   
momentk1 = cross(pre_momentk1(:,1:3), pre_momentk1(:,4:6));
momentk2 = cross(pre_momentk2(:,1:3), pre_momentk2(:,4:6));
torque_knee = -(momentk1(:,3)+momentk2(:,3)-torque_ankle);
% momentk1 は足関節間力のモーメント、momentk2 は膝関節間力のモーメント

%% 各姿勢における股関節トルクの計算
fknee2 = -fknee1;
% fknee2 は下腿にかかる膝関節間力と大きさは一緒で逆方向の力 = 大腿にかかる膝関節間力
fhip1 = NaN(sz1(1),2);
fhip1(:,1) = -fknee2(:,1);
fhip1(:,2) = -fknee2(:,2)-m_femur*g;
% fhip1 は順番に(股関節間力のx成分　股関節間力のy成分)
% 股関節間力のx成分は (-大腿への膝関節間力) で計算
% 股関節間力のy成分は (-大腿への膝関節間力-大腿にかかる重力) で計算
pre_momenth1 = NaN(sz1(1),6);
pre_momenth1(:,1) = fknee2(:,1);
pre_momenth1(:,2) = fknee2(:,2);
pre_momenth1(:,3) = 0;
pre_momenth1(:,4) = cos2(:,3)-pknee(:,1);
pre_momenth1(:,5) = cos2(:,4)-pknee(:,2);
pre_momenth1(:,6) = 0;
% pre_momenth1 は大腿にかかる膝関節間力のモーメントの力、大腿重心からの距離のx,y,z成分を順番に並べたもの
pre_momenth2 = NaN(sz1(1),6);
pre_momenth2(:,1) = fhip1(:,1);
pre_momenth2(:,2) = fhip1(:,2);
pre_momenth2(:,3) = 0;
pre_momenth2(:,4) = cos2(:,3)-phip(:,1);
pre_momenth2(:,5) = cos2(:,4)-phip(:,2);
pre_momenth2(:,6) = 0;
% pre_momenth2 は大腿にかかる股関節間力のモーメントの力、大腿重心からの距離のx,y,z成分を順番に並べたもの
momenth1 = cross(pre_momenth1(:,1:3), pre_momenth1(:,4:6));
momenth2 = cross(pre_momenth2(:,1:3), pre_momenth2(:,4:6));
torque_hip = -(momenth1(:,3)+momenth2(:,3)-torque_knee);
% momentk1 は足関節間力のモーメント、momentk2 は膝関節間力のモーメント

%% 股関節トルクの確認
torque_hip2 = NaN(sz1(1),1);
for n = 1:sz1(1)
	moment = cross([0 m_upper*g 0], [phip(n,1)-cos2(n,5) phip(n,2)-cos2(n,6) 0]);
	torque_hip2(n,1) = -moment(3);
end
