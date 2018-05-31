function [ TT, Sa ] = tbdy2017( psa02, psa10, site_class,Rf )
% Calculates design spectra for given PGA, Site Class 
% by using Turkish Design Code 2017 standarts
% Language: Turkish
% http://www.resmigazete.gov.tr/eskiler/2018/03/20180318M1-2-1.pdf
% Page: 7 - 11
% Outputs
% Sa - Spectral Acceleration
% TT - Periods

% Inputs
% Rf - Distance from the closest fault
% psa02 is Pseudo Spectral Acceleration value in 0.2 s
% psa10 is Pseudo Spectral Acceleration value in 1.0 s
% site_class is the soil classification of EC8. 
% It can be 'A','B','C','D','E'

%Site Amplification Coefficient for PSA 0.2
switch site_class
    case 'A'
        Fs = 0.8;
    case 'B'
        Fs = 0.9;
    case 'C'
        if psa02 >= 0.75
            Fs = 1.2;
        elseif psa02
            Fs = 1.3;
        end
    case 'D'
        if psa02 <= 0.25
            Fs = 1.6;
        elseif psa02 == 0.5
            Fs = 1.4;
        elseif psa02 == 0.75
            Fs = 1.2;
        elseif psa02 == 1.0
            Fs = 1.1;
        elseif psa02 >= 1.25
            Fs = 1.0;
        end
    case 'E'
        if psa02 <= 0.25
            Fs = 2.4;
        elseif psa02 == 0.5
            Fs = 1.7;
        elseif psa02 == 0.75
            Fs = 1.3;
        elseif psa02 == 1.0
            Fs = 1.1;
        elseif psa02 == 1.25
            Fs = 0.9;
        elseif psa02 >= 1.50
            Fs = 0.8;
        end
end

%Site Amplification Coefficient for PSA 1.0
switch site_class
    case 'A'
        F1 = 0.8;
    case 'B'
        F1 = 0.8;
    case 'C'
        if psa10 <= 0.5
            F1 = 1.5;
        elseif psa10 >= 0.6
            F1= 1.4;
        end
    case 'D'
        if psa10 <= 0.1
            F1 = 2.4;
        elseif psa10 == 0.2
            F1 = 2.2;
        elseif psa10 == 0.3
            F1 = 2.0;
        elseif psa10 == 0.4
            F1 = 1.9;
        elseif psa10 >= 0.5
            F1 = 1.8;
        elseif psa10 >= 0.6
            F1 = 1.7;
        end
    case 'E'
        if psa10 <= 0.1
            F1 = 4.2;
        elseif psa10 == 0.2
            F1 = 3.3;
        elseif psa10 == 0.3
            F1 = 2.8;
        elseif psa10 == 0.4
            F1 = 2.4;
        elseif psa10 >= 0.5
            F1 = 2.2;
        elseif psa10 >= 0.6
            F1 = 2.0;
        end
end

% Distance to Fault Constant df
if 15 >= Rf
    dfc = 1.2;
elseif 15 < Rf && Rf <= 25
    dfc = 1.2 - 0.02*(Rf - 15);
end

% Design Spectral Acceleration Values
Sd02 = psa02*Fs;
Sd10 = psa10*F1*dfc;

% Plotting Parameters
% Corner Periods of Horizontal Design Spectrum 
TA = 0.2*(Sd10/Sd02);
TB = (Sd10/Sd02);
% T 0 - T0
Tst = 0:0.01:TA;
% T flat part
Tft = TA:0.01:TB;
% T Ts - 6 s
Tlg = TB:0.01:6;
% T 6 s - 10 s
Tlt = 6:0.01:10;
% Total T
T = [TB Tft Tlg Tlt];

% Sa 0 - T0
Sas = Sd02.*(0.4+0.6.*(Tst./TA));
% Sa flat part
sai = ones(1,length(Tft));
Sai = sai.*Sd02;
% Sa Ts - 6 s
Sal = Sd10./(Tlg);
% Sa Ts - 6 s
Slt = 6.*Sd10./(Tlt).^2;
% Total Sa
Sa = 0.4.*[Sas Sai Sal Slt];

%Periods
TT = linspace(0,6,length(Sa));

plot(TT,Sa)
xlabel('Periods (s)')
ylabel('Spectral Acceleration (cm / s^{2})')
title('Design Spectra')
legend(['Site Class ' site_class])
end