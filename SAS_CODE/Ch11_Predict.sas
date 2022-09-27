/***********************************************
Sample program: Ch011  Regression Predict
************************************************/;
/*DM "LOG;CLEAR;OUTPUT;CLEAR;";*/
/**/
/*libname Mydata  'D:\Mydata17';*/
/*ods html;*/

/*******************************;
�Y���ѬO2013/12/31
�������i�m��:�H2005~2013��ƹw��2014��ROA

Example: Case-Simple-Predict
				Model: ROA=b0+b1*LagROA+b2*LagDebtR+b3*LagExpense+e
							where 
							DebtR=Debt/Total Asset, 
							NextROA=ROA in the subsequent year, ROA=NI/Total Asset;
							Expense=���P�O��/��~���J�b�B
Step0: ����������T�A�åB�ư�missing value�P���ݭ�
Step1:�H2005~2012��ƶi��V�m�P���p�Y�ơA���ܼ�lag 1���C�]Note: Y�O2006��2012, X�O2005��2011�^
Step2:�HStep1�����p�Y�ơA�w��2013��ROA�A�Y���n���s�ץ�Step1�ҫ��A����ҫ���{�����C�]Note: Y�O2013, X�O2012�^
Step3:�HStep1���ҫ��A���p���j�k�Y�ơA�w��2014 ROA�A���ܼ�lag 1���C�]Note: Y�O2014, X�O2013�^
Step4: �ɶ��L�F�@�~�A��F2014/12/31�A�]���i�H�o��w�����Z�Ħn���n�C;

*******************************/

***Step 0:�����������;
data Sample;
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	DebtR=LT/AT;
	Expense=XAD/Sale;
	keep Conm yyyy ROA DebtR Expense;
run;
**��Lag;
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

**�ư��j�k�U�ܼƪ�missing value�A�ɦW����reg2;
data Sample3;
	set Sample2;
	if ROA=. then delete;
	if LagDebtR=. then delete;
	if LagExpense=. then delete;
run;
*Smart Method 1; 
data Sample3b;
	set Sample2;
	Array DeleteVars(*) ROA LagROA LagDebtR LagExpense ;	 /*�]�w�}�C�W�ٻP�}�C���]�t���ܼ�*/
	Do i=1 to 4;                                                      /*�w��}�C�����C���ܼơA�i��ۦP�ʧ@(�j��)*/
		if DeleteVars(i)=. then delete;                       /*�Ni=1,2,3,4,5���O�a�J�A�]���|�i��5���ۦP�ʧ@(�j��)*/
	End;	
run;
*Smart Method 2;
%let RegVars=ROA LagROA LagDebtR LagExpense;    /*�]�w�N�W���A�u�n�᭱�J��&RegVars�A�N�|�N����ROA DebtR RD AD GM*/
data Sample3c;
	set Sample2;
	Array DeleteVars(*) &RegVars;            /*&RegVars�A�N�|�N����ROA DebtR RD AD GM*/
	NRegVars=dim(DeleteVars);                /*�p��DeleteVars�}�C���A���h�֭��ܼ�*/
	Do i=1 to NRegVars;
		if DeleteVars(i)=. then delete;
	End;	
run;

**truncate continuous variables�A�b"�C�@�~"winsorize at 1% and 99%;
%Include "C:\Users\ed307\Desktop\school\�j�T�U\�]�g�ƾڤ��R��k\SAS_CODE\Macro-winsorize.sas";   /*����winsorize.sas�o�ӵ{���A���|�ݦۦ�󴫧A�񪺦a��*/

%winsor(dsetin=Sample3, dsetout=Sample4, byvar=yyyy, vars=ROA LagROA LagDebtR LagExpense, type=delete, pctl=1 99); /*trim at 1% and 99%*/

data SampleZ;
	set Sample4;
run;
proc sort out=SampleZ nodup; by Conm  yyyy; run;

**Step1:�H2005~2012��ƶi��V�m�P���p�Y�ơA���ܼ�lag 1���C�]Note: Y�O2006��2012, X�O2005��2011�^;
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
**Step2:�HStep1�����p�Y�ơA�w��2013��ROA�A�Y���n���s�ץ�Step1�ҫ��A����ҫ���{�����C�]Note: Y�O2013, X�O2012�^;
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

***Step3:�HStep1���ҫ��A���p���j�k�Y�ơA�w��2014 ROA�A���ܼ�lag 1���C�]Note: Y�O2014, X�O2013�^;
***Step4: �ɶ��L�F�@�~�A��F2014/12/31�A�]���i�H�o��w�����Z�Ħn���n�C;

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









