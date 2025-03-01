%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Hinweis: Original Kamiji-Simulation

Lädt die Parameter für die Simulation des Kinetosemodells und bekommt die
Testdaten der Probanden. Nachdem die Simulation durchgeführt
wurde, wird die Struktur simOut durch die Felder MSI_all und MSI_t
erweitert. Hiermit kann nun eine grafische Gegenüberstellung erzeugt
werden.

Parameter:
    matPath     :  beinhaltet den Pfad mit den mat-Dateien
    xlxsPath    :  beinhaltet den Pfad mit der xlxs-Datei
    ModelPath   :  beinhaltet den Pfad zum Modell 
    ModelParPath:  beinhaltet den Pfad zur Parameter Datei des Modells 
    Fs          :  1 x 1 Skalar, Schrittweite der Messung, Abtastrate [Hz]

Output: simOut  : 1 x n Struktur, beinhaltet alle Testdaten (siehe getSubjectData.m)
            Fields erweitert:
            MSI_K_all           : 1 x m  
            MSI_K_t             : 1 x m
        ids     : 1 x k Vektor, Alle gefundene IDs, auch die defekten (id = -1)
%==========================================================================
%}

function [simOut,ids] = SimOrgSVC( matPath, xlxsPath, ModelDir, ModelParPath, Fs )
%     %Parameter laden
    addpath(ModelDir);
    run( ModelParPath );
    simFiles = dir([ModelDir '\*.*slx']);
    if isempty(simFiles)
        errID = ''; 
        msg = 'In <ModelPath> there is no Model or Folder does not exist.';
        baseException = MException(errID,msg);
        throw(baseException);
    end
    simName = strcat(simFiles(1).folder, '\', simFiles(1).name);
    %Sammle alle Daten der Probanden
    [Subject, AllIds] = getSubjectData( matPath, xlxsPath );  
    
%% Start    
    wb = waitbar(0, 'Start create Data');
    for i=1:length(Subject)
        waitbar( i/length(Subject), wb, 'Creating Data...' );
        %Wenn die Daten nicht Ok sind dann überspringe diesen Datensatz
        if not(Subject(i).DataOk)
            continue;
        end    
        % Laden der Beschleunigungen
        AXB = Subject(i).a_x;
        AYB = Subject(i).a_y;
        AZB = Subject(i).a_z;
    
        % Laden der Winkelgeschwindigkeit
        angRateX = Subject(i).angRateX;
        angRateY = Subject(i).angRateY;
        angRateZ = Subject(i).angRateZ;
    
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
    
        % erzeugen Winkelgeschwindigkeit [rad/s]
        w = [];    
        w(:,1) = angRateX;
        w(:,2) = angRateY;
        w(:,3) = angRateZ;
    
        %% Simulation des Modells von Kamiji
    
        ids = AllIds;
        
        %Simulation Kamiji
        % Zeit-Beschleunigungs-vektor kombinieren
        t_a_arr = [t, a];     
        % Zeit-Winkelgeschwindigkeits-Vektor kombinieren
        t_w_arr = [t, w];        
        % Starten der Simulation      
        erg = sim(simName,'SrcWorkspace','current');     
        % Zwischenspeichern der Ergebnisse
        MSI_all = erg.sim_MSI; 
        tout = erg.tout;%[s]
        t_out = tout;
    
        Subject(i).MSI_K_all = MSI_all;
        Subject(i).MSI_K_t = t_out;
               
        if i == length(Subject)
            close(wb);
        end
    simOut = Subject;  

end
