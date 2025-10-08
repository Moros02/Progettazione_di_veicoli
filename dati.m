%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati Predeterminati dal committente
z=convert.ft_m(20000);              %Quota di volo [m]
n_pax=100;        %numero di passeggeri
X_TO=1800;        %Lunghezza di pista in takeoff [m]
X_LA=1500;        %Lunghtzza di pista in landing [m]
V_LA=convert.kts_ms(115);         %Velocità in atterraggio [m/s]
A=2.5e6;%sovrastimato %convert.nm_m(1000);           %Autonomia [m]
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
ni=2.44e-5;         %Viscosità [m^2/s]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati derivati dall'ala
Cl_land=2.3;      %Coefficiente di lift in atterraggio
Cl_toff=2.3;      %Coefficiente di lift in decollo
t_c=0.14;          %t/c dell'ala [%]
delta=0.3;        %delta per trasformare rho [kg/m^3]
n=2.5;            %Fattore di carico dell'ala
%Aggiuntivi
% E=14;            %Efficienza Cl/Cd
e=0.95;              %oswald efficiency factor


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati del motore
alfa=0.9;         %percentuale di fuel in crociera [%]
XFR=0.65;          %Coefficiente spinta motore
zeta=0.5;         %Manetta [%]  0.6 forse meglio
c_s0=(0.9/3600);         %consumo specifico a quota zero[N/N*s] 
psi=((T/Tsl)^5.256)*((Tsl/T)^1.75); %funzione psi(z)
c_s=c_s0*psi;     %consumo specifico in quota [N/N*s]
n_paxrow=4;       %numero di passeggeri per fila



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Dati predeterminati ulteriori
p_pax=95;         % peso per passeggero [kg]
v_pax=convert.ft3_m3(5);  % Volume per passeggero [m^3]
n_eq=4;           % Membri equipaggio
p_sed=15;         % Peso per ogni sedile [kg]
W_liqu=200+(1.9*n_pax); % Peso dei liquidi a bordo [kg]
g=9.81;           % Accelerazione di gravità [m/s^2]
a_frenata=1.6;    % Accelerazione in frenata Tra 1.2 e 1.8 [m/s^2]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Calcolo Preliminare del CD0:
% b=sqrt(S*lambda);
% c_aero=S/b;
% Re_wing=(V_cruise*c_aero)/ni;