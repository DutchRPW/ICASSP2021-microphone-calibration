function p = settings()

p = struct();

p.col = struct();
p.col.red = [228, 26, 28] ./ 255;
p.col.blue = [55, 126, 184] ./ 255;
p.col.green = [77, 175, 74] ./ 255;
p.col.purple = [152, 78, 163] ./ 255;
p.col.orange = [255, 127, 0] ./ 255;
p.col.yellow = [255, 255, 51] ./ 255;
p.col.brown = [166, 86, 40] ./ 255;
p.col.pink = [247, 129, 191] ./ 255;
p.col.grey = [153, 153, 153] ./ 255;

p.width = 8.6; % Plot width [cm]
p.aspect = sqrt(2); % Aspect ratio (width / height)
p.height = p.width / p.aspect; % Plot height [cm]

p.margin = 0.1; % Margin around figure [cm]

p.font = struct();
p.font.face = 'Nimbus Roman';
p.font.size = 9;
p.font.smallsize = 7;

p.line = struct();
p.line.width = 1.5;

p.grid = struct();
p.grid.color = 'k';
p.grid.alpha = 1;
p.grid.linewidth = 0.5;

end