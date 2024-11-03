%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Lädt die Parameter für die Simulation des Kinetosemodells und bekommt die
Testdaten der Probanden. Anschließend wird ein K-Frequenz-Faktor ermittelt.
Dieser Wert passt die Sensibilität der Probanden in Abhängigkeit der
Änderungsrate der Beschleunigung an. Nachdem die Simulation durchgeführt
wurde, wird die Struktur simOut durch die Felder MSI_all und MSI_t
erweitert. Hiermit kann nun eine grafische Gegenüberstellung erzeugt
werden.

Parameter:
    matPath         :  beinhaltet den Pfad mit den mat-Dateien
    xlxsPath        :  beinhaltet den Pfad mit der xlxs-Datei
    ModelPath       :
    ModelParPath    :
    f_a             :  1 x 1 Skalar, Änderungsrate der Beschleunigung [Hz]
    Fs              :  1 x 1 Skalar, Schrittweite der Messung [Hz]

Output: 
(wird erweitert)
        simOut                 : 1 x n Struktur, beinhaltet alle Testdaten (siehe getSubjectData.m)
            Fields erweitert:
            MSI_B_all          : 1 x j Vektor, Alle MSI-Werte aus Braccesi Simulation [%] 
            MSI_B_t            : 1 x j Vektor, Zeitwerte aus Braccesi Simulation [s]

        ids                    : 1 x k Vektor, Alle gefundene IDs, auch die defekten (id = -1)
%==========================================================================
%}

function [simOut,ids] = SimUNIPG( simOut, matPath, xlxsPath, ModelPath, ModelParPath, f_a, Fs )
%     %Parameter laden
    run( ModelParPath );
    simFiles = dir([ModelPath '\*.*slx']);
    simName = strcat(simFiles(1).folder, '\', simFiles(1).name);
    %Sammle alle Daten der Probanden
    [Subject, AllIds] = getSubjectData( matPath, xlxsPath );
    
    %% Berechnen den K_frequenzfaktors
    k_freq = getKFreq(f_a);

%% Start    
    wb = waitbar(0, 'Start create Data');
    for i=1:length(Subject)
        waitbar( i/length(Subject), wb, 'Creating Data...' );
        %Wenn die Daten nicht Ok sind dann überspringe diesen Datensatz
        if not(Subject(i).DataOk)
            continue;
        end 
        
        % Laden der Beschleunigungen (Braccesi hat eine anderes KOS)
        AZB = Subject(i).a_x;
        AXB = Subject(i).a_y;
        AYB = Subject(i).a_z;
    
        % Erzeugen eines Zeitvektors mit entsprechender der Zeitschrittweite
        dt = 1/Fs;  %[s] 0.01s -> alle 10ms ein Sample
        t_max = (length(AXB)/Fs); 
        t = (0:dt:t_max-dt)';
    
        %StopTime der Simulation
        t_Stop = t_max;
    
        %% Arrays transponieren
        % erzeugen Beschleunigungsvektor [m/s²]
        a = [];
        a(:,1) = AXB';
        a(:,2) = AYB';
        a(:,3) = AZB';%beinhaltet bereit die Erdbeschleunigung
    
        %% Simulation des Modells von Kamiji
    
        ids = AllIds;
        
        %Simulation Kamiji
        % Zeit-Beschleunigungs-vektor kombinieren
        t_a_arr = [t, a];            
        % Starten der Simulation
%         disp(['Simulation von ID: ', num2str(Subject(i).Id), ' läuft...']);        
        erg = sim(simName,'SrcWorkspace','current');
%         disp(['Simulation von ID: ', num2str(Subject(i).Id), ' ist beendet!']);        
        % Zwischenspeichern der Ergebnisse
        MSI_all = erg.sim_MSI; 
        tout = erg.tout;%[s]
        t_out = tout;
        %MSI_Max = max(MSI_all);
        %disp(['Simulated MSI-Value: ' MSI_Max]);        
        Subject(i).MSI_all = MSI_all;
        Subject(i).MSI_t = t_out;
    
%         [MSDV_all,~] = ISO2631_MSDV(a(:,3), f_a);
%         Subject(i).MSDV_all = MSDV_all;
%         Subject(i).MSDV_t = t;
        
        if i == length(Subject)
            close(wb);
        end
    simOut = Subject;  

end
