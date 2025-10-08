clear
clc
close all
%Dati di Input
Npax=80;
Xto=1500;
Xla=1250;
Vland=59.16;
M=0.7;
zft=20000; %piedini
z=zft*0.3048; %metri
rhosl=1.225;
Clmax_dec=2.3;
xFR=0.65;
a_decc=1.3;
alfa=0.95;
e=0.85;

rho=(1-0.0065/288.15*z)^4.256*rhosl;

a=sqrt(1-0.0065/288.15*z)*340.294;

A=1852*10^3; %m


%Stime iniziali

FSC=0.017;
Clmax_land=2.3;
lambda=7.5;
k=0.12;
Cd0=0.02;

N=0;

x=0:1:5000;

%Equazioni Iterative

    omega=(Xla/1.66)*a_decc*rhosl*Clmax_land/(1-alfa*k);

    T0_S=(x).^2.*(1/9.81)*(1.75/(Clmax_dec*Xto*rhosl*xFR));

    yT0_S=0.5*rho*(M*a)^2*Cd0+(x).^2./(0.5*rho*(M*a)^2*e*pi*lambda);
    
    y=ones(1,100)*omega;

plot(x,T0_S)

hold on

plot(x,yT0_S)

x_vert = omega;
yl = ylim;
plot([x_vert x_vert], [yl(1) yl(2)], 'g', 'LineWidth', 2);  % verde tratteggiato

