function lidar
% lidar produces an animation of LiDAR functionality.
%
% Syntax: lidar
%
% Inputs:
%   none
%
% Outputs:
%   animated GIF
%
% Examples:
%   lidar
%
% Other m-files required: none, but requires imagemagick to produce the
%                         animated GIF. Runs on Ubuntu 20.04.
% Subfunctions: 
%               
% MAT-files required: none
%
% See also: tcspc

% Jakub Nedbal
% King's College London
% Oct 2020
% Last Revision:  03-Oct-2020 - First working prototype
%
% Copyright 2020 Jakub Nedbal
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



% Some constants setting up the simulation
lidarPhotons = 2000;        % Number of LiDAR photons
backgroundPhotons = 1000;   % Number of background photons
lidarTime = 66;             % Center of the LiDAR peak (nanoseconds)
TDCrange = 100;             % Range of the TDC (nanoseconds)

% Create a vector of photons that are mixture of LiDAR reflections and
% background light
phots = [randn(1, lidarPhotons) + lidarTime, ...    % LiDAR photons
         TDCrange * rand(1, backgroundPhotons)];    % Background photons
% Randomly reshuffle these photons
phots = phots(randperm(numel(phots)));
% Add photons that are fixed at the beginning
startPhots = [NaN, ...                       % nothing happens
              -rand(1, 6) * TDCrange, ...    % six background photons
              rand(1, 2) * TDCrange, ...     % two DCR events 
              NaN(1, 2)];                    % two nothing happens events
% Add lidar photons
lidarPhots = randn(1, 7) + lidarTime;        % Seven LIDAR photons
% Combine the fixed photon events and the random photon events
phots = [startPhots, lidarPhots, phots];
% Round the photon arrival times to nanoseconds
phots = round(phots);

% Colors in RGB format
% Laser color
colLaser = [220, 50, 30] / 255;
% Turned off laser color
colLaserOff = [90, 90, 90] / 255;
% Background photon color
colBack = [0, 90, 181] / 255;
% SPAD diode color
colDiode = [255, 194, 10] / 255;
% Dark version of SPAD diode color
colDiodeDark = mean([colDiode; colDiode; [0 0 0]]);
% Matrix of oscillating SPAD diode colors
colDiodeOsc = colDiode' .* (0.5 + 0.5 * cos((0 : 0.2 : 1.8) * pi)) + ...
              colDiodeDark' .* (0.5 - 0.5 * cos((0 : 0.2 : 1.8) * pi));

% Microtime histogram
t = 0 : TDCrange;

% Position of axes in the figure
axPos = [ 80, 80, 400, 250; ...
         600, 80, 400, 250; ...
         550,  0, 500, 400];

%% Figure to display the animations
close all
figure('Units', 'pixels', ...
       'Position', [100, 100, 1050, 400], ...
       'PaperPositionMode', 'auto', ...
       'InvertHardCopy', 'off', ...
       'Color', 'w');

%% Create axes for microtime simulation
ax2 = axes('Units', 'Pixels', ...
           'Position', axPos(2, :), ...
           'XLim', [0, TDCrange], ...
           'Box', 'on', ...
           'XTick', [], ...
           'YTick', []);
ax2.YScale = 'log';             % Logarithmic Y-axis
% Label the axes
xlabel('Microtime {\itt} [ns]', 'FontSize', 24)
ylabel('Log Probability', 'FontSize', 24)
title('Photon Density', 'FontSize', 24)
hold on

% Empty vector for the photon probability density
dec = zeros(size(t));
% Empty area with the photon probability density
Dh(2) = area(t, dec);
% Set the area color
set(Dh(2), 'EdgeColor', 'none', 'FaceColor', [0.5 1 0.5]);
% Make a darker color outline
Dh(1) = plot(t, dec, 'Color', [0 0.7 0], 'LineWidth', 2);
% Set the Ylimits for the axes
set(ax2, 'YLim', [0 1])

%% Draw a photodiode
% Below are empirical coordinates of vectors making up the SPAD diode
spad.x = [50, 50, 38, 50, 38, 50, 50, 50, 62, 50, 62, 50, 50];
spad.y = [0, 30, 30, 68, 68, 68, 100, 68, 68, 68, 30, 30, 0];
spad.arrow1.x = [67, 70.5, 71.25, 87, 71.25, 72.0, 65];
spad.arrow1.y = [59, 66, 63, 78, 63, 60, 59];
spad.arrow2.y = spad.arrow1.y - 16;
% Create axes for the SPAD diode
ax.spad = axes('Units', 'Pixels', ...
               'Position', [axPos(1, [1 2]) + [-40, 173], 86, 47]);
% Draw the SPAD diode
spad.diode = fill(spad.x, spad.y, 'c');
% Set the parameters of the SPAD diode patch
spad.diode.LineWidth = 2;
spad.diode.FaceColor = 'k';
spad.diode.EdgeColor = 'k';
hold on
% Add an arrow to the SPAD diode symbol
spad.arrow1f = fill(spad.arrow1.x, spad.arrow1.y, 'c');
spad.arrow1f.LineWidth = 2;
spad.arrow1f.FaceColor = 'k';
spad.arrow1f.EdgeColor = 'k';
% Add an second arrow to the SPAD diode symbol
spad.arrow2f = fill(spad.arrow1.x, spad.arrow2.y, 'c');
spad.arrow2f.LineWidth = 2;
spad.arrow2f.FaceColor = 'k';
spad.arrow2f.EdgeColor = 'k';
% Hide the axes and set their limits for consistent display
ax.spad.XAxis.Visible = 'off';
ax.spad.YAxis.Visible = 'off';
ax.spad.Color = 'none';
ax.spad.XLim = [0 100];
ax.spad.YLim = [0 100];
% Add title to the SPAD axes
spad.title = title('SPAD', 'FontSize', 24);

%% Draw a laser diode
% Below are empirical coordinates of vectors making up the laser diode
laser.x = spad.x;
laser.y = 100 - spad.y;
laser.arrow1.x = [30, 70, 70, 74, 70, 70, 30];
laser.arrow1.y = [50, 50, 53, 50, 47, 50, 50] + 1;
% Create axes for the laser diode
ax.laser = axes('Units', 'Pixels', ...
                'Position', [axPos(1, [1 2]) + [-40, 52], 86, 47]);
% Draw the laser diode
laser.diode = fill(laser.x, laser.y, 'c');
% Set the parameters of the laser diode patch
laser.diode.LineWidth = 2;
laser.diode.FaceColor = colLaserOff;
laser.diode.EdgeColor = colLaserOff;
hold on
% Add an arrow to the laser diode symbol
laser.arrowf = fill(laser.arrow1.x, laser.arrow1.y, 'c');
laser.arrowf.LineWidth = 2;
laser.arrowf.FaceColor = colLaserOff;
laser.arrowf.EdgeColor = colLaserOff;
% Hide the axes and set their limits for consistent display
ax.laser.XAxis.Visible = 'off';
ax.laser.YAxis.Visible = 'off';
ax.laser.Color = 'none';
ax.laser.XLim = [0 100];
ax.laser.YLim = [0 100];
% Add title to the laser diode axes
title('Laser', 'FontSize', 24)
hx = xlabel('OFF', 'FontSize', 24);
hx.Visible = 'on';
hx.Position(2) = hx.Position(2) - 5;    % Move the label up a little

%% Create axes for the animation of photons in the LiDAR
ax1 = axes('Units', 'Pixels', ...
           'Position', axPos(1, :), ...
           'XLim', [0 TDCrange], ...
           'YLim', [0 1], ...
           'Box', 'off', ...
           'YTick', [], ...
           'FontSize', 24, ...
           'XTick', [], ...
           'XColor', 'w', ...
           'YColor', 'w');
% Add lidar axes title
title('LIDAR', 'FontSize', 24)
hold on
% Plot an object for LiDAR reflection
plot(90 * [1, 1], [0.35, 0.75], 'k', 'LineWidth', 4)
% Label the object
text(90, 0.80, 'Object', ...
     'FontSize', 24, 'FontWeight', 'bold', ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
% Get the handle of the X axis label for later description of the events
hmsg = xlabel('', 'FontSize', 24, 'Color', 'k');
% Move the axes to the bottom so it does not obstruct other objects in the
% figure
uistack(ax1, 'bottom')

%% Plot laser photons
% Work out photon locations in the animations
photon.path = [axPos(1, 1); axPos(1, 2)] + ...
              [linspace(30, 320, 4), linspace(320, 30, 4); ...
               linspace(37, 98, 4), linspace(98, 155, 4)];
% Remove the duplicate photon
photon.path(:, 4) = [];
% Simulate a photon as a harmonic function with Gaussian envelope
% X coordinates of the photon trace
photon.time = -6 * pi : pi / 10 : 6 * pi;
% Y coordinates of the photon trace
% Product of harmonic and Gaussian functions
photon.shape = sin(photon.time) .* ...
               exp(-photon.time .^ 2 / ((photon.time(end) / 2.5) ^ 2));
% Draw the photons in their individual small axes
for i = 1 : size(photon.path, 2)
    % Create small axes for each photon
    ax.photon(i) = ...
        axes('Units', 'Pixels', ...
             'Position', [photon.path(1, i), photon.path(2, i), 80, 80]);
    % Plot each photon trace
    photon.handle(i) = plot(photon.time, photon.shape, ...
                            'Color', colLaser, 'LineWidth', 2);
    % Hide and scale the axes
    ax.photon(i).XLim = photon.time([1, end]);
    ax.photon(i).Visible = 'off';
    photon.handle(i).Visible = 'off';
end

%% Plot background photons
% Work out photon locations in the animations
background.path = [axPos(1, 1); axPos(1, 2)] + ...
                  [linspace(900, 30, 10); ...
                   ones(1, 10) * 155];
% Draw the photons in their individual small axes
for i = 1 : size(background.path, 2)
    % Create small axes for each photon
    ax.background(i) = ...
        axes('Units', 'Pixels', ...
        'Position', [background.path(1, i), background.path(2, i), 80,80]);
    % Plot each photon trace
    background.handle(i) = plot(photon.time, photon.shape, ...
                                'Color', colBack, 'LineWidth', 2);
    % Hide and scale the axes
    ax.background(i).XLim = photon.time([1, end]);
    ax.background(i).Visible = 'off';
    background.handle(i).Visible = 'off';
end

%% Create white axes behind which the background photons, which would
% obstruct the photon density map graph, are hidden
axes('Units', 'Pixels', ...
     'Position', axPos(3, :), ...
     'YColor', 'w', 'XColor', 'w', 'Box', 'off');
 % Bring the photon density map axes to the top
uistack(ax2, 'top')


%% Start the animation
% u and v are incides sorting the images
u = 0; v = 0;
% Create a first snapshot of the animation
print(gcf, sprintf('lidar%02d_%03d.png', v, u), '-dpng', '-r100');

% Run the animation for the initial back of events
for k = 1 : numel(startPhots)
    v = v + 1;
    % If the event is "nothing happens"
    if isnan(phots(k))  % Nothing happens
        % Label the LiDAR graph "No SPAD Activity"
        hmsg.String = 'No SPAD Activity';
        % Save 10 frames on no activity
        for u = 1 : 10
            print(gcf, sprintf('lidar%02d_%03d.png', v, u), '-dpng', '-r100');
            if u == 8
                %hmsg.String = '';
            end
        end
    end

    % If the event is negative, meaning a background photon
    if phots(k) < 0     % Background photon
        % Label the LiDAR graph "Background Photon"
        hmsg.String = 'Background Photon';
        % Run through 10 frames of the animation
        for u = 1 : 10
            % Calculate which is the current photon in the animation to
            % display
            curPhot = 9 + floor(phots(k) / 10) + u;
            % switch on the current photon
            if curPhot <= numel(background.handle) && curPhot > 0
                % Display the photon
                background.handle(curPhot).Visible = 'on';
            end
            % switch off the previous photon, left over from the last frame
            if curPhot - 1 <= numel(background.handle) && curPhot - 1 > 0
                % Hide the photon
                background.handle(curPhot - 1).Visible = 'off';
            end
            % If the current photon is the last photon in the set
            if curPhot == numel(background.handle)
                % Add another event to the photon probability trace
                dec = dec + exp(-((t + phots(k)) .^ 2) / (0.05));
                % Update the graph with the latest event
                set(Dh, 'YData', dec);
                % Scale the Y axis acordingly
                ax2.YLim = [0.1, max(dec) * 1.1];
                % Flash the SPAD
                spad.diode.FaceColor = colDiode;
                spad.diode.EdgeColor = colDiode;
                spad.arrow1f.FaceColor = colDiode;
                spad.arrow1f.EdgeColor = colDiode;
                spad.arrow2f.FaceColor = colDiode;
                spad.arrow2f.EdgeColor = colDiode;
                spad.title.Color = colDiode;
            end
            % Save the frame
            print(gcf, sprintf('lidar%02d_%03d.png', v, u), ...
                  '-dpng', '-r100');
            if u == 8
                %hmsg.String = '';
            end
            
            % Darken the SPAD, so it always turn black after every frame
            spad.diode.FaceColor = 'k';
            spad.diode.EdgeColor = 'k';
            spad.arrow1f.FaceColor = 'k';
            spad.arrow1f.EdgeColor = 'k';
            spad.arrow2f.FaceColor = 'k';
            spad.arrow2f.EdgeColor = 'k';
            spad.title.Color = 'k';
        end
        % Hide any background photons shown
        set(background.handle, 'Visible', 'off')
    end
    
    % If the event is positive, meaning a dark count event
    if phots(k) > 0     % DCR event
        % Label the LiDAR graph "Dark Count"
        hmsg.String = 'Dark Count';
        % Run through 10 frames of the animation
        for u = 1 : 10
            % Add an event at the appropriate time
            if ceil(phots(k) / 10) == u
                % Add another event to the photon probability trace
                dec = dec + exp(-((t - phots(k)) .^ 2) / (0.05));
                % Update the graph with the latest event
                set(Dh, 'YData', dec);
                % Scale the Y axis acordingly
                ax2.YLim = [0.1, max(dec) * 1.1];
                % Flash the SPAD
                spad.diode.FaceColor = colDiode;
                spad.diode.EdgeColor = colDiode;
                spad.arrow1f.FaceColor = colDiode;
                spad.arrow1f.EdgeColor = colDiode;
                spad.arrow2f.FaceColor = colDiode;
                spad.arrow2f.EdgeColor = colDiode;
                spad.title.Color = colDiode;
            end
            % Save the frame
            print(gcf, sprintf('lidar%02d_%03d.png', v, u), ...
                  '-dpng', '-r100');
            if u == 8
                %hmsg.String = '';
            end
            
            % Darken the SPAD, so it always turn black after every frame
            spad.diode.FaceColor = 'k';
            spad.diode.EdgeColor = 'k';
            spad.arrow1f.FaceColor = 'k';
            spad.arrow1f.EdgeColor = 'k';
            spad.arrow2f.FaceColor = 'k';
            spad.arrow2f.EdgeColor = 'k';
            spad.title.Color = 'k';
        end
    end
end

%% LIDAR only demonstration
% Label the LiDAR graph "LIDAR Action"
hmsg.String = 'LIDAR Action';
% Give the laser diode the red color to make it look like it is turned on
laser.diode.FaceColor = colLaser;
laser.diode.EdgeColor = colLaser;
laser.arrowf.FaceColor = colLaser;
laser.arrowf.EdgeColor = colLaser;
hx.Color = colLaser;
% Switch the laser diode label to "ON"
hx.String = 'ON';
% Go through each LiDAR photon
for k = k + (1 : numel(lidarPhots))
    v = v + 1;
    % Run through 10 frames of the animation
    for u = 1 : 10
        % switch on the current photon
        if u <= numel(photon.handle)
            photon.handle(u).Visible = 'on';
        end
        % switch off the previous photon
        if u - 1 <= numel(photon.handle) && u > 1
            photon.handle(u - 1).Visible = 'off';
        end
        % Add an event at the appropriate time
        if ceil(phots(k) / 10) == u
            % Add another event to the photon probability trace
            dec = dec + exp(-((t - phots(k)) .^ 2) / (0.05));
            % Update the graph with the latest event
            set(Dh, 'YData', dec);
            % Scale the Y axis acordingly
            ax2.YLim = [0.1, max(dec) * 1.1];
            % Flash the SPAD
            spad.diode.FaceColor = colDiode;
            spad.diode.EdgeColor = colDiode;
            spad.arrow1f.FaceColor = colDiode;
            spad.arrow1f.EdgeColor = colDiode;
            spad.arrow2f.FaceColor = colDiode;
            spad.arrow2f.EdgeColor = colDiode;
            spad.title.Color = colDiode;
        end
        if u == 8 && k == 18
            %hmsg.String = '';
        end
        % Save the frame
        print(gcf, sprintf('lidar%02d_%03d.png', v, u), '-dpng', '-r100');

        % Darken the SPAD
        spad.diode.FaceColor = 'k';
        spad.diode.EdgeColor = 'k';
        spad.arrow1f.FaceColor = 'k';
        spad.arrow1f.EdgeColor = 'k';
        spad.arrow2f.FaceColor = 'k';
        spad.arrow2f.EdgeColor = 'k';
        spad.title.Color = 'k';
    end
end


%% Fast forward LIDAR demonstration
hmsg.String = 'Fast Forward';
v = v + 1;
u = 0;
% Go through the next hundred events
for k = k + (1 : 100)
    u = u + 1;
    % Add another event to the photon probability trace
    dec = dec + exp(-((t - phots(k)) .^ 2) / (0.05));
    % Update the graph with the latest event
    set(Dh, 'YData', dec);
    % Scale the Y axis acordingly
    ax2.YLim = [0.1, max(dec) * 1.1];
    % Update the SPAD color. The color is from a lookup table, which is
    % harmonically socillating between light and dark yellow to give an
    % imrpession of high SPAD activity.
    spad.diode.EdgeColor = colDiodeOsc(:,mod(u, size(colDiodeOsc, 2)) + 1);
    spad.diode.FaceColor = spad.diode.EdgeColor;
    spad.arrow1f.EdgeColor = spad.diode.EdgeColor;
    spad.arrow1f.FaceColor = spad.diode.EdgeColor;
    spad.arrow2f.EdgeColor = spad.diode.EdgeColor;
    spad.arrow2f.FaceColor = spad.diode.EdgeColor;
    spad.title.Color = spad.diode.EdgeColor;
    % Alternate the visible photons to give the impression of activity
    if mod(u, 2)
        set(photon.handle(1 : 2 : end), 'Visible', 'on')
        set(photon.handle(2 : 2 : end), 'Visible', 'off')
        set(background.handle(1 : 2 : end), 'Visible', 'on')
        set(background.handle(2 : 2 : end), 'Visible', 'off')
    else
        set(photon.handle(2 : 2 : end), 'Visible', 'on')
        set(photon.handle(1 : 2 : end), 'Visible', 'off')
        set(background.handle(2 : 2 : end), 'Visible', 'on')
        set(background.handle(1 : 2 : end), 'Visible', 'off')
    end
    % Hide the label "Fast forward" at event 100
    if k == 100
        hmsg.String = '';
    end
    % Save the frame
    print(gcf, sprintf('lidar%02d_%03d.png', v, u), '-dpng', '-r100');
end


%% Further fast forward LIDAR demonstration
% Label the LiDAR graph "Fast Forward"
hmsg.String = 'Fast Forward';
v = v + 1;
u = 0;
% Go through the remaining events
for k = k : numel(phots)
    % Add another event to the photon probability trace
    dec = dec + exp(-((t - phots(k)) .^ 2) / (0.05));
    % Update the graph with the latest event
    set(Dh, 'YData', dec);
    % Scale the Y axis acordingly
    ax2.YLim = [0.1, max(dec) * 1.1];
    % Save a frame only once every 100 events
    if mod(k, 100) == 0
        u = u + 1;
        % Update the SPAD color. The color is from a lookup table, which is
        % harmonically socillating between light and dark yellow to give an
        % imrpession of high SPAD activity.
        spad.diode.EdgeColor = ...
            colDiodeOsc(:, mod(u, size(colDiodeOsc, 2)) + 1);
        spad.diode.FaceColor = spad.diode.EdgeColor;
        spad.arrow1f.EdgeColor = spad.diode.EdgeColor;
        spad.arrow1f.FaceColor = spad.diode.EdgeColor;
        spad.arrow2f.EdgeColor = spad.diode.EdgeColor;
        spad.arrow2f.FaceColor = spad.diode.EdgeColor;
        spad.title.Color = spad.diode.EdgeColor;
        % Alternate the visible photons to give the impression of activity
        if mod(u, 2)
            set(photon.handle(1 : 2 : end), 'Visible', 'on')
            set(photon.handle(2 : 2 : end), 'Visible', 'off')
            set(background.handle(1 : 2 : end), 'Visible', 'on')
            set(background.handle(2 : 2 : end), 'Visible', 'off')
        else
            set(photon.handle(2 : 2 : end), 'Visible', 'on')
            set(photon.handle(1 : 2 : end), 'Visible', 'off')
            set(background.handle(2 : 2 : end), 'Visible', 'on')
            set(background.handle(1 : 2 : end), 'Visible', 'off')
        end        
        print(gcf, sprintf('lidar%02d_%03d.png', v, u), '-dpng', '-r100');
    end
    % Hide the label "Fast forward" once the 80% event has been reached
    if k == round(numel(phots) * 0.8)
        hmsg.String = '';
    end
end

%% Finalize the sequence
% Switch off the laser diode by making it dark gray
laser.diode.FaceColor = colLaserOff;
laser.diode.EdgeColor = colLaserOff;
laser.arrowf.FaceColor = colLaserOff;
laser.arrowf.EdgeColor = colLaserOff; %#ok<STRNU>
hx.Color = colLaserOff;
% Label the laser diode "OFF"
hx.String = 'OFF';
% Hide all photon traces
set(photon.handle, 'Visible', 'off')
set(background.handle, 'Visible', 'off')
% Update the SPAD color to black, meaning it is inactive
spad.diode.EdgeColor = 'k';
spad.diode.FaceColor = spad.diode.EdgeColor;
spad.arrow1f.EdgeColor = spad.diode.EdgeColor;
spad.arrow1f.FaceColor = spad.diode.EdgeColor;
spad.arrow2f.EdgeColor = spad.diode.EdgeColor;
spad.arrow2f.FaceColor = spad.diode.EdgeColor;
spad.title.Color = spad.diode.EdgeColor; %#ok<STRNU>
v = v + 1;
% Save ten frames of no activity
for u = 1 : 10
    print(gcf, sprintf('lidar%02d_%03d.png', v, u), '-dpng', '-r100');
end
% Store the first frame of the animation
copyfile('lidar00_000.png', 'lidar_start_animation.png');
% Store the last frame of the animation
copyfile('lidar21_010.png', 'lidar_finish_animation.png');

% Try to combine all the frames into animated GIFs. This will probably only
% work on Linux and maybe MAC OS X machines
try 
    % Create background photons animation
    unix(['convert -delay 20 -loop 1 ', ...
          'lidar0[2-7]_*.png lidar_background_photons_animation.gif']);
    % Create dark count animation
    unix(['convert -delay 20 -loop 1 ', ...
          'lidar0[8-9]_*.png lidar_dark_count_animation.gif']);
    % Create no action animation
    unix(['convert -delay 20 -loop 1 ', ...
          'lidar1[0-1]_*.png lidar_no_action_animation.gif']);
    % Create lidar only animation
    unix(['convert -delay 20 -loop 1 ', ...
          'lidar1[2-7]_*.png lidar_reflection_animation.gif']);
    % Create the full animation
    unix('convert -delay 20 -loop 1 lidar*.png lidar_animation.gif');

    % Remove the stack of PNG files with individual frames
    unix('rm lidar??_???.png');
catch
    error(['The animated GIF export routine does not work. ', ...
           'It requires Imagemagick installed. ', ...
           'It should work on Linux machines.'])
end

% The resulting animated files are not optimized for the best GIF
% compression. Attempts to do so using Imagemagick resulted in poor 
% overwriting of some of the photons in the animation. Instead optimization
% can be done reliably in GIMP.
% * Open the GIF file in GIMP. Go to "Image -> Mode -> Indexed...". 
% * In the window that pops up, press the "Convert" button leaving the 
%   default options in place.
% * Click to "Filters -> Animation -> Optimize (for GIF)". This opens a
%   new window with an image optimized for GIF.
% * Go to that window and export it to a new GIF file, using 
%   "File -> Export As...", making sure that "As Animation" is selected in 
%   the export dialog window.
% This creates a new GIF file that is compressed to a much smaller size 
% while containing the same animation.