function [status, fname_xfoil] = FUNC_RunXfoil(section_name,alpha,Re,Mach,X_foil_wd,current_dir)
% Run XFoil and return the results.
% [polar,foil] = xfoil(coord,alpha,Re,Mach,{extra commands})
%
% Xfoil.exe needs to be in the same directory as this m function.
% For more information on XFoil visit these websites;
%  http://web.mit.edu/drela/Public/web/xfoil
%
% Inputs:
%    coord: Normalised foil co-ordinates (n by 2 array, of x & y
%           from the TE-top passed the LE to the TE bottom)
%           or a filename of the XFoil co-ordinate file
%           or a NACA 4 or 5 digit descriptor (e.g. 'NACA0012')
%    alpha: Angle-of-attack, can be a vector for an alpha polar
%       Re: Reynolds number (use Re=0 for inviscid mode)
%     Mach: Mach number
% extra commands: Extra XFoil commands
%           The extra XFoil commands need to be proper xfoil commands
%           in a character array. e.g. 'oper/iter 150'
%
% The transition criterion Ncrit can be specified using the
% 'extra commands' option as follows,
% foil = xfoil('NACA0012',10,1e6,0.2,'oper/vpar n 12')
%
%   Situation           Ncrit
%   -----------------   -----
%   sailplane           12-14
%   motorglider         11-13
%   clean wind tunnel   10-12
%   average wind tunnel    9 <= standard "e^9 method"
%   dirty wind tunnel    4-8
%
% A flap deflection can be added using the following command,
% 'gdes flap {xhinge} {yhinge} {flap_defelction} exec'
%
% Outputs:
%  polar: structure with the polar coefficients (alpha,CL,CD,CDp,CM,
%          Top_Xtr,Bot_Xtr)
%   foil: stucture with the specific aoa values (s,x,y,UeVinf,
%          Dstar,Theta,Cf,H,cpx,cp) each column corresponds to a different
%          angle-of-attack.
%         If only one left hand operator is specified, only the polar will be parsed and output
%
% If there are different sized output arrays for the different incidence
% angles then they will be stored in a structured array, foil(1),foil(2)...
%
% If the output array does not have all alphas in it, that indicates a convergence failure in Xfoil.
% In that event, increase the iteration count with 'oper iter ##;
%
% Examples:
%    % Single AoA with a different number of panels
%    [pol foil] = xfoil('NACA0012',10,1e6,0.0,'panels n 330')
%
%    % Change the maximum number of iterations
%    [pol foil] = xfoil('NACA0012',5,1e6,0.2,'oper iter 50')
%

MAXiter = 100;

cd(X_foil_wd);
addpath(current_dir);
% default filenames
fname_xfoil = strrep(section_name,".dat","") + "_Re_" + strrep(string(round(Re/1e6,1,"significant")),".","_") + "_p";
file_coord_airfoil = section_name;

fid = fopen(fname_xfoil+".inp",'w');
if (fid<=0)
    error([mfilename ':io'],'Unable to create xfoil.inp file');
else

    fprintf(fid,'PLOP\n');    %Evita la messa a schermo dei risultati bho su linux è un po diverso, senza punto davanti da errore con il punto plotta lo stesso
    fprintf(fid,'G \n\n'); %Evita la messa a schermo dei risultati

    fprintf(fid,'load %s\n',file_coord_airfoil);

    % fprintf(fid,'\n ppar'); %pcop
    % fprintf(fid,'\n n ');
    % fprintf(fid,'\n 150 ');
    % fprintf(fid,'\n\n\n');

    fprintf(fid,'oper\n');

    % set Reynolds and Mach
    fprintf(fid,'re %g\n',Re);
    fprintf(fid,'mach %g\n',Mach);
    fprintf(fid,'iter %g\n',MAXiter);

    % Switch to viscous mode
    if (Re>0)
        fprintf(fid,'visc\n');
    end

    fprintf(fid,'VPAR\n');         % (enter viscous parameter menu)
    fprintf(fid,'N 10.0\n\n');

    Nalpha=length(alpha);
    % Polar accumulation
    fprintf(fid,'pacc\n\n\n');



    % Xfoil alpha calculations
    [file_dump, file_cpwr] = deal(cell(1,Nalpha)); % Preallocate cell arrays

    for ii = 1:Nalpha
        % Individual output filenames
        if alpha(ii)<0
            alpha_string = strrep(strrep(string(round(alpha(ii),2)),".","_"),"-","m");
        else
            alpha_string = strrep(string(round(alpha(ii),2)),".","_");
        end

        dump_cpwr_names = fname_xfoil + "_" + alpha_string;
        file_dump{ii} = sprintf('%s_dump.txt',dump_cpwr_names);
        file_cpwr{ii} = sprintf('%s__cpwr.txt',dump_cpwr_names);

        % Commands
        fprintf(fid,'alfa %g\n',alpha(ii));
        fprintf(fid,'dump %s\n',file_dump{ii});
        fprintf(fid,'cpwr %s\n',file_cpwr{ii});
    end
    % Polar output filename
    file_pwrt = sprintf('%s_pwrt.txt',fname_xfoil);
    fprintf(fid,'pwrt\n%s\n',file_pwrt);
    fprintf(fid,'plis\n');
    fprintf(fid,'\nquit\n');
    fclose(fid);

    Input_filename=fname_xfoil+".inp";
    Outpu_filename=fname_xfoil+".out";



    %%% Execute_xfoil =====================================================
    %======================================================================
    if ispc
        cmd = sprintf("xfoil.exe < %s > %s", Input_filename,Outpu_filename);

        arg = {'cmd', '/c',sprintf('"xfoil.exe < %s > %s"',Input_filename,Outpu_filename),'nul'};

        PB = java.lang.ProcessBuilder(arg);
        p = PB.start();

        t = 0;
        while t < 15
            if ~p.isAlive
                %disp('xfoil is finished succesfully')
                t = 15;
            else
                pause(0.01)
                t = t + 0.01;
            end
        end
        if p.isAlive
            p.destroy();
            warning([mfilename ':system'],'Xfoil has been killed! %s',cmd);
            status = 1;
        else
            status = 0;
        end
        delete(Input_filename)
        delete(Outpu_filename)
        delete(file_coord_airfoil)
        for ij=1:Nalpha
            delete(file_cpwr{ij})
            delete(file_dump{ij})
        end
    elseif isunix
        %AGGIUNGERE XFOIL PATH DAVANTI, di dove è istallato cioè di dove
        %trovo l'eseguibile
        cmd = sprintf("xfoil < %s > %s -nosplash & ", Input_filename,Outpu_filename);
        tic
        [status,cmdout] = system(cmd)

        disp('SIMULATION XFOIL LAUNCHED')
        dt = 0.1;
        time_counter = 0;
        time_max_xfoil_an = 7;

        toc
        while (isfile(file_pwrt) == false && time_counter < time_max_xfoil_an)
            pause(dt);
            time_counter = time_counter + dt;
        end
        toc
        if time_counter > time_max_xfoil_an
            status = 16;
        end

        pause(0.01)

        delete(Input_filename)
        delete(Outpu_filename)
        for ij=1:Nalpha
            delete(file_cpwr{ij})
            delete(file_dump{ij})
        end

        if status ~= 0

            %         if isfile(Outpu_filename) == false
            ExitFlagOpt.Value = 5;
            ExitFlagOpt.ExitType = 'NIENTE REPORT';
            ExitFlagOpt.Message = 'F**k: NIENTE REPORT';
            ExitFlagOpt.ExitWeight = 2e3;
            disp('NIENTE REPORT');
            cd ..
            status = 1;
            delete(Input_filename)
            delete(Outpu_filename)
            for ij=1:Nalpha
                delete(file_cpwr{ij})
                delete(file_dump{ij})
            end
            return
        else
            status = 0;
        end

    end

end
cd(current_dir) 
end
