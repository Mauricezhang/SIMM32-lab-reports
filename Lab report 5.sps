* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.

* Check coding errors

FREQUENCIES VARIABLES=pain1 pain2 pain3 pain4 sex age STAI_trait pain_cat cortisol_serum 
    cortisol_saliva mindfulness
  /FORMAT=NOTABLE
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN MEDIAN MODE SKEWNESS SESKEW KURTOSIS SEKURT
  /ORDER=ANALYSIS.

* Recode & restruture

VARSTOCASES
  /MAKE pain FROM pain1 pain2 pain3 pain4
  /INDEX=time(4) 
  /KEEP=ID sex age STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva weight IQ 
    household_income 
  /NULL=KEEP.

RECODE sex ('female'=0) ('male'=1) INTO sex_dum.
EXECUTE.

* Random intercept model

MIXED pain WITH time sex_dum age STAI_trait pain_cat mindfulness cortisol_serum
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=time sex_dum age STAI_trait pain_cat mindfulness cortisol_serum | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED RESID.

* Random slope model

MIXED pain WITH time sex_dum age STAI_trait pain_cat mindfulness cortisol_serum
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=time sex_dum age STAI_trait pain_cat mindfulness cortisol_serum | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED RESID.

* Visualize the model fit

VARSTOCASES
  /MAKE pain FROM pain PRED_int PRED_sl
  /INDEX=data_type(pain) 
  /KEEP=ID time sex sex_dum age STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva 
    weight IQ household_income RESID_int RESID_sl 
  /NULL=KEEP.

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(pain)[name="MEAN_pain"] data_type 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: MEAN_pain=col(source(s), name("MEAN_pain"))
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("Mean pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line Mean of pain by time by data_type"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time*MEAN_pain), color.interior(data_type), missing.wings())
END GPL.

OUTPUT EXPORT
  /CONTENTS  EXPORT=VISIBLE  MODELVIEWS=PRINTSETTING
  /JPG  IMAGEROOT='F:\Master\SIMM32\Exercises\Lab_5\ID.jpg'
     PERCENTSIZE=100  GRAYSCALE=NO.

* Add quadratic term of time

DESCRIPTIVES VARIABLES=time
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE time_centered=time - 2.5.
EXECUTE.

COMPUTE time_centered_sq=time_centered * time_centered.
EXECUTE.

* Random slope model with quadratic term

MIXED pain WITH sex_dum age STAI_trait pain_cat mindfulness cortisol_serum time_centered 
    time_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=sex_dum age STAI_trait pain_cat mindfulness cortisol_serum time_centered time_centered_sq 
    | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time_centered | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED RESID.

* Visulize the model fit

VARSTOCASES
  /MAKE pain FROM pain PRED_qua
  /INDEX=data_type(pain) 
  /KEEP=ID time time_centered time_centered_sq sex sex_dum age STAI_trait pain_cat mindfulness 
    cortisol_serum cortisol_saliva weight IQ household_income PRED_int RESID_int PRED_sl RESID_sl 
    RESID_qua 
  /NULL=KEEP.

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(pain)[name="MEAN_pain"] data_type 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time=col(source(s), name("time"), unit.category())
  DATA: MEAN_pain=col(source(s), name("MEAN_pain"))
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time"))
  GUIDE: axis(dim(2), label("Mean pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line Mean of pain by time by data_type"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time*MEAN_pain), color.interior(data_type), missing.wings())
END GPL.

OUTPUT EXPORT
  /CONTENTS  EXPORT=VISIBLE  MODELVIEWS=PRINTSETTING
  /JPG  IMAGEROOT='F:\Master\SIMM32\Labs\Lab 5\Graph 21-40\ID.jpg'
     PERCENTSIZE=100  GRAYSCALE=NO.

* Model diagnostics
* Influential cases

EXAMINE VARIABLES=pain BY ID
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Re-run the model without ID_11

DATASET ACTIVATE DataSet2.
MIXED pain WITH sex_dum age STAI_trait pain_cat mindfulness cortisol_serum time_centered 
    time_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=sex_dum age STAI_trait pain_cat mindfulness cortisol_serum time_centered time_centered_sq 
    | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT time_centered | SUBJECT(ID) COVTYPE(UN).

* Normality of residuals

EXAMINE VARIABLES=RESID_qua
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Linearity

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=PRED_qua RESID_qua MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: PRED_qua=col(source(s), name("PRED_qua"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("Predicted Values"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by Predicted Values"))
  ELEMENT: point(position(PRED_qua*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=sex_dum RESID_qua MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: sex_dum=col(source(s), name("sex_dum"), unit.category())
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("sex_dum"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by sex_dum"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(sex_dum*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age RESID_qua MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by age"))
  ELEMENT: point(position(age*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait RESID_qua MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by STAI_trait"))
  ELEMENT: point(position(STAI_trait*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat RESID_qua MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by pain_cat"))
  ELEMENT: point(position(pain_cat*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness RESID_qua MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by mindfulness"))
  ELEMENT: point(position(mindfulness*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum RESID_qua MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_centered RESID_qua MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_centered=col(source(s), name("time_centered"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("time_centered"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by time_centered"))
  ELEMENT: point(position(time_centered*RESID_qua))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_centered_sq RESID_qua MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_centered_sq=col(source(s), name("time_centered_sq"))
  DATA: RESID_qua=col(source(s), name("RESID_qua"))
  GUIDE: axis(dim(1), label("time_centered_sq"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by time_centered_sq"))
  ELEMENT: point(position(time_centered_sq*RESID_qua))
END GPL.

* Multicollinearity

CORRELATIONS
  /VARIABLES=sex_dum age STAI_trait pain_cat mindfulness cortisol_serum time_centered 
    time_centered_sq
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* Constant variance across clusters

SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

COMPUTE RESID_qua_sq=RESID_qua * RESID_qua.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT RESID_qua_sq
  /METHOD=ENTER ID_2 ID_3 ID_4 ID_5 ID_6 ID_7 ID_8 ID_9 ID_10 ID_11 ID_12 ID_13 ID_14 ID_15 ID_16 
    ID_17 ID_18 ID_19 ID_20.

* Normal distribution of random effects

MIXED pain WITH sex_dum age STAI_trait pain_cat mindfulness cortisol_serum time_centered 
    time_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=sex_dum age STAI_trait pain_cat mindfulness cortisol_serum time_centered time_centered_sq 
    | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT time_centered | SUBJECT(ID) COVTYPE(UN) SOLUTION.

DATASET ACTIVATE DataSet3.
EXAMINE VARIABLES=VAR00001
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.
