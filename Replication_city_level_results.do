version 10.0

capture clear
clear matrix
capture log close

set mem 100m
set matsize 5000

set more off

set scheme s2gmanual
*set scheme s1mono

use "city_level_panel_for_web.dta", clear

gen cont_europe=0
replace cont_europe=1 if continent=="Europe"
gen cont_africa=0
replace cont_africa=1 if continent=="Africa"
gen cont_asia=0
replace cont_asia=1 if continent=="Asia"

foreach x in 1000 1100 1200 1300 1400 1500 1600 1700 1750 1800 1850 1900{
	gen ln_wpot_`x'=ln_wpot*ydum`x'
	gen ln_oworld_`x'=ln_oworld*ydum`x'
	gen ln_tropical_`x'=ln_tropics*ydum`x'
	gen ln_rugged_`x'=ln_rugged*ydum`x'
	gen ln_elevation_`x'=ln_elevation*ydum`x'
	gen cont_europe_`x'=cont_europe*ydum`x'
	gen cont_africa_`x'=cont_africa*ydum`x'
	gen cont_asia_`x'=cont_asia*ydum`x'
	}

local ln_potato_flexible "ln_wpot_1100 ln_wpot_1200 ln_wpot_1300 ln_wpot_1400 ln_wpot_1500 ln_wpot_1600 ln_wpot_1700 ln_wpot_1750 ln_wpot_1800 ln_wpot_1850 ln_wpot_1900"
local ln_oworld_flexible "ln_oworld_1100 ln_oworld_1200 ln_oworld_1300 ln_oworld_1400 ln_oworld_1500 ln_oworld_1600 ln_oworld_1700 ln_oworld_1750 ln_oworld_1800 ln_oworld_1850 ln_oworld_1900"
local ln_tropical_flexible "ln_tropical_1100 ln_tropical_1200 ln_tropical_1300 ln_tropical_1400 ln_tropical_1500 ln_tropical_1600 ln_tropical_1700 ln_tropical_1750 ln_tropical_1800 ln_tropical_1850 ln_tropical_1900"
local ln_rugged_flexible "ln_rugged_1100 ln_rugged_1200 ln_rugged_1300 ln_rugged_1400 ln_rugged_1500 ln_rugged_1600 ln_rugged_1700 ln_rugged_1750 ln_rugged_1800 ln_rugged_1850 ln_rugged_1900"
local ln_elevation_flexible "ln_elevation_1100 ln_elevation_1200 ln_elevation_1300 ln_elevation_1400 ln_elevation_1500 ln_elevation_1600 ln_elevation_1700 ln_elevation_1750 ln_elevation_1800 ln_elevation_1850 ln_elevation_1900"
local cont_europe_flexible "cont_europe_1100 cont_europe_1200 cont_europe_1300 cont_europe_1400 cont_europe_1500 cont_europe_1600 cont_europe_1700 cont_europe_1750 cont_europe_1800 cont_europe_1850 cont_europe_1900"
local cont_africa_flexible "cont_africa_1100 cont_africa_1200 cont_africa_1300 cont_africa_1400 cont_africa_1500 cont_africa_1600 cont_africa_1700 cont_africa_1750 cont_africa_1800 cont_africa_1850 cont_africa_1900"
local cont_asia_flexible "cont_asia_1100 cont_asia_1200 cont_asia_1300 cont_asia_1400 cont_asia_1500 cont_asia_1600 cont_asia_1700 cont_asia_1750 cont_asia_1800 cont_asia_1850 cont_asia_1900"

*******************
*** Regressions ***
*******************

log using "Replication_city_level_results.log", replace

* Conley SEs *
gen cutoff1=10	/* Closer than cutoff = 1, further = 0 */
gen cutoff2=10
gen constant=1

drop if missing(latitude)==1
drop if missing(longitude)==1
for @ in any ln_city_population ln_wpot_post year isocode continent: drop if missing(@)==1
for @ in any ln_rugged ln_elevation ln_tropics ln_oworld: drop if missing(@)==1

**************************************
*** TABLE 8 - City level estimates ***
**************************************

/* Column 1 - Baseline controls only */
* Conley SEs; num parms = 1 const + 694-1 city FE + 11 year FE + 1 wpot_post + 11*44 controls = 750 
*xi: x_ols latitude longitude cutoff1 cutoff2 ln_city_population constant ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year i.city, xreg(750) coord(2)
* Clustered SEs
xi: areg ln_city_population ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year, absorb(city) cluster(isocode)


/* Column 2 - Basline controls & continent x year FEs */
* Conley SEs; num parms = 1 const + 694-1 city FE + 11 year FE + 1 wpot_post + 11*4 controls + 11*(4-1) continent-year FE = 783 --- Had to do 2-step method
*preserve
*xi: reg ln_city_population           `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year*i.continent i.city
*predict ln_city_population_resid, resid
*xi: reg cutoff1 cutoff2 ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year*i.continent i.city
*predict ln_wpot_post_resid, resid
*x_ols latitude longitude cutoff1 cutoff2 ln_city_population_resid ln_wpot_post_resid, xreg(2) coord(2)
*restore 
* Clustered SEs
xi: areg ln_city_population ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year i.year*i.continent, absorb(city) cluster(isocode)

******************************************************
*** Baseline controls regressions - Omiting Europe ***
******************************************************

for @ in any ln_rugged ln_elevation ln_tropics ln_oworld: drop if missing(@)==1

save "working.dta", replace

use "working.dta", clear
drop if continent=="Europe"

/* Column 3 - Baseline controls */
*Conley SEs; num parms = 1 const + 348-1 city FE + 11 year FE + 1 wpot_post + 11*4 controls = 404 
*preserve
*xi: reg ln_city_population `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.city i.year
*predict ln_city_population_resid, resid
*xi: reg ln_wpot_post       `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.city i.year
*predict ln_wpot_post_resid, resid
*x_ols latitude longitude cutoff1 cutoff2 ln_city_population_resid ln_wpot_post_resid, xreg(2) coord(2)
*restore
* Clustered SEs
xi: areg ln_city_population ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year, absorb(city) cluster(isocode)

/* Column 4 - Basline controls & continent x year FEs */
* Conley SEs; num parms = 1 const + 348-1 city FE + 11 year FE + 1 wpot_post + 11*4 controls + 11*2 continent-year FE = 426 --- Had to do 2-step method
*preserve
*xi: reg ln_city_population `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.city i.year `cont_asia_flexible' `cont_africa_flexible'
*predict ln_city_population_resid, resid
*xi: reg ln_wpot_post       `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.city i.year `cont_asia_flexible' `cont_africa_flexible'
*predict ln_wpot_post_resid, resid
*x_ols latitude longitude cutoff1 cutoff2 ln_city_population_resid ln_wpot_post_resid, xreg(2) coord(2)
*restore
* Clustered SEs
xi: areg ln_city_population ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' `cont_asia_flexible' `cont_africa_flexible', absorb(city) cluster(isocode)

***************************
*** Keeping only Europe ***
***************************

use "working.dta", clear
keep if continent=="Europe"

tab continent

/* Column 5 - Baseline controls */
* Conley SEs; num parms = 1 const + 350-1 city FE + 11 year FE + 1 wpot_post + 11*44 controls = 406
*xi: x_ols latitude longitude cutoff1 cutoff2 ln_city_population constant ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year i.city, xreg(404) coord(2)
* Clustered SEs
xi: areg ln_city_population ln_wpot_post `ln_oworld_flexible' `ln_tropical_flexible' `ln_rugged_flexible' `ln_elevation_flexible' i.year, absorb(city) cluster(isocode)

erase "working.dta"

log close


