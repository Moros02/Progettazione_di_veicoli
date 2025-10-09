function cd0=cd0_evaluation(data,S,b)
c_aer=S/b;
Re_wing=(data.V_cruise*c_aer)/data.ni;
cf_wing=0.455/((log(Re_wing))^2.58*(1+0.144*data.M^2)^0.65);
f_int=1.2;
f_pres=1.2;
f_spess=1+2*(data.t_c)+60*(data.t_c)^4;
R_fuso=sqrt(((data.n_paxrow*0.9+1.2)/2)^2+0.9^2);
L_fuso=(data.n_pax/data.n_paxrow)*1.2*1.1;
S_fuso=6.28*R_fuso*L_fuso;
Re_fuso=(data.V_cruise*L_fuso)/data.ni;
Cf_fuso=0.455/((log(Re_fuso))^2.58*(1+0.144*data.M^2)^0.65);

cd0=((2*cf_wing*f_spess*f_pres*1.2)+Cf_fuso*(S_fuso/S))*f_int;
end