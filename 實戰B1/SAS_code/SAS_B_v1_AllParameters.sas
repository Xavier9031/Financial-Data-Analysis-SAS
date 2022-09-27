/*匯入&刪去金融業*/
PROC IMPORT OUT= WORK.price
    DATAFILE= "C:\Users\ed307\Desktop\sas_B\股價資料_n.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;

data price1;
	set price;
	yyyy = year(_COL2);
	_COL0 = cat("TW_", _COL0);
	rename _COL0 = sid;
	rename _COL1 = conm;
	rename _COL2 = datadate;
	rename _COL3 = num;
	rename _COL4 = dy;
	rename _COL5 = PE;
	rename _COL6 = ind;
	rename _COL7 = par;
	rename _COL8 = sale;
	rename _COL9 = return;
    rename _COL10 = turn;
RUN;
 
PROC IMPORT OUT= WORK.account
    DATAFILE= "C:\Users\ed307\Desktop\sas_B\會計資料_n.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;
data account1;
set account;
yyyy = year(_COL2);
_COL0 = cat("TW_", _COL0);
rename _COL0 = sid;
rename _COL1 = conm;
rename _COL2 = datadate;
rename _COL5 = debtr;
rename _COL6 = roa;
rename _COL7 = roe;
rename _COL8 = netg;
RUN;
PROC IMPORT OUT= WORK.bhs
    DATAFILE= "C:\Users\ed307\Desktop\sas_B\董監持股_n.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;
data bhs1;
set bhs;
yyyy = year(_COL2);
_COL0 = cat("TW_", _COL0);
rename _COL0 = sid;
rename _COL1 = conm;
rename _COL2 = datadate;
rename _COL3 = shr;
rename _COL4 = she;
rename _COL5 = mshe;
RUN;
*排序一下;
proc sort data=bhs1 nodup; by sid yyyy; run;
proc sort data=account1 nodup; by sid yyyy; run;
proc sort data=price1 nodup; by sid yyyy; run;
data complete;
merge bhs1 account1 price1;
by sid yyyy;
run;
data complete1;
set complete;
WHERE ind ne '金融控股';
RUN;
data complete1;
set complete1;
WHERE ind ne '證券';
RUN;
data complete1;
set complete1;
WHERE ind ne '產險業';
RUN;
data complete1;
set complete1;
WHERE ind ne '期貨';
RUN;
data complete1;
set complete1;
WHERE ind ne '票券公司';
RUN;
data complete1;
set complete1;
WHERE ind ne '本國銀行';
RUN;

/*計算個股 CAPM 模型得到的非系統風險，即為此殘差的標準差*/
PROC IMPORT OUT= WORK.market
    DATAFILE= "C:\Users\ed307\Desktop\sas_B\market_return\mk_r.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;
PROC IMPORT OUT= WORK.market_return
    DATAFILE= "C:\Users\ed307\Desktop\sas_B\market_return\mk_rm.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;

data market_return_1;
	set market_return;
	_COL3 = _COL3/100;
	mm = month(_COL2);
	yyyy =year(_COL2);
	_COL0 = cat("TW_", _COL0);
	rename _COL0 = sid;
	rename _COL1 = conm;
	rename _COL2 = date;
	rename _COL3 = Rm;
	keep mm yyyy _COL3;
RUN;

data market_1;
	set market;
	_COL4 = _COL4/100;
	mm = month(_COL3);
	yyyy =year(_COL3);
	_COL0 = cat("TW_", _COL0);
	rename _COL0 = sid;
	rename _COL1 = conm;
	rename _COL2 = tej_type;
	rename _COL3 = date;
	rename _COL4 = return;
RUN;

proc sort data = market_1 nodup; by yyyy mm sid; run;
proc sort data = market_return_1 nodup; by yyyy mm; run;

data market_2;
	merge market_1 market_return_1;
	by yyyy mm;
run;

proc sort data = market_2 nodup; by sid yyyy mm; run;

proc reg data=market_2 outest=market_reg noprint; 	
	model return = Rm;
	by sid yyyy;
	output out=market_reg_E p=predicx r=residualx;
quit;

proc sort data = market_reg_E nodup; by sid yyyy; run;

proc means data=market_reg_E STD noprint;
	var residualx;
	by sid yyyy;
	output out=e_std_1 std=idiorisk;
run;


data e_std;
	set e_std_1;
	keep sid yyyy idiorisk;
run;

/*合併殘差的標準差與匯入的資料*/
proc sort data = e_std nodup; by sid yyyy; run;
proc sort data = complete1 nodup; by sid yyyy; run;

data complete2;
	merge complete1(in=c) e_std;
	by sid yyyy;
	if c = 1;
run;

/*求風險溢酬*/
PROC IMPORT OUT= WORK.risk_free
    DATAFILE= "C:\Users\ed307\Desktop\sas_B\risk_free.xlsx"
    DBMS=EXCEL REPLACE ;
	GETNAMES=YES;
	MIXED=NO;
	SCANTEXT=YES;
	USEDATE=YES;
	SCANTIME=YES;
RUN;


proc sort data = complete2 nodup; by yyyy sid; run;
proc sort data = risk_free nodup; by yyyy; run;

data complete3;
	merge complete2 risk_free;
	by yyyy;
run;

data complete4;
	set complete3;
	where yyyy >= 2002;
run;

data complete5;
	set complete4;
	risk_premium = return - risk_free_rate;
run;

proc sort data = complete5 nodup; by sid yyyy; run;

/*資料處理&留下需要的資料*/
data complete6;
	set complete5;
	risk_premium = risk_premium/100;
	risk_free_rate = risk_free_rate/100;
	shr = shr/100;
	she = she/100;
	mshe = mshe/100;
	debtr = debtr/100;
	netg = netg/100;
	dy = dy/100;
	return = return/100;
	turn = turn/100;
	drop datadate roa roe num ind;
run;

/*取lag*/
proc sort data = complete6 nodup; by sid yyyy; run;

data complete7;
	set complete6;
	by sid  yyyy;
	Lag_shr=lag(shr);
	Lag_she=lag(she);
	Lag_mshe=lag(mshe);
	Lag_Tobins_Q=lag(Tobins_Q);
	Lag_Tobins_Q_A=lag(Tobins_Q__A_);
	Lag_debtr=lag(debtr);
	Lag_dy = lag(dy);
	Lag_netg=lag(netg);
	Lag_PE=lag(PE);
	Lag_par=lag(par);
	Lag_sale=lag(sale);
	Lag_return=lag(return);
	Lag_turn=lag(turn);
	Lag_idiorisk = lag(idiorisk);
	Lag_riskprem = lag(risk_premium);
	if first. sid then do;
		Lag_shr=.;
		Lag_she=.;
		Lag_mshe=.;
		Lag_Tobins_Q=.;
		Lag_Tobins_Q_A=.;
		Lag_debtr=.;
		Lag_dy=.;
		Lag_netg=.;
		Lag_PE=.;
		Lag_par=.;
		Lag_sale=.;
		Lag_return=.;
		Lag_turn=.;
		Lag_idiorisk=.;
		Lag_riskprem=.;
	end;
run;
data complete8;
	set complete7;
	if risk_premium=. then delete;
	if Lag_shr=. then delete;
	if Lag_she=. then delete;
	if Lag_mshe=. then delete;
	if Lag_Tobins_Q=. then delete;
	if Lag_Tobins_Q_A=. then delete;
	if Lag_debtr=. then delete;
	if Lag_dy=. then delete;
	if Lag_netg=. then delete;
	if Lag_PE=. then delete;
	if Lag_par=. then delete;
	if Lag_sale=. then delete;
	if Lag_return=. then delete;
	if Lag_turn=. then delete;
	if Lag_idiorisk=. then delete;
	if Lag_riskprem=. then delete;
run;
data complete9;
	set complete8;
	drop conm shr she mshe Tobins_Q Tobins_Q__A_ debtr dy netg PE par sale return turn idiorisk risk_free_rate;
run;

/*移除極值*/
%Include "C:\Users\ed307\Desktop\school\大三下\財經數據分析方法\SAS_CODE\Macro-winsorize.sas";   /*執行winsorize.sas這個程式，路徑需自行更換你放的地方*/
%winsor(dsetin=complete9, dsetout=complete10, byvar = yyyy, vars = risk_premium , type=delete , pctl=3 97); /*trim at 3% and 97%*/


/*去除極端值前*/
data SampleU;
	set complete9;
run;
proc sort out=SampleU nodup; by yyyy sid ; run;

proc means data=SampleU n mean std median min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
	var risk_premium Lag_shr Lag_she Lag_mshe Lag_Tobins_Q Lag_Tobins_Q_A Lag_debtr Lag_dy Lag_netg Lag_PE Lag_par Lag_sale Lag_return Lag_turn Lag_idiorisk Lag_riskprem;
run;

proc means data=SampleU n mean std median min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
	var risk_premium Lag_shr Lag_she Lag_mshe Lag_Tobins_Q Lag_Tobins_Q_A Lag_debtr Lag_dy Lag_netg Lag_PE Lag_par Lag_sale Lag_return Lag_turn Lag_idiorisk Lag_riskprem;
	by yyyy;
run;

/*去除極端值後*/
data SampleZ;
	set complete10;
run;
proc sort out=SampleZ nodup; by yyyy sid ; run;

proc means data=SampleZ n mean std median min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
	var risk_premium Lag_shr Lag_she Lag_mshe Lag_Tobins_Q Lag_Tobins_Q_A Lag_debtr Lag_dy Lag_netg Lag_PE Lag_par Lag_sale Lag_return Lag_turn Lag_idiorisk Lag_riskprem;
run;

proc means data=SampleZ n mean std median min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
	var risk_premium Lag_shr Lag_she Lag_mshe Lag_Tobins_Q Lag_Tobins_Q_A Lag_debtr Lag_dy Lag_netg Lag_PE Lag_par Lag_sale Lag_return Lag_turn Lag_idiorisk Lag_riskprem;
	by yyyy;
run;

PROC CORR DATA=SampleZ;
  TITLE "Correlation Matrix";
  VAR risk_premium Lag_shr Lag_she Lag_mshe Lag_Tobins_Q Lag_Tobins_Q_A Lag_debtr Lag_dy Lag_netg Lag_PE Lag_par Lag_sale Lag_return Lag_turn Lag_idiorisk Lag_riskprem;
RUN;

proc sort out=SampleZ nodup; by sid  yyyy; run;
**Step1:以2004~2019資料進行訓練與估計係數，自變數lag 1期;
data Estimate1;
	set SampleZ;
	where yyyy between 2004 and 2019;
run;


/*tuning start*/

proc reg data=Estimate1 outest=Coeff     ; 	
model risk_premium= Lag_shr Lag_she Lag_mshe Lag_Tobins_Q Lag_Tobins_Q_A Lag_debtr Lag_dy Lag_netg Lag_PE Lag_par Lag_sale Lag_return Lag_turn Lag_idiorisk Lag_riskprem;
quit;

data Coeff2;
	set Coeff;
	B0=Intercept;
	B1=Lag_shr;
	B2=Lag_she;
	B3=Lag_mshe;
	B4=Lag_Tobins_Q;
	B5=Lag_Tobins_Q_A;
	B6=Lag_debtr;
	B7=Lag_dy;
	B8=Lag_netg;
	B9=Lag_PE;
	B10=Lag_par;
	B11=Lag_sale;
	B12=Lag_return;
	B13=Lag_turn;
	B14=Lag_idiorisk;
	B15=Lag_riskprem;
	keep B0-B15;
run;

**Step2:以Step1的估計係數，預測，若不好重新修正Step1模型，直到模型表現不錯。;
Data PredictA1;
	set SampleZ;
	where yyyy=2020;
run;
proc sql;
	create table PredictA2 as
	select *
	from PredictA1, Coeff2;
quit;
data PredictA3;
	set PredictA2;
	Predict_risk_premium=B0+B1*Lag_shr+B2*Lag_she+B3*Lag_mshe+B4*Lag_Tobins_Q+B5*Lag_Tobins_Q_A+B6*Lag_debtr+B7*Lag_dy+B8*Lag_netg+B9*Lag_PE+B10*Lag_par+B11*Lag_sale+B12*Lag_return+B13*Lag_turn+B14*Lag_idiorisk+B15*Lag_riskprem;
	Error=risk_premium-Predict_risk_premium;
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

***Step3:以Step1的模型，估計之迴歸係數，預測，自變數lag 1期。;
***Step4: 時間過了一年，因此可以得到預測的績效好不好。;

Data PredictB1;
	set SampleZ;
	where yyyy=2021;
run;
proc sql;
	create table PredictB2 as
	select *
	from PredictB1, Coeff2;
quit;
data PredictB3;
	set PredictB2;
	Predict_risk_premium=B0+B1*Lag_shr+B2*Lag_she+B3*Lag_mshe+B4*Lag_Tobins_Q+B5*Lag_Tobins_Q_A+B6*Lag_debtr+B7*Lag_dy+B8*Lag_netg+B9*Lag_PE+B10*Lag_par+B11*Lag_sale+B12*Lag_return+B13*Lag_turn+B14*Lag_idiorisk+B15*Lag_riskprem;
	Error=risk_premium-Predict_risk_premium;
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

