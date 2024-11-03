%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Für mit den gegebenen Werten eine Berechnung des MSDV nach der ISO2631-1
durch.

Parameter:
    SimOut      :   Ergebnisse der Simulation, für die jeweiligen Subjects
                    wird die Beschleunigung gelesen und der MSDV ermittelt, dieser wird
                    anschließend in die Struct der SimOut gerschrieben
    f_a         :   1 x 1 Skalar, Änderungsrate der Beschleunigung [Hz]
    count       :   1 x 1 Skalar, Schrittweite der Messung [Hz]Maximale Anzahl an Testpersonen
    Fs          :   1 x 1 Skalar, Schrittweite der Messung [Hz]Schrittweite der Messung [Hz]    

Output: simOut  :   1 x n Struktur, beinhaltet alle Testdaten (siehe getSubjectData.m)
            Fields erweitert:
                MSDV_all    :   1 x n,
                MSDV_t      :   1 x n,
%==========================================================================
%}
function [Simout] = SimISO2631(Simout, f_a, count, Fs)
    for i = 1:count
        % Laden der Beschleunigungen vom Kopf in Z-Richtung
        AZB = Simout(i).MTi_a_z;
        % Erzeugen eines Zeitvektors mit entsprechender der Zeitschrittweite
        dt = 1/Fs;  %[s] 0.01s -> alle 10ms ein Sample
        t_max = (length(AZB)/Fs); 
        t = (0:dt:t_max-dt)';
        %MSDV Berechnen    
        [MSDV_all,~] = ISO2631_MSDV(AZB, f_a);
        Simout(i).MSDV_all = MSDV_all;
        Simout(i).MSDV_t = t;
    end    
end