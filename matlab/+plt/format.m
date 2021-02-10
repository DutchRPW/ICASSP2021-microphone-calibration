function format(handles)

drawnow;

p = plt.settings();

% Fonts and grid colors
for h = handles
    ax = h.CurrentAxes;
    
    ax.FontSize = p.font.smallsize;
    ax.FontName = p.font.face;
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.GridColor = p.grid.color;
    ax.GridAlpha = p.grid.alpha;
    ax.GridLineStyle = '-';
    ax.MinorGridColor = p.grid.color;
    ax.MinorGridAlpha = p.grid.alpha;
    ax.MinorGridLineStyle = '-';
    ax.LineWidth = p.grid.linewidth;

    th = findall(h, 'Type', 'text');
    for i = 1:length(th)
        set(th(i), 'FontName', p.font.face);
        set(th(i), 'FontSize', p.font.size);
        set(th(i), 'Color', 'k');
    end
end
    
% Fix axes position (tightest inset over all figures + margin)
for h = handles
    h.CurrentAxes.Units = 'centimeters';
end

drawnow;

ti = zeros(1, 4);
for h = handles
    ti = max(ti, h.CurrentAxes.TightInset);
end

for h = handles
    h.CurrentAxes.Position = [ti(1:2) + p.margin, ...
        [p.width, p.height] - ti(1:2) - ti(3:4) - 2 .* p.margin];
end

drawnow;

end