
/* Formats for Assignment 2A */

proc format;
	value sexf
		1 = 'Male'
		2 = 'Female'
	;
	value cobf
		1 = 'Australia'
		2 = 'Overseas'
	;
	value ynf
		1 = 'Yes'
		0 = 'No'
		;
	value triagef
	 	1 = 'Resuscitation'
		2 = 'Emergency'
		3 = 'Urgent'
		4 = 'Semi urgent'
		5 = 'Non urgent'
	;
	value sepmodef
		1 = 'Admitted to hospital'
		2 = 'Departed ED'
		3 = 'Died in ED'
		4 = 'Dead on arrival'
	;
run;
