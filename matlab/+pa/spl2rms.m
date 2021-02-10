function pa_rms = spl2rms(spl)
% Convert the values from dB(SPL) to Pa(RMS)
pa_rms = pa.spl2pk(spl) / sqrt(2); % [Pa]
end