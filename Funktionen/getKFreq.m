%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Diese Funktion erstellt die Werte des konstanten Frequenzfaktorverlauf. In
Abhängigkeit der Frequenz f_a wird der dazugehörige Frequnzfaktor
gebildet. Wenn die Frequenz nicht existiert wird der k_freq = 1
gesetzt.

Parameter:
    f_a     :   1 x n Vector, Frequenz der Eingangssignale

Output:
    k_freq  :   1 x n Vector, konstanter Frequenzfaktor für die Simulation

%==========================================================================
%}
function k_freq = getKFreq(f_a)    
%% Berechnen den K_frequenzfaktors
    % Frequenzen aus Fig.1 Bos und Bles 1998 
    f_org = [0, 0.083, 0.1, 0.125, 0.167, 0.250, 0.333, 0.417, 0.5]';
    % Interativ ermittelte Faktoren
    k_faktor = [0, 0.02, 0.1, 1.65, 2, 1.25, 0.4, 0.05, 0.01 ]';
    % Frequenzen feiner aufsplitten
    f_fine = (0:0.001:0.5)';
    % Interative ermittelte Faktoren interpolieren, pchip: weißt keine
    % Schwingungen auf nach der Interpolarisation
    kFreqInterp = interp1( f_org, k_faktor, f_fine, 'pchip' ); 
    % Gemeinsames Array erzeugen
    arr = [f_fine, kFreqInterp];
    % Passenden Faktor zur Änderungsrate der Beschleunigung ermitteln
    for i=1:length(f_a)
        idx = f_fine == f_a(i);
        if max(idx) == 0
            k_freq(i) = 1;
        else    
            k_freq(i) = arr( idx, 2 );
        end
    end
end