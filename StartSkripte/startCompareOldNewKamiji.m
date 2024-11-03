%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Das Spript dient dem Vergleich von dem originalen Kamiji Modell und dem
erweiterten Kamiji Modell und erzeugt einen Plot in dem beide Ergebnisse
einen jeweils einen Datensatz übereinander gelegt wurden.

%==========================================================================
%}
clc; clear; close all;

addpath('..\Funktionen\');
%Datensatz laden
matDir = '..\Daten\SingleMessung\';
% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';

%Abtastrate
Fs = 100;
%Änderungsrate Beschleunigung
f_a = 0.2;

%% Einzelne Simualtionen starten
% erweitertes Kamiji Modell
simErgNew = SimSVC( matDir, xlsxDir, ...
    '..\Kinetose-Modelle\Final_Modell_Kamiji_erweitert\',...
    '..\Kinetose-Modelle\Final_Modell_Kamiji_erweitert\ParamterKamijiSVC_Changed.m',...
    f_a, Fs);
% Originales Kamiji Modell
simErgOrg = SimOrgSVC( matDir, xlsxDir, ...
    '..\Kinetose-Modelle\Modell_Kamiji\',...
    '..\Kinetose-Modelle\Modell_Kamiji\ParamterKamijiSVC.m',...
    Fs);

%% Vergleichsplot erstellen neu-alt-selfRating
%uncomment wenn Plots gewünscht sind
for i=1:length(simErgNew)
    if not(simErgNew(i).DataOk) || not(simErgOrg(i).DataOk)
        continue;
    end
    str = strcat( 'Proband*in Id: ', num2str(simErgNew(i).Id) );
    
    figure(simErgNew(i).Id);
    % Self-rating bei beiden SimErgOrg und SimErgNew enthalten (sind
    % gleich)
    title( 'Vergleich "Stop and Go", t < 500s' );
%     title( 'Vergleich "Stop and Go", 500s ≤ t ≤ 1000s' );
%     title( 'Vergleich "Stop and Go", t > 1000s' );
    
%     title( 'Vergleich "Spurwechsel", t < 1000s' );
%     title( 'Vergleich "Spurwechsel", 1000s ≤ t ≤ 1500s' );
%     title( 'Vergleich "Spurwechsel", t > 1500s' );

    
    yyaxis left
    plot( simErgNew(i).kinetosis_level_timestemp, simErgNew(i).kinetosis_level );
    ylim([0 10]);
    ylabel('Self-Rating [-]');
    
    yyaxis right
    plot(simErgNew(i).MSI_K_t, simErgNew(i).MSI_K_all,....
         simErgOrg(i).MSI_K_t, simErgOrg(i).MSI_K_all);
    legend( str, 'Erweitertes Modell', 'Original Modell', 'Location', 'northwest' ); 
    ylim([0 100]);
    ylabel('MSI [%]');
    xlabel('Zeit [s]');
    grid on;
    grid minor;   
end
