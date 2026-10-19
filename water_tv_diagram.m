% =========================================================================
% Project:     Interactive Water T-v Diagram & Property Analyzer
% Author:      Juan Fontalvo
% Course:      ENES 206, Montgomery College (final project)
%
% Description: Asks for a pressure, interpolates saturated water properties
%              from a NIST table, then takes six specific volumes inside
%              the saturation dome and finds the quality of each one.
%              Plots the T-v diagram with those states, plus h_fg and
%              v_f/v_g trends.
% =========================================================================
clear; clc; close all;

%% 1. DATA IMPORT & SETUP
data = readmatrix('water_saturation_table.csv');   % skips the header row

P_table     = data(:, 1);   % kPa
T_sat_table = data(:, 4);   % °C
v_f_table   = data(:, 5);   % m^3/kg
v_g_table   = data(:, 6);   % m^3/kg
h_fg_table  = data(:, 11);  % kJ/kg

P_min = min(P_table);
P_max = max(P_table);       % critical point

% The table jumps from 0.6 to 37 kPa in one step, so interpolate in ln(P).
% 1/T and ln(v_g) are close to straight lines in ln(P), which keeps it accurate.
lnP    = log(P_table);
T_at   = @(P) 1 ./ interp1(lnP, 1 ./ (T_sat_table + 273.15), log(P), 'pchip') - 273.15;
vf_at  = @(P) interp1(lnP, v_f_table, log(P), 'pchip');
vg_at  = @(P) exp(interp1(lnP, log(v_g_table), log(P), 'pchip'));
hfg_at = @(P) interp1(lnP, h_fg_table, log(P), 'pchip');

%% 2. USER INPUT & ERROR HANDLING (PRESSURE)
fprintf('=== Saturated Water Property & T-v Diagram Tool ===\n');
fprintf('Valid pressure range: %g kPa to %g kPa (critical point, not included)\n\n', P_min, P_max);

P_user = input('Enter the desired pressure P (in kPa): ');

% At the critical point v_f = v_g, so there's no dome left to put states in
while isempty(P_user) || ~isnumeric(P_user) || ~isscalar(P_user) || isnan(P_user) || ...
        P_user < P_min || P_user >= P_max
    fprintf('Error: Please enter a single number from %g kPa up to (not including) %g kPa.\n', P_min, P_max);
    P_user = input('Enter the desired pressure P (in kPa): ');
end

%% 3. PROPERTY INTERPOLATION
T_sat = T_at(P_user);
v_f   = vf_at(P_user);
v_g   = vg_at(P_user);
h_fg  = hfg_at(P_user);

fprintf('\n--- Interpolated Saturation Properties at P = %g kPa ---\n', P_user);
fprintf('Saturation Temperature (T_sat) : %.2f °C\n', T_sat);
fprintf('Saturated Liquid Volume (v_f)  : %.6f m^3/kg\n', v_f);
fprintf('Saturated Vapor Volume (v_g)   : %.6f m^3/kg\n', v_g);
fprintf('Latent Heat (h_fg)             : %.2f kJ/kg\n\n', h_fg);

%% 4. SIX STATES INSIDE THE SATURATION DOME
num_states = 6;
v_states   = zeros(1, num_states);
T_states   = ones(1, num_states) * T_sat;   % T stays at T_sat inside the dome
x_states   = zeros(1, num_states);

fprintf('Enter %d specific volume (v) values inside the dome (between %.6f and %.6f m^3/kg):\n', ...
    num_states, v_f, v_g);

for i = 1:num_states
    v_in = input(sprintf('  State %d specific volume v (m^3/kg): ', i));

    while isempty(v_in) || ~isnumeric(v_in) || ~isscalar(v_in) || isnan(v_in) || ...
            v_in < v_f || v_in > v_g
        fprintf('  Invalid value! To stay inside the dome, v must be between %.6f and %.6f m^3/kg.\n', v_f, v_g);
        v_in = input(sprintf('  State %d specific volume v (m^3/kg): ', i));
    end

    v_states(i) = v_in;
    x_states(i) = (v_in - v_f) / (v_g - v_f);   % quality

    if x_states(i) < 0.5
        side_label = 'Saturated Liquid Side (x < 0.5)';
    elseif x_states(i) > 0.5
        side_label = 'Saturated Vapor Side (x > 0.5)';
    else
        side_label = 'Exact Midpoint (x = 0.5)';
    end

    fprintf('    -> Quality x = %.3f | Location: %s\n', x_states(i), side_label);
end

%% 5. PLOT 1: T-v DIAGRAM
% Dome comes from the same interpolation, so the isobar ends land right on it
P_dome  = logspace(log10(P_min), log10(P_max), 300);
T_dome  = T_at(P_dome);
vf_dome = vf_at(P_dome);
vg_dome = vg_at(P_dome);

figure('Name', 'T-v Diagram for Water', 'NumberTitle', 'off');
hold on;

plot(vf_dome, T_dome, 'b-', 'LineWidth', 2, 'DisplayName', 'Saturated Liquid Line (v_f)');
plot(vg_dome, T_dome, 'r-', 'LineWidth', 2, 'DisplayName', 'Saturated Vapor Line (v_g)');
plot(v_f_table(end), T_sat_table(end), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 7, 'DisplayName', 'Critical Point');
plot([v_f, v_g], [T_sat, T_sat], 'k--', 'LineWidth', 1.5, 'DisplayName', sprintf('Isobar at P = %g kPa', P_user));

liq_idx = x_states < 0.5;
vap_idx = x_states >= 0.5;

if any(liq_idx)
    scatter(v_states(liq_idx), T_states(liq_idx), 70, 'b', 'filled', 'o', 'DisplayName', 'User States (Liquid Side)');
end
if any(vap_idx)
    scatter(v_states(vap_idx), T_states(vap_idx), 70, 'r', 'filled', 's', 'DisplayName', 'User States (Vapor Side)');
end

% Log scale so the liquid side of the dome isn't squished against the axis
set(gca, 'XScale', 'log');
xlabel('Specific Volume, v (m^3/kg) [Log Scale]');
ylabel('Temperature, T (°C)');
title(sprintf('Water T-v Diagram with User States at P = %g kPa (T_{sat} = %.2f °C)', P_user, T_sat));
legend('Location', 'best');
grid on;
hold off;

%% 6. PLOT 2: PROPERTY TRENDS
figure('Name', 'Thermodynamic Property Relationships', 'NumberTitle', 'off');

% h_fg drops to zero at the critical point
subplot(1, 2, 1);
plot(T_sat_table, h_fg_table, 'm-o', 'LineWidth', 2);
hold on;
plot(T_sat, h_fg, 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 12);
xlabel('Saturation Temperature, T_{sat} (°C)');
ylabel('Latent Heat of Vaporization, h_{fg} (kJ/kg)');
title('Latent Heat vs. Saturation Temperature');
legend('Table Curve', 'User Pressure Point', 'Location', 'southwest');
grid on;
hold off;

% v_f and v_g close in on each other until they meet at the critical point
subplot(1, 2, 2);
loglog(P_table, v_g_table, 'r-s', 'LineWidth', 2, 'DisplayName', 'Vapor (v_g)');
hold on;
loglog(P_table, v_f_table, 'b-o', 'LineWidth', 2, 'DisplayName', 'Liquid (v_f)');
loglog(P_user, v_g, 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 10, 'DisplayName', 'User P');
loglog(P_user, v_f, 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 10, 'HandleVisibility', 'off');
xlabel('Saturation Pressure, P (kPa) [Log Scale]');
ylabel('Specific Volume, v (m^3/kg) [Log Scale]');
title('Specific Volume Convergence (Log-Log)');
legend('Location', 'best');
grid on;
hold off;
