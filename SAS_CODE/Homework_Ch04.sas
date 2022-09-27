data hw04_0;
	set Mydata. F01s_b_ret_monthly;
	yyyy = year(datadate);
run;
proc sort data=hw04_0 out=hw04_1 nodup; by yyyy conm; run;
proc means data=hw04_1 sum std;
       var RET;
        by yyyy conm;
	    output out=hw04_2 sum=sumRET std=stdRET;  
quit;

proc rank data=hw04_2 out=hw04_3 groups=3; 
	var StdRET;
	by yyyy;
	Ranks Rank_StdRET;
run;

proc sort data=hw04_3 out=hw04_4 nodup; by Rank_StdRET yyyy ; run;

proc means data=hw04_4 mean;
       var sumRET;
        by Rank_StdRET yyyy;
	    output out=hw04_5 mean=meanRET;  
quit;

proc sort data=hw04_5 nodup; by yyyy ; run;

proc transpose data=hw04_5 out=hw04_6 prefix=g;
	var meanRET;
	by yyyy;
	id Rank_StdRET;
quit;

proc print data=hw04_6;run;
