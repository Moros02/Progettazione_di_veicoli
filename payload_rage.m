%Payload range
R1=0:10:data.A;
Q_fisso=(data.p_pax+data.p_sed)*(data.n_pax+data.n_eq)+data.W_liqu;
Q_pay1=Q_fisso*ones(1,length(R1));
Q_OE=0.55*(xs5(1)/data.g);
statistic.Q_fmax=predict(mdl_wf,xs5(1)/data.g);
R_max=E/data.c_s*data.a*data.M*log((xs5(1)/data.g)/(xs5(1)/data.g-statistic.Q_fmax));
R2=(data.A:10:R_max);
Q_pay2=(xs5(1)/data.g).*(-R2.*data.c_s./(data.V_cruise*E)).*(xs5(1)/data.g)-Q_OE;
% plot(R1,Q_pay1)
% hold on
% plot(R2,Q_pay2)
disp('================== PAYLOAD-RANGE ==================')
% --- 1. Recupera i valori finali e definisci i pesi ---
MTOW = xs5(1)/data.g;       % [kg] Limite Massimo al Decollo (dal fsolve)
Q_OE = MTOW-xs5(3)*MTOW-Q_fisso;         % [kg] Peso Operativo a Vuoto 
Q_f_max_tank = statistic.Q_fmax; % [kg] Max carburante imbarcabile (da tua regressione)
% Calcola il Payload Massimo (Q_pay_max)
% Il PDF [cite: 5] specifica 100 passeggeri a 95 kg (pax+bagaglio) [cite: 113]
% e 4 persone di equipaggio[cite: 5].
Q_pay_max = Q_fisso; % [kg] [cite: 281]
% --- 2. Calcola Efficienza (L/D) e Costante di Autonomia (K_range) ---
V = data.V_cruise;          % [m/s]
SFC = data.c_s;             % Assumo sia in [1/s] o [kg/(N*s)]*g
CL = (2*xs5(1))/(data.rho*(V^2)*(xs5(1)/xs5(2))); % xs5(1) è Q [N]
CD0 = workfunction.cd0_evaluation(data,(xs5(1)/xs5(2)),statistic.b);
E = CL / (CD0 + (CL^2 / (pi * data.e * xs5(5)))); % E = L/D
K_range = (V * E) / SFC;    % [m] Costante di autonomia (V*L/D / SFC)
% --- 3. Calcola i punti chiave (a, b, c) ---
% Punto (a): Max Payload, MTOW 
W_pay_a = Q_pay_max;
W_fuel_a = MTOW - Q_OE - W_pay_a;
W_ini_a = MTOW;
W_final_a = Q_OE + W_pay_a;
R_a = K_range * log(W_ini_a / W_final_a); % [m]
% Punto (b): Max Fuel, MTOW 
W_fuel_b = Q_f_max_tank;
W_pay_b = MTOW - Q_OE - W_fuel_b;
W_ini_b = MTOW;
W_final_b = Q_OE + W_pay_b;
R_b = K_range * log(W_ini_b / W_final_b); % [m]
% Punto (c): Max Fuel, Zero Payload (Ferry Range) 
W_pay_c = 0;
W_fuel_c = Q_f_max_tank;
W_ini_c = Q_OE + W_fuel_c; % MTOW è RIDOTTO [cite: 472]
W_final_c = Q_OE;
R_c = K_range * log(W_ini_c / W_final_c); % [m]
% --- 4. Genera i vettori per il plot ---
% Zona 1: Max Payload 
R_zone1_x_km = [0, R_a/1000];
Q_pay_zone1_y_kg = [W_pay_a, W_pay_a];
% Zona 2: Constant MTOW (Curva trade-off) 
% Genero un vettore di range tra punto (a) e (b)
R_zone2_x = linspace(R_a, R_b, 50);
% Calcolo il payload corrispondente usando la formula inversa di Breguet
Q_pay_zone2_y_kg = MTOW * exp(-R_zone2_x / K_range) - Q_OE;
R_zone2_x_km = R_zone2_x / 1000;
% Zona 3: Max Fuel (Curva con payload ridotto) 
% Genero un vettore di payload tra punto (b) e (c)
Q_pay_zone3_y_kg = linspace(W_pay_b, W_pay_c, 50);
% Calcolo il range corrispondente usando la formula diretta di Breguet
W_ini_zone3 = Q_OE + Q_pay_zone3_y_kg + Q_f_max_tank;
W_final_zone3 = Q_OE + Q_pay_zone3_y_kg;
R_zone3_x = K_range * log(W_ini_zone3 ./ W_final_zone3);
R_zone3_x_km = R_zone3_x / 1000;
% --- 5. Plotta il diagramma ---
figure;
plot(R_zone1_x_km, Q_pay_zone1_y_kg, 'b-', 'LineWidth', 2);
hold on;
plot(R_zone2_x_km, Q_pay_zone2_y_kg, 'r-', 'LineWidth', 2);
plot(R_zone3_x_km, Q_pay_zone3_y_kg, 'g-', 'LineWidth', 2);
% Aggiungi punti e label per chiarezza
plot(R_a/1000, W_pay_a, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
text(R_a/1000, W_pay_a, '  Punto (a)', 'VerticalAlignment', 'bottom');
plot(R_b/1000, W_pay_b, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
text(R_b/1000, W_pay_b, '  Punto (b)', 'VerticalAlignment', 'bottom');
plot(R_c/1000, W_pay_c, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
text(R_c/1000, W_pay_c, '  Ferry Range (c)', 'VerticalAlignment', 'bottom');
text(R_a/2000, W_pay_a, 'ZONA 1 ', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
text((R_a+R_b)/2000, (W_pay_a+W_pay_b)/2, 'ZONA 2 ', 'HorizontalAlignment', 'center');
text((R_b+R_c)/2000, W_pay_b/2, 'ZONA 3 ', 'HorizontalAlignment', 'center');
title('Diagramma Payload-Range (Regional Jet)');
xlabel('Range (km)');
ylabel('Payload (kg)');
grid on;
grid minor;
hold off;