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
theta_ank = 7/18*pi:1/180*pi:pi/2;
theta_knee = 2/3*pi;
theta_hip = -7/36*pi:1/180*pi:pi/2;

%% 各関節角度に対する各セグメントの質量中心の座標
g_all = zeros(length(theta_ank)*length(theta_hip),9);
col = 0;
% gは順番に(足関節角度 股関節角度 膝関節角度 下腿の質量中心のx座標 下腿の質量中心のy座標 大腿の質量中心のx座標 大腿の質量中心のy座標 上体の質量中心のx座標 上体の質量中心のy座標)
for i = 1:length(theta_ank)
    x_low = mc_low*cos(theta_ank(i)); %下腿の質量中心のx座標を(下腿の長さ)*sinθで計算
    y_low = mc_low*sin(theta_ank(i)); %下腿の質量中心のy座標を(下腿の長さ)*cosθで計算
    x_femur = len_low*cos(theta_ank(i)) + mc_femur*cos(theta_knee);
    y_femur = len_low*sin(theta_ank(i)) + mc_femur*sin(theta_knee);
    for k = 1:length(theta_hip)
        x_upper = len_low*cos(theta_ank(i)) + len_femur*cos(theta_knee)+ mc_upper*cos(theta_hip(k));
        y_upper = len_low*sin(theta_ank(i)) + len_femur*sin(theta_knee)+ mc_upper*sin(theta_hip(k));
        col = col+1;
        g_all(col,:) = [theta_ank(i)*180/pi theta_knee*180/pi theta_hip(k)*180/pi x_low y_low x_femur y_femur x_upper y_upper];
    end
end

%% 各関節角度に対する重心座標
gbody = zeros(length(theta_ank)*length(theta_hip),5);
% gは順番に(足関節角度 膝関節角度 股関節角度 重心のx座標 重心のy座標)
for l = 1:length(theta_ank)*length(theta_hip)
    x_g = (m_foot*mc_foot_x + m_low*g_all(l,4) + m_femur*g_all(l,6) + m_upper*g_all(l,8))/(m_foot+m_low+m_femur+m_upper);
    y_g = (m_foot*mc_foot_y + m_low*g_all(l,5) + m_femur*g_all(l,7) + m_upper*g_all(l,9))/(m_foot+m_low+m_femur+m_upper);
    gbody(l,:) = [g_all(l,1) g_all(l,2) g_all(l,3) x_g y_g];
end 

%% 重心が足関節内にあるかの判定
squat_position = zeros(length(theta_ank)*length(theta_hip),5);
% squat_positionは順番に(足関節角度 膝関節角度 股関節角度 重心のx座標 重心のy座標)
for m = 1:length(theta_ank)*length(theta_hip)
    if gbody(m,4) < 19 && gbody(m,4) > -6.5 && gbody(m,5)> 0
        squat_position(m,:) = gbody(m,:);
    end
end
for m = length(theta_ank)*length(theta_hip):-1:1
    if squat_position(m,4) == 0 && squat_position(m,5) == 0
        squat_position(m,:) = [];
    end 
end

%% 関節トルクを求めるにあたっての初期値
m_body = 69.6;
g = -9.80;

%% 各姿勢における足関節トルクの計算
sz = size(squat_position);
fground = zeros(sz(1),5);
% fground は順番に(足関節角度 膝関節角度 股関節角度 床反力のx成分 床反力のy成分) θはその姿勢における床反力の床からの角度
vector_fground = 0;
% vector_fground は床反力の原点に対する位置ベクトルを表す
for n = 1:sz(1)
    fground(n,1:3) = squat_position(n,1:3);
    % vector_fground = [squat_position(n,4) squat_position(n,5)];
    % cos_theta = dot(vector_fground,[19 0]) / (norm(vector_fground)*norm([19 0]));
    % fground(n,4) = acos(cos_theta);
    fground(n,4) = 0;
    fground(n,5) = m_body*g;
end
fjoint_ankle = zeros(sz(1),7);
% joint_force_ankle は順番に(足関節角度 膝関節角度 股関節角度 足関節間力のx成分　足関節間力のy成分 重心→足関節ベクトルx 重心→足関節ベクトルy)
% 関節間力のx成分は (-床反力のx成分)　で計算
% 関節間力のy成分は (-床反力のy成分-重力) で計算
for n = 1:sz(1)
    fjoint_ankle(n,1:3) = fground(n,1:3);
    fjoint_ankle(n,4) = -fground(n,4);
    fjoint_ankle(n,5) = - -m_foot*g - fground(n,5);
    fjoint_ankle(n,6:7) = [0-mc_foot_x 0];
end
pre_moment1 = zeros(sz(1),6);
% preparation_moment1 は床反力のモーメントの力、重心からの距離のx,y,z成分を順番に並べたもの
for n = 1:sz(1)
    pre_moment1(n,1:3) = [fground(n,4) fground(n,5) 0];
    pre_moment1(n,4:6) = [19-mc_foot_x 0 0];
end
pre_moment2 = zeros(sz(1),6);
% preparation_moment2 は足関節間力のモーメントの力、重心からの距離のx,y,z成分を順番に並べたもの
for n = 1:sz(1)
    pre_moment2(n,1:3) = [fjoint_ankle(n,4) fjoint_ankle(n,5) 0];
    pre_moment2(n,4:6) = [0-mc_foot_x 0 0];
end
torque_ankle = zeros(sz(1),4);
% torque_ankle は順番に(足関節角度 膝関節角度 股関節角度 トルク)
for n = 1:sz(1)
    torque_ankle(n,1:3) = fjoint_ankle(n,1:3);
    moment1 = cross(pre_moment1(n,1:3), pre_moment1(n,4:6));
    moment2 = cross(pre_moment2(n,1:3), pre_moment2(n,4:6));
    torque_ankle(n,4) = -(moment1(1,3)+moment2(1,3));
end
% moment1 は床反力のモーメント、moment2 は足関節間力のモーメント

%% 各姿勢における膝関節トルクの計算
fjoint_ankle2 = zeros(sz(1), 6);

fjoint_knee = zeros(sz(1),5);
% joint_force_knee は順番に(足関節角度 膝関節角度 股関節角度 足関節間力のx成分　足関節間力のy成分)
for n = 1:sz(1)
    fjoint_knee(n,1:3) = fjoint_ankle(n,1:3);
    fjoint_knee(n,4) = 0;
    fjoint_knee(n,5) = 0;
end
knee_torque = zeros(sz(1),4);
% ankle_torque は順番に(足関節角度 膝関節角度 股関節角度 足関節トルク)

%% 各姿勢における股関節トルクの計算
joint_force_hip = zeros(sz(1),5);
% joint_force_knee は順番に(足関節角度 膝関節角度 股関節角度 股関節間力のx成分　股関節間力のy成分)
for n = 1:sz(1)
    joint_force_hip(n,1:3) = fjoint_knee(n,1:3);
    joint_force_hip(n,4) = 0;
    joint_force_hip(n,5) = 0;
end

%% 各関節角度に対するプロット用の座標
%squat_plot_x = zeros(sz(1),9);
%squat_plot_y = zeros(sz(1),9);
%squat_plotは順番に(足関節角度 膝関節角度 股関節角度 かかと　つま先　足関節　膝関節　股関節　頭)
%for n = 1:sz(1)
%    knee = [len_low*cos(squat_position(n,1)/180*pi) len_low*sin(squat_position(n,1)/180*pi)];
%    hip = [knee(1,1)+len_femur*cos(squat_position(n,2)/180*pi) knee(1,2)+len_femur*sin(squat_position(n,2)/180*pi)];
%    head = [hip(1,1)+len_upper*cos(squat_position(n,3)/180*pi) hip(1,2)+len_upper*sin(squat_position(n,3)/180*pi)];
%    squat_plot_x(n,1:3) = squat_position(n,1:3);
%    squat_plot_y(n,1:3) = squat_position(n,1:3);
%    squat_plot_x(n,4:9) = [-6.5 19 0 knee(1,1) hip(1,1) head(1,1)];
%    squat_plot_y(n,4:9) = [0 0 0 knee(1,2) hip(1,2) head(1,2)];
%end

%% プロット
%for o = 1:sz(1)
%    figure(1)
%    hold on
%    plot([squat_plot_x(o,1) squat_plot_x(o,2)], [squat_plot_y(o,1) squat_plot_y(o,2)], '-ok');
%    plot([squat_plot_x(o,3) squat_plot_x(o,4)], [squat_plot_y(o,3) squat_plot_y(o,4)],'-ok');
%    plot([squat_plot_x(o,4) squat_plot_x(o,5)], [squat_plot_y(o,4) squat_plot_y(o,5)],'-ok');
%    plot([squat_plot_x(o,5) squat_plot_x(o,6)], [squat_plot_y(o,5) squat_plot_y(o,6)],'-ok');
    %filename = join(string([squat_position(1,1:3)]),'_');
    %saveas(gcf, 'filename');
    %hold off
%end
