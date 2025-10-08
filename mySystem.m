function sys=mySystem(x)
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
E=14;            %Efficienza Cl/Cd
e=0.95;              %oswald efficiency factor


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Dati del motore
alfa=0.9;         %percentuale di fuel in crociera [%]
XFR=0.65;          %Coefficiente spinta motore
zeta=0.28;         %Manetta [%]
c_s0=(0.9/3600);         %consumo specifico a quota zero[N/N*s] 
psi=((T/Tsl)^5.256)*((Tsl/T)^1.75); %funzione psi(z)
c_s=c_s0*psi;     %consumo specifico in quota [kg/N*s]
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



%Sia x(1)=Q
%Sia x(2)=S
%Sia x(3)=k
%Sia x(4)=T
%Sia x(5)=lambda
b_1=28.0945;
sys=zeros(5,1);
%Atterraggio
f_int=1.2;
f_pres=1.2;
L_fuso=(n_pax/n_paxrow)*1.2*1.1;
R_fuso=sqrt(((n_paxrow*0.9+1.2)/2)^2+0.9^2);
S_fuso=6.28*R_fuso*L_fuso;
Q_fisso=(p_pax+W_liqu+p_sed)*g;
N=n*1.5;

sys(1)=((X_LA/1.66)*a_frenata*((rhosl*Cl_land)/(1-alfa*x(3))))-(x(1)/x(2)); %QM_S

sys(2)=((x(1)/x(2))^2)*(1/g)*1.75*(1/(XFR*Cl_toff*X_TO*rhosl))-(x(4)/x(2));%T0_S

sys(3)=(1/(psi*zeta))*(0.5*rho*(V_cruise^2)*((2*0.455/((log((V_cruise*(x(2)/b_1))/ni))^2.58*(1+0.144*M^2)^0.65)...
    *(1+2*(t_c)+60*(t_c)^4)...
    *f_pres*1.2)+...
    (0.455/((log((V_cruise*L_fuso)/ni))^2.58*(1+0.144*M^2)^0.65))*(S_fuso/x(2)))*f_int...
    +((x(1)/x(2))^2)./(0.5*rho*(V_cruise^2)*e*pi*x(5)));

sys(4)=((2*x(1))/(rho*(V_cruise^2)*x(2))/(((2*0.455/((log((V_cruise*(x(2)/b_1))/ni))^2.58*(1+0.144*M^2)^0.65)...
    *(1+2*(t_c)+60*(t_c)^4)...
    *f_pres*1.2)+...
    (0.455/((log((V_cruise*L_fuso)/ni))^2.58*(1+0.144*M^2)^0.65))*(S_fuso/x(2)))*f_int+(...
    ((2*x(1))/(rho*(V_cruise^2)*x(2)))^2/(pi*e*x(5))))/c_s)*V_cruise*(log(1/(1-alfa*x(3))));

sys(5)=(1/7760)*N*(x(1)^(3/2))*(x(5)^(3/2))*sqrt(x(2)/x(1))+6*(x(2)/x(1))*x(1)...
    +(1/1000)*N*x(1)*L_fuso...
    +3.5*(x(2)/x(1))*x(1)+...
    0.03*x(1)+...
    0.2*x(1)+...
    0.2*x(4)+...
    Q_fisso+...
    x(3)*x(1);



end