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
Exercise 9-1: �HMydata. F01s_c_ucgi_owner_summary ����ơA
				Model: Pledge_director=b0+b1*OwnershipR_Control+b2*NDirector+b3*Family;


/*Simple logistic regression    */
proc sort data=reg nodup; by descending Distress; run;
proc logistic data = reg desc;
  model Distress = DebtR / expb; /*�p��odds ratio*/
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
proc reg data=reg   outest=o1  ;	/*Outest:�N���p�Y�Ʀs�X*/
	model DebtR= LnAT ROE   /rsquare ;
run; quit;
proc reg data=reg   outest=o2 tableout  ;	
	model DebtR= LnAT ROE   /rsquare ;
run; quit;
proc reg data=reg   outest=o3  ;	
	model DebtR= LnAT ROE   /rsquare ;
	ods output ParameterEstimates=t2 FitStatistics=t3 nobs=t4 Anova=t5 ;  /*ods output:�Nhtml�ݨ쪺������T�s�X*/
run; quit;
proc sort data=reg nodup; by yyyy ;run;
proc reg data=reg   outest=o4  ;	
	model DebtR= LnAT ROE   /rsquare ;
	by yyyy;   /*By:���s���p*/
run; quit;
proc reg data=reg   outest=o5  ;	
	model DebtR= LnAT ROE   /rsquare ;
    output out=output1 p=yhat r=residual ; /*Output:�N������T�s�X*/
run; quit;
proc sort data=reg nodup; by yyyy sic_tej; run;
proc reg data=reg   outest=o6  ;	
	model DebtR= LnAT ROE   /rsquare ;
	by yyyy sic_tej;
    output out=output1 p=yhat r=residual ;
	ods output ParameterEstimates=t2 FitStatistics=t3 nobs=t4 Anova=t5 ;  
run; quit;

/*******************************;
Example: �HMydata. F01s_b_ret_monthly ����ơA�p��"��~��"�Ӫ�CAPM���t�έ��I(systematic risk, beta)�CRi=b0+beta*Rm+e�C�íp��C�@�Ӫ�beta����X�U�~��������
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
data Sample2;   /*�N���S�v��ƨ֦ܥD�˥�*/
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
Exercise 9-2: �HMydata. F01s_b_ret_monthly ����ơA�p���~�׭Ӫ�CAPM���D�t�έ��I(non-systematic risk, idiosyncratic risk)�C�D�t�έ��I�OCAPM (Ri=b0+beta*Rm+e)�ݮt���зǮt�C;




/*******************************;
Example: Case-Simple
				Model: DebtR=b0+b1*ROA+b2*Pledge_director+b3*OwnershipR_Control+b4*Family+b5*RET_STD+e
							where 
							DebtR=Debt/Total Asset, 
							ROA=NI/Total Asset;
							RET_STD=standard deviation of monthly return in year t
�i��j�k
*******************************/

data Sample;
	set Mydata. F01s_A_financialann;
	DebtR=LT/AT;
	 ROA=NI/AT;
	yyyy=year(datadate);
	keep gvkey yyyy datadate  CONM sic_tej   DebtR ROA  ;

run;
proc sort nodup; by Conm yyyy; run;
/*�H�U�}�l�@�B�@�B�N�C�Ӱj�k�ܼƺ�X*/
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

data Sample2; /*�N�C�Ӱj�k�ܼƦX�֨�D�˥�*/
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
proc logistic data=reg outest=s1 desc ;/*����,by �Pclass�N�q���P*/
	class yyyy  /Param=REF;  /*�]�w���O�ܼƪ�dummy variable*/
	model Distress=LnAT ROE yyyy   /link=logit rsquare  expb ;
run;quit;
proc logistic data=reg outest=s1 desc ;
	class yyyy  /Param=REF;
	model Distress=LnAT ROE yyyy   /link=logit rsquare  expb ;
	output out=yhat p=zyhat;
	ods output ParameterEstimates=s2 rsquare=s3 nobs=s4 ModelInfo=s5;
run;quit;

**** 
Exercise 9-3: �HMydata. F01s_A_financialann����ơA�C�Ӳ��~���O����U�CLogistic�j�k�ҫ�
				Model: P(DROA=1)=b0+b1*DebtR+b2*LnAT
				DROA=1��ROA>0
				LnAT=log(AT)�C;
				
