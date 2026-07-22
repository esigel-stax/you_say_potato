*------------------------------------------------------------------------------
* beliefs.do
*
* (v2 — child-quality items removed; income-dispersion outcomes added.)
*
* Build country-level outcomes from EVS5/WVS7 Joint v5:
*   (a) communal-vs-individual belief index (11 items, no child qualities)
*   (b) within-country dispersion of self-reported income decile
*
* Then test the Nunn-Qian (2011) potato suitability effect on each outcome.
*

* To add? height dispersin within france,
* Sample: countries in country_level_panel_for_web.dta with cont_europe==1
*         AND that appear in EVS5/WVS7 Joint v5 (N=32 for beliefs, N=31 for
*         income dispersion — Portugal lacks income item).
*------------------------------------------------------------------------------

version 17
clear all
set more off
cap log close

*------------------------------------------------------------------------------
* PATHS — edit these two globals to match your machine and then run the file.
*------------------------------------------------------------------------------
* Folder that holds country_level_panel_for_web.dta, the EVS .dta, and where
* the output .dta / .log will be written.
global POTATO "/Users/esigel/Library/CloudStorage/Dropbox-JC'sDataEmporium/Eleanor Sigel/Potato/NUNN_QIAN_QJE_2011_REPLICATION_FILES"

* Folder that holds the EVS/WVS Joint v5 file (Stata format).  If the .dta is
* in the same folder as $POTATO, set this equal to $POTATO.
global EVS "$POTATO"

cd "$POTATO"
log using "$POTATO/beliefs.log", replace

*--- 1. Open EVS/WVS Joint, keep N-Q European countries -------------------
use "$EVS/EVS_WVS_Joint_Stata_v5_0.dta", clear

* EVS uses ISO 3166-1 Alpha-2 in cntry_AN; N-Q uses Alpha-3 in isocode.
gen str3 isocode = ""
replace isocode = "ALB" if cntry_AN=="AL"
replace isocode = "AUT" if cntry_AN=="AT"
replace isocode = "BGR" if cntry_AN=="BG"
replace isocode = "BIH" if cntry_AN=="BA"
replace isocode = "BLR" if cntry_AN=="BY"
replace isocode = "CHE" if cntry_AN=="CH"
replace isocode = "CZE" if cntry_AN=="CZ"
replace isocode = "DEU" if cntry_AN=="DE"
replace isocode = "DNK" if cntry_AN=="DK"
replace isocode = "ESP" if cntry_AN=="ES"
replace isocode = "EST" if cntry_AN=="EE"
replace isocode = "FIN" if cntry_AN=="FI"
replace isocode = "FRA" if cntry_AN=="FR"
replace isocode = "GBR" if cntry_AN=="GB" | cntry_AN=="NIR"
replace isocode = "HRV" if cntry_AN=="HR"
replace isocode = "HUN" if cntry_AN=="HU"
replace isocode = "ISL" if cntry_AN=="IS"
replace isocode = "ITA" if cntry_AN=="IT"
replace isocode = "LTU" if cntry_AN=="LT"
replace isocode = "LVA" if cntry_AN=="LV"
replace isocode = "MKD" if cntry_AN=="MK"
replace isocode = "NLD" if cntry_AN=="NL"
replace isocode = "NOR" if cntry_AN=="NO"
replace isocode = "POL" if cntry_AN=="PL"
replace isocode = "PRT" if cntry_AN=="PT"
replace isocode = "ROU" if cntry_AN=="RO"
replace isocode = "RUS" if cntry_AN=="RU"
replace isocode = "SVK" if cntry_AN=="SK"
replace isocode = "SVN" if cntry_AN=="SI"
replace isocode = "SWE" if cntry_AN=="SE"
replace isocode = "UKR" if cntry_AN=="UA"
replace isocode = "YUG" if cntry_AN=="RS" | cntry_AN=="ME"   /* Serbia + Montenegro */
keep if isocode != ""

*--- 2. Recode belief items (NO child qualities) --------------------------
* Negative codes in EVS/WVS = missing.
foreach v in C038 C039 C041 D026_03 D026_05 D054 E035 E036 E037 E039 A165 {
    replace `v' = . if `v' < 0
}

* 5-point agree scales: 1=strongly agree (communal direction) -> 5 (disagree)
foreach v in C038 C039 C041 D026_03 D026_05 {
    gen r`v' = (5 - `v') / 4 if inrange(`v',1,5)
}
* 4-point agree scale
gen rD054 = (4 - D054) / 3 if inrange(D054,1,4)

* 1-10 scales (communal = high values for E036, E037, E039; reversed for E035)
gen rE035 = 1 - (E035 - 1) / 9   if inrange(E035,1,10)
gen rE036 = (E036 - 1) / 9       if inrange(E036,1,10)
gen rE037 = (E037 - 1) / 9       if inrange(E037,1,10)
gen rE039 = (E039 - 1) / 9       if inrange(E039,1,10)

* Generalized trust: 1=trust (individual broad-radius); 2=cannot trust (communal)
gen rA165 = A165 - 1   if inlist(A165,1,2)

* Respondent-level communal index = mean of the 11 recoded items
egen comm_index_resp = rowmean( rC038 rC039 rC041 rD026_03 rD026_05 rD054 ///
                                rE035 rE036 rE037 rE039 rA165 )

*--- 2b. Civic engagement (A065-A080 series; binary 0/1) ------------------
foreach v in A065 A066 A067 A068 A071 A072 A074 A078 A079 A080_01 A080_02 {
    replace `v' = . if `v' < 0
}
* Count of memberships answered and held.
egen civic_answered = rownonmiss( A065 A066 A067 A068 A071 A072 A074 A078 ///
                                  A079 A080_01 A080_02 )
egen civic_count_raw = rowtotal( A065 A066 A067 A068 A071 A072 A074 A078 ///
                                  A079 A080_01 A080_02 ), missing
gen civic_count = civic_count_raw if civic_answered >= 6
gen civic_share = civic_count / civic_answered if civic_answered >= 6
label var civic_count "Civic engagement: # memberships out of 11 (count)"
label var civic_share "Civic engagement: share of orgs respondent belongs to"
drop civic_count_raw

* (Self-reported WVS income X047 dropped at v6: replaced with N-Q's
*  historical city-population data, which is the actual income/prosperity
*  proxy in Nunn-Qian 2011.  See block 4b below.)

*--- 4. Country collapse: belief index + income mean & dispersion ---------
* NOTE: Stata's -collapse- does not allow (sd) with [pw=]. We therefore do
* the means with pweight (population-correct weighting) and the SD with
* aweight (the only weight class Stata permits with the sd statistic in
* -collapse-).  For cross-country comparison the point estimates of the SD
* under pweight vs aweight are essentially identical.
preserve
    collapse (mean) communal_index = comm_index_resp ///
             (mean) civic_share    = civic_share ///
             (mean) civic_count    = civic_count ///
             [pw=gwght], by(isocode)
    label var communal_index "Communal-individual belief index (0=indiv,1=communal,11 items)"
    label var civic_share    "Civic engagement: share of orgs respondent belongs to"
    label var civic_count    "Civic engagement: # memberships out of 11"
    save "$POTATO/country_outcomes.dta", replace
restore

*--- 4b. Income / prosperity from N-Q historical city panel ----------------
* Replaces the self-reported WVS income variable with the actual prosperity
* proxy in Nunn-Qian (2011): log city population in 1850 (the latest year
* in the Europe-only city panel).  Per-country values are the cross-city
* mean (prosperity level) and SD (urban-size dispersion / hierarchy).
preserve
    use "$POTATO/Europe_only_city_level_panel_for_web.dta", clear
    keep if year == 1850
    collapse (mean) ln_pop_1850_mean = ln_city_population ///
             (sd)   ln_pop_1850_sd   = ln_city_population ///
             (count) n_cities_1850   = ln_city_population, by(isocode)
    label var ln_pop_1850_mean "N-Q: mean log city population 1850"
    label var ln_pop_1850_sd   "N-Q: within-country SD of log city pop 1850"
    save "$POTATO/country_nq_pop.dta", replace
restore

*--- 5. Merge into N-Q country panel and run cross-sectional OLS ---------
use "$POTATO/country_level_panel_for_web.dta", clear
keep if cont_europe == 1
duplicates drop isocode, force
merge 1:1 isocode using "$POTATO/country_outcomes.dta"
keep if _merge==3
drop _merge
merge 1:1 isocode using "$POTATO/country_nq_pop.dta", keep(master match) nogen

local geog "ln_oworld ln_elevation ln_tropical ln_rugged"
local full "`geog' ln_disteq ln_dist_coast malaria"
local rel  "protestant roman"   /* added back as Spec 5 */

di "=========== COMMUNAL INDEX (11 items, no child qualities) ==========="
reg communal_index ln_wpot,                       robust
estimates store c1
reg communal_index ln_wpot ln_oworld,             robust
estimates store c2
reg communal_index ln_wpot `geog',                robust
estimates store c3
reg communal_index ln_wpot `full',                robust
estimates store c4
reg communal_index ln_wpot `full' `rel',          robust
estimates store c5

di "=========== INCOME / PROSPERITY — N-Q mean log city pop 1850 ==========="
reg ln_pop_1850_mean ln_wpot,                     robust
estimates store s1
reg ln_pop_1850_mean ln_wpot ln_oworld,           robust
estimates store s2
reg ln_pop_1850_mean ln_wpot `geog',              robust
estimates store s3
reg ln_pop_1850_mean ln_wpot `full',              robust
estimates store s4
reg ln_pop_1850_mean ln_wpot `full' `rel',        robust
estimates store s5

di "=========== INCOME DISPERSION — N-Q within-country SD of log city pop 1850 ==========="
reg ln_pop_1850_sd ln_wpot,                       robust
estimates store v1
reg ln_pop_1850_sd ln_wpot ln_oworld,             robust
estimates store v2
reg ln_pop_1850_sd ln_wpot `geog',                robust
estimates store v3
reg ln_pop_1850_sd ln_wpot `full',                robust
estimates store v4
reg ln_pop_1850_sd ln_wpot `full' `rel',          robust
estimates store v5

di "=========== CIVIC ENGAGEMENT — share of 11 orgs =========="
reg civic_share ln_wpot,                          robust
estimates store e1
reg civic_share ln_wpot ln_oworld,                robust
estimates store e2
reg civic_share ln_wpot `geog',                   robust
estimates store e3
reg civic_share ln_wpot `full',                   robust
estimates store e4
reg civic_share ln_wpot `full' `rel',             robust
estimates store e5

di "=========== Robustness — drop Iceland (ln_wpot = 0) =========="
reg civic_share ln_wpot                       if isocode!="ISL", robust
reg civic_share ln_wpot ln_oworld             if isocode!="ISL", robust
reg civic_share ln_wpot `full'                if isocode!="ISL", robust

* Pretty tables (if esttab available)
cap which esttab
if !_rc {
    local kp "ln_wpot ln_oworld ln_elevation ln_tropical ln_rugged ln_disteq ln_dist_coast malaria protestant roman _cons"
    esttab c1 c2 c3 c4 c5, b(%6.4f) se(%6.4f) star(* .10 ** .05 *** .01) ///
        keep(`kp') stats(N r2, fmt(%9.0f %6.3f)) ///
        title("Potato suitability and communal-vs-individual beliefs")
    esttab s1 s2 s3 s4 s5, b(%6.4f) se(%6.4f) star(* .10 ** .05 *** .01) ///
        keep(`kp') stats(N r2, fmt(%9.0f %6.3f)) ///
        title("Potato suitability and within-country income SD")
    esttab v1 v2 v3 v4 v5, b(%6.4f) se(%6.4f) star(* .10 ** .05 *** .01) ///
        keep(`kp') stats(N r2, fmt(%9.0f %6.3f)) ///
        title("Potato suitability and within-country income CV")
    esttab e1 e2 e3 e4 e5, b(%6.4f) se(%6.4f) star(* .10 ** .05 *** .01) ///
        keep(`kp') stats(N r2, fmt(%9.0f %6.3f)) ///
        title("Potato suitability and civic engagement (A065-A080)")
}

*------------------------------------------------------------------------------
* 6. ITEM SCREEN — does ln_wpot predict ANY individual EVS/WVS item?
*
* Sweep every numeric A/B/C/D/E/F/G/X/Y item in the joint file, take the
* gwght-weighted country mean, then regress on ln_wpot under:
*   Spec 1: bivariate
*   Spec 4: full pre-treatment ecological controls
* Report robust (HC1) SEs.  Apply Benjamini-Hochberg FDR across all items
* separately for each spec.  Output: item_screen_results.dta / .csv.
*------------------------------------------------------------------------------
preserve

use "$EVS/EVS_WVS_Joint_Stata_v5_0.dta", clear

* Same ISO mapping as block 1 (shorter copy).
gen str3 isocode = ""
replace isocode = "ALB" if cntry_AN=="AL"
replace isocode = "AUT" if cntry_AN=="AT"
replace isocode = "BGR" if cntry_AN=="BG"
replace isocode = "BIH" if cntry_AN=="BA"
replace isocode = "BLR" if cntry_AN=="BY"
replace isocode = "CHE" if cntry_AN=="CH"
replace isocode = "CZE" if cntry_AN=="CZ"
replace isocode = "DEU" if cntry_AN=="DE"
replace isocode = "DNK" if cntry_AN=="DK"
replace isocode = "ESP" if cntry_AN=="ES"
replace isocode = "EST" if cntry_AN=="EE"
replace isocode = "FIN" if cntry_AN=="FI"
replace isocode = "FRA" if cntry_AN=="FR"
replace isocode = "GBR" if cntry_AN=="GB" | cntry_AN=="NIR"
replace isocode = "HRV" if cntry_AN=="HR"
replace isocode = "HUN" if cntry_AN=="HU"
replace isocode = "ISL" if cntry_AN=="IS"
replace isocode = "ITA" if cntry_AN=="IT"
replace isocode = "LTU" if cntry_AN=="LT"
replace isocode = "LVA" if cntry_AN=="LV"
replace isocode = "MKD" if cntry_AN=="MK"
replace isocode = "NLD" if cntry_AN=="NL"
replace isocode = "NOR" if cntry_AN=="NO"
replace isocode = "POL" if cntry_AN=="PL"
replace isocode = "PRT" if cntry_AN=="PT"
replace isocode = "ROU" if cntry_AN=="RO"
replace isocode = "RUS" if cntry_AN=="RU"
replace isocode = "SVK" if cntry_AN=="SK"
replace isocode = "SVN" if cntry_AN=="SI"
replace isocode = "SWE" if cntry_AN=="SE"
replace isocode = "UKR" if cntry_AN=="UA"
replace isocode = "YUG" if cntry_AN=="RS" | cntry_AN=="ME"
keep if isocode != ""

* Pick out every numeric EVS/WVS substantive item.
* Pattern: starts with A-G or X-Y, then 3 digits, then optional _suffix.
ds, has(type numeric)
local numvars `r(varlist)'
local items ""
foreach v of local numvars {
    if regexm("`v'", "^[A-GXY][0-9][0-9][0-9]") {
        local items `items' `v'
    }
}
local nitems : word count `items'
di as result "ITEM SCREEN: " `nitems' " candidate items"

* Recode negative codes to missing across every item.
foreach v of local items {
    quietly replace `v' = . if `v' < 0
}

* gwght-weighted country mean of every item.
collapse (mean) `items' [pw=gwght], by(isocode)
tempfile screen_means
save `screen_means'

* Merge with N-Q pre-treatment ecological controls.
use "$POTATO/country_level_panel_for_web.dta", clear
keep if cont_europe == 1
duplicates drop isocode, force
merge 1:1 isocode using `screen_means', keep(match) nogen

local fullX "ln_oworld ln_elevation ln_tropical ln_rugged ln_disteq ln_dist_coast malaria"

* Pre-allocate a postfile to collect per-item regression output.
tempname mh
tempfile screen_out
postfile `mh' str20 item double(beta_s1 se_s1 p_s1 r2_s1) ///
                          double(beta_s4 se_s4 p_s4 r2_s4) ///
                          int n_s1 int n_s4 ///
              using `screen_out', replace

quietly foreach v of local items {
    capture noisily {
        * skip items with no variation across countries
        summarize `v', meanonly
        if r(N) < 18 continue
        summarize `v'
        if r(sd) == 0 | missing(r(sd)) continue

        reg `v' ln_wpot, robust
        local b1 = _b[ln_wpot]
        local s1 = _se[ln_wpot]
        local p1 = 2*ttail(e(df_r), abs(`b1'/`s1'))
        local r1 = e(r2)
        local n1 = e(N)

        reg `v' ln_wpot `fullX', robust
        local b4 = _b[ln_wpot]
        local s4 = _se[ln_wpot]
        local p4 = 2*ttail(e(df_r), abs(`b4'/`s4'))
        local r4 = e(r2)
        local n4 = e(N)

        post `mh' ("`v'") (`b1') (`s1') (`p1') (`r1') ///
                          (`b4') (`s4') (`p4') (`r4') (`n1') (`n4')
    }
}
postclose `mh'

use `screen_out', clear

* Benjamini-Hochberg FDR for both specs.
foreach spec in s1 s4 {
    gsort p_`spec'
    gen rank_`spec' = _n
    quietly count if !missing(p_`spec')
    local m = r(N)
    gen q_bh_`spec' = p_`spec' * `m' / rank_`spec'
    * enforce monotonicity by taking running min from largest rank down
    gsort -rank_`spec'
    replace q_bh_`spec' = min(q_bh_`spec', q_bh_`spec'[_n-1]) if _n > 1
    replace q_bh_`spec' = min(q_bh_`spec', 1)
}

* Final sort by Spec 4 p-value (the preferred screen).
gsort p_s4
list item beta_s4 se_s4 p_s4 q_bh_s4 r2_s4 beta_s1 p_s1 q_bh_s1 in 1/30, ///
    sep(0) noobs

save "$POTATO/item_screen_results.dta", replace
export delimited using "$POTATO/item_screen_results.csv", replace

restore

*------------------------------------------------------------------------------
* 7. FRANCE CONSCRIPT HEIGHTS — within-country potato effect on a physical
*    welfare outcome (mean height) plus a dispersion outcome (within-
*    department SD of height).  Same France_heights_for_web.dta NQ use in
*    Table V Panel B of the paper.
*
*    Outcome A: individual conscript HEIGHT.  Specs replicate NQ:
*      (1) baseline controls + TOWNBIRT FE, cluster by PROVINC
*      (2) baseline + region x birth-decade FE, TOWNBIRT FE, cluster PROVINC
*      (3) all controls + TOWNBIRT FE, cluster PROVINC
*      (4) all controls + region x birth-decade FE, TOWNBIRT FE, cluster PROVINC
*    Outcome B: PROVINC-level SD of HEIGHT.  Same four specs at the
*    department-mean level (department-mean ln_wpot, no individual age
*    controls; cluster by REGION).
*------------------------------------------------------------------------------
preserve
use "$POTATO/France_heights_for_web.dta", clear

gen AGE2 = AGE * AGE

di "=========== FRANCE HEIGHTS — outcome HEIGHT (individual) =========="
* Spec 1: baseline controls + TOWNBIRT FE
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* ///
    tropics_dec* i.BIRTHYR, absorb(TOWNBIRT) cluster(PROVINC)
estimates store h1
* Spec 2: + region x birth-decade FE
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* ///
    tropics_dec* i.BIRTHDEC*i.REGION i.BIRTHYR, absorb(TOWNBIRT) cluster(PROVINC)
estimates store h2
* Spec 3: all controls
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* ///
    tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* i.BIRTHYR, ///
    absorb(TOWNBIRT) cluster(PROVINC)
estimates store h3
* Spec 4: all controls + region x birth-decade FE
xi: areg HEIGHT wpot_post1700 AGE AGE2 ow_dec* rugged_dec* elevation_dec* ///
    tropics_dec* ln_latitude_dec* ln_dist_coast_dec* malaria_dec* ///
    i.BIRTHDEC*i.REGION i.BIRTHYR, absorb(TOWNBIRT) cluster(PROVINC)
estimates store h4

di "=========== FRANCE HEIGHTS DISPERSION — within-PROVINC SD ==========="
* Department-level collapse.  Build PROVINC means of the controls and the
* within-PROVINC SD of HEIGHT.  Need at least 5 conscripts per department
* for a meaningful SD (drop tiny PROVINCs).
collapse (mean) wpot_post1700 ow_dec1-ow_dec11 rugged_dec1-rugged_dec11 ///
                elevation_dec1-elevation_dec11 tropics_dec1-tropics_dec11 ///
                ln_latitude_dec1-ln_latitude_dec11 ///
                ln_dist_coast_dec1-ln_dist_coast_dec11 ///
                malaria_dec1-malaria_dec11 REGION ///
         (sd)   height_sd = HEIGHT ///
         (count) n_men    = HEIGHT, by(PROVINC)
keep if n_men >= 5

reg height_sd wpot_post1700, robust
estimates store d1
reg height_sd wpot_post1700 ow_dec*, robust
estimates store d2
reg height_sd wpot_post1700 ow_dec* rugged_dec* elevation_dec* tropics_dec*, robust
estimates store d3
reg height_sd wpot_post1700 ow_dec* rugged_dec* elevation_dec* tropics_dec* ///
              ln_latitude_dec* ln_dist_coast_dec* malaria_dec*, robust
estimates store d4

cap which esttab
if !_rc {
    esttab h1 h2 h3 h4, b(%6.4f) se(%6.4f) star(* .10 ** .05 *** .01) ///
        keep(wpot_post1700) stats(N r2, fmt(%9.0f %6.3f)) ///
        title("Potato suitability and conscript heights (France)")
    esttab d1 d2 d3 d4, b(%6.4f) se(%6.4f) star(* .10 ** .05 *** .01) ///
        keep(wpot_post1700 _cons) stats(N r2, fmt(%9.0f %6.3f)) ///
        title("Potato suitability and within-department SD of heights (France)")
}
restore

log close
*------------------------------------------------------------------------------
* END
*------------------------------------------------------------------------------

