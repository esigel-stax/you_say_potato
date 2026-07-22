version 10.1

clear matrix
capture clear
capture log close
set mem 100m
set matsize 5000
set more off

set scheme s2gmanual
*set scheme s1mono

log using "Replication_Europe_only_city_level_results.log", replace

use "Europe_only_city_level_panel_for_web.dta", clear

local ln_potato_flexible "ln_wpot_1000 ln_wpot_1200 ln_wpot_1300 ln_wpot_1400 ln_wpot_1500 ln_wpot_1600 ln_wpot_1700 ln_wpot_1750 ln_wpot_1800 ln_wpot_1850"
local ydum_flexible "ydum1000 ydum1200 ydum1300 ydum1400 ydum1500 ydum1600 ydum1700 ydum1750 ydum1800 ydum1850"
local ln_oworld_flexible "ln_oworld_1000 ln_oworld_1200 ln_oworld_1300 ln_oworld_1400 ln_oworld_1500 ln_oworld_1600 ln_oworld_1700 ln_oworld_1750 ln_oworld_1800 ln_oworld_1850"
local ln_tropics_flexible "ln_tropics_1000 ln_tropics_1200 ln_tropics_1300 ln_tropics_1400 ln_tropics_1500 ln_tropics_1600 ln_tropics_1700 ln_tropics_1750 ln_tropics_1800 ln_tropics_1850"
local ln_rugged_flexible "ln_rugged_1000 ln_rugged_1200 ln_rugged_1300 ln_rugged_1400 ln_rugged_1500 ln_rugged_1600 ln_rugged_1700 ln_rugged_1750 ln_rugged_1800 ln_rugged_1850"
local ln_elevation_flexible "ln_elevation_1000 ln_elevation_1200 ln_elevation_1300 ln_elevation_1400 ln_elevation_1500 ln_elevation_1600 ln_elevation_1700 ln_elevation_1750 ln_elevation_1800 ln_elevation_1850"

**************
* Conley SEs *
**************
gen cutoff1=5	/* Closer than cutoff = 1, further = 0 */
gen cutoff2=5
gen constant=1

********************************
*** Columns 6 & 7 of Table 8 ***
********************************

/* Baseline controls */
* Conley SEs
preserve
xi: areg ln_city_population i.year*ln_rugged i.year*ln_elevation i.year*ln_tropics i.year*ln_oworld, absorb(city)
predict ln_city_population_resid if e(sample)==1, resid
xi: areg ln_wpot_post i.year*ln_rugged i.year*ln_elevation i.year*ln_tropics i.year*ln_oworld, absorb(city)
predict ln_wpot_post_resid if e(sample)==1, resid
x_ols latitude longitude cutoff1 cutoff2 ln_city_population_resid constant ln_wpot_post_resid, xreg(2) coord(2)
restore
* Clustered SEs
xi: areg ln_city_population ln_wpot_post i.year*ln_rugged i.year*ln_elevation i.year*ln_tropics i.year*ln_oworld, absorb(city) cluster(isocode)


/* Baseline controls - country x year FEs */
* Conley SEs
preserve
xi: areg ln_city_population i.year*ln_rugged i.year*ln_elevation i.year*ln_tropics i.year*ln_oworld i.year*i.isocode, absorb(city)
predict ln_city_population_resid if e(sample)==1, resid
xi: areg ln_wpot_post i.year*ln_rugged i.year*ln_elevation i.year*ln_tropics i.year*ln_oworld  i.year*i.isocode, absorb(city)
predict ln_wpot_post_resid if e(sample)==1, resid
x_ols latitude longitude cutoff1 cutoff2 ln_city_population_resid constant ln_wpot_post_resid, xreg(2) coord(2)
restore
* Clustered SEs
xi: areg ln_city_population ln_wpot_post i.year*ln_rugged i.year*ln_elevation i.year*ln_tropics i.year*ln_oworld i.year*i.isocode, absorb(city) cluster(isocode)

log close


