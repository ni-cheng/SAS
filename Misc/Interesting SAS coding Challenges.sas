/*
I have a set of number with different digits. I want to make all of them 6
digits, if they are not, adding zero to the right? Like this,
Original data set
x
345
4567
777777
23567
.
.
.
Desired result look like this,
x
345000
456700
777777
235670
.
.
.
Thanks very much! Will send baozi for the help.
*/

data x;
   input x $6.;
   y=translate(x, '0', ' ');
datalines;
345
4567
777777
23567
;
run;

/************************/

/*
Original data be like:
var1 var2 var3 var4
2 4 6 7
4 9 7 6
5 2 1 1

如何得到一个新的variable， 它的值是var1-var4中有最大值的那个variable的名字。
结果应该是:

newvar
var4
var2
var1


谢谢
*/
data _xxx;
   input var1 var2 var3 var4;
cards;
2 4 6 7
4 9 7 6
5 2 1 1
7 3 7 3
;
run;

proc transpose data=_xxx out=_xxx2;
run;

proc means data=_xxx2 noprint;
     var col1-col4;
     output out=_xxx3(keep=v1-v4)
            maxid(col1(_name_)  col2(_name_)  col3(_name_) col4(_NAME_))= v1-v4/autoname;
run;

proc transpose data=_xxx3 out=_xxx3t;
     var v1-v4;
run;
data _xxx;
    merge _xxx _xxx3t(keep=COL1);
    rename col1=varname;
run;

/*
Hi Everyone,

I want to use fixed effects to estimate a model, using GMM estimation and the model consists of simultaneous equations. I am using PROC MODEL (proc panel does not support simultaneous equations) and using dummy variable to control the fixed effects.
Since there are 100+ dummy variables, does that mean I need to create 100+ parameters corresponding to these 100+ dummy variables? Is there any efficient way to add the dummy variables when using PROC MODEL? Generate 100+ parameters for the dummy variable is too much burden...
Suppose the simultaneous eq. model is like this:

y1=a0+a1*x1+a2*x2
y2=b0+b1*x1+b2*x3

After adding the dummy variables, the model will be like this??!!

y1=a0+a1*x1+a2*x2+a3*col1+a4*col2+a5*col3+....a102*col100+...
y2=b0+b1*x1+b2*x3+b3*col1+b4*col2+b5*col3+....b102*col100+...

Is there any easy way to write the dummy variables and the corresponding parameters,  like col1-c100 in PROC MODEL?

Thanks very much.
Alice.

https://communities.sas.com/t5/SAS-Procedures/an-efficient-way-to-add-dummy-variables-in-PROC-MODEL/m-p/116702#M32183
*/

/** if you have SAS/STAT, use PROC GLMMOD, to output parameter  and associated column numbers and use SQL to create your statement: **/；

proc glmmod data=sashelp.cars outparm=parm;
        class type;
        model MPG_CITY=TYPE;
run;

proc sql noprint;
        select cats('a', _colnum_, '*col', _colnum_) into :stmt separated by '+'
        from    parm
;
quit;

%put &stmt;

/*
Hi Everyone,

I want to use fixed effects to estimate a model, using GMM estimation and the model consists of simultaneous equations. I am using PROC MODEL (proc panel does not support simultaneous equations) and using dummy variable to control the fixed effects.
Since there are 100+ dummy variables, does that mean I need to create 100+ parameters corresponding to these 100+ dummy variables? Is there any efficient way to add the dummy variables when using PROC MODEL? Generate 100+ parameters for the dummy variable is too much burden...
Suppose the simultaneous eq. model is like this:

y1=a0+a1*x1+a2*x2
y2=b0+b1*x1+b2*x3

After adding the dummy variables, the model will be like this??!!

y1=a0+a1*x1+a2*x2+a3*col1+a4*col2+a5*col3+....a102*col100+...
y2=b0+b1*x1+b2*x3+b3*col1+b4*col2+b5*col3+....b102*col100+...

Is there any easy way to write the dummy variables and the corresponding parameters,  like col1-c100 in PROC MODEL?
*/

/*if you have SAS/STAT, use PROC GLMMOD, to output parameter  and associated column numbers and use SQL to create your statement:*/

proc glmmod data=sashelp.cars outparm=parm;
        class type;
        model MPG_CITY=TYPE;
run;

proc sql noprint;
        select cats('a', _colnum_, '*col', _colnum_) into :stmt separated by '+'
        from    parm
;
quit;
%put &stmt;

/***
原始表格
name day sale
a 1 23
a 2 56
a 3 45
…
a 100 34
b 1 4
b 2 4
b 3 5
…
b 100 45
week 从1-100
现在要sum sale for each name first 10 d, first 20d, first 30 d,一直到
100d
最后结果是
name sale10d sale20d sale30d …sale100d
a
b
我现在用很笨的办法, subsetting dataset 变成 很多小的 datasets
第一个是只包括前10天, 第二个只包括前20天, …
然后在分别做sum
想问下有没有简单点的办法 ? 感谢!
*****/

** --oloolo
data test;
   do id=‘a’, ‘b’, ‘c’;
      do day=1 to 100;
         sale=ranuni(9796876)*100;
         output;
      end;
   end;
run;

data fmt;
   retain fmtname ‘cssale’ type ‘n’ hlo ‘M’;
   retain start 1;
   do end=10 to 100 by 10;
      label=cats(put(end, Z3.),‘d’);
      output;
   end;
run;

proc format cntlin=fmt cntlout=fmtchk;
run;
proc means data=test noprint nway;
   by id;
   class day /mlf exclusive;
   format day cssale.;
   var sale;
   output out=cumsum sum(sale)=salesum;
run;
proc transpose data=cumsum out=cumsumt name=day prefix=sale;
   by id;
   var salesum;
   id day;
run;


