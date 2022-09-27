/***********************************************
Sample program: Ch06  Plot
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;


data az;
	set Mydata. F01s_A_financialann;

	DebtR=LT/AT;
	ROA=NI/AT;
	ROE=NI/CEQ;

	yyyy=year(datadate);
	AT2=AT/1000000;
	Sale2=Sale/1000000;
	DebtR2=DebtR*100;
	keep gvkey datadate  CONM sic_tej  SICb  yyyy DebtR ROA ROE   AT AT2 Sale Sale2 DebtR2;

run;
proc sort nodup; by yyyy; run;
                 
proc means data=az mean;
	var ROA ROE DebtR ;
	by yyyy;
	output out=out_data mean=mROA mROE mDebtR;
run;


/********************************************************************************************
						Bar Chart: 長條圖-頻率圖
********************************************************************************************/

/* Bar Chart*/
proc gchart data= az;
	vbar ROA  ;
run; quit;
proc gchart data= az;
	hbar ROA ;
run; quit;
proc gchart data= az;
	vbar ROA /Type=pct ;  /*可以呈現百分比*/
run; quit;
*TYPE = 選項：可以指定 SAS 用某一種描述統計值繪圖。常用選項為:FREQ 次數繪圖,PCT 百分比繪圖,CFREQ 累積次數繪圖, CPCT 累積百分比繪圖;

proc gchart data= az;
	vbar SICb ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar SICb ;
run; quit;

**** 
*Exercise 6-1 : 以Mydata. F01s_b_ret_monthly 為資料，劃出月報酬的頻率分布百分比的Bar Chart (不含加權指數的月報酬);


/********************************************************************************************
						Bar Chart: 長條圖- 橫軸為類別,縱軸為數值
********************************************************************************************/
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=DebtR ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=DebtR2 ;   /*有些變數的單位，不被SAS認可，所以要轉換單位*/
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=AT2 ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=Sale2 ;
run; quit;
/* Bar3d Chart*/
proc gchart data= az;
	where yyyy=2014;
	vbar3d Conm  /Freq=DebtR2 ;
run; quit;

**** 
*Exercise 6-2 : 以Mydata. F01s_b_ret_monthly 為資料，劃出2014年12月底各股股價的Bar Chart (不含加權指數的月報酬);



/********************************************************************************************
						Pie Chart: 圓餅圖-頻率
********************************************************************************************/

/*pie Chart*/
proc gchart data= az;
	where yyyy=2014;
	pie SICb ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	pie Conm ;
run; quit;
proc gchart data= az;
	where yyyy=2014;  
	pie Sale2 ;  /*有些變數的單位，不被SAS認可，所以要轉換單位*/
run; quit;
/********************************************************************************************
						Pie Chart: 圓餅圖-類別與數值百分比
********************************************************************************************/
proc gchart data= az;
	where yyyy=2014;
	pie Conm/ Freq=Sale2  ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	pie Conm/ Freq=Sale2 Type=percent  ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	pie Conm/ Freq=Sale Type=percent  ;
run; quit;

/*pie3d Chart*/
proc gchart data= az;
	where yyyy=2014;
	pie3d Conm/ Freq=Sale2 Type=percent  ;
run; quit;

**** 
*Exercise 6-3: 以Mydata F01s_c_ucgi_owner_summary 為資料，畫出2014年集團控制百分比的Pie Chart ;
*Exercise 6-3-new: 以Mydata F01s_c_ucgi_owner_summary 為資料，畫出2014年不同集團控制類型(變數名稱：ControlType2)各占多少百分比的Pie Chart ;


/********************************************************************************************
						Proc Gplot : XY圖, 單一條線

							可以繪製XY 散布圖或折線圖
							可以初步了解兩變數間之關聯性

********************************************************************************************/
proc gplot data= az;
	plot ROA*DebtR;
run; quit;

symbol1 color=blue  value=dot;    /*改變線的形式*/
proc gplot data= az;
	plot ROA*DebtR;
run; quit;

proc gplot data= az;
	plot ROA*yyyy;
run; quit;
proc gplot data= out_data;
	plot mROA*yyyy;
run; quit;
goptions reset=all;                                                   


**** 
*Exercise 6-4 : 以Mydata. F01s_b_ret_monthly 為資料，劃出2011~2015年"加權指數"歷月之股價;
                                       


/********************************************************************************************
						Proc Gplot: XY圖, 兩條線
********************************************************************************************/

proc gplot data= out_data;
	plot mROA*yyyy mDebtR*yyyy /overlay ;  /*overlay是讓兩線在同一張圖呈現*/
run; quit;

symbol1 interpol=join color=vibg value=dot;                       /*設定線的格式*/                                                                      
symbol2 interpol=join color=mob font=marker value=C height=0.7;     
legend1 position=(top center inside)     label=none  mode=share; /*legend是設定註解的格式*/
axis1  label=none  ;                                                /*Axis是設定X軸與Y軸的格式*/                                                         
axis2 label=none;               
proc gplot data= out_data;
	plot mROA*yyyy mDebtR*yyyy /overlay legend=legend1 haxis=axis1 vaxis=axis2;
run; quit;

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
symbol1 interpol=join color=vibg value=dot;                                                                                             
symbol2 interpol=join color=mob font=marker value=C height=0.7;     
legend1 position=(top center inside)     label=none  mode=share; 
axis1  label=none  ;                                                                                                         
axis2 label=none;               
proc gplot data= merge1;
	plot ROA2330*year ROA2317*year /overlay legend=legend1 haxis=axis1 vaxis=axis2 ;
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
proc gplot data= sample3;
	plot ROA2330*year ROA2317*year /overlay legend=legend1 haxis=axis1 vaxis=axis2 ;
run; quit;
                                                     
**** 
*Exercise 6-5 : 以Mydata. F01s_b_ret_monthly 為資料，畫圖比較2011~2015年台積電和鴻海歷月股價走勢,畫在同一張圖內;
                        
                                                                                                                       



/********************************************************************************************
*Example: 彙整 Gplot
********************************************************************************************/

/* Create sample data */                                                                                                                
data sample;                                                                                                                            
   do Xvar=1 to 10;                                                                                                                     
      Yvar1=round(ranuni(0)*(30));                                                                                                      
      Yvar2=round(ranuni(0)*(70-40))+40;                                                                                                
      Yvar3=round(ranuni(0)*(100-70))+70;                                                                                               
      output;                                                                                                                           
   end;                                                                                                                                 
run;                                                                                                                                    
                                                                                                                                        
/* Define the title */                                                                                                      
title1 "Use Solid-Filled Symbols with PROC GPLOT";                                                                                      
                                                                                                                                        
/* Define symbol characteristics */                                                                                                     
symbol1 interpol=join value=squarefilled   color=vibg height=2;                                                                         
symbol2 interpol=join value=trianglefilled color=depk height=2;                                                                         
symbol3 interpol=join value=diamondfilled  color=mob  height=2;                                                                         
/* Define legend characteristics */                                                                                                     
legend1 label=none frame;                                                                                                               
/* Define axis characteristics */                                                                                                       
axis1 label=("X Variable") minor=none offset=(1,1);                                                                                     
axis2 label=(angle=90 "Y Variable")                                                                                                     
      order=(0 to 100 by 10) minor=(n=1);                                                                                               
                                                                                                                                        
proc gplot data=sample;                                                                                                                 
   plot (yvar1 yvar2 yvar3)*xvar / overlay legend=legend1 haxis=axis1 vaxis=axis2;                                                                             
run;                                                                                                                                    
quit;     

*更多內容可參照https://support.sas.com/sassamples/graphgallery/PROC_GPLOT.html;

