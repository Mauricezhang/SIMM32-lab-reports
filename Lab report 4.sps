* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.

* Recode variables cortisol & sex

COMPUTE cortisol=(cortisol_serum + cortisol_saliva) / 2.
EXECUTE.

RECODE sex ('female'=0) ('male'=1) INTO sex_dum.
EXECUTE.

* Linear mixed model

MIXED pain WITH sex_dum age STAI_trait pain_cat mindfulness cortisol
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=sex_dum age STAI_trait pain_cat mindfulness cortisol | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED.

* Variance of fixed effects

DESCRIPTIVES VARIABLES=FXPRED_1
  /STATISTICS=MEAN STDDEV VARIANCE MIN MAX.

* Apply to dataset B

DATASET ACTIVATE DataSet2.
COMPUTE cortisol=(cortisol_serum + cortisol_saliva) / 2.
EXECUTE.

RECODE sex ('female'=0) ('male'=1) INTO sex_dum.
EXECUTE.

COMPUTE pred_by_A=2.616 + 0.218 * sex_dum - 0.038 * age - 0.016 * STAI_trait + 0.054 * pain_cat - 
    0.027 * mindfulness + 0.685 * cortisol.
EXECUTE.

* Observed variance in B
* Observed residual

COMPUTE obs_resid=pain - pred_by_A.
EXECUTE.

COMPUTE obs_res_sqa=obs_resid * obs_resid.
EXECUTE.

DESCRIPTIVES VARIABLES=obs_res_sqa
  /STATISTICS=MEAN SUM STDDEV MIN MAX.

* Regular residual

DESCRIPTIVES VARIABLES=pain
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE mean_resid=pain - 5.2.
EXECUTE.

COMPUTE mean_res_sqa=mean_resid * mean_resid.
EXECUTE.

DESCRIPTIVES VARIABLES=mean_res_sqa
  /STATISTICS=MEAN SUM STDDEV MIN MAX.


