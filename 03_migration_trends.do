clear all
set more off

global root "C:/Users/mm_wi/Documents/research/migration"
global data "$root/other_data"
global results "$root/analysis_stata/results"
global manuscript "$root/manuscript"
capture mkdir "$results"

* ======================================================================
* 1. Load and Clean Excel Migration Data
* ======================================================================
import excel using "$data/migration.xlsx", clear
rename A year
rename B pct_women
rename C num_women

* Correct data entry typo for 2011 where 5.38 was entered as 538
replace pct_women = 5.38 if year == 2011 & pct_women > 100

label variable year "Year"
label variable pct_women "% of Women among Total Migrants"
label variable num_women "Number of Women Workers Migrated"

* Save cleaned dataset
save "$data/migration_trends.dta", replace

* ======================================================================
* 2. Dual-Axis Line Graph
* ======================================================================
twoway (connected num_women year, yaxis(1) lcolor(navy) mcolor(navy) msymbol(O) msize(small) lwidth(medthick)) ///
       (connected pct_women year, yaxis(2) lcolor(maroon) mcolor(maroon) msymbol(D) msize(small) lwidth(medthick) lpattern(dash)), ///
       xline(2003, lcolor(gs9) lpattern(shortdash) lwidth(medthin)) ///
       text(36000 2003 "2003 Reform", placement(w) size(small) color(black)) ///
       ytitle("Number of Women Workers Migrated", axis(1) color(navy) size(small)) ///
       ytitle("% of Women among Total Workers Migrated", axis(2) color(maroon) size(small)) ///
       ylabel(0(10000)40000, axis(1) format(%9.0fc) labsize(small) grid) ///
       ylabel(0(2)14, axis(2) format(%9.1f) labsize(small)) ///
       xlabel(1991(2)2013, angle(45) labsize(small)) ///
       xtitle("Year", size(small)) ///
       legend(order(1 "Number of Women Workers Migrated (Left Axis)" ///
                    2 "% of Women among Total Workers Migrated (Right Axis)") ///
              rows(2) position(6) size(small) region(lcolor(none))) ///
       title("Trends in Female International Migration from Bangladesh (1991–2013)", size(medium)) ///
       note("Source: Bureau of Manpower, Employment and Training (BMET). Dashed vertical lines indicate the 2003 policy reform.", size(vsmall)) ///
       graphregion(fcolor(white) lcolor(white)) bgcolor(white) ///
       name(g_dual, replace)

graph export "$results/female_migration_trends_dual.jpg", name(g_dual) as(jpg) quality(100) width(1600) replace
graph export "$manuscript/female_migration_trends_dual.jpg", name(g_dual) as(jpg) quality(100) width(1600) replace
graph export "$results/female_migration_trends_dual.pdf", name(g_dual) as(pdf) replace

* ======================================================================
* 3. Two-Panel Combined Graph
* ======================================================================
* Panel A: Number of female migrants
twoway (connected num_women year, lcolor(navy) mcolor(navy) msymbol(O) msize(small) lwidth(medthick)), ///
       xline(2003, lcolor(gs9) lpattern(shortdash) lwidth(medthin)) ///
       text(35000 2003 "2003", placement(w) size(vsmall) color(black)) ///
       ytitle("Number of Women Workers Migrated", size(small)) ///
       ylabel(0(10000)40000, format(%9.0fc) labsize(small) grid) ///
       xlabel(1991(3)2013, angle(45) labsize(small)) ///
       xtitle("Year", size(small)) ///
       title("(a) Number of Women Workers Migrated", size(medium)) ///
       graphregion(fcolor(white) lcolor(white)) bgcolor(white) name(g_num, replace)

* Panel B: Percentage of female migrants
twoway (connected pct_women year, lcolor(maroon) mcolor(maroon) msymbol(D) msize(small) lwidth(medthick)), ///
       xline(2003, lcolor(gs9) lpattern(shortdash) lwidth(medthin)) ///
       text(12 2003 "2003", placement(w) size(vsmall) color(black)) ///
       ytitle("% of Women Migrants", size(small)) ///
       ylabel(0(2)14, format(%9.1f) labsize(small) grid) ///
       xlabel(1991(3)2013, angle(45) labsize(small)) ///
       xtitle("Year", size(small)) ///
       title("(b) % of Women among Total Workers Migrated", size(medium)) ///
       graphregion(fcolor(white) lcolor(white)) bgcolor(white) name(g_pct, replace)

graph combine g_num g_pct, rows(1) xsize(10) ysize(4.8) ///
       title("Female International Migration Trends from Bangladesh (1991–2013)", size(medium)) ///
       note("Source: Bureau of Manpower, Employment and Training (BMET). Vertical dashed lines denote the 2003 policy reform.", size(vsmall)) ///
       graphregion(fcolor(white) lcolor(white)) ///
       name(g_comb, replace)

graph export "$results/female_migration_trends_combined.jpg", name(g_comb) as(jpg) quality(100) width(2000) replace
graph export "$manuscript/female_migration_trends_combined.jpg", name(g_comb) as(jpg) quality(100) width(2000) replace
graph export "$results/female_migration_trends_combined.pdf", name(g_comb) as(pdf) replace

* Default exported files
graph export "$results/female_migration_trends.jpg", name(g_comb) as(jpg) quality(100) width(2000) replace
graph export "$manuscript/female_migration_trends.jpg", name(g_comb) as(jpg) quality(100) width(2000) replace
graph export "$results/female_migration_trends.pdf", name(g_comb) as(pdf) replace

disp "All migration trends graphs generated successfully!"
exit, clear
