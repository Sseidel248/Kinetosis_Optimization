%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Pürft ob ein X und ein Y Wert innerhalb eines Fensters um einen optimalen X
und einen optimalen Y Wert liegt.

Parameter:
    chkX        :   1 x 1 Skalar, Zuprüfender X-Wert
    chkY        :   1 x 1 Skalar, Zuprüfender Y-Wert
    optimalX    :   1 x 1 Skalar, Ideal X-Wert
    optimalY    :   1 x 1 Skalar, Ideal Y-Wert

Output:
    FensterMax  :   1 x 1 Skalar, Bewertung des Punkten chkX und ChkY
                                  bezogen auf das Fenster,
                                  Ausgabe: 0...1

%==========================================================================
%}
function FensterMax = getFensterMax(chkX, chkY, optimalX, optimalY)	
    % Self-Rating Wert
	%Fensterkorridor berechnen
    delta_XIn = 50;   % Delta Links und Rechts
    delta_YIn = 1*10; % MISC in MSI
    sqrIn_deltaX = 2*(delta_XIn);
    sqrIn_deltaY = 2*delta_YIn;
    sqrIn_startX = optimalX-delta_XIn;
    sqrIn_startY = optimalY-delta_YIn;
    sqrIn_endX = sqrIn_startX + sqrIn_deltaX;
    sqrIn_endY = sqrIn_startY + sqrIn_deltaY;

    delta_XOut = 100; % Delta Links und Rechts
    delta_YOut = 2*10;% MISC in MSI 
    sqrOut_deltaX = 2*delta_XOut;
    sqrOut_deltaY = 2*delta_YOut;
    sqrOut_startX = optimalX-delta_XOut;
    sqrOut_startY = optimalY-delta_YOut;
    sqrOut_endX = sqrOut_startX + sqrOut_deltaX;
    sqrOut_endY = sqrOut_startY + sqrOut_deltaY;
        
    xv_o = [sqrOut_startX sqrOut_startX sqrOut_endX sqrOut_endX sqrOut_startX NaN ...
            sqrIn_startX sqrIn_startX sqrIn_endX sqrIn_endX sqrIn_startX];
    yv_o = [sqrOut_startY sqrOut_endY sqrOut_endY sqrOut_startY sqrOut_startY NaN ...
            sqrIn_startY sqrIn_endY sqrIn_endY sqrIn_startY sqrIn_startY];
    xv_i = [sqrIn_startX sqrIn_startX sqrIn_endX sqrIn_endX sqrIn_startX];
    yv_i = [sqrIn_startY sqrIn_endY sqrIn_endY sqrIn_startY sqrIn_startY];
    
    %im inneren Bereich
    in = inpolygon(chkX, chkY, xv_i, yv_i);
    %im mittleren Bereich
    in2 = inpolygon(chkX, chkY, xv_o, yv_o);
    
    if in
        FensterMax = 1;
    elseif in2        
        ValueX = getValue(chkX,optimalX,delta_XOut,delta_XIn);
        ValueY = getValue(chkY,optimalY,delta_YOut,delta_YIn);
       
        FensterMax = 0.5 * ValueX + 0.5 * ValueY;
    else
        FensterMax = 0; 
    end
end

%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Prüft ob ein Wert kleiner ist als die untere Grenze, größer als die obere
Grenze oder genau dazwischen liegt. Wenn der Wert dazwischen liegt, wird
das prozentuale Abstandsverhältnis zwischen dem Wert und der unteren
Grenze berechnet. Je näher der Wert an der unteren Grenze liegt desto näher
ist der Rückgabewert an der 1 dran, je weiter weg der Wert von der
untere Grenze liegt, desto näher ist der Rückgabewert an der 0 dran.

Parameter:
    chk             :   1 x 1 Skalar, Zuprüfender Wert
    optimal         :   1 x 1 Skalar, Ideal Wert
    upperlimdelta   :   1 x 1 Skalar, oberer Grenzwert
    lowerlimdelta   :   1 x 1 Skalar, untterer Grenzwert

Output:
    Value  :   1 x 1 Skalar, Bewertung des Punkt <chk> bezogen auf 
                             <optimal>, Ausgabe: 0...1

%==========================================================================
%}
function value = getValue(chk, optimal, upperlimdelta, lowerlimdelta)
    if abs(chk-optimal) < lowerlimdelta
        value = 1;
    else                    
        value = (upperlimdelta-abs(chk-optimal))/(upperlimdelta-lowerlimdelta);
    end
end