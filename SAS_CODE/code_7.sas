**** 
Exercise 4-1: �HMydata. F01s_b_ret_monthly ����ơA�B��proc sort,  �e�{�Ӹ���ɤ������ǪѲ�;
data EX4_1;
	set Mydata. F01s_b_ret_monthly;
	keep conm;
run;
proc sort data = EX4_1 out=test6nodup;
	by conm;
run;

****
Exercise 4-2: �HMydata. F01s_c_ucgi_owner_summary ����ơA�B��proc means,  
�e�{�C�~���P�����α���A(ControlType2)���������(OwnerShipR_Control)�����ƻP�����, 
�ñN�����ƻP����Ʀs������ "exercise_out"��;
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
