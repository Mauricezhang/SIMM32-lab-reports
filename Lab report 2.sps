* Encoding: UTF-8.
* Geting data

GET DATA
  /TYPE=XLSX
  /FILE='F:\Master\SIMM32\Lab 2\lab_2_assignment_dataset.xlsx'
  /SHEET=name 'home_sample_1'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

* Data check

FREQUENCIES VARIABLES=pain sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN MEDIAN MODE SKEWNESS SESKEW KURTOSIS SEKURT
  /HISTOGRAM
  /ORDER=ANALYSIS.

* Recoding

RECODE sex ('female'=0) ('male'=1) (MISSING=SYSMIS) INTO sex_dum.
EXECUTE.

* Multiple regression

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER sex_dum age
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

* Check Outlier

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID COO_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: COO_1=col(source(s), name("COO_1"))
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Cook's Distance"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of Cook's Distance by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*COO_1))
END GPL.

* Linearity

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by age"))
  ELEMENT: point(position(age*pain))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by STAI_trait"))
  ELEMENT: point(position(STAI_trait*pain))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by pain_cat"))
  ELEMENT: point(position(pain_cat*pain))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*pain))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_saliva pain MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_saliva=col(source(s), name("cortisol_saliva"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("cortisol_saliva"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by cortisol_saliva"))
  ELEMENT: point(position(cortisol_saliva*pain))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter with Fit Line of pain by mindfulness"))
  ELEMENT: point(position(mindfulness*pain))
END GPL.

* Normality of residuals

EXAMINE VARIABLES=RES_1
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Heteroscedasticity

COMPUTE RES_squ=RES_1 * RES_1.
EXECUTE.

DATASET ACTIVATE DataSet1.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT RES_squ
  /METHOD=ENTER sex_dum age
  /METHOD=ENTER STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /SCATTERPLOT=(*ZRESID ,*ZPRED).

* Multicollinearity

COMPUTE cortisol=(cortisol_serum + cortisol_saliva) / 2.
EXECUTE.

* Multiple regression after diagnostics

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER sex_dum age
  /METHOD=ENTER STAI_trait pain_cat cortisol mindfulness
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

