* Encoding: UTF-8.

* Desciptives

FREQUENCIES VARIABLES=Survived Sex SibSp Parch Pclass
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM MEAN MEDIAN MODE SKEWNESS SESKEW KURTOSIS SEKURT    
  /PIECHART FREQ
  /ORDER=ANALYSIS.

EXAMINE VARIABLES=Age Fare BY Survived
  /PLOT BOXPLOT STEMLEAF HISTOGRAM
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Recode

RECODE Sex ('male'=0) (ELSE=1) INTO sex_dum.
EXECUTE.

RECODE SibSp (0=0) (1=1) (ELSE=2) INTO SibSp_num.
EXECUTE.

RECODE Parch (0=0) (1=1) (ELSE=2) INTO Parch_num.
EXECUTE.

SPSSINC CREATE DUMMIES VARIABLE=SibSp_num 
ROOTNAME1=SibSp 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

SPSSINC CREATE DUMMIES VARIABLE=Parch_num 
ROOTNAME1=Parch 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

SPSSINC CREATE DUMMIES VARIABLE=Pclass 
ROOTNAME1=Pclass 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

* Exploration and visualization

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Sex COUNT()[name="COUNT"] Survived MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Sex=col(source(s), name("Sex"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Sex"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Sex by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Sex*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=SibSp_num COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: SibSp_num=col(source(s), name("SibSp_num"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("SibSp_num"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of SibSp_num by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(SibSp_num*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Parch_num COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Parch_num=col(source(s), name("Parch_num"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Parch_num"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Parch_num by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Parch_num*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Pclass by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Pclass*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

* Fit logistic regression

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER sex_dum Age SibSp_2 SibSp_3 Parch_2 Parch_3 Pclass_2 Pclass_3 
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH sex_dum Age SibSp_2 SibSp_3 Parch_2 Parch_3 
    Pclass_2 Pclass_3
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.

