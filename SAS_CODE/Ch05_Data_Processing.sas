/***********************************************
Sample program: Ch05  Data Processing
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

/********************************************************************************************
						°ò¥»¹Bºâ: :+ - * / ¦¸¤è, rename
********************************************************************************************/

data a1;
	set Mydata. F01s_A_financialann;

	ATnew=CEQ+LT;
	Profit=SALE-COGS;
	DebtR=LT/AT;
	 ROA=NI/AT;
	Debt=AT*DebtR;
	logSize=log(AT);  /*Log¬Oln, ¤£¬O¯uªºlog*/
	
	ROA2=ROA**2; /*¥­¤è*/
	ROA3=ROA**3; /*¤T¦¸¤è*/
	ROA4=sqrt(ROA);  /*¶}®Ú¸¹*/
	ROA5=ROA**0.5;  /*¶}®Ú¸¹*/
	rename XAD=XADnew;  /*§ó§ïÅÜ¼Æ¦WºÙ  Rename ÂÂ=·s*/
run;

data a2;
	set a1;
	if AT ne . and AT ne 0 then DebtR2=LT/AT; /*Á×§K¤À¥À¬°0 ©Îmissing·|¥X²{Äµ§i°T®§¡A©Ò¥H¥[¤W³o¨Ç±ø¥ó¡F²Å¦X±ø¥ó¤~°õ¦æ; ne is not equal*/
	/*±ø¥ó¥i¥H¦h­Ó±ø¥ó¡A¦ýthen «á­±¥u¯à°µ¤@¥ó¨Æ*/
	/*±ø¥ó¥²¶·¼g§¹¾ã¡A­Y¼gif AT ne . and  ne 0 then DebtR2=LT/AT  ¬O¤£§¹¾ãªº±ø¥ó;*/
	if AT>0 then DebtR3=LT/AT;
	if AT>0 then LnAT=log(AT);

	if AT>0 then do ; /*­Ythen«á­±­n°µ¦n¦h¥ó¨Æ±¡¡A­n¹³³o¼Ë¼g*/
		DebtR4=LT/AT;
		LnAT2=log(AT);
		ROA=NI/AT;
	end;
	if CEQ>0 then ROE=NI/CEQ;
	keep gvkey datadate  CONM sic_tej  SICb DebtR ROA logSize AT Sale ;


run;
/********************************************************************************************
						 Calendar  Function: ¨ú¥Xyear qtr month;
********************************************************************************************/
data az;
	set a2;
	yyyy=year(datadate);
	qq=qtr(datadate);
	mm=month(datadate);
	yyyymm=yyyy*100+mm;
	yyyyqq=yyyy*100+qq;
	sic4=substr(SICb,1,4); /*Substr¬O¨ú¥X¤å¦rÅÜ¼Æ¤¤ªº¤å¦r*/

run;




/********************************************************************************************
					Where: ¿z¿ï¸ê®Æ	 ; 
********************************************************************************************/
data c0;
	set az;
	where yyyy>=2010;  /*Where¤¤ªº±ø¥ó¥i¥H¬O=,>,<,>=,<=, ne, between*/
	keep yyyy sic_tej  ;
run;
proc sort nodupkey; by yyyy sic_tej ;run;
/*proc sort data=az out=c0(keep=yyyy sic_tej ) nodupkey; by yyyy sic_tej; run;*/

data c1a;
	set c0;
	where yyyy>=2012;
run;
data c1b;
	set c0;
	where yyyy>=2012 and sic_tej=12;
run;
data c1c;
	set c0;
	where yyyy=2012 or yyyy<=2008;
run;
data c2;
	set c0;
	where yyyy ne 2012 ;
run;
data c3;
	set az(keep=datadate conm);
	where datadate>='01JAN2012'd;
run;
data c4;
	set az;
	where sic4='M12C';
	*where sic4 eq 'M12C';
run;
data c5;
	set c0;
	where yyyy>2009 or yyyy<2007;
run;
data c6;
	set az;
	where ROA is not missing;  /*„³«ü±Æ°£missing value*/
run;
data c7;
	set az;
	where yyyy between 2008 and 2010;
run;
**** 
*Exercise 5-1: ¥HMydata. F01s_c_ucgi_owner_summary ¬°¸ê®Æ¡A¨ú¥X¸³ºÊ½è©ã¶W¹L¦Ê¤À¤§70ªº¤½¥q;
**** 
*Exercise 5-2: ¥HMydata. F01s_b_ret_monthly ¬°¸ê®Æ¡A¨ú¥X­ÓªÑ¤ë³ø¹S(¤£§t¥[Åv«ü¼Æªº¤ë³ø¹S);




/********************************************************************************************
				If...then:¥i³]dummy variable, ¤À¸s ; 
********************************************************************************************/
data d0;
	set az;
	where yyyy>=2010;
	keep yyyy sic_tej SICb;
run;
proc sort nodupkey; by yyyy;run;

data d1;  /*if¤¤¥i¥H³]©w¦h­«±ø¥ó¡Aand, or*/
	set d0;
	if yyyy=2014 then d1a=1; 
	if yyyy=2014 then d1b=1; else d1b=0;
	if yyyy=2014 and sic_tej=12 then d1c=1; else d1c=0;
	if yyyy=2014 then d1d='last';
	d2b=(yyyy=2014); /*¸ûÂ²«K*/
	d2c=(yyyy=2014 and sic_tej=12);  
run;
data d2;
	set d0;
	if yyyy=2014 then delete;
run;
data d3;
	set d0;
	if yyyy=2014 then output; /*Output¬O«ü¶×¥X¬°¸ê®ÆÀÉ*/
run;
data d4;
	set d0;
	if yyyy ne 2014 then delete;
run;

data d5; /*¤À¸sªº§@ªk*/
	set az;
	if DebtR>=0.8 then DebtRx=5;
	else if DebtR>=0.6 then DebtRx=4;
	else if DebtR>=0.4 then DebtRx=3;
	else if DebtR>=0.2 then DebtRx=2;
	else DebtRx=1;
run;
proc freq data=	d5 ;
	table yyyy*DebtRx  ;
run;
**** 
*Exercise 5-3: ¥HMydata. F01s_c_ucgi_owner_summary ¬°¸ê®Æ¡A­Y¬°®a±Ú¥ø·~¡A«hFamily=1¡A¨ä¥¦³]¬°0;
data Ex5_3;
	set Mydata. F01s_c_ucgi_owner_summary;
	if ControlType == 'F' then Family = 1;
	else Family = 0;
run;

**** 
*Exercise 5-4: ¥HMydata F01s_c_ucgi_owner_summary ¬°¸ê®Æ¡A¥H¸³ºÊ¤H¼Æ¡A¨C¤­¤H¬°¶¡¶Z¤À¸s¡A¹B¥Îproc freq,§e²{¨C¦~¨C¤@¸s¸³ºÊ®u¦¸ªºÀW²v¤À¥¬. ;
data Ex5_4;
	set Mydata. F01s_c_ucgi_owner_summary;

run;


/********************************************************************************************
			¸ê®Æ¦X¨Ö:	set-¤W¤U¦X,  merge:¥ª¥k¦X;	
Merge¬O«D±`­«­nªº¥\¯à¡A¸ê®Æ¾ã²z±`±`­n¹B¥Î¸Ó§Þ¥©

********************************************************************************************/
****set;
data e0;
	set az;
	where yyyy between 2006 and 2010;
	keep conm yyyy sic_tej ROA Sale;
run;
proc sort nodupkey; by yyyy conm;run;
data e1a;
	set e0;
	where yyyy<=2007;
data e1b;
	set e0;
	where yyyy>=2009;
run;
data e2;
	set e1a e1b;  „³/*¥i¥H±N¨â­Ó¸ê®ÆÀÉ««ª½Å|°_¨Ó ¦ý¤£±`³o¼Ë¨Ï¥Î ½Ð¤p¤ß*/;
run;


***************Merge***************;
**merge1;
data f1A;
	set az;
	where yyyy=2014;
	if ROA<0.03 then delete;
	keep conm yyyy sic_tej  ROA Sale;
run;
proc sort; by conm; run;
data f1B;
	set mydata. F01s_c_ucgi_owner_summary;
	where year(datadate)=2014;
	yyyy=year(datadate);
	Family=(ControlType='F');
	keep conm yyyy Family;
run;
proc sort; by conm; run;
data f2;
	merge f1A f1B;  /*¥i¥H±N¨â­Ó¸ê®ÆÀÉ¥ª¥k¦X¨Ö*/
	by conm;
run;
data f3;
	merge f1A(in=c) f1B;
	by  conm;
	if c=1; *if c;   /*¥u«O¯d¥ª¤âÃä¦³¶i¨Óªº¸ê®Æ*/
run;
data f4;
	merge f1A(in=c) f1B(in=f);
	by  conm;
	if f=1; /*¥u«O¯d¥k¤âÃä¦³¶i¨Óªº¸ê®Æ*/
run;
data f5;
	merge f1A(in=c) f1B(in=f);
	by  conm;
	if c=1 and f=1; /*¥u«O¯d¥ª¤â©M¥k¤âÃä³£¦³¶i¨Óªº¸ê®Æ*/
run;

**merge2;
data g1A;
	set az;
	where yyyy between 2012 and 2014;
	if ROA<0.03 then delete;
	keep conm yyyy sic_tej  ROA Sale;
run;
proc sort; by conm yyyy; run;
data g1B;
	set mydata. F01s_c_ucgi_owner_summary;
	where year(datadate) between 2011 and 2013;
	yyyy=year(datadate);
	Family=(ControlType='F');
	keep conm yyyy Family;
run;
proc sort; by conm yyyy; run;
data g3;
	merge g1A(in=c) g1B;
	by  conm yyyy;
	if c=1; *if c;
run;
data g4;
	merge g1A(in=c) g1B(in=f);
	by  conm yyyy;
	if f=1; 
run;
data g5;
	merge g1A(in=c) g1B(in=f);
	by  conm yyyy;
	if c=1 and f=1; 
run;
/*¦X¨Ö®É­n¤@¹ï¤@,¦h¹ï¤@,¤@¹ï¦h, ¦ý¤Á§Ò¦h¹ï¦h¦X¨Ö*/
/*¨S¦³¤@¹ï¤@Ãö«Y ¼Ë¥»¶Ã¿±µÈ*/
data g6;
	merge g1A(in=c) g1B(in=f);
	by  conm ;
	if c=1 and f=1; 
run;


/********************************************************************************************
					*Example: ¥HMydata. F01s_A_financialann  ¬°¸ê®Æ¡A­pºâ¨C®a¤½¥q¨C¤@¦~ªºindustry adjusted ROA(ROA_Adj)¡Cindustry adjusted ROA(ROA_Adj)=ROA- mean ROA of the corresponding industry;
********************************************************************************************/
data Sample;
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	keep gvkey yyyy datadate  CONM sic_tej    ROA ;
run;
proc sort  nodup; by yyyy sic_tej; run;
proc means data=Sample n mean; 
       var ROA;
       by yyyy sic_tej;
       output out=industry_ROA n=nFirm mean=mROA;
quit;
data k1; /*¥ýºâ²£·~¥­§¡¡A ¦A¨Ö¦^¥h¡A³o¼Ë¤~¯à¬Û´î*/
       merge Sample industry_ROA (drop=_type_ _freq_);
       by yyyy sic_tej;
       ROA_Adj=ROA-mROA;
run;

**** 
*Exercise 5-5: ¥HMydata. F01s_A_financialann Mydata F01s_c_ucgi_owner_summary ¬°¸ê®Æ¡A­pºâ¨C¦~®a±Ú¥ø·~»P«D®a±Ú¥ø·~ROA¥­§¡¼Æ¤Î¤¤¦ì¼Æ;
data Ex5_5a;
	set Mydata. F01s_A_financialann;
	yyyy = year(datadate);
	ROA=NI/AT;
	keep gvkey CONM yyyy DataDate ROA;
run;
data Ex5_5b;
	set Mydata. F01s_c_ucgi_owner_summary;
	keep gvkey ControlType;
run;
data Ex5_5c;
	merge Ex5_5a Ex5_5b(in=f);
	by gvkey;
	if f =1;
run;


data Ex5_5a;
	set Mydata. F01s_A_financialann;
	yyyy = year(datadate);
	ROA=NI/AT;
	keep gvkey CONM yyyy DataDate ROA;
run;
data Ex5_5b;
	set Mydata. F01s_c_ucgi_owner_summary;
	yyyy = year(datadate);
	keep gvkey yyyy ControlType;
run;

proc sort data=Ex5_5a nodup; by gvkey yyyy; run;
proc sort data=Ex5_5b nodup; by gvkey yyyy; run;

data Ex5_5z;
	merge Ex5_5a Ex5_5b;
	by gvkey yyyy;
run;

proc sort data=Ex5_5c nodup; by gvkey yyyy; run;
proc sort data=Ex5_5z nodup; by gvkey yyyy; run;

data comparr;
	merge Ex5_5c(if c) Ex5_5d;
	by gvkey yyy
run;

data Ex5_5d;
	set Ex5_5c;
	isF = "NF";
	if ControlType = "F" then isF = "F";
	drop ControlType;
run;
proc sort data=Ex5_5d nodup; by isF yyyy; run;
proc means data=Ex5_5d mean median;
       var ROA;
       by isF yyyy;
	   output out=Ex5_5k mean=meanROA median=medianROA;
quit;

data Ex5_5d;
	set Ex5_5z;
	isF = "NF";
	if ControlType = "F" then isF = "F";
	drop ControlType;
run;
proc sort data=Ex5_5d nodup; by isF yyyy; run;
proc means data=Ex5_5d mean median;
       var ROA;
       by isF yyyy;
	   output out=Ex5_5e mean=meanROA median=medianROA;
quit;



****
*Exercise 5-6: ¥HMydata. F01s_b_ret_monthly ¬°¸ê®Æ¡A§ä¥X¨C¤@"¦~"Market adjusted return¡CMarket adjusted return=RET-Rm, Rm¬Omarket portfolio returns. ¨Ã§e²{ª½¦æ¬°¦~¡A¾î¦C¬°¤½¥q;
data Ex5_6a;
	set Mydata. F01s_b_ret_monthly;
	yyyy = year(datadate);
	where gvkey = "Y9999";
	rename RET = RM;
	keep yyyy RET;
run;
proc sort data=Ex5_6a nodup; by yyyy; run;
proc means data=Ex5_6a sum;
       var RM;
       by yyyy;
	   output out=Ex5_6a1 sum=yRM;
quit;

data Ex5_6b;
	set Mydata. F01s_b_ret_monthly;
	yyyy = year(datadate);
	where gvkey ne "Y9999";
run;
proc sort data=Ex5_6b nodup; by gvkey yyyy; run;

proc means data=Ex5_6b sum;
       var RET;
       by gvkey yyyy;
	   output out=Ex5_6b1 sum=yRET;
quit;

proc sort data=Ex5_6a1 nodup; by yyyy gvkey; run;
proc sort data=Ex5_6b1 nodup; by yyyy; run;

data Ex5_6c;
	merge Ex5_6a1(in=c) Ex5_6b1(in=f);
	by yyyy;
	if c=1 and f=1;
run;

data Ex5_6d;
	set Ex5_6c;
	adjRET = yRET-yRM;
	keep yyyy gvkey adjRET;
run;

proc sort data=Ex5_6d nodup; by yyyy gvkey ; run;

proc transpose data=Ex5_6d out=Ex5_6e prefix = id_;
       var adjRET;
	   id gvkey;
       by yyyy;
quit;

data Ex5_6_ans;
	set Ex5_6e;
	drop _NAME_;
run;
proc print data=Ex5_6_ans;run;
