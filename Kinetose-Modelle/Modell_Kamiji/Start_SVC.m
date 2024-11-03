clc; clear; close all;

addpath('..\..\Funktionen\');
%Parameter laden
run( 'ParamterKamijiSVC.m' );


matDir = '..\..\Daten\TestMessungen\';
xlsxDir = '..\..\Daten\Teilnehmer_Xlsx\';

Subject = getSubjectData(matDir, xlsxDir);

% Laden der Beschleunigungen
AXB = Subject(1).a_x;
AYB = Subject(1).a_y;
AZB = Subject(1).a_z;

angRateX = Subject(1).angRateX;
angRateY = Subject(1).angRateY;
angRateZ = Subject(1).angRateZ;

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

% erzeugen Winkelgeschwindigkeit [rad/s]
w = [];    
w(:,1) = angRateX;
w(:,2) = angRateY;
w(:,3) = angRateZ;

%% Simulation des Modells von Barccesi

% Zeit-Beschleunigungs-vektor kombinieren
t_a_arr = [t, a];
t_w_arr = [t, w];
    
%Änderungrate der Beschleunigung 0.2Hz
k_freq = GetKFactor( 0.2 );
    
% Starten der Simulation
disp('Simulation läuft...');
ergSVC = sim('SVC_Modell.slx');
disp('Simulation ist beendet.');
    
% Zwischenspeichern der Ergebnisse
MSI_all = ergSVC.sim_MSI;
tout = ergSVC.tout;%[s]
t_out = tout;
MSI_Max = max(MSI_all);
    

disp('Maximalwert MSI [%]:');
disp(MSI_Max);


% figure(2)
% hold on;
% subplot(2,3,1);
% plot(t,Subject(1).a_nedx);
% grid on;
% title('ned X');
% ylabel('m/s²')
% 
% subplot(2,3,2);
% plot(t,Subject(1).a_nedy, 'r');
% grid on;
% title('ned Y');
% ylabel('m/s²')
% 
% subplot(2,3,3);
% plot(t,Subject(1).a_nedz, 'k');
% grid on;
% title('ned Z');
% ylabel('m/s²')
% 
% subplot(2,3,[4,5,6] );
% plot(t,Subject(1).a_nedx,'b',t,Subject(1).a_nedy,'r',t,Subject(1).a_nedz, 'k');
% grid on;
% legend('ned X','ned Y','ned Z');
% if Subject(1).isSpurWechsel
%     title('Acc bei Spurwechsel');
% else
%     title('Acc bei StopAndGo');
% end    
% ylabel('m/s²')
% hold off;

%Vergleich Geschwindigkeit mit MSI-Verlauf
figure(1)
hold on;
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
hold off;

Quotient = 0;
for i=1:length(Subject)
    if ~isempty(Subject(i).Max_Selfrate)
        ID(i,1) = i;
        Max_MSI(i,1) = Subject(i).Max_Selfrate;
        AbortTime(i,1) = Subject(i).AbortTime;
        Quotient = Quotient +1;
    end
end
%AbortTime is 1x1??
smaller500 = AbortTime(AbortTime <= 500);
between500n1000 = AbortTime(AbortTime > 500 && AbortTime <= 1000); 
between1000n1500 = AbortTime(AbortTime > 1000 && AbortTime <= 1500);
bigger1500 = AbortTime(AbortTime > 1500);
%pie


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