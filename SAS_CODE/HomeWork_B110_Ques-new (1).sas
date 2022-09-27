/***********************************************
Sample program: Ch03  Basic Introduction
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

/*******************************;
Homework Ch03-1: 研究資產周轉率是否影響ROE，且區分不同產業
-->將ROE對資產周轉率跑迴歸分析，且每產業跑一次迴歸。
定義:
資產周轉率(Turnover) =總營業額 (Total Revenue) /總資產值 (Total Asset)
ROE=Net Income/Total Equity
資料:mydata. F01s_a_financialann

Homework Ch03-2: 計算每一年法人持股率(InstOwnership)的平均值   (不限2005-2014年)
資料:mydata. F01_c_ucgi_owner_summary   (note:不是F01s_c_ucgi_owner_summary)

*******************************/


/*******************************;
Homework Ch04: 以Mydata. F01s_b_ret_monthly 為資料，運用proc rank, proc means, proc transpose, 
將每年的股票，以"總風險(StdRET)"區分為3群，並計算每一群的平均"年報酬率"。
並以直排為年,橫列為1~10的群組呈現。
定義：總風險(StdRET)以該股票當年度月報酬的標準差
*******************************/


**** 
/*Homework Ch05: 以Mydata. F01_a_financialann, F01_b_ret_monthly  為資料，(note:不是F01s_b_ret_monthly)
(1)計算每一"年"的每個"產業(sic_tej)"的"平均年報酬率" (即該產業個股年報酬率的平均值)。
呈現方式，直的為產業，橫的為年份 (利用proc transpose)。
(2)在每一"年"每個"產業(sic_tej)"中，依照"年報酬率"區分為約略均等的5群，最高那一群設定為"Winer"，最低那一群設定為"Loser"，
若某一年某產業的股票家數不足10家(n<10)者，刪除那一年的那個產業。
a. 將每一年的Winer，通通集合(不論那個產業)在一起為一個大的投資組合，請問每一年，Winer投資組合的報酬率為何？
b. 將每一年的Loser，通通集合(不論那個產業)在一起為一個大的投資組合，請問每一年，Loser投資組合的報酬率為何？
此題呈現方式，直的為群(Loser/Winer)，橫的為年份 (利用proc transpose)。

*提示：
1.此題會應用到proc means (適時使用noprint, 不然會跑很久), proc rank, merge, where, proc transpose, if...then..., delete等指令, 
自行去組合發揮。
2.產業到Mydata. F01_a_financialann找，利用merge方式合併產業和stock returns。
3.若某一年某產業的股票家數不足10家(n<10)者，刪除那一年的那個產業。-->分別利用proc means中 output out=, merge可幫助你達到目的
(note:Homework Ch05的每一題，每一個股票，當年度報酬率月數不足12個月的，要刪除。不然拿來比較不公平。)
*/;

/*******************************;
Homework Ch06: 
Homework:畫出以下series
以F01s_b_ret_monthly為例，畫出"廣達"與"友達"歷月(datadate)的月股價，兩條線畫在同一張圖;
*******************************/


/*******************************;
Homework Ch08: 以Mydata. F01s_a_financialann  Mydata. F01s_c_ucgi_owner_summary為資料，
依照法人持股比率，將每一年每產業區分為高低兩群。
比較高與低兩群之平均ROA是否相等 (含平均數和中位數檢定)。(note:此題平均或中位數是所有年份合在一起看，只有分群時要依照每一年每產業區分)
*******************************/

data s1;
	set Mydata. F01s_a_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	keep gvkey yyyy sic_tej ROA;
run;
proc sort data=s1 nodup; by gvkey yyyy sic_tej ROA; run;
data s2;
	set Mydata. F01s_c_ucgi_owner_summary;
	yyyy=year(datadate);
	keep gvkey yyyy InstOwnership;
run;
proc sort data=s2 nodup; by gvkey yyyy InstOwnership; run;

data HW_8_0;
	merge s1 s2;
	by  gvkey yyyy;
run;
proc sort data=HW_8_0 nodup; by yyyy sic_tej; run;
proc rank data=HW_8_0 out=HW_8_1 groups=2;
	var InstOwnership;
	by yyyy sic_tej;
	Ranks Rank_IO;
run;

proc ttest data = HW_8_1;   /*H0：兩產業的平均ROA相等*/
  class Rank_IO;
  var ROA;
run;

proc npar1way data = HW_8_1 wilcoxon;  /*H0：兩產業的ROA中位數相等*/
  class Rank_IO;
  var ROA;
run;

/*******************************;
Homework Ch09: Case-Simple 
				資料：F01s_a_financialann, F01s_c_ucgi_owner_summary
				Model: InstOwnership=b0+b1*Eletric+b2*logSize+b3*DE_ratio+e;
							where 
							Own_firm=法人持股比例
							Electric=1:電子業(Tej產業別為23), 0 其它產業
							logSize=總資產，取natural logarithm
							DE_ratio=Debt to equity ratio=Debt/Equity
				進行迴歸
*******************************/
data hw9_0;
	set mydata. F01s_a_financialann;
	yyyy = year(DataDate);
	Electric = 0;
	IF sic_tej = 23 THEN Electric = 1;
	logSize = log(AT);
	DE_ratio = LT/CEQ;
	keep gvkey yyyy Electric logSize DE_ratio;
run;

data hw9_1;
	set mydata. F01s_c_ucgi_owner_summary;
	yyyy = year(DataDate);
	keep gvkey yyyy InstOwnership;
run;

proc sort data=hw9_0 nodup; by gvkey yyyy; run;
proc sort data=hw9_1 nodup; by gvkey yyyy; run;

data hw9_2;
	merge hw9_0 hw9_1;
	by  gvkey yyyy;
run;

proc reg data = hw9_2;
  model InstOwnership = Electric logSize DE_ratio ;
run;


/*******************************;
Homework Ch10: 以Mydata. F01s_A_financialann, Mydata. F01s_b_ret_monthly 為資料，進行下列迴歸。
ChgROA=b0+b1*LagRETY+b1*LagDebtR+b2*LagLnSize+e
變數定義：
ChgROA=本期與前一期ROA之差
LagRETY=前一期的年股票報酬率(buy and hold return)
LagDebtR=前一期的負債比率
LagLnSize=前一期的log(總資產)
*******************************/;
