function [status,cmdout]=airfoil_eval(alpha_i,alpha_f,alpha_step,Re,xfoil_path,output_folder,profiles_folder,evaluation_airfoil)


n_iter = 100; 
airfoil_name = evaluation_airfoil;
polar_file = fullfile(output_folder, [erase(airfoil_name, '.dat') '_polar.txt']);
input_file = fullfile(profiles_folder, 'the_trainman.in');

fprintf('\n=== Processing %s ===\n', airfoil_name);
airfoil_path = fullfile(profiles_folder, airfoil_name); 
    % --- Create the XFOIL input file ---
    fid = fopen(input_file, 'w');
    fprintf(fid, 'LOAD \n');
    fprintf(fid, '%s\n',airfoil_name);
    % fprintf(fid, '%s\n', airfoil_name);
    fprintf(fid, 'PANE\n');
    fprintf(fid, 'OPER\n');
    fprintf(fid, 'Visc %.0f\n', Re);
    fprintf(fid, 'PACC\n');
    fprintf(fid, '%s\n', polar_file);     % start saving polar
    fprintf(fid, 'y\n');
    fprintf(fid, '\n');
    fprintf(fid, 'ITER %d\n', n_iter);
    fprintf(fid, 'ASeq %.2f %.2f %.2f\n', alpha_i, alpha_f, alpha_step);
    fprintf(fid, 'QUIT\n');
    fclose(fid);


    try
        tic;
        current_dir = pwd;                          % save current folder
        cd('airfoils_data');                % change to XFOIL folder
        cmd = sprintf('"%s" < "%s"', xfoil_path, input_file);
        [status, cmdout] = system(cmd);
        elapsed = toc;
        cd(current_dir);   
        if status ~= 0
            fprintf('❌ Error running %s:\n%s\n', airfoil_name, cmdout);
        else
            fprintf('✅ Successfully computed %s in %.2f seconds\n', airfoil_name, elapsed);
        end

    catch ME
        fprintf('⚠️ Error: %s\n', ME.message);
    end
end