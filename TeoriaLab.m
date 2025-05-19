snrs = [0:0.5:50];
warning('off','all')
Mary = 4;

codewordLength = 255;
messageLength = 223;
t = bchnumerr(codewordLength, messageLength);
dmin = 2*t + 1;


[~,TBCH] = bchgenpoly(codewordLength,messageLength);
BCHRATE = messageLength/codewordLength;
[~,TRS] = rsgenpoly(codewordLength,messageLength, [], [], 'double');
TRS*(ceil(log2(1+codewordLength)));

bers = [];
for i=1:length(snrs)

    snr = snrs(i);

    ebn0 = convertSNR(snr,"snr","ebno","BitsPerSymbol",log2(Mary),"SamplesPerSymbol",1);
    berRS = bercoding(ebn0,'RS','hard',codewordLength,messageLength,'qam',Mary);
    berBCH = bercoding(ebn0,'block','hard',codewordLength,messageLength,dmin,'qam',Mary);
    berAWGN = berawgn(ebn0,'qam',Mary);

    bers(i,1) = berAWGN;
    bers(i,2) = berBCH;
    bers(i,3) = berRS;


end
warning('on','all');

figure;
plot(snrs,log10(bers(:,1:3)))
xlabel('SNR [dB]')
ylabel('BER')
legend({'UNCODED','BCH','RS'})
ylim([-12 0])

%%
%%% szukanie zysku
bersGain = linspace(-70,-3,1000);
bersGain(isinf(bersGain)) = [];

snrGainRS = [];
snrGainBCH = [];
for i=1:length(bersGain)

    [~,ix] = unique(log10(bers(:,1)));
    ix2 = find(isinf(log10(bers(ix,1))));
    ix(ix2) = [];
    snrBerUn = interp1(log10(bers(ix,1)),snrs(ix),bersGain(i));

    [~,ix] = unique(log10(bers(:,3)));
    ix2 = find(isinf(log10(bers(ix,3))));
    ix(ix2) = [];
    snrsBerCo = interp1(log10(bers(ix,3)),snrs(ix),bersGain(i));

    snrGainRS(i) = snrBerUn-snrsBerCo;

    [~,ix] = unique(log10(bers(:,2)));
    ix2 = find(isinf(log10(bers(ix,2))));
    ix(ix2) = [];
    snrsBerCo = interp1(log10(bers(ix,2)),snrs(ix),bersGain(i));

    snrGainBCH(i) = snrBerUn-snrsBerCo;

end

figure;
plot(bersGain,snrGainRS)
hold on;
plot(bersGain,snrGainBCH)
xlabel('log10(BER)')
ylabel('Code gain [SNR]')
legend({'RS','BCH'})