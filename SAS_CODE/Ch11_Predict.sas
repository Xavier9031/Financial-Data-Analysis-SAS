/***********************************************
Sample program: Ch011  Regression Predict
************************************************/;
/*DM "LOG;CLEAR;OUTPUT;CLEAR;";*/
/**/
/*libname Mydata  'D:\Mydata17';*/
/*ods html;*/

/*******************************;
若今天是2013/12/31
期末報告練習:以2005~2013資料預測2014的ROA

Example: Case-Simple-Predict
				Model: ROA=b0+b1*LagROA+b2*LagDebtR+b3*LagExpense+e
							where 
							DebtR=Debt/Total Asset, 
							NextROA=ROA in the subsequent year, ROA=NI/Total Asset;
							Expense=推銷費用/營業收入淨額
Step0: 收集相關資訊，並且排除missing value與極端值
Step1:以2005~2012資料進行訓練與估計係數，自變數lag 1期。（Note: Y是2006～2012, X是2005～2011）
Step2:以Step1的估計係數，預測2013的ROA，若不好重新修正Step1模型，直到模型表現不錯。（Note: Y是2013, X是2012）
Step3:以Step1的模型，估計之迴歸係數，預測2014 ROA，自變數lag 1期。（Note: Y是2014, X是2013）
Step4: 時間過了一年，到了2014/12/31，因此可以得到預測的績效好不好。;

*******************************/

***Step 0:收集相關資料;
data Sample;
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	DebtR=LT/AT;
	Expense=XAD/Sale;
	keep Conm yyyy ROA DebtR Expense;
run;
**取Lag;
proc sort nodup; by Conm  yyyy; run;
data Sample2;
	set Sample;
	by Conm  yyyy;
	LagROA=lag(ROA);
	LagDebtR=lag(DebtR);
	LagExpense=lag(Expense);
	if first. Conm then do;
		LagROA=.;
		LagDebtR=.;
		LagExpense=.;
	end;
run;

**排除迴歸各變數的missing value，檔名取為reg2;
data Sample3;
	set Sample2;
	if ROA=. then delete;
	if LagDebtR=. then delete;
	if LagExpense=. then delete;
run;
*Smart Method 1; 
data Sample3b;
	set Sample2;
	Array DeleteVars(*) ROA LagROA LagDebtR LagExpense ;	 /*設定陣列名稱與陣列內包含的變數*/
	Do i=1 to 4;                                                      /*針對陣列內的每個變數，進行相同動作(迴圈)*/
		if DeleteVars(i)=. then delete;                       /*將i=1,2,3,4,5分別帶入，因此會進行5次相同動作(迴圈)*/
	End;	
run;
*Smart Method 2;
%let RegVars=ROA LagROA LagDebtR LagExpense;    /*設定代名詞，只要後面遇到&RegVars，就會代換為ROA DebtR RD AD GM*/
data Sample3c;
	set Sample2;
	Array DeleteVars(*) &RegVars;            /*&RegVars，就會代換為ROA DebtR RD AD GM*/
	NRegVars=dim(DeleteVars);                /*計算DeleteVars陣列中，有多少個變數*/
	Do i=1 to NRegVars;
		if DeleteVars(i)=. then delete;
	End;	
run;

**truncate continuous variables，在"每一年"winsorize at 1% and 99%;
%Include "C:\Users\ed307\Desktop\school\大三下\財經數據分析方法\SAS_CODE\Macro-winsorize.sas";   /*執行winsorize.sas這個程式，路徑需自行更換你放的地方*/

%winsor(dsetin=Sample3, dsetout=Sample4, byvar=yyyy, vars=ROA LagROA LagDebtR LagExpense, type=delete, pctl=1 99); /*trim at 1% and 99%*/

data SampleZ;
	set Sample4;
run;
proc sort out=SampleZ nodup; by Conm  yyyy; run;

**Step1:以2005~2012資料進行訓練與估計係數，自變數lag 1期。（Note: Y是2006～2012, X是2005～2011）;
data Estimate1;
	set SampleZ;
	where yyyy between 2006 and 2012;
run;
proc reg data=Estimate1 outest=Coeff     ; 	
	model ROA= LagROA LagDebtR LagExpense;
quit;
data Coeff2;
	set Coeff;
	B0=Intercept;
	B1=LagROA;
	B2=LagDebtR;
	B3=LagExpense;

	keep B0-B3;
run;
**Step2:以Step1的估計係數，預測2013的ROA，若不好重新修正Step1模型，直到模型表現不錯。（Note: Y是2013, X是2012）;
Data PredictA1;
	set SampleZ;
	where yyyy=2013;
run;
proc sql;
	create table PredictA2 as
	select *
	from PredictA1, Coeff2;
quit;
data PredictA3;
	set PredictA2;
	Predict_ROA=B0+B1*LagROA+B2*LagDebtR+B3*LagExpense;
	Error=ROA-Predict_ROA;
	Abs_Error=abs(Error);
	Error2=Error**2;
run;
proc means data=PredictA3 mean noprint;
	var Abs_Error Error2;
	output out=Predict_PerformanceA1 mean=MAE MSE;
run;
data Predict_PerformanceA2;
	set Predict_PerformanceA1;
	RMSE=sqrt(MSE);
	keep MAE RMSE;
run;
proc print data=Predict_PerformanceA2; run;

***Step3:以Step1的模型，估計之迴歸係數，預測2014 ROA，自變數lag 1期。（Note: Y是2014, X是2013）;
***Step4: 時間過了一年，到了2014/12/31，因此可以得到預測的績效好不好。;

Data PredictB1;
	set SampleZ;
	where yyyy=2014;
run;
proc sql;
	create table PredictB2 as
	select *
	from PredictB1, Coeff2;
quit;
data PredictB3;
	set PredictB2;
	Predict_ROA=B0+B1*LagROA+B2*LagDebtR+B3*LagExpense;
	Error=ROA-Predict_ROA;
	Abs_Error=abs(Error);
	Error2=Error**2;
run;
proc means data=PredictB3 mean noprint;
	var Abs_Error Error2;
	output out=Predict_PerformanceB1 mean=MAE   MSE;
run;
data Predict_PerformanceB2;
	set Predict_PerformanceB1;
	RMSE=sqrt(MSE);
	keep MAE RMSE;
run;
proc print data=Predict_PerformanceB2; run;









