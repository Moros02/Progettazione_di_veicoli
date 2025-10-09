Q_iter=[Q_MTO_1,0,0,0];
S_iter=[Sw_1,0,0,0];
for i=1:length(Q_iter)-1

%Si calcola il CL:
CL=(2*Q_iter(i))/(rho*(V_cruise^2)*S_iter(i));
E=CL/(CD0_velivolo+(CL^2/(pi*e*lambda)));

%AUTONOMIA--------------------------------------------------------
%Scrivendo omega=(1-alfa*k);
omega=1/exp((A*c_s)/(E*V_cruise)); %POTREBBE ESSERE g*c_s
k=(1-omega)/alfa;
 % disp(['Il valore di k di prima iterazione è: ', num2str(k)]);
%Si trova il peso di carbutante sia k=Q_f/Q_MTO
% Q_f=Q_iter(i)*k;
% disp(['Il peso di carburante in kg di prima iterazione è: ',num2str(Q_f)]);
%Si scrive ora QMTO/S in funzione di omega:

%Atterraggio----------------------------------------------------
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/omega);
 disp(['Il valore di QM/S di prima iterazione è: ',num2str(QM_S)]);
%Si scrive T0/S:

%Decollo---------------------------------------------------------------
T0_S=(QM_S^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl));
% disp(['Il valore di T0/S di prima iterazione è: ', num2str(T0_S)]);

%Cruise--------------------------------------------------------------
T_S=(1/(psi*zeta))*(0.5*rho*(V_cruise^2)*CD0_velivolo+((Q_MTO_1/Sw_1)^2)./(0.5*rho*(V_cruise^2)*e*pi*lambda));
% disp(['Il valore di T/S di prima iterazione è: ',num2str(T_S)]);

%Equazione stima pesi------------------------------------------------
Q=Q_iter(i);
S=S_iter(i);
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
Q_iter(i+1)=Q_ala+Q_fus+Q_impennaggi+Q_carrello+Q_impianti+Q_motore+Q_fisso+Q_f;
disp(['liter è',num2str(i+1)]);
disp(['Peso del velivolo da equazione pesi: ',num2str(Q_iter(i+1))]);

S_iter(i+1)=(1/QM_S)*Q_iter(i+1);

c_aer=S_iter(i+1)/b_1;
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

CD0_velivolo=((2*cf_wing*f_spess*f_pres*1.2)+Cf_fuso*(S_fuso/S_iter(i+1)))*f_int;
disp(['Superficie Alare da equazione: ',num2str(S_iter(i+1))]);

end