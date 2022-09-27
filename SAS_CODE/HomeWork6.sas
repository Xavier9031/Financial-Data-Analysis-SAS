**** 
/*Homework Ch05: 以Mydata. F01_a_financialann, F01_b_ret_monthly  為資料，(note:不是F01s_b_ret_monthly)
(1)計算每一"年"的每個"產業(sic_tej)"的"平均年報酬率" (即該產業個股年報酬率的平均值)。
呈現方式，直的為產業，橫的為年份 (利用proc transpose)。
(2)在每一"年"每個"產業(sic_tej)"中，依照"年報酬率"區分為約略均等的5群，最高那一群設定為"Winer"，最低那一群設定為"Loser"，
若某一年某產業的股票家數不足10家(n<10)者，刪除那一年的那個產業。
a. 將每一年的Winer，通通集合(不論那個產業)在一起為一個大的投資組合，請問每一年，Winer投資組合的報酬率為何？
b. 將每一年的Loser，通通集合(不論那個產業)在一起為一個大的投資組合，請問每一年，Loser投資組合的報酬率為何？
此題呈現方式，直的為群(Loser/Winer)，橫的為年份 (利用proc transpose)。;

*第一題;
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


*第二題;
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
