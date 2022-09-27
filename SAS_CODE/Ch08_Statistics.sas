/***********************************************
Sample program: Ch06  Hypothesis Test
************************************************/;

DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

data az;
	set Mydata. F01s_A_financialann;

	ProfitR=(SALE-COGS)/Sale;
	DebtR=LT/AT;
	 ROA=NI/AT;
	logSize=log(AT);
	DROA=(ROA>0);

	yyyy=year(datadate);
	keep gvkey yyyy datadate  CONM sic_tej   DebtR ROA logSize AT Sale ProfitR DROA;

run;

/********************************************************************************************
						One Sample Test
********************************************************************************************/

/*One sample t-test*/
proc ttest data = az h0 = 0.02;
  var ROA;
run;

/*One sample median test*/
proc univariate data = az loccount mu0 = 0.02;
  var ROA;
run;*LOCCOUNT:requests a table that shows the number of observations greater than, not equal to, and less than the value of MU0=.;


/*One sample proportion: Binomial test    */
proc freq data = az;
  tables DROA / binomial(p=.1);
  exact binomial;
run;

**** 
Exercise 8-1: �HMydata. F01s_b_ret_monthly ����ơA�˩w�Ӫѥ�������S�v(���t�j�L)�O�_=0;


/********************************************************************************************
						Two Sample Test
********************************************************************************************/

/* Two independent samples t-test   */
proc ttest data = az;
  class sic_tej;
  var ROA;
run;

/*Wilcoxon-Mann-Whitney test    */
proc npar1way data = az wilcoxon;
  class sic_tej;
  var ROA;
run;

/*Paired t-test    */
proc ttest data = az;
  paired ROA*ProfitR;
run;

/* Wilcoxon signed rank sum test   */
data aza;
  set az;
  diff = ROA - ProfitR;
run;
proc univariate data = aza;
  var diff;
run;

/*Compare proportion in two sample*/;
proc freq data=az;
        table DROA*sic_tej / chisq riskdiff;
 run;

**** 
Exercise 8-2: �HMydata. F01s_c_ucgi_owner_summary ����ơA�˩w�a�ڥ��~�P�D�a�ڥ��~�����ʽ���v�O�_�۵� (�t�����ƩM������˩w);

/********************************************************************************************
						Correlations
********************************************************************************************/
/* Correlation   */
proc corr data = az;
  var ROA ProfitR;
run;
proc corr data = az;
  var ROA ProfitR DebtR;
run;
/*Non-parametric spearman correlation    */
proc corr data = az spearman;
  var ROA ProfitR DebtR;
run;
**** 
Exercise 8-3: �HMydata. F01s_c_ucgi_owner_summary ����ơA�e�{���ʽ���v�B������Ѥ�v�B���ʮu���B�a�ڥ��~��pearson correlation&spearman correlation;




/********************************************************************************************
						Freq Test
********************************************************************************************/
/* Chi-square goodness of fit  */
proc freq data = az;
  tables DROA / chisq testp=(30 70);
run;
/*Chi-square test    */
proc freq data = az;
  tables DROA*sic_tej / chisq;
run;

/*Fisher's exact test    */
proc freq data = az;
  tables DROA*sic_tej / fisher;
run;

proc freq data=az;
*        weight Count;
        table DROA*sic_tej  / chisq riskdiff;
run;quit;


**** 
Exercise 8-4: �HMydata. F01s_A_financialann, Mydata. F01s_c_ucgi_owner_summary ����ơA����q�l�~�P���~�~�a�ڥ��~����ҬO�_�۵� (Chi-square test);


