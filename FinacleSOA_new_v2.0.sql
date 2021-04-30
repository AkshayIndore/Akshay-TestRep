--#===================================================================================================*
--# Source Name        : Account_statement.sql
--# Author             :
--# Description        : This sql generates lst file of account statement
--# Called Scripts     :  NA
--# Calling Script     :  NA
--# Bank Name          :  RATNAKAR
--#  Srl No       Date                  Name                   Description
--#==================================================================================================*
set serveroutput on size unlimited
set head off
set line 1000
set pages 0
set echo off
set trimspool on
set feedback off
set verify off
--spool Accounts_Statement.lst

DECLARE

lv_opn_bal      number;
lv_running_Bal  number;
lv_fromDate     varchar2(20) ;
lv_toDate       varchar2(20) ;
lv_preDate      date ;
lv_tran_ord     number :=0;

begin
select db_stat_date into lv_fromDate from tbaadm.gct;
select db_stat_date into lv_toDate from tbaadm.gct;
BEGIN
--{
select (to_date(lv_fromDate,'DD-MM-YYYY')-1) into lv_preDate from dual;
EXCEPTION WHEN NO_DATA_FOUND THEN
lv_preDate := '';
--}
END;




begin

select nvl(tran_date_bal,0)  into lv_opn_bal
from tbaadm.eab
where acid = ( select acid from tbaadm.gam where foracid = '&1')
and eod_date <= (select db_stat_date-1  from tbaadm.gct)
--lv_preDate
and end_eod_date >= (select db_stat_date-1  from tbaadm.gct);
--lv_preDate;
EXCEPTION WHEN NO_DATA_FOUND THEN
lv_opn_bal:= 0.00;

end;



 begin
 for x in
 (select         gam.sol_id,
 gam.acid,
 foracid,
 tran_date,
 value_date,
 instrmnt_num,
 part_tran_type,
 decode(part_tran_type,'D',tran_amt) dr_amt,
 decode(part_tran_type,'C',tran_amt) cr_amt,
 tran_particular ,
 tran_id,
 ref_num,
 tran_rmks
 from tbaadm.dtd,tbaadm.gam
 where dtd.acid = gam.acid
 and gam.foracid = '&1'
 and dtd.tran_date between  lv_fromDate  and lv_toDate
 and dtd.del_flg = 'N'
 and dtd.pstd_flg = 'Y'
 order by pstd_date,tran_id)


 loop

 begin


 if ( x.part_tran_type = 'C' ) then
 lv_running_Bal := lv_opn_bal + nvl(x.cr_amt,'0.00');
 else
 lv_running_Bal := lv_opn_bal - nvl(x.dr_amt,'0.00');
 end if;


 lv_opn_bal := lv_running_Bal;
 lv_tran_ord := lv_tran_ord +1 ;

--dbms_output.put_line (  x.foracid||'|'|| x.tran_date||'|'|| x.value_date||'|'|| x.instrmnt_num||'|'|| x.tran_particular||'|'|| nvl(x.dr_amt,'0.00')||'|'|| nvl(x.cr_amt,'0.00')||'|'|| lv_running_Bal||'|'|| x.tran_id||'|'|| x.ref_num);

dbms_output.put_line ( x.foracid||'|'||x.tran_date||'|'||trim(x.tran_id)||'|'||x.tran_particular||'|'||x.sol_id||'|'||nvl(x.dr_amt,'0.00')||'|'|| nvl(x.cr_amt,'0.00')||'|'|| lv_running_Bal);
 end;
 end loop;
 end;
 end;
 /
--spool off
