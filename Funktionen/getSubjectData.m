%{
Author: Sebastian Seidel
Mat.-Nr.: 394185 

Die Funktion dient dazu mit den mat-Dateien und der xlsx-Datei ein
Testdaten Struktur zu füllen. Hierbei müssen die mat-Dateien nach einer 
bestimmte Namens Konvention benannt werden, damit sie den Probanden IDs aus 
der xlsx-Datei zugeordnet werden können (siehe Hinweis).

Parameter:  
    matDir      : beinhaltet das verzeichnis mit den mat-Dateien
    xlxsDir     : beinhaltet das verzeichnis mit der xlxs-Datei

Hinweis: 
    -   matDir und xlxsDir ohne '\' am Ende
    -   Messungenen müssen nach folgenden Chema abgelegt werden: 
        3stellige ProbandenID_Datum(JJJJMMTT)_Uhrzeit(HH_MM_SS)
        z.B. 001_20210621_12_22_00.mat
    -   Feste Abtastrate von 100Hz (fs)

Output: TestDaten              : 1 x n Struktur, beinhaltet alle Testdaten
            Fields:
            Id                 : 1 x 1 Skalar, Id des Probanden
            DataOk             : 1 x 1 Boolean, Flag ob der Datensatz ok ist
            kinetosis_level    : 1 x m Vektor, beinhaltet zu einem Probanden
                                  die abgefragten Kinetoselevel [-]
            kinetosis_level_timestemp : 1 x m Vektor, beinhaltet zu einem
            Probanden den jeweiligen Zeitpunkt an dem er abgefragt wurde [s]
            a_x                : 1 x i Vektor, Beschleunigungen in X vom Kopf [Head_AccX](VN-100 IMU)[m/s²]
            a_y                : 1 x i Vektor, Beschleunigungen in Y vom Kopf [Head_AccY](VN-100 IMU)[m/s²]
            a_z                : 1 x i Vektor, Beschleunigungen in Z vom Kopf [Head_AccZ](VN-100 IMU)[m/s²]
            MTi_a_z            : 1 x   Vektor, Beschleunigungen in Z vom Sitz [m/s²] (ISO-2631-1)
            a_res              : 1 x i Vektor, Resultierende Beschleunigungen [m/s²]
            angRateX           : 1 x i Vektor, Winkelgeschw. um die X-Achse vom Kopf [Head_AngRateX](VM-100 IMU)[rad/s]
            angRateY           : 1 x i Vektor, Winkelgeschw. um die Y-Achse vom Kopf [Head_AngRateY](VM-100 IMU)[rad/s]  
            angRateZ           : 1 x i Vektor, Winkelgeschw. um die Z-Achse vom Kopf [Head_AngRateZ](VM-100 IMU)[rad/s]
            isSpurWechsel      : 1 x 1 Boolean, true = Fahrmanöver SpurWechsel; false = Stop and Go
            AbortTime          : 1 x 1 Skalar, beinhaltet die Abbruchszeit
            Max_Selfrate       : 1 x 1 Skalar, höchsten Self-Rate Wert
            a_x_kfz
            t_kfz
        SubjectsIds            : 1 x f Vektor, beinhaltet alle Ids der Probanden [-]
        count                  : 1 x 1 Skalar, Maximale Anzahl an Probanden [-]

%==========================================================================
%}
function [TestData, SubjectIds, count] = getSubjectData( matDir, xlsxDir ) 
    %Probandenprotokoll und Messdateien finden und einlesen
    %*.mat Dateien
    if ~endsWith(matDir,'\')
        path_files = strcat( matDir, '\' );
    else
        path_files = matDir;
    end    
    %path_mat = strcat( matDir, '\*.*mat' );
    Files = dir(fullfile(path_files, '**', '*.*mat'));
    if isempty(Files)
        errID = ''; 
        msg = 'In <matDir> there are no records or Folder does not exist.';
        baseException = MException(errID,msg);
        throw(baseException);
    end
    %Files = dir( path_mat );
    
    %*.xlsx Dateien
    path_excel = strcat( xlsxDir, '\*.*xlsx' );
    Excel_tab=dir( path_excel );
    if isempty(Excel_tab)
        errID = ''; 
        msg = 'In <xlsxDir> there are no *.xlsx File or Folder does not exist.';
        baseException = MException(errID,msg);
        throw(baseException);
    end
    
    if ~endsWith(xlsxDir,'\')
       xlsxDir = strcat(xlsxDir,'\');
    end   
    [num,txt,Probandenliste] = xlsread([xlsxDir Excel_tab(1).name]);   
    
    %Spaltennummer in Exceltabelle suchen
    Date_col = find(strcmp(Probandenliste(1,:), 'Termin'));
    ID_col = find(strcmp(Probandenliste(1,:), 'ID'));
    Manoever_col = find(strcmp(Probandenliste(1,:), 'Beschleunigungsart'));
    Richtung_col = find(strcmp(Probandenliste(1,:), 'Sitzrichtung'));
    
    %gibt die maximale anzahl an Dateien zurück
    count = length(Files);
    wb = waitbar( 0, 'Start reading...' );
    for ind=1:length(Files)

        waitbar( ind/length(Files), wb, 'Reading Files...' );
        
        %Messdatei einlesen
        FileName=Files(ind).name;
        Foldername=strcat(Files(ind).folder,'\');
   
        load( [Foldername FileName] );
   
        String_pos = strfind(FileName,digitsPattern(3)+ '_' + wildcardPattern + '.mat');
        
        %Probanden ID initialisieren
        SubjectIds(ind) = -1;
        TestData(ind).Id = -1;
        TestData(ind).DataOk = false;
        
        %Nur Dateien lesen, die mit der dreistelligen ID beginnen
        if String_pos(1) == 1
       
            Proband_ID_str = FileName(String_pos(1):String_pos(1)+2); 
            Proband_ID = str2num(Proband_ID_str);
   
        else
            continue
        end
   
        %fehlerhafte Messungen rausnehmen
        if Proband_ID == 3 || Proband_ID == 6 || Proband_ID == 9 || Proband_ID == 16
%         figure(Proband_ID) 
%         plot(data{kinetosis_level_index}.Values.Time(pos_start:end),data{kinetosis_level_index}.Values.Data(pos_start:end))
%         hold on
%         plot(data{kinetosis_level_index}.Values.Time(pos_start),kinetosis_level(1),'r*')
            continue    
        end
        
        %Probanden-ID auslesen
        ID_row = find(strcmp(string(Probandenliste(:,ID_col)), string(Proband_ID)));
   
        %Messdatum auslesen aus Messdatei
        date_pos = strfind(FileName, digitsPattern(8)+ '_' + wildcardPattern + '.mat');
        Date_str = FileName(date_pos(1):date_pos(1)+7); 
   
        %Messdatum auslesen aus Protokoll
        Date_Liste = Probandenliste(ID_row,Date_col);
        Date_Liste_format = [Date_Liste{1}(end-3:end) Date_Liste{1}(end-6:end-5) Date_Liste{1}(end-9:end-8)];
   
        %Abgleich der Daten
        if strcmp(Date_Liste_format,Date_str)
        else
            warning('Error by Proband %d! \nDate in Excellist and Date in Filename are not similar',Proband_ID)
        end
   
        %Manöverart und Sitzrichtung auslesen
        Manoever_str = Probandenliste(ID_row,Manoever_col);
        Richtung_str = Probandenliste(ID_row,Richtung_col);
        Spurwechsel_Index = -1;
        
        %Daten in Messdatei finden
        for i=1:numElements(data)
            blockpath_str=data{i}.BlockPath.getBlock(1);
            if contains(blockpath_str,'Abort_Button')
                Abort_index = i;
            end
            if contains(blockpath_str,'Pause_Button')
                Start_index = i;
            end
            if contains(blockpath_str,'Current_Target_Amplitude')
                Current_Target_Amplitude_index = i;
            end
            if contains(blockpath_str,'kinetosis_level')
                kinetosis_level_index = i;
            end
            if contains(blockpath_str,'Log_IMU_Head')
                Log_IMU_Head_index = i;
            end
            if contains(blockpath_str,'Spurwechsel')
                Spurwechsel_Index = i;
            end
            if contains(blockpath_str,'MTi-680G_CAN')
                MTi_680G_CAN_index = i;
            end
            if contains(blockpath_str,'Bus_CAN_Fzg')
                Bus_CAN_Fzg_index = i;
            end
        end
        %Fehlerhafte Daten sollen ausgesondert werden
        if isempty(data{Log_IMU_Head_index}.Values.Head_AccX.Data) || ... 
           isempty(data{Log_IMU_Head_index}.Values.Head_AccY.Data) || ...
           isempty(data{Log_IMU_Head_index}.Values.Head_AccZ.Data)    
            continue;
        end    
%% Kinetose Level    
        % Kinetose-Level bei dem die Zeit gestoppt wird, falls nicht vorher der
        % Abbruchbutton gedrückt wurde
        max_level = 9;
    
        %Identifiziere Start des Versuchs - erster Ausschlag des Sollwertvorgabe
        pos_start = find(data{Start_index}.Values.Data,1);
    
        %Identifiziere Zeitpunkt: Drücken des Abbruchknopfes
        Aborttime_pos = find(data{Abort_index}.Values.Data(pos_start:end),1);
        Aborttime =  Aborttime_pos + pos_start -1;
        TestTime = Aborttime_pos;
    
        %Identifiziere Zeitpunkt: Erreichen des Max Kinetoselevels
        kinetosis_level = data{kinetosis_level_index}.Values.Data(pos_start:end);
        enter_pos = find(data{kinetosis_level_index}.Values.Data(pos_start:end)==12);
        level_pos = [1;enter_pos(find(diff(enter_pos)>3)+1)-3];
   
        %Identifikation der falling edge 
        for t=2:length(level_pos)
            idx_2 = 1;
            while kinetosis_level(level_pos(t)- idx_2) == kinetosis_level(level_pos(t))
                idx_2 = idx_2 + 1;
            end
            level_pos(t) = level_pos(t)- (idx_2-1);
        end
        kinetosis_level( kinetosis_level == 12 ) = 0;
        
        pos_max_level = pos_start - 1 + level_pos(find(11>=data{kinetosis_level_index}.Values.Data(level_pos+pos_start-1) & data{kinetosis_level_index}.Values.Data(level_pos+pos_start-1)>=max_level,1));
        pos_end=min([Aborttime,pos_max_level]);
    %pos_end=min([Aborttime]); % Auskommentieren, falls Abbruch nur bei
    %Drücken des Abbruchkopfes festgestezt wird und nicht am Kinetoselevel 
    
%         figure(Proband_ID)     
%         plot(data{kinetosis_level_index}.Values.Time,data{kinetosis_level_index}.Values.Data)
%         hold on
%         plot(data{kinetosis_level_index}.Values.Time(pos_max_level),data{kinetosis_level_index}.Values.Data(pos_max_level),'r*')
%         hold on
%         plot(data{kinetosis_level_index}.Values.Time(Aborttime),data{kinetosis_level_index}.Values.Data(Aborttime),'g|')
%         hold on
%         plot(data{kinetosis_level_index}.Values.Time(pos_start),data{kinetosis_level_index}.Values.Data(pos_start),'m|')


    %Anzeige der Level und Abfragezeitpunkte
        kinetosis_level(level_pos);
        %diff(level_pos+1)/1000/60
%% Teststart und -endpunkte 
    %Identifiziere Manöverstart- und -endzeitpunkte
        pos_temp= find(data{Current_Target_Amplitude_index}.Values.Data(pos_start:pos_end));
        pos_temp_start = [pos_temp(1); pos_temp(find(diff(pos_temp)>1)+1)];
        pos_temp_ende = [pos_temp(find(diff(pos_temp)>1));pos_temp(end)];
    
        pos_manoever = [pos_temp(1); pos_temp(find(diff(pos_temp)>1)+1)]+ pos_start -1;
    
        
%         figure(Proband_ID*100)     
%         plot(data{Current_Target_Amplitude_index}.Values.Time,data{Current_Target_Amplitude_index}.Values.Data)
%         hold on
%         plot(data{Current_Target_Amplitude_index}.Values.Time(pos_max_level),data{Current_Target_Amplitude_index}.Values.Data(pos_max_level),'r*')
%         hold on
%         plot(data{Current_Target_Amplitude_index}.Values.Time(Aborttime),data{Current_Target_Amplitude_index}.Values.Data(Aborttime),'go')
%         hold on
%         plot(data{Current_Target_Amplitude_index}.Values.Time(pos_start),data{Current_Target_Amplitude_index}.Values.Data(pos_start),'mo')
%         hold on
%         plot(data{Current_Target_Amplitude_index}.Values.Time(pos_manoever),data{Current_Target_Amplitude_index}.Values.Data(pos_manoever),'k*')
    
    %Anzahl der erlebten Manöver gesamt
        number_manoever = length(pos_manoever);
   
    %Dauer der Pausen zwischen zwei Manöver
        duration = [pos_temp_start(2:end) - pos_temp_ende(1:end-1)];
    %Identifiziere alle Wenden (Pausendauer größer als 8s) 
        wende_sum = sum(duration(duration>8000));
    
    %Generiere finale Daten
        Data.ID(ind,1)=Proband_ID;
        Data.Manoever(ind,1)= {Manoever_str};
        Data.Richtung(ind,1)= {Richtung_str};
    
    %Data.Failure_time(ind,1) =((pos_end - pos_start)-wende_sum)/1000; %
    %ohne Wende
    %Data.Failure_time(ind,1) =((pos_end - pos_start))/1000; % mit Wende
        Data.Failure_time(ind,1) = number_manoever * 5; % nur Manoever (ohne Wende, ohne Pausen)
    
    % Eventstatus muss Null sein, wenn kein Abbruch stattfindet
        End_of_Time = find(data{Abort_index}.Values.Data(pos_start:end),1);
    
    %Abbruchknopf nicht gedrückt oder Zeitpunkt des Abbruchs größer als
    %25min
        if isempty(End_of_Time) || End_of_Time > 25 *1000 * 60  
            Data.Eventstatus(ind,1) = 1;
            
        else
            Data.Eventstatus(ind,1) = 0;
        end
        
        
        SubjectIds(ind) = Proband_ID;
        
        TestData(ind).kinetosis_level = double(kinetosis_level(level_pos));
        TestData(ind).kinetosis_level_timestemp = (level_pos)/1000; %[s]
        TestData(ind).kinetosis_level_timestemp(1) = 0;
        TestData(ind).DataOk = true;
        TestData(ind).Id = Proband_ID;
        
        rnd_start = round(data{kinetosis_level_index}.Values.Time(pos_start),2);
        %um Fehler mit der Double genauigkeit zu vermeiden, subtrahieren
        tmp = round(data{Log_IMU_Head_index}.Values.Head_AccX.Time - rnd_start,5) == 0;
        conv_start_idx = find(tmp,1);
        
        rnd_end = round(data{kinetosis_level_index}.Values.Time(pos_end),2);
        %um Fehler mit der Double genauigkeit zu vermeiden, subtrahieren
        tmp2 = round(data{Log_IMU_Head_index}.Values.Head_AccX.Time - rnd_end) == 0;
        conv_end_idx = find(tmp2,1);
        
        %Speichern von Beschleunigung und Winkel
        TestData(ind).a_x = data{Log_IMU_Head_index}.Values.Head_AccX.Data(conv_start_idx:conv_end_idx);
        TestData(ind).a_y = data{Log_IMU_Head_index}.Values.Head_AccY.Data(conv_start_idx:conv_end_idx);
        TestData(ind).a_z = data{Log_IMU_Head_index}.Values.Head_AccZ.Data(conv_start_idx:conv_end_idx);
        TestData(ind).a_res = sqrt(TestData(ind).a_x.^2+TestData(ind).a_y.^2+TestData(ind).a_z.^2);
        TestData(ind).angRateX = data{Log_IMU_Head_index}.Values.Head_AngRateX.Data(conv_start_idx:conv_end_idx);
        TestData(ind).angRateY = data{Log_IMU_Head_index}.Values.Head_AngRateY.Data(conv_start_idx:conv_end_idx);
        TestData(ind).angRateZ = data{Log_IMU_Head_index}.Values.Head_AngRateZ.Data(conv_start_idx:conv_end_idx);
        
        %Speichern der Z-Beschleunigung vom Sitz für ISO2631-1
        TestData(ind).MTi_a_z = data{MTi_680G_CAN_index}.Values.MTi_680G_CAN_accZ.Data(conv_start_idx:conv_end_idx);     

        TestData(ind).isSpurWechsel = Spurwechsel_Index > -1;
        TestData(ind).AbortTime = TestTime/1000;%[s]TestTime
%         TestData(ind).AbortTime = Aborttime/1000;%[s]
        TestData(ind).Max_Selfrate = max(TestData(ind).kinetosis_level);
        
        TestData(ind).a_x_kfz = data{Bus_CAN_Fzg_index}.Values.CAN_Beschleunigung_SP_Ax_Ist.Data(conv_start_idx:conv_end_idx);
        TestData(ind).t_kfz = data{Bus_CAN_Fzg_index}.Values.CAN_Beschleunigung_SP_Ax_Ist.Time(conv_start_idx:conv_end_idx);
        
        if ind == length(Files) 
            close(wb);
        end    
    end
end