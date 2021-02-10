# Characterization of MEMS Microphone Sensitivity and Phase Distributions
This repository contains the data and code used in the following paper:
> Patrick Wijnings, Sander Stuijk, Rick Scholte, Henk Corporaal, "Characterization of MEMS Microphone Sensitivity and Phase Distributions with Applications in Array Processing," _ICASSP 2021 - 2021 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)_, Toronto, Canada, 2021.

## Data format
To limit the size of the data, the 10 seconds long measurements have been pre-processed using the discrete Fourier transform with amplitude-corrected flat top window (see the paper for more details). They are stored in the `matlab/phasors.mat` MAT-file. The `ref` field contains the 64 microphones × 155 measurements of the reference array. The `uut` field contains the 64 microphones × 155 units under test.

The channels are ordered left-to-right, then top-to-bottom, when viewing the unit under test from the back. (Thus, two adjacent microphones of the reference and unit under test array have the same index in their respective struct field.)

The complex numbers correspond to the 1 kHz frequency bin and are in units of Pa(RMS). That is, a 1 kHz sine wave with peak-to-peak amplitude of ± 1 Pa will correspond to an absolute value of 0.707 Pa(RMS). The phase follows the sign convention of:
> E. G. Williams, Fourier acoustics: sound radiation and nearfield acoustical holography. Academic Press, 1999.

This convention is opposite from the one used by e.g. Matlab's fft fuction, which means we applied a complex conjugation in our pre-processing.

## Dependencies
For computing the results (`matlab/main.m`), you need [MATLAB R2020b](https://www.mathworks.com/).

For generating the plots (`matlab/make_plots.m`), you need to download [`brewermap.m`](https://github.com/DrosteEffect/BrewerMap/blob/master/brewermap.m) and place it into the `matlab/+third` folder. You also need to install [GhostScript 9.53.3 (64 bit)](https://www.ghostscript.com/download/gsdnld.html) for post-processing of the EPS files. The Nimbus Roman font must be available on your system (see `FontMap.gs`).