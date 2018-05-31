function [ TT, Sa ] = dbybhy( pga, site_class,I )
%Calculates design spectra for given PGA, Site Class and building importance 
%coefficient/factor  by using Turkish Design Code 2007 standarts
% Language: Turkish
% http://www.imo.org.tr/resimler/dosya_ekler/bab4c5794c4be19_ek.pdf
% Page: 11 - 13
% Outputs
% Sa - Spectral Acceleration
% TT - Periods


% pga is 0.4 for 1st degree earthquake zone
% 0.3 for 2nd degree earthquake zone
% 0.2 for 3rd degree earthquake zone
% 0.1 for 4th degree earthquake zone

% site_class is the soil classification of EC8. 
% It can be 'A','B','C','D','E'

%building importance coefficient/factor
% 1 - Residence, hotel, office (Use this if you are not sure!)
% 1.2 - Cinema, Theater, Concert Hall, Sport Facility
% 1.4 - School, Dormatory, Museus, Prison, Military post
% 1.5 - Hospital, Fire Station, Postal Office, Transportation stations
% (train, metro, harbor, airport etc.), power plant, disaster plan
% stations, public buildings, depots with explosives and toxic materials.
if I == 1.0 || I == 1.2 || I == 1.4 || I == 1.5
    I = I;
else
    disp('I can only be 1, 1.2, 1.4 or 1.5!')
    return
end

% Spectral Acceleration Coefficient
% A(T) = pga*I*Sa
% Elastic Spectral Acceleration
% Sae(T) = A(T)*g


%Site Amplification Coefficient for PSA 0.2
switch site_class
    case 'A'
        Ta = 0.1;
        Tb = 0.3;
    case 'B'
        Ta = 0.15;
        Tb = 0.40;
    case 'C'
        Ta = 0.15;
        Tb = 0.60;

    case 'D'
        Ta = 0.20;
        Tb = 0.90;      
    case 'E'
        Ta = 0.20;
        Tb = 0.90;      
end

% T 0 - T0
Tst = 0:0.01:Ta;
% T flat part
Ti = Ta:0.01:Tb;
% T Ts - 3 s
Tl = Tb:0.01:3;
% Total T
T = [Tst Ti Tl];

% Sa 0 - T0
Sas = 1 + 1.5.*(Tst./Ta);
% Sa flat part
sai = ones(1,length(Ti));
Sai = sai.*2.5;
% Sa Ts - 3 s
Sal = 2.5.*(Tb./Tl).^0.8;
% Total Sa
Sa = pga*I*[Sas Sai Sal];

%Periods
TT = linspace(0,3,length(Sa));

plot(TT,Sa)
xlabel('Periods (s)')
ylabel('Spectral Acceleration (cm / s^{2})')
title('Design Spectra')
legend(['Site Class ' site_class])
end