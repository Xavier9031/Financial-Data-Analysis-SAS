/*	�ĤC��
1082414�i��F
1082404�L�R�z
1082417�L�ɸ�
1082501��f��	*/

****
Exercise 4-3: �HMydata. F01s_b_ret_monthly ����ơA�B��proc means,  
�e�{�C��Ѳ��C�~����~�פ�buy and hold���S�v�Φ��X�����, 
�ñN�o�X�����G�s������ "exercise_out"��;
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
