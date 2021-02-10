%% Plot
close all;

%% Plot gain map
% Initialize.
p = plt.settings();
handle_fig1 = figure('Units', 'centimeters', 'Position', [15, 5, p.width, p.height]);

% Do the plotting.
imagesc(gain_delta);

hxl1 = xlabel('Device under test');
hyl1 = ylabel('Microphone');

% Setup colormap.
lim = 1.7; % Colormap limit value [dB]
cm = third.brewermap(2560, 'PRGn');

% Warp the colormap to prevent most data points to be squished into the
% white-colored region of the map.
cx = linspace(0, 1, 2560);
cxq = gain_pd.cdf(linspace(-lim, lim, 2560));
cmy = interp1(cx, cm, cxq);

colormap(cmy);

auto_caxis = caxis();
assert(all(abs(auto_caxis) <= lim + lim / 2560)); % Ensure no data is clipped
caxis([-lim, lim]);

% Setup colorbar.
hc1 = colorbar(gca);
hc1.LineWidth = p.grid.linewidth;
hcy1 = ylabel(hc1, 'Sensitivity offset from nominal [dB]');
hcy1.FontSize = p.font.size;

% Setup grid / axis ticks.
ax = gca;
ax.YTick = (1:8:65) - 0.5;
ax.YTickLabel = [{[]}, num2cell(8:8:64)];
ax.XTick = (1:20:131) - 0.5;
ax.XTickLabel = [{[]}, num2cell(20:20:130)];

grid on;

%% Plot phase map
% Initialize.
p = plt.settings();
handle_fig2 = figure('Units', 'centimeters', 'Position', [15, 5, p.width, p.height]);

% Do the plotting.
imagesc(phase_delta);

hxl2 = xlabel('Device under test');
hyl2 = ylabel('Microphone');

% Setup colormap.
lim = 5; % Colormap limit value [deg]
cm_b = flipud(third.brewermap(2560, 'PuOr'));
cm_a = third.brewermap(2560, 'PRGn');
cm = [cm_a(1:1280, :); cm_b(1281:end, :)];

% Warp the colormap to prevent most data points to be squished into the
% white-colored region of the map.
cx = linspace(0, 1, 2560);
cxq = phase_pd.cdf(linspace(-lim, lim, 2560));
cmy = interp1(cx, cm, cxq);

colormap(cmy);

auto_caxis = caxis();
assert(all(abs(auto_caxis) <= lim + lim / 2560)); % Ensure no data is clipped
caxis([-lim, lim]);

% Setup colorbar
hc2 = colorbar(gca);
hc2.LineWidth = p.grid.linewidth;
hcy2 = ylabel(hc2, 'Phase offset from nominal [°]');
hcy2.FontSize = p.font.size;

% Setup grid / axis ticks.
ax = gca;
ax.YTick = (1:8:65) - 0.5;
ax.YTickLabel = [{[]}, num2cell(8:8:64)];
ax.XTick = (1:20:131) - 0.5;
ax.XTickLabel = [{[]}, num2cell(20:20:130)];

grid on;

%% Plot gain histogram
% Initialize.
p = plt.settings();
handle_fig3 = figure('Units', 'centimeters', 'Position', [15, 5, p.width, p.height]);

cm = third.brewermap(12, 'Paired');

histogram(gain_delta(:), -1.7:0.05:1.7, 'Normalization', 'pdf', ...
    'EdgeColor', 'none', 'FaceColor', cm(3, :), ...
    'FaceAlpha', 1, 'LineWidth', p.line.width);

hold on;
plot(-1.7:0.01:1.7, gain_pd.pdf(-1.7:0.01:1.7), 'LineWidth', p.line.width, 'Color', cm(4, :));

xlim([-1.7, 1.7]);
ylim([0, 2.5]);

hl1 = legend('Histogram', 't-distribution fit', 'Location', 'northeast');
hl1.FontName = p.font.face;
hl1.FontSize = p.font.size;
hl1.EdgeColor = 'none';

hold off;

grid on;
hxl3 = xlabel('Sensitivity offset from nominal [dB]');
hyl3 = ylabel('Probability density [1/dB]');

text(handle_fig3.CurrentAxes, 0.037, 0.965, ["\mu", "\sigma", "\nu"], ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'Units', 'normalized', 'BackgroundColor', 'w');
text(handle_fig3.CurrentAxes, 0.067, 0.965, sprintf('\n\n= %.2f (%.2f\\leftrightarrow%.2f)    ', ...
    gain_pd.nu, ...
    gain_fit_ci(1, 3), ...
    gain_fit_ci(2, 3)), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'BackgroundColor', 'white');

text(handle_fig3.CurrentAxes, 0.067, 0.965, sprintf('= %.2f dB (%.2f\\leftrightarrow%.2f)', ...
    abs(gain_pd.mu), ...
    gain_fit_ci(1, 1), ...
    gain_fit_ci(2, 1)), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'BackgroundColor', 'none');

text(handle_fig3.CurrentAxes, 0.067, 0.965, sprintf('\n= %.2f dB (%.2f\\leftrightarrow%.2f)', ...
    gain_pd.sigma, ...
    gain_fit_ci(1, 2), ...
    gain_fit_ci(2, 2)), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'BackgroundColor', 'none');

%% Plot phase histogram
% Initialize.
p = plt.settings();
handle_fig4 = figure('Units', 'centimeters', 'Position', [15, 5, p.width, p.height]);

cm = third.brewermap(12, 'Paired');

histogram(phase_delta(:), -5:0.1:5, 'Normalization', 'pdf', ...
    'EdgeColor', 'none', 'FaceColor', cm(7, :), ...
    'FaceAlpha', 1, 'LineWidth', p.line.width);

hold on;
plot(-5:0.02:5, phase_pd.pdf(-5:0.02:5), 'LineWidth', p.line.width, 'Color', cm(8, :));

xlim([-5, 5]);
%ylim([0, 2.5]);

hl2 = legend('Histogram', 't-distribution fit', 'Location', 'northeast');
hl2.FontName = p.font.face;
hl2.FontSize = p.font.size;
hl2.EdgeColor = 'none';

hold off;

ax = gca;
ax.XTick = -5:1:5;
%ax.YTick = 0:0.5:2.5;

grid on;
hxl4 = xlabel('Phase offset from nominal [°]');
hyl4 = ylabel('Probability density [1/°]');

text(handle_fig4.CurrentAxes, 0.037, 0.965, ["\mu", "\sigma", "\nu"], ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'Units', 'normalized', 'BackgroundColor', 'w');
text(handle_fig4.CurrentAxes, 0.067, 0.965, sprintf('= %.2f° (%.2f\\leftrightarrow%.2f)\n= %.2f° (%.2f\\leftrightarrow%.2f)\n= %.2f (%.2f\\leftrightarrow%.2f)', ...
    abs(phase_pd.mu), ...
    abs(phase_fit_ci(1, 1)), ...
    phase_fit_ci(2, 1), ...
    phase_pd.sigma, ...
    phase_fit_ci(1, 2), ...
    phase_fit_ci(2, 2), ...
    phase_pd.nu, ...
    phase_fit_ci(1, 3), ...
    phase_fit_ci(2, 3)), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'BackgroundColor', 'w');

%% Plot beamforming histogram
% Initialize.
p = plt.settings();
handle_fig5 = figure('Units', 'centimeters', 'Position', [15, 5, p.width, p.height]);

cm = third.brewermap(12, 'Paired');

histogram(bf_gain(:), -1.7:0.05:1.7, 'Normalization', 'pdf', ...
    'EdgeColor', 'none', 'FaceColor', cm(9, :), ...
    'FaceAlpha', 1, 'LineWidth', p.line.width);

hold on;
plot(-1.7:0.01:1.7, bf_gain_pd.pdf(-1.7:0.01:1.7), 'LineWidth', p.line.width, 'Color', cm(10, :));

xlim([-1.7, 1.7]);
ylim([0, 9]);

hl3 = legend('Histogram', 'Gumbel fit', 'Location', 'northeast');
hl3.FontName = p.font.face;
hl3.FontSize = p.font.size;
hl3.EdgeColor = 'none';

hold off;

grid on;
hxl5 = xlabel('Beamformer gain offset from nominal [dB]');
hyl5 = ylabel('Probability density [1/dB]');

text(handle_fig5.CurrentAxes, 0.037, 0.965, ["\mu", "\sigma"], ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'Units', 'normalized', 'BackgroundColor', 'w');
text(handle_fig5.CurrentAxes, 0.067, 0.965, sprintf('= %.2f dB (%.2f\\leftrightarrow%.2f)\n= %.2f dB (%.2f\\leftrightarrow%.2f)', ...
    abs(bf_gain_pd.mu), ...
    bf_gain_fit_ci(1, 1), ...
    bf_gain_fit_ci(2, 1), ...
    bf_gain_pd.sigma, ...
    bf_gain_fit_ci(1, 2), ...
    bf_gain_fit_ci(2, 2)), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'BackgroundColor', 'w');

%% Plot beamforming histogram
% Initialize.
p = plt.settings();
handle_fig6 = figure('Units', 'centimeters', 'Position', [15, 5, p.width, p.height]);

cm = third.brewermap(12, 'Paired');

plot(-1.7:0.01:1.7, bf_fit_gain_pd.pdf(-1.7:0.01:1.7), 'LineWidth', p.line.width, 'Color', cm(10, :));

xlim([-1.7, 1.7]);
ylim([0, 18]);

hl4 = legend('Normal distr.', 'Location', 'northeast');
hl4.FontName = p.font.face;
hl4.FontSize = p.font.size;
hl4.EdgeColor = 'none';

hold off;

grid on;
hxl6 = xlabel('Beamformer gain offset from nominal [dB]');
hyl6 = ylabel('Probability density [1/dB]');

text(handle_fig6.CurrentAxes, 0.037, 0.965, ["\mu", "\sigma"], ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'Units', 'normalized', 'BackgroundColor', 'w');
text(handle_fig6.CurrentAxes, 0.067, 0.965, sprintf('= %.2f dB\n= %.2f dB', ...
    abs(bf_fit_gain_pd.mu), ...
    bf_fit_gain_pd.sigma), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Units', 'normalized', 'BackgroundColor', 'w');

%% Format/export all plots
% Make sure plotting area is the same for both plots, also setup fonts etc.
plt.format([handle_fig1, handle_fig2, handle_fig3, handle_fig4, handle_fig5, handle_fig6]);

% Add space for colorbar
handle_fig1.CurrentAxes.Position = handle_fig1.CurrentAxes.Position - [0 0 1.2 0];
hc1.Units = 'centimeters';
hc1.Position = [handle_fig1.CurrentAxes.Position(1) + handle_fig1.CurrentAxes.Position(3) + 0.1, ...
    handle_fig1.CurrentAxes.Position(2), 0.2, handle_fig1.CurrentAxes.Position(4)];

handle_fig2.CurrentAxes.Position = handle_fig2.CurrentAxes.Position - [0 0 1.2 0];
hc2.Units = 'centimeters';
hc2.Position = [handle_fig2.CurrentAxes.Position(1) + handle_fig2.CurrentAxes.Position(3) + 0.1, ...
    handle_fig2.CurrentAxes.Position(2), 0.2, handle_fig2.CurrentAxes.Position(4)];

% Adjust placement of colorbar label so it is uniform for both plots
hcy1.Units = 'centimeters';
hcy2.Units = 'centimeters';
drawnow;
hcy2.Position(1) = hcy1.Position(1);

% Adjust placement of y labels to also make them uniform
hyl1.Units = 'centimeters';
hyl2.Units = 'centimeters';
hyl3.Units = 'centimeters';
hyl4.Units = 'centimeters';
hyl5.Units = 'centimeters';
hyl6.Units = 'centimeters';
drawnow;

yx = min([hyl1.Position(1), hyl2.Position(1), hyl3.Position(1), hyl4.Position(1), hyl5.Position(1), hyl6.Position(1)]);
hyl1.Position(1) = yx;
hyl2.Position(1) = yx;
hyl3.Position(1) = yx;
hyl4.Position(1) = yx;
hyl5.Position(1) = yx;
hyl6.Position(1) = yx;

% Same for x labels
hxl1.Units = 'centimeters';
hxl2.Units = 'centimeters';
hxl3.Units = 'centimeters';
hxl4.Units = 'centimeters';
hxl5.Units = 'centimeters';
hxl6.Units = 'centimeters';
drawnow;

xy = min([hxl1.Position(2), hxl2.Position(2), hxl3.Position(2), hxl4.Position(2), hxl5.Position(2), hxl6.Position(2)]);
hxl1.Position(2) = xy;
hxl2.Position(2) = xy;
hxl3.Position(2) = xy;
hxl4.Position(2) = xy;
hxl5.Position(2) = xy;
hxl6.Position(2) = xy;

% Adjust placement of legend
hl1.Position(1) = hl1.Position(1) + 0.022;
hl1.Position(2) = 0.804;
hl2.Position(1) = hl2.Position(1) + 0.022;
hl2.Position(2) = 0.804;
hl3.Position(1) = hl3.Position(1) + 0.022;
hl3.Position(2) = 0.804;
hl4.Position(1) = hl4.Position(1) + 0.022;
hl4.Position(2) = 0.804 + 0.0545;

% Export as PDF
plt.export(handle_fig1, 'fig1_sensitivity');
plt.export(handle_fig2, 'fig2_phase');
plt.export(handle_fig3, 'fig3_sensitivity_histogram');
plt.export(handle_fig4, 'fig4_phase_histogram');
plt.export(handle_fig5, 'fig5_beamforming');
plt.export(handle_fig6, 'fig6_beamforming_fit');