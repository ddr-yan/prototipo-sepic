clear;
close all;


%% Especificaciones del convertidor

Fsw_val    = 500e3;     % 500 kHz
Vin_val    = 12;        % 12 V
Vinmin_val = 11;        % 11 V
Vinmax_val = 13;        % 13 V
Iout_val   = 2;         % 2 A
Vout_val   = 12;        % 12 V
Voutmax_val= Vout_val;  
Vd_val     = 0.525;     % 0.525 ohm
Rdson_val  = 22e-3;     % 22 mohm
Qgd_val    = 26e-9;     % 26 nF
Ig_val     = 1;         % 1 A
Vripple_val= 0.1;       % 100 mV
Ct_val     = 1e-9;      % 1 nf 
n_val = 0.9;            %eficiencia estimada


%% Función para mostrar valores en el sistema internacional
function printSI(name, val, unit)

    % Conversión previa de unidades especiales
    switch unit
        case 'mV/us'
            val = val * 1e-3;   % V/s → mV/us
            baseUnit = 'mV/us';
            usePrefix = false;  % NO aplicar prefijos SI
        otherwise
            baseUnit = unit;
            usePrefix = true;
    end

    if val == 0
        fprintf('%s = 0 %s\n', name, baseUnit);
        return;
    end

    prefixes = {'p','n','u','m','','k','M','G'};
    scales   = [1e-12 1e-9 1e-6 1e-3 1 1e3 1e6 1e9];

    if usePrefix
        idx = find(abs(val) ./ scales >= 1 & abs(val) ./ scales < 1000, 1, 'last');

        if isempty(idx)
            idx = 5; % sin prefijo
        end

        scaled = val / scales(idx);

        str = sprintf('%.3f', scaled);
        str = regexprep(str, '\.?0+$', '');

        fprintf('%s = %s %s%s\n', name, str, prefixes{idx}, baseUnit);

    else
        % Sin prefijo (caso mV/us)
        str = sprintf('%.3f', val);
        str = regexprep(str, '\.?0+$', '');

        fprintf('%s = %s %s\n', name, str, baseUnit);
    end
end

%% 1) Símbolos
syms Fsw Vin Iout Vout Vinmin Vinmax Vd Rdson Qgd Ig Voutmax Vripple Cs Ct n

%% 2) Ecuaciones componentes

%% Componentes pasivos
D    = (Vout+Vd)/(Vin+Vout+Vd);
Dmax = (Vout+Vd)/(Vinmin+Vout+Vd);
Dmin = (Vout+Vd)/(Vinmax+Vout+Vd);
Iin  = Iout*D/(1-D);
Iinp = Iin/n;
Iripple=0.25;
dIl  = Iinp*Iripple; 


L1   = Vinmin*Dmax/(dIl*Fsw);
L2   = L1;
IL1pk = (Iinp)*(1+Iripple/2);
IL2pk = Iout+ dIl/2;

Cin =  (Vout*Iout/Vinmin) *(1-Dmax)/(Vripple*Fsw); 
Icinrms     = dIl/sqrt(12); 

Cs = Iout*Dmax/(0.05*Vinmax*Fsw);
Csesr = 0.05*Vinmax/max(IL1pk,IL2pk); 
Icsrms = Iinp*sqrt((1-Dmax)/Dmax);

Cout     = Iout*Dmax/(Vripple*Fsw);
Coutesr      = Vripple/(IL1pk+IL2pk);
Icoutrms = Iout*sqrt(Dmax/(1-Dmax));

%% Componentes activos

Iqpk  = IL1pk+IL2pk;
Iqrms = Iinp/sqrt(Dmax);
Pq    = Iqrms^2*Rdson*Dmax + (Vinmin+Vout+Vd)*Iqpk*(Qgd*Fsw)/Ig;
Vqmin = Vinmax+Voutmax+Vd;

Idpk = Iqpk;
Vdr = Vqmin;

%% 3) Ecuaciones controlador/compensación  

Rcs = 1/Iqpk;

Rcs_val = 0.2; % se selecciona Rcs como 0.2 ohm.
% Divisor de realimentación
Vref = 2.495;
Rfbu = 100e3;
Rfbb = Rfbu*(Vref/(Vout-Vref));  %Se selecciona RFBU como 100k

%Frecuencia de conmutación
Rt   =  1.72/(Ct*Fsw);%Se selecciona Ct como 1000pf

%pendiente de compensación
L1_val= 50e-6;
L2_val=L1_val;% se selecciona una 
Sn = Vinmin*Rcs_val/(L1_val*L2_val/(L1_val+L2_val)); %pendiente de subida del inductor L1
Mideal = (1/pi+0.5)/(1-D);   %factor de compensación ideal
Se = (Mideal-1)*Sn; %pendiente de compensación
tonmin=Dmin/Fsw; % tiempo minimo de conducción
Sosc  = 1.7/tonmin; % pendiente de carga del oscilador
Rcsf = 22e3/(Sosc/Se-1); % resistencia de filtrado necesaria


%% 5) Vector de sustitución
vars = [ Fsw,    Vin,    Vinmin,    Vinmax,    Iout,    Vout,    Voutmax,    Vd,    Rdson,    Qgd,    Ig,    Vripple     Ct     , n];
vals = [ Fsw_val,Vin_val,Vinmin_val,Vinmax_val,Iout_val,Vout_val,Voutmax_val,Vd_val,Rdson_val,Qgd_val,Ig_val,Vripple_val Ct_val , n_val];

%% 6) Evaluación
sol_D        = double(subs(D,        vars, vals));
sol_Dmax     = double(subs(Dmax,     vars, vals));
sol_Dmin     = double(subs(Dmin,     vars, vals));

sol_Iin      = double(subs(Iin,      vars, vals));
sol_Iinp      = double(subs(Iinp,      vars, vals));
sol_dIl      = double(subs(dIl,      vars, vals));

sol_L1       = double(subs(L1,       vars, vals));
sol_L2       = double(subs(L2,       vars, vals));
sol_IL1pk    = double(subs(IL1pk,    vars, vals));
sol_IL2pk    = double(subs(IL2pk,    vars, vals));

sol_Iqpk     = double(subs(Iqpk,     vars, vals));
sol_Iqrms    = double(subs(Iqrms,    vars, vals));
sol_Pq       = double(subs(Pq,       vars, vals));
sol_Vqmin       = double(subs(Vqmin,       vars, vals));

sol_Idpk     = double(subs(Idpk,     vars, vals));
sol_Vdr     = double(subs(Vdr,     vars, vals));

sol_Cin     = double(subs(Cin,     vars, vals));
sol_Icinrms     = double(subs(Icinrms,     vars, vals));

sol_Cs     = double(subs(Cs,     vars, vals));
sol_Icsrms   = double(subs(Icsrms,   vars, vals));
sol_Csesr     = double(subs(Csesr,     vars, vals));

sol_Cout     = double(subs(Cout,     vars, vals));
sol_Coutesr      = double(subs(Coutesr,      vars, vals));
sol_Icoutrms = double(subs(Icoutrms, vars, vals));



sol_Rcs    = double(subs(Rcs,    vars, vals));
sol_Rfbu   = double(subs(Rfbu,   vars, vals));
sol_Rfbb   = double(subs(Rfbb,   vars, vals));
sol_Rt     = double(subs(Rt,     vars, vals));
sol_Sn     = double(subs(Sn,     vars, vals));
sol_Mideal = double(subs(Mideal, vars, vals));
sol_Se     = double(subs(Se,     vars, vals));
sol_tonmin = double(subs(tonmin, vars, vals));
sol_Sosc   = double(subs(Sosc,   vars, vals));
sol_Rcsf   = double(subs(Rcsf,   vars, vals));



%% 7) Mostrar resultados

printSI('D',        sol_D,        '');
printSI('Dmax',     sol_Dmax,     '');
printSI('Dmin',     sol_Dmin,     '');

printSI('Iin',      sol_Iin,      'A');
printSI('Iinp',     sol_Iinp,     'A');
printSI('dIl',      sol_dIl,      'A');

printSI('L1',       sol_L1,       'H');
printSI('L2',       sol_L2,       'H');
printSI('IL1pk',    sol_IL1pk,    'A');
printSI('IL2pk',    sol_IL2pk,    'A');

printSI('Cin',      sol_Cin,      'F');
printSI('Icinrms',  sol_Icinrms,  'A');

printSI('Cs',       sol_Cs,       'F');
printSI('Icsrms',   sol_Icsrms,   'A');
printSI('Csesr',    sol_Csesr,    'ohm');

printSI('Cout',     sol_Cout,     'F');
printSI('Coutesr',  sol_Coutesr,  'ohm');
printSI('Icoutrms', sol_Icoutrms, 'A');


printSI('Iqpk',     sol_Iqpk,     'A');
printSI('Iqrms',    sol_Iqrms,    'A');
printSI('Pq',       sol_Pq,       'W');
printSI('Vqmin',    sol_Vqmin,    'V');

printSI('Idpk',     sol_Idpk,     'A');
printSI('Vdr',      sol_Vdr,      'V');



printSI('Rcs',    sol_Rcs,    'ohm');
printSI('Rfbu',   sol_Rfbu,   'ohm');
printSI('Rfbb',   sol_Rfbb,   'ohm');
printSI('Ct',     Ct_val,     'F');
printSI('Rt',     sol_Rt,     'ohm');
printSI('Sn',     sol_Sn,     'mV/us');
printSI('Mideal', sol_Mideal, '');
printSI('Se',     sol_Se,     'mV/us');
printSI('tonmin', sol_tonmin, 's');
printSI('Sosc',   sol_Sosc,   'mV/us');
printSI('Rcsf',   sol_Rcsf,   'ohm');

