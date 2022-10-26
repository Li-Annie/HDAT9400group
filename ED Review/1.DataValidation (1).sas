/**************************************************************
* Project: 	HDAT9400 - Management and curation of health data
* Purpose:	Data Validation
* Inputs: 	assignmt2a_ed_data.sas7bdat
* Author:	Annie Li
* Date:		15th Oct 2022
* Last modified: 15th Oct 2022
**************************************************************/

/* Checking the variables in the dataset against the EDA data dictionary */
proc contents data=a2data.assignmt2a_ed_data;
run;


/* Checking the whether the variables exceeded the maximum and minimum 
values specified in the EDA data dictionary */
proc univariate data=a2data.assignmt2a_ed_data;
var separation_mode triage_category health_insurance interpreter sex_ed cob_ed age_ed;
run;

/* Checking what levels are in the cob_ed variable in the ED dataset. */
proc freq data=a2data.assignmt2a_ed_data;
table cob_ed / missing;
run;

/* Checking which numeric variables has missing values */
proc means data=a2data.assignmt2a_ed_data min max nmiss;
var age_ed cob_ed ed_admission ed_separation health_insurance id interpreter separation_mode sex_ed triage_category;
run;


/* Checking percentage of missing values */
proc freq data=a2data.assignmt2a_ed_data;
tables sex_ed cob_ed health_insurance interpreter/ missing;
run;




