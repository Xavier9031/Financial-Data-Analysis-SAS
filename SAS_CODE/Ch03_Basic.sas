/***********************************************
Sample program: Ch03  Basic Introduction
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";/* 清空輸出 */

libname Mydata  'C:\Users\ed307\Desktop\school\大三下\財經數據分析方法\SAS_CODE\MyData'; /*引號內，大小寫是有差別的*/
ods html;/* 新的呈現方式 */

***  Simple example;
proc print data=mydata. F01_a_financialann ;  /*列印資料*/
run;

proc print data=mydata. F01s_a_financialann(obs=10);   /*列印資料:10筆*/
run;
proc contents data=mydata. F01s_a_financialann;   /*呈現資料內容：按照變數字母順序*/
run;
proc contents data=mydata. F01s_a_financialann varnum; run;  /*呈現資料內容：按照變數時間的順序*/
proc contents data=mydata. F01s_a_financialann varnum short; run;   /*只呈現變數名稱*/


***  Library_Example;

data mydata. test1; /*出現在mydata內*/   /*Data是設立新的資料檔*/
	set mydata. F01s_a_financialann;   /*Set 是將資料檔裝進去*/
run;
data work. test2;   /*出現在work內*/
	set mydata. F01s_a_financialann;
run;
data test3;  /*出現在work內*/
	set mydata. F01s_a_financialann;
run;

***  Mean ROA;
data a1; 
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);    /*將”年”取出來，變成新的變數*/
	ROA=NI/AT;
run;
proc means data=a1;    /*計算平均數*/
	var ROA;
run;
proc sort data=a1; by yyyy ; run;
proc means data=a1;   /*排序*/
	var ROA;
	class yyyy ;
run;
proc sort data=a1; by yyyy sic_tej; run;
proc means data=a1;    /*計算平均數，且每一年的每個產業計算一次*/
	var ROA;
	class yyyy sic_tej;
run;

/*******************************;
Exercise 3-1: 計算每一年的ROE平均值與標準差。
定義:ROE=Net Income/Total Equity。
資料:mydata. F01s_a_financialann
*******************************/

*** regress ROA on DebtR each year;
data a2;
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	DebtR=LT/AT;
run;
proc reg data=a2;
	model ROA=DebtR;   /*regression: Y是ROA, X是DebtR*/
run;  quit;
proc sort data=a2; by yyyy sic_tej; run;
proc reg data=a2;
	model ROA=DebtR;
	by yyyy;      /*每一年分別跑一次迴歸*/
run;  quit;
proc reg data=a2 outest=para1;
	model ROA=DebtR;
	by yyyy sic_tej;   /*每一年的每個產業，分別跑一次迴歸*/
run;  quit;

/*******************************;
Exercise 3-2: 將ROE對毛利率(ProfitR)跑迴歸分析，且每年跑一次迴歸。
定義:
ROE=Net Income/Total Equity。
毛利率(ProfitR) =(營業收入-營業成本)/營業收入
資料:mydata. F01s_a_financialann
*******************************/



