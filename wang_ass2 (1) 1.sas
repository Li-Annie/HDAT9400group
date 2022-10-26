/* Assignment 2 GP dataset     */
/* WANG DB                     */
/* 20/10/2022                  */


libname Assign2A '/home/u62313591/HDAT9400/Assignment 2A';
%include "/home/u62313591/HDAT9400/Assignment 2A/assignmt2a_formats.sas";

/* To make a permanent copy of dataset survey*/
data Assign2A_gp_data_copy;
	set Assign2A.assignmt2a_gp_data;
	run;
/* Finding:  number of records*/
proc contents data=Assign2A_gp_data_copy; 
run; 

* check values of the variable ID in gp_data for all records:
Variables with more than one frquency in ID can be flaggged as duplicates;
		proc freq data= Assign2A_gp_data_copy; 
			TABLE ID /missing;
			run;

*checking for duplicates*****;

proc sort data=Assign2A_gp_data_copy out= no_dup_gp_data nodupkey dupout= gp_data_no_dup2;
  by ID;
run;

/*Look for duplicate IDs, each Id should be unique */
proc sort data=work.no_dup_gp_data out=no_par nodupkey dupout=no_par2;
by ID;
run;

data work.missing;
set work.no_dup_gp_data;
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
data Assign2A.no_dup_gp_data;
	set no_par;
	if ID = 152 or ID = 243 or ID = 2897
	then delete;
run;
 
*----------------------------------------------------------------;
/*Calcualte frequencies for categorical variables and summary stats for continuous */
proc freq data=Assign2A.no_dup_gp_data; 
table adverse_reaction sex reason smoke_now ever_smoked healthcare_card cob/ missing;
run;

* Sex is coded as 1,2 and M,F, therefore, we need to create a new variable to clean the data;
data Assign2A.no_dup_gp_data;
	set Assign2A.no_dup_gp_data;
	if sex in ('M', '1') then sex_clean=1;
	 else if sex in ('F','2') then sex_clean=2;
run;

* Check new variable: Run crosstab between the original sex and new variable;
	proc freq data=Assign2A.no_dup_gp_data;
		table sex*sex_clean /norow nocol nopercent missing;
	run;


proc summary data=Assign2A.no_dup_gp_data n min p25 mean p75 max nmiss print; 
var  age age_start age_stop diast_bp drinks_day height weight syst_bp ;
run;

	* The Variable "age_stop, drinks_day" has value =999,/ we Check these values;
	proc freq data=Assign2A.no_dup_gp_data;
		where age_stop>105;
		table age_stop;
	run;
	* 153 cases with age_stop outside the acceptable range from the data dictionary. 
	* These cases may be ommited in the analysis as it could mean the year the participant stopped smoking;
	
	proc freq data=Assign2A.no_dup_gp_data;
		where drinks_day>20;
		table drinks_day;
	run;
	* 50 cases with drinks_day outside the acceptable range from the data dictionary. 
	* Value = 999 may be considered  meaningful;
	proc freq data=Assign2A.no_dup_gp_data;
		where weight>270;
		table weight;
	run;
	* 26 cases with weight outside the acceptable range from the data dictionary. 
	* Value = 999 may be considered  meaningful;
	
	
******formats to be applied ob the new variables;
proc format;
	value smoke_status_GP
	    0 = 'Never smoked'
		1 = 'Current smoker'
		2 = 'Ex-smoker'
	;
	value ynf
		0 = 'No'
		1 = 'Yes'
	;
	value highBP_GP
		0 = 'Normal blood pressure'
		1 = 'High blood pressure'
	;
	value $sexc
	   '1'="male"
	   '2'="female"
;
run;




**creating the variables, we a permanent copy of cleaned data;
data NEW_gp_data;
  set Assign2A.no_dup_gp_data;


/*smoking status*/
if smoke_now=1 then smoke_status_GP =1;
else if smoke_now=0 and ever_smoked=0 then smoke_status_GP=0;
else if smoke_now=0 and ever_smoked=1 then smoke_status_GP=2;

/*drinks per day*/
if drinks_day <=2 then risky_alcohol_GP=0;
else if drinks_day >2 then risky_alcohol_GP=1;

/*creating BMI and rounding it to two d.p*/
if cmiss(weight, height)=0 then BMI_GP = round((weight/height**2),.01);

/*obese_GP */
if BMI_GP<30 then obese_GP=0;
if BMI_GP>=30 then obese_GP=1;

/*highBP_GP*/
if (syst_bp <135 and diast_bp<85) then highBP_GP=0;
else if (syst_bp >=135 or diast_bp>=85) then highBP_GP=1;

format smoke_status_GP smoke_status_GP. risky_alcohol_GP 
obese_GP ynf. highBP_GP highBP_GP.;

if missing(BMI_GP) then obese_GP=.;

****converting the 99,998,999 to missing******;
array Nums[*] _numeric_;
   array Chars[*] _character_;
   do i = 1 to dim(Nums);
      if Nums[i] = 999 or 998 or 99 then Nums[i] = .;
   end;
 do i = 1 to dim(Chars);
      Chars[i] = Chars[i]="";
   end;
   drop i;
run;


