%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Dieses Skript dient dazu eine tabellarische Übersicht über die Probanden,
ihrer maxiamlen Self-Ratings zu bekommen (alle Datensätze). 
Außerdem werden zusätzlich diemaximalen vorausgesagten MSI-Werte von dem 
Modell Kamiji und Braccesi bestimmt. 
Zuguterletzt soll die tabellarische Übersicht der Entscheidung dienen, für
welches Modell im Rahmen der Bachelorarbeit verwendet wird.

%==========================================================================
%}
clc; clear; close all;

% Modelpath
addpath('..\Kinetose-Modelle\Modell_Barccesi\' );
addpath('..\Kinetose-Modelle\Modell_Kamiji\' );
addpath('..\Funktionen\');
%Datensatz laden
matDir = '..\Daten\Gruppen\';
% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';

%Parameter laden
run( 'ParamterKamijiSVC.m' );
run( 'ParameterBarccesiUNIPG.m' );

% Schrittweite festlegen
f = 100;   %[Hz]
dt = 1/f;  %[s] 0.01s -> alle 10ms ein Sample

% Änderungsrate der Beschleunigung festlegen
f_a = 0.2;

%Datensatz lesen
Subject = getSubjectData(matDir, xlsxDir);
ids = [];
kamijiMaxValues = [];
braccesiMaxValues = [];
msiMaxValues = [];


ResultCells = {'Id','Kamiji max MSI [%]','Braccesi max MSI [%]','max Self-Rating in MSI [%]',...
                'Max Self-Rating in MISC [-]', 'MSDV [m/s^{1,5}]', 'Aborttime [s]'};
%% Daten für Simulation Kamiji aufbereiten
disp('Simulationen von Kamiji läufen...');
for i = 1:length(Subject)
    if Subject(i).Id == -1
        continue;
    end
    
    AXB_K = Subject(i).a_x;
    AYB_K = Subject(i).a_y;
    AZB_K = Subject(i).a_z;

    angRateX_K = Subject(i).angRateX;
    angRateY_K = Subject(i).angRateY;
    angRateZ_K = Subject(i).angRateZ;

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
    ergSVC = sim('SVC_Modell.slx');

    ResultCells(i,2) = {max(ergSVC.sim_MSI)};
    kamijiMaxValues = add(kamijiMaxValues,max(ergSVC.sim_MSI));
end
disp('Simulationen von Kamiji sind beendet.');

%% Daten für Simulation Barccesi aufbereiten
disp('Simulationen von Barccesi läufen...');
for i = 1:length(Subject)
    if Subject(i).Id == -1
        continue;
    end
    % Anderes KOS als KAmiji
    AZB_B = Subject(i).a_x;
    AXB_B = Subject(i).a_y;
    AYB_B = Subject(i).a_z;

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
    ergUNIPG = sim('UNIPG_Modell.slx');

    % Zwischenspeichern der Ergebnisse
    ResultCells(i,3) = {max(ergUNIPG.sim_MSI)};
    braccesiMaxValues = add(braccesiMaxValues,max(ergUNIPG.sim_MSI));
end
disp('Simulationen von Barccesi sind beendet.');

%% Finalen Self-Rate Wert sammeln
for i=1:length(Subject)
    if Subject(i).Id == -1
        continue;
    end
    ResultCells(i,4) = {max(Subject(i).kinetosis_level)};
    ResultCells(i,5) = {10*max(Subject(i).kinetosis_level)};
    msiMaxValues = add(msiMaxValues,10*max(Subject(i).kinetosis_level));
end

%% ISO 2631-1 berechnen
for i=1:length(Subject)
    if Subject(i).Id == -1
        continue;
    end
    MSDVn = ISO2631_MSDV(Subject(i).MTi_a_z, f_a);
    ResultCells(i,6) = {MSDVn(end)};
    ResultCells(i,7) = {Subject(i).AbortTime};
end    

%% Ergebnisse in einem Array kombinieren
for i=1:length(Subject)
    if Subject(i).DataOk
        ResultCells(i,1) = {Subject(i).Id};
        ids = add(ids,Subject(i).Id);
    else
        ResultCells(i,1) = {'Defekt'};
    end
end

ResultTable = cell2table(ResultCells);

writetable(ResultTable, '..\Exporte\Overview.xlsx' );
disp('Ergebnisse gespeichert.');

%% Berechnen der Standartabweichung von Kamiji und Braccesi vom Self-Rating
%Abweichung = {'Kamiji zu Self-Rating [%]', 'Braccesi zu Self-Rating [%]'};
Abweichung = [];
AllAbweichung = [];
for i=1:length(kamijiMaxValues)
  Abweichung(i,1) = 100-(kamijiMaxValues(i)/msiMaxValues(i)*100);
end
for i=1:length(braccesiMaxValues)
  Abweichung(i,2) = 100-(braccesiMaxValues(i)/msiMaxValues(i)*100);
end

figure();
ax = gca;
bar(ax,ids,Abweichung);
grid on;
grid minor;
set(ax,'FontSize',30);
title('Abweichung der Modelle vom Self-Rating','FontSize',32);
ylabel('Abweichung [%]');
xlabel('Probanden*innen ID');
legend('Kamiji','Braccesi','Location','eastoutside');

figure();
ax = gca;
boxplot(ax, Abweichung, {'Kamiji','Braccesi'});
grid on;
grid minor;
set(ax,'FontSize',18);
title('Abweichung der Modelle vom Self-Rating','FontSize',20);
ylabel('Abweichung [%]');


function arr = add(arr, input)
    len = length(arr);
    newLen = len+1;
    arr(newLen,1) = input;
end





