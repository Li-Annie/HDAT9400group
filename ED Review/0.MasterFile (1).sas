/**************************************************************
* Project: 	HDAT9400 - Management and curation of health data
* Purpose:	Set macros and run project programs
* Inputs: 	assignmt2a_ed_data.sas7bdat
* Outputs:	yyyymmdd_ed_data_cleaned.pdf
* Author:	Annie Li
* Date:		13th Oct 2022
* Last modified: 15th Oct 2022
**************************************************************/

/* Set the root location for the assessment 2 folder.*/ 
%let source = /home/u59424678/HDAT9400_AL/Week_5/Assessment2;


/* Automatically update the location of the code subfolder of the 
assessment 2 folder.*/
%let code = &source/Code;


/* Automatically update the location of the data subfolder of the
assessment 2 folder. */
%let data = &source/Data;


/* Automatically update the location of the results subfolder of the 
assessment 2 folder.*/
%let cleaned = &source/Cleaned_Data;


/* Created  directory for the SAS library that is named in a LIBNAME statement
 if the directory does not exist.  */
options dlcreatedir;
libname a2clean "&cleaned";


/* Use the libname statement to create libraries based on the above locations. */ 
libname a2code "&code";
libname a2data "&data";


/* Tell SAS to ignore missing formats using options no format error */
/* written as nofmterr */
options nofmterr;

/* Run the project programs in order */
%INCLUDE "&code/1.DataValidation.sas";
%INCLUDE "&code/2.DataCleaning.sas";


