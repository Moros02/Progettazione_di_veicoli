function sys=Equation_Systems(x,data)
%Sia x(1)=Q [kg]
%Sia x(2)=Q/S [N/m^2]
%Sia x(3)=k  
%Sia x(4)=T/S  [N/m^2]
%Sia x(5)=lambda
S=(x(1)*data.g)/x(2);
sys=zeros(5,1);
%CDO VELIVOLO
b=sqrt(x(5)*S);
CD0_velivolo=workfunction.cd0_evaluation(data,S,b);
%EFFICIENZA
CL=(2*x(1)*data.g)/(data.rho*(data.V_cruise^2)*S);
E=CL/(CD0_velivolo+(CL^2/(pi*data.e*x(5))));
%autonomia------------------------------
sys(1)=(E/data.c_s)*data.V_cruise*log(1/(1-data.alfa*x(3)))-data.A;
%Atterraggio----------------------------------------------------
sys(2)=(data.X_LA/1.66)*data.a_frenata*((data.rhosl*data.Cl_land)/(1-data.alfa*x(3)))-x(2); %Q/S
%Decollo---------------------------------------------------------------
sys(3)=(x(2)^2)*(1/data.g)*1.75*(1/(data.XFR*data.Cl_toff*data.X_TO*data.rhosl))-x(4); %T/S
%Cruise--------------------------------------------------------------
sys(4)=(1/(data.psi*data.zeta))*(0.5*data.rho*(data.V_cruise^2)*CD0_velivolo+((x(2))^2)/(0.5*data.rho*(data.V_cruise^2)*data.e*pi*x(5)))-x(4);
%Equazione stima pesi------------------------------------------------
sys(5)=workfunction.weight_eval(data,x(1),x(2),x(4),x(5),x(3));
end