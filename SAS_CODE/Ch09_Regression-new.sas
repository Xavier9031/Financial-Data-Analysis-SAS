/***********************************************
Sample program: Ch09  Regression
************************************************/;

DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;


data reg;
	set Mydata. F01s_A_financialann;
	if AT>0 then DebtR=LT/AT;
	if AT>0 then LnAT=log(AT);
	if CEQ>0 then ROE=NI/CEQ;
	if AT>0 then ROA=NI/AT;
	Distress=(DebtR>0.6);
	ProfitR=(SALE-COGS)/Sale;

	DROA=(ROA>0);
	yyyy=year(datadate);
	keep yyyy gvkey sic_tej conm DebtR LnAT ROE ROA Distress  ProfitR  ;
run;

/********************************************************************************************
						Regression
********************************************************************************************/
/* Simple linear regression   */
proc reg data = reg;
  model ROA = DebtR ;
run; quit;
/*Multiple regression    */
proc reg data = reg;
  model ROA = DebtR ProfitR LnAT ;
run;
**** 
Exercise 9-1: 以Mydata. F01s_c_ucgi_owner_summary 為資料，
				Model: Pledge_director=b0+b1*OwnershipR_Control+b2*NDirector+b3*Family;


/*Simple logistic regression    */
proc sort data=reg nodup; by descending Distress; run;
proc logistic data = reg desc;
  model Distress = DebtR / expb; /*計算odds ratio*/
run;
/*logistic regression    */
proc logistic data = reg desc;
  model Distress = DebtR ProfitR LnAT / expb;
run;



/********************************************************************************************
						Regression: Detail
********************************************************************************************/

proc reg data=reg     ;	
	model DebtR= LnAT ROE   ;
run; quit;
proc reg data=reg   outest=o1  ;	/*Outest:將估計係數存出*/
	model DebtR= LnAT ROE   /rsquare ;
run; quit;
proc reg data=reg   outest=o2 tableout  ;	
	model DebtR= LnAT ROE   /rsquare ;
run; quit;
proc reg data=reg   outest=o3  ;	
	model DebtR= LnAT ROE   /rsquare ;
	ods output ParameterEstimates=t2 FitStatistics=t3 nobs=t4 Anova=t5 ;  /*ods output:將html看到的相關資訊存出*/
run; quit;
proc sort data=reg nodup; by yyyy ;run;
proc reg data=reg   outest=o4  ;	
	model DebtR= LnAT ROE   /rsquare ;
	by yyyy;   /*By:分群估計*/
run; quit;
proc reg data=reg   outest=o5  ;	
	model DebtR= LnAT ROE   /rsquare ;
    output out=output1 p=yhat r=residual ; /*Output:將相關資訊存出*/
run; quit;
proc sort data=reg nodup; by yyyy sic_tej; run;
proc reg data=reg   outest=o6  ;	
	model DebtR= LnAT ROE   /rsquare ;
	by yyyy sic_tej;
    output out=output1 p=yhat r=residual ;
	ods output ParameterEstimates=t2 FitStatistics=t3 nobs=t4 Anova=t5 ;  
run; quit;

/*******************************;
Example: 以Mydata. F01s_b_ret_monthly 為資料，計算"當年度"個股CAPM的系統風險(systematic risk, beta)。Ri=b0+beta*Rm+e。並計算每一個股beta的綜合各年的平均值
*******************************/
data Rm;
	set Mydata. F01s_b_ret_monthly;
	where gvkey = 'Y9999';
	rename RET=Rm;
	keep datadate RET;
run;
proc sort nodup; by datadate; run;
data Sample;
	set Mydata. F01s_b_ret_monthly;
	where gvkey ne 'Y9999' and RET is not missing ;
run;
proc sort nodup; by datadate; run;
data Sample2;   /*將報酬率資料併至主樣本*/
	merge  Rm Sample(in=a);
	by datadate;
	if a=1;
	if Rm=. then delete;
		yyyy=year(datadate);
run;
proc sort data=Sample2 nodup; by conm yyyy; run;
proc reg data=Sample2 outest=Coeff  noprint; 	
	model RET=Rm;
	by conm yyyy;
	output out=Regout p=predicx r=residualx;
quit;
data Coeff2;
	set Coeff;
	Beta=Rm;
	keep conm yyyy Beta;
run;
proc sort nodup; by conm yyyy; run;
proc print; run;
proc means data=Coeff2 mean noprint;
	var Beta;
	class conm;
run;
**** 
Exercise 9-2: 以Mydata. F01s_b_ret_monthly 為資料，計算當年度個股CAPM的非系統風險(non-systematic risk, idiosyncratic risk)。非系統風險是CAPM (Ri=b0+beta*Rm+e)殘差的標準差。;




/*******************************;
Example: Case-Simple
				Model: DebtR=b0+b1*ROA+b2*Pledge_director+b3*OwnershipR_Control+b4*Family+b5*RET_STD+e
							where 
							DebtR=Debt/Total Asset, 
							ROA=NI/Total Asset;
							RET_STD=standard deviation of monthly return in year t
進行迴歸
*******************************/

data Sample;
	set Mydata. F01s_A_financialann;
	DebtR=LT/AT;
	 ROA=NI/AT;
	yyyy=year(datadate);
	keep gvkey yyyy datadate  CONM sic_tej   DebtR ROA  ;

run;
proc sort nodup; by Conm yyyy; run;
/*以下開始一步一步將每個迴歸變數算出*/
*Family OwnershipR_Control;
data Ownership;
	set Mydata. F01s_c_ucgi_owner_summary;
	Family=(ControlType='F');
	yyyy=year(datadate);
	keep yyyy conm Family OwnershipR_Control Pledge_director;
run;
proc sort nodup; by Conm yyyy; run;
*RET_STD;
data RET1;
	set Mydata. F01s_b_ret_monthly;
	yyyy=year(datadate);
	where gvkey ne 'Y9999' and RET is not missing ;
run;
proc sort nodup; by Conm yyyy; run;
proc means data=RET1 std;
	var RET;
	by Conm yyyy;
	output out=RET2 std=RET_std;
quit;
proc sort data=RET2 nodup; by Conm yyyy; run;

data Sample2; /*將每個迴歸變數合併到主樣本*/
	merge RET2 Ownership Sample (in=a);
	by Conm yyyy;
	if a=1;
run;

proc reg data=Sample2     ;	
	model DebtR= ROA Pledge_director OwnershipR_Control  Family RET_STD  ;
run; quit;



/********************************************************************************************
						Logistic Regression: Detail
********************************************************************************************/
proc sort data=reg nodup; by descending Distress;run;
proc logistic data=reg desc  ;
	model Distress=LnAT ROE    /link=logit rsquare   ;
run;quit;
proc logistic data=reg desc  ;
	model Distress=LnAT ROE    /link=probit rsquare   ; /*Probit Regression*/
run;quit;
proc sort data=reg nodup; by sic_tej descending Distress;run;
proc logistic data=reg outest=s1 desc ;
	model Distress=LnAT ROE    /link=logit rsquare   ;
	by sic_tej;
run;quit;
proc logistic data=reg outest=s1 desc ;/*此例,by 與class意義不同*/
	class yyyy  /Param=REF;  /*設定類別變數的dummy variable*/
	model Distress=LnAT ROE yyyy   /link=logit rsquare  expb ;
run;quit;
proc logistic data=reg outest=s1 desc ;
	class yyyy  /Param=REF;
	model Distress=LnAT ROE yyyy   /link=logit rsquare  expb ;
	output out=yhat p=zyhat;
	ods output ParameterEstimates=s2 rsquare=s3 nobs=s4 ModelInfo=s5;
run;quit;

**** 
Exercise 9-3: 以Mydata. F01s_A_financialann為資料，每個產業分別執行下列Logistic迴歸模型
				Model: P(DROA=1)=b0+b1*DebtR+b2*LnAT
				DROA=1指ROA>0
				LnAT=log(AT)。;
				
