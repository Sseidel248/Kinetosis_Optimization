%{
Author: Sebastian Seidel
Mat.-Nr.: 394185 

Parameterdatei für das numerische Kinetose-Modell nach Kamiji 2007.
Originalwerte in Klammern hinter der Beschreibung.
Angepasste Werte verwendet in den Variablen.

--------------------------------------------------------------------------
Definition der Modellparamter
%==========================================================================
%}

P_kin = 0.85;   % [-] Kinetoseanfälligkeit bei gemischten Gruppen aus Frauen und Männern [85%] (0.85)
b_h = 0.5;      % [m/s²] Indifferenter Punkt der Hillfunktion (0.5)
K_a = 0.1;      % [-] Skalierungsfaktor der somatosensorischen Wahrnehmungsungenauigkeit von a (0.1)
K_w = 0.9;      % [-] Skalierungsfaktor der somatosensorischen Wahrnehmungsungenauigkeit von w (0.9)
K_ac = 1.2;     % [1/s] Gewichtung der Rückführung von delta_ar (1.2)
K_vc = 6;       % [1/s] Gewichtung der Rückführung von delta_vr (6)
K_wc = 4;       % [1/s] Gewichtung der Rückführung von delta_wr (4)
n_h = 2;        % [-] Grad der Hillfunktion (2) 
tau_a = 190;    % [s] Zeitkonstante 1 SCC (190)
tau_d = 7;      % [s] Zeitkonstante 2 SCC (7)
tau_LP = 0.1;   % [s] Zeitkonstante LP (0.1)
tau_MSI = 720;  % [s] Zeitkonstante der MSI-Übertragungsfunktion (720)