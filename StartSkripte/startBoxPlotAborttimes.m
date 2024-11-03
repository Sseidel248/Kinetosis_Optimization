%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Erzeugt einen Boxplot für die Verteilung Abbruchszeiten über die 
Fahrmanöver.

%==========================================================================
%}
clc; clear; close all;

addpath('..\Funktionen\');
addpath('..\Kinetose-Modelle\Modell_Kamiji_tau_Individual\');

%% Simulation ausführen
run( 'ParamterKamijiSVC.m' );

%Datensatz laden
matDir = '..\Daten\Gruppen\Versuchsgruppe\';

% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';

%Datensatz lesen
Subject = getSubjectData(matDir, xlsxDir);

AllAbortTimes = [];
DriveType = [];

for i=1:length(Subject)
    if ~Subject(i).DataOk
        continue;
    end
    AllAbortTimes = add( AllAbortTimes, Subject(i).AbortTime );
    DriveType = add( DriveType, Subject(i).isSpurWechsel );
end

DriveType = categorical(DriveType,[1 0],{'Spurwechsel','StopAndGo'});

f = figure(1);
ax = gca;
boxchart(ax,AllAbortTimes,'GroupByColor',DriveType);
set(ax,'FontSize',16)
ylabel( 'Abbruchzeiten [s]');
xticklabels({''});
xlabel( 'Fahrmanöver');
title( 'Verteilung Abbruchszeiten über Fahrmanöver', 'FontSize', 18 );
grid on;
legend('Location', 'northeastoutside');

function arr = add(arr, input)
    len = length(arr);
    newLen = len+1;
    arr(newLen,1) = input;
end