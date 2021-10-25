*! version 1.2 -- revised 7/15/2010
*! version 1.3 -- revised 4/15/2015 by crw changing the Stata version number from 7 to 12
capture program drop tablist
program define tablist
  version 12
  syntax varlist [if] [in] [, Sort(string) Perc(string) *]

  preserve

  contract `varlist' `if' `in' , freq(_Freq_)
  if "`sort'" == "v" {
    gsort `varlist'
  }
  else if "`sort'" == "+f" {
    gsort +_Freq_
  } 
  else {
    gsort -_Freq_
  }
  generate _CFreq_ = sum(_Freq_)
  generate _Perc_ = (_Freq_ / _CFreq_[_N])*100
  generate _CPerc_ = (_CFreq_ / _CFreq_[_N])*100
  format _Freq_ _CFreq_ %5.0f
  format _Perc_ _CPerc_ %6.2f

  list `varlist' _Freq_ _Perc_ _CFreq_ _CPerc_ , noobs `options'
  
  restore

end

