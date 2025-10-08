
%Matching chart plot
run("dati.m");
run("risoluzione_definitiva.m")
%decollo
qms=linspace(0,10000,200);
T0_S=(qms.^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl)); %con qms=QM_S

%Atterramentor
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/(1-alfa*k));

%Crociera
T_S=(1/(psi*zeta))*(0.5*rho*(V_cruise^2)*CD0_velivolo+(qms.^2)./(0.5*rho*(V_cruise^2)*e*pi*lambda));

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

