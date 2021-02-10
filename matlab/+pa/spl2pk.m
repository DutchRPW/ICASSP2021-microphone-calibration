function pa_pk = spl2pk(spl)
% Convert the values from dB(SPL) to Pa(Pk)
p_ref = 20e-6; % Reference pressure [Pa]
pa_pk = sqrt(2) * p_ref * db2mag(spl); % [Pa]

end