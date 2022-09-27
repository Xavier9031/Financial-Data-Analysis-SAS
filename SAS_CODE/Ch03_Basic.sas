/***********************************************
Sample program: Ch03  Basic Introduction
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";/* �M�ſ�X */

libname Mydata  'C:\Users\ed307\Desktop\school\�j�T�U\�]�g�ƾڤ��R��k\SAS_CODE\MyData'; /*�޸����A�j�p�g�O���t�O��*/
ods html;/* �s���e�{�覡 */

***  Simple example;
proc print data=mydata. F01_a_financialann ;  /*�C�L���*/
run;

proc print data=mydata. F01s_a_financialann(obs=10);   /*�C�L���:10��*/
run;
proc contents data=mydata. F01s_a_financialann;   /*�e�{��Ƥ��e�G�����ܼƦr������*/
run;
proc contents data=mydata. F01s_a_financialann varnum; run;  /*�e�{��Ƥ��e�G�����ܼƮɶ�������*/
proc contents data=mydata. F01s_a_financialann varnum short; run;   /*�u�e�{�ܼƦW��*/


***  Library_Example;

data mydata. test1; /*�X�{�bmydata��*/   /*Data�O�]�߷s�������*/
	set mydata. F01s_a_financialann;   /*Set �O�N����ɸ˶i�h*/
run;
data work. test2;   /*�X�{�bwork��*/
	set mydata. F01s_a_financialann;
run;
data test3;  /*�X�{�bwork��*/
	set mydata. F01s_a_financialann;
run;

***  Mean ROA;
data a1; 
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);    /*�N���~�����X�ӡA�ܦ��s���ܼ�*/
	ROA=NI/AT;
run;
proc means data=a1;    /*�p�⥭����*/
	var ROA;
run;
proc sort data=a1; by yyyy ; run;
proc means data=a1;   /*�Ƨ�*/
	var ROA;
	class yyyy ;
run;
proc sort data=a1; by yyyy sic_tej; run;
proc means data=a1;    /*�p�⥭���ơA�B�C�@�~���C�Ӳ��~�p��@��*/
	var ROA;
	class yyyy sic_tej;
run;

/*******************************;
Exercise 3-1: �p��C�@�~��ROE�����ȻP�зǮt�C
�w�q:ROE=Net Income/Total Equity�C
���:mydata. F01s_a_financialann
*******************************/

*** regress ROA on DebtR each year;
data a2;
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	DebtR=LT/AT;
run;
proc reg data=a2;
	model ROA=DebtR;   /*regression: Y�OROA, X�ODebtR*/
run;  quit;
proc sort data=a2; by yyyy sic_tej; run;
proc reg data=a2;
	model ROA=DebtR;
	by yyyy;      /*�C�@�~���O�]�@���j�k*/
run;  quit;
proc reg data=a2 outest=para1;
	model ROA=DebtR;
	by yyyy sic_tej;   /*�C�@�~���C�Ӳ��~�A���O�]�@���j�k*/
run;  quit;

/*******************************;
Exercise 3-2: �NROE���Q�v(ProfitR)�]�j�k���R�A�B�C�~�]�@���j�k�C
�w�q:
ROE=Net Income/Total Equity�C
��Q�v(ProfitR) =(��~���J-��~����)/��~���J
���:mydata. F01s_a_financialann
*******************************/



