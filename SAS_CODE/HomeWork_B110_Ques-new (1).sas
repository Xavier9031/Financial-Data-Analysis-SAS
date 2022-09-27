/***********************************************
Sample program: Ch03  Basic Introduction
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

/*******************************;
Homework Ch03-1: ��s�겣�P��v�O�_�v�TROE�A�B�Ϥ����P���~
-->�NROE��겣�P��v�]�j�k���R�A�B�C���~�]�@���j�k�C
�w�q:
�겣�P��v(Turnover) =�`��~�B (Total Revenue) /�`�겣�� (Total Asset)
ROE=Net Income/Total Equity
���:mydata. F01s_a_financialann

Homework Ch03-2: �p��C�@�~�k�H���Ѳv(InstOwnership)��������   (����2005-2014�~)
���:mydata. F01_c_ucgi_owner_summary   (note:���OF01s_c_ucgi_owner_summary)

*******************************/


/*******************************;
Homework Ch04: �HMydata. F01s_b_ret_monthly ����ơA�B��proc rank, proc means, proc transpose, 
�N�C�~���Ѳ��A�H"�`���I(StdRET)"�Ϥ���3�s�A�íp��C�@�s������"�~���S�v"�C
�åH���Ƭ��~,��C��1~10���s�էe�{�C
�w�q�G�`���I(StdRET)�H�ӪѲ���~�פ���S���зǮt
*******************************/


**** 
/*Homework Ch05: �HMydata. F01_a_financialann, F01_b_ret_monthly  ����ơA(note:���OF01s_b_ret_monthly)
(1)�p��C�@"�~"���C��"���~(sic_tej)"��"�����~���S�v" (�Y�Ӳ��~�ӪѦ~���S�v��������)�C
�e�{�覡�A���������~�A����~�� (�Q��proc transpose)�C
(2)�b�C�@"�~"�C��"���~(sic_tej)"���A�̷�"�~���S�v"�Ϥ�������������5�s�A�̰����@�s�]�w��"Winer"�A�̧C���@�s�]�w��"Loser"�A
�Y�Y�@�~�Y���~���Ѳ��a�Ƥ���10�a(n<10)�̡A�R�����@�~�����Ӳ��~�C
a. �N�C�@�~��Winer�A�q�q���X(���ר��Ӳ��~)�b�@�_���@�Ӥj�����զX�A�аݨC�@�~�AWiner���զX�����S�v����H
b. �N�C�@�~��Loser�A�q�q���X(���ר��Ӳ��~)�b�@�_���@�Ӥj�����զX�A�аݨC�@�~�ALoser���զX�����S�v����H
���D�e�{�覡�A�������s(Loser/Winer)�A����~�� (�Q��proc transpose)�C

*���ܡG
1.���D�|���Ψ�proc means (�A�ɨϥ�noprint, ���M�|�]�ܤ[), proc rank, merge, where, proc transpose, if...then..., delete�����O, 
�ۦ�h�զX�o���C
2.���~��Mydata. F01_a_financialann��A�Q��merge�覡�X�ֲ��~�Mstock returns�C
3.�Y�Y�@�~�Y���~���Ѳ��a�Ƥ���10�a(n<10)�̡A�R�����@�~�����Ӳ��~�C-->���O�Q��proc means�� output out=, merge�i���U�A�F��ت�
(note:Homework Ch05���C�@�D�A�C�@�ӪѲ��A��~�׳��S�v��Ƥ���12�Ӥ몺�A�n�R���C���M���Ӥ���������C)
*/;

/*******************************;
Homework Ch06: 
Homework:�e�X�H�Useries
�HF01s_b_ret_monthly���ҡA�e�X"�s�F"�P"�͹F"����(datadate)����ѻ��A����u�e�b�P�@�i��;
*******************************/


/*******************************;
Homework Ch08: �HMydata. F01s_a_financialann  Mydata. F01s_c_ucgi_owner_summary����ơA
�̷Ӫk�H���Ѥ�v�A�N�C�@�~�C���~�Ϥ������C��s�C
������P�C��s������ROA�O�_�۵� (�t�����ƩM������˩w)�C(note:���D�����Τ���ƬO�Ҧ��~���X�b�@�_�ݡA�u�����s�ɭn�̷ӨC�@�~�C���~�Ϥ�)
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

proc ttest data = HW_8_1;   /*H0�G�ⲣ�~������ROA�۵�*/
  class Rank_IO;
  var ROA;
run;

proc npar1way data = HW_8_1 wilcoxon;  /*H0�G�ⲣ�~��ROA����Ƭ۵�*/
  class Rank_IO;
  var ROA;
run;

/*******************************;
Homework Ch09: Case-Simple 
				��ơGF01s_a_financialann, F01s_c_ucgi_owner_summary
				Model: InstOwnership=b0+b1*Eletric+b2*logSize+b3*DE_ratio+e;
							where 
							Own_firm=�k�H���Ѥ��
							Electric=1:�q�l�~(Tej���~�O��23), 0 �䥦���~
							logSize=�`�겣�A��natural logarithm
							DE_ratio=Debt to equity ratio=Debt/Equity
				�i��j�k
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
Homework Ch10: �HMydata. F01s_A_financialann, Mydata. F01s_b_ret_monthly ����ơA�i��U�C�j�k�C
ChgROA=b0+b1*LagRETY+b1*LagDebtR+b2*LagLnSize+e
�ܼƩw�q�G
ChgROA=�����P�e�@��ROA���t
LagRETY=�e�@�����~�Ѳ����S�v(buy and hold return)
LagDebtR=�e�@�����t�Ť�v
LagLnSize=�e�@����log(�`�겣)
*******************************/;
