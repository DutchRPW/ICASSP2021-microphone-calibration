function export(handle, name)

% Make sure figure has fully updated
drawnow;

% Export to eps, without fonts
eps = [tempname, '.eps'];
print(handle, eps, '-painters', '-depsc2', '-r600', '-loose');

% Convert eps to pdf, with embedded fonts
pdf = sprintf('../img/%s.pdf', name);
root_dir = strrep(pwd, "\", "/") + "/..";
gs_exe = "c:/Program Files/gs/gs9.53.3/bin/gswin64c.exe";
gs_cmd = sprintf("""%s"" -sFONTMAP=""%s/FontMap.gs"" -dNOPAUSE " + ...
    "-dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dEPSCrop " + ...
    "-dAutoFilterColorImages=false -dAutoFilterGrayImages=false " + ...
    "-dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode " + ...
    "-dColorConversionStrategy=/LeaveColorUnchanged -dDownsampleMonoImages=false " + ...
    "-dDownsampleGrayImages=false -dDownsampleColorImages=false " + ...
    "-dEmbedAllFonts=true -sOutputFile=""%s"" -f ""%s"" ", ...
    gs_exe, root_dir, pdf, eps);

system(gs_cmd);

% Remove temporary eps
delete(eps);

end