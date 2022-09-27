**** 
/*Homework Ch05: �HMydata. F01_a_financialann, F01_b_ret_monthly  ����ơA(note:���OF01s_b_ret_monthly)
(1)�p��C�@"�~"���C��"���~(sic_tej)"��"�����~���S�v" (�Y�Ӳ��~�ӪѦ~���S�v��������)�C
�e�{�覡�A���������~�A����~�� (�Q��proc transpose)�C
(2)�b�C�@"�~"�C��"���~(sic_tej)"���A�̷�"�~���S�v"�Ϥ�������������5�s�A�̰����@�s�]�w��"Winer"�A�̧C���@�s�]�w��"Loser"�A
�Y�Y�@�~�Y���~���Ѳ��a�Ƥ���10�a(n<10)�̡A�R�����@�~�����Ӳ��~�C
a. �N�C�@�~��Winer�A�q�q���X(���ר��Ӳ��~)�b�@�_���@�Ӥj�����զX�A�аݨC�@�~�AWiner���զX�����S�v����H
b. �N�C�@�~��Loser�A�q�q���X(���ר��Ӳ��~)�b�@�_���@�Ӥj�����զX�A�аݨC�@�~�ALoser���զX�����S�v����H
���D�e�{�覡�A�������s(Loser/Winer)�A����~�� (�Q��proc transpose)�C;

*�Ĥ@�D;
data sic_conm;
	set Mydata.F01_a_financialann;
	keep gvkey sic_tej;
run;

proc sort data = sic_conm nodup; by gvkey; run;

data RETs_mon;
	set mydata. F01_b_ret_monthly;
	yyyy = year(datadate);
run;

proc sort data = RETs_mon ; by yyyy gvkey ; run;

proc means data=RETs_mon sum noprint;
       var RET;
       by yyyy gvkey; 
	   output out=RETs_mon2 sum = avgRET;
quit;

data RETs_mon3;
	set RETs_mon2;
	where _FREQ_ = 12;
run;

proc sort data = RETs_mon3 nodup; by gvkey; run;

data RETs_mon4;
	merge RETs_mon3(in=c) sic_conm(in=f);
	by gvkey;
	if c=1 and f=1; 
run;

proc sort data = RETs_mon4 nodup; by yyyy sic_tej ; run;
	
proc means data=RETs_mon4 mean noprint;
       var avgRET;
       by yyyy sic_tej; 
	   output out=RETs_year_sic mean=yRET;
quit;

proc sort data = RETs_year_sic nodup; by sic_tej yyyy  ; run;

data pre_ans;
	set RETs_year_sic;
	keep yyyy sic_tej yRET;
run;

proc sort data = pre_ans nodup; by sic_tej yyyy  ; run;

proc transpose data=pre_ans out=ans1 prefix=yy;
       var yRET;
       id yyyy;
       by sic_tej;
run;

proc print data=ans1;run;


*�ĤG�D;
data RETs_year_sic_n10up;
	set RETs_year_sic;
	where _FREQ_ >= 10;
run;

proc sort data=RETs_year_sic_n10up nodup; by yyyy; run;

proc rank data=RETs_year_sic_n10up out=RETs_year_sic_rank groups=5; 
	var yRET;
	by yyyy;
	Ranks Rank_RET;
run;

data RETs_year_sic_rank2;
	set RETs_year_sic_rank;
	IF Rank_RET ne 0 &&  Rank_RET ne 4 THEN delete;
	IF Rank_RET = 0 THEN type = "losser";
	IF Rank_RET = 4 THEN type = "winner";
	keep yyyy sic_tej yRET type;
run;

proc sort data=RETs_year_sic_rank2 nodup; by yyyy type; run;

proc means data=RETs_year_sic_rank2 mean noprint;
       var yRET;
       by yyyy type; 
	   output out=RETs_WL mean=R;
quit;

data pre_ans2;
	set RETs_WL;
	keep yyyy type R;
run;

proc sort data = pre_ans2 nodup; by type yyyy  ; run;

proc transpose data=pre_ans2 out=ans2 prefix=yy;
       var R;
       id yyyy;
       by type;
run;

proc print data=ans2;run;
