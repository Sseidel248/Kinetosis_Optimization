%{
Author: Sebastian Seidel
Mat.-Nr.: 394185 

Werte W_f und f wurden der Tabelle 3 der ISO 2631-1 entnommen.
Diese Funktion dient nur der Berechnung für das Beanspruchungskriterium
Kinetose. Der verwendete Parameter ist lediglich w_f (ISO 2631-1 S.8).
Da das Eingangssignal a eine festen Änderungsrate besitzt entfällt hier die
Bestimmung der Änderungsrate über eine 1/3 Oktavebandfilterung.

Benötigt:
   Audio Toolbox

Parameter:
    a   : n x 1 Vektor, beinhaltet die Beschleunigungen in Z-Richtung, 
                gemessen am Sitz des Fahrers [m/s²]
    f_a : 1 x 1 Skalar, beinhaltet die Änderungsrate der Beschleunigung [Hz]

Output:
    MSDV_n: n x 1 Vektor, Motion Sickness Dose values nach ISO 2631-1:1997 [m/s^1.5]
    a_w_n : n x 1 Vektor, beinhaltet die Frequenzgewichtete Beschleunigung [m/s²]

Hinweis:
    Für f_a wird für ein komplettes Signal als konstant angenommen, womit nur
    ein Oktaveband entsteht.
%==========================================================================
%}
function [MSDV_n, a_w_n] = ISO2631_MSDV(a, f_a)
    %% rausrechnen von g aus der Beschleunigung
    a = a-9.81;

    %% Frequenzen für Wf Tabelle 3 S.7 
    f = [];
    f(1 )=0.0200;
    f(2 )=0.0250;
    f(3 )=0.0315;
    f(4 )=0.0400;
    f(5 )=0.0500;
    f(6 )=0.0630;
    f(7 )=0.0800;
    f(8 )=0.1000;
    f(9 )=0.1250;
    f(10)=0.1600;
    f(11)=0.2000;
    f(12)=0.2500;
    f(13)=0.3150;
    f(14)=0.4000;
    f(15)=0.5000;
    f(16)=0.6300;
    f(17)=0.8000;
    f(18)=1.0000;
    f(19)=1.2500;
    f(20)=1.6000;
    f(21)=2.0000;
    f(22)=2.5000;
    f(23)=3.1500;
    f(24)=4.0000;
    
    %% Gewichtungsfaktor für Wf Tabelle 3 S.7
    w_f = [];
    w_f(1 )=0.024200;
    w_f(2 )=0.037700;
    w_f(3 )=0.059700;
    w_f(4 )=0.097100;
    w_f(5 )=0.157000;
    w_f(6 )=0.267000;
    w_f(7 )=0.461000;
    w_f(8 )=0.695000;
    w_f(9 )=0.895000;
    w_f(10)=1.006000;
    w_f(11)=0.992000;
    w_f(12)=0.854000;
    w_f(13)=0.619000;
    w_f(14)=0.384000;
    w_f(15)=0.224000;
    w_f(16)=0.116000;
    w_f(17)=0.053000;
    w_f(18)=0.023500;
    w_f(19)=0.009980;
    w_f(20)=0.003770;
    w_f(21)=0.001550;
    w_f(22)=0.000640;
    w_f(23)=0.000250;
    w_f(24)=0.000097;
    
    %% Berechnung der Frequenzgewichteten Beschleunigung
    % RMS von einem Element bilden (ISO 2631-1 S.12)
    a = abs(a);
    
    idx = find(f == f_a);
    if idx == 0
        disp('Achtung!');
        disp(['Die Frequenz: ' f_a 'Hz kommt in der ISO 2631-1 nicht vor, daher wird W_f gleich 1 gesetzt.']);
        a_w_n = a;
    else
        a_w_n = w_f(idx).*a;  
    end
    % Da nur ein Oktavband ist i = 1 und die Summe entfällt (ISO 2631-1 S.12)
    a_w_n = sqrt(a_w_n.^2);
    
    %% Berechnung des Motion Sickness Dose Value MSDV
    MSDV_n = sqrt(cumsum(a_w_n.^2));
   
    %Plot test
%     t = 0:1/100:(length(MSDV_n)-1)/100;
%     plot(MSDV_n,t)

end