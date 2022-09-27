**** 
Exercise 4-1: 以Mydata. F01s_b_ret_monthly 為資料，運用proc sort,  呈現該資料檔內有哪些股票;
data EX4_1;
	set Mydata. F01s_b_ret_monthly;
	keep conm;
run;
proc sort data = EX4_1 out=test6nodup;
	by conm;
run;

****
Exercise 4-2: 以Mydata. F01s_c_ucgi_owner_summary 為資料，運用proc means,  
呈現每年不同的集團控制型態(ControlType2)的控制持股(OwnerShipR_Control)平均數與中位數, 
並將平均數與中位數存到資料檔 "exercise_out"中;
data EX4_2;
	set Mydata. F01s_c_ucgi_owner_summary;
	yyyy=year(datadate);
run;
proc sort data = EX4_2;
	by yyyy ControlType2;
run;

proc means data = EX4_2  mean median;
	var OwnerShipR_Control;
	by yyyy ControlType2 ;
	output out=exercise_out mean=tr median=po;
quit;
