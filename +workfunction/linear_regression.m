function [mdl]=linear_regression(var_x,var_y,Display,Array)
    arguments
        %var_x double {mustBeVector(var_x)}
        %var_y double {mustBeVector(var_y)}
        % var_x {mustBeTextScalar}
        var_x
        var_y 
        Display logical = false
        Array double = linspace(0,300,200)  % default array
    end
    var_x = char(var_x);
    var_y = char(var_y);
    global Database
    X_var=Database.(var_x);
    Y_var=Database.(var_y);
    mdl=fitlm(X_var,Y_var, 'linear', 'VarNames',{var_x, var_y});

    Array=Array(:);
    y_array=predict(mdl, Array);
    
    if Display==true
        figure
        scatter(X_var,Y_var,'filled');
        hold on
        plot(Array,y_array);
        xlabel(var_x);
        ylabel(var_y);
        title(sprintf('Retta di regressione lineare di %s in funzione di %s',var_y, var_x))
        grid on
        grid minor
        hold off
    end

end 