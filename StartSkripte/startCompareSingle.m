%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Dieses Skript dient dazu eine gerafische Übersicht eines Datensatzen 
darzustellen. Hierbei werden die Self-Rating des jeweiligen Probanden über 
die MSI-Werte des Modells von Kamiji und Braccesi dargestellt. Zusätzlich 
wird der qualitative zu bewertende Verlauf des MSDV der ISO 2631-1 
aufgetragen. 

%==========================================================================
%}
clc; clear; close all;

addpath('..\Funktionen\');
%Datensatz laden
matDir = '..\Daten\SingleMessung\';
% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';

addpath( '..\Kinetose-Modelle\Modell_Barccesi\' );
addpath( '..\Kinetose-Modelle\Modell_Kamiji\' );

%Parameter laden
run( 'ParamterKamijiSVC.m' );
run( 'ParameterBarccesiUNIPG.m' );

% Schrittweite festlegen
f = 100;   %[Hz]
dt = 1/f;  %[s] 0.01s -> alle 10ms ein Sample

% Abtastrate festlegen
fs = 0.2;

%Datensatz lesen
Subject = getSubjectData(matDir, xlsxDir);

%% Daten für Kamiji aufbereiten
AXB_K = Subject(1).a_x;
AYB_K = Subject(1).a_y;
AZB_K = Subject(1).a_z;

angRateX_K = Subject(1).angRateX;
angRateY_K = Subject(1).angRateY;
angRateZ_K = Subject(1).angRateZ;

t_max_K = (length(AXB_K)/f); 
t_K = (0:dt:t_max_K-dt)';

%StopTime der Simulation
t_Stop = t_max_K;

% erzeugen Beschleunigungsvektor [m/s²]
a = [];
a(:,1) = AXB_K';
a(:,2) = AYB_K';
a(:,3) = AZB_K';

% erzeugen Winkelgeschwindigkeit [rad/s]
w = [];    
w(:,1) = angRateX_K';
w(:,2) = angRateY_K';
w(:,3) = angRateZ_K';

% Zeit-Beschleunigungs-vektor kombinieren
t_a_arr = [t_K, a];
t_w_arr = [t_K, w];

% Starten der Simulation
disp('Simulation von Kamiji läuft...');
ergSVC = sim('SVC_Modell.slx');
disp('Simulation von Kamiji ist beendet.');

MSI_all_K = ergSVC.sim_MSI;%[-]
tout_K = ergSVC.tout;%[s]

%% Daten für Barccesi aufbereiten
% Anderes KOS als KAmiji
AZB_B = Subject(1).a_x;
AXB_B = Subject(1).a_y;
AYB_B = Subject(1).a_z;

t_max_B = (length(AXB_B)/f); 
t_B = (0:dt:t_max_B-dt)';

%StopTime der Simulation
t_Stop = t_max_B;

% erzeugen Beschleunigungsvektor [m/s²]
a = [];
a(:,1) = AXB_B';
a(:,2) = AYB_B';
a(:,3) = AZB_B';%beinhaltet bereit die Erdbeschleunigung

% Zeit-Beschleunigungs-vektor kombinieren
t_ax_arr = [t_B, a(:,1)];
t_ay_arr = [t_B, a(:,2)];
t_az_arr = [t_B, a(:,3)];

% Starten der Simulation
disp('Simulation von Barccesi läuft...');   
ergUNIPG = sim('UNIPG_Modell.slx');
disp('Simulation von Barccesi ist beendet.');

% Zwischenspeichern der Ergebnisse
MSI_all_B = ergUNIPG.sim_MSI;
tout_B = ergUNIPG.tout;%[s]

%% Daten für ISO2631-1 aufbereiten
% In der sitzender
AZB_ISO = Subject(1).MTi_a_z;

t_max_ISO = (length(AZB_ISO)/f); 
t_ISO = (0:dt:t_max_ISO-dt)';

%MSDV Berechnen    
[MSDV_all,~] = ISO2631_MSDV(AZB_ISO, fs);

%% Vergleichsplot erstellen
MSI_Self = Subject(1).kinetosis_level;
t_MSI_Self = Subject(1).kinetosis_level_timestemp;
str = strcat('Vergleich der Modelle, Proband*in Id: ', num2str(Subject(1).Id));

%Mit ISO 2631-1
figure(Subject(1).Id);
ax = gca;
title(str,'FontSize',20);

yyaxis left
plot( t_MSI_Self, MSI_Self );
ylim([0 12]);
ylabel('Self-Rating[-]');

yyaxis right
plot( tout_K, MSI_all_K, tout_B, MSI_all_B, t_ISO, MSDV_all );
ylim([0 120]);
ylabel('Ergebnisse der Berechnung')
xlabel('Zeit [s]');

grid on;
grid minor;
set(ax,'FontSize',18);
legend( 'Proband*in', 'MSI (Kamiji) [%]', 'MSI (Barccesi) [%]', 'MSDV (ISO 2631-1) [m/s^{1,5}]', 'Location', 'northoutside' );

%Ohne ISO 2631-1
% figure(2);
% title('Vergleich der Modelle');
% 
% yyaxis left
% plot( tout_K, MSI_all_K, tout_B, MSI_all_B );
% ylim([0 100]);
% 
% yyaxis right
% plot( t_MSI_Self, MSI_Self );
% ylim([0 10]);
% ylabel('Self-Rating[-]');
% xlabel('Zeit [s]');
% 
% grid on;
% grid minor;
% legend( 'MSI (Kamiji) [%]', 'MSI (Barccesi) [%]', str, 'Location', 'northwest' );



