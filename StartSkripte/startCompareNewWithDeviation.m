%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Das Skript erzeugt ein BoxPlot in dem die Genauigkeit bezogen auf
den Self-Rating-Graph angezeigt wird. Außerdem werden alle dafür
verwendeten Werte in eine Excel Datei gespeichert.
Hier wird das erweiterte Modell nach Kamiji mit leicht veränderten
erweiterten Modell nach Kamiji verglichen. Die Veränderung bei den anderen
Modell betrifft die Winkelgeschwindigkeit. Diese Winkelgeschwindigkeit wird
mittels eines Faktors <delta> (Funktion: SimSVC_WithDeviation) angepasst.
%==========================================================================
%}

clc; clear; close all;

%M-Files
addpath('..\Funktionen\');

%geändertes Modell
modelpathnew = '..\Kinetose-Modelle\Final_Modell_Kamiji_erweitert\';
modelparamnew = '..\Kinetose-Modelle\Final_Modell_Kamiji_erweitert\ParamterKamijiSVC_Changed.m';

%Daten laden
datafiles = '..\Daten\Gruppen\Kontrollgruppe\';
xlsxfile = '..\Daten\Teilnehmer_Xlsx\';

%Speicherpfad der Excel Tabelle
savePath = '..\Exporte\Overview_Final_Results_with_Deviation.xlsx';

%Eigenschaften
fs = 100; %[Hz]
fa = 0.2; %[Hz]

%% Simaltion Original und Daten sammeln
ResultDevi90 = SimSVC_WithDeviation(datafiles, xlsxfile, modelpathnew, modelparamnew, fa, fs, 0.9);
n = 1;
for i=1:length(ResultDevi90)
    if ResultDevi90(i).DataOk
        MSIFinalDevi90(n) = ResultDevi90(i).MSI_K_all(end);
        SelfRateDevi90(n) = double(ResultDevi90(i).kinetosis_level(end)*10);
        n=n+1;
    end    
end

%% Simaltion Original und Daten sammeln
ResultDevi80 = SimSVC_WithDeviation(datafiles, xlsxfile, modelpathnew, modelparamnew, fa, fs, 0.8);
n = 1;
for i=1:length(ResultDevi80)
    if ResultDevi80(i).DataOk
        MSIFinalDevi80(n) = ResultDevi80(i).MSI_K_all(end);
        SelfRateDevi80(n) = double(ResultDevi80(i).kinetosis_level(end)*10);
        n=n+1;
    end    
end

%% Simaltion Original und Daten sammeln
ResultDevi70 = SimSVC_WithDeviation(datafiles, xlsxfile, modelpathnew, modelparamnew, fa, fs, 0.7);
n = 1;
for i=1:length(ResultDevi70)
    if ResultDevi70(i).DataOk
        MSIFinalDevi70(n) = ResultDevi70(i).MSI_K_all(end);
        SelfRateDevi70(n) = double(ResultDevi70(i).kinetosis_level(end)*10);
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
deviationWith90 = 100-(abs(MSIFinalDevi90-SelfRateDevi90)./SelfRateDevi90) * 100; %[%]
deviationWith80 = 100-(abs(MSIFinalDevi80-SelfRateDevi80)./SelfRateDevi80) * 100; %[%]
deviationWith70 = 100-(abs(MSIFinalDevi70-SelfRateDevi70)./SelfRateDevi70) * 100; %[%]
deviationWithout = 100-(abs(MSIFinalNew-SelfRateNew)./SelfRateNew) * 100; %[%]
deviationAll = [deviationWith70' deviationWith80' deviationWith90' deviationWithout'];

%Box Plot erstellen
figure(1);
ax = gca;
boxchart(ax,deviationAll);
set(ax,'FontSize',17)
ylabel('Genauigkeit [%]');
ylim([0 100]);
xticklabels({'70% Winkelgeschw.','80% Winkelgeschw.','90% Winkelgeschw.', '100% Winkelgeschw.'});
titleText = ['Vergleich der Vorhersagegenauigkeit bei',char(10),'verschiedenen Winkelgeschwindigkeiten'];
title(titleText, 'FontSize', 19);
grid on;
grid minor;

%speichern der Ergebnisse als Excel
ResultArr = [Ids' MSIFinalNew' MSIFinalDevi90' MSIFinalDevi80' MSIFinalDevi70'];
ResultTable = array2table(ResultArr,'VariableNames',{'Id','MSI_AngRate_100%','MSI_AngRate_90%','MSI_AngRate_80%',...
    'MSI_AngRate_70%'});
writetable(ResultTable, savePath);
msg = strcat('Gespeichert unter: "', savePath, '"');
disp(msg);
