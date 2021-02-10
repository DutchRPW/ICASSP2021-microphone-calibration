function spl = pk2spl(pa_pk)
% Convert the values from Pa(Pk) to dB(SPL)
p_ref = 20e-6; % Reference pressure [Pa]
spl = mag2db(abs(pa_pk) / (sqrt(2) * p_ref)); % [dB(SPL)]

end