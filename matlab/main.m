%% Load phasors
% Based on 10 seconds long measurements, pre-processed using discrete
% Fourier transform with amplitude-corrected flat top window.
% The 'ref' field contains the 64 microphones × 155 measurements of the
% reference array. The 'uut' field contains the 64 microphones × 155 units
% under test.
%
% The channels are ordered left-to-right, then top-to-bottom, when viewing
% the unit under test from the back. (Thus, two adjacent microphones of
% the reference and unit under test array have the same index in their
% respective struct field.)
%
% The complex numbers correspond to the 1 kHz frequency bin and
% are in units of Pa(RMS). That is, a 1 kHz sine wave with peak-to-peak
% amplitude of ± 1 Pa will correspond to an absolute value of 0.707
% Pa(RMS). The phase follows the sign convention of "E. G. Williams,
% Fourier acoustics: sound radiation and nearfield acoustical holography.
% Academic Press, 1999." This convention is opposite from the one used by
% e.g. Matlab's fft fuction, which means we applied a complex conjugation
% in our pre-processing.
phasors = load('phasors.mat');

%% Discard unreliable measurements
% The measurements were done in two sessions (on a different day), where
% due to practical availability reasons two (different) signal generators
% were used. The used speaker was the same for all measurements, but the
% average output level was different for each generator.
%
% Measurements 1-56 were done using one signal generator, and the others
% using the other.
k = 56;

% Some measurements contain too little signal. This likely has occured due
% to some issues with the source. We discard all measurements where the
% (median over the) reference array was 5 dB less than the median for that
% signal generator.
median_ref_level = median(pa.rms2spl(phasors.ref), 1); % Median over the microphones of the reference array [dB(SPL)]
threshold = 5; % Threshold for discarding [dB]

ref_median1 = median(median_ref_level(1:k)); % Median for signal generator 1 [dB(SPL)]
ref_median2 = median(median_ref_level(k+1:end)); % Median for signal generator 2 [db(SPL)]

src_mask = [ ... % Logical array, true if the measurement should be kept
    median_ref_level(1:k) >= ref_median1 - threshold, ...
    median_ref_level(k+1:end) >= ref_median2 - threshold ...
];

% Due to the large number of matings and unmatings, a connector of a
% DMAIO data capture board had issues at some point. This resulted in some
% channels in some measurements having no signal (i.e. numerical 0). We
% remove those measurements as well.
min_uut_level = min(pa.rms2spl(phasors.uut), [], 1);

con_mask = ... % Logical array, true if the measurement should be kept
    min_uut_level >= pa.rms2spl(eps);

% Combine two masks above (true if the measurement should be kept)
mask = src_mask & con_mask;

% Total number of outliers removed
n_outliers = nnz(~mask);

%% Compute relative gain and phase
gain = mag2db(abs(phasors.uut(:, mask) ./ phasors.ref(:, mask))); % UUT gain relative to reference [dB]
phase = rad2deg(angle(phasors.uut(:, mask) ./ phasors.ref(:, mask))); % UUT phase relative to reference [deg]

k2 = nnz(mask(1:k)); % 'Mapped' index for measurements in session 1 (after removing outliers)

%% Subtract median offsets to recover UUT properties
% We subtract the median offset (for each session) to recover the UUT
% properties we are interested in.
gain_delta = [gain(:, 1:k2) - median(gain(:, 1:k2), 2), gain(:, k2+1:end) - median(gain(:, k2+1:end), 2)]; % UUT gain relative to nominal [dB]
phase_delta = [phase(:, 1:k2) - median(phase(:, 1:k2), 2), phase(:, k2+1:end) - median(phase(:, k2+1:end), 2)]; % UUT phase relative to nominal [dB]

%% Fit probability distributions
% Fit t-distributions
gain_pd = fitdist(gain_delta(:), 'tLocationScale');
phase_pd = fitdist(phase_delta(:), 'tLocationScale');

% Confidence intervals of the three parameters (mu, sigma, nu)
gain_fit_ci = gain_pd.paramci();
phase_fit_ci = phase_pd.paramci();

%% Compute confidence intervals for tolerances (k = 2 i.e. 95%)
% UUT tolerances
gain_ci = gain_pd.icdf(normcdf(2)); % UUT gain tolerance [+/- dB]
phase_ci = phase_pd.icdf(normcdf(2)); % UUT phase tolerance [+/- deg]

%% Apply beamforming to each array of the sample population
% Beamforming equation (broadside source means steering vector consists of
% all ones).
bf = mean(db2mag(gain_delta) .* exp(1i .* deg2rad(phase_delta)), 1); % Complex beamforming gain [-]

% Extract gain compared to nominal beamforming gain of 1. Phase is not very
% relevant for the beamformed result, but could be computed in a similar
% way.
bf_gain = mag2db(abs(bf)); % Beamforming gain relative to nominal [dB]

%% Fit probability distribution for beamforming gain
% Fit an extreme value (Gumbel) distribution
bf_gain_pd = fitdist(bf_gain(:), 'ExtremeValue');

% Confidence intervals of the two parameters (mu, sigma)
bf_gain_fit_ci = bf_gain_pd.paramci();

%% Compute confidence interval for beamforming tolerance (k = 2 i.e. 95%)
% We have to do some gymnastics to compute the confidence interval for the
% Gumbel distribution since it is not symmetric around the mean.
lower_cd = normcdf(-2); % Nominal lower CDF value (i.e. 2.5%) [-]
upper_cd = normcdf(2); % Nominal upper CDF value (i.e. 97.5%) [-]

% Try multiple offsets to the CDF thresholds and select the one which
% results in the tightest range in sample space.
offsets = linspace(-lower_cd, lower_cd, 1000); % This covers the full range since both the lower and upper CDF values must be between 0 and 1.
lower_cbound = bf_gain_pd.icdf(lower_cd + offsets); % Lower bound of candidate confidence intervals [-dB]
upper_cbound = bf_gain_pd.icdf(upper_cd + offsets); % Upper bound of candidate confidence intervals [+dB]
range_cbound = upper_cbound - lower_cbound; % Range of candidate confidence intervals [dB]

[~, idx] = min(range_cbound); % Index of candidate with smallest range
bf_gain_ci_lower = lower_cbound(idx); % Corresponding lower bound [-dB]
bf_gain_ci_upper = upper_cbound(idx); % Corresponding upper bound [+dB]

%% Apply beamforming to random samples from the t-distributions fit above
% We can do the same by generating samples from the gain/phase
% t-distributions which were fit above. This assumes all microphones are
% IID, while in practice there are some correlations per array (either
% because the microphones are close together on the reel, or due to
% limitations of the measurement method). Hence we recover a normal
% distribution here, in contrast to an extreme value distribution above.
M = 64; % Number of microphones
N = 10000; % Number of random samples (i.e. simulated arrays)

bf_samples_gain = db2mag(gain_pd.random(M, N));
bf_samples_phase = deg2rad(phase_pd.random(M, N));
bf_fit = mean(bf_samples_gain .* exp(1i .* bf_samples_phase), 1);
bf_fit_gain = mag2db(abs(bf_fit));
bf_fit_gain_pd = fitdist(bf_fit_gain(:), 'Normal');
bf_fit_gain_fit_ci = bf_fit_gain_pd.paramci();