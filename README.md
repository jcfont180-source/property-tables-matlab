# Water T-v Diagram & Property Analyzer (MATLAB)

My final project for ENES 206 at Montgomery College.

You enter a pressure, and the program interpolates saturated water properties from a NIST table. Then you give it six specific volumes inside the saturation dome, and it works out the quality of each state and which side of the dome it's on. At the end it plots the T-v diagram with your states, plus latent heat and specific volume trends.

## Files

- `water_tv_diagram.m`: main program
- `water_saturation_table.csv`: saturated water table, from 0.61 kPa up to the critical point (22,064 kPa)
- `convert_nist_data.m`: the script that built the CSV from the raw NIST liquid and vapor tables (the raw files aren't included)

## How to run

Open this folder in MATLAB (R2019a or newer, for `readmatrix`), run `water_tv_diagram`, and answer the prompts.

## Data

Saturation properties from the [NIST Chemistry WebBook](https://webbook.nist.gov/chemistry/fluid/), converted from molar to mass units.
