/*	第七組
1082414張恆達
1082404林靜慧
1082417林宥萱
1082501賴柏薰	*/

****
Exercise 4-3: 以Mydata. F01s_b_ret_monthly 為資料，運用proc means,  
呈現每支股票每年的當年度之buy and hold報酬率及有幾筆資料, 
並將得出的結果存到資料檔 "exercise_out"中;
data EX4_3;
	set Mydata. F01s_b_ret_monthly;
	yyyy=year(datadate);
run;

proc sort data = EX4_3;
	by yyyy conm;
run;

proc means data=EX4_3 n sum;
	var RET;
	by yyyy conm;
	output out=exercise_out_1 n=tr sum = po;
quit;
