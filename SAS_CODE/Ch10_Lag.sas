/***********************************************
Sample program: Ch10  Lag, If...first
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
	keep gvkey yyyy datadate  CONM sic_tej   DebtR ROA logSize AT Sale ProfitR DROA;

run;




******編號, if, 	if first, if last, if then ... output;
data f0;/*給每個樣本一個編號*/
	set az;
	No1+1;
	keep  No1 yyyy conm  sic_tej Sale ;
run;
proc sort nodup; by conm  yyyy; run;
*lag; /*sales growth, std of sales*/
data f11;
	set f0;
	lag1Sale=lag(Sale);
	SaleG=(Sale-lag1Sale)/lag1Sale;
run;
proc sort nodup; by  conm yyyy; run;
data f12;
	set f11;
	by conm yyyy;
	if first. conm then FirstYear='Yes';
run;
data f13;
	set f12;
	by conm yyyy;
	if first. conm then SaleG=.;
run;

/*******************************;
Exercise 10-1: 以Mydata. F01s_A_financialann 為資料，計算ROA_new1=NI/(Total asset in the beginning year), ROA_new2=NI/(Average Total asset between the beginning year and the endding year)
*******************************/



data f21;
	set f0;
	lag1Sale=lag1(Sale);
	lag2Sale=lag2(Sale);
	lag3Sale=lag3(Sale);
	stdSale=std(Sale, lag1Sale, lag2Sale, lag3Sale);
run;
proc sort nodup; by conm yyyy; run;
data f22;
	set f21;
	by conm yyyy;
	if first. conm then order_yyyy=0; order_yyyy+1;
	if order_yyyy<=3 then stdSale=.;
run;
*the last year;
data f23;
	set f22;
	by conm yyyy;
	if last. conm then lastyyyy='Yes';
run;
data f23;
	set f22;
	by conm yyyy;
	if last. conm then lastyyyy='Yes';
	if last. conm then output; *if last. conm;
run;
data f23;
	set f22;
	by conm yyyy;
	if last. conm; 
run;

/*******************************;
Exercise 10-2: 以Mydata. F01s_A_financialann 為資料，迴歸模型：ROA=b0+b1*DebtR+b2*STD_ROA+e
						STD_ROA=最近五年ROA的標準差;
*******************************/



**the Rank saleG in each year;
data f31;
	set f0;
	SaleG=(sale-lag(sale))/lag(sale);
run;
proc sort nodup; by  conm yyyy; run;
data f32;
	set f31;
	by conm yyyy;
	if first. conm then SaleG=.;
	if first. conm then order_yyyy=0; order_yyyy+1;
run;


proc sort out=f32s nodup; by yyyy saleG; run;
data f33;
	set f32s;
	by yyyy saleG;
	if first. yyyy then RankSaleG=0; RankSaleG+1; /*compare order_yyyy, RankSaleG*/
run;

*min saleG;
proc sort nodup; by yyyy saleG; run;
data f34a;
	set f33;
	by yyyy saleG;
	if first. yyyy then output; 
run;
*max saleG;
data f34b;
	set f33;
	by yyyy saleG;
	if last. yyyy then output; 
run;
*min 3 saleG;
data f34c;
	set f33;
	if RankSaleG>3 then delete;
run;
*max 3 saleG;
proc sort data=f33 out=f33s nodup; by yyyy descending saleG; run;
data f34d1;
	set f33s;
	by yyyy descending saleG;
	if first. yyyy then RankSaleGmax=0; RankSaleGmax+1; /*compare order_yyyy, RankSaleG*/
run;
data f34d2;
	set f34d1;
	where RankSaleGmax<=3;
run;
/*******************************;
Exercise 10-3: 以Mydata. F01s_A_financialann 為資料，進行以下迴歸：
迴歸模型：NextROA=b0+b1*DebtR+b2*LnAT+e
                      NextROA=計算下一期的ROA
						LnAT=log(AT)
*******************************/


**the Rank saleG for "each industry" in each year;
proc sort data=f32 out=f41 nodup; by yyyy sic_tej   saleG; run;
data f43;
	set f41;
	by  yyyy  sic_tej saleG;
	if first. sic_tej then RankSaleG=0; RankSaleG+1; /*compare order_yyyy, RankSaleG*/
run;

*min saleG;
proc sort nodup; by  yyyy sic_tej saleG; run;
data f44a;
	set f43;
	by  yyyy sic_tej saleG;
	if first. sic_tej then output; 
run;
*max saleG;
data f44b;
	set f43;
	by  yyyy sic_tej saleG;
	if last. sic_tej then output; 
run;
*min 3 saleG;
data f44c;
	set f43;
	if RankSaleG>3 then delete;
run;
*max 3 saleG;
proc sort data=f43 out=f43s nodup; by   yyyy sic_tej descending saleG; run;
data f44d1;
	set f43s;
	by  yyyy sic_tej descending saleG;
	if first. sic_tej then RankSaleGmax=0; RankSaleGmax+1; 
run;
data f44d2;
	set f44d1;
	where RankSaleGmax<=3;
run;




