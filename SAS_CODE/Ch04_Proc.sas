/***********************************************
Sample program: Ch04  Procedure
************************************************/;

DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

data az;
	set Mydata. F01s_A_financialann;

	DebtR=LT/AT;
	ROA=NI/AT;
	yyyy=year(datadate);
	mm=month(datadate);

	keep gvkey   CONM yyyy mm  sic_tej  DebtR ROA AT;   /*Keep是保留變數, Drop 將變數丟棄, 可以放在很多地方 */
run;
/********************************************************************************************
						 keep, drop; 保留或拿掉變數
********************************************************************************************/
data b1 (keep=conm yyyy at);  /*Keep是保留變數, Drop 將變數丟棄, 可以放在很多地方 */
	set az;
run;
data b2;
	set az(keep=conm yyyy at);
run;
data b3;
	set az;
	keep conm yyyy at;
run;
data b4;
	set b3;
	drop conm at;  /*Keep是保留變數, Drop 將變數丟棄, 可以放在很多地方 */
run;


/********************************************************************************************
						 Proc Sort; 排序
********************************************************************************************/
/*注意各資料檔的樣本數*/
proc sort data=b1 ;          /*預設是由小排到大*/
	by yyyy at; 
run;

proc sort data=b1 out=c1a ; by yyyy at; run;
proc sort data=b1 out=c1b ; by yyyy descending at; run;   /*Descending是由大排到小*/

proc sort data=b4 out=c2a ; by yyyy; run;
proc sort data=b4 out=c2b nodup ; by yyyy; run;  /*Nodup不同列取不重複者*/

proc sort data =az out=c3a nodup; by conm yyyy; run;
proc sort data =az out=c3b nodup; by _all_; run;   /*_all_代表所有變數*/
proc sort data =az out=c3c nodupkey; by conm yyyy; run;  /*Nodupkey:by 的那幾個變數，絕對不重複*/

proc sort data =az out=c4 nodup; by conm descending yyyy; run;

**** 
Exercise 4-1: 以Mydata. F01s_b_ret_monthly 為資料，運用proc sort,  呈現該資料檔內有哪些股票;
data ex4_1;
	set Mydata. F01s_b_ret_monthly;
	keep conm;
run;
proc sort data = ex4_1 out = ex4_1_out nodupkey; by conm;run;


/********************************************************************************************
						 Proc means; 敘述統計,平均數,標準差,加總
						 proc都用quit結束；其他用run結束
********************************************************************************************/
proc sort data=az nodup; by yyyy; run;/*以下proc means內有by, 而只要有by，之前一定要排序*/
proc means data=az n mean;
       var ROA;
       by yyyy;  /*by 可分群進行統計*/
quit;
proc means data=az n mean std median ;
       var ROA;
       class yyyy;   /*Class在『某些』procedure可分群進行統計。但某些procedure中，class & by 的功能不太相同*/
quit;
proc means data=az n mean std median min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
       var ROA DebtR;
        class yyyy;
	    output out=h11 n=n1 n2 mean=m1 m2 median=md1 md2 std=stda stdb;  /*把計算出來的平均數、標準差等儲存到資料檔，方便後續可繼續使用	*/
quit;
proc sort data=az nodup; by yyyy sic_tej; run;
proc means data=az n mean;
       var ROA;
       class yyyy sic_tej;
       output out=h12 mean=mROA;
quit;
proc means data=az n mean;
       var ROA;
       class yyyy sic_tej;
	   weight AT;  /*Weight是進行加權平均*/
quit;
proc means data=az n sum;  /*Sum是加總*/
       var AT;
       by yyyy sic_tej;
       output out=h13A sum=;
quit;
proc means data=az n sum;
       var AT;
       by yyyy sic_tej;
       output out=h13B sum=AT_industry;
quit;

****
Exercise 4-2: 以Mydata. F01s_c_ucgi_owner_summary 為資料，運用proc means,  
呈現每年不同的集團控制型態(ControlType2)的控制持股(OwnerShipR_Control)平均數與中位數, 
並將平均數與中位數存到資料檔 "exercise_out"中;
****
Exercise 4-3: 以Mydata. F01s_b_ret_monthly 為資料，運用proc means,  
呈現每支股票每年的當年度之buy and hold報酬率及有幾筆資料, 
並將得出的結果存到資料檔 "exercise_out"中;



/********************************************************************************************
						Proc transpose; 轉置資料
********************************************************************************************/
proc sort data=h13B out=h21 nodup; by sic_tej; run;
proc transpose data=h21 out=h22 ;
       var AT_industry;
       by sic_tej;
run;
proc transpose data=h21 out=h23 prefix=yy ;  /*prefix是轉製後變數名稱開頭*/
       var AT_industry;
       id yyyy;   /*Id:可將值轉換到變數名稱*/
       by sic_tej;  /*by 之前要確認是否排序過*/
run;
proc transpose data=h23 out=h24 prefix=AT_industry ;
       var yy2006-yy2014;
       by sic_tej;
run;
****
Exercise 4-4: 以Mydata. F01s_b_ret_monthly 為資料，運用proc transpose,  
呈現每年不同的公司月報酬,直行為年與公司名稱, 橫列為月份;
data ex4_4;
	set Mydata. F01s_b_ret_monthly;
	YYYY = year(datadate);
	MMMM = month(datadate);
	keep conm RET YYYY MMMM;
run;
proc sort data=ex4_4 out=ex4_4_1 ; 
	by YYYY conm; 
quit;
proc transpose data=ex4_4_1 out=ex4_4_2 prefix=Mon_;
       var RET;
	   id MMMM;
       by YYYY conm;
quit;
data ex4_4_ans;
	set ex4_4_2;
	drop _NAME_ _LABEL_;
run;



/********************************************************************************************
						Proc univariate;  敘述統計與製作histogram圖
********************************************************************************************/
proc sort data=az nodup; by yyyy; run;
proc univariate data=az ;  /*Proc univariate與proc means類似，但功能更多*/
       var ROA;
quit;
proc univariate data=az plot;
       var ROA;
	   histogram ;  /*Histogram可產生直方圖*/
quit;
proc univariate data=az plot;
       var ROA;
	   class yyyy;
quit;
****
Exercise 4-5: 以Mydata. F01s_b_ret_monthly 為資料，運用proc univariate,  呈現月報酬的頻率分布圖(histogram);
data ex4_5;
	set Mydata. F01s_b_ret_monthly;
	YYYY = year(datadate);
	MMMM = month(datadate);
run;
proc univariate data=ex4_5 plot;
       var RET;
	   histogram ;
quit;


/********************************************************************************************
						 Proc rank; 排名, 分群
********************************************************************************************/
proc sort data=az nodup; by ROA; run;
proc rank data=az out=j1 ;  /*排名是由小到大，，0為起始*/
	var ROA;
	Ranks Rank_ROA;  /*Ranks是將排名存到這變數中*/
run;
proc rank data=az out=j2 groups=3; /*Groups可決定分多少群，排名是由小到大，0為起始*/
	var ROA;
	Ranks Rank_ROA;
run;
proc sort data=az nodup; by yyyy sic_tej ROA; run;
proc rank data=az out=j3 groups=3;
	var ROA;
	by yyyy sic_tej;
	Ranks Rank_ROA;
run;
proc sort data=az nodup; by ROA; run;
proc rank data=az out=j4 percent;  /*Percent 是排序的百分比，就像成績是全班的多少百分比，但在此越接近0代表越小，越接近1越大，*/
	var ROA;
	Ranks Rank_ROA;
run;
****
Exercise 4-6: 以Mydata. F01s_b_ret_monthly 為資料，運用proc rank。
股票投資策略想要找出每個月股票報酬的贏家和輸家。 
將每個月的股票報酬，盡量均等區分為5群，最高的為贏家和最低的為輸家。;
data ex4_6;
	set Mydata. F01s_b_ret_monthly;
	yyyy = year(datadate);
	mmmm = month(datadate);
run;
proc sort data=ex4_6 out=ex4_6_1 nodup; by yyyy mmmm; run;
proc rank data=ex4_6_1 out=ex4_6_2 groups=5; 
	var RET;
	by yyyy mmmm;
	Ranks Rank_RET;
run;
proc sort data=ex4_6_2 out=ex4_6_3 nodup; by yyyy mmmm Rank_RET; run;

data winner;
	set ex4_6_2;
	IF Rank_RET>0 THEN delete;
run;
data loser;
	set ex4_6_2;
	IF Rank_RET<4 THEN delete;
run;

*HW7;

/********************************************************************************************
						 Proc standard; 將變數標準化 (不教)
********************************************************************************************/
proc standard data=az out=k1;  /*可設定標準化的目標平均數(mean)和標準差(std)*/
	var ROA;
run;
proc standard data=az out=k2 mean=50 std=10;
	var ROA;
run;
proc sort data=az nodup; by yyyy sic_tej ROA; run;
proc standard data=az out=k3 mean=50 std=10;
	var ROA;
	by yyyy sic_tej;
run;
****
Exercise 4-7: 以Mydata. F01s_c_ucgi_owner_summary 為資料，運用proc standard，
將每一年的董監席次標準化為平均數=0，標準差=1，的標準化數值。;


/********************************************************************************************
						 Proc tabulate; 製作敘述統計之表格 (不教)  可製作列聯表
********************************************************************************************/
proc tabulate data=az ;
	class sic_tej;  /*class是分類或分群的變數,如類別變數*/
	var ROA;   /*var是要檢驗的數值變數*/
	table sic_tej*ROA*mean;  /*table是要如何呈現表格*/
run;
proc tabulate data=az ;
	class sic_tej;
	var ROA;
	table sic_tej, ROA*mean;  /*只要多一個逗點，就會分”列”或分”頁”*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA ;
	table sic_tej, yyyy*ROA*mean; 
run;
proc sort data=az; by sic_tej; run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA ;
	table yyyy, ROA*mean;
	by sic_tej;
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA ;
	table sic_tej, yyyy, ROA*mean; /*只要多一個逗點，就會分”列”或分”頁”*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA DebtR ;
	table sic_tej, yyyy*(ROA DebtR)*mean;  /*可同時統計多個變數*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var AT;
	table sic_tej, yyyy*AT*sum;
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var AT;
	table sic_tej, yyyy*AT*(n mean sum std min max pctn pctsum);  /*可同時統計多個統計量*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA AT;
	table sic_tej, yyyy, (ROA AT)*(n mean sum std min max pctn pctsum);
run;
****
Exercise 4-8: 以Mydata. F01s_c_ucgi_owner_summary 為資料，運用proc tabulate,
計算每年不同集團控制型態的控制持股(OwnerShipR_Control)平均值， 
並以直排為集團控制型態( ControlType2),橫列為年的方式呈現;



/********************************************************************************************
						 Proc surveyselect; 隨機抽樣 (不教)
********************************************************************************************/
* Simple Random Sample;
proc surveyselect data = az 	method = SRS 	rep = 1 	sampsize = 10 seed = 12345 out = m1;  /*SRS是簡單隨機抽樣 Seed是隨機的起始值 Rep是否重複抽樣(已抽過的是否能夠重抽)*/
	id _all_;
run;
proc surveyselect data = az 	method = SRS 	rep = 1 	sampsize = 10 seed = 12345 out = m2;
	id _all_;
	strata yyyy sic_tej;
run;
*Systematic Random Sample;
proc surveyselect data = az 	method = SYS 	rep = 1 	sampsize = 10 seed = 12345 out = m3; /*SYS是系統抽樣*/
	id _all_;
	strata yyyy sic_tej;
run;
proc means data=m1 ;
	var ROA;
run;

/********************************************************************************************
						 Proc freq; 統計頻率次數
********************************************************************************************/
proc freq data=	az;
	table Conm ;   /*Table決定要如何呈現頻率表“*”是『列聯表』的頻率*/
run;
proc freq data=	az;
	table Conm yyyy ;
run;
proc freq data=	az;
	table sic_tej yyyy ;
run;
proc freq data=	az ;
	table sic_tej*yyyy  ;   /*Table決定要如何呈現頻率表“*”是『列聯表』的頻率*/
run;

proc freq data=	az ;
	table sic_tej*yyyy /norow nocol ; /*cumcol totpct nofreq nopercent norow nocol nocum */ /*Norow, nocol是不要呈現某些列或欄，讓表格比較清爽*/
run;
proc freq data=	az;
	table sic_tej*Conm yyyy*Conm ;
run;
proc freq data=	az;
	table (sic_tej  yyyy)*Conm ;
run;
proc freq data=	az;
	table ROA / missing ; /*Missing是呈現missing variable的次數*/
run;

****
Exercise 4-9: 以Mydata. F01s_c_ucgi_owner_summary 為資料，運用proc freq,呈現每年董監席次的頻率分布.   ;



/********************************************************************************************
Example: 以Mydata. F01s_A_financialann為資料，運用proc rank, proc means, proc transpose,  
將每年的公司,依照ROA分成等比例的5群,並計算每一群的負債比例; 
並以直排為年,橫列為1~5的群組呈現;
***練習結合不同指令，來完成一件複雜的任務
********************************************************************************************/
data Sample;
	set Mydata. F01s_A_financialann;
	DebtR=LT/AT;
	ROA=NI/AT;
	yyyy=year(datadate);

	keep gvkey   CONM yyyy sic_tej  DebtR ROA ;
run;
proc sort nodup; by yyyy ROA; run;
proc rank data=Sample out=Sample2 groups=5;
	var ROA;
	Ranks ROA_rank;
	by yyyy;
run;
data Sample3;
	set Sample2;
	ROA_rank=ROA_rank+1;
run;
proc sort nodup; by yyyy ROA_rank; run;
proc means data=Sample3;
	var DebtR;
	by yyyy ROA_rank;
	output out=Exercise_out mean=mDebtR;
quit;
proc transpose data=Exercise_out out=Exercise_out2 prefix=g;
	var mDebtR;
	by yyyy ;
	id ROA_rank;
quit;
proc print data=Exercise_out2; run;




