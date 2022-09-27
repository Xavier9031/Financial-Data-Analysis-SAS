PROC IMPORT OUT= WORK.RE_RAW
    DATAFILE= "C:\Users\ed307\Desktop\RE.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;

data RE;
	set RE_RAW;
	yyyy = year(_COL1);
	rename _COL0 = sid;
	rename _COL1 = datadate;
	rename _COL2 = RET;
	rename _COL3 = TD;
	rename _COL4 = PE;
	rename _COL5 = PB;
	rename _COL6 = PS;
	rename _COL7 = CD;
	rename _COL8 = PV;
RUN;

PROC IMPORT OUT= WORK.BS_RAW
    DATAFILE= "C:\Users\ed307\Desktop\BS.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;

data BS;
	set BS_RAW;
	yyyy = year(_COL1);
	rename _COL0 = sid;
	rename _COL1 = datadate;
	rename _COL2 = CDR;
	rename _COL3 = SYD;
	rename _COL4 = PR;
	rename _COL5 = PP;
	rename _COL6 = ATG;
	rename _COL7 = DEBT;
	rename _COL8 = ROE;
	rename _COL9 = ROA;
RUN;

proc sort data=BS nodup; by sid yyyy; run;
proc sort data=RE nodup; by sid yyyy; run;

data BSRE1;
	merge BS RE;
	by  sid yyyy;
	*if c=1 and f=1; /*只保留左手和右手邊都有進來的資料*/
run;

data BSRE2;
	set BSRE1;
	where yyyy ne 2022 && yyyy ne 2021;
	drop datadate roa roe DEBT;
run;

data NRET;
	set BSRE2;
	where RET ne .;
	*IF RET = . && yyyy = 2005 THEN delete;
	*IF RET = . && yyyy = 2018 THEN delete;
run;

proc sort data=NRET nodup; by yyyy; run;


proc rank data=NRET out=r_RET groups=100; 
	var RET TD PE PB PS CD PV CDR SYD PR PP ATG;
	by yyyy;
	Ranks rank_RET rank_TD rank_PE rank_PB rank_PS rank_CD rank_PV rank_CDR rank_SYD rank_PR rank_PP rank_ATG;
run;

DATA Porf;
	set r_RET;
	if rank_RET = . then delete;
	if 	rank_TD  = . then delete;
	if 	rank_PE  = . then delete;
	if 	rank_PB  = . then delete;
	if 	rank_PS  = . then delete;
	if 	rank_CD  = . then delete;
	if 	rank_PV  = . then delete;
	if 	rank_CDR  = . then delete;
	if 	rank_SYD  = . then delete;
	if 	rank_PR  = . then delete;
	if 	rank_PP  = . then delete;
	if rank_ATG = . then delete;
	keep sid yyyy RET rank_RET rank_TD rank_PE rank_PB rank_PS rank_CD rank_PV rank_CDR rank_SYD rank_PR rank_PP rank_ATG;
run;

data selc;
	set Porf;
	where rank_RET > 90 && rank_TD > 30 && rank_PE > 30 && rank_PB > 30 && rank_PS > 30 && rank_CD > 30 && rank_PV > 30 && rank_CDR > 30 && rank_SYD > 30 && rank_PR > 30 && rank_PP > 30 && rank_ATG > 30 ;
run;




data selc;
	set Porf;
	where rank_RET > 30 && rank_TD > 1 && rank_PE > 10 && rank_PB >3 && rank_PS > 27 && rank_CD > 70 && rank_PV > 6 && rank_CDR > 83 && rank_SYD > 88 && rank_PR > 49 && rank_PP > 40 && rank_ATG > 3 ;
run;

proc sort data=selc nodup; by yyyy; run;

proc means data=selc n mean std median;
	var RET;
    class yyyy;  /*by 可分群進行統計*/
	output out=h11 n = n1 mean = m1 median = md1 std = stda;
quit;

data geRET;
	set h11;
	where yyyy >=2005 && yyyy <=2014;
	ptr = (100 + m1)/100;
	keep yyyy ptr ;
run;

proc surveymeans data= geret geomean;
	var ptr;
run;

data selcTEST;
	set selc;
	yyyy = yyyy + 1;
	keep sid yyyy;
run;

proc sort data=BSRE1 nodup; by sid yyyy; run;
proc sort data=selcTEST nodup; by sid yyyy; run;

data selcRET;
	merge BSRE1 selcTEST(in=f);
	by  sid yyyy;
	if f=1; 
	keep sid yyyy RET;
run;

proc sort data=selcRET nodup; by yyyy; run;

proc means data=selcRET n mean std median;
	var RET;
    class yyyy;  /*by 可分群進行統計*/
	output out=h11 n = n1 mean = m1 median = md1 std = stda;
quit;

data geRET;
	set h11;
	ptr = (100 + m1)/100;
	keep yyyy ptr ;
run;

proc surveymeans data= geret geomean;
	var ptr;
run;
