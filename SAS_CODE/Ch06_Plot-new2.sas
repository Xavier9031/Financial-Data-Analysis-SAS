/***********************************************
Sample program: Ch06  Plot
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

data sample_reduce;
	set Mydata. F01s_A_financialann;

	DebtR=LT/AT;
	ROA=NI/AT;
	ROE=NI/CEQ;

	yyyy=year(datadate);
	if abs(ROA)>100 then delete;
	keep gvkey datadate  CONM sic_tej  SICb  yyyy DebtR ROA ROE   AT ;

run;
proc sort nodup; by yyyy; run;
data sample_big;
	set Mydata. F01_A_financialann;

	DebtR=LT/AT;
	ROA=NI/AT;
	ROE=NI/CEQ;

	yyyy=year(datadate);
	if abs(ROA)>100 then delete;
	keep gvkey datadate  CONM sic_tej  SICb  yyyy DebtR ROA ROE   AT  Sale ;

run;
proc sort nodup; by yyyy; run;          
 
/******************************************************/
***Pie Chart:����;
******************************************************/;
proc sgpie data=sample_reduce;
  	pie conm   ;  /*�W�v*/
*  	pie conm/datalabeldisplay=all    ;/*�i�H�e�{�ʤ���*/
run;
proc sgpie data=sample_reduce;
	where yyyy=2014;
  	pie conm /response=sale  ;
*  	pie conm /response=sale datalabeldisplay=all ; /*�i�H�e�{�ʤ���*/
*	pie conm /response=sale datalabeldisplay=all datalabelloc=outside;
*  pie conm /response=sale datalabeldisplay=all datalabelloc=callout;
run;
***����;
proc sgpie data=sample_reduce;
	where yyyy=2014;
  	donut conm /response=sale  ;
run;
proc sgpie data=sample_big;
	where yyyy=2014;
  	pie SIC_tej/datalabeldisplay=all  datalabelloc=callout  ;
run;


***Exercise 6-1:�e�X�H�UPie Chart
�HF01_c_ucgi_owner_summary���ҡA�e�{���P�������O(���α���A(ControlType2))�b2013�~���˥���"����"��Bar Chart;
data Ex6_1a;
	set Mydata. F01_c_ucgi_owner_summary;
	yyyy=year(datadate);
run;

proc sgpie data=Ex6_1b;
	where yyyy=2013;
  	pie ControlType2/datalabeldisplay=all;
run;

/********************************************************************************************
						Bar Chart: ������-�W�v�� (X�b�A�����O�ܼ�)
********************************************************************************************/
***���P���O���W�v;
proc sgplot data=sample_big ; 
	vbar  yyyy ;  /*�W�v*/  /*vbar �i�אּhbar (����)*/
*	vbar  yyyy /datalabel;  
*	vbar  yyyy /datalabel stat=pct;
*	vbar  yyyy /datalabel stat=pct categoryorder=respdesc ;  /*categoryorder=respdesc �O�Ѥj��p�Ƨ�*/
*	vbar  yyyy /datalabel stat=pct categoryorder=respdesc seglabel;  /*seglabel�O�N�ƾڼg�J�Ϥ�*/
run;
proc sgplot data=sample_big ;
	where yyyy>2011;
	vbar  sic_tej /group=yyyy groupdisplay=cluster; /*group�O���p�s��Agroupdisplay �i��� cluster or stack*/
*	styleattrs datacolors=(bioy);  /*�����C��*/
run;
proc sgplot data=sample_big ;
	where yyyy>2011;
	vbar  sic_tej /group=yyyy groupdisplay=cluster stat=pct ;  
*	vbar  sic_tej /group=yyyy groupdisplay=stack stat=pct ; /*stack�O���|*/
*	vbar  sic_tej /group=yyyy groupdisplay=stack stat=pct seglabel ; /*seglabel�O�N�Ʀr�g�J�ϧ�*/
run;

***Exercise 6-2: �e�X�H�U��iBar Chart
1.�HF01_c_ucgi_owner_summary���ҡA�e�{���P�������O(���α���A(ControlType2))���˥��ƪ�Bar Chart;
proc sgplot data=Mydata. F01_c_ucgi_owner_summary ;
	vbar  ControlType2 /datalabel;
run;


*2.�HF01_c_ucgi_owner_summary���ҡA�e�{���P�������O(���α���A(ControlType2))���˥���"����"��Bar Chart;
proc sgplot data=Mydata. F01_c_ucgi_owner_summary ;
	vbar  ControlType2 /datalabel stat=pct;
run;



***�@�몺������;
data temp;
	set sample_reduce;
	where gvkey='2330';
run;
proc sgplot data=temp ;
	vbar  yyyy /response=ROA ;  
*	vbar  yyyy /response=ROA seglabel;  
run;
*method 2;
proc sgplot data=sample_reduce ;
	where gvkey='2330';
	vbar  yyyy /response=ROA seglabel;  /*�S���]�wstat�A�w�]��"�[�`"*/
run;

***Exercise 6-3: �e�X�H�UBar Chart
�HF01s_b_ret_monthly���ҡA���X2014�~12�멳�Ҧ�"�Ӫ�"�ѻ�(Prc)��Bar Chart (���t�[�v���ƪ�����S);

proc sgplot data=Mydata. F01s_b_ret_monthly ;
	where year(datadate) = 2014 && month(datadate) = 12 && gvkey ne 'Y9999';
	vbar  conm /response=Prc datalabel;  
run;


***���P���O��������(�έp�q)�A���u�O�W�v;
proc sgplot data=sample_big ;
*	where yyyy=2014;
	vbar  sic_tej /response=ROA ;  /*�S���]�wstat�A�w�]��"�[�`"*/
run;
proc sgplot data=sample_big ;
	vbar  sic_tej /response=ROA stat=mean ;  /*stat=FREQ | MEAN | MEDIAN | PERCENT | SUM*/
run;

title  "Bar Chart of mean ROA by Industry";
proc sgplot data=sample_big ;
	vbar  sic_tej /response=ROA stat=mean ;  
    xaxis label="Industry";
    yaxis label="Mean ROA";
 	keylegend / title="Variable" location=inside position=topright  across=1;
run;
goptions reset=all;                                                   
proc sgplot data=sample_big ;
	vbar  sic_tej /response=ROA stat=mean ;  
    xaxis display=(nolabel);
    yaxis display=(nolabel);
run;
goptions reset=all;                                                   

proc sgplot data=sample_big ;
	vline  yyyy /response=ROA stat=mean ;  
run;
proc sgplot data=sample_big ;
	vbar  yyyy /response=ROA stat=mean ;  
	vline  yyyy /response=ROA stat=mean ;  
run;

***Exercise 6-4:
Exercise:�e�X�H�UBar Chart
1.�HF01_c_ucgi_owner_summary���ҡA�e�{���P�������O(���α���A(ControlType2))���k�H����%(InstOwnership)��������;

proc sgplot data=Mydata. F01_c_ucgi_owner_summary ;
	vbar  ControlType2 /response=InstOwnership stat=mean datalabel ;  
run;



/********************************************************************************************
						Series:��u��
********************************************************************************************/
proc sgplot data=sample_reduce;
	where gvkey='2330';
	series y=ROA  x=yyyy ;
run;quit;
proc sgplot data=sample_reduce;
	where gvkey='2330';
	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) ;  /*���ܶ��I�ϥ�*/
*	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) lineattrs = (color=red   thickness = 2) ; /*���ܽu���C��*/
*	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) lineattrs = (color=red   thickness = 2) 
	  datalabel datalabelattrs=(size=12); /*�N�ƭȼg�J�Ϥ�*/
run;quit;
proc sgplot data=sample_reduce;
	where gvkey='2330';
	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) lineattrs = (color=red   thickness = 2) 
	  datalabel datalabelattrs=(size=12);
	xaxis label="�~" valueattrs=(size=14) fitpolicy=rotate  labelattrs=(size=14)  ;
	yaxis label="�겣���S�v(ROA)"    labelattrs=(size=14)  valueattrs=(size=14);
run;quit;

***Exercise 6-5:�e�X�H�Useries
�HF01s_b_ret_monthly���ҡA�e�X"�[�v����"���몺����;

data Ex6_5;
	set mydata. F01s_b_ret_monthly;
	yyyy = year(datadate);
	mm = month((datadate));
	where gvkey = "Y9999";
run;

proc sgplot data=Ex6_5;
	series y=PRC  x=datadate;
run;quit;


***�ⶵseries�e�b�P�@�i�Ϥ�;
proc sgplot data= sample_reduce;
	where gvkey='2330';
	series y=ROA x=yyyy  ;
	series y=DebtR x=yyyy ;
run; quit;

proc sgplot data= sample_reduce;
	where gvkey='2330';
	series y=ROA x=yyyy/markers markerattrs=(symbol=circlefilled color=red  size=12) lineattrs = (color=red   thickness = 2) ;  ;
	series y=DebtR x=yyyy/markers markerattrs=(symbol=DiamondFilled color=blue  size=12) lineattrs = (color=blue   thickness = 2) ; ;
run; quit;
proc sgplot data= sample_reduce;
	where gvkey='2330';
	spline y=ROA x=yyyy ;
run; quit;
proc sgplot data= sample_reduce;
	where gvkey='2330';
	series y=ROA x=yyyy  ;
	spline y=ROA x=yyyy ;
run; quit;

proc sgplot data= sample_reduce; /*not good*/
	where gvkey='2330';
	series y=ROA x=DebtR ;
run; quit;

***Exercise 6-6:�e�X�H�Useries
�HF01_c_ucgi_owner_summary���ҡA
�e�Ϥ��"�x�n�q"���~(datadate)���k�H����%(InstOwnership)�M�������(OwnerShipR_Control), �e�b�P�@�i�Ϥ�;


/********************************************************************************************
						scatter: XY���G��
********************************************************************************************/
proc sgplot data=sample_reduce;
	scatter x=ROA  y=DebtR ;
run;
proc sgplot data=sample_reduce;
	scatter x=ROA  y=DebtR ;
	ellipse x=ROA  y=DebtR ;
* 	reg  x=ROA y=DebtR;
run;
proc sgplot data=sample_reduce;
	scatter x=ROA  y=DebtR/markerattrs=(symbol=circlefilled size=20 )   ;
*	scatter x=ROA  y=DebtR/markerattrs=(symbol=circlefilled size=20 ) 
	filledoutlinedmarkers markerfillattrs=(color=yellow) markeroutlineattrs=(color=red thickness=2)  markeroutlineattrs=(color=red thickness=2)  ;
run;

*Example;
proc sgplot data=sample_reduce  ;
	scatter x=ROA y=DebtR /  markerattrs=(size=8 symbol=circlefilled color=red ) name="dot";
	ellipse x=ROA y=DebtR/ name="ellipse";
	reg  x=ROA y=DebtR /nomarkers lineattrs=(pattern=1 color=gray thickness=0.6%) name="reg";
	keylegend "ellipse" "reg" /location= inside noborder;
	styleattrs backcolor=white wallcolor=white;    
	xaxis valueattrs=(size=8) label="Debt Ratio";
	yaxis  valueattrs=(size=8) label="ROA";
run;

***Exercise 6-7:�e�X�H�UXY���G��
�HF01s_c_ucgi_owner_summary���ҡA�e�X�H�UXY���G�ϡAX�b���������%�AY�b�����ƽ��%�A�å[�J�j�k���Ͷսu��;



/********************************************************************************************
						Histogram:�W�v���t��
********************************************************************************************/
proc sgplot data=sample_reduce ;
	histogram  ROA;
*	density ROA;
run;
proc sgplot data=sample_reduce ; 
	histogram  ROA ;
	histogram  DebtR  ;
*	density ROA;
*	density DebtR;
run;
proc sgplot data=sample_big ;
	histogram  yyyy;
run;
proc sgplot data=sample_big ;/*not good*/
	histogram  sic_tej;
run;
proc sgplot data=sample_reduce ;/*not ok*/
	histogram  conm;/*not ok, The variable must be numeric*/
run;

***Exercise 6-8: �HMydata. F01s_b_ret_monthly ����ơA���X����S���W�v�����ʤ���histogram (���t�[�v���ƪ�����S);
proc sgplot data = Mydata. F01s_b_ret_monthly;
	WHERE gvkey NE 'Y9999';
	histogram  rET;
	DNSITY ret;
run;


/********************************************************************************************
*Example:�e�Ϥ���x�n�q�M�E�����~ROA,�e�b�P�@�i�Ϥ�
********************************************************************************************/
data sample1;
	set Mydata. F01s_A_financialann;
	year=year(datadate);
	ROA=NI/AT;
run;
proc sort nodup; by year; run;
**Method01;
data f2330;
	set sample1;
	where gvkey='2330';
	rename ROA=ROA2330;
	keep year ROA;
run;
data f2317;
	set sample1;
	where gvkey='2317';
	rename ROA=ROA2317;
	keep year ROA;
run;
data merge1;  /*��l��Ƥ��O�@�}�l�N�ŦX�n�D�A�]���ݹw���i���z*/
	merge f2330 f2317;
	by year;
run;
proc sgplot data= merge1;
	series y=ROA2330 x=year  ;
	series y=ROA2317 x=year ;
run; quit;
**Method02;  /*��transpose�]�\�{���|��²�u*/
data sample2;
	set sample1;
	where gvkey='2330' or gvkey='2317';
run;
proc sort data=sample2 nodup; by year gvkey; run;
proc transpose data=sample2 out=sample3 prefix=ROA;
	var ROA;
	by year;
	id gvkey;
quit;
proc sgplot data= merge1;
	series y=ROA2330 x=year  ;
	series y=ROA2317 x=year ;
run; quit;



***Note:
*color
https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0edl20cvxxmm9n1i9ht3n21eict.htm;
*symbol:
https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0i3rles1y5mvsn1hrq3i2271rmi.htm
;
