/**************************************************************
* Project: 	HDAT9400 - Management and curation of health data
* Purpose:	Data Cleaning
* Inputs: 	assignmt2a_ed_data.sas7bdat
* Outputs:	
* Author:	Annie Li
* Date:		15th Oct 2022
* Last modified: 15th Oct 2022
**************************************************************/


/* Checking for complete duplicates in the ED dataset 
through sorting by unique person ID*/
proc sort data = a2data.assignmt2a_ed_data nodupkey out= a2code.edversion1 dupout=a2code.edcompletedup;
by _ALL_;
run;


/* Checking for partial duplicates in the edversion1 dataset in the a2code library  */
/* using flagging.  */
data a2code.edversion1;
set a2code.edversion1;
if cob_ed =. then flag1 = 1;
if dx1 ='.' then flag2 = 1;
if dx2 ='.' then flag3 = 1;
if dx3 ='.' then flag4 = 1;
if dx4 ='.' then flag5 = 1;
if dx5 ='.' then flag6 = 1;
if health_insurance =. then flag7 =1;
if interpreter =. then flag8 =1;
if sex_ed =. then flag9 =1;
nmiss = sum(flag1, flag2, flag3, flag4, flag5, flag6, flag7, flag8, flag9);
run;


proc sort data=a2code.edversion1 nodupkey out=a2code.cleaned dupout=a2code.dup;
by id cob_ed ed_admission nmiss;
run;

/* Check whether there is pattern of missing data by month */
/* Created ad_month and sep_month variable for ED admission date 
and ED separation date based on the month of ED admission and ED separation. */
data a2code.cleaned;
set a2code.cleaned;
ad_month = month(ed_admission);
sep_month = month(ed_separation);
run;


proc freq data=a2code.cleaned;
table ad_month*cob_ed/nocol norow nopercent missing;
table ad_month*health_insurance/nocol norow nopercent missing;
table ad_month*interpreter/nocol norow nopercent missing;
table ad_month*sex_ed/nocol norow nopercent missing;
table sep_month*cob_ed/nocol norow nopercent missing;
table sep_month*health_insurance/nocol norow nopercent missing;
table sep_month*interpreter/nocol norow nopercent missing;
table sep_month*sex_ed/nocol norow nopercent missing;
run;

/* Change the format of the cob_ed from 2 levels to 3 levels */
proc format;
value fcob_ed
1 = 1
2 = 2
99 = 3;
run;

/* Final copy of cleaned dataset without duplicate and using new format for cob_ed */
data a2clean.tidy;
set a2code.cleaned (drop = ad_month sep_month);
format cob_ed fcob_ed.;
run;


