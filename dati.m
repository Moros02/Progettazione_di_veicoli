data=struct();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati Predeterminati dal committente
data.z=convert.ft_m(20000);              %Quota di volo [m]
data.n_pax=100;        %numero di passeggeri
data.X_TO=1800;        %Lunghezza di pista in takeoff [m]
data.X_LA=1500;        %Lunghtzza di pista in landing [m]
data.V_LA=convert.kts_ms(115);         %Velocità in atterraggio [m/s]
data.A=2.5e6;%sovrastimato %convert.nm_m(1000);           %Autonomia [m]
data.M=0.7;              %Mach di crociera



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%Determinazione Dati ambiente
data.rhosl=1.225;        %Densità a livello del mare [kg/m^3]
data.Tsl=288;            %Temperatura a livello del mare [K]
data.asl=340.3;          %Velocità suono a livello del mare
data.T=data.Tsl-0.0065*data.z;     %Temperatura a quota z [K] (siamo in Troposfera)
data.rho=((data.T/data.Tsl)^4.256)*data.rhosl; %Densità in crociera
data.a=sqrt(data.T/data.Tsl)*data.asl;  %Velocità del suono in crociera
data.V_cruise=data.M*data.a;       %Velocità di crociera [m/s^2]
data.ni=2.44e-5;         %Viscosità [m^2/s]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati derivati dall'ala
data.Cl_land=2.3;      %Coefficiente di lift in atterraggio
data.Cl_toff=2.3;      %Coefficiente di lift in decollo
data.t_c=0.14;          %t/c dell'ala [%]
data.delta=0.3;        %delta per trasformare rho [kg/m^3]
data.n=2.5;            %Fattore di carico dell'ala
%Aggiuntivi
% E=14;            %Efficienza Cl/Cd
data.e=0.6;              %oswald efficiency factor


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati del motore
data.alfa=0.9;         %percentuale di fuel in crociera [%]
data.XFR=0.65;          %Coefficiente spinta motore
data.zeta=0.5;         %Manetta [%]  0.6 forse meglio
data.c_s0=(0.9/3600);         %consumo specifico a quota zero[N/N*s] 
data.psi=((data.T/data.Tsl)^5.256)*((data.Tsl/data.T)^1.75); %funzione psi(z)
data.c_s=data.c_s0*data.psi;     %consumo specifico in quota [N/N*s]
data.n_paxrow=4;       %numero di passeggeri per fila



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Dati predeterminati ulteriori
data.p_pax=100;         % peso per passeggero [kg]
data.v_pax=convert.ft3_m3(5);  % Volume per passeggero [m^3]
data.n_eq=4;           % Membri equipaggio
data.p_sed=15;         % Peso per ogni sedile [kg]
data.W_liqu=200+(1.9*data.n_pax); % Peso dei liquidi a bordo [kg]
data.g=9.81;           % Accelerazione di gravità [m/s^2]
data.a_frenata=1.6;    % Accelerazione in frenata Tra 1.2 e 1.8 [m/s^2]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Calcolo Preliminare del CD0:
% b=sqrt(S*lambda);
% c_aero=S/b;
% Re_wing=(V_cruise*c_aero)/ni;