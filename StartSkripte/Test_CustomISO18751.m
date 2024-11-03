%{
Author: Sebastian Seidel
Mat.-Nr.: 394185

Programm zu testen und veranschaulichen des Bewertungsschemas.
%==========================================================================
%}
clear all;

addpath('..\Funktionen\');
xmax=2000;
x=0:1:xmax;
RefFun=sqrt(x);
T1Fun=sqrt(x)+10*sind(x+90)-5;
T1Fun(1)=0;
T2Fun=sqrt(x)+6*sind(x+45)-5;
T2Fun(1)=0;

figure(1);
ax = gca;
plot(ax,x,RefFun,x,T1Fun,x,T2Fun);
grid on;
title(ax,'Ausgangssituation');
xlim([0 xmax+100])
legend(ax,'Referenz','Testgraph 1','Testgraph 2','Location','northwest');
set(ax,'FontSize',20);

%% Test
Result={'Parameter','Testgraph 1','Testgraph 2'};
[X1,A1,B1,C1]=CustomISO18751(RefFun,x,T1Fun,x);
[X2,A2,B2,C2]=CustomISO18751(RefFun,x,T2Fun,x);
Result(2,:)={'A',A1,A2};
Result(3,:)={'B',B1,B2};
Result(4,:)={'C',C1,C2};
Result(5,:)={'X',X1,X2};