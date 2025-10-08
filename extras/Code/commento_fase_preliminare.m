%%%%%Inizio
clear
clc

run("dati.m");
%Si ricorda che le variabili di progetto sono:
% Q Q/S, T/S, lambda, Q_f.

%Calcolo dei coefficienti di resistenza del velivolo
C_D0=1;

%
lambda=1;
%Equazione del decollo
T0_S=(QM_S^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl));
%Equazione Dell'atterraggio
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/(1-alfa*k));
%Equazione dell'autonomia
A=(E/c_s)*V_cruise*(log(1/(1-alfa*k)));
%Equazione in crociera
T_S=(1/(psi*zeta))*(0.5*rhosl*delta*(V_cruise^2)*C_D0+(QM_S^2)*(1/(0.5*rhosl*delta*(V_cruise^2)*e*pi*lambda)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stima dei pesi (Non ho S. Devo tipo stimarlo? non ho capito bene) Allora,
%una volta che ho lambda, se ho b posso trovare S. ma non ho capito bene
%sta cosa di Q. Da rivedere.
N=n*1.5;   %Sovrastima del fattore di carico? 
L_fus=10;  %lunghezza fusoliera [m]
Q_ala=(1/7760)*N*(Q^(3/2))*(lambda^(3/2))*sqrt(S/Q)+6*(S/Q)*Q;
Q_fus=(1/1000)*N*Q*L_fus;
Q_impennaggi=3.5*(S/Q)*Q;
Q_carrello=0.03*Q;
Q_impianti=0.2*Q;
Q_motore=30;
Q_fisso=(p_pax+W_liqu+p_sed)*g;
Q_f=k*Q;
QM=Q_ala+Q_fus+Q_impennaggi+Q_carrello+Q_impianti+Q_motore+Q_fisso+Q_f;
%Mumbling: questa equazione può servirci perché essendo tutto noto avendo k posso trovare Qf???? 
