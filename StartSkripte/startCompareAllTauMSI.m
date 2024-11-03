%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Erzeugt einen Excel Tabelle mit einer Übersicht. In dieser Übersicht Sind
die berechneten Simulationen von Datensätzen eines Zeitbereichen aus einem
Fahrmanöver mit verschiedenen tauMSI dargestellt.

%==========================================================================
%}
clc; clear; close all;

addpath('..\Funktionen\');
% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';
% ModelPath
addpath('..\Kinetose-Modelle\Modell_Kamiji_tau_Individual\');

%% Simulation ausführen
run( 'ParamterKamijiSVC.m' );

% mainPath = '..\Daten\Gruppen\Versuchsgruppe\SpurWechsel_Messungen\';
mainPath = '..\Daten\Gruppen\Versuchsgruppe\StopAndGo_Messungen\';
% SubFolder = 'kleiner_1000';
% SubFolder = '1000_bis_1500';
% SubFolder = 'größer_1500';
% SubFolder = 'kleiner_500';
% SubFolder = '500_bis_1000';
SubFolder = 'größer_1000';
mainPath = strcat(mainPath,SubFolder,'\');
%Testen verschiedener tau_MSI - Werte 
tau_MSIs = [60 90 120 150 180];
% tau_MSIs = [300 330 360 390 420];
xlsxName = strcat( 'OverView_tau_',num2str(tau_MSIs(1)),'_bis_',num2str(tau_MSIs(end)),'_',SubFolder,'.xlsx' );

%%  Speicherpfad der Excel-Datei
savePath = strcat( '..\Exporte\', xlsxName );

%% Datensatz lesen
Subject = getSubjectData(mainPath, xlsxDir);

disp(['Simulationen von Kamiji "' mainPath '" laufen...']);

% Schrittweite festlegen
f = 100;   %[Hz]
dt = 1/f;  %[s] 0.01s -> alle 10ms ein Sample

%% Simulation
lastRow = 0;
for m=1:length(Subject)

    if ~Subject(m).DataOk
        Result(lastRow+1,1) = { Subject(m).Id };
        Result(lastRow+2,1) = { 'Dataset defect' };
        continue; 
    end
    disp(['---- Subject ID: ' num2str(Subject(m).Id)]);
    for i=1:length(tau_MSIs)
        Result(lastRow+1,1) = { Subject(m).Id };
        Result(lastRow+2,1) = { Subject(m).isSpurWechsel };
        T = [];
        tau_MSI = tau_MSIs(i);

%% Simulation       
        disp(['Simulationen mit tau_MSI = ' num2str(tau_MSI) ' ...']);
	% Daten für Kamiji aufbereiten
        AXB_K = Subject(m).a_x;
        AYB_K = Subject(m).a_y;
        AZB_K = Subject(m).a_z;
	
        angRateX_K = Subject(m).angRateX;
        angRateY_K = Subject(m).angRateY;
        angRateZ_K = Subject(m).angRateZ;
	
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
        ergSVC = sim('SVC_Modell_k_individual.slx');
%% Auswertung    
        MSI(1,i).data = ergSVC.sim_MSI;%[-]
        MSI(1,i).time = ergSVC.tout;%[s]
 
        SelfRateTime = Subject(m).kinetosis_level_timestemp;
        SelfRateData = Subject(m).kinetosis_level;              
        %round da es beim interpolieren zu Fehlern kommt wenn zu viele
        %Kommastellen vorhanden sind
        ReferenceTime = MSI(1,i).time;
        Reference = interp1(SelfRateTime,SelfRateData,ReferenceTime);         
        %MISC an MSI anpassen
        Reference = Reference*10;                       
    %% Zusammentragen der Ergebnisse in Cells-Array
        [X,A,B,C] = CustomISO18751(Reference,ReferenceTime,MSI(1,i).data,MSI(1,i).time);
        Result(lastRow+1,i+1) = {A};
        Result(lastRow+2,i+1) = {B};
        Result(lastRow+3,i+1) = {C};
        Result(lastRow+4,i+1) = {X};
        %Save FinalScores: tauMSI6; tauMSI5; tauMSI4; tauMSI3; tauMSI2;
        %tauMSI1
        Resultnum(m,length(tau_MSIs)+1-i) = X;
    end
    lastRow = lastRow+4;
end

% Wenn die Ergebnisse als Excel gespeichert werden soll - uncomment
ResultTable = array2table(Result);
writetable( ResultTable, savePath );
disp( savePath );
disp( 'gespeichert!' );





