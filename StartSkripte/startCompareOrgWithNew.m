%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Das Skript erzeugt ein BoxPlot in dem die Genauigkeit bezogen auf
den Self-Rating-Graph angezeigt wird. Außerdem werden alle dafür
verwendeten Werte in eine Excel Datei gespeichert.
Hier wird das Originalmodell nach Kamiji mit dem erweiterten
Modell nach Kamiji verglichen.

%==========================================================================
%}

clc; clear; close all;

%M-Files
addpath('..\Funktionen\');

%geändertes Modell
modelpathnew = '..\Kinetose-Modelle\Final_Modell_Kamiji_erweitert\';
modelparamnew = '..\Kinetose-Modelle\Final_Modell_Kamiji_erweitert\ParamterKamijiSVC_Changed.m';

%Original Modell
modelpathorg = '..\Kinetose-Modelle\Modell_Kamiji\';
modelparamold = '..\Kinetose-Modelle\Modell_Kamiji\ParamterKamijiSVC.m';

%Daten laden
datafiles = '..\Daten\Gruppen\Kontrollgruppe\';
xlsxfile = '..\Daten\Teilnehmer_Xlsx\';

%Speicherpfad der Excel Tabelle
savePath = '..\Exporte\Overview_Final_Results.xlsx';

%Eigenschaften
fs = 100; %[Hz]
fa = 0.2; %[Hz]

%% Simaltion Original und Daten sammeln
ResultOrg = SimOrgSVC(datafiles, xlsxfile, modelpathorg, modelparamold, fs);
n = 1;
for i=1:length(ResultOrg)
    if ResultOrg(i).DataOk
        MSIFinalOrg(n) = ResultOrg(i).MSI_K_all(end);
        SelfRateOrg(n) = double(ResultOrg(i).kinetosis_level(end)*10);
        n=n+1;
    end    
end

%% Simulation Verändert und Daten sammeln
ResultNew = SimSVC(datafiles, xlsxfile, modelpathnew, modelparamnew, fa, fs);
n = 1;
for i=1:length(ResultNew)
    if ResultNew(i).DataOk
        Ids(n) = ResultNew(i).Id;
        MSIFinalNew(n) = ResultNew(i).MSI_K_all(end);
        SelfRateNew(n) = double(ResultNew(i).kinetosis_level(end)*10);
        n=n+1;
    end    
end

%% Auswertung
deviationOrg = 100-(abs(MSIFinalOrg-SelfRateOrg)./SelfRateOrg)*100; %[%]
deviationNew = 100-(abs(MSIFinalNew-SelfRateOrg)./SelfRateNew)*100; %[%]
deviationAll = [deviationOrg' deviationNew'];

%Box Plot erstellen
figure(1);
ax = gca;
boxchart(ax,deviationAll);
set(ax,'FontSize',16)
ylabel('Genauigkeit [%]');
ylim([0 100]);
xticklabels({'Original', 'Erweitert'});
title('Kinetose Vorhersagegenauigkeit der Kamiji-Modelle', 'FontSize', 18);
grid on;
grid minor;

%speichern der Ergebnisse als Excel
ResultArr = [Ids' MSIFinalOrg' MSIFinalNew' (SelfRateNew/10)' SelfRateNew' deviationOrg' deviationNew'];
ResultTable = array2table(ResultArr,'VariableNames',{'Id','MSI_Org','MSI_New','MISC',...
    'MISC in MSI', 'Genauigkeit_Org', 'Genauigkeit_New'});
writetable(ResultTable, savePath);
msg = strcat('Gespeichert unter: "', savePath, '"');
disp(msg);
