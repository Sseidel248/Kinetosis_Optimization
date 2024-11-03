clc; clear; close all;

addpath('..\..\Funktionen\');
%Parameter laden
run( 'ParameterBarccesiUNIPG.m' );

%matDir = 'D:\Studium\01_Bachelor_Studium\_Bachelorarbeit\Modell\Kinetose-Modelle\TestMessungen';
matDir = '..\..\Daten\TestMessungen\';
%xlxsDir = 'D:\Studium\01_Bachelor_Studium\_Bachelorarbeit\Modell\Kinetose-Modelle\TestMessungen';
xlsxDir = '..\..\Daten\Teilnehmer_Xlsx\';

Subject = getSubjectData(matDir, xlsxDir);

%{
Unterschied Kamiji und Barccesi Koordinatensystem
Messung - Kamiji  - Barccesi
x       - x       - z
y       - y       - x
z       - z       - y
%}

% Laden der Beschleunigungen
AZB = Subject(1).a_x;
AXB = Subject(1).a_y;
AYB = Subject(1).a_z;

% Erzeugen eines Zeitvektors mit entsprechender der Zeitschrittweite
f = 100;   %[Hz]
dt = 1/f;  %[s] 0.01s -> alle 10ms ein Sample
t_max = (length(AXB)/f); 
t = (0:dt:t_max-dt)';

%StopTime der Simulation
t_Stop = t_max;

%% Arrays transponieren
% erzeugen Beschleunigungsvektor [m/s²]
a = [];
a(:,1) = AXB';
a(:,2) = AYB';
a(:,3) = AZB';%beinhaltet bereit die Erdbeschleunigung

%% Simulation des Modells von Barccesi

% Zeit-Beschleunigungs-vektor kombinieren
t_ax_arr = [t, a(:,1)];
t_ay_arr = [t, a(:,2)];
t_az_arr = [t, a(:,3)];
    
%Änderungrate der Beschleunigung 0.2Hz
k_freq = GetKFactor( 0.2 );
    
% Starten der Simulation
disp('Simulation läuft...');   
ergUNIPG = sim('UNIPG_Modell.slx');
disp('Simulation ist beendet.');
    
% Zwischenspeichern der Ergebnisse
MSI_all = ergUNIPG.sim_MSI;
tout = ergUNIPG.tout;%[s]
t_out = tout;
MSI_Max = max(MSI_all);
    
disp('Maximalwert MSI [%]:');
disp(MSI_Max);

%Vergleich Geschwindigkeit mit MSI-Verlauf
figure(2)

yyaxis left
plot(tout,MSI_all);
ylabel( 'MSI [%]');
ylim([0 100]);

yyaxis right
plot(Subject(1).kinetosis_level_timestemp,Subject(1).kinetosis_level);
ylabel( 'Self Rating (MISC)  [-]');
ylim([0 10]);

xlabel( 'Zeit in [s]');
title( 'MSI-Verlauf bei 3-Dimensionaler Anregung');

function k_out = GetKFactor( AccSamplerate )
    f_org = [0, 0.083, 0.1, 0.125, 0.167, 0.250, 0.333, 0.417, 0.5]';   
    k_faktor = [0, 0.02, 0.1, 1.65, 2, 1.25, 0.4, 0.05, 0.01 ]';

    f_fine = (0:0.001:0.5)';

    xInterP = interp1( f_org, k_faktor, f_fine, 'pchip' ); 

    arr = [f_fine, xInterP];
    k_out = arr( arr(:,1)==AccSamplerate,2 );
    % plot(f_fine, xInterP);
    % grid on
    % disp( 'Testausgabe für f = 0.2Hz' );
    % disp( 'K-Faktor:' );
    % test = arr( arr(:,1)==0.2,2 );
    % disp( test );
    % disp( 'Max K_Faktor:' );
    % disp( max(arr(:,2)) );
end