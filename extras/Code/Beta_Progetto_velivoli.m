
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati Predeterminati dal committente
z=ft_m(20000);              %Quota di volo [m]
n_pax=100;        %numero di passeggeri
X_TO=1800;        %Lunghezza di pista in takeoff [m]
X_LA=1500;        %Lunghtzza di pista in landing [m]
V_LA=kts_ms(115);         %Velocità in atterraggio [m/s]
A=nm_m(1000);           %Autonomia [m]
M=0.7;              %Mach di crociera



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%Determinazione Dati ambiente
rhosl=1.225;        %Densità a livello del mare [kg/m^3]
Tsl=288;            %Temperatura a livello del mare [K]
asl=340.3;          %Velocità suono a livello del mare
T=Tsl-0.0065*z;     %Temperatura a quota z [K] (siamo in Troposfera)
rho=((T/Tsl)^4.256)*rhosl; %Densità in crociera
a=sqrt(T/Tsl)*asl;  %Velocità del suono in crociera
V_cruise=M*a;       %Velocità di crociera [m/s^2]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati derivati dall'ala
Cl_land=2.2;      %Coefficiente di lift in atterraggio
Cl_toff=2.2;      %Coefficiente di lift in decollo
t_c=0.2;          %t/c dell'ala [%]
delta=0.3;        %delta per trasformare rho [kg/m^3]
n=2.5;            %Fattore di carico dell'ala
%Aggiuntivi
E=0.3;            %Efficienza Cl/Cd
e=1;              %oswald efficiency factor


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati del motore
alfa=0.02;         %percentuale di fuel in crociera [%]
XFR=0.65;          %Coefficiente spinta motore
zeta=1;         %Manetta [%]
c_s0=0.3;         %consumo specifico a quota zero 
psi=((T/Tsl)^5.256)*((Tsl/T)^1.75); %funzione psi(z)
c_s=c_s0*psi;     %consumo specifico in quota
n_paxrow=4;       %numero di passeggeri per fila



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Dati predeterminati ulteriori
p_pax=95;         % peso per passeggero [kg]
v_pax=ft3_m3(5);  % Volume per passeggero [m^3]
n_eq=4;           % Membri equipaggio
p_sed=15;         % Peso per ogni sedile [kg]
W_liqu=200+(1.9*n_pax); % Peso dei liquidi a bordo [kg]
g=9.81;           % Accelerazione di gravità [m/s^2]
a_frenata=1.6;    % Accelerazione in frenata Tra 1.2 e 1.8 [m/s^2]

%%%%%%INTERPOLAZIONI

Database=readtable("Dbfrulla.txt");
X=Database.seats;
Y=Database.W_MTO;
mdl=fitlm(X,Y, 'linear', 'VarNames',{'Seats', 'W_MTO'});
xarray=linspace(0,300,200);
yarray=predict(mdl, xarray');
figure
scatter(X,Y,'filled');
hold on
plot(xarray,yarray);
xlabel('Seats');
ylabel('W_MTO');
title('Retta di regressione lineare per peso velivoli')
grid on
grid minor
hold off
mdl_woe=fitlm(Database.W_MTO, Database.W_OE, 'linear', 'VarNames',{'W_MTO','W_OE'});
x=linspace(0,100000,300);
y=predict(mdl_woe,x');
figure
scatter(Database.W_MTO, Database.W_OE,'filled')
hold on
plot(x,y,'-r','LineWidth',1);
xlabel('W_MTO');
ylabel('W_OE');
grid on 
grid minor
hold off


%%%%DATI DALL'INTERPOLAZIONE

W_seats100=predict(mdl,100); %Previsione del peso interpolato per 100 passeggeri


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%PARTENDO DA QUA UTILIZZANDO
%Scrivendo omega=(1-alfa*k)
omega=1/e^((A*c_s)/(E*V_cruise));
%Si scrive ora QMTO/S in funzione di omega:
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/omega);
%Si scrive T0/S:
T0_S=(QM_S^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl));

%OPPURE QUESTE:
%Equazione del decollo
T0_S=(QM_S^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl));
%Equazione Dell'atterraggio
QM_S=(X_LA/1.66)*a_frenata*((rhosl*Cl_land)/(1-alfa*k));
%Equazione dell'autonomia
A=(E/c_s)*V_cruise*(log(1/(1-alfa*k)));
%Equazione in crociera
T_S=(1/(psi*zeta))*(0.5*rhosl*delta*(V_cruise^2)*C_D0+(QM_S^2)*(1/(0.5*rhosl*delta*(V_cruise^2)*e*pi*lambda)));