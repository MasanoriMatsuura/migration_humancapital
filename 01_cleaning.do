clear all
set more off
set maxvar 10000

* Define paths
global root "C:/Users/mm_wi/Documents/research/migration"
global out "$root/analysis_stata/data"
capture mkdir "$out"

* ======================================================================
* USE PR (Person Recode) FILES — BOTH MEN AND WOMEN
* ======================================================================
* PR files contain ALL household members with sex, age, and education.
* This is essential for the DiD design: Female (treated) vs Male (control).

*Wave 1993
use "$root/BD_1993-94_DHS_11042023_421_202139/BDPR31DT/BDPR31FL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz{
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_
gen wave = 1993
save dhs1993.dta, replace

*Wave 1996
use "$root/BD_1996-97_DHS_12052023_716_202139/BDPR3ADT/BDPR3AFL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz{
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_

gen wave = 1996
save dhs1996.dta, replace

*Wave 1999
use "$root/BD_1999-00_DHS_12052023_259_202139/BDPR41DT/BDPR41FL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz{
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_

gen wave = 1999
save dhs1999.dta, replace

*Wave 2004
use "$root/BD_2004_DHS_12052023_344_202139/BDPR4JDT/BDPR4JFL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz{
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_

gen wave = 2004
save dhs2004.dta, replace

*Wave 2007
use "$root/BD_2007_DHS_12052023_345_202139/BDPR51DT/BDPR51FL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz{
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_

gen wave = 2007
save dhs2007.dta, replace

*Wave 2011
use "$root/BD_2011_DHS_12052023_345_202139/BDPR61DT/BDPR61FL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz {
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_

gen wave = 2011
save dhs2011.dta, replace

*Wave 2017
use "$root/BD_2017-18_DHS_12052023_258_202139/BDPR7RDT/BDPR7RFL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz {
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_

gen wave = 2017
save dhs2017.dta, replace

*Wave 2022
use "$root/BD_2022_DHS/BDPR81DT/BDPR81FL.DTA", clear
 foreach var in hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz {
            capture confirm variable `var'
            if _rc != 0 {
                disp "    Variable `var' not found, generating as missing."
                gen `var' = .
            }
        }
keep hv001 hv002 hvidx hv005 hv104 hv105 hv109 hv024 hv025 hv270 shdistr shupaz
rename hv005 weight
rename hv105 age
rename hv104 sex
rename hv109 educ_attain
rename hv024 division
rename hv025 urban
rename shdistr dist
rename shupaz upaz
rename hv270 wealth
rename hv001 cluster_id_

gen wave = 2022
save dhs2022.dta, replace

* Append all PR waves
clear
use dhs1993.dta
foreach w in dhs1996 dhs1999 dhs1999 dhs2004 dhs2004 dhs2007 dhs2011 dhs2017 dhs2022{
	append  using `w'

} 
disp "Total observations after appending all waves: `=_N'"

* ======================================================================
* DERIVE KEY VARIABLES
* ======================================================================

* Birth year: approximate as wave - age
gen birth_year = wave - age

* Female dummy (1 = female, 0 = male)
gen female = (sex == 2)
label define sex_lbl 0 "Male" 1 "Female", replace
label values female sex_lbl
label variable female "Female"

* Drop observations with missing age or sex
drop if age == . | sex == .
* Restrict to individuals old enough to have completed secondary (age >= 18)
keep if age >= 18

* Fix urban/rural to 0/1 binary (DHS: 1=Urban, 2=Rural)
replace urban = 0 if urban == 2
capture label drop urban_lbl
label define urban_lbl 1 "Urban" 0 "Rural", replace
label values urban urban_lbl

* ======================================================================
* OUTCOME: Secondary Education Completion
* ======================================================================
* hv109 (educ_attain): 0=no ed, 1=incomplete primary, 2=complete primary,
*   3=incomplete secondary, 4=complete secondary, 5=higher
gen sec_completed = 0
replace sec_completed = 1 if educ_attain >= 4 & educ_attain <= 5
replace sec_completed = . if educ_attain == . | educ_attain == 9 | educ_attain == 8
label variable sec_completed "Secondary Completion"

gen prim_completed = 0
replace prim_completed = 1 if educ_attain >= 2 & educ_attain <= 5
replace prim_completed = . if educ_attain == . | educ_attain == 9 | educ_attain == 8
label variable prim_completed "Primary Completion"


* ======================================================================
* COHORT DEFINITIONS
* ======================================================================

* --- 2003 Policy Reform ---
* Control: born <= 1987 (age 16+ in 2003, schooling done)
* Partially exposed: born 1988-1990 (age 13-16 in 2003)
* Fully exposed: born >= 1991 (age 12 or younger in 2003)
gen part_exp_03 = (birth_year >= 1988 & birth_year <= 1990)
gen full_exp_03 = (birth_year >= 1991)
gen ctrl_03     = (birth_year <= 1987)
* post_03: indicator for any exposure (partial or full) to 2003 policy
gen post_03     = (birth_year >= 1988)

* --- 2003 Policy Reform for primary school ---
* Control: born <= 1990(age 13+ in 2003, schooling done)
* Partially exposed: born 1991-1996 (age 7-12 in 2003)
* Fully exposed: born >= 1997 (age 6 or younger in 2003)
gen part_exp_03_prim = (birth_year >= 1991 & birth_year <= 1996)
gen full_exp_03_prim = (birth_year >= 1997)
gen ctrl_03_prim     = (birth_year <= 1990)
* post_03: indicator for any exposure (partial or full) to 2003 policy
gen post_03_prim     = (birth_year >= 1991)

*======================================================================
* DiD INTERACTION TERMS: Female × Post
* ======================================================================
gen female_post_03     = female * post_03
gen female_part_03     = female * part_exp_03
gen female_full_03     = female * full_exp_03

gen female_post_03_prim     = female * post_03_prim
gen female_part_03_prim     = female * part_exp_03_prim
gen female_full_03_prim     = female * full_exp_03_prim
* ======================================================================
* LABELS
* ======================================================================
label variable part_exp_03 "Part. Exposed 2003 (1987-1990)"
label variable full_exp_03 "Fully Exposed 2003 (\textgreater =1991)"
label variable ctrl_03 "Control 2003 (\textless =1986)"
label variable post_03 "Post-2003 Cohort"
label variable part_exp_03_prim "Part. Exposed 2003 (1991-1996)"
label variable full_exp_03_prim "Fully Exposed 2003 (\textgreater =1997)"
label variable ctrl_03_prim "Control 2003 (\textless =1990)"
label variable post_03_prim "Post-2003 Cohort"

label variable female_post_03 "Female x Post-2003"
label variable female_part_03 "Female x Part. Exposed 2003"
label variable female_full_03 "Female x Fully Exposed 2003"
label variable female_post_03_prim "Female x Post-2003"
label variable female_part_03_prim "Female x Part. Exposed 2003"
label variable female_full_03_prim "Female x Fully Exposed 2003"

label variable age "Age at Survey"
label variable urban "Urban Residence"
label variable wealth "Wealth Index"
label variable birth_year "Birth Year"
label variable division "Division"
gen age_in_2003 = 2003 - birth_year
gen age_in_2006 = 2006 - birth_year
label variable age_in_2003 "Age in 2003"
label variable age_in_2006 "Age in 2006"

// 年（year）とクラスターIDの組み合わせごとに一意な連番（1, 2, 3...）を振る
egen cluster_id = group(wave cluster_id)

// ラベル付け
label var cluster_id "Unique Cluster ID across years (non-panel)"

disp "=== Final dataset summary ==="
disp "Total obs: `=_N'"
tab female
tab wave

save "$out/pr_did_appended.dta", replace

disp "Data cleaning complete!"
