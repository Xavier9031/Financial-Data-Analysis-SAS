/***********************************************
Sample program: Ch08  SQL
************************************************/;
DM "LOG;CLEAR;OUTPUT;CLEAR;";

libname Mydata  'D:\Mydata17';
ods html;

data az;
	set Mydata. F01s_A_financialann;

	ProfitR=(SALE-COGS)/Sale;
	DebtR=LT/AT;
	 ROA=NI/AT;
	logSize=log(AT);
	DROA=(ROA>0);

	yyyy=year(datadate);
*	keep gvkey yyyy datadate  CONM sic_tej   DebtR ROA logSize AT Sale ProfitR DROA;
	if yyyy<=2010 then delete;
	keep gvkey yyyy datadate  CONM sic_tej   DebtR ROA;

run;
proc sort nodup; by yyyy sic_tej; run;

***distinct;
proc sql;
	create table b0 as
	select *
	from az;
quit;
proc sql;
	create table b1 as
	select yyyy, sic_tej
	from az;
quit;
proc sql;
	create table b2 as
	select distinct yyyy, sic_tej
	from az;
quit;

proc sql;
	create table bz as
	select distinct yyyy, sic_tej
	from az
	where yyyy>=2013
	order by yyyy, sic_tej;
quit;

***count;
*每一年有多少產業;
proc sql;
	create table c1 as
	select yyyy, count(sic_tej) as NInd
	from b1;
quit;
proc sql;
	create table c2 as
	select distinct yyyy, count(sic_tej) as NInd2
	from b2;
quit;
proc sql;
	create table c3 as
	select distinct yyyy, count(sic_tej) as NInd3
	from b2
	group by yyyy;
quit;
proc sql;
	create table cz as
	select distinct yyyy, count(sic_tej) as NInd4
	from (select distinct yyyy, sic_tej from az)
	group by yyyy;
quit;

***mean, std, max, min;
*industry adjusted ROA;
proc sql;
	create table d1 as
	select distinct Conm, yyyy, ROA, sic_tej
	from az
	order by yyyy, ROA desc, Conm;
quit;
proc sql;
	create table d2 as
	select distinct yyyy, sic_tej, mean(ROA) as mROA, std(ROA) as std1, min(ROA) as minx, max(ROA) as max1
	from d1
	group by yyyy, sic_tej; 
quit;



******left join, right join , full joint另一種merge方式，比merge好用太多;
data Ownership;
	set Mydata. F01s_c_ucgi_owner_summary;
	Family=(ControlType='F');
	year=year(datadate);   *Note: not yyyy;
	keep conm year Family Pledge_director;
run;
proc sql;
	create table e1 as
	select *
	from az as A left join Ownership as B
	on A. conm=B. conm and
		A. yyyy=B. year;
quit;
proc sql;
	create table e2 as
	select A. *, B. Family, B. Pledge_director
	from az as A left join Ownership as B
	on A. conm=B. conm and
		A. yyyy=B. year;
quit;
proc sql;
	create table e3 as
	select distinct A. *, B. Family, B. Pledge_director
	from az as A left join Ownership as B
	on A. conm=B. conm and
		A. yyyy=B. year
	having yyyy>=2013
	order by conm, yyyy;
quit;
proc sql;
	create table e4 as
	select distinct A. *,  B. Pledge_director as Lag_Pledge
	from az as A left join Ownership as B
	on A. conm=B. conm and
		A. yyyy=B. year+1
	order by conm, yyyy;
quit;

/*summary
proc sql;
	create table xxx1 as
	select (distinct)  A.gg, A.bb, B. xx, B. yy
	from xxA as A left(right) join xxB as B
	on A. xx=B. xx and (or)
		A. xx=B. xx
	where xxA....
	having xx is not missing
	order by xx,xx,xx;
quit;

note:
left join, right join, full join;
and or,
=, > ,>=,<,<=, ne, between; 
*/


/********************************
Example: 以Mydata. F01s_A_financialann  為資料，計算每家公司每一年的industry adjusted ROA(ROA_Adj)。industry adjusted ROA(ROA_Adj)=ROA/ mean ROA of the corresponding industry;
********************************/
data Sample;
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	keep gvkey yyyy datadate  CONM sic_tej    ROA ;
run;
proc sort  nodup; by yyyy sic_tej; run;
**method01;
proc means data=Sample n mean;
       var ROA;
       by yyyy sic_tej;
       output out=industry_ROA n=nFirm mean=mROA;
quit;
data test1;
       merge sample industry_ROA (drop=_type_ _freq_);
       by yyyy sic_tej;
       ROA_Adj=ROA-mROA;
run;
**method02;
proc sql;
	create table IndROA as
	select distinct yyyy, sic_tej, mean(ROA) as mROA
	from Sample
	group by yyyy, sic_tej;
quit;
proc sql;
	create table test2A as
	select A. *, B. mROA
	from sample as A left join IndROA as B
	on A. yyyy=B. yyyy and
		A. sic_tej=B. sic_tej;
quit;
data test2B;
       set test2A;
       ROA_Adj=ROA-mROA;
run;
**method03;
proc sql;
	create table IndROA as
	select distinct yyyy, sic_tej, mean(ROA) as mROA
	from Sample
	group by yyyy, sic_tej;
quit;
proc sql;
	create table test3 as
	select A. *, (A. ROA-B. mROA) as ROA_Adj
	from sample as A left join IndROA as B
	on A. yyyy=B. yyyy and
		A. sic_tej=B. sic_tej;
quit;
**method04;
proc sql;
	create table test4A as
	select distinct *, mean(ROA) as mROA
	from Sample
	group by yyyy, sic_tej;
quit;
data test4B;
       set test4A;
       ROA_Adj=ROA-mROA;
run;
**method05;
proc sql;
	create table test5 as
	select distinct *, (ROA-mean(ROA)) as ROA_Adj
	from Sample
	group by yyyy, sic_tej;
quit;




/*******************************;
Example: 以Mydata. F01s_b_ret_monthly 為資料，找出每一"年"Market adjusted return。Market adjusted return=RET-Rm, Rm是market portfolio returns. 並呈現直行為年，橫列為公司
Note:雖然資料頻率為monthly, 但要加總為yearly returns
Note: 比較Ch05 同樣問題之程式寫法
*******************************/
*Method01 (Sql);
data Sample;
	set Mydata. F01s_b_ret_monthly;
	where gvkey ne 'Y9999' ;
	yyyy=year(datadate);
	mm=month(datadate);
run;
proc sort nodup; by yyyy mm; run;
data Rm;
	set Mydata. F01s_b_ret_monthly;
	where gvkey = 'Y9999' ;
	yyyy=year(datadate);
	mm=month(datadate);
run;
proc sort nodup; by yyyy mm; run;
proc sql;
	create table Sample2 as
	select A. *, (A. RET-B. RET) as RETadj
	from Sample as A left join Rm as B
	on A. yyyy=B. yyyy and
		A. mm=B. mm;
quit;
proc sql;
	create table Sample3 as
	select distinct Conm, yyyy, sum(RETadj) as RETadjY
	from sample2
	group by Conm, yyyy
	order by Conm, yyyy;
quit;
proc transpose data=sample3 out=sample4;
	var RETadjY;
	by Conm;
	id yyyy;
run;
proc print data=sample4; run;
*Method02 (Sql);
data Sample;
	set Mydata. F01s_b_ret_monthly;
	yyyy=year(datadate);
	mm=month(datadate);
run;
proc sql;
	create table Sample2b as
	select A. *, (A. RET-B. RET) as RETadj
	from Sample as A left join Sample as B
	on A. yyyy=B. yyyy and
		A. mm=B. mm
	where B. gvkey='Y9999'
	having A. gvkey ne 'Y9999';
quit;
proc sql;
	create table Sample3b as
	select distinct Conm, yyyy, sum(RETadj) as RETadjY
	from sample2b
	group by Conm, yyyy
	order by Conm, yyyy;
quit;
proc transpose data=sample3b out=sample4b;
	var RETadjY;
	by Conm;
	id yyyy;
run;
proc print data=sample4b; run;


/*******************************;
Example: merge無法做到或很難做到的任務
Example: 以Mydata. F01s_A_financialann  為資料，計算每家公司每一年的industry adjusted ROA(ROA_Adj)。industry adjusted ROA(ROA_Adj)=ROA/ mean ROA of "the other firms" in its corresponding industry;
"the other firms"是不包含自己公司
*******************************/
data Sample;
	set Mydata. F01s_A_financialann;
	yyyy=year(datadate);
	ROA=NI/AT;
	No+1;
	keep gvkey yyyy datadate  CONM sic_tej    ROA No ;
run;
data SampleB;
	set Sample;
run;
proc sql;
	create table Sample2 as
	select A. *, B. yyyy as yyyyB, B. conm as conmB, B. ROA as ROAB
	from Sample as A left join SampleB as B
	on A. yyyy=B. yyyy and
		A. sic_tej=B. sic_tej and
		A. Conm ne B. Conm
	order by No, yyyyB;
quit;
proc sql;
	create table Sample3 as
	select distinct No, Conm, yyyy, sic_tej, ROA, mean(ROAB) as mROA
	from Sample2
	group by No
	order by No;
quit;
data Sample4;
       set Sample3;
       ROA_Adj=ROA-mROA;
run;



/*******************************;
Example: merge無法做到或很難做到的任務
以Mydata. F01s_A_financialann 為主樣本，計算每一樣本之Beta=當年度自己公司"12"個月月報酬計算的CAPM beta。CAPM的系統風險(systematic risk, beta)。Ri=b0+beta*Rm+e。	
*******************************/
data Sample;
	set Mydata. F01s_A_financialann;
	 ROA=NI/AT;
	logSize=log(AT);
	datadate=datadate+30;
	yyyy=year(datadate);
	No+1;
	keep gvkey yyyy datadate  CONM sic_tej   ROA No;
run;
proc sort nodup; by conm yyyy; run;

*Method01: (Ch06的寫法);
data Rm;
	set Mydata. F01s_b_ret_monthly;
	where gvkey = 'Y9999';
	rename RET=Rm;
	keep datadate  RET;
run;
proc sort nodup; by datadate; run;
data RET;
	set Mydata. F01s_b_ret_monthly;
	where gvkey ne 'Y9999' and RET is not missing ;
run;
proc sort nodup; by datadate; run;
data RET2;
	merge  Rm RET(in=a);
	by datadate;
	if a=1;
	if Rm=. then delete;
		yyyy=year(datadate);
run;
proc sort nodup; by conm yyyy; run;
proc reg data=RET2 outest=Coeff    noprint; 	
	model RET=Rm;
	by conm yyyy;
quit;
data Coeff2;
	set Coeff;
	where _type_ = 'PARMS';
	Beta=Rm;
	keep conm yyyy Beta;
run;
proc sort nodup; by conm yyyy; run;
data Sample2;
	merge Coeff2 Sample (in=a);
	by Conm yyyy;
	if a=1;
run;
proc sort nodup; by No; run;

*Method02: (Sql的寫法);
proc sql;
	create table RET2b as
	select A. *, B. datadate as datadateB, B. RET
	from Sample as A left join Mydata. F01s_b_ret_monthly as B
	on A. Conm=B. Conm and
		B. datadate-A. datadate between 0 and -364
	having RET is not missing
	order by No, datadateB ;
quit;
proc sql;
	create table RET3b as
	select A. *, B. RET as Rm
	from RET2b as A left join Mydata. F01s_b_ret_monthly as B
	on A. datadateB=B. datadate 
	where B. gvkey='Y9999' 
	order by No, datadateB;
quit;	
proc reg data=RET3b outest=Coeffb    noprint; 	
	model RET=Rm;
	by No;
quit;
proc sql;
	create table Sample2b as
	select distinct A. *, B. Rm as Beta
	from Sample as A left join Coeffb as B
	on A. No=B. No
	where _type_ = 'PARMS' 
	order by No;
quit;

/*******************************;
Example: merge無法做到或很難做到的任務
以Mydata. F01s_A_financialann 為主樣本，計算每一樣本之Beta=當年度自己公司"36"個月月報酬計算的CAPM beta。CAPM的系統風險(systematic risk, beta)。Ri=b0+beta*Rm+e。	
*******************************/
***Ans:只要將上面的Method02的-364改為-1094即可。上面的Method01無法做。;



