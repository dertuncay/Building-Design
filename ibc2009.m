function [ TT, Sa ] = ibc2009( pga, psa02, psa10, site_class )
%Calculates design spectra for given PGA, PSA02 and PSA1 and Site Class by using
%International building code 2009 standarts
% Outputs
% Sa - Spectral Acceleration
% TT - Periods

% pga is the peak ground acceleration value which can be find in hazard
% maps

% psa02 is Pseudo Spectral Acceleration value in 0.2 s
% psa10 is Pseudo Spectral Acceleration value in 1.0 s

% site_class is the soil classification of EC8. 
% It can be 'A','B','C','D','E'

%Site Amplification Coefficient for PSA 0.2
switch site_class
    case 'A'
        Fa = 0.8;
    case 'B'
        Fa = 1.0;
    case 'C'
        if psa02 == 0.75
            Fa = 1.1;
        elseif site_class == 'C' && psa02 > 0.75
            Fa = 1.0;
        elseif psa02 <= 0.5
            Fa = 1.2;
        end
    case 'D'
        if psa02 <= 0.25
            Fa = 1.6;
        elseif psa02 == 0.5
            Fa = 1.4;
        elseif psa02 == 0.75
            Fa = 1.2;
        elseif psa02 == 1.0
            Fa = 1.1;
        elseif psa02 >= 1.25
            Fa = 1.0;
        end
    case 'E'
        if psa02 <= 0.25
            Fa = 2.5;
        elseif psa02 == 0.5
            Fa = 1.7;
        elseif psa02 == 0.75
            Fa = 1.2;
        elseif psa02 == 1.0
            Fa = 0.9;
        elseif psa02 >= 1.25
            Fa = 0.9;
        end
end

%Site Amplification Coefficient for PSA 1.0
switch site_class
    case 'A'
        Fv = 0.8;
    case 'B'
        Fv = 1.0;
    case 'C'
        if psa10 <= 0.1
            Fv = 1.7;
        elseif psa10 == 0.2
            Fv = 1.6;
        elseif psa10 == 0.3
            Fv = 1.5;
        elseif psa10 == 0.4
            Fv = 1.4;
        elseif psa10 >= 0.5
            Fv = 1.3;
        end
    case 'D'
        if psa10 <= 0.1
            Fv = 2.4;
        elseif psa10 == 0.2
            Fv = 2.0;
        elseif psa10 == 0.3
            Fv = 1.8;
        elseif psa10 == 0.4
            Fv = 1.6;
        elseif psa10 >= 0.5
            Fv = 1.5;
        end
    case 'E'
        if psa10 <= 0.1
            Fv = 3.5;
        elseif psa10 == 0.2
            Fv = 3.2;
        elseif psa10 == 0.3
            Fv = 2.8;
        elseif psa10 == 0.4
            Fv = 2.4;
        elseif psa10 >= 0.5
            Fv = 2.4;
        end
end

% Maximum Considered Earthquake Spectral Acceleration
Sm02 = Fa*psa02;
Sm10 = Fv*psa10;

% Design Spectral Acceleration Values
Sd02 = (2/3)*Sm02;
Sd10 = (2/3)*Sm10;

% Plotting Parameters
T0 = 0.2*(Sd10/Sd02);
Ts = (Sd10/Sd02);
% T 0 - T0
Tst = 0:0.01:T0;
% T flat part
Ti = T0:0.01:Ts;
% T Ts - 3 s
Tl = Ts:0.01:3;
% Total T
T = [Ts Ti Tl];

% Sa 0 - T0
Sas = Sd02.*(0.4+0.6.*(Tst./T0));
% Sa flat part
sai = ones(1,length(Ti));
Sai = sai.*Sd02;
% Sa Ts - 3 s
Sal = Sd10./Tl;
% Total Sa
Sa = pga*[Sas Sai Sal];

%Periods
TT = linspace(0,3,length(Sa));

plot(TT,Sa)
xlabel('Periods (s)')
ylabel('Spectral Acceleration (cm / s^{2})')
title('Design Spectra')
legend(['Site Class ' site_class])
end