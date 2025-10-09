clear all
close all
clc
run("dati.m")
%%%CREO UNA STRUCT DA USARE NEL FSOLVE
% vars = whos;
% p = struct();
% for i = 1:length(vars)
%     p.(vars(i).name) = eval(vars(i).name);
% end
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
statistic=struct(); %struttura con i dati dalla statistica
statistic.Q_MTO=predict(mdl_WMTO,100);
disp(['Valore di Q_MTO preso da interpolazione: ',num2str(statistic.Q_MTO)]);


%%%%%%%%%%%% Predicto superficie e b (di conseguenza lambda)
mdl_Sw=workfunction.linear_regression('W_MTO','Sw',genflag,linspace(0,100000,300));
statistic.Sw=predict(mdl_Sw,statistic.Q_MTO);
disp(['La superficie alare stimata (interpolando la stima del peso) è [m^2]: ',num2str(statistic.Sw)]);
%b
mdl_b=workfunction.linear_regression('W_MTO','b',genflag,linspace(0,100000,300));
statistic.b=predict(mdl_b,statistic.Q_MTO);
%lambda
lambda=(statistic.b^2)/statistic.Sw;
disp(['Il valore di allungamento alare è: ',num2str(lambda)]);

%%% RISOLVO LE EQUAZIONI UNA VOLTA IN MODO DA AVERE VALORI DI PARTENZA:
%%%%%%%%%%%%%%STIMA DEL CD0:
CD0_velivolo=workfunction.cd0_evaluation(data,statistic.Sw,statistic.b);
%Si calcola il CL:
CL=(2*statistic.Q_MTO)/(data.rho*(data.V_cruise^2)*statistic.Sw);
E=CL/(CD0_velivolo+(CL^2/(pi*data.e*lambda)));
%EQ1
omega=1/exp((data.A*data.c_s)/(E*data.V_cruise));
k=(1-omega)/data.alfa;
%EQ2
QM_S=(data.X_LA/1.66)*data.a_frenata*((data.rhosl*data.Cl_land)/omega);
%EQ3
T0_S=(QM_S^2)*(1/data.g)*1.75*(1/(data.XFR*data.Cl_toff*data.X_TO*data.rhosl));
%EQ4
T_S=(1/(data.psi*data.zeta))*(0.5*data.rho*(data.V_cruise^2)*CD0_velivolo+((statistic.Q_MTO/statistic.Sw)^2)./(0.5*data.rho*(data.V_cruise^2)*data.e*pi*lambda));
%EQ5
QM=workfunction.weight_eval(data,statistic.Q_MTO,QM_S,T0_S,lambda,k);
%%%%% Cerco di risolvere le equazioni utilizzando un Fsolve
% x0=[QM,QM_S,k,T0_S,lambda];
x0=[391444.5,5504,0.176,2131.2,11.01];
options = optimoptions('fsolve','Display','iter');
f = @(x) Equation_Systems(x,data);
[x, fval, exitflag, output] = fsolve(f, x0, options);
disp('Solution:');
disp(x);


%%%%%%PLOT DEL MATCHING CHART:
DispMatchingchart=true;
if DispMatchingchart
    qms=linspace(0,10000,1000);
    T0_S=(qms.^2)*(1/data.g)*1.75*(1/(data.XFR*data.Cl_toff*data.X_TO*data.rhosl)); %con qms=QM_S
    QM_S=(data.X_LA/1.66)*data.a_frenata*((data.rhosl*data.Cl_land)/(1-data.alfa*x(3)));
    T_S=(1/(data.psi*data.zeta))*(0.5*data.rho*(data.V_cruise^2)*(workfunction.cd0_evaluation(data,(x(1)/x(2)),statistic.b))+(qms.^2)./(0.5*data.rho*(data.V_cruise^2)*data.e*pi*x(5)));
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
end

CL=(2*x(1))/(data.rho*(data.V_cruise^2)*(x(1)/x(2)));
E=CL/((workfunction.cd0_evaluation(data,(x(1)/x(2)),statistic.b))+(CL^2/(pi*data.e*x(5))));
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
f = @(x) Equation_Systems(x,data);
[xs{iter+1}, fval, exitflag, output] = fsolve(f, x0, options);
end
disp('Solution:');
disp(xs{5});