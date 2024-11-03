%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Das Skript soll eine Übersicht die prozentuale Verteilung von "StopAndGo" 
und "SpurWechsel" innerhalb der ganzen Tests erzeugen. Dabei wird ein
Trotendiagramm erzeugt.
1. Verteilung Stop and Go und Spur Wechsel in allen Messunge
%==========================================================================
%}
clc; clear; close all;

addpath('..\Funktionen\');
%Datensatz laden
matDir = '..\Daten\Gruppen\Versuchsgruppe\';
% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';
% Modelpath
addpath('..\Kinetose-Modelle\Modell_Kamiji_tau_Individual\');

%% Simulation ausführen
run( 'ParamterKamijiSVC.m' );

% Schrittweite festlegen
f = 100;   %[Hz]
dt = 1/f;  %[s] 0.01s -> alle 10ms ein Sample

% Abtastrate festlegen
fs = 0.2;

%Datensatz lesen
Subject = getSubjectData(matDir, xlsxDir);

% Zahlen für Kuchendiagramm
countFull = length(Subject);
countStopGo = 0;
countSpurWechsl = 0;
countDefect = 0;
%StopAndGo

for n=1:length(Subject)
    if Subject(1,n).Id > -1
        if Subject(1,n).isSpurWechsel 
            SpurWechsel = 'Spurwechsel';
            countSpurWechsl = countSpurWechsl +1;  
        else
            SpurWechsel = 'StopAndGo';
            countStopGo = countStopGo +1;
        end    
        Result(n,1) = {Subject(1,n).Max_Selfrate};
        Result(n,2) = {Subject(1,n).AbortTime};
        Result(n,3) = {SpurWechsel};
    else
        countDefect = countDefect +1;
        Result(n,1) = {'_Defect_'};
        Result(n,2) = {'_Defect_'};
        Result(n,3) = {'_Defect_'};  
    end    
end
countWithoutDefect = countFull-countDefect;

%% Speichern als Excel - uncomment
% ResultTable = array2table(Result,'VariableNames',...
%     {'Max_MSI [-]','Abborttime [s]','Direction'});
% writetable(ResultTable, 'D:\Studium\01_Bachelor_Studium\_Bachelorarbeit\Modell\Kinetose-Modelle\Overview_Fahrmanöver.xlsx' );
% disp('Ergebnisse gespeichert.');

%% Darstellen Verteilung StopAndGo und SpurWechsel
figure(1);
tiledlayout(1,1,'TileSpacing','compact');
X = [(countStopGo/countWithoutDefect), (countSpurWechsl/countWithoutDefect)];
ax1 = nexttile;
mymap = [0, 0.4470, 0.7410;
         0.8500, 0.3250, 0.0980];
mycolormap = colormap(mymap);
p = pie(X);
str = ['Anteile der Fahrmanöver der Versuchsgruppe (100% = ', num2str(countWithoutDefect), ')'];
title(str, 'FontSize', 18);
pText = findobj(p,'Type','text');
percentValues = get(pText,'String'); 
txt = {'StopAndGo: ';'Spurwechsel: '}; 
combinedtxt = strcat(txt,percentValues);
pText(1).String = combinedtxt(1);
pText(1).FontSize = 16;
pText(2).String = combinedtxt(2);
pText(2).FontSize = 16;

