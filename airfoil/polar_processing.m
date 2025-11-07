clear
clc
load('dimensionamentoPreliminare.mat')

% 
% alfa_min = -4;
% alfa_max = 8;
% alfa_step = 1;
% AoA_vect = AoA_min:AoA_step:AoA_max;
% Re = dimensionamento_preliminare.Re_wing;
% Mach = dimensionamento_preliminare.M;
% XfoilFolder=fullfile(pwd, 'airfoils_data\xfoil.exe');
% current_dir=string(cd);
% profiles_folder = fullfile(pwd, 'airfoils_data');
% output_folder = fullfile(pwd, 'airfoil_polars');
% files = dir(fullfile(profiles_folder, '*.dat')); %prendo tutti i file nella cartella
% full_coord_airfoils={files.name}; %prendo solamente i nomi degli airfoils.
% excluded_airfoils = {'e549.dat','goe398.dat','goe533.dat','l7769.dat'}; %lista di airfoils esclusi che non funzionano
% evaluations_arifoils = setdiff(full_coord_airfoils, excluded_airfoils); %finalmente stringa finale di airfoils che voglio date
% 
% [status,cmdout] = airfoil_eval(alfa_min,alfa_max,alfa_step,Re,XfoilFolder,output_folder,profiles_folder,evaluations_arifoils{1});

% for a=1:length(evaluations_arifoils)
% [status,cmdout] = airfoil_eval(alfa_min,alfa_max,alfa_step,Re,XfoilFolder,output_folder,profiles_folder,evaluations_arifoils{a});
% end



polarFolder = fullfile(pwd, 'airfoil_polars');
polarFiles = dir(fullfile(polarFolder, '*.txt'));
AirfoilName={};
allAlpha = [];
allCl = [];
allCd = [];
for k = 1:length(polarFiles)
    filePath = fullfile(polarFolder, polarFiles(k).name);
    fprintf('Reading %s\n', filePath);
    [~, baseName, ~] = fileparts(polarFiles(k).name);
    airfoilName = regexprep(baseName, '(^polar_|_polar.*$)', '');

    data = readtable(filePath, 'FileType', 'text', 'HeaderLines', 10);
    if height(data) < 3
        disp('Polare non valida')
    elseif any(strcmpi(data.Properties.VariableNames, 'alpha'))
        alpha = data.alpha;
        Cl = data.CL;
        Cd = data.CD;
    else
        alpha = data.Var1;
        Cl = data.Var2;
        Cd = data.Var3;
    end
    nRows = length(alpha);
    AirfoilName = [AirfoilName; repmat({airfoilName}, nRows, 1)];
    allAlpha = [allAlpha; alpha];
    allCl = [allCl; Cl];
    allCd = [allCd; Cd];
end
polarData = table(AirfoilName, allAlpha, allCl, allCd, ...
                  'VariableNames', {'AirfoilName','Alpha','Cl','Cd'});
disp(polarData(1:10, :));

save('all_airfoils_polars.mat', 'polarData');


airfoils = unique(polarData.AirfoilName);
nAirfoils = length(airfoils);

figure;
colors = lines(nAirfoils);  % distinct colors
for k = 1:nAirfoils
    idx = strcmp(polarData.AirfoilName, airfoils{k});
    plot(polarData.Alpha(idx), polarData.Cl(idx), '.-', 'Color', colors(k,:), 'DisplayName', airfoils{k});
    hold on;
end
xlabel('\alpha (deg)'); ylabel('C_L'); grid on;
legend('Location','best');
title('Curve di Cl funzione di \alpha');

figure;
colors = lines(nAirfoils);  % distinct colors
for k = 1:nAirfoils
    idx = strcmp(polarData.AirfoilName, airfoils{k});
    plot(polarData.Cd(idx), polarData.Cl(idx), '.-', 'Color', colors(k,:), 'DisplayName', airfoils{k});
    hold on;
end
hold off
xlabel('C_D'); ylabel('C_L'); grid on;
legend('Location','best');
title('Polar Curves for All Airfoils');

figure;
for i=1:nAirfoils
    idx=strcmp(polarData.AirfoilName, airfoils{i});
    E=polarData.Cl(idx)./polarData.Cd(idx);
    plot(polarData.Alpha(idx),E,'.-', 'Color',colors(i,:), 'DisplayName',airfoils{i});
    hold on;
end
hold off;
xlabel('\alpha'); ylabel('E'); grid on;
legend('Location','best');
title('Efficienza funzione di \alpha');