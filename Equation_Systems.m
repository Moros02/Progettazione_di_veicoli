function sys=Equation_Systems(x,p,b_1)
%Sia x(1)=Q
%Sia x(2)=Q/S
%Sia x(3)=k
%Sia x(4)=T/S
%Sia x(5)=lambda
S=x(1)/x(2);
sys=zeros(5,1);
%CDO VELIVOLO
b=sqrt(x(5)*S);
c_aer=S/b;
Re_wing=(p.V_cruise*c_aer)/p.ni;
cf_wing=0.455/((log(Re_wing))^2.58*(1+0.144*p.M^2)^0.65);
f_int=1.2;
f_pres=1.2;
f_spess=1+2*(p.t_c)+60*(p.t_c)^4;
R_fuso=sqrt(((p.n_paxrow*0.9+1.2)/2)^2+0.9^2);
L_fuso=(p.n_pax/p.n_paxrow)*1.2*1.1;
S_fuso=6.28*R_fuso*L_fuso;
Re_fuso=(p.V_cruise*L_fuso)/p.ni;
Cf_fuso=0.455/((log(Re_fuso))^2.58*(1+0.144*p.M^2)^0.65);
CD0_velivolo=((2*cf_wing*f_spess*f_pres*1.2)+Cf_fuso*(S_fuso/S))*f_int;

%EFFICIENZA
CL=(2*x(1))/(p.rho*(p.V_cruise^2)*S);
E=CL/(CD0_velivolo+(CL^2/(pi*p.e*x(5))));
%autonomia------------------------------
sys(1)=(E/p.c_s)*p.V_cruise*log(1/(1-p.alfa*x(3)))-p.A;
%Atterraggio----------------------------------------------------
sys(2)=(p.X_LA/1.66)*p.a_frenata*((p.rhosl*p.Cl_land)/(1-p.alfa*x(3)))-x(2); %Q/S
%Decollo---------------------------------------------------------------
sys(3)=(x(2)^2)*(1/p.g)*1.75*(1/(p.XFR*p.Cl_toff*p.X_TO*p.rhosl))-x(4); %T/S
%Cruise--------------------------------------------------------------
sys(4)=(1/(p.psi*p.zeta))*(0.5*p.rho*(p.V_cruise^2)*CD0_velivolo+((x(2))^2)/(0.5*p.rho*(p.V_cruise^2)*p.e*pi*x(5)))-x(4);
%Equazione stima pesi------------------------------------------------
N=p.n*1.5;   %Sovrastima del fattore di carico? 
L_fus=(p.n_pax/p.n_paxrow)*1.2*1.1;  %lunghezza fusoliera [m]
Q_ala=(1/7760)*N*(x(1)^(3/2))*(x(5)^(3/2))*sqrt(1/x(2))+6*S;
Q_fus=(1/1000)*N*x(1)*L_fus;
Q_impennaggi=3.5*S;
Q_carrello=0.03*x(1);
Q_impianti=0.2*x(1);
Q_motore=0.2*x(4)*S;
Q_fisso=(p.p_pax+p.W_liqu+p.p_sed)*p.g;
Q_f=x(3)*x(1);
%NB: eventualmente ricorda di togliere 0.85 da Qala
sys(5)=(0.85*Q_ala)+Q_fus+Q_impennaggi+Q_carrello+Q_impianti+Q_motore+Q_fisso+Q_f-x(1);
end