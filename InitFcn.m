%%% USTAWIENIA MODULACJI
Mary = 4; % QAM-Mary
samplesPerFrame = 8920*log2(Mary); %ile probek w jednej ramce

%%% USTAWIENIA BERT
targetErr = 1e7; %maksymalna liczba bledow do detekcji
maxSymb = 1e8; %maksymalna liczba przeslanych symboli

%%% USTAWIENIA KANALU RAYLEIGHA
% pathDelays = [0 1e-3];
% pathGains = [0 -10];
% dopplerShift = 1e-5;
pathDelays = [0];
pathGains = [0];
dopplerShift = 0;
dopplerSpectrum = doppler('Flat');


%%% USTAWIENIA SZUMU (AWGN)
snrAwgn = 10000;

%%% USTAWIENIA KODU BCH/RS(codewordLength,messageLength)
codewordLength = 7;
messageLength = 4;
codewordLength = 255;
messageLength = 223;
%codewordLength = 15;
%messageLength = 11;

%Generowanie wielomianow dla BCH i RS
genPoly = bchgenpoly(codewordLength,messageLength);
m = ceil(log2(codewordLength + 1));
primitivePoly = gfprimdf(m);
genPolyRS = rsgenpoly(codewordLength,messageLength, [], [], 'double');
ppoly = primpoly(m,'nodisplay');
rsBits = (ceil(log2(1+codewordLength)));
rateBlock = messageLength/codewordLength;

%%% USTAWIENIA KODU SPLOTOWEGO
trellisPoly = poly2trellis(7, [171 133]);
tracebackDepth = 34;
rateConv = trellisPoly.numInputSymbols/trellisPoly.numOutputSymbols;
puncturePattern = ones(1,1); % mozliwosc redukcji rate kodu... Nowy rate kodu to trellisPoly.numInputSymbols/(sum(puncturePattern)/length(puncturePattern)*trellisPoly.numOutputSymbols)

%%% USTAWIENIA EQUALIZERA
eq.sps = 1;
eq.taps = 5;
eq.lambda = 0.99;
eq.refTap = 1;
eq.inputDelay = 0;
eq.wUpdatePer = 1;
eq.const = qammod( 0:(Mary-1), Mary,'gray','UnitAveragePower',1);

%%%%%%%
%%% PONIZEJ KOD DO DOBIERANIA SAMPLES PER FRAME - nie tykać!
%%%%%%%
logMary = log2(Mary);
logCodeword = ceil(log2(codewordLength + 1));
ratio = codewordLength / messageLength;

lcmValue = lcm(logMary, logCodeword);

numerator = lcmValue * messageLength;
gcdValue = gcd(numerator, codewordLength);
minMultiple = numerator / gcdValue;

minSamplesPerFrame = 20000;
maxSamplesPerFrame = 30000;

samplesPerFrame = ceil(minSamplesPerFrame / minMultiple) * minMultiple;

if samplesPerFrame > maxSamplesPerFrame
    % Wybieramy najbliższą wartość do środka zakresu
    midRange = (minSamplesPerFrame + maxSamplesPerFrame) / 2;
    samplesPerFrame = round(midRange / minMultiple) * minMultiple;
    if samplesPerFrame < minSamplesPerFrame || samplesPerFrame > maxSamplesPerFrame
        % Jeśli wciąż poza zakresem, wybieramy najbliższą granicę
        lowerBound = floor(minSamplesPerFrame / minMultiple) * minMultiple;
        upperBound = ceil(maxSamplesPerFrame / minMultiple) * minMultiple;
        
        if minSamplesPerFrame - lowerBound < upperBound - maxSamplesPerFrame
            samplesPerFrame = upperBound;
        else
            samplesPerFrame = lowerBound;
        end
    end
end