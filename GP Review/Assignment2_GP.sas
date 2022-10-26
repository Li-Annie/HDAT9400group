/* Assignment 2 GP dataset     */
/* Sean DB                     */
/* 13/10/2022                  */

libname Assign2A '/home/u59893681/HDAT9400/Assignment 2A';

%include "/home/u59893681/HDAT9400/Assignment 2A/assignmt2a_formats.sas";

/* View the contents of the GP dataset and look at variables */
proc contents data=Assign2A.assignmt2a_gp_data;
run;

/*Look for exact matches accross all the variables, not just ID, 11 found and removed */
proc sort data=Assign2A.assignmt2a_gp_data out=no_dup nodupkey dupout=no_dup2;
by _all_;
run;


/*Look for duplicate IDs, each Id should be unique */
proc sort data=work.no_dup out=no_par nodupkey dupout=no_par2;
by ID;
run;

data work.missing;
set work.no_dup;
miss = cmiss(adverse_reaction, age, age_start, age_stop, cob, diast_bp,
drinks_day, ever_smoked, GP_last, healthcare_card,
height, reason, sex, smoke_now, syst_bp, weight);
run;

proc sort data=work.missing; by ID miss; run;

proc sort data=work.missing out=no_par nodupkey dupout=no_par2;
by ID;
run;

/*assess the freqeuncy of missing data values for the removed duplicates */
proc freq data=work.no_par2;
table miss;
run;

/* remove final 6 observations where no pattern is evident*/
data Assign2A.no_duplicates;
	set no_par;
	if ID = 152 or ID = 243 or ID = 2897
	then delete;
run;
 
*----------------------------------------------------------------;
/*Calcualte frequencies for categorical variables and summary stats for continuous */
proc freq data=Assign2A.no_duplicates; 
table adverse_reaction sex reason smoke_now ever_smoked healthcare_card cob/ missing;
run;

proc summary n min p25 mean p75 max nmiss print; 
var  age age_start age_stop diast_bp drinks_day height weight syst_bp ;
run;


*Start thinking about cross tabulations and the creation of new variables for things like BMI;

data Assign2A.no_duplicates;
	set Assign2A.no_duplicates;
if sex= '.'
then delete;
run;

















