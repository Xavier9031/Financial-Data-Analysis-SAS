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
proc ttest data = az h0 = 0.02;  /*H0Mean ROA=0.02*/
  var ROA;
run;

/*One sample median test*/
proc univariate data = az loccount mu0 = 0.02;  /*H0Median ROA=0.02*/
  var ROA;
run;*LOCCOUNT:requests a table that shows the number of observations greater than, not equal to, and less than the value of MU0=.;


/*One sample proportion: Binomial test    */
proc freq data = az;   /*H0Proportion of positive ROA  =0.5*/
  tables DROA / binomial(p=.1);
  exact binomial;
run;

**** 
Exercise 8-1: Mydata. F01s_b_ret_monthly 戈浪﹚キАる厨筍瞯(ぃ絃)琌=0;


/********************************************************************************************
						Two Sample Test
********************************************************************************************/

/* Two independent samples t-test   */
proc ttest data = az;   /*H0ㄢ玻穨キАROA单*/
  class sic_tej;
  var ROA;
run;

/*Wilcoxon-Mann-Whitney test    */
proc npar1way data = az wilcoxon;  /*H0ㄢ玻穨ROAい计单*/
  class sic_tej;
  var ROA;
run;

/*Paired t-test    */
proc ttest data = az;  /*H0ROA籔ProfitRキА计单*/
  paired ROA*ProfitR;
run;

/* Wilcoxon signed rank sum test   */
data aza;
  set az;
  diff = ROA - ProfitR;
run;
proc univariate data = aza; /*H0ROA籔ProfitRキА计单*/
  var diff;
run;

/*Compare proportion in two sample*/;
proc freq data=az;   /*H0ㄢ玻穨positive ROAゑㄒ单*/
        table DROA*sic_tej / chisq ;
 run;

**** 
Exercise 8-2: Mydata. F01s_c_ucgi_owner_summary 戈浪﹚產壁穨籔獶產壁穨ぇ赋菏借┿ゑ瞯琌单 (キА计㎝い计浪﹚);
**** 
Exercise 8-3: Mydata. F01s_A_financialann, Mydata. F01s_c_ucgi_owner_summary 戈ゑ耕筿穨籔珇穨ぇ產壁穨ゑㄒ琌单 (Chi-square test);



/********************************************************************************************
						Correlations
********************************************************************************************/
/* Correlation   */
proc corr data = az; /*Pearson correlation coefficients*/
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
Exercise 8-4: Mydata. F01s_c_ucgi_owner_summary 戈瞷赋菏借┿ゑ瞯北ゑ瞯赋菏畊Ω產壁穨pearson correlation&spearman correlation;





