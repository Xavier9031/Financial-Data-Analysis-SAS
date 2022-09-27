/***********************************************
Sample program: Ch06  Plot
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;


data az;
	set Mydata. F01s_A_financialann;

	DebtR=LT/AT;
	ROA=NI/AT;
	ROE=NI/CEQ;

	yyyy=year(datadate);
	AT2=AT/1000000;
	Sale2=Sale/1000000;
	DebtR2=DebtR*100;
	keep gvkey datadate  CONM sic_tej  SICb  yyyy DebtR ROA ROE   AT AT2 Sale Sale2 DebtR2;

run;
proc sort nodup; by yyyy; run;
                 
proc means data=az mean;
	var ROA ROE DebtR ;
	by yyyy;
	output out=out_data mean=mROA mROE mDebtR;
run;


/********************************************************************************************
						Bar Chart: ������-�W�v��
********************************************************************************************/

/* Bar Chart*/
proc gchart data= az;
	vbar ROA  ;
run; quit;
proc gchart data= az;
	hbar ROA ;
run; quit;
proc gchart data= az;
	vbar ROA /Type=pct ;  /*�i�H�e�{�ʤ���*/
run; quit;
*TYPE = �ﶵ�G�i�H���w SAS �άY�@�شy�z�έp��ø�ϡC�`�οﶵ��:FREQ ����ø��,PCT �ʤ���ø��,CFREQ �ֿn����ø��, CPCT �ֿn�ʤ���ø��;

proc gchart data= az;
	vbar SICb ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar SICb ;
run; quit;

**** 
*Exercise 6-1 : �HMydata. F01s_b_ret_monthly ����ơA���X����S���W�v�����ʤ���Bar Chart (���t�[�v���ƪ�����S);


/********************************************************************************************
						Bar Chart: ������- ��b�����O,�a�b���ƭ�
********************************************************************************************/
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=DebtR ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=DebtR2 ;   /*�����ܼƪ����A���QSAS�{�i�A�ҥH�n�ഫ���*/
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=AT2 ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	vbar Conm  /Freq=Sale2 ;
run; quit;
/* Bar3d Chart*/
proc gchart data= az;
	where yyyy=2014;
	vbar3d Conm  /Freq=DebtR2 ;
run; quit;

**** 
*Exercise 6-2 : �HMydata. F01s_b_ret_monthly ����ơA���X2014�~12�멳�U�Ѫѻ���Bar Chart (���t�[�v���ƪ�����S);



/********************************************************************************************
						Pie Chart: ����-�W�v
********************************************************************************************/

/*pie Chart*/
proc gchart data= az;
	where yyyy=2014;
	pie SICb ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	pie Conm ;
run; quit;
proc gchart data= az;
	where yyyy=2014;  
	pie Sale2 ;  /*�����ܼƪ����A���QSAS�{�i�A�ҥH�n�ഫ���*/
run; quit;
/********************************************************************************************
						Pie Chart: ����-���O�P�ƭȦʤ���
********************************************************************************************/
proc gchart data= az;
	where yyyy=2014;
	pie Conm/ Freq=Sale2  ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	pie Conm/ Freq=Sale2 Type=percent  ;
run; quit;
proc gchart data= az;
	where yyyy=2014;
	pie Conm/ Freq=Sale Type=percent  ;
run; quit;

/*pie3d Chart*/
proc gchart data= az;
	where yyyy=2014;
	pie3d Conm/ Freq=Sale2 Type=percent  ;
run; quit;

**** 
*Exercise 6-3: �HMydata F01s_c_ucgi_owner_summary ����ơA�e�X2014�~���α���ʤ���Pie Chart ;
*Exercise 6-3-new: �HMydata F01s_c_ucgi_owner_summary ����ơA�e�X2014�~���P���α�������(�ܼƦW�١GControlType2)�U�e�h�֦ʤ���Pie Chart ;


/********************************************************************************************
						Proc Gplot : XY��, ��@���u

							�i�Hø�sXY �����ϩΧ�u��
							�i�H��B�F�Ѩ��ܼƶ������p��

********************************************************************************************/
proc gplot data= az;
	plot ROA*DebtR;
run; quit;

symbol1 color=blue  value=dot;    /*���ܽu���Φ�*/
proc gplot data= az;
	plot ROA*DebtR;
run; quit;

proc gplot data= az;
	plot ROA*yyyy;
run; quit;
proc gplot data= out_data;
	plot mROA*yyyy;
run; quit;
goptions reset=all;                                                   


**** 
*Exercise 6-4 : �HMydata. F01s_b_ret_monthly ����ơA���X2011~2015�~"�[�v����"���뤧�ѻ�;
                                       


/********************************************************************************************
						Proc Gplot: XY��, ����u
********************************************************************************************/

proc gplot data= out_data;
	plot mROA*yyyy mDebtR*yyyy /overlay ;  /*overlay�O����u�b�P�@�i�ϧe�{*/
run; quit;

symbol1 interpol=join color=vibg value=dot;                       /*�]�w�u���榡*/                                                                      
symbol2 interpol=join color=mob font=marker value=C height=0.7;     
legend1 position=(top center inside)     label=none  mode=share; /*legend�O�]�w���Ѫ��榡*/
axis1  label=none  ;                                                /*Axis�O�]�wX�b�PY�b���榡*/                                                         
axis2 label=none;               
proc gplot data= out_data;
	plot mROA*yyyy mDebtR*yyyy /overlay legend=legend1 haxis=axis1 vaxis=axis2;
run; quit;

/********************************************************************************************
*Example:�e�Ϥ���x�n�q�M�E�����~ROA,�e�b�P�@�i�Ϥ�
********************************************************************************************/
data sample1;
	set Mydata. F01s_A_financialann;
	year=year(datadate);
	ROA=NI/AT;
run;
proc sort nodup; by year; run;
**Method01;
data f2330;
	set sample1;
	where gvkey='2330';
	rename ROA=ROA2330;
	keep year ROA;
run;
data f2317;
	set sample1;
	where gvkey='2317';
	rename ROA=ROA2317;
	keep year ROA;
run;
data merge1;  /*��l��Ƥ��O�@�}�l�N�ŦX�n�D�A�]���ݹw���i���z*/
	merge f2330 f2317;
	by year;
run;
symbol1 interpol=join color=vibg value=dot;                                                                                             
symbol2 interpol=join color=mob font=marker value=C height=0.7;     
legend1 position=(top center inside)     label=none  mode=share; 
axis1  label=none  ;                                                                                                         
axis2 label=none;               
proc gplot data= merge1;
	plot ROA2330*year ROA2317*year /overlay legend=legend1 haxis=axis1 vaxis=axis2 ;
run; quit;


**Method02;  /*��transpose�]�\�{���|��²�u*/
data sample2;
	set sample1;
	where gvkey='2330' or gvkey='2317';
run;
proc sort data=sample2 nodup; by year gvkey; run;
proc transpose data=sample2 out=sample3 prefix=ROA;
	var ROA;
	by year;
	id gvkey;
quit;
proc gplot data= sample3;
	plot ROA2330*year ROA2317*year /overlay legend=legend1 haxis=axis1 vaxis=axis2 ;
run; quit;
                                                     
**** 
*Exercise 6-5 : �HMydata. F01s_b_ret_monthly ����ơA�e�Ϥ��2011~2015�~�x�n�q�M�E������ѻ�����,�e�b�P�@�i�Ϥ�;
                        
                                                                                                                       



/********************************************************************************************
*Example: �J�� Gplot
********************************************************************************************/

/* Create sample data */                                                                                                                
data sample;                                                                                                                            
   do Xvar=1 to 10;                                                                                                                     
      Yvar1=round(ranuni(0)*(30));                                                                                                      
      Yvar2=round(ranuni(0)*(70-40))+40;                                                                                                
      Yvar3=round(ranuni(0)*(100-70))+70;                                                                                               
      output;                                                                                                                           
   end;                                                                                                                                 
run;                                                                                                                                    
                                                                                                                                        
/* Define the title */                                                                                                      
title1 "Use Solid-Filled Symbols with PROC GPLOT";                                                                                      
                                                                                                                                        
/* Define symbol characteristics */                                                                                                     
symbol1 interpol=join value=squarefilled   color=vibg height=2;                                                                         
symbol2 interpol=join value=trianglefilled color=depk height=2;                                                                         
symbol3 interpol=join value=diamondfilled  color=mob  height=2;                                                                         
/* Define legend characteristics */                                                                                                     
legend1 label=none frame;                                                                                                               
/* Define axis characteristics */                                                                                                       
axis1 label=("X Variable") minor=none offset=(1,1);                                                                                     
axis2 label=(angle=90 "Y Variable")                                                                                                     
      order=(0 to 100 by 10) minor=(n=1);                                                                                               
                                                                                                                                        
proc gplot data=sample;                                                                                                                 
   plot (yvar1 yvar2 yvar3)*xvar / overlay legend=legend1 haxis=axis1 vaxis=axis2;                                                                             
run;                                                                                                                                    
quit;     

*��h���e�i�ѷ�https://support.sas.com/sassamples/graphgallery/PROC_GPLOT.html;

