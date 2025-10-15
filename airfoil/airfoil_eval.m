
% --- Step 1: Collect inputs ---
%RICORDATI DI AVERE REYNOLDS INSERITO

alpha_i = input('Enter initial alpha: ');
alpha_f = input('Enter final alpha: ');
alpha_step = input('Enter alpha step: ');
n_iter = 100; 
xfoil_path = 'xfoil.exe'; 

% --- Step 2: Prepare folders ---
profiles_folder = pwd; % current folder
output_folder = pwd;   % same folder for results
files = dir(fullfile(profiles_folder, '*.dat'));

if isempty(files)
    error('No .dat files found in current directory!');
end

% --- Step 3: Iterate through airfoils ---
for k = 1:length(files)
    airfoil_name = erase(files(k).name, '.dat');
    polar_file = fullfile(output_folder, [airfoil_name '_polar.txt']);
    input_file = fullfile(output_folder, 'the_trainman.in');

    fprintf('\n=== Processing %s ===\n', airfoil_name);

    % --- Create the XFOIL input file ---
    fid = fopen(input_file, 'w');
    fprintf(fid, 'LOAD %s\n', files(k).name);
    fprintf(fid, '%s\n', airfoil_name);
    fprintf(fid, 'PANE\n');
    fprintf(fid, 'OPER\n');
    fprintf(fid, 'Visc %.0f\n', Re);
    fprintf(fid, 'PACC\n');
    fprintf(fid, '%s\n\n', polar_file);
    fprintf(fid, 'ITER %d\n', n_iter);
    fprintf(fid, 'ASeq %.2f %.2f %.2f\n', alpha_i, alpha_f, alpha_step);
    fprintf(fid, '\n\nquit\n');
    fclose(fid);

    % --- Step 4: Run XFOIL ---
    try
        tic;
        cmd = sprintf('"%s" < "%s"', xfoil_path, input_file);
        [status, cmdout] = system(cmd);
        elapsed = toc;

        if status ~= 0
            fprintf('❌ Error running %s:\n%s\n', airfoil_name, cmdout);
        else
            fprintf('✅ Successfully computed %s in %.2f seconds\n', airfoil_name, elapsed);
        end

    catch ME
        fprintf('⚠️ Error: %s\n', ME.message);
    end
end

fprintf('\nAll airfoils processed.\n');
