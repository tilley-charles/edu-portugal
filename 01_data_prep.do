capture log close _all
clear all
version 16.0
set linesize 150
set more off
set seed 298156384
set trace off
set tracedepth 3
set type double
set varabbrev off

local root C:\Users\\`c(username)'\Projects\portugal

log using "`root'\01_data_prep.log", replace

/*
 PROGRAM: 01_data_prep
 PURPOSE: Combine data, define constructs
*/

local in_mat  `root'\src\raw\student-mat.csv
local in_por  `root'\src\raw\student-por.csv
local out_csv `root'\src\final\student.csv
local out_dta `root'\src\final\student.dta

adopath ++ "`root'/ado"


/* load raw data */
foreach s in mat por {
  
  import delimited using "`in_`s''", clear varnames(1) case(preserve)

  * expected number of fields
  assert `c(k)'==33

  * subject flag
  gen subj = "`s'"

  * no identifier in raw files, verify each row is unique
  isid *

  gen pseudo_id = _n
    // only unique within subject

  tempfile `s'
  save   "``s''"

}


/* append frames */
use "`mat'", clear

append using "`por'"

tablist subj, sort(v) ab(32)


/* constructs */

* no missingness in data frame
mdesc *
assert wordcount("`r(notmiss_vars)'")==`c(k)'

* school
assert inlist(school, "GP", "MS")

gen school_GP = school=="GP"

tablist school_GP school, sort(v) ab(32)

rename school __school

* gender
assert inlist(sex, "F", "M")

gen female = sex=="F"

tablist female sex, sort(v) ab(32)

rename sex __sex

* age
assert inrange(age, 15, 22)

summ age

* urbanicity
assert inlist(address, "U", "R")

gen urban = address=="U"

tablist urban address, sort(v) ab(32)

rename address __address

* family size
assert inlist(famsize, "LE3", "GT3")

gen famsize_4plus = famsize=="GT3"

tablist famsize_4plus famsize, sort(v) ab(32)

rename famsize __famsize

* parent cohabitation status
assert inlist(Pstatus, "T", "A")

gen par_together = Pstatus=="T"

tablist par_together Pstatus, sort(v) ab(32)

rename Pstatus __Pstatus

* [mother/father] education
foreach g in m f {

  local G = strupper("`g'")

  assert inlist(`G'edu, 0, 1, 2, 3, 4)

  gen `g'_edu_coll = `G'edu==4
    // 0-3 = less than college
    // 4   = college

  tablist `g'_edu_coll `G'edu, sort(v) ab(32)

  rename `G'edu __`G'edu

}

* [mother/father] occupation
foreach g in m f {

  local G = strupper("`g'")

  assert inlist(`G'job, "teacher", "health", "services", "at_home", "other")
    // teacher = teacher
    // health care
    // civil services
    // stay-at-home
    // other

  foreach lev in teacher health services at_home other {

    gen `g'_job_`lev' = `G'job=="`lev'"

  }

  capture drop __validate
  egen         __validate = rowtotal(`g'_job_*)
  assert       __validate==1

  tablist `g'_job_* `G'job, sort(v) ab(32)

  rename `G'job __`G'job

}

* reason to choose school
assert inlist(reason, "home", "reputation", "course", "other")
  // close to home
  // school reputation
  // course preferences
  // other

gen sch_close = reason=="home"
  // splitting based on school proximity versus all other factors

tablist sch_close reason, sort(v) ab(32)

rename reason __reason

* guardian
assert inlist(guardian, "mother", "father", "other")
  // unclear exact definition of field
  // perhaps primary point-of-contact for school?

gen guardian_m = guardian=="mother"
gen guardian_f = guardian=="father"
gen guardian_o = guardian=="other"

assert guardian_m + guardian_f + guardian_o == 1

tablist guardian_* guardian, sort(v) ab(32)

rename guardian __guardian

* travel time to school
assert inlist(traveltime, 1, 2, 3, 4)
  // 1 = < 15 min
  // 2 = 15 to 30 min
  // 3 = 30 min to 1 hour
  // 4 = 1 hour

gen sch_trvl_time_ge15m = inlist(traveltime, 2, 3, 4)

assert (traveltime==1) + sch_trvl_time_ge15m == 1

tablist sch_trvl_time_ge15m traveltime, sort(v) ab(32)

rename traveltime __traveltime

* weekly study time
assert inlist(studytime, 1, 2, 3, 4)
  // 1 = < 2 hours
  // 2 = 2 to 5 hours
  // 3 = 5 to 10 hours
  // 4 = 10+ hours

gen wk_study_hrs_lt2   = studytime==1
gen wk_study_hrs_2to5  = studytime==2
gen wk_study_hrs_5plus = inlist(studytime, 3, 4)

assert wk_study_hrs_lt2 + wk_study_hrs_2to5 + wk_study_hrs_5plus == 1

tablist wk_study_* studytime, sort(v) ab(32)

rename studytime __studytime

* number of past class failures
assert inlist(failures, 0, 1, 2, 3)

summ failures

* additional school educational support
* additional family educational support
* additional paid classes
* extra-curricular activities
* internet access at home
* attended nursey school
* wants to attend higher education
* in a romantic relationship

local orig schoolsup    famsup       paid     activities internet      nursery     higher     romantic
local new  sch_edu_supp fam_edu_supp paid_cls extracurr  home_internet att_nursery goal_hi_ed in_relation

assert `: word count `orig''==`: word count `new''

forvalues x = 1/`: word count `orig'' {

  local o : word `x' of `orig'
  local n : word `x' of `new'

  assert inlist(`o', "no", "yes")

  gen `n' = `o'=="yes"

  tablist `n' `o', sort(v) ab(32)

  rename `o' __`o'

}

* SCALE: quality of family relationships (1 = very bad, 5 = excellent)
* SCALE: free time after school (1 = very low, 5 = very high)
* SCALE: go out with friends (1 = very low, 5 = very high)
* SCALE: weekday alcohol consumption (1 = very low, 5 = very high)
* SCALE: weekend alcohol consumption (1 = very low, 5 = very high)
* SCALE: current health status (1 = very bad, 5 = very good)

local orig famrel       freetime     goout        Dalc          Walc          health
local new  scl_fam_rel scl_free_time scl_go_frnds scl_alc_wkday scl_alc_wkend scl_health

assert `: word count `orig''==`: word count `new''

forvalues x = 1/`: word count `orig'' {

  local o : word `x' of `orig'
  local n : word `x' of `new'

  assert inlist(`o', 1, 2, 3, 4, 5)
  qui summ `o'
  assert `r(min)'==1 & `r(max)'==5

  rename `o' `n'

  tablist `n', sort(v) ab(32)

}

* absences
summ absences

assert `r(min)'==0 & `r(max)'==75

* pre-/post-test
summ G1 G2 G3

assert `r(min)'==0 & `r(max)'==20

rename G1 pre_test1
rename G2 pre_test2
rename G3 post_test

summ post_test, detail

gen post_test_gtp25 = post_test>`r(p25)'
gen post_test_gtp50 = post_test>`r(p50)'
gen post_test_gtp75 = post_test>`r(p75)'


/* output */
drop __*

isid subj pseudo_id

order subj pseudo_id ///
      school_GP female age urban famsize_4plus par_together guardian_* ///
      m_edu_coll m_job_* ///
      f_edu_coll f_job_* ///
      sch_close sch_trvl_time_ge15m failures absences ///
      wk_study_* *_edu_supp paid_cls extracurr home_internet att_nursery goal_hi_ed ///
      in_relation scl_* ///
      pre_test1 pre_test2 post_test post_test_gt*

save "`out_dta'", replace
export delimited using "`out_csv'", replace



capture log close _all

