/***********************************************
Sample program: Ch04  Procedure
************************************************/;

DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

data az;
	set Mydata. F01s_A_financialann;

	DebtR=LT/AT;
	ROA=NI/AT;
	yyyy=year(datadate);
	mm=month(datadate);

	keep gvkey   CONM yyyy mm  sic_tej  DebtR ROA AT;   /*Keep�O�O�d�ܼ�, Drop �N�ܼƥ��, �i�H��b�ܦh�a�� */
run;
/********************************************************************************************
						 keep, drop; �O�d�ή����ܼ�
********************************************************************************************/
data b1 (keep=conm yyyy at);  /*Keep�O�O�d�ܼ�, Drop �N�ܼƥ��, �i�H��b�ܦh�a�� */
	set az;
run;
data b2;
	set az(keep=conm yyyy at);
run;
data b3;
	set az;
	keep conm yyyy at;
run;
data b4;
	set b3;
	drop conm at;  /*Keep�O�O�d�ܼ�, Drop �N�ܼƥ��, �i�H��b�ܦh�a�� */
run;


/********************************************************************************************
						 Proc Sort; �Ƨ�
********************************************************************************************/
/*�`�N�U����ɪ��˥���*/
proc sort data=b1 ;          /*�w�]�O�Ѥp�ƨ�j*/
	by yyyy at; 
run;

proc sort data=b1 out=c1a ; by yyyy at; run;
proc sort data=b1 out=c1b ; by yyyy descending at; run;   /*Descending�O�Ѥj�ƨ�p*/

proc sort data=b4 out=c2a ; by yyyy; run;
proc sort data=b4 out=c2b nodup ; by yyyy; run;  /*Nodup���P�C�������ƪ�*/

proc sort data =az out=c3a nodup; by conm yyyy; run;
proc sort data =az out=c3b nodup; by _all_; run;   /*_all_�N��Ҧ��ܼ�*/
proc sort data =az out=c3c nodupkey; by conm yyyy; run;  /*Nodupkey:by �����X���ܼơA���藍����*/

proc sort data =az out=c4 nodup; by conm descending yyyy; run;

**** 
Exercise 4-1: �HMydata. F01s_b_ret_monthly ����ơA�B��proc sort,  �e�{�Ӹ���ɤ������ǪѲ�;
data ex4_1;
	set Mydata. F01s_b_ret_monthly;
	keep conm;
run;
proc sort data = ex4_1 out = ex4_1_out nodupkey; by conm;run;


/********************************************************************************************
						 Proc means; �ԭz�έp,������,�зǮt,�[�`
						 proc����quit�����F��L��run����
********************************************************************************************/
proc sort data=az nodup; by yyyy; run;/*�H�Uproc means����by, �ӥu�n��by�A���e�@�w�n�Ƨ�*/
proc means data=az n mean;
       var ROA;
       by yyyy;  /*by �i���s�i��έp*/
quit;
proc means data=az n mean std median ;
       var ROA;
       class yyyy;   /*Class�b�y�Y�ǡzprocedure�i���s�i��έp�C���Y��procedure���Aclass & by ���\�ण�ӬۦP*/
quit;
proc means data=az n mean std median min p1 p5 p10 p25 p50 p75 p90 p95 p99 max;
       var ROA DebtR;
        class yyyy;
	    output out=h11 n=n1 n2 mean=m1 m2 median=md1 md2 std=stda stdb;  /*��p��X�Ӫ������ơB�зǮt���x�s�����ɡA��K����i�~��ϥ�	*/
quit;
proc sort data=az nodup; by yyyy sic_tej; run;
proc means data=az n mean;
       var ROA;
       class yyyy sic_tej;
       output out=h12 mean=mROA;
quit;
proc means data=az n mean;
       var ROA;
       class yyyy sic_tej;
	   weight AT;  /*Weight�O�i��[�v����*/
quit;
proc means data=az n sum;  /*Sum�O�[�`*/
       var AT;
       by yyyy sic_tej;
       output out=h13A sum=;
quit;
proc means data=az n sum;
       var AT;
       by yyyy sic_tej;
       output out=h13B sum=AT_industry;
quit;

****
Exercise 4-2: �HMydata. F01s_c_ucgi_owner_summary ����ơA�B��proc means,  
�e�{�C�~���P�����α���A(ControlType2)���������(OwnerShipR_Control)�����ƻP�����, 
�ñN�����ƻP����Ʀs������ "exercise_out"��;
****
Exercise 4-3: �HMydata. F01s_b_ret_monthly ����ơA�B��proc means,  
�e�{�C��Ѳ��C�~����~�פ�buy and hold���S�v�Φ��X�����, 
�ñN�o�X�����G�s������ "exercise_out"��;



/********************************************************************************************
						Proc transpose; ��m���
********************************************************************************************/
proc sort data=h13B out=h21 nodup; by sic_tej; run;
proc transpose data=h21 out=h22 ;
       var AT_industry;
       by sic_tej;
run;
proc transpose data=h21 out=h23 prefix=yy ;  /*prefix�O��s���ܼƦW�ٶ}�Y*/
       var AT_industry;
       id yyyy;   /*Id:�i�N���ഫ���ܼƦW��*/
       by sic_tej;  /*by ���e�n�T�{�O�_�ƧǹL*/
run;
proc transpose data=h23 out=h24 prefix=AT_industry ;
       var yy2006-yy2014;
       by sic_tej;
run;
****
Exercise 4-4: �HMydata. F01s_b_ret_monthly ����ơA�B��proc transpose,  
�e�{�C�~���P�����q����S,���欰�~�P���q�W��, ��C�����;
data ex4_4;
	set Mydata. F01s_b_ret_monthly;
	YYYY = year(datadate);
	MMMM = month(datadate);
	keep conm RET YYYY MMMM;
run;
proc sort data=ex4_4 out=ex4_4_1 ; 
	by YYYY conm; 
quit;
proc transpose data=ex4_4_1 out=ex4_4_2 prefix=Mon_;
       var RET;
	   id MMMM;
       by YYYY conm;
quit;
data ex4_4_ans;
	set ex4_4_2;
	drop _NAME_ _LABEL_;
run;



/********************************************************************************************
						Proc univariate;  �ԭz�έp�P�s�@histogram��
********************************************************************************************/
proc sort data=az nodup; by yyyy; run;
proc univariate data=az ;  /*Proc univariate�Pproc means�����A���\���h*/
       var ROA;
quit;
proc univariate data=az plot;
       var ROA;
	   histogram ;  /*Histogram�i���ͪ����*/
quit;
proc univariate data=az plot;
       var ROA;
	   class yyyy;
quit;
****
Exercise 4-5: �HMydata. F01s_b_ret_monthly ����ơA�B��proc univariate,  �e�{����S���W�v������(histogram);
data ex4_5;
	set Mydata. F01s_b_ret_monthly;
	YYYY = year(datadate);
	MMMM = month(datadate);
run;
proc univariate data=ex4_5 plot;
       var RET;
	   histogram ;
quit;


/********************************************************************************************
						 Proc rank; �ƦW, ���s
********************************************************************************************/
proc sort data=az nodup; by ROA; run;
proc rank data=az out=j1 ;  /*�ƦW�O�Ѥp��j�A�A0���_�l*/
	var ROA;
	Ranks Rank_ROA;  /*Ranks�O�N�ƦW�s��o�ܼƤ�*/
run;
proc rank data=az out=j2 groups=3; /*Groups�i�M�w���h�ָs�A�ƦW�O�Ѥp��j�A0���_�l*/
	var ROA;
	Ranks Rank_ROA;
run;
proc sort data=az nodup; by yyyy sic_tej ROA; run;
proc rank data=az out=j3 groups=3;
	var ROA;
	by yyyy sic_tej;
	Ranks Rank_ROA;
run;
proc sort data=az nodup; by ROA; run;
proc rank data=az out=j4 percent;  /*Percent �O�ƧǪ��ʤ���A�N�����Z�O���Z���h�֦ʤ���A���b���V����0�N��V�p�A�V����1�V�j�A*/
	var ROA;
	Ranks Rank_ROA;
run;
****
Exercise 4-6: �HMydata. F01s_b_ret_monthly ����ơA�B��proc rank�C
�Ѳ���굦���Q�n��X�C�Ӥ�Ѳ����S��Ĺ�a�M��a�C 
�N�C�Ӥ몺�Ѳ����S�A�ɶq�����Ϥ���5�s�A�̰�����Ĺ�a�M�̧C������a�C;
data ex4_6;
	set Mydata. F01s_b_ret_monthly;
	yyyy = year(datadate);
	mmmm = month(datadate);
run;
proc sort data=ex4_6 out=ex4_6_1 nodup; by yyyy mmmm; run;
proc rank data=ex4_6_1 out=ex4_6_2 groups=5; 
	var RET;
	by yyyy mmmm;
	Ranks Rank_RET;
run;
proc sort data=ex4_6_2 out=ex4_6_3 nodup; by yyyy mmmm Rank_RET; run;

data winner;
	set ex4_6_2;
	IF Rank_RET>0 THEN delete;
run;
data loser;
	set ex4_6_2;
	IF Rank_RET<4 THEN delete;
run;

*HW7;

/********************************************************************************************
						 Proc standard; �N�ܼƼзǤ� (����)
********************************************************************************************/
proc standard data=az out=k1;  /*�i�]�w�зǤƪ��ؼХ�����(mean)�M�зǮt(std)*/
	var ROA;
run;
proc standard data=az out=k2 mean=50 std=10;
	var ROA;
run;
proc sort data=az nodup; by yyyy sic_tej ROA; run;
proc standard data=az out=k3 mean=50 std=10;
	var ROA;
	by yyyy sic_tej;
run;
****
Exercise 4-7: �HMydata. F01s_c_ucgi_owner_summary ����ơA�B��proc standard�A
�N�C�@�~�����ʮu���зǤƬ�������=0�A�зǮt=1�A���зǤƼƭȡC;


/********************************************************************************************
						 Proc tabulate; �s�@�ԭz�έp����� (����)  �i�s�@�C�p��
********************************************************************************************/
proc tabulate data=az ;
	class sic_tej;  /*class�O�����Τ��s���ܼ�,�p���O�ܼ�*/
	var ROA;   /*var�O�n���窺�ƭ��ܼ�*/
	table sic_tej*ROA*mean;  /*table�O�n�p��e�{���*/
run;
proc tabulate data=az ;
	class sic_tej;
	var ROA;
	table sic_tej, ROA*mean;  /*�u�n�h�@�ӳr�I�A�N�|�����C���Τ�������*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA ;
	table sic_tej, yyyy*ROA*mean; 
run;
proc sort data=az; by sic_tej; run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA ;
	table yyyy, ROA*mean;
	by sic_tej;
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA ;
	table sic_tej, yyyy, ROA*mean; /*�u�n�h�@�ӳr�I�A�N�|�����C���Τ�������*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA DebtR ;
	table sic_tej, yyyy*(ROA DebtR)*mean;  /*�i�P�ɲέp�h���ܼ�*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var AT;
	table sic_tej, yyyy*AT*sum;
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var AT;
	table sic_tej, yyyy*AT*(n mean sum std min max pctn pctsum);  /*�i�P�ɲέp�h�Ӳέp�q*/
run;
proc tabulate data=az ;
	class sic_tej yyyy;
	var ROA AT;
	table sic_tej, yyyy, (ROA AT)*(n mean sum std min max pctn pctsum);
run;
****
Exercise 4-8: �HMydata. F01s_c_ucgi_owner_summary ����ơA�B��proc tabulate,
�p��C�~���P���α���A���������(OwnerShipR_Control)�����ȡA 
�åH���Ƭ����α���A( ControlType2),��C���~���覡�e�{;



/********************************************************************************************
						 Proc surveyselect; �H����� (����)
********************************************************************************************/
* Simple Random Sample;
proc surveyselect data = az 	method = SRS 	rep = 1 	sampsize = 10 seed = 12345 out = m1;  /*SRS�O²���H����� Seed�O�H�����_�l�� Rep�O�_���Ʃ��(�w��L���O�_�������)*/
	id _all_;
run;
proc surveyselect data = az 	method = SRS 	rep = 1 	sampsize = 10 seed = 12345 out = m2;
	id _all_;
	strata yyyy sic_tej;
run;
*Systematic Random Sample;
proc surveyselect data = az 	method = SYS 	rep = 1 	sampsize = 10 seed = 12345 out = m3; /*SYS�O�t�Ω��*/
	id _all_;
	strata yyyy sic_tej;
run;
proc means data=m1 ;
	var ROA;
run;

/********************************************************************************************
						 Proc freq; �έp�W�v����
********************************************************************************************/
proc freq data=	az;
	table Conm ;   /*Table�M�w�n�p��e�{�W�v��*���O�y�C�p��z���W�v*/
run;
proc freq data=	az;
	table Conm yyyy ;
run;
proc freq data=	az;
	table sic_tej yyyy ;
run;
proc freq data=	az ;
	table sic_tej*yyyy  ;   /*Table�M�w�n�p��e�{�W�v��*���O�y�C�p��z���W�v*/
run;

proc freq data=	az ;
	table sic_tej*yyyy /norow nocol ; /*cumcol totpct nofreq nopercent norow nocol nocum */ /*Norow, nocol�O���n�e�{�Y�ǦC����A��������M�n*/
run;
proc freq data=	az;
	table sic_tej*Conm yyyy*Conm ;
run;
proc freq data=	az;
	table (sic_tej  yyyy)*Conm ;
run;
proc freq data=	az;
	table ROA / missing ; /*Missing�O�e�{missing variable������*/
run;

****
Exercise 4-9: �HMydata. F01s_c_ucgi_owner_summary ����ơA�B��proc freq,�e�{�C�~���ʮu�����W�v����.   ;



/********************************************************************************************
Example: �HMydata. F01s_A_financialann����ơA�B��proc rank, proc means, proc transpose,  
�N�C�~�����q,�̷�ROA��������Ҫ�5�s,�íp��C�@�s���t�Ť��; 
�åH���Ƭ��~,��C��1~5���s�էe�{;
***�m�ߵ��X���P���O�A�ӧ����@�����������
********************************************************************************************/
data Sample;
	set Mydata. F01s_A_financialann;
	DebtR=LT/AT;
	ROA=NI/AT;
	yyyy=year(datadate);

	keep gvkey   CONM yyyy sic_tej  DebtR ROA ;
run;
proc sort nodup; by yyyy ROA; run;
proc rank data=Sample out=Sample2 groups=5;
	var ROA;
	Ranks ROA_rank;
	by yyyy;
run;
data Sample3;
	set Sample2;
	ROA_rank=ROA_rank+1;
run;
proc sort nodup; by yyyy ROA_rank; run;
proc means data=Sample3;
	var DebtR;
	by yyyy ROA_rank;
	output out=Exercise_out mean=mDebtR;
quit;
proc transpose data=Exercise_out out=Exercise_out2 prefix=g;
	var mDebtR;
	by yyyy ;
	id ROA_rank;
quit;
proc print data=Exercise_out2; run;




