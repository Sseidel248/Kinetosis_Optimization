%Test für getFensterMax
%Fenster um (0|0)
%Fenster innen X:50 50 -50 -50
%Fenster außen X:100 100 -100 -100
%Fenster innen X:1 1 -1 -1
%Fenster außen X:3 3 -3 -3
t1 = getFensterMax(-75,2,0,0);
disp('Test1:')
disp(getResult(t1 < 1 && t1 > 0));

t2 = getFensterMax(0,2,0,0);
disp('Test2:')
disp(getResult(t2 < 1 && t2 > 0));

t3 = getFensterMax(75,2,0,0);
disp('Test3:')
disp(getResult(t3 < 1 && t3 > 0));

t4 = getFensterMax(-75,0,0,0);
disp('Test4:')
disp(getResult(t4 < 1 && t4 > 0));

t5 = getFensterMax(0,0,0,0);
disp('Test5:')
disp(getResult(t5 == 1));

t6 = getFensterMax(75,0,0,0);
disp('Test6:')
disp(getResult(t6 < 1 && t6 > 0));

t7 = getFensterMax(-75,-2,0,0);
disp('Test7:')
disp(getResult(t7 < 1 && t7 > 0));

t8 = getFensterMax(0,-2,0,0);
disp('Test8:')
disp(getResult(t8 < 1 && t8 > 0));

t9 = getFensterMax(1,-2,0,0);
disp('Test9:')
disp(getResult(t9 < 1 && t9 > 0));

t10 = getFensterMax(0,5,0,0);
disp('Test10:')
disp(getResult(t10 == 0));

t11 = getFensterMax(0,-5,0,0);
disp('Test11:')
disp(getResult(t11 == 0));

t12 = getFensterMax(125,0,0,0);
disp('Test12:')
disp(getResult(t12 == 0));

t13 = getFensterMax(-125,0,0,0);
disp('Test13:')
disp(getResult(t13 == 0));

function str = getResult(b)
    if b
        str = 'bestanden!';
    else
        str = 'nicht bestanden';
    end    
end