function p = g_regressor__true_p(in1,in2)
%G_REGRESSOR__TRUE_P
%    P = G_REGRESSOR__TRUE_P(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    24-Jun-2020 17:45:16

mu1 = in1(1,:);
mu2 = in1(2,:);
mu3 = in1(3,:);
mu4 = in1(4,:);
mu5 = in1(5,:);
mu6 = in1(6,:);
mu7 = in1(7,:);
mu8 = in1(8,:);
mu9 = in1(9,:);
rho1 = in2(1,:);
rho2 = in2(2,:);
rho3 = in2(3,:);
rho4 = in2(4,:);
rho5 = in2(5,:);
rho6 = in2(6,:);
rho7 = in2(7,:);
rho8 = in2(8,:);
rho9 = in2(9,:);
p = [mu1.*rho1;mu2.*rho2;mu3.*rho3;mu4.*rho4;mu5.*rho5;mu6.*rho6;mu7.*rho7;mu8.*rho8;mu9.*rho9;mu1;mu2;mu3;mu4;mu5;mu6;mu7;mu8;mu9];