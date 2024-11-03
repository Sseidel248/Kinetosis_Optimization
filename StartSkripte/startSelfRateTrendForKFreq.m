%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Das Skript sammelt zuerst alle Daten der Probanden und erzeugt einen
gemittelten Self-Rating von alles Self-Ratings. 
Anhand dieses gemittelten Self-Rating wird der frequenzabhängige Faktor 
ausgelegt. Anschließend werden die optimierten Graphen mit der Funktion
CustomISO18751(...) bewertet.

Diagrammerstellung:
    Gemittelter Trend der Self-Ratings aller Probanden*innen
    Vergleich verschiedener konst. Frequenzfaktor Verläufe
    Mittelwerte der Gesamtbewertungen

%==========================================================================
%}
clc; clear; close all;

addpath('..\Funktionen\');
%Datensatz laden
matDir = '..\Daten\Gruppen\Versuchsgruppe\';
% Pfade in denen sich Dateien befinden
xlsxDir = '..\Daten\Teilnehmer_Xlsx\';
% Modelpath
addpath('..\Kinetose-Modelle\Modell_Kamiji_K_Freq\');
run( 'ParamterKamijiSVC.m' );


%Änderungsrate Beschleunigung [Hz]
fs = 0.2;
%Abtastrate Signale [Hz]
f = 100;
dt = 1/f;

Subject = getSubjectData(matDir,xlsxDir);
%% Sammeln alles Trendkoeffizienten um daraus einen Mittelwert zu bilden
disp('Berechnen der Daten für den Trendverlauf...');
allCoefs = [];
allTimes = [];%beinhaltet auch von defekten Datensätzen
for i=1:length(Subject)
    if ~Subject(i).DataOk
        allTimes(i) = -1;
        continue;
    end    
    data = Subject(i).kinetosis_level;
    test__(i)= max(Subject(i).kinetosis_level);
    t = Subject(i).kinetosis_level_timestemp;
    [~, coef] = lineartrend(data,t);
    allTimes(i) = max(t);
    allCoefs(i,:) = coef;
end

allOkTimes = [];
for i=1:length(allTimes)
    if ~(allTimes(i) == -1)
        len = length(allOkTimes);
        len = len+1;
        allOkTimes(len) = allTimes(i);
    end    
end
% Durchschnittsabbruchszeit
meanMaxTime = mean(allOkTimes);
% erstellen eines neuen Zeitvektors
tNew = linspace(0,meanMaxTime);
% Von alle mit polyfit ermittelten Koeffizienten den jeweiligen Mittelwert 
% bilden
medianCoefs = median(allCoefs);
% Grapherstellung zu den gemittelten Koeffizienten
medianTrend = polyval(medianCoefs,tNew);

figure(2);
plot(tNew,medianTrend);
ax = gca;
set(ax,'FontSize',16);
grid on;
grid minor;
title('Mittlerer Trend der Self-Ratings der Versuchsgruppe','FontSize',18);
ylim([0 10]);
xlabel('Zeit [s]');
ylabel('Self-Raing');
strX = strcat('~',num2str(round(max(tNew))),' s');
xl = xline(max(tNew),'--',{strX},'FontSize',16);
xl.LabelVerticalAlignment = 'middle';
strY = num2str(round(max(medianTrend),1));
yl = yline(max(medianTrend),'--',{strY},'Color',[0.8500 0.3250 0.0980],'FontSize',16);
yl.LabelHorizontalAlignment = 'center';
legend('Gemittelter Verlauf','Maximale ∅ Abbruchszeit','Maximaler ∅ Self-Rate',...
       'Location','northeastoutside');
   
  
%% Berechnen den K_frequenzfaktors
% Frequenzen aus Fig.1 Bos und Bles 1998 
f_org = [0, 0.05, 0.09, 0.135, 0.167, 0.250, 0.333, 0.417, 0.5, 0.6, 0.7]';
% Frequenzen feiner aufsplitten
f_fine = (0:0.001:0.7)';

% k_Faktor Variation von max 1.25 bis 2
k_faktor_max2    = [0, 0.02, 0.2, 1.65, 2, 1.35, 0.8, 0.4, 0.15, 0.02, 0.0]';
k_faktor_max1_5  = k_faktor_max2 * 0.75;


% Nachgebildete Faktoren interpolieren, pchip: weißt keine
% Schwingungen auf nach der Interpolarisation
xInterP_2    = interp1( f_org, k_faktor_max2, f_fine, 'pchip' );
xInterP_1_5  = interp1( f_org, k_faktor_max1_5, f_fine, 'pchip' ); 

% Gemeinsames Array erzeugen
arr_2    = [f_fine, xInterP_2];
arr_1_5  = [f_fine, xInterP_1_5];


% Vergleich der Konstanten Frequenzfaktoren
% figure(1);
% hax = axes;
% plot(f_fine,xInterP_2,f_fine,xInterP_1_5);
% hold on;
% grid on;
% grid minor;
% ylim([0 2.25]);
% xlabel('Änderungsrate [Hz]');
% ylabel('konstanter Frequenzfaktor [-]');
% title('Vergleich verschiedener konst. Frequenzfaktor Verläufe','FontSize',18);
% line([0.2 0.2],get(hax,'YLim'),'Color',[1 0 0])
% set(hax,'FontSize',16);
% legend('Variante 1 (k_{freqMax}=2)','Variante 2 (k_{freqMax}=1.5)',...
%        'Datensätze mit 0.2Hz', 'Location', 'northeastoutside');
% hold off;

%CustomISO18751 für die ausgewählten Subject durchführen durchführen
ResultISO18751 = {'ID','A','B','C','X','kfreq'};
ids = [];
Results = [];
for i=1:length(Subject)
    if ~Subject(i).DataOk
        continue;
    end 
    id = Subject(i).Id;
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
  
    % erzeugen eines kFreq-Faktor Vektors
    for n=1:3
        kf = zeros(size(a));
        %verschieden k_Freq Faktoren nehmen
        switch n
            case 1
                kf(kf==0) = arr_2( arr_2(:,1) == fs, 2 );
            case 2
                kf(kf==0) = arr_1_5( arr_1_5(:,1) == fs, 2 );
            case 3
                kf(kf==0) = 1;               
        end
        tmp_kf = kf(1,1);
        kfreq = [t_K, kf];    
        % Starten der Simulation    
        ergSVC = sim('SVC_Modell_k_freq.slx');
        TestSignal = ergSVC.sim_MSI;
        TestTime = ergSVC.tout;
        % MISC and MSI anpassen -interpolieren-
        RefSignalOrg = medianTrend;
        % Fehler beim benutzen von interp1 Subject(i-2).kinetosis_level_timestemp 
        % und TestTime, da die Sample Punkte doppelt vorkommen.
        RefTime = ergSVC.tout;
        RefSignal = interp1(tNew,RefSignalOrg,TestTime);
        RefSignal = RefSignal*10;
        [X,A,B,C]=CustomISO18751(RefSignal,RefTime,TestSignal,TestTime);
        row=(i-1)*5+n+1;
        ResultISO18751(row,:)={id,A,B,C,X,tmp_kf};
        
        %Testplot
%         figure(i+10);
%         hold on;
%         plot(RefTime,RefSignal,TestTime,TestSignal);
        Results = appendRow(Results,X,n,n == 1);   
    end
    disp(strcat('Fahrprofil ID:', num2str(id), ' fertig!'));
end
ResultTable = cell2table(ResultISO18751);
writetable(ResultTable, '..\Exporte\Overview_k_freq_v3.xlsx' );
disp('Ergebnisse gespeichert.');

medianResult = (median(Results))';
varianten = [1 2 0]; 

figure();
ax = gca;
bar(ax,varianten,medianResult);
grid on;
grid minor;
set(ax,'FontSize',16);
title('Median der Gesamtbewertungen','FontSize',18);
ylabel('Punktzahl');
xlabel('Varianten der Faktoren');
center = max(medianResult);
ylim([center-0.005 center+0.005]);

function [out, coef] = lineartrend(data,time)
    coef = polyfit(time,data,1);
    out = polyval(coef,time);
end

function out = add(out,value)
    n = length(out);
    n = n+1;
    out(n,1) = value;
end

function out = appendRow(out,value,col,isNewRow)
    [n,~] = size(out);
    if isNewRow || n == 0
        n = n+1;
    end        
    out(n,col) = value;    
end    