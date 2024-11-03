%{
Author: Sebastian Seidel
Mat.-Nr.: 394185 

Parameterdatei für das numerische Kinetose-Modell nach Barccesi 2011.
Originalwerte in Klammern hinter der Beschreibung.
Angepasste Werte verwendet in den Variablen.

--------------------------------------------------------------------------
Definition der Modellparamter
%==========================================================================
%}

tau_x = 0.6;    % [s] (0.6)
tau_y = 2.4;    % [s] (2.4)
tau_z = 0.6;    % [s] (0.6)
k_x   = 0.84;   % [1/s] (0.84)
k_y   = 3.36;   % [1/s] (3.36)
k_z   = 0.84;   % [1/s] (0.84)
n     = 2;      % [-] Grad der Hillfunktion (2)
b     = 0.7;    % [-] Indifferenter Punkt der Hillfunktion (0.7)
mue   = 900;    % [s] Zeitkonstante der MSI-Übertragungsfunktion (900)
P     = 0.85;   % [-] Kinetoseanfälligkeit bei gemischten Gruppen aus Frauen und Männern [85%] (0.85)
k     = 1.414;  % [-]
