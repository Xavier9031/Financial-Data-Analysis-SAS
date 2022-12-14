/***********************************************
Sample program: Ch05  Data Processing
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

/********************************************************************************************
						基本運算: :+ - * / 次方, rename
********************************************************************************************/

data a1;
	set Mydata. F01s_A_financialann;

	ATnew=CEQ+LT;
	Profit=SALE-COGS;
	DebtR=LT/AT;
	 ROA=NI/AT;
	Debt=AT*DebtR;
	logSize=log(AT);  /*Log是ln, 不是真的log*/
	
	ROA2=ROA**2; /*平方*/
	ROA3=ROA**3; /*三次方*/
	ROA4=sqrt(ROA);  /*開根號*/
	ROA5=ROA**0.5;  /*開根號*/
	rename XAD=XADnew;  /*更改變數名稱  Rename 舊=新*/
run;

data a2;
	set a1;
	if AT ne . and AT ne 0 then DebtR2=LT/AT; /*避免分母為0 或missing會出現警告訊息，所以加上這些條件；符合條件才執行; ne is not equal*/
	/*條件可以多個條件，但then 後面只能做一件事*/
	/*條件必須寫完整，若寫if AT ne . and  ne 0 then DebtR2=LT/AT  是不完整的條件;*/
	if AT>0 then DebtR3=LT/AT;
	if AT>0 then LnAT=log(AT);

	if AT>0 then do ; /*若then後面要做好多件事情，要像這樣寫*/
		DebtR4=LT/AT;
		LnAT2=log(AT);
		ROA=NI/AT;
	end;
	if CEQ>0 then ROE=NI/CEQ;
	keep gvkey datadate  CONM sic_tej  SICb DebtR ROA logSize AT Sale ;


run;
/********************************************************************************************
						 Calendar  Function: 取出year qtr month;
********************************************************************************************/
data az;
	set a2;
	yyyy=year(datadate);
	qq=qtr(datadate);
	mm=month(datadate);
	yyyymm=yyyy*100+mm;
	yyyyqq=yyyy*100+qq;
	sic4=substr(SICb,1,4); /*Substr是取出文字變數中的文字*/

run;




/********************************************************************************************
					Where: 篩選資料	 ; 
********************************************************************************************/
data c0;
	set az;
	where yyyy>=2010;  /*Where中的條件可以是=,>,<,>=,<=, ne, between*/
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
	where ROA is not missing;  /*?釩?排除missing value*/
run;
data c7;
	set az;
	where yyyy between 2008 and 2010;
run;
**** 
*Exercise 5-1: 以Mydata. F01s_c_ucgi_owner_summary 為資料，取出董監質押超過百分之70的公司;
**** 
*Exercise 5-2: 以Mydata. F01s_b_ret_monthly 為資料，取出個股月報酬(不含加權指數的月報酬);




/********************************************************************************************
				If...then:可設dummy variable, 分群 ; 
********************************************************************************************/
data d0;
	set az;
	where yyyy>=2010;
	keep yyyy sic_tej SICb;
run;
proc sort nodupkey; by yyyy;run;

data d1;  /*if中可以設定多重條件，and, or*/
	set d0;
	if yyyy=2014 then d1a=1; 
	if yyyy=2014 then d1b=1; else d1b=0;
	if yyyy=2014 and sic_tej=12 then d1c=1; else d1c=0;
	if yyyy=2014 then d1d='last';
	d2b=(yyyy=2014); /*較簡便*/
	d2c=(yyyy=2014 and sic_tej=12);  
run;
data d2;
	set d0;
	if yyyy=2014 then delete;
run;
data d3;
	set d0;
	if yyyy=2014 then output; /*Output是指匯出為資料檔*/
run;
data d4;
	set d0;
	if yyyy ne 2014 then delete;
run;

data d5; /*分群的作法*/
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
*Exercise 5-3: 以Mydata. F01s_c_ucgi_owner_summary 為資料，若為家族企業，則Family=1，其它設為0;
data Ex5_3;
	set Mydata. F01s_c_ucgi_owner_summary;
	if ControlType == 'F' then Family = 1;
	else Family = 0;
run;

**** 
*Exercise 5-4: 以Mydata F01s_c_ucgi_owner_summary 為資料，以董監人數，每五人為間距分群，運用proc freq,呈現每年每一群董監席次的頻率分布. ;
data Ex5_4;
	set Mydata. F01s_c_ucgi_owner_summary;

run;


/********************************************************************************************
			資料合併:	set-上下合,  merge:左右合;	
Merge是非常重要的功能，資料整理常常要運用該技巧

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
	set e1a e1b;  ??/*可以將兩個資料檔垂直疊起來 但不常這樣使用 請小心*/;
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
	merge f1A f1B;  /*可以將兩個資料檔左右合併*/
	by conm;
run;
data f3;
	merge f1A(in=c) f1B;
	by  conm;
	if c=1; *if c;   /*只保留左手邊有進來的資料*/
run;
data f4;
	merge f1A(in=c) f1B(in=f);
	by  conm;
	if f=1; /*只保留右手邊有進來的資料*/
run;
data f5;
	merge f1A(in=c) f1B(in=f);
	by  conm;
	if c=1 and f=1; /*只保留左手和右手邊都有進來的資料*/
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
/*合併時要一對一,多對一,一對多, 但切忌多對多合併*/
/*沒有一對一關係 樣本亂膨脹*/
data g6;
	merge g1A(in=c) g1B(in=f);
	by  conm ;
	if c=1 and f=1; 
run;


/********************************************************************************************
					*Example: 以Mydata. F01s_A_financialann  為資料，計算每家公司每一年的industry adjusted ROA(ROA_Adj)。industry adjusted ROA(ROA_Adj)=ROA- mean ROA of the corresponding industry;
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
data k1; /*先算產業平均， 再併回去，這樣才能相減*/
       merge Sample industry_ROA (drop=_type_ _freq_);
       by yyyy sic_tej;
       ROA_Adj=ROA-mROA;
run;

**** 
*Exercise 5-5: 以Mydata. F01s_A_financialann Mydata F01s_c_ucgi_owner_summary 為資料，計算每年家族企業與非家族企業ROA平均數及中位數;
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
*Exercise 5-6: 以Mydata. F01s_b_ret_monthly 為資料，找出每一"年"Market adjusted return。Market adjusted return=RET-Rm, Rm是market portfolio returns. 並呈現直行為年，橫列為公司;
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
