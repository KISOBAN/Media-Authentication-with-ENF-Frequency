fs = 44100;

%STEP 2 TESTING FUNCTION ON a SINGLE AUDIO SIGNAL (recording 1)
Frequency = [60 120 180 240];
t = tiledlayout(2,2);

for i = 1:1:4
nexttile
enf(r1data,fs*16,0.5,'hanning',0,fs,Frequency(i));
title("Surface Plot : " + Frequency(i) + "Hz");
end

%STEP 3 COMPARE 2 ENF SIGNALS (NO PREPROCESSING)

%a is the maximum energy array
%b is the weighted energy array
figure(2);
[a b] = enf(ground1data,fs*16,0.5,'hanning',0,fs,120);     %ground truth1
title("Ground Truth 1 Surface Plot at 120Hz")
figure(3);
[c d] = enf(r1data,fs*16,0.5,'hanning',0,fs,120);   %recording 1
title("Recording 1 Surface Plot at 120Hz")
%Subtracting the mean from both weighted energies 
meanb = (b - mean(b)); %this is the one with the delay (GROUND TRUTH SIGNAL)
meand = (d - mean(d)); %this is the recording (ORIGINAL SIGNAL)
figure(4);
r = xcorr(meanb,meand); %Since the second output is the x-axis,
plot(r)
title("Cross Correlation of Ground Truth and Recording 1")
% the x and y values of this matrix needs to be flipped

%Creating the Frequency Array Again
% from the plot (denoted r) of cross correlation, the maximum value occurs
% at x=35, so 35 'mean' values is prepadded to the ground truth signal
%Creating the 120Hz Frequency Array


array35 = mean(d)*ones(1,35);
newdata = [array35 r1data.'];
figure(5);
[e g] = enf(newdata.',fs*16,0.5,'hanning',0,fs,120);
figure(6);
plot(b);
hold on
plot(g);
title("Aligned Weighted Energies");
%PLOTTING MAXIMUM ENERGY ALLIGNED
figure(7);
plot(a);
hold on
plot(e);
title("Aligned Maximum Energies");
%STEP 4 FILTER THEN DOWN SAMPLE
lowpassground = filtfilt(SOS,G,ground1data); %the data after lowpass filtering

figure(8);
[groundmax groundweight] = enf(lowpassground,441*16,0.5,'hanning',9328,441,120); %Zeropadding = 16384 - 16*fs = 9328

meang = (groundweight - mean(groundweight));

lowpassrec = filtfilt(SOS,G,r1data);
figure(9);
[recmax recweight] = enf(lowpassrec,441*16,0.5,'hanning',9328,441,120);
meanrec = (recweight - mean(recweight));

figure(10);
r = xcorr(meang,meanrec);
plot(r); %the point is to find the delay
%the maximum occurs at X=35 so prepad the recording with 35 of its mean
%values

newrec = [mean(recweight)*ones(1,35) lowpassrec.'];
figure(11);
[e g] = enf(newrec.',441*16,0.5,'hanning',9328,441,120);
figure(12);
plot(groundweight);
hold on
plot(g);

