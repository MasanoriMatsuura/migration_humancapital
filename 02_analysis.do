clear all
set more off
set maxvar 10000
global root "C:/Users/mm_wi/Documents/research/migration"
global out "$root/analysis_stata/data"
global results "$root/analysis_stata/results"
capture mkdir "$results"

use "$out/pr_did_appended.dta", clear

* ==== Drop missing outcome ====
drop if sec_completed == .
drop if prim_completed == .

drop if birth_year < 1980
drop if birth_year > 2002
disp "Observations for analysis: `=_N'"
tab female

save data.dta, replace
* ======================================================================
* SUMMARY STATISTICS
* ======================================================================
/*capture ssc install estout
capture ssc install coefplot
capture ssc install reghdfe
capture ssc install ftools*/

estpost summarize sec_completed prim_completed female post_03 ///
    full_exp_03 part_exp_03 ctrl_03 post_03_prim full_exp_03_prim part_exp_03_prim ctrl_03_prim ///
    age urban wealth, detail   //full_exp_06 part_exp_06 ctrl_06 ///
esttab using "$results/summary_stats.tex", replace ///
    cells("count mean(fmt(3)) sd(fmt(3)) min max") ///
    nomtitle nonumber label ///
    title("Summary Statistics\label{tab:summary}")


* ######################################################################
* PART A: 2003 POLICY REFORM (SECONDARY COMPLETION DiD)
* ######################################################################
use data.dta, clear
preserve

* A1) Basic DiD: Female x Post-2003 (binary)
reghdfe sec_completed female post_03 female_post_03 wealth [pweight=weight]  if  birth_year >= 1983 & birth_year < 1994, ///
    absorb(wave division urban) cluster(cluster_id) 
eststo did_03_basic
reghdfe prim_completed female post_03_prim female_post_03_prim wealth [pweight=weight] if birth_year >= 1986 & birth_year < 2002 , ///
    absorb(wave division urban) cluster(cluster_id)
eststo did_03_basic_prim

* A2) Granular DiD: Female x Partial + Female x Full (2003)
reghdfe sec_completed female part_exp_03 full_exp_03 ///
    female_part_03 female_full_03 wealth [pweight=weight] if birth_year >= 1983 & birth_year < 1994, ///
    absorb(wave division urban) cluster(cluster_id)
eststo did_03_gran
reghdfe prim_completed female part_exp_03_prim full_exp_03_prim ///
    female_part_03_prim female_full_03_prim wealth [pweight=weight] if birth_year >= 1986 & birth_year < 2002, ///
    absorb(wave division urban) cluster(cluster_id)
eststo did_03_gran_prim

* A3) Donut DiD 2003: Drop partially exposed (1988-1990)
reghdfe sec_completed female full_exp_03 female_full_03 wealth [pweight=weight] ///
    if part_exp_03 != 1 &  birth_year >= 1983 & birth_year < 1994, ///
    absorb(wave division urban) cluster(cluster_id)
eststo donut_did_03
reghdfe prim_completed female full_exp_03_prim female_full_03_prim wealth [pweight=weight] ///
    if part_exp_03_prim != 1 &  birth_year >= 1986 & birth_year < 2002, ///
    absorb(wave division urban) cluster(cluster_id)
eststo donut_did_03_prim

* Output 2003 Table
esttab did_03_basic_prim did_03_gran_prim donut_did_03_prim using "$results/regression_results_03_prim.tex", replace ///
    mtitles("DiD (Binary)" "DiD (Granular)" "Donut DiD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(female post_03_prim female_post_03_prim ///
         part_exp_03_prim full_exp_03_prim female_part_03_prim female_full_03_prim) ///
    order(female post_03_prim female_post_03_prim ///
         part_exp_03_prim full_exp_03_prim female_part_03_prim female_full_03_prim) ///
    title("DiD: Impact of 2003 Migration Policy on Primary Education\label{tab:regression03prim}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "All models include wave, region, and urban/rural FEs." ///
             "Treated = Female. Control = Male.")

esttab did_03_basic did_03_gran donut_did_03 using "$results/regression_results_03.tex", replace ///
    mtitles("DiD (Binary)" "DiD (Granular)" "Donut DiD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(female post_03 female_post_03 ///
         part_exp_03 full_exp_03 female_part_03 female_full_03) ///
    order(female post_03 female_post_03 ///
          part_exp_03 full_exp_03 female_part_03 female_full_03) ///
    title("DiD: Impact of 2003 Migration Policy on Secondary Education\label{tab:regression03}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "All models include wave, region, and urban/rural FEs." ///
             "Treated = Female. Control = Male.")
			 
restore


* ######################################################################
* PART B: PANEL EVENT STUDY (eventdd IMPLEMENTATION)
* Following Clarke and Tapia Schythe (2020, IZA DP No. 13524)
* ######################################################################
use data.dta, clear
preserve

* Restrict sample for 2003 reform: birth cohorts 1983 to 1993, secondary school
keep if birth_year >= 1983 & birth_year < 1994

* Standardized time-to-event variable:
* 0 corresponds to 1988 birth cohort (aged 15 at 2003 reform), -1 corresponds to 1987 (omitted baseline)
* For pure controls (males), timevar is set to missing as specified in Clarke & Tapia Schythe (2020)
gen timeToTreat_03 = birth_year - 1988 if female == 1

* Event study estimation using eventdd with high-dimensional fixed effects (hdfe)
eventdd sec_completed wealth [pweight=weight], ///
    timevar(timeToTreat_03) method(hdfe, absorb(female birth_year wave region urban)) ///
    cluster(cluster_id) ci(rcap) baseline(-1) ///
    graph_op(title("Event Study: 2003 Policy Reform") ///
             ytitle("Female-specific Effect on Secondary Completion") ///
             xtitle("Birth Cohort Relative to 1988 (t=0)") ///
             xlabel(-5(1)5) ///
             yline(0, lcolor(black) lpattern(dash)))

graph export "$results/event_study_03.png", as(png) width(1200) replace
graph export "$results/event_study_03.pdf", as(pdf) replace

restore

preserve

* Restrict sample for 2003 reform, primary education: birth cohorts 1985 to 2002, primary school
keep if birth_year >= 1986 & birth_year < 2002

* Standardized time-to-event variable:
* 0 corresponds to 1991 birth cohort (aged 12 at 2003 reform), -1 corresponds to 1990 (omitted baseline)
* For pure controls (males), timevar is set to missing as specified in Clarke & Tapia Schythe (2020)
gen timeToTreat_03_prim = birth_year - 1991 if female == 1

* Event study estimation using eventdd with high-dimensional fixed effects (hdfe)
eventdd prim_completed wealth [pweight=weight], ///
    timevar(timeToTreat_03_prim) method(hdfe, absorb(female birth_year wave region urban)) ///
    cluster(cluster_id) ci(rcap) baseline(-1) ///
    graph_op(title("Event Study: 2003 Policy Reform") ///
             ytitle("Female-specific Effect on Primary Completion") ///
             xtitle("Birth Cohort Relative to 1991 (t=0)") ///
             xlabel(-5(1)10) ///
             yline(0, lcolor(black) lpattern(dash)))

graph export "$results/event_study_03_prim.png", as(png) width(1200) replace
graph export "$results/event_study_03_prim.pdf", as(pdf) replace

restore

* ######################################################################
* PART C: 2003 POLICY REFORM (Heterogeneity)
* ######################################################################
use data.dta, clear
preserve

* A1) Basic DiD: Female x Post-2003 (binary)
reghdfe sec_completed i.female##i.urban post_03##i.urban female_post_03##i.urban wealth [pweight=weight]  if  birth_year >= 1983 & birth_year < 1994, ///
    absorb(wave region urban) cluster(cluster_id) 
eststo did_03_basic
reghdfe prim_completed female##i.urban post_03_prim##i.urban female_post_03_prim##i.urban wealth [pweight=weight] if birth_year >= 1986 & birth_year < 2002 , ///
    absorb(wave region urban) cluster(cluster_id)
eststo did_03_basic_prim

* A2) Granular DiD: Female x Partial + Female x Full (2003)
reghdfe sec_completed female##i.urban part_exp_03##i.urban full_exp_03##i.urban ///
    female_part_03##i.urban female_full_03##i.urban wealth [pweight=weight] if birth_year >= 1983 & birth_year < 1994, ///
    absorb(wave region urban) cluster(cluster_id)
eststo did_03_gran
reghdfe prim_completed female##i.urban part_exp_03_prim##i.urban full_exp_03_prim##i.urban ///
    female_part_03_prim##i.urban female_full_03_prim##i.urban wealth [pweight=weight] if birth_year >= 1986 & birth_year < 2002, ///
    absorb(wave region urban) cluster(cluster_id)
eststo did_03_gran_prim

* A3) Donut DiD 2003: Drop partially exposed (1988-1990)
reghdfe sec_completed female full_exp_03##i.urban female_full_03##i.urban wealth [pweight=weight] ///
    if part_exp_03 != 1 &  birth_year >= 1983 & birth_year < 1994, ///
    absorb(wave region urban) cluster(cluster_id)
eststo donut_did_03
reghdfe prim_completed female##i.urban full_exp_03_prim##i.urban female_full_03_prim##i.urban wealth [pweight=weight] ///
    if part_exp_03_prim != 1 &  birth_year >= 1986 & birth_year < 2002, ///
    absorb(wave region urban) cluster(cluster_id)
eststo donut_did_03_prim

* Output 2003 Table
esttab did_03_basic_prim did_03_gran_prim donut_did_03_prim using "$results/hetero_urban_results_03_prim.tex", replace ///
    mtitles("DiD (Binary)" "DiD (Granular)" "Donut DiD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(female post_03_prim female_post_03_prim ///
         part_exp_03_prim full_exp_03_prim female_part_03_prim female_full_03_prim) ///
    order(female##i.urban part_exp_03_prim##i.urban full_exp_03_prim##i.urban ///
    female_part_03_prim##i.urban female_full_03_prim##i.urban) ///
    title("DiD: Impact of 2003 Migration Policy on Primary Education\label{tab:urban03prim}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "All models include wave, region, and urban/rural FEs." ///
             "Treated = Female. Control = Male.")

esttab did_03_basic did_03_gran donut_did_03 using "$results/hetero_urban_results_03.tex", replace ///
    mtitles("DiD (Binary)" "DiD (Granular)" "Donut DiD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(female post_03 female_post_03 ///
         part_exp_03 full_exp_03 female_part_03 female_full_03) ///
    order(female post_03 female_post_03 ///
          part_exp_03 full_exp_03 female_part_03 female_full_03) ///
    title("DiD: Impact of 2003 Migration Policy on Secondary Education\label{tab:urban03}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "All models include wave, region, and urban/rural FEs." ///
             "Treated = Female. Control = Male.")
			 
restore

* ######################################################################
* PART C: PLACEBO TEST — FAKE REFORM YEAR 2000 (SECONDARY COMPLETION)
* Assuming reform occurred in 2000 (instead of 2003/2006)
* Placebo cohort definitions (same age logic applied to 2000):
*   Control (fake 2000):       born <= 1983 (age 17+ in 2000)
*   Partially exposed (fake):  born 1984-1987 (age 13-16 in 2000)
*   Fully exposed (fake):      born >= 1988 (age 12 or younger in 2000)
*   Cutoff for RDD:            birth year 1984 (centered = 0 at 1984)
* ######################################################################
use data.dta, clear
preserve

* Placebo cohort indicators_secondary
gen ctrl_fake     = (birth_year <= 1984)
gen part_exp_fake = (birth_year >= 1985 & birth_year <= 1987)
gen full_exp_fake = (birth_year >= 1988)
gen post_fake     = (birth_year > 1984)

* Female x Placebo interaction terms
gen female_post_fake = female * post_fake
gen female_part_fake = female * part_exp_fake
gen female_full_fake = female * full_exp_fake

label variable ctrl_fake     "Placebo Control (born <=1984)"
label variable part_exp_fake "Placebo Part. Exposed (1985-1987)"
label variable full_exp_fake "Placebo Fully Exposed (>=1988)"
label variable post_fake     "Placebo Post-2000 Cohort"
label variable female_post_fake "Female x Placebo Post-2000"
label variable female_part_fake "Female x Placebo Part. Exposed"
label variable female_full_fake "Female x Placebo Fully Exposed"

* D1) Basic Placebo DiD (secondary completion, fake 2000 reform)
reghdfe sec_completed female post_fake female_post_fake wealth [pweight=weight] if birth_year < 1991, ///
    absorb(wave region urban) cluster(cluster_id)
eststo did_fake_basic

* D2) Granular Placebo DiD
reghdfe sec_completed female part_exp_fake full_exp_fake ///
    female_part_fake female_full_fake wealth [pweight=weight] if birth_year < 1991, ///
    absorb(wave region urban) cluster(cluster_id)
eststo did_fake_gran

* D3) Donut Placebo DiD (drop partial)
reghdfe sec_completed female full_exp_fake female_full_fake wealth [pweight=weight] ///
    if part_exp_fake != 1 & birth_year < 1991, ///
    absorb(wave region urban) cluster(cluster_id)
eststo donut_did_fake

* Output Placebo DiD Table
esttab did_fake_basic did_fake_gran donut_did_fake using "$results/regression_results_placebo.tex", replace ///
    mtitles("DiD (Binary)" "DiD (Granular)" "Donut DiD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(female post_fake female_post_fake ///
         part_exp_fake full_exp_fake female_part_fake female_full_fake) ///
    order(female post_fake female_post_fake ///
          part_exp_fake full_exp_fake female_part_fake female_full_fake) ///
    title("Placebo DiD: Fake Reform Year 2000 (Secondary Completion)\label{tab:placebodid}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "All models include wave, region, and urban/rural FEs." ///
             "Placebo cutoff: birth year 1984. No reform in 2000 occurred.")
restore

preserve

* Placebo cohort indicators_primary
gen ctrl_fake_prim     = (birth_year <= 1984)
gen part_exp_fake_prim = (birth_year >= 1985 & birth_year <= 1990)
gen full_exp_fake_prim = (birth_year >= 1991)
gen post_fake_prim     = (birth_year > 1985)

* Female x Placebo interaction terms
gen female_post_fake_prim = female * post_fake_prim
gen female_part_fake_prim = female * part_exp_fake_prim
gen female_full_fake_prim = female * full_exp_fake_prim

label variable ctrl_fake_prim     "Placebo Control (born <=1984)"
label variable part_exp_fake_prim "Placebo Part. Exposed (1985-1990)"
label variable full_exp_fake_prim "Placebo Fully Exposed (>=1991)"
label variable post_fake_prim     "Placebo Post-1997 Cohort"
label variable female_post_fake_prim "Female x Placebo Post-1997"
label variable female_part_fake_prim "Female x Placebo Part. Exposed"
label variable female_full_fake_prim "Female x Placebo Fully Exposed"

* D1) Basic Placebo DiD (secondary completion, fake 2000 reform)
reghdfe prim_completed female post_fake_prim female_post_fake_prim wealth [pweight=weight] if birth_year < 1997, ///
    absorb(wave region urban) cluster(cluster_id)
eststo did_fake_basic_prim

* D2) Granular Placebo DiD
reghdfe prim_completed female part_exp_fake_prim full_exp_fake_prim ///
    female_part_fake_prim female_full_fake_prim wealth [pweight=weight] if birth_year < 1997, ///
    absorb(wave region urban) cluster(cluster_id)
eststo did_fake_gran_prim

* D3) Donut Placebo DiD (drop partial)
reghdfe prim_completed female full_exp_fake_prim female_full_fake_prim wealth [pweight=weight] ///
    if part_exp_fake_prim != 1 & birth_year < 1997, ///
    absorb(wave region urban) cluster(cluster_id)
eststo donut_did_fake_prim

* Output Placebo DiD Table
esttab did_fake_basic_prim did_fake_gran_prim donut_did_fake_prim using "$results/regression_results_placebo_prim.tex", replace ///
    mtitles("DiD (Binary)" "DiD (Granular)" "Donut DiD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(female post_fake_prim female_post_fake_prim ///
         part_exp_fake_prim full_exp_fake_prim female_part_fake_prim female_full_fake_prim) ///
    order(female post_fake_prim female_post_fake_prim ///
         part_exp_fake_prim full_exp_fake_prim female_part_fake_prim female_full_fake_prim) ///
    title("Placebo DiD: Fake Reform Year 1997 (Primary Completion)\label{tab:placebodidprim}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "All models include wave, region, and urban/rural FEs." ///
             "Placebo cutoff: birth year 1984. No reform in 1997 occurred.")
restore


* ######################################################################
* PART D: Robustness check RDD
* Assuming reform occurred in 2000 (instead of 2003/2006)
* Placebo cohort definitions (same age logic applied to 2000):
*   Control (fake 2000):       born <= 1983 (age 17+ in 2000)
*   Partially exposed (fake):  born 1984-1987 (age 13-16 in 2000)
*   Fully exposed (fake):      born >= 1988 (age 12 or younger in 2000)
*   Cutoff for RDD:            birth year 1984 (centered = 0 at 1984)
* ######################################################################
* ---- Placebo RDD (Females Only, Fake Cutoff = 1984) ----
* Run as a separate preserve block (outside the DiD preserve)
restore

preserve
keep if female == 1

gen run_var_fake   = birth_year - 1984
gen treated_fake_rdd = (run_var_fake >= 0)
gen run_var_treat_fake  = run_var_fake * treated_fake_rdd
gen run_var_fake_sq     = run_var_fake^2
gen run_var_treat_fake_sq = run_var_fake_sq * treated_fake_rdd

* Linear Placebo RDD
reghdfe sec_completed treated_fake_rdd run_var_fake run_var_treat_fake, ///
    absorb(wave region urban) cluster(cluster_id) tol(1e-6)
eststo rdd_fake_lin

* Quadratic Placebo RDD
reghdfe sec_completed treated_fake_rdd run_var_fake run_var_treat_fake ///
    run_var_fake_sq run_var_treat_fake_sq, ///
    absorb(wave region urban) cluster(cluster_id) tol(1e-6)
eststo rdd_fake_quad

* Donut Placebo RDD (drop 1984-1987 partial zone)
gen part_exp_fake_rdd = (birth_year >= 1984 & birth_year <= 1987)
reghdfe sec_completed treated_fake_rdd run_var_fake run_var_treat_fake ///
    if part_exp_fake_rdd==0, ///
    absorb(wave region urban) cluster(cluster_id) tol(1e-6)
eststo donut_rdd_fake

* Output Placebo RDD Table
esttab rdd_fake_lin rdd_fake_quad donut_rdd_fake using "$results/regression_rdd_placebo.tex", replace ///
    mtitles("Linear RDD" "Quadratic RDD" "Donut RDD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(treated_fake_rdd run_var_fake run_var_treat_fake) ///
    title("Placebo RDD: Fake Reform Year 2000 (Females Only, Secondary Completion)\label{tab:rddplacebo}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "Running variable: birth year centered at 1984 (fake cutoff)." ///
             "No reform occurred in 2000; estimates should be near zero.")

* Placebo RDD Plot
collapse (mean) mean_sec = sec_completed, by(birth_year)
gen run_var_fake = birth_year - 1984
twoway (scatter mean_sec run_var_fake if run_var_fake >= -10 & run_var_fake <= 10 & run_var_fake < 0, mcolor(blue) msize(medium)) ///
       (scatter mean_sec run_var_fake if run_var_fake >= -10 & run_var_fake <= 10 & run_var_fake >= 0, mcolor(red) msize(medium)) ///
       (lfit mean_sec run_var_fake if run_var_fake >= -10 & run_var_fake <= 10 & run_var_fake < 0, lcolor(blue) lwidth(medthick)) ///
       (lfit mean_sec run_var_fake if run_var_fake >= -10 & run_var_fake <= 10 & run_var_fake >= 0, lcolor(red) lwidth(medthick)), ///
       xline(0, lcolor(black) lpattern(dash)) ///
       title("Placebo RDD: Fake 2000 Reform (Females)") ///
       xtitle("Birth Year relative to 1984 (Fake Cutoff, t=0)") ///
       ytitle("Mean Secondary Completion") ///
       legend(order(3 "Pre-Cutoff Fit" 4 "Post-Cutoff Fit"))
graph export "$results/rdd_plot_placebo.png", as(png) replace
graph export "$results/rdd_plot_placebo.pdf", as(pdf) replace

restore







* ######################################################################
* PART E: ROBUSTNESS CHECKS - COHORT RDD (FEMALES ONLY)
* ######################################################################
preserve

* Restrict sample to females only to mirror previous RDD specifications
keep if female == 1

* --- E1) 2003 Cohort RDD for Females ---
gen event_time_03 = birth_year - 1987
gen treated_03_rdd = (event_time_03 >= 0)
gen run_var_03 = event_time_03
gen run_var_treat_03 = run_var_03 * treated_03_rdd
gen run_var_03_sq = run_var_03^2
gen run_var_treat_03_sq = run_var_03_sq * treated_03_rdd

* Linear RDD
reghdfe sec_completed treated_03_rdd run_var_03 run_var_treat_03  if birth_year < 1993, ///
    absorb(wave region urban) cluster(cluster_id)
eststo rdd_lin_03

* Quadratic RDD
reghdfe sec_completed treated_03_rdd run_var_03 run_var_treat_03 run_var_03_sq run_var_treat_03_sq  if birth_year < 1993, ///
    absorb(wave region urban) cluster(cluster_id)
eststo rdd_quad_03

* Donut RDD 2003
reghdfe sec_completed treated_03_rdd run_var_03 run_var_treat_03 if part_exp_03==0 & birth_year < 1993, ///
    absorb(wave region urban) cluster(cluster_id)
eststo donut_rdd_03

* Output 2003 RDD Table
esttab rdd_lin_03 rdd_quad_03 donut_rdd_03 using "$results/regression_rdd_03.tex", replace ///
    mtitles("Linear RDD" "Quadratic RDD" "Donut RDD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(treated_03_rdd run_var_03 run_var_treat_03) ///
    title("Robustness: Cohort RDD estimates for 2003 Reform (Females Only)\label{tab:rdd03}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "Running variable: birth year centered at 1987. Cutoff t=0 (born 1987).")


/* --- E2) 2006 Cohort RDD for Females ---
gen event_time_06 = birth_year - 1990
gen treated_06_rdd = (event_time_06 >= 0)
gen run_var_06 = event_time_06
gen run_var_treat_06 = run_var_06 * treated_06_rdd
gen run_var_06_sq = run_var_06^2
gen run_var_treat_06_sq = run_var_06_sq * treated_06_rdd

* Linear RDD
reghdfe sec_completed treated_06_rdd run_var_06 run_var_treat_06, ///
    absorb(wave region urban) cluster(cluster_id)
eststo rdd_lin_06

* Quadratic RDD
reghdfe sec_completed treated_06_rdd run_var_06 run_var_treat_06 run_var_06_sq run_var_treat_06_sq, ///
    absorb(wave region urban) cluster(cluster_id)
eststo rdd_quad_06

* Donut RDD 2006
reghdfe sec_completed treated_06_rdd run_var_06 run_var_treat_06 if part_exp_06==0, ///
    absorb(wave region urban) cluster(cluster_id)
eststo donut_rdd_06

* Output 2006 RDD Table
esttab rdd_lin_06 rdd_quad_06 donut_rdd_06 using "$results/regression_rdd_06.tex", replace ///
    mtitles("Linear RDD" "Quadratic RDD" "Donut RDD") ///
    label b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(treated_06_rdd run_var_06 run_var_treat_06) ///
    title("Robustness: Cohort RDD estimates for 2006 Reform (Females Only)\label{tab:rdd06}") ///
    addnotes("Standard errors clustered by enumeration area." ///
             "Running variable: birth year centered at 1990. Cutoff t=0 (born 1990).")
*/
* --- RDD Plotting ---
collapse (mean) mean_sec = sec_completed, by(birth_year)

* 2003 Plot
gen event_time_03 = birth_year - 1987
twoway (scatter mean_sec event_time_03 if event_time_03 >= -15 & event_time_03 <= 15 & event_time_03 < 0 & birth_year < 1993, mcolor(blue) msize(medium)) ///
       (scatter mean_sec event_time_03 if event_time_03 >= -15 & event_time_03 <= 15 & event_time_03 >= 0 & birth_year < 1993, mcolor(red) msize(medium)) ///
       (lfit mean_sec event_time_03 if event_time_03 >= -15 & event_time_03 <= 15 & event_time_03 < 0 & birth_year < 1993, lcolor(blue) lwidth(medthick)) ///
       (lfit mean_sec event_time_03 if event_time_03 >= -15 & event_time_03 <= 15 & event_time_03 >= 0 & birth_year < 1993, lcolor(red) lwidth(medthick)), ///
       xline(0, lcolor(black) lpattern(dash)) ///
       title("RDD: 2003 Policy Discontinuity (Females)") ///
       xtitle("Birth Year relative to 1987 (t=0)") ///
       ytitle("Mean Secondary Completion") ///
       legend(order(3 "Pre-reform Fit" 4 "Post-reform Fit"))
graph export "$results/rdd_plot_03.png", as(png) replace
graph export "$results/rdd_plot_03.pdf", as(pdf) replace

/* 2006 Plot
gen event_time_06 = birth_year - 1990
twoway (scatter mean_sec event_time_06 if event_time_06 >= -15 & event_time_06 <= 15 & event_time_06 < 0, mcolor(blue) msize(medium)) ///
       (scatter mean_sec event_time_06 if event_time_06 >= -15 & event_time_06 <= 15 & event_time_06 >= 0, mcolor(red) msize(medium)) ///
       (lfit mean_sec event_time_06 if event_time_06 >= -15 & event_time_06 <= 15 & event_time_06 < 0, lcolor(blue) lwidth(medthick)) ///
       (lfit mean_sec event_time_06 if event_time_06 >= -15 & event_time_06 <= 15 & event_time_06 >= 0, lcolor(red) lwidth(medthick)), ///
       xline(0, lcolor(black) lpattern(dash)) ///
       title("RDD: 2006 Policy Discontinuity (Females)") ///
       xtitle("Birth Year relative to 1990 (t=0)") ///
       ytitle("Mean Secondary Completion") ///
       legend(order(3 "Pre-reform Fit" 4 "Post-reform Fit"))
graph export "$results/rdd_plot_06.png", as(png) replace
graph export "$results/rdd_plot_06.pdf", as(pdf) replace
*/
restore

disp "Analysis complete!"
