%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Dieses Skript dient dazu eine tabellarische Übersicht über die Probanden,
ihrer maxiamlen Self-Ratings zu bekommen. Außerdem werden zusätzlich die
maximalen vorausgesagten MSI-Werte von dem Modell Kamiji und Braccesi
bestimmt. 
Zuguterletzt soll die tabellarische Übersicht der Entscheidung dienen, für
welches Modell im Rahmen der Bachelorarbeit verwendet wird.

%==========================================================================
%}
clc; clear; close all;

addpath('..\Funktionen\');
%Datensatz laden
matDir = '..\Daten\Gruppen\';

% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';
%Parameter laden
run( 'ParamterKamijiSVC.m' );

% Schrittweite festlegen
f = 100;   %[Hz]
dt = 1/f;  %[s] 0.01s -> alle 10ms ein Sample

% Abtastrate festlegen
fs = 0.2;

%Datensatz lesen
Subject = getSubjectData(matDir, xlsxDir);


%% Vergleichsplot erstellen
for i=1:length(Subject)
    if Subject(i).Id == -1
        Result(i,3) = {'_Defect_'};
        Result(i,2) = {'_Defect_'};
        Result(i,1) = {'_Defect_'};
        Result(i,4) = {'_Defect_'};
        continue;
    end
    Result(i,3) = {Subject(i).AbortTime};
    Result(i,2) = {max(Subject(i).kinetosis_level)};
    Result(i,1) = {Subject(i).Id};
    if Subject(i).isSpurWechsel
        Result(i,4) = {'SpurWechsel'};
    else
        Result(i,4) = {'StopAndGo'}; 
    end    
end

%%Ergebnisse in einem Array kombinieren
ResultTable = cell2table(Result,'VariableNames',...
    {'Id','max Self-Rating in MISC [-]', 'Abbruchszeitpunkt [s]', 'Art des Tests'});
writetable(ResultTable, '..\Exporte\Overview_AbortTime.xlsx' );
disp('Ergebnisse gespeichert.');





