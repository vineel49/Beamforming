% Beamforming in multiantenna
% 1 Transmit antenna, 'L' Receive antennas

close all
clear all
clc
SNR_dB = 15; % SNR PER BIT (dB)
L = 4; % NUMBER OF RECEIVE ANTENNAS
NUM_FRAMES = 10^5; % SIMULATION RUNS
FRAME_SIZE = 1024; % FRAME SIZE
NUM_BIT = 2*FRAME_SIZE; % # DATA BITS
FADE_VAR_1D = 0.5; % 1D FADE VARIANCE
FADE_STD_DEV = sqrt(FADE_VAR_1D); % STANDARD DEVIATION OF THE FADING CHANNEL

% SNR PER BIT (Eb/No) - OVERALL RATE IS 2
SNR = 10^(0.1*SNR_dB); 
NOISE_VAR_1D = L*0.5*2*2*FADE_VAR_1D/(2*SNR); % 1D AWGN VARIANCE 
NOISE_STD_DEV = sqrt(NOISE_VAR_1D); % NOISE STANDARD DEVIATION

tic()
C_BER = 0; % bit errors in each frame
for FRAME_CNT = 1:NUM_FRAMES
%----            TRANSMITTER      -----------------------------------------
% SOURCE
A = randi([0 1],1,NUM_BIT);

% QPSK MAPPING (00->1+1i,01->1-1i,10->-1+1i,11->-1-1i; SYMBOL POWER IS 2)
MOD_SIG = 1-2*A(1:2:end) + 1i*(1-2*A(2:2:end));

%---------------     CHANNEL      -----------------------------------------
% RAYLEIGH FREQUENCY FLAT FADING CHANNEL
FADE_CHAN = zeros(L,FRAME_SIZE); % INITIALIZATION
for i1 = 1:L
FADE_CHAN(i1,:) = normrnd(0,FADE_STD_DEV,1,FRAME_SIZE)+1i*normrnd(0,FADE_STD_DEV,1,FRAME_SIZE);
end

% AWGN
AWGN = zeros(L,FRAME_SIZE);
for i1 = 1:L
AWGN(i1,:) = normrnd(0,NOISE_STD_DEV,1,FRAME_SIZE)+1i*normrnd(0,NOISE_STD_DEV,1,FRAME_SIZE);
end

% CHANNEL OUTPUT
CHAN_OP = repmat(MOD_SIG,L,1).*FADE_CHAN + AWGN;

%----------------      RECEIVER  ------------------------------------------
% MAXIMUM RATIO COMBINING
BEAM_FR_OP = sum(CHAN_OP.*conj(FADE_CHAN),1);

% ML DETECTION
DEC_A = zeros(1,NUM_BIT);
DEC_A(1:2:end) = real(BEAM_FR_OP)<0;
DEC_A(2:2:end) = imag(BEAM_FR_OP)<0;

% CALCULATING BIT ERRORS IN EACH FRAME
C_BER = C_BER + nnz(A-DEC_A);
end
toc()
% BIT ERROR RATE
BER = C_BER/(NUM_BIT*NUM_FRAMES)