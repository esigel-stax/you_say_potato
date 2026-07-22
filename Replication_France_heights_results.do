version 10.1
capture clear
clear matrix
capture log close
set more off
set mem 400m
set matsize 5000

log using "Replication_France_heights_results.log", replace

use "France_heights_for_web.dta", clear

gen AGE2=AGE*AGE

* For Conley SEs *
gen cutoff1=5	/* Closer than cutoff = 1, further = 0 */
gen cutoff2=5
gen constant=1

*************************
*** Baseline controls ***
*************************
* Conley SEs
preserve
xi: reg HEIGHT AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* i.BIRTHYR i.TOWNBIRT
predict HEIGHT_resid, resid
xi: reg wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* i.BIRTHYR i.TOWNBIRT
predict wpot_post1700_resid, resid
xi: x_ols latitude longitude cutoff1 cutoff2 HEIGHT_resid constant wpot_post1700_resid, xreg(2) coord(2)
restore
* Clustered SEs
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* i.BIRTHYR, absorb(TOWNBIRT) cluster(PROVINC)

/* Adding Region FEs */
* Conley SEs
preserve
xi: reg HEIGHT AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* i.BIRTHDEC*i.REGION i.BIRTHYR i.TOWNBIRT
predict HEIGHT_resid, resid
xi: reg wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* i.BIRTHDEC*i.REGION i.BIRTHYR i.TOWNBIRT
predict wpot_post1700_resid, resid
xi: x_ols latitude longitude cutoff1 cutoff2 HEIGHT_resid constant wpot_post1700_resid, xreg(2) coord(2)
restore
* Clustered SEs
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* i.BIRTHDEC*i.REGION i.BIRTHYR, absorb(TOWNBIRT) cluster(PROVINC)


**********************************
*** Regressions - All controls ***
**********************************
* Conley SEs
preserve
xi: reg HEIGHT AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* i.BIRTHYR i.TOWNBIRT
predict HEIGHT_resid, resid
xi: reg wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* i.BIRTHYR i.TOWNBIRT
predict wpot_post1700_resid, resid
xi: x_ols latitude longitude cutoff1 cutoff2 HEIGHT_resid constant wpot_post1700_resid, xreg(2) coord(2)
restore
* Clustered SEs
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* i.BIRTHYR, absorb(TOWNBIRT) cluster(PROVINC)

/* Adding Region FEs */
* Conley SEs
preserve
xi: reg HEIGHT AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* i.BIRTHDEC*i.REGION i.BIRTHYR i.TOWNBIRT
predict HEIGHT_resid, resid
xi: reg wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* i.BIRTHDEC*i.REGION i.BIRTHYR i.TOWNBIRT
predict wpot_post1700_resid, resid
xi: x_ols latitude longitude cutoff1 cutoff2 HEIGHT_resid constant wpot_post1700_resid, xreg(2) coord(2)
restore
* Clustered SEs
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* i.BIRTHDEC*i.REGION i.BIRTHYR, absorb(TOWNBIRT) cluster(PROVINC)

log close
