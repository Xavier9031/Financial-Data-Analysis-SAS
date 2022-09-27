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
***Pie Chart:圓餅圖;
******************************************************/;
proc sgpie data=sample_reduce;
  	pie conm   ;  /*頻率*/
*  	pie conm/datalabeldisplay=all    ;/*可以呈現百分比*/
run;
proc sgpie data=sample_reduce;
	where yyyy=2014;
  	pie conm /response=sale  ;
*  	pie conm /response=sale datalabeldisplay=all ; /*可以呈現百分比*/
*	pie conm /response=sale datalabeldisplay=all datalabelloc=outside;
*  pie conm /response=sale datalabeldisplay=all datalabelloc=callout;
run;
***圓圈圖;
proc sgpie data=sample_reduce;
	where yyyy=2014;
  	donut conm /response=sale  ;
run;
proc sgpie data=sample_big;
	where yyyy=2014;
  	pie SIC_tej/datalabeldisplay=all  datalabelloc=callout  ;
run;


***Exercise 6-1:畫出以下Pie Chart
以F01_c_ucgi_owner_summary為例，呈現不同控制類別(集團控制型態(ControlType2))在2013年之樣本數"佔比"的Bar Chart;
data Ex6_1a;
	set Mydata. F01_c_ucgi_owner_summary;
	yyyy=year(datadate);
run;

proc sgpie data=Ex6_1b;
	where yyyy=2013;
  	pie ControlType2/datalabeldisplay=all;
run;

/********************************************************************************************
						Bar Chart: 長條圖-頻率圖 (X軸適用類別變數)
********************************************************************************************/
***不同類別的頻率;
proc sgplot data=sample_big ; 
	vbar  yyyy ;  /*頻率*/  /*vbar 可改為hbar (水平)*/
*	vbar  yyyy /datalabel;  
*	vbar  yyyy /datalabel stat=pct;
*	vbar  yyyy /datalabel stat=pct categoryorder=respdesc ;  /*categoryorder=respdesc 是由大到小排序*/
*	vbar  yyyy /datalabel stat=pct categoryorder=respdesc seglabel;  /*seglabel是將數據寫入圖中*/
run;
proc sgplot data=sample_big ;
	where yyyy>2011;
	vbar  sic_tej /group=yyyy groupdisplay=cluster; /*group是分小群體，groupdisplay 可選擇 cluster or stack*/
*	styleattrs datacolors=(bioy);  /*改變顏色*/
run;
proc sgplot data=sample_big ;
	where yyyy>2011;
	vbar  sic_tej /group=yyyy groupdisplay=cluster stat=pct ;  
*	vbar  sic_tej /group=yyyy groupdisplay=stack stat=pct ; /*stack是堆疊*/
*	vbar  sic_tej /group=yyyy groupdisplay=stack stat=pct seglabel ; /*seglabel是將數字寫入圖形*/
run;

***Exercise 6-2: 畫出以下兩張Bar Chart
1.以F01_c_ucgi_owner_summary為例，呈現不同控制類別(集團控制型態(ControlType2))之樣本數的Bar Chart;
proc sgplot data=Mydata. F01_c_ucgi_owner_summary ;
	vbar  ControlType2 /datalabel;
run;


*2.以F01_c_ucgi_owner_summary為例，呈現不同控制類別(集團控制型態(ControlType2))之樣本數"佔比"的Bar Chart;
proc sgplot data=Mydata. F01_c_ucgi_owner_summary ;
	vbar  ControlType2 /datalabel stat=pct;
run;



***一般的長條圖;
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
	vbar  yyyy /response=ROA seglabel;  /*沒有設定stat，預設為"加總"*/
run;

***Exercise 6-3: 畫出以下Bar Chart
以F01s_b_ret_monthly為例，劃出2014年12月底所有"個股"股價(Prc)的Bar Chart (不含加權指數的月報酬);

proc sgplot data=Mydata. F01s_b_ret_monthly ;
	where year(datadate) = 2014 && month(datadate) = 12 && gvkey ne 'Y9999';
	vbar  conm /response=Prc datalabel;  
run;


***不同類別的平均數(統計量)，不只是頻率;
proc sgplot data=sample_big ;
*	where yyyy=2014;
	vbar  sic_tej /response=ROA ;  /*沒有設定stat，預設為"加總"*/
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
Exercise:畫出以下Bar Chart
1.以F01_c_ucgi_owner_summary為例，呈現不同控制類別(集團控制型態(ControlType2))之法人持股%(InstOwnership)的平均數;

proc sgplot data=Mydata. F01_c_ucgi_owner_summary ;
	vbar  ControlType2 /response=InstOwnership stat=mean datalabel ;  
run;



/********************************************************************************************
						Series:折線圖
********************************************************************************************/
proc sgplot data=sample_reduce;
	where gvkey='2330';
	series y=ROA  x=yyyy ;
run;quit;
proc sgplot data=sample_reduce;
	where gvkey='2330';
	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) ;  /*改變圓點圖示*/
*	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) lineattrs = (color=red   thickness = 2) ; /*改變線的顏色*/
*	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) lineattrs = (color=red   thickness = 2) 
	  datalabel datalabelattrs=(size=12); /*將數值寫入圖中*/
run;quit;
proc sgplot data=sample_reduce;
	where gvkey='2330';
	series y=ROA  x=yyyy /markers markerattrs=(symbol=circlefilled color=red  size=12) lineattrs = (color=red   thickness = 2) 
	  datalabel datalabelattrs=(size=12);
	xaxis label="年" valueattrs=(size=14) fitpolicy=rotate  labelattrs=(size=14)  ;
	yaxis label="資產報酬率(ROA)"    labelattrs=(size=14)  valueattrs=(size=14);
run;quit;

***Exercise 6-5:畫出以下series
以F01s_b_ret_monthly為例，畫出"加權指數"歷月的指數;

data Ex6_5;
	set mydata. F01s_b_ret_monthly;
	yyyy = year(datadate);
	mm = month((datadate));
	where gvkey = "Y9999";
run;

proc sgplot data=Ex6_5;
	series y=PRC  x=datadate;
run;quit;


***兩項series畫在同一張圖中;
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

***Exercise 6-6:畫出以下series
以F01_c_ucgi_owner_summary為例，
畫圖比較"台積電"歷年(datadate)之法人持股%(InstOwnership)和控制持股(OwnerShipR_Control), 畫在同一張圖內;


/********************************************************************************************
						scatter: XY散佈圖
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

***Exercise 6-7:畫出以下XY散佈圖
以F01s_c_ucgi_owner_summary為例，畫出以下XY散佈圖，X軸為控制持股%，Y軸為董事質押%，並加入迴歸的趨勢線圖;



/********************************************************************************************
						Histogram:頻率分配圖
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

***Exercise 6-8: 以Mydata. F01s_b_ret_monthly 為資料，劃出月報酬的頻率分布百分比的histogram (不含加權指數的月報酬);
proc sgplot data = Mydata. F01s_b_ret_monthly;
	WHERE gvkey NE 'Y9999';
	histogram  rET;
	DNSITY ret;
run;


/********************************************************************************************
*Example:畫圖比較台積電和鴻海歷年ROA,畫在同一張圖內
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
data merge1;  /*原始資料不是一開始就符合要求，因此需預先進行整理*/
	merge f2330 f2317;
	by year;
run;
proc sgplot data= merge1;
	series y=ROA2330 x=year  ;
	series y=ROA2317 x=year ;
run; quit;
**Method02;  /*用transpose也許程式會較簡短*/
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
