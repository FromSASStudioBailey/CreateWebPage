OPTIONS MERROR SYMBOLGEN MLOGIC MPRINT SOURCE SOURCE2;run;
%LET ORIGIN_COUNT=2;
%LET ORIGIN1=Europe;
%LET ORIGIN2=Asia;
%LET ORIGIN0=2;

%LET MSRP=50000;

%LET ORIGIN=&ORIGIN1;
%LET TYPE=SUV;

/* COMMENT: WRAPPING YOUR VARIABLES IN A SINGLE QUOTE IS DEFAULT, FOR DOUBLE, COMMENT OUT LINE BELOW AND THEN UNCOMMENT LINE BELOW THAT */
%LET INSERT_TXT=SNGL_QT;
/* COMMENT:%LET INSERT_TXT=DBL_QT; */
%GLOBAL  chkOrigin ;
 %let Origin_in_or_out=in;
%if %EVAL(&chkOrigin=on) %then   
	%do;                            
		%let Origin_in_or_out=NOT IN ;
	%end;                             
 							
%macro listthem(my_var_name=,var_name_cnt=, insert_name=);
/* COMMENT:when user only selects one value from list box, the count variable macro does not get created. Example: they only select one option for Education */
/* COMMENT:in that case the macro variable EDUCATION0 (COUNT OF SELECTIONS IN THIS CASE 1) DOES NOT GET CREATED. BELOW DEALS WITH THAT SITUATION */
%if %eval(&insert_name=DBL_QT) %THEN
%DO;
	%do n=1 %to &var_name_cnt.; "&&&my_var_name&n." %IF %eval(&n < &var_name_cnt) %THEN ,;
	%end;
%END; 
%if %eval(&insert_name=SNGL_QT) %THEN 
%DO; 
	%do n=1 %to &var_name_cnt.;%UNQUOTE(%STR(%')&&&my_var_name&n.%STR(%')) %IF %eval(&n < &var_name_cnt) %THEN ,; 
	%end;
%END; 
%mend listthem;
proc casutil;
	droptable incaslib="casuser" casdata="Test&SYSUSERID." quiet;
run;
data casuser.Test&SYSUSERID.(promote=yes);
 SET CASUSER.MYCAR; 
LENGTH
 CRITERIA_Type   CRITERIA_Origin   CRITERIA_MSRP $50.;
%if (%bquote(&MSRP) NE %str(Not Used)) %then
 %do;
		IF MSRP < &MSRP;
 %end;
%if (%bquote(&Type) NE %str(Not Used)) %then
 %do;
		IF Type IN ("&Type.");
 %end;
%if ((%bquote(&Origin) NE %str(Not Used)) AND %symexist(Origin0)=1) %then
 %do;
		IF Origin &Origin_IN_OR_OUT. (%listthem(my_var_name=Origin,var_name_cnt=&Origin0.,insert_name=&insert_txt.));
 %end;
%if ((%bquote(&Origin) NE %str(Not Used)) AND %symexist(Origin0)=0) %then
 %do;
		IF Origin &Origin_IN_OR_OUT.  ("&Origin.");
 %end;*/;

RUN;
proc casutil;
	droptable incaslib="casuser" casdata="CRITERIA&SYSUSERID." quiet;
run;
data casuser.CRITERIA&SYSUSERID.(promote=yes);
LENGTH
 CRITERIA_Type   CRITERIA_Origin   CRITERIA_MSRP $50.;
LENGTH AccidentYear $4.;
LENGTH DevelopmentMonths $3.;
/* COMMENT: OUR VA REPORT IS EXPECTING THESE VARIABLES, NEED TO MAKE SURE THEY EXIST EVEN IF POPULATED WITH NOTHING */
 CRITERIA_Type='';   CRITERIA_Origin='';   CRITERIA_MSRP='';
%if (%bquote(&MSRP) NE %str(Not Used)) %then
 %do;
		CRITERIA_MSRP="MSRP < &MSRP.";
 %end;
%if (%bquote(&Type) NE %str(Not Used)) %then
 %do;
		CRITERIA_Type="Type EQUALS '&Type.'";
 %end;
%if ((%bquote(&Origin) NE %str(Not Used)) AND %symexist(Origin0)=1) %then
 %do;
		CRITERIA_Origin="Origin &Origin_IN_OR_OUT. (%listthem(my_var_name=Origin,var_name_cnt=&Origin0.,insert_name=&insert_txt.))";
 %end;
%if ((%bquote(&Origin) NE %str(Not Used)) AND %symexist(Origin0)=0) %then
 %do;
		CRITERIA_Origin="Origin &Origin_IN_OR_OUT.  (&Origin.)";
 %end;
AccidentYear='2000';
DevelopmentMonths='000';
RUN;
data casuser.Test&SYSUSERID.(append=yes);
	if _n_=0 then
		do;
			set casuser.Test&SYSUSERID.;
		end;
	set casuser.CRITERIA&SYSUSERID.;
run;