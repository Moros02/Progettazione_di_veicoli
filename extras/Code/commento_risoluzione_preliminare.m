%%%%%% FASE PRELIMINARE DI CALCOLO ORGANIZZATA IN ORDINE DI RISOLUZIONE:
clear
clc
run("dati.m");
%Dall'equazione dell'Autonomia trovo (1-alfak)

%Scrivendo omega=(1-alfa*k)
omega=1/e^((A*c_s)/(E*V_cruise));
%Si scrive ora QMTO/S in funzione di omega:
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/omega);
%Si scrive T0/S:
T0_S=(QM_S^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl));


%Interpolazione lineare dei valori
global Database
Database=readtable("Dbfrulla.txt");
% disp(Database);
X=Database.seats;
Y=Database.W_MTO;
%Fitlm crea un oggetto linear model, per usarlo devo munirmi di predict
mdl=fitlm(X,Y, 'linear', 'VarNames',{'Seats', 'W_MTO'});
%disp(mdl); mi fa vedere i valori stime
%plot(mdl); mi da il modello di regressione con i conf.bounds e i valori
%scatter(X,Y,'filled'); mi da i valori di partenza della tabella
% [W_MTO,xfit,yfit]=workfunction.linear_regression(X,Y,0:1:300); se voglio
% solo retta di regressione
seat100=predict(mdl,100);
%Vado con il plot della retta
xarray=linspace(0,300,200);
yarray=predict(mdl, xarray');
figure
scatter(X,Y,'filled');
hold on
plot(xarray,yarray);
% plot(xfit,yfit)     Se voglio per caso plottare solo la retta di
% regressione
xlabel('Seats');
ylabel('W_MTO');
title('Retta di regressione lineare per peso velivoli')
grid on
grid minor
hold off

% Si plotta il grafico di regressione di W_OE in funz di W_MTO
mdl_woe=fitlm(Database.W_MTO, Database.W_OE, 'linear', 'VarNames',{'W_MTO','W_OE'});
x=linspace(0,100000,300);
y=predict(mdl_woe,x');
figure
scatter(Database.W_MTO, Database.W_OE,'filled')
hold on
plot(x,y,'-r','LineWidth',1);
xlabel('W_MTO');
ylabel('W_OE');
title(sprintf('Retta di regressione lineare di %s in funzione di %s','W_OE', 'W_MTO'))
grid on 
grid minor
hold off

mld_woe2=workfunction.linear_regression('W_MTO','W_OE',true,linspace(0,100000,300));