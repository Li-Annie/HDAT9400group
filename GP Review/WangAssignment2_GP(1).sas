/* Assignment 2 GP dataset     */
/* WANG DB                     */
/* 20/10/2022                  */

libname Assign2A '/home/u62313591/HDAT9400/Assignment 2A';
%include "/home/u62313591/HDAT9400/Assignment 2A/assignmt2a_formats.sas";

/* To make a permanent copy of dataset survey*/
 data Assign2A_gp_data_copy2;
	set Assign2A.assignmt2a_gp_data;
	run;
	
*----------------------------------------------------------------;
*START OF DATA QUALITY CHECKS AND NEW VARIABLES CREATION 
*----------------------------------------------------------------;
	
/* Finding number of records*/
	*  Summary information about the contents of the GP dataset;
	*  The data contains 5837 Observations , with 17 variables 
	*  The variables corresponds to the data dictionary provided;

 proc contents data=Assign2A_gp_data_copy2; 
	run; 


/* The number of records for each ID*/
	* This can be used to inspect the duplicates for each ID;
	* Each ID with more than one record is a flag for duplicates and closer inspection 
	* Is required;
 proc summary data=Assign2A_gp_data_copy2 nway; 
	class ID;
	output out=ID_check;
/* ID with more than 1 observation*/
	* We identify the specific IDs with more than one records/observations;
 proc print data=ID_check noobs; 
		where _freq_>1;
	run; * There were 42 observations read from the data set WORK.ID_CHECK.
       WHERE _freq_>1;
       
/* Print the IDs with more than one obs*/
	* We printout the specific records where ID has more than 1 observations
	* This can help to show the exact duplicates and partial duplicates, 
	* including inconsistent data input;
 proc print data=Assign2A_gp_data_copy2 noobs;
		where ID in (1, 52, 152, 243, 439, 858, 977, 1474, 1480, 1565, 1712, 
  1848, 1945, 2519, 2682, 2781, 2845, 2876, 2887, 2897, 
  3059, 3174, 3520, 3623, 3711, 3742, 3943, 3965, 4114, 4154, 
  4333, 4348, 4440, 4691, 4705, 4775, 4900, 4916, 5410, 5452, 5484, 5502);
  run;
	
/*Look for exact matches accross all the variables, not just ID, 11 found and removed */
	* We use the proc sort command to remove the exact duplicates
	* 11 exact duplicates removed from Assign2A_gp_data_copy2;
 proc sort data=Assign2A_gp_data_copy2 out=no_dup nodupkey dupout=no_dup2;
	by _all_;
	run;


/*Look for duplicate IDs, each Id should be unique */
	* We use proc sort fuction to idetify and remove the partial duplicates
	* no_par table will show the no partial duplicates;
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

/*Remove partial dupicate for the entire dataset*/
	* No partial duplicates are saved in the no_par table;
 proc sort data=work.missing out=no_par nodupkey dupout=no_par2;
 by ID;
 run;

/* remove final 6 observations where no pattern is evident*/
	* The IDs with more than 1 obervations that are neither exact or partial duplicates;
	* These are  6 observations (3 IDs) to be removed from the no_par dataset;
 data Assign2A.no_duplicates;
	set no_par;
	if ID = 152 or ID = 243 or ID = 2897
	then delete;
 run;
 
  
*----------------------------------------------------------------;
/*Calcualte frequencies for categorical variables and summary stats for continuous */
	* This will help to identify the categorial variables that are out of range;
	* Only the sex variable has variable values out of range;
   proc freq data=Assign2A.no_duplicates; 
	table adverse_reaction sex reason smoke_now ever_smoked healthcare_card cob/ missing;
	run;

	* Sex is coded as 1,2 and M,F, 
	* we need to create a new variable to clean the data;
  data Assign2A.Clean;
	set Assign2A.no_duplicates;
	if sex in ('M', '1') then sex_cln = 1;
	else if sex in ('F','2') then sex_cln= 2; 
	else if sex in (.) then sex_cln= .; 
	else sex_cln =sex;
run;

/* Check new variable: Run crosstab between the original sex and new variable*/
	* there are 10 observations with no sex value indicated;
	* input M, and F have been changed to 1 and 2 respectively;
	proc freq data=Assign2A.Clean;
		table sex*sex_cln /norow nocol nopercent missing;
	run;
	
*Checking descriptive statistics for continuous variables;
	* Variables that are outside the range provided;
	* In the data dictionary can be identified;	
	proc summary data=Assign2A.Clean n min p25 mean p75 max nmiss print;
	var  age age_start age_stop diast_bp drinks_day height weight syst_bp ;
	run;


	* The Variable "age_stop, weight and drinks_day" has value =999,/ we Check these values;
	* we inspect the variables independently, starting with age_stop;
	proc freq data=Assign2A.Clean;
		where age_stop>105;
		table age_stop;
	run;
	* 153 cases with age_stop outside the acceptable range from the data dictionary. 
	* These cases may be ommited in the analysis as it could mean the year the participant stopped smoking;
	
	/* we now inspect drinks_day*/
	proc freq data=Assign2A.Clean;
		where drinks_day>20;
		table drinks_day;
	run;
	* 50 cases with drinks_day outside the acceptable range from the data dictionary coded = 999, 
	may be ignored as standard missing data;	
	
	* We lastly inspect weight;
	proc freq data=Assign2A.Clean;
		where weight>270;
		table weight;
	run;
	* 26 cases with weight outside the acceptable range from the data dictionary;
	

******formats to be applied ob the new variables;
 proc format;
	value smoke_status_GP
	    0 = 'Never smoked'
		1 = 'Current smoker'
		2 = 'Ex-smoker'
	;
	value sex_cln
	    1 = 'Male'
		2 = 'Female'
	;
	value ynf
		0 = 'No'
		1 = 'Yes'
	;
	value highBP_GP
		0 = 'Normal blood pressure'
		1 = 'High blood pressure'
	;

 run;


**creating the variables, we a permanent copy of cleaned data;
 data NEW_gp_data;
  set Assign2A.Clean;

/*smoke_status_GP*/
	if missing(smoke_now) or missing(ever_smoked) then smoke_status_GP=.;
	else if smoke_now=0 and ever_smoked=0 then smoke_status_GP=0;
	else if smoke_now=1 then smoke_status_GP=1;
	else if smoke_now=0 and ever_smoked=1 then smoke_status_GP=2;
	else smoke_status_GP = .; 

/*risky_alcohol_GP*/
	if missing(drinks_day) then risky_alcohol_GP= .;
	else if drinks_day <=2 then risky_alcohol_GP= 0;
	else if drinks_day >2 and drinks_day <= 20 then risky_alcohol_GP=1;
	else risky_alcohol_GP = .; 

/*creating BMI and rounding it to two d.p*/
	if cmiss(weight, height)=0 then BMI_GP = round((weight/height**2),.01);
	else BMI_GP = .; 

/*obese_GP */
	if missing(BMI_GP) then obese_GP=.;
	else if BMI_GP<30 then obese_GP=0;
	else if BMI_GP>=30 then obese_GP=1;
	else obese_GP = .;

/*highBP_GP*/
	if (syst_bp <135 and diast_bp<85) then highBP_GP=0;
	else if (syst_bp >=135 or diast_bp>=85) then highBP_GP=1;
	else highBP_GP=.;

	format sex_cln sex_cln. smoke_status_GP smoke_status_GP. risky_alcohol_GP 
	obese_GP ynf. highBP_GP highBP_GP.;

	run;

 data Final_gp_data;
  set work.NEW_gp_data;

 run;
 
 *check the contents of the new data;
  proc contents data=Final_gp_data; 
	run; 

*----------------------------------------------------------------;
*END OF DATA QUALITY CHECKS AND NEW VARIABLES CREATION 
*----------------------------------------------------------------;

/* We create flags for missing data and invalid observations 
	*to be ommited during analysis*/
	* We start by converting the . 99,998,999 to missing flags; 
	* where if missing we input Y;
 data Final_gp_data;
	set Final_gp_data;
	if healthcare_card in(.,99,998,999) then miss1="Y";
	if ever_smoked in(.,99,998,999) then miss2="Y";
	if smoke_now in(.,99) then miss3="Y";
	if cob in(.,99,998,999) then miss4="Y";
	if drinks_day in (.,99,998,999) then miss5 = "Y";
	if age_start in (.,99,998,999) then miss6 = "Y";
	if age_stop in (.,99,998,999) then miss7 = "Y";
	if sex_cln in (.,99,998,999) then miss8 = "Y";
	if diast_bp in (.,99,998,999) then miss9 = "Y";
	if syst_bp in (.,99,998,999) then miss10 = "Y";
run;


***age start and age stop invalid flags***;
 data Final_gp_data;
		set Final_gp_data;
	if age_start<10 or age_start>105 then age_startfl="Y";
	if age_stop<10 or age_stop>105 then age_stopfl="Y";
	run;

*** drinks_day invalid flags***;
 data Final_gp_data;
	set Final_gp_data;
 if drinks_day>20 then drinks_dayfl="Y";
 run;

***height and weight invalid flags***;
 data Final_gp_data;
		set Final_gp_data;
	if height<0.55 or height>2.4 then heightfl="Y";
	if weight<5.0 or weight>270 then weightfl="Y";
	run;

*****Summaries for demographics*****;
*sex cob;
%macro demo_cat(var=, wher=);
proc freq data=Final_gp_data;
  table &var./out=&var.;
  where &wher.;
run;
%mend;
%demo_cat(var=sex_cln, wher=(not missing(sex_cln)));/*sex frequencies*/
%demo_cat(var=cob,wher=%nrstr(miss4 ^="Y"));

*****summaries for continous demographics*****;
%macro summ(var=,wher=);
proc means data=Final_gp_data n mean std min max median q1 q3 ; 
  var &var.;
  where &wher.;
   output out=&var._res
         n=
         mean=
         std=
         min=
         max=
         median=
         q1=
         q3= /autoname
;
 run;
%mend;
%summ(var=age,wher=(not missing(age)));/*summary stats for age*/
%summ(var=height, wher=%nrstr(heightfl ^="Y"));/*summary stats for height*/
%summ(var=weight,wher=%nrstr(weightfl ^="Y"));/*summary stats for weight*/
%summ(var=BMI_GP,wher=(not missing(BMI_GP)));/*summary stats for BMI*/
