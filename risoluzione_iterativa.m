clear all
close all
clc
run("dati.m")
%%%CREO UNA STRUCT DA USARE NEL FSOLVE
vars = whos;
p = struct();
for i = 1:length(vars)
    p.(vars(i).name) = eval(vars(i).name);
end
%%%%%%%%%%%%%%%%%55
global Database
Database=readtable("dati_velivoli.csv");
genflag=false;
%%%%%%%%%% Generazione modelli lineari
mdl_WMTO=workfunction.linear_regression('seats','W_MTO',genflag,linspace(0,300,200));
mdl_WOE=workfunction.linear_regression('W_MTO','W_OE',genflag,linspace(0,100000,300));
mdl_wf=workfunction.linear_regression('W_MTO','W_f',genflag,linspace(0,100000,300));
mdl_wp=workfunction.linear_regression('W_MTO','W_p',genflag,linspace(0,100000,300));

%%%%%%%%%%%% Predizione del peso
Q_MTO_1=predict(mdl_WMTO,100);
disp(['Valore di Q_MTO preso da interpolazione: ',num2str(Q_MTO_1)]);


%%%%%%%%%%%% Predicto superficie e b (di conseguenza lambda)
mdl_Sw=workfunction.linear_regression('W_MTO','Sw',genflag,linspace(0,100000,300));
Sw_1=predict(mdl_Sw,Q_MTO_1);
disp(['La superficie alare stimata (interpolando la stima del peso) è [m^2]: ',num2str(Sw_1)]);
%b
mdl_b=workfunction.linear_regression('W_MTO','b',genflag,linspace(0,100000,300));
b_1=predict(mdl_b,Q_MTO_1);
%lambda
lambda=(b_1^2)/Sw_1;
disp(['Il valore di allungamento alare è: ',num2str(lambda)]);

%%% RISOLVO LE EQUAZIONI UNA VOLTA IN MODO DA AVERE VALORI DI PARTENZA:
%%%%%%%%%%%%%%STIMA DEL CD0:
c_aer=Sw_1/b_1;
Re_wing=(V_cruise*c_aer)/ni;
cf_wing=0.455/((log(Re_wing))^2.58*(1+0.144*M^2)^0.65);
f_int=1.2;
f_pres=1.2;
f_spess=1+2*(t_c)+60*(t_c)^4;
R_fuso=sqrt(((n_paxrow*0.9+1.2)/2)^2+0.9^2);
L_fuso=(n_pax/n_paxrow)*1.2*1.1;
S_fuso=6.28*R_fuso*L_fuso;
Re_fuso=(V_cruise*L_fuso)/ni;
Cf_fuso=0.455/((log(Re_fuso))^2.58*(1+0.144*M^2)^0.65);
CD0_velivolo=((2*cf_wing*f_spess*f_pres*1.2)+Cf_fuso*(S_fuso/Sw_1))*f_int;
%Si calcola il CL:
CL=(2*Q_MTO_1)/(rho*(V_cruise^2)*Sw_1);
E=CL/(CD0_velivolo+(CL^2/(pi*e*lambda)));
%EQ1
omega=1/exp((A*c_s)/(E*V_cruise));
k=(1-omega)/alfa;
%EQ2
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/omega);
%EQ3
T0_S=(QM_S^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl));
%EQ4
T_S=(1/(psi*zeta))*(0.5*rho*(V_cruise^2)*CD0_velivolo+((Q_MTO_1/Sw_1)^2)./(0.5*rho*(V_cruise^2)*e*pi*lambda));
%EQ5
Q=Q_MTO_1;
S=Sw_1;
N=n*1.5;   %Sovrastima del fattore di carico? 
L_fus=(n_pax/n_paxrow)*1.2*1.1;  %lunghezza fusoliera [m]
Q_ala=(1/7760)*N*(Q^(3/2))*(lambda^(3/2))*sqrt(1/QM_S)+6*(1/QM_S)*Q;
Q_fus=(1/1000)*N*Q*L_fus;
Q_impennaggi=3.5*(1/QM_S)*Q;
Q_carrello=0.03*Q;
Q_impianti=0.2*Q;
Q_motore=0.2*T0_S*(1/QM_S)*Q;
Q_fisso=(p_pax+W_liqu+p_sed)*g;
Q_f=k*Q;
QM=Q_ala+Q_fus+Q_impennaggi+Q_carrello+Q_impianti+Q_motore+Q_fisso+Q_f;
%%%%% Cerco di risolvere le equazioni utilizzando un Fsolve
% x0=[QM,QM_S,k,T0_S,lambda];
x0=[391444.5,5504,0.176,2131.2,11.01];
options = optimoptions('fsolve','Display','iter');
f = @(x) Equation_Systems(x,p,b_1);
[x, fval, exitflag, output] = fsolve(f, x0, options);
disp('Solution:');
disp(x);



%%%%%%PLOT DEL MATCHING CHART:
qms=linspace(0,10000,1000);
T0_S=(qms.^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl)); %con qms=QM_S
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/(1-alfa*x(3)));
T_S=(1/(psi*zeta))*(0.5*rho*(V_cruise^2)*(workfunction.cd0_evaluation(p,(x(1)/x(2)),b_1))+(qms.^2)./(0.5*rho*(V_cruise^2)*e*pi*x(5)));
figure
plot(qms, T0_S, 'b-', 'LineWidth',2);
hold on;
yl=ylim;
plot([QM_S QM_S], [yl(1) yl(2)], 'r-', 'LineWidth', 2);
plot(qms, T_S, 'k-', 'LineWidth', 2)
hold off;

xlabel('QM\_S');
ylabel('T0\_S');
title('Matching Chart');
legend('Decollo T0/S', 'Atterraggio QM/S','Crociera T/S', 'Location', 'northeast');
grid on;
grid minor;

CL=(2*x(1))/(rho*(V_cruise^2)*(x(1)/x(2)));
E=CL/((workfunction.cd0_evaluation(p,(x(1)/x(2)),b_1))+(CL^2/(pi*e*x(5))));
disp(['Efficienza: ', num2str(E)])
b=sqrt(x(5)*(x(1)/x(2)));


disp(['Il valore di Q è:', num2str(x(1))])
disp(['Il valore di Q/S è:', num2str(x(2))])
disp(['Il valore di k è:', num2str(x(3))])
disp(['Il valore di T/S è:', num2str(x(4))])
disp(['Il valore di lambda è:', num2str(x(5))])

%%%%%%%%%%% ITERAZIONE PER I VALORI Q, Q/S, k, T/S, lambda %%%%%%%%%%x
xs=cell(1,5);
xs{1}=[x(1),x(2),x(3),x(4),x(5)];

for iter=1:length(xs)-1
x0=xs{iter};
options = optimoptions('fsolve','Display','iter');
f = @(x) Equation_Systems(x,p,b_1);
[xs{iter+1}, fval, exitflag, output] = fsolve(f, x0, options);
end
disp('Solution:');
disp(xs{5});