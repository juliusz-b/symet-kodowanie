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
snrAwgn = 60;

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
trellisPoly = poly2trellis(4, [15 16]);
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





%ebn0 = convertSNR(snrAwgn,"snr","ebno","BitsPerSymbol",log2(Mary),"SamplesPerSymbol",1);
%3/berawgn(ebn0,'qam',Mary)
%bercoding(ebn0,'RS','hard',codewordLength,messageLength,'qam',Mary)

if floor(samplesPerFrame/(messageLength*ceil(log2(1+codewordLength))))~=(samplesPerFrame/(messageLength*ceil(log2(1+codewordLength))))
    warning('Uwaga! Niepoprawnie dobrano kod do liczby probek. Automatyczna modyfikacja dl. wiadomosci.')
    mul = ceil(samplesPerFrame/(messageLength*ceil(log2(1+codewordLength))));
    samplesPerFrame = mul * (messageLength*ceil(log2(1+codewordLength)));
end