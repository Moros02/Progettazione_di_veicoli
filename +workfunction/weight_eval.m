function QM=weight_eval(data,Q,QM_S,T0_S,lambda,k)
N=data.n*1.5;   %Sovrastima del fattore di carico? 
L_fus=(data.n_pax/data.n_paxrow)*1.2*1.1;  %lunghezza fusoliera [m]
Q_ala=(1/7760)*N*(Q^(3/2))*(lambda^(3/2))*sqrt(1/QM_S)+6*(1/QM_S)*Q;
Q_fus=(1/1000)*N*Q*L_fus;
Q_impennaggi=3.5*(1/QM_S)*Q;
Q_carrello=0.03*Q;
Q_impianti=0.2*Q;
Q_motore=0.2*T0_S*(1/QM_S)*Q;
Q_fisso=(data.p_pax+data.W_liqu+data.p_sed)*data.g;
Q_f=k*Q;
QM=Q_ala+Q_fus+Q_impennaggi+Q_carrello+Q_impianti+Q_motore+Q_fisso+Q_f;
end