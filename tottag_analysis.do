*========================================================
* tottag_analysis.do
*--------------------------------------------------------
* Reproduces the cell values for the manuscript and
* supplemental tables in Barnett et al. (2026).
*
* Companion repository:
*   https://github.com/[user]/tottag-acceptability-2026
*
* Manuscript:
*   Barnett et al. (2026). Measuring caregiver-child
*   proximity in daily life: Feasibility and acceptability
*   of the TotTag wearable sensor.
*   Infant Behavior and Development.
*   https://doi.org/10.1016/j.infbeh.2026.102221
*
* Runs on:
*   data/tottag_acceptability_data.dta  (or .csv)
*   N = 129 families, wide format
*
* Software: Stata 18.0 (compatible with Stata >= 15)
* Expected runtime: under 1 minute
*========================================================

clear all
set more off
version 15
capture log close

*--------------------------------------------------------
* 0) Load the de-identified analytic dataset
*--------------------------------------------------------
* Adjust path if running from outside the repository root.
* .dta is preferred (preserves value labels); .csv is provided as backup.
capture noisily use "data/tottag_acceptability_data.dta", clear
if _rc {
    display as text "Falling back to CSV import..."
    import delimited "data/tottag_acceptability_data.csv", clear case(preserve)
}

* Confirm sample size
assert _N == 129
display _newline as result "Loaded dataset: N = " _N " families."


*========================================================
* 1) Composite reconstruction (transparency check)
*--------------------------------------------------------
* Composites are pre-computed in the shared dataset. This
* block reconstructs them from raw items so reviewers can
* verify the construction. Values should match exactly.
*========================================================

* --- Item 12 (Tech Issues, Yes/No -> 1/5) ----------------
foreach cg in cg1 cg2 {
    capture drop acc12_remap_`cg'_chk
    gen byte acc12_remap_`cg'_chk = .
    replace  acc12_remap_`cg'_chk = 1 if tottag_accept12_`cg' == 1   // Yes
    replace  acc12_remap_`cg'_chk = 5 if tottag_accept12_`cg' == 0   // No
}

* --- Item 5 (Reminders helpful: Yes/Sometimes/No -> 5/3/1) ---
foreach cg in cg1 cg2 {
    capture drop acc5_remap_`cg'_chk
    gen byte acc5_remap_`cg'_chk = .
    replace  acc5_remap_`cg'_chk = 5 if tottag_accept5_`cg' == 1
    replace  acc5_remap_`cg'_chk = 3 if tottag_accept5_`cg' == 2
    replace  acc5_remap_`cg'_chk = 1 if tottag_accept5_`cg' == 3
}

* --- Item 9 (Perceived benefit: 1/2/3 -> 1/3/5) ----------
foreach cg in cg1 cg2 {
    capture drop acc9_rescaled_`cg'_chk
    gen byte acc9_rescaled_`cg'_chk = .
    replace  acc9_rescaled_`cg'_chk = 1 if tottag_accept9_`cg' == 1
    replace  acc9_rescaled_`cg'_chk = 3 if tottag_accept9_`cg' == 2
    replace  acc9_rescaled_`cg'_chk = 5 if tottag_accept9_`cg' == 3
}

* --- Item 10 (Re-participate: 1/2/3 -> 1/3/5) ------------
foreach cg in cg1 cg2 {
    capture drop acc10_rescaled_`cg'_chk
    gen byte acc10_rescaled_`cg'_chk = .
    replace  acc10_rescaled_`cg'_chk = 1 if tottag_accept10_`cg' == 1
    replace  acc10_rescaled_`cg'_chk = 3 if tottag_accept10_`cg' == 2
    replace  acc10_rescaled_`cg'_chk = 5 if tottag_accept10_`cg' == 3
}

* --- Item 14 (Tech support quality, drop NA = 6) ---------
foreach cg in cg1 cg2 {
    capture drop acc14_clean_`cg'_chk
    gen byte acc14_clean_`cg'_chk = tottag_accept14_`cg'
    replace  acc14_clean_`cg'_chk = . if tottag_accept14_`cg' == 6
}

* --- Item 6 (Interference REVERSED -> Integration into Routines) ---
foreach cg in cg1 cg2 {
    capture drop acc6_rev_`cg'_chk
    gen byte acc6_rev_`cg'_chk = 6 - tottag_accept6_`cg'
}

* --- Procedural Feasibility: mean of items 12, 5, 4 (>=2 of 3) ---
foreach cg in cg1 cg2 {
    capture drop dom_procfeas_`cg'_chk _nproc_`cg'
    egen double dom_procfeas_`cg'_chk = ///
        rowmean(acc12_remap_`cg'_chk acc5_remap_`cg'_chk tottag_accept4_`cg')
    egen byte _nproc_`cg' = ///
        rownonmiss(acc12_remap_`cg'_chk acc5_remap_`cg'_chk tottag_accept4_`cg')
    replace dom_procfeas_`cg'_chk = . if _nproc_`cg' < 2
    drop _nproc_`cg'
}

* Verify against pre-computed composites
display _newline as text "{hline 60}"
display as result "Composite verification (differences should be ~0):"
foreach cg in cg1 cg2 {
    quietly count if abs(acc12_remap_`cg'  - acc12_remap_`cg'_chk)  > .001 & !missing(acc12_remap_`cg')
    display "  acc12_remap_`cg' mismatches: " r(N)
    quietly count if abs(dom_procfeas_`cg' - dom_procfeas_`cg'_chk) > .001 & !missing(dom_procfeas_`cg')
    display "  dom_procfeas_`cg' mismatches: " r(N)
}

* Drop the check variables to keep the workspace tidy
drop *_chk


*========================================================
* 2) TABLE 1: Family and Caregiver Characteristics (N = 125)
*--------------------------------------------------------
* Table 1 uses the analytic sample marked by final_model_new == 1.
*========================================================

preserve
keep if final_model_new == 1

display _newline as text "{hline 60}"
display as result "TABLE 1 - Family and Caregiver Characteristics (N = " _N ")"

* Household characteristics
tab hh_income_cat, missing                          // income brackets, N (%)
summarize n_children_home                           // children in home: Mean (SD)
tab partnered, missing                              // 1 = two-caregiver, 0 = single

* Caregiver 1 characteristics
tab cg1_gender, missing
tab edu_cg1, missing
tab employed_cg1, missing

* Caregiver 2 characteristics
tab cg2_gender, missing
tab edu_cg2, missing
tab employed_cg2, missing

* Child (inferred) race and ethnicity — the manuscript reports parent-level
* race/ethnicity; those variables were derived from intake records held on
* the lab server and are not included in this public dataset. The child-
* level inferred values are reported below for completeness.
tab child_race, missing
tab child_eth, missing

restore


*========================================================
* 3) TABLE 2: Family-Level Procedural Feasibility & Acceptability (N = 129)
*========================================================
display _newline as text "{hline 60}"
display as result "TABLE 2 - Family-level composites (N = " _N ")"

summarize dom_procfeas_family ///
    dom_ease_family dom_comfort_family dom_privacy_family ///
    dom_benefit_family dom_burden_family dom_sat_family ///
    dom_acceptability_family


*========================================================
* 4) TABLE 3: Adherence Indicators for Daily TotTag Survey Completion
*========================================================
display _newline as text "{hline 60}"
display as result "TABLE 3 - Daily survey completion (max = 7 per row)"

foreach v in survey_completion_morning survey_completion_evening ///
             survey_completion_morning_cr2 survey_completion_evening_cr2 ///
             survey_morning_fam survey_evening_fam {
    quietly summarize `v'
    display as text %-40s "`v'" ///
        "  Mean = " %5.2f r(mean) ///
        "  SD = "  %5.2f r(sd)   ///
        "  % of max = " %5.1f (r(mean)/7)*100 "%"
}


*========================================================
* 5) TABLE 4: Spearman Correlations (14 variables, N = 129)
*========================================================
display _newline as text "{hline 60}"
display as result "TABLE 4 - Spearman correlations"

* Ensure total survey completion is present (recomputed for safety)
capture drop survey_total_fam
egen   survey_total_fam = rowtotal(survey_morning_fam survey_evening_fam)
label var survey_total_fam "Family: Total survey completion (0-14)"

spearman ///
    dom_procfeas_family ///       // 1.  Procedural Feasibility
    dom_ease_family     ///       // 2.  Ease of Use
    dom_comfort_family  ///       // 3.  Comfort
    dom_privacy_family  ///       // 4.  Privacy
    dom_benefit_family  ///       // 5.  Perceived Scientific Benefit
    dom_burden_family   ///       // 6.  Burden / Integration into Routines
    dom_sat_family      ///       // 7.  Overall Satisfaction
    survey_evening_fam  ///       // 8.  Evening Survey Completion
    survey_morning_fam  ///       // 9.  Morning Survey Completion
    survey_total_fam    ///       // 10. Total Survey Completion
    employed_cg1        ///       // 11. Caregiver 1 Employed
    employed_cg2        ///       // 12. Caregiver 2 Employed
    hh_income_cat       ///       // 13. Household Income
    age_months,         ///       // 14. Child Age (months)
    stats(rho p) star(.05)


*========================================================
* 6) TABLE 5: Predictors of Satisfaction (N = 125)
*========================================================
display _newline as text "{hline 60}"
display as result "TABLE 5 - Predictors of Satisfaction"

preserve
keep if final_model_new == 1

* Standardized betas
regress dom_sat_family ///
    dom_procfeas_family ///
    dom_ease_family     ///
    dom_comfort_family  ///
    dom_privacy_family  ///
    dom_benefit_family  ///
    dom_burden_family,  ///
    beta

* Unstandardized estimates with 95% CIs
regress dom_sat_family ///
    dom_procfeas_family ///
    dom_ease_family     ///
    dom_comfort_family  ///
    dom_privacy_family  ///
    dom_benefit_family  ///
    dom_burden_family,  ///
    level(95)

* VIF check
vif

restore


*========================================================
* 7) SUPPLEMENTAL TABLE S2: CG1 Acceptability (n = 124)
*========================================================
display _newline as text "{hline 60}"
display as result "TABLE S2 - Caregiver 1 acceptability"

summarize dom_procfeas_cg1 ///
    dom_ease_cg1 dom_comfort_cg1 dom_privacy_cg1 ///
    dom_benefit_cg1 dom_burden_cg1 dom_sat_cg1 ///
    dom_acceptability_cg1


*========================================================
* 8) SUPPLEMENTAL TABLE S3: CG2 Acceptability (n = 108)
*========================================================
display _newline as text "{hline 60}"
display as result "TABLE S3 - Caregiver 2 acceptability"

summarize dom_procfeas_cg2 ///
    dom_ease_cg2 dom_comfort_cg2 dom_privacy_cg2 ///
    dom_benefit_cg2 dom_burden_cg2 dom_sat_cg2 ///
    dom_acceptability_cg2


*========================================================
* 9) SUPPLEMENTAL TABLE S6: Outcomes by Deployment Tertile
*--------------------------------------------------------
* deploy_tertile is pre-computed in the shared dataset
* (tertile of the date families received TotTag devices).
* Date ranges reported in the Supplemental Table S6 footnote:
*   Early third:  Jun 27, 2024 - Feb 24, 2025
*   Middle third: Mar 4, 2025 - Jul 6, 2025
*   Late third:   Jul 7, 2025 - Oct 27, 2025
*========================================================
display _newline as text "{hline 60}"
display as result "TABLE S6 - Outcomes by TotTag deployment tertile"

label define tert_lbl 1 "Early third" 2 "Middle third" 3 "Late third", replace
label values deploy_tertile tert_lbl

* Sample sizes per tertile
tab deploy_tertile

* Mean (SD) by tertile
tabstat dom_procfeas_family dom_ease_family dom_comfort_family ///
        dom_privacy_family dom_benefit_family dom_burden_family ///
        dom_sat_family survey_morning_fam survey_evening_fam, ///
    by(deploy_tertile) statistics(mean sd) format(%5.2f)

* Wilcoxon rank-sum: Early vs. Late
local outcomes ///
    dom_procfeas_family dom_ease_family dom_comfort_family ///
    dom_privacy_family dom_benefit_family dom_burden_family ///
    dom_sat_family survey_morning_fam survey_evening_fam

foreach v of local outcomes {
    display _newline as text "{hline 60}"
    display as result "`v': Early vs. Late rank-sum test"
    ranksum `v' if inlist(deploy_tertile, 1, 3), by(deploy_tertile)
}

display _newline as result ///
    "=== End of tottag_analysis.do ==="
