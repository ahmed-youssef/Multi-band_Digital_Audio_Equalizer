clear all;
% Input
[x,Fs]=wavread('hugeWAV');
x = x(:, 1);


% Filter 1
fcuts = [0.2 0.22];
mags = [1 0];
devs = [0.0001 0.0001];
[n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs);
hh1 = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
hh1 = hh1';

% Filter 2
fcuts = [0.28 0.3 0.4 0.42];
mags = [0 1 0];
devs = [0.0001 0.0001 0.0001];
[n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs);
hh2 = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
hh2 = hh2';

% Filter 3
fcuts = [0.48 0.5];
mags = [0 1];
devs = [0.0001 0.0001];
[n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs);
hh3 = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
hh3 = hh3';

lu = [length(hh1), length(hh2), length(hh3)];
L = max(lu);

N = 882; % window size
N_FFT = N + L + 10;

d = stft(x, N_FFT,hann(N));
x_hat=istft(d, N_FFT, hann(N));

%Plots
figure(1)
freqz(hh1);
Title('Frequency Response of the First Filter');
figure(2)
freqz(hh2);
Title('Frequency Response of the Second Filter');
figure(3)
freqz(hh3);
Title('Frequency Response of the Third Filter');

% Spectrum Mods
H1 = fft(hh1, N_FFT);
H2 = fft(hh2, N_FFT);
H3 = fft(hh3,N_FFT);

fin = size(d, 2);
d_y = zeros(size(d));

for i = 1:floor(fin/3)
    d_y(:, i) = H1.*d(:, i);
end

for i = floor(fin/3 + 1):floor(fin*2/3)
    d_y(:, i) = H2.*d(:, i);
end

for i = floor(fin*2/3 + 1):fin
    d_y(:, i) = H3.*d(:, i);
end

y_hat = istft(d_y, N_FFT, hann(N));

figure(4)
freqz(y_hat);
Title('Frequency Response of the Output Signal');
sound(y_hat, Fs);

figure(5)
spectrogram(y_hat);
%  N = 128; 
%  w = zeros(10*N,1);
%  w_m = window(@blackman, N); 
%  w_m_sq = w_m.*w_m;
%  for i = 1:(N/2):(9*N)
%      w(i:i-1+N) = w(i:i-1+N) + w_m;
%  end
%   
%   plot(w)
% 
