rem PL/SQL Developer Test Script

set feedback off
set autoprint off

rem Execute PL/SQL Block
create or replace package PKG_HEALTHCHECK_HC is

FUNCTION F_HEALTHCHECK_HC RETURN SYS_REFCURSOR;                 -- Providing us the status of the format files is correct or not present in systemstatus table
function F_GETMODULE_HC (filename in varchar) return varchar2;  -- providing us the module name of the input file provided by us to the function
procedure P_UPDSTATUS_HC(filename in varchar2, z out varchar2); --as per above input file, inserting the values in systemstatus table of correct files

end PKG_HEALTHCHECK_HC;

create or replace package body PKG_HEALTHCHECK_HC is

FUNCTION F_HEALTHCHECK_HC
RETURN SYS_REFCURSOR 
IS
v_cursor SYS_REFCURSOR;
ss_status  varchar2(100);
--cur_systemstatus_ss SYS_REFCURSOR;
--cur_systemcheck_config_scc SYS_REFCURSOR;
ss_brand  systemstatus.brand%TYPE;
ss_module  systemstatus.module%TYPE;
ss_value  systemstatus.value%TYPE;
ss_latest_insertion  systemstatus.insertedon%TYPE;
ss_no_of_inserted_files number;
ss_time_col  systemstatus.value%TYPE;
ss_extracted_date systemstatus.value%TYPE;
--ss_latest_value systemstatus.insertedon%TYPE;
v_x  systemstatus.value%TYPE;
ss_last_mon_val systemstatus.value%TYPE;
ss_latest_value systemstatus.value%TYPE;
ss_date_value_from_config_pos systemstatus.value%TYPE;
ss_time_value_from_config_pos systemstatus.value%TYPE;
ss_sufix_val_from_config_pos systemstatus.value%TYPE;
ss_prefix_val_from_config_pos systemstatus.value%TYPE;
ss_FILECREATE_DAYS systemstatus.value%TYPE;
ss_filecreate_days_diff systemstatus.value%TYPE;
ss_config_date_format systemstatus.value%TYPE;
ssc_BRAND systemcheck_config.BRAND%TYPE;
ssc_MODULE systemcheck_config.MODULE%TYPE;
ssc_FILEFIX systemcheck_config.FILEFIX%TYPE;
ssc_INOUT systemcheck_config.INOUT%TYPE;
ssc_file_prf_suf systemcheck_config.FILEFIX%TYPE;
ssc_suffix systemcheck_config.FILEFIX%TYPE;
ssc_FILECREATE_DAYSBEHIND systemcheck_config.FILECREATE_DAYSBEHIND%TYPE;
ssc_expected_file systemcheck_config.FILEFIX%TYPE;
ssc_config_date_format systemcheck_config.FILEFIX%TYPE;
ssc_config_time_format systemcheck_config.FILEFIX%TYPE;
ssc_status_date_position systemcheck_config.FILEFIX%TYPE;
ssc_status_time_position systemcheck_config.FILEFIX%TYPE;
exp_expected_format systemcheck_config.FILEFIX%TYPE;
exp_Expected_file_name systemcheck_config.FILEFIX%TYPE;
exp_Expected_suffix systemcheck_config.FILEFIX%TYPE;
exp_filecreate_daysbehind systemcheck_config.filecreate_daysbehind%TYPE;
v_start_date_position systemcheck_config.FILEFIX%TYPE;
v_end_date_position systemcheck_config.FILEFIX%TYPE;
v_start_time_position systemcheck_config.FILEFIX%TYPE;
v_end_time_position systemcheck_config.FILEFIX%TYPE;
act_actual_format systemstatus.value%TYPE;
act_actual_file systemstatus.value%TYPE;

dl_dwn_file  download_logs.dwn_file%TYPE;
dl_uploaded varchar2(225);

cursor cur_systemcheck_config_scc is

with sq as
(
select case when 
substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is not null 
and 
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is not null
  then 
  replace((replace(filefix, substr(filefix,(instr(filefix,'<#',1)), instr(filefix, '>',1)-(instr(filefix,'<#',1))+1),'%'))
, substr(filefix,(instr(filefix,'<##',1)), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)-1)),'%' )
when substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is null
and
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is null
  then 'Date/Time format is not present'
when 
substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is not null 
and 
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is null
  then
  replace(filefix, substr(filefix,(instr(filefix,'<#',1)), instr(filefix, '>',1)-(instr(filefix,'<#',1))+1),'%') 
when 
substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is null 
and 
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is not null  
  then
  replace(filefix,substr(filefix,(instr(filefix,'<##',1)), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)-1)),'%')
else 'Different_case' end file_prf_suf
,filefix,FILECREATE_DAYSBEHIND,BRAND, MODULE,INOUT,FILECREATE_DAYS
from systemcheck_config
)
select BRAND, MODULE, filefix,INOUT,file_prf_suf,FILECREATE_DAYS
--,substr(file_prf_suf,0,instr(file_prf_suf,'%',1)-1) prefix 
--,SUBSTR(file_prf_suf, INSTR(file_prf_suf, '%') + 1, INSTR(file_prf_suf, '%', 1, 2) - INSTR(file_prf_suf, '%') - 1) midddle
--, SUBSTR(file_prf_suf, INSTR(file_prf_suf, '%', -1) + 1) suffix
,CASE WHEN SUBSTR(FILECREATE_DAYS,1,1) LIKE 'M' THEN 0 ELSE
(LENGTH(filecreate_days)-LENGTH(REPLACE(filecreate_days,(SELECT DECODE(substr(TO_CHAR(SYSDATE, 'DAY'),0,2),'MO','1','TU','2','WE','3','TH','4','FR','5','SA','6','SU','7','DAY NOT PRESENT') FROM DUAL),'')))
END filecreate_days_diff
,case when sq.file_prf_suf IN ('Date/Time format is not present','Different_case') THEN 'Date/Time format is not present/Different_case' ELSE 
substr(file_prf_suf,0,instr(file_prf_suf,'%',1)-1)
||case when substr(filefix,(instr(filefix,'<#',1)+2),(instr(filefix, '>',1)-(instr(filefix,'<#',1)+2) )) like '%DD%' then to_char(sysdate-FILECREATE_DAYSBEHIND,'RRRRMMDD') else to_char(sysdate-FILECREATE_DAYSBEHIND,'RRRRMM') end--to_char(sysdate-FILECREATE_DAYSBEHIND,'RRRRMMDD')--to_char(sysdate-FILECREATE_DAYSBEHIND,'RRRRMMDD')
||SUBSTR(file_prf_suf, INSTR(file_prf_suf, '%') + 1, INSTR(file_prf_suf, '%', 1, 2) - INSTR(file_prf_suf, '%') - 1)
--||TO_CHAR(SYSTIMESTAMP, 'HH24MISS')
--||SUBSTR(file_prf_suf, INSTR(file_prf_suf, '%', -1) + 1)  
END expected_file,--,FILECREATE_DAYSBEHIND
SUBSTR(file_prf_suf, INSTR(file_prf_suf, '%', -1) + 1) suffix,
case when substr(filefix,(instr(filefix,'<#',1)+2),(instr(filefix, '>',1)-(instr(filefix,'<#',1)+2) ))  like '%DD%'then FILECREATE_DAYSBEHIND else 0 end FILECREATE_DAYSBEHIND --not like '%DD%'then 0 else FILECREATE_DAYSBEHIND
,case when sq.file_prf_suf IN ('Date/Time format is not present','Different_case') THEN 'Date/Time format is not present/Different_case' ELSE 
(''''||substr(filefix,(instr(filefix,'<#',1)+2),(instr(filefix, '>',1)-(instr(filefix,'<#',1)+2) ))|| '''') end config_date_format 
--, ( (instr(filefix,'<#',1)+2)||','|| (instr(filefix, '>',1)-(instr(filefix,'<#',1)+2) ))  config_date_format 
,substr( (instr(filefix,'<##',1)+3), (instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3))) config_time_format
--, ( (instr(filefix,'<##',1)+3)||','|| (instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)))   config_time_format 
,case when sq.file_prf_suf IN ('Date/Time format is not present','Different_case') THEN 'Date/Time format is not present/Different_case' ELSE 
( (instr(filefix,'<#',1)  )||','|| ((instr(filefix, '>',1)-2 )-(instr(filefix,'<#',1)  ) )) end status_date_position  --'<#' is having 2 digit count, so we have to reduse the count by 1 for comparing actual value, same for '>'
,case when sq.file_prf_suf IN ('Date/Time format is not present','Different_case') THEN 'Date/Time format is not present/Different_case' ELSE 
 ( (instr(filefix,'<##',1)-3)||','|| '6') end status_time_position
 --( (instr(filefix,'<##',1)+3)||','|| (instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3))) end status_time_position
from sq; 
----------------------------------
cursor cur_systemstatus_ss is 
select  s.BRAND, s.MODULE, s.VALUE, s. Latest_insertion, c. no_of_inserted_files,c.latest_value,substr(value,(instr(value,'.',1)-6), 6) time_col
--into ss_brand,ss_module,ss_value,ss_latest_insertion,ss_no_of_inserted_files,ss_latest_value
, substr(s.VALUE,v_start_date_position,v_end_date_position) date_value_from_config_pos                                       --,REGEXP_SUBSTR(value, '\d{4}\d{2}\d{2}') AS extracted_date
, substr(s.VALUE,v_start_time_position,v_end_time_position) time_value_from_config_pos
, substr(s.VALUE,1,length(ssc_expected_file)) prefix_value_from_config_pos --ssc_expected_file is coming from another cursor
, substr(s.VALUE,-length(ssc_suffix)) suffix_value_from_config_pos -- ssc_suffix is coming from another cursor

,  substr(s.VALUE,(v_start_date_position+v_end_date_position),(1)) last_mon_val --2
, ssc_config_date_format config_date_format --coming from another cursor (config cursor) --as we have joined on the basis of s.Module = ssc_MODULE
from
(select  BRAND, MODULE, VALUE,substr(value,15,8) name_date, max(INSERTEDON) Latest_insertion, null no_of_inserted_files from systemstatus group by  BRAND, MODULE, VALUE) s,
(select BRAND, MODULE,max(INSERTEDON) Latest_insertion, count(INSERTEDON) no_of_inserted_files
--,max(to_date(substr(value,15,8),'RRRRMMDD')) latest_value
,max((substr(value,15,8))) latest_value
 from systemstatus
group by  BRAND, MODULE
) c -- only Latest_insertion is present, so it will fetch the latest VALUE module/brand wise
where s.BRAND=c.BRAND
and  s.MODULE=c.MODULE
--and  s.Latest_insertion=c.Latest_insertion
and s.name_date=c.latest_value
and s.Module = ssc_MODULE -- joining the cursors on the basis of modules
order by s. Latest_insertion desc;
----------------------------------
cursor cur_download_logs_dl is 
select SUBSTR(dwn_file,1,22) from download_logs;-- where SUBSTR(dwn_file,1,22) = substr(SS_VALUE,1,22);
--v_found BOOLEAN := FALSE;
BEGIN
--  loop
--where INOUT = 'OUT'
/*select filecreate_daysbehind,substr(FILEFIX,1,14),filefix expected_format,substr(FILEFIX,1,14)||to_char(sysdate-filecreate_daysbehind,'RRRRMMDD')Expected_file_name ,filecreate_daysbehind ,substr(filefix,1,22) from systemcheck_config c*/
open cur_systemcheck_config_scc; 
loop
fetch cur_systemcheck_config_scc into ssc_BRAND,ssc_MODULE,ssc_FILEFIX,ssc_INOUT,ssc_file_prf_suf,ss_FILECREATE_DAYS,ss_filecreate_days_diff,ssc_expected_file,ssc_suffix
,ssc_FILECREATE_DAYSBEHIND,ssc_config_date_format,ssc_config_time_format,ssc_status_date_position,ssc_status_time_position;--ssc_BRAND,ssc_MODULE,ssc_FILEFIX,ssc_INOUT,ssc_expected_file; 
 EXIT WHEN  cur_systemcheck_config_scc%NOTFOUND; 

exp_expected_format := ssc_FILEFIX;
exp_Expected_file_name := ssc_expected_file; --substr(ssc_expected_file,1,23);--substr(ssc_FILEFIX,1,14)||to_char(sysdate-ssc_FILECREATE_DAYSBEHIND,'RRRRMMDD');
exp_Expected_suffix := ssc_suffix;

v_start_date_position:= substr( ssc_status_date_position ,1,instr( ssc_status_date_position, ',')-1);--select substr( '14,5' ,1,instr( '14,5', ',')-1) from dual  
v_end_date_position:= substr( ssc_status_date_position ,instr( ssc_status_date_position, ',')+1,2);  --select substr( '14,5' ,instr( '14,5', ',')+1,2) from dual 

v_start_time_position:= substr( ssc_status_time_position ,1,instr( ssc_status_time_position, ',')-1);--select substr( '14,5' ,1,instr( '14,5', ',')-1) from dual  
v_end_time_position:= substr( ssc_status_time_position ,instr( ssc_status_time_position, ',')+1,2);  --select substr( '14,5' ,instr( '14,5', ',')+1,2) from dual 
  

IF cur_systemstatus_ss%ISOPEN THEN
      CLOSE cur_systemstatus_ss;
END IF; --at line 48 joining the cursors on the basis of modules, so we have to close it 

open cur_systemstatus_ss;
loop
fetch cur_systemstatus_ss into ss_brand,ss_module,ss_value,ss_latest_insertion,ss_no_of_inserted_files,ss_latest_value
,ss_time_col,ss_date_value_from_config_pos,ss_time_value_from_config_pos, ss_prefix_val_from_config_pos,ss_sufix_val_from_config_pos,ss_last_mon_val,ss_config_date_format ;--, ss_extracted_date
 
--end loop;
EXIT WHEN  cur_systemstatus_ss%NOTFOUND;
act_actual_format:= ss_value;
--act_actual_file := ss_prefix_val_from_config_pos; -- substr(ss_value,1,23);
act_actual_file := substr(ss_value,1,length(ssc_expected_file));
--end loop;
--DBMS_OUTPUT.PUT_LINE('value-------------------------------------------------------------' || ss_value); 
--DBMS_OUTPUT.PUT_LINE('days behind------------------------------------------------------------- :' || ssc_FILECREATE_DAYSBEHIND); 
ss_extracted_date:= to_char(sysdate-ssc_FILECREATE_DAYSBEHIND,ssc_config_date_format); --only works if cofig table is having valid date format.--to_char(sysdate,'YYYYMMDD') 

if 
exp_Expected_file_name = act_actual_file -- expected and actual file comparision of prefix (including date)
and 
exp_Expected_suffix = ss_sufix_val_from_config_pos -- expected and actual file comparision of suffix
 then 
   ss_status := 'Success';
   --ss_latest_value--> latest_actaul_file > we want laf if all the files are having issue
else
  ss_status := 'Error';
  
end if;
/*
DBMS_OUTPUT.PUT_LINE('days behind above :' || ssc_FILECREATE_DAYSBEHIND); 
DBMS_OUTPUT.PUT_LINE('prefix :' || ss_prefix_val_from_config_pos); 
DBMS_OUTPUT.PUT_LINE('suffix :' || ss_sufix_val_from_config_pos); 
 DBMS_OUTPUT.PUT_LINE('suffix_config :' || ssc_suffix);-- length(ssc_suffix)

if 
 TO_CHAR(systimestamp, 'HH24:MI:SS')>'17:00:00' -- --TO_CHAR(ss_time_value_from_config_pos, 'HH24:MI:SS')
 then ssc_FILECREATE_DAYSBEHIND:=ssc_FILECREATE_DAYSBEHIND+1;
 end if;
 */
--INSERT INTO temp_table VALUES (ssc_BRAND,ssc_MODULE,exp_Expected_file_name,act_actual_file,ss_status) ;

end loop;

if
 ss_brand = ssc_BRAND --Brand -- optional
 and
ss_module = ssc_MODULE --Module ---- optional
and
exp_Expected_file_name = act_actual_file -- expected and actual file comparision
and 
exp_Expected_suffix = ss_sufix_val_from_config_pos
 then 
   ss_status := 'Success';
   --ss_latest_value--> latest_actaul_file > we want laf if all the files are having issue
elsif 
ss_brand <> ssc_BRAND 
or
ss_module <> ssc_MODULE
--or
--exp_Expected_file_name <> act_actual_file
then
  ss_status := 'Error';
  ss_value := 'value not present'; -- optional 
  act_actual_format := 'value not present';
  --ss_latest_value --> latest_actaul_file > we want laf if all the files are having issue
 else
  ss_status := 'Error'; 
end if;


--file create days checking only if it passes the above conditions:
if ss_status ='Success' then
 if substr(ss_filecreate_days,1,1) = 'D' THEN 
    if ss_filecreate_days_diff = '1' then ss_status := 'Success';   --V_days := 'MO,TU,WE,TH,FR,SA,SU';
    else ss_status := 'Error'; end if;
 ELSIF substr(ss_filecreate_days,1,1) = 'W' THEN
    if ss_filecreate_days_diff = '1' then ss_status := 'Success';  
    else ss_status := 'Error'; end if;      
 ELSIF substr(ss_filecreate_days,1,1) = 'M' then
      FOR val IN (
                   SELECT TRIM(REGEXP_SUBSTR(substr(ss_FILECREATE_DAYS,3,20000), '[^,]+', 1, LEVEL)) AS val --this query is making (10,15,12) all the digits individually like val.val=10, val.val=15,val.val=12
                   FROM dual /* Note: In ss_FILECREATE_DAYS for Month M, the numbers are actual date, i.e. M-10,28,23 : means that file will run on 10, 28 and 23 rd dates of every nmonth */
                   CONNECT BY LEVEL <= REGEXP_COUNT(substr(ss_FILECREATE_DAYS,3,20000), ',') + 1
                   ORDER BY TO_NUMBER(val) ASC
                 ) LOOP
                    -- v_x := TO_CHAR(TO_DATE((val.val||substr(to_date(sysdate,'dd-mm-rrrr'),-7)), 'DD-MON-RR'), 'DAY'); --select TO_CHAR(TO_DATE(('15'||substr(to_date(sysdate,'dd-mm-rrrr'),-7)), 'DD-MON-RR'), 'DAY') from  dual
                    v_x := TO_DATE((val.val||substr(to_date(sysdate,'dd-mm-rrrr'),-7)), 'DD-MON-RR')-ssc_FILECREATE_DAYSBEHIND; --ssc_FILECREATE_DAYSBEHIND will always be 0 for the month ('M')
                     IF
                       v_x = TO_DATE(SYSDATE-ssc_FILECREATE_DAYSBEHIND, 'DD-MON-RR') AND -- complete date comparision
                      TO_CHAR(TO_DATE(v_x,'DD-MON-RR')-ssc_FILECREATE_DAYSBEHIND,'DAY') = TO_CHAR(SYSDATE, 'DAY') --TO_CHAR(SYSDATE, 'DAY')--(multiple dates are having same days, so fully comparing the date too) -- v_x is the Day of the date, date is in loop in which month and year is of sysdate, but day(number) is in loop, i.e. M-10,28,23 will be 10/01/2024,28/02/2024,23/02/2024..
                     then ss_status := 'MONTH_SUCCESS';
                     EXIT; --BREAK; - once we got existance of 'MONTH_SUCCESS', then we will break the loop.
                     ELSE ss_status := 'MONTH_ERROR';
                     END IF;    
                   END LOOP;
 else ss_status := 'Error'; end if;
    
ELSE ss_status := 'Error';
end IF;
/*
BEGIN --substr(ss_FILECREATE_DAYS,3,20000)
  FOR val IN (
    SELECT TRIM(REGEXP_SUBSTR(substr(ss_FILECREATE_DAYS,3,20000), '[^,]+', 1, LEVEL)) AS val
    FROM dual
   CONNECT BY LEVEL <= REGEXP_COUNT(substr(ss_FILECREATE_DAYS,3,20000), ',') + 1
  ) LOOP
  
 v_x := TO_CHAR(TO_DATE((val.val||substr(to_date(sysdate,'dd-mm-rrrr'),-7)), 'DD-MON-RR'),'DAY');

    DBMS_OUTPUT.PUT_LINE ('val.val' || val.val);
     DBMS_OUTPUT.PUT_LINE ('v_x=' || v_x);
  END LOOP;
end;
*/
---few more checks
--/*
if
  ss_status ='Success' then 
  if
    ss_config_date_format = '''YYYYMM''' 
    AND 
    ss_last_mon_val --substr(ss_value,(v_start_date_position+v_end_date_position),(2)) 
      --like '%0123456789%'
    IN ('0','1','2','3','4','5','6','7','8','9') 
  THEN ss_status := 'ERROR_'; 
  End if;
 End if;

--->>checking of IN/OUT file

open  cur_download_logs_dl;
loop
fetch cur_download_logs_dl into dl_dwn_file;
EXIT WHEN  cur_download_logs_dl%NOTFOUND; 

 IF
 ssc_INOUT = 'IN'
 THEN 
    IF act_actual_file = dl_dwn_file -- = substr(SS_VALUE,1,22) = dl_dwn_file
    THEN dl_uploaded := 'YES';
    ELSIF act_actual_file <> dl_dwn_file-- substr(SS_VALUE,1,22)<> dl_dwn_file-- SUBSTR(dl_dwn_file,1,22)
       THEN dl_uploaded := 'NO';
      ELSE dl_uploaded := 'NO';
      END IF;
      ELSIF ssc_INOUT = 'OUT'
        THEN dl_uploaded := 'NA ITS OUT FILE'; 
       END IF; 
end loop;

INSERT INTO temp_table VALUES (ssc_BRAND,ssc_MODULE,ssc_expected_file,exp_Expected_file_name,act_actual_format,ss_status,dl_uploaded,ssc_FILECREATE_DAYSBEHIND) ; 

close cur_download_logs_dl;
end loop;
close cur_systemcheck_config_scc;


OPEN v_cursor FOR
SELECT brand, module,exp_full_filename, Exp_filename, Latest_filename, status,upload,FILECREATE_DAYSBEHIND FROM temp_table ;--temp_table;
return v_cursor;
END F_HEALTHCHECK_HC; 
------------------
------------------
function F_GETMODULE_HC (filename in varchar) return varchar2 is
  v_result varchar2(200);
 cursor systemcheck_config_pos is
  with sq as 
(
select case when 
substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is not null 
and 
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is not null
  then 
  replace((replace(filefix, substr(filefix,(instr(filefix,'<#',1)), instr(filefix, '>',1)-(instr(filefix,'<#',1))+1),'%'))
, substr(filefix,(instr(filefix,'<##',1)), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)-1)),'%' )
when substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is null
and
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is null
  then 'Date/Time format is not present'
when 
substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is not null 
and 
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is null
  then
  replace(filefix, substr(filefix,(instr(filefix,'<#',1)), instr(filefix, '>',1)-(instr(filefix,'<#',1))+1),'%') 
when 
substr(filefix,(instr(filefix,'<#',1)+2), instr(filefix, '>',1)-(instr(filefix,'<#',1)+2)) is null 
and 
substr(filefix,(instr(filefix,'<##',1)+3), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)+3)) is not null  
  then
  replace(filefix,substr(filefix,(instr(filefix,'<##',1)), instr(filefix, '>',1,2)-(instr(filefix,'<##',1)-1)),'%')
else 'Different_case' end file_prf_suf
,filefix,FILECREATE_DAYSBEHIND,BRAND, MODULE,INOUT,FILECREATE_DAYS
from systemcheck_config)
--------
select BRAND, MODULE,filefix,file_prf_suf,
       instr(file_prf_suf,'%',1,1) pre_pos,
       instr(file_prf_suf,'%',1,2) suff_pos,
       instr(file_prf_suf,'%',1,2) - instr(file_prf_suf,'%',1,1) mid_pos,
       substr(file_prf_suf,0,instr(file_prf_suf,'%',1,1)-1 ) pre_Val,
       substr(file_prf_suf,instr(file_prf_suf,'%',1,1)+1,(instr(file_prf_suf,'%',1,2) - instr(file_prf_suf,'%',1,1))-1 ) mid_Val,
       substr(file_prf_suf,instr(file_prf_suf,'%',1,2)+1 ,length(filefix)-instr(file_prf_suf,'%',1,2) ) suff_Val
from sq;
v_file_prf_suf systemcheck_config.FILEFIX%TYPE;
v_filefix systemcheck_config.FILEFIX%TYPE;
v_BRAND systemcheck_config.FILEFIX%TYPE;
v_MODULE systemcheck_config.FILEFIX%TYPE;
v_pre_pos systemcheck_config.FILEFIX%TYPE;
v_suff_pos systemcheck_config.FILEFIX%TYPE;
v_mid_pos systemcheck_config.FILEFIX%TYPE;
v_pre_Val systemcheck_config.FILEFIX%TYPE;
v_mid_Val systemcheck_config.FILEFIX%TYPE;
v_suff_Val systemcheck_config.FILEFIX%TYPE;
v_filename systemcheck_config.FILEFIX%TYPE;
ret_module systemcheck_config.FILEFIX%TYPE;
begin
  open systemcheck_config_pos;
  loop
    fetch systemcheck_config_pos into v_BRAND, v_MODULE,v_filefix,v_file_prf_suf,v_pre_pos,v_suff_pos,v_mid_pos,v_pre_Val,v_mid_Val,v_suff_Val;
    EXIT WHEN systemcheck_config_pos %notfound;

   v_filename:=  substr(filename,0,instr(v_file_prf_suf,'%',1,1)-1 );
   --dbms_output.put_line(v_pre_Val);
   if v_pre_Val = v_filename then v_result:= v_MODULE;
   -- return(v_result);
    ELSIF filename is null then v_result := 'File name is not present';
   -- ELSIF v_pre_Val <> v_filename THEN  v_result:= 'No module for the file';
    end if; 
    if v_result is null then v_result:= 'No module for the file'; end if;
  end loop;
  --v_result:='Kindly provide the file name';
return(v_result);   
CLOSE systemcheck_config_pos;
end F_GETMODULE_HC;
------------------
------------------
procedure P_UPDSTATUS_HC(filename in varchar2, z out varchar2) is
 y varchar2(200);

begin
 --  z:='TE1_AU_00001T_';
    select F_GETMODULE_HC(filename) into y from dual; --file_mod_check(filename)
   --'File name is not present'
  -- 'No module for the file'
   if y <> 'No module for the file'     
     then 
       if y <> 'File name is not present'
         then
           
           insert into systemstatus (brand,module,value,insertedon)
           values ('BUN',y,filename,sysdate);
           dbms_output.put_line(filename||'file has been inserted to the systemstatus table having module as '||y);
           commit;
            IF SQL%ROWCOUNT = 0 THEN
      -- Handle the case where no rows were updated
      DBMS_OUTPUT.PUT_LINE('No rows updated.');     
    END IF;
       end if;
   end if; 
   if y in ('No module for the file','File name is not present') then z:=y;
   else z:= filename||'file has been inserted to the systemstatus table having module as '||y;
   end if;
end P_UPDSTATUS_HC;

end PKG_HEALTHCHECK_HC;

/
/