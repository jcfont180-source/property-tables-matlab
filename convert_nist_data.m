% =========================================================================
% Project:     Interactive Water T-v Diagram & Property Analyzer
% Author:      Juan Fontalvo
% Course:      ENES 206, Montgomery College (final project)
%
% Description: Builds water_saturation_table.csv for the main program.
%              Merges the raw NIST saturated liquid and vapor tables and
%              converts them from molar units to mass units.
% =========================================================================
clear; clc;

% Molar mass of water
M_kg = 0.01801528;   % kg/mol
M_g  = 18.01528;     % g/mol

% One file per phase. readmatrix skips the header and turns 'undefined' into NaN.
% NIST columns: 1 T (K), 2 P (MPa), 3 density, 4 volume, 5 u, 6 h, 7 s
liq = readmatrix('nist_liquid.txt', 'FileType', 'text');
vap = readmatrix('nist_vapor.txt',  'FileType', 'text');

P_MPa = liq(:, 2);
P_kPa = P_MPa * 1000;
T_K   = liq(:, 1);
T_C   = T_K - 273.15;

% L/mol -> m^3/kg
vf_m3kg = liq(:, 4) / M_g;
vg_m3kg = vap(:, 4) / M_g;

% kJ/mol -> kJ/kg
uf_kJkg  = liq(:, 5) / M_kg;
ug_kJkg  = vap(:, 5) / M_kg;
hf_kJkg  = liq(:, 6) / M_kg;
hg_kJkg  = vap(:, 6) / M_kg;
hfg_kJkg = hg_kJkg - hf_kJkg;

% J/(mol*K) -> kJ/(kg*K)
sf_kJkgK = liq(:, 7) / M_g;
sg_kJkgK = vap(:, 7) / M_g;

clean_table = table(P_kPa, P_MPa, T_K, T_C, vf_m3kg, vg_m3kg, ...
                    uf_kJkg, ug_kJkg, hf_kJkg, hg_kJkg, hfg_kJkg, ...
                    sf_kJkgK, sg_kJkgK);

writetable(clean_table, 'water_saturation_table.csv');
fprintf('Successfully created water_saturation_table.csv with %d rows!\n', height(clean_table));
