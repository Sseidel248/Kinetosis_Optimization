clear all; close all; clc;

% Daten laden
addpath('..\Funktionen\');
matDir = '..\Daten\SingleMessung\';
xlxsDir = '..\Daten\Teilnehmer_Xlsx\';
Subject = getSubjectData(matDir, xlxsDir);

ax = Subject(1).a_x;        % Signal X
ay = Subject(1).a_y;        % Signal y
az = Subject(1).a_z;        % Signal z
asitz = Subject(1).MTi_a_z; % Signal Sitz-z
akfz = Subject(1).a_x_kfz; % Signal kfz-x

FFT(ax,'Signal X');
FFT(ay,'Signal Y');
FFT(az,'Signal Z');
FFT(asitz,'Signal Sitz Z');
FFT(akfz,'Signal Kfz X');



%Aperiodisches Signal FFT
function FFT(signal,DiagName)
% Ausgangssignal
f_mess = 100;               % Abtastfrequenz in Hz

L = length(signal);         % Signallänge
dt = 1/f_mess;
t = 0:dt:dt*(L-1);          % Zeitvektor
                           
fftsignale = fft(signal);   % FFT bestimmen
P = abs(fftsignale/L);      % Skalieren
df = f_mess/L;
f = 0:df:f_mess-df;         % Frequenzvektor x (Spektrum)

% Plotten der Ergebnisse
figure();

subplot(2,1,1);
plot(t,signal);
xlabel('Zeit [s]');
grid on;

subplot(2,1,2);
plot(f,P);
xlabel('Frequenz [Hz]');
grid on;

sgtitle(DiagName);
xlim([-0.1 0.4]);
end
