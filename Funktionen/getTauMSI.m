%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Diese Funktion erstellt die Werte für den individuellen tau_MSI in 
Abhängigkeit des Fahrmanövers.
Entsprechend der Abbruchszeit und dem Boolean, ob es ein Spurwechsel ist
oder nicht, wird der passende tau_MSU zurückgegeben

Parameter:
    aborttime     :   1 x 1 Double, Zeitpunkt der Abbruchszeit in [s]
    isSpurwechsel :   1 x 1 Boolean, Flag der gesetzt wird wenn es sich um
                                     das Fahrmanöver Spurwechsel handelt
                                     (0 = StopAndGo, 1 = Spurwechsel)

Output:
    tau_MSI  :   1 x 1 Skalar, konstanter tau_MSI

%==========================================================================
%}
function tau_MSI = getTauMSI(aborttime, isSpurwechsel)
    tau_SW  = [60; 120; 360];
    tau_SnG = [60; 150; 150];    
    if isSpurwechsel
        if aborttime < 1000
            tau_MSI = tau_SW(1);
        elseif (aborttime >= 1000) && (aborttime <= 1500)
            tau_MSI = tau_SW(2);  
        else
            tau_MSI = tau_SW(3);
        end    
    else
        if aborttime < 500
            tau_MSI = tau_SnG(1);    
        elseif (aborttime >= 500) && (aborttime <= 1000)
            tau_MSI = tau_SnG(2);  
        else
            tau_MSI = tau_SnG(3);
        end  
    end
end