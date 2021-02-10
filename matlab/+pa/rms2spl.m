function spl = rms2spl(pa_rms)
% Convert the values from Pa(RMS) to dB(SPL)
spl = pa.pk2spl(sqrt(2) * pa_rms); % [dB(SPL)]
end