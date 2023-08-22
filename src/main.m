                                            close all; clear; clc;
%-----------------------------------------------------------------------
% 1.    Load a mono audio test signal (.wav)
[filename, path] = uigetfile('*.wav', ...
    'Select a mono audio file', '..\test files\', 'MultiSelect', 'off');
disp(filename)
if (filename == 0)
    disp('Cancelled!')
    return
end
[x, fo] = audioread([path, filename]);
% fo = sampling frequency of x(n)
signal_len = length(x);

%-----------------------------------------------------------------------
% 2.    Input signal Pre-pocessing: Normalization
x_sr = sum(x)/signal_len;
x = x - x_sr;  % removes DC component
x_max = max(abs(x));
x_norm = x/x_max;  % Normalization to [-1,+1] range
x_pass = abs(x_norm) > 0.075;
x_padd = padding(x_pass, 16, 9, 'same');
x_med = med_filtr(x_padd, 1, 16, 9);
x_sel = x_norm.*[x_med; zeros(1, length(x_norm)-length(x_med))'];

%-----------------------------------------------------------------------
% 3.    Cepstrum of the Input signal
win_len = 128; % num of points of each segment
window = hamming(win_len); % gausswin(win_len);
overlap = 64;
shift = win_len - overlap; % = 64
N = 128;    % num of points for FFT
blocks = zeros(win_len, 1); % ie. segments
for i = 0 : shift : signal_len - 1 - win_len
    ordinal = (i/shift)+1;
    % ordinal of the segment/spectrum/cepstrum/point of F0 contour
    blocks(1: win_len, ordinal) = x_sel(i+1 : i+win_len).*window;
end

    % Short time/term spectrums
STFT = fft(blocks, N);
STFTmag = abs(STFT);
% sqrt(C*conj(C)) = abs(C), when C is a complex number

    % Cepstrums of the Input signal
K = real(ifft(log(STFTmag), N));

% fft and other built-in fns work by columns of matrices
% of dimensions row_num x col_num ie. win_len x ordinal

%-----------------------------------------------------------------------
% 4.    Time, Frequency and Quefrency axis
T = 1/fo;
t_axis = (0: signal_len - 1)*T;  % t_axis is Time axis [s]

dt_F0 = shift*T; % = 0.01161 s = 11.61 ms
t_axis_F0 = (2: ordinal+1)*dt_F0;  % t_axis_F0 is Time axis [s]

df = fo/N;
f_axis = (0: N/2-1)*df;  % f_axis is Frequency axis [Hz]

dq = T; % = 0.125 ms
q_axis = (0: N/2-1)*dq;  % q_axis is Quefrency axis [s]

%-----------------------------------------------------------------------
% 5.    F0 - Fundamental Frequency of the input signal
F0_ggr = 300;  % [Hz]
F0_low_lim = 80; % [Hz]
T0_low_lim = 1/F0_ggr; % = 3.33 ms
T0_ggr = 1/F0_low_lim; % = 12.5 ms

index_ggr = min(N,ceil(T0_ggr/dq));
index_low_lim = floor(T0_low_lim/dq);
[Kmaxi, Kmax_ind] = max(K(index_low_lim: index_ggr, :));
%-----------------------------------------
% peak detection threshold
% peak position on time axis is 1/F0
threshold = max(Kmaxi)*0.25;
    % threshold = max(Kmaxi)*0.52; % = 0.1056 for Filtered signal
        % threshold = max(Kmaxi)*0.48; % = 0.10896 for Noisy signal
% threshold decides if a segment of the input signal is resonant ie. has F0
%-----------------------------------------
max_ind = find(Kmaxi >= threshold);
% max, find and other built-in fns work by matrix columns

F0 = zeros(ordinal, 1);
F0(max_ind) = 1./((Kmax_ind(max_ind) + index_low_lim - 1)*dq);

% We want just non-zero values of F0 --> new axis
t_axis_F0_non0 = t_axis_F0(F0 ~= 0);
F0_non0 = F0(F0 ~= 0);

%-----------------------------------------------------------------------
% 6.    Median filtering (3, 5)
med_shift = 1;
med_window = 3;
med_center = 2;

% padding F0 (mirror the samples) to get length(med_F0) = length(F0_non0)
F0_padd = padding(F0_non0, med_window, med_center, 'mirror');
F0_med = med_filtr(F0_padd, med_shift, med_window, med_center);

%-----------------------------------------------------------------------
% 7.    Non-linear filtering (Rabiner, Schafer)
%       Median (3, 5) + Linear h = [1/4, 1/2, 1/4]
b = [1/4, 1/2, 1/4];
a = zeros(1, length(b));
a(1) = 1;
y = filter(b, a, F0_med);
z = F0_non0 - y;
z_padd = padding(z, med_window, med_center, 'same');
z_med = med_filtr(z_padd, med_shift, med_window, med_center);
v = filter(b, a, z_med);
F0_med_lin = y + v;

F0_med_lin_padd1 = ...
    padding(F0_med_lin, med_window, med_center, 'mirror');
F0_med_lin_med1 = ...
    med_filtr(F0_med_lin_padd1, med_shift, med_window, med_center);

F0_med_lin_padd = ...
    padding(F0_med_lin_med1, med_window, med_center, 'zeros');
F0_med_lin_med = ...
    med_filtr(F0_med_lin_padd, med_shift, med_window, med_center);

%-----------------------------------------------------------------------
% 8.    Fig. Group 1: Input signal and its Fundamental Frequency 
%                   SYNCED, after Median and Non-linear filtering,
%                       with Praat data
%-----------------------------------------
figure(1)
    subplot(2,1,1)
plot(t_axis, x_norm)
hold on
plot(t_axis, [x_med; zeros(1, length(x_norm)-length(x_med))'])
ylabel('Amplitude')%, xlabel('Time [s]')
title('Input speech signal (normalized)')
axis([min(t_axis) max(t_axis), -1.05 1.05])
hold off
grid on
    subplot(2,1,2)
plot(t_axis_F0_non0, F0_non0, 'k-s', 'linewidth', 1.5,...
    'markersize', 3, 'markerfacecolor', 'b')
xlabel('Time [s]'), ylabel('Frequency [Hz]')
title(['Fundamental Frequency F_0, threshold = ', num2str(threshold)])
axis([min(t_axis) max(t_axis), ...
        round(min(F0_non0)*0.9/30)*30 round(max(F0_non0)*1.1/30)*30])
limits = axis;
set(gca,'ytick',limits(3): 10: limits(4))
grid on
%-----------------------------------------
% Fig. 2
figure(2)
    subplot(2,1,1)
plot(t_axis_F0_non0, F0_med, 'k-s', ...
    'linewidth', 1.5, 'markersize', 3, 'markerfacecolor', 'g')
ylabel('Frequency [Hz]')
title(['Fundamental Frequency F_0'...
    ', Median (', num2str(med_center), ', ' num2str(med_window),...
    ') filtering'])
axis(limits)
set(gca,'ytick',limits(3):10:limits(4))
grid on
    subplot(2,1,2)

% Load Praat dataset (.txt)
[filepath,name,ext] = fileparts(filename);
if (filename == 0)
    disp('Loading data generated in Praat is cancelled!')
    praat_t_axis_F0_non0 = [min(t_axis) max(t_axis)];
    praat_F0_non0 = [0 0];
    plot(praat_t_axis_F0_non0, praat_F0_non0, '--r', 'linewidth', 3)
else
    [r_br, Time_praat, F0_praat] =...
        read_praat_output('test files', name);
    % only non-zero F0
    praat_t_axis_F0_non0 = Time_praat(F0_praat ~= 0);
    praat_F0_non0 = F0_praat(F0_praat ~= 0);
    plot(praat_t_axis_F0_non0, praat_F0_non0, 'k-s',...
        'linewidth', 1.5, 'markersize', 3, 'markerfacecolor', 'm')
    xlabel('Time [s]'), ylabel('Frequency [Hz]')
    title('Fundamental Frequency F_0, Praat')
    axis(limits)
    set(gca,'ytick',limits(3): 10: limits(4))
    grid on
end
%-----------------------------------------
% Fig. 3
figure(3)
    subplot(2, 1, 1)
plot(t_axis_F0_non0, F0_med_lin, 'k-s', ...
    'linewidth', 1.5, 'markersize', 3, 'markerfacecolor', 'c')
ylabel('Frequency [Hz]')
title('Fundamental Frequency F_0, Non-linear filtering')
axis(limits)
set(gca,'ytick',limits(3): 10: limits(4))
grid on
    subplot(2, 1, 2)
plot(t_axis_F0_non0, F0_med_lin_med, 'k-s', ...
    'linewidth', 1.5, 'markersize', 3, 'markerfacecolor', 'y')
xlabel('Time [s]'), ylabel('Frequency [Hz]')
title('Fundamental Frequency F_0, Non-linear + Median filtering')
axis(limits)
set(gca,'ytick',limits(3): 10: limits(4))
grid on

%-----------------------------------------------------------------------
% 9.    Fig. Group 2: F0 Graphs
%-----------------------------------------
% Fig. 4
figure(4)
plot(t_axis_F0_non0, F0_non0, 'k-s', 'linewidth', 1,...
    'markersize', 3, 'markerfacecolor', 'b')
hold on
plot(t_axis_F0_non0, F0_med, 'k-s', ...
    'linewidth', 1, 'markersize', 3, 'markerfacecolor', 'g')
plot(praat_t_axis_F0_non0, praat_F0_non0, 'k-s',...
        'linewidth', 1, 'markersize', 3, 'markerfacecolor', 'm')
plot(t_axis_F0_non0, F0_med_lin_med, 'k-s', ...
    'linewidth', 1, 'markersize', 3, 'markerfacecolor', 'y')
xlabel('Time [s]'), ylabel('Frequency [Hz]')
title('Fundamental Frequency F_0')
legend('threshold', 'Median', 'Praat', 'Nelin + Med', 'location', 'southoutside')
% legenda ide tamo gde ne smeta
axis([min(praat_t_axis_F0_non0(1), t_axis_F0_non0(1))*0.9 ...
    max(praat_t_axis_F0_non0(end), t_axis_F0_non0(end))*1.05, ...
    limits(3:4)])
set(gca,'ytick',limits(3): 10: limits(4))
grid on
hold off

%-----------------------------------------------------------------------
% 10.    Fig. Group 3: Spectrums and Cepstrums (segments 168 to 190)
start_segment = 168;
stop_segment = 190;
STFTmagdB = 20*log10(STFTmag);
STFTmaxdB = max(max(STFTmagdB));
STFTnormdB = STFTmagdB/STFTmaxdB;
%-----------------------------------------
% Fig.5
figure(5)
    subplot(1, 2, 1)
plot(f_axis, STFTnormdB(1: N/2, start_segment) + start_segment, ...
    'linewidth', 1.4)
for i = start_segment + 1: 1: stop_segment
    line(f_axis, STFTnormdB(1: N/2, i) + i, 'linewidth', 1.4)
end
xlabel('Frequency [Hz]')
ylabel('Spectrum Ordinal')
title('Spectrums (normalized)')
axis([min(f_axis) max(f_axis), start_segment-1 stop_segment+1])
limits_s = axis;
set(gca,'xtick',limits_s(1): 1000: limits_s(2))
set(gca,'ytick',limits_s(3)+1: 1: limits_s(4)-1)
line([F0_low_lim F0_low_lim], [limits_s(3), limits_s(4)], ...
    'linestyle', ':', 'color', 'r', 'linewidth', 2)
line([F0_ggr F0_ggr], [limits_s(3), limits_s(4)], ...
    'linestyle', ':', 'color', 'r', 'linewidth', 2)
grid on
    subplot(1, 2, 2)
plot(q_axis, K(1: N/2, start_segment) + start_segment, 'k', 'linewidth', 1.5)
for i = start_segment + 1: 1: stop_segment
    line(q_axis, K(1: N/2, i) + i, 'color', 'k', 'linewidth', 1.5)
end
line([T0_low_lim T0_low_lim], [limits_s(3), limits_s(4)], ...
    'linestyle', ':', 'color', 'r', 'linewidth', 2)
line([T0_ggr T0_ggr], [limits_s(3), limits_s(4)], ...
    'linestyle', ':', 'color', 'r', 'linewidth', 2)
xlabel('Quefrency [s]')
ylabel('Cepstrum Ordinal')
title('Cepstrums')
axis([min(q_axis) max(q_axis), start_segment-1 stop_segment+1])
limits_k = axis;
set(gca,'ytick',limits_k(3)+1: 1: limits_k(4)-1)
grid on

%-----------------------------------------------------------------------
% 11.    Fig. Group 4: Spectrum & Cepstrum (segment Num. 175)
segment = 175;
lim = index_low_lim; % = 36
K_short_seg = K(1: lim, segment);
K_short_seg(lim + 1 : win_len, 1) = 0; % zero padding
short_win = window;
K_short_seg_win = K_short_seg.*short_win;
K_short_seg_fft = abs(fft(K_short_seg_win, N));
%-----------------------------------------
factor = 43; % lower factor increases HF part of cepstrum (see fig)
    % factor = 28;  % for Filtered signal
        % factor = 90;  % for Noisy signal
%-----------------------------------------
K_short_seg_scaled = - 20*(1/log(10))*K_short_seg_fft *factor;
K_short_seg_norm = K_short_seg_scaled + abs(max(K_short_seg_scaled));

STFTmag_seg = STFTmag(1: N/2, segment);
STFTmag_seg_dB = 20*log10(STFTmag_seg);
STFTmag_seg_norm_dB = STFTmag_seg_dB - abs(max(STFTmag_seg_dB));
%-----------------------------------------
figure(6)
plot(f_axis, STFTmag_seg_norm_dB, 'linewidth', 1.25)
line(f_axis, K_short_seg_norm(1: N/2), ...
    'color', 'k', 'linewidth', 2)
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
title(['Segment num. ' num2str(segment)])
legend('Spectrum', 'FT(Cepstrum)')
% legenda ide tamo gde ne smeta
axis([min(f_axis) max(f_axis), - 80 5])
limits_f = axis;
set(gca,'xtick',limits_f(1): 500: limits_f(2))
set(gca,'ytick',limits_f(3): 5: limits_f(4))
line([F0_low_lim F0_low_lim], [limits_f(3), limits_f(4)], ...
    'linestyle', ':', 'color', 'r', 'linewidth', 2)
line([F0_ggr F0_ggr], [limits_f(3), limits_f(4)], ...
    'linestyle', ':', 'color', 'r', 'linewidth', 2)
grid on

%*************************************************************************
%   END
