%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Graphenvergleich in Anlehnung an die ISO/TS 18751.

Parameter:
    RSignal     :   1 x n Vektor, Zu Prüfende X-Werte (Testgraph T)
    RTime       :   1 x n Vektor, Zu Prüfende Y-Werte (Testgraph T)
    TSignal     :   1 x n Vektor, Ideale X-Werte (Referenzgraph R)
    TTime       :   1 x n Vektor, Ideale Y-Werte (Referenzgraph R)

Hinweis:    
    Die Vektoren sollten die alle die gleiche Länge haben. Es wird eine
    Interpolarisation auf die Länge des Referenssignals empfohlen, um 
    ungenauigkeit zu vermeiden.

Output:
    X   :   1 x 1 Skalar, beinhaltet die Bewertung in Anlehnung an die
                          ISO/TS 18751
    A   :   1 x 1 Skalar, beinhaltet die Korridorwertung (Teil der
                          Gesamtwertung)
    B   :   1 x 1 Skalar, beinhaltet die Fenstermax.-Wertung (Teil der
                          Gesamtwertung)
    C   :   1 x 1 Skalar, beinhaltet die Schwankungswertung (Teil der
                          Gesamtwertung)

%==========================================================================
%}
function [X, A, B, C] = CustomISO18751(RSignal, RTime, TSignal, TTime)
% Gewichtungsfaktoren
% Im Korridor um den Graph
    x1 = 0.6;
% Im Fenster den Maximalen Self-Rating
    x2 = 0.3;
% gering Schwankung
    x3 = 0.1;

% Parameter für Korridor MISC angepasst an MSI
    inK = 0.5 * 10;
    outK = 1.5 * 10;
% ---- Prüfung 1 : liegt der Graph im Korridor um den Self-Rating Graph
    Korridor_all = [];
    for n=1:length(RTime)
        %Wegen Gleitkommadarstellung (Ungenauigkeit)
        T = TSignal(n);
        R = RSignal(n);
        %Keine Werte extrapolieren (Wenn NaN dann nicht mitzählen)
        if isnan(R)
            continue;
        end    

        if abs(T-R) < inK
            Korridor_all(n,1) = 1;
        elseif abs(T-R) > outK
            Korridor_all(n,1) = 0;
        else                    
            Korridor_all(n,1) = (outK-abs(T-R))/(outK-inK);
        end
    end
    A = mean(Korridor_all);    
% ---- Prüfung 2 : liegt der letzte Werte im Fenster um den letzten
    FensterMax = getFensterMax(TTime(end),TSignal(end),RTime(end),RSignal(end));
    B = FensterMax;                 
% ---- Prüfung 3 : berechnen der normierten Standartabweichung der 1. Abbleitung
    diffMSI = diff(TSignal);
    diffAbweichung = std(diffMSI);
% Hinweis je kleiner die Schwankung desto besser!
    Schwankung = 1 - diffAbweichung;
    C = Schwankung;
%% Berechnen der Gesamtbewertung
    X = x1 * A + x2 * B + x3 * C;
end