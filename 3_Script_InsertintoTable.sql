select * from SYSTEMCHECK_CONFIG
INSERT INTO SYSTEMCHECK_CONFIG (
    brand,
    module,
    filefix,
    inout,
    filecreate_daysbehind,
    filecreate_days,
    filecreate_hour
) --VALUES
with names as (
select 'MYER', 'CLAIM', 'TC1_AU_00001T_<#YYYYMMDD>_<##HH24MISS>.xml', 'OUT', 0, 'D-1,2,3,4,5,6,7', 19 FROM dual union all
select 'MYER', 'TEST', 'TE1_AU_00001T_<#YYYYMMDD><##HH24MISS>.xml', 'OUT', 0, 'M-10,15,12', 12 FROM dual union all
select 'MYER', 'SUPPLIERS', 'SP1_AU_00001T_<#YYYYMMDD><##HH24MISS>.xml', 'IN', 0, 'W-3,4,5', 19 FROM dual union all
select 'MYER', 'STORES', 'ST1_AU_00001T_<#YYYYMMDD><##HH24MISS>.xml', 'IN', 0, 'D-1,2,3,4,5,6,7', 19 FROM dual union all
select 'MYER', 'BUNASNS', 'AS1_AU_00001T_<#YYYYMMDD><##HH24MISS>.xml', 'IN', 0, 'M-10,3,30', 19 FROM dual union all
select 'MYER', 'ITEMS', 'PD1_AU_00001T_<#YYYYMMDD><##HH24MISS>.xml', 'IN', 0, 'W-7,1', 19 FROM dual union all
select 'MYER', 'SCAN_NOTICE', 'SN1_AU_00001T_<#YYYYMMDD>_<##HH24MISS>.xml', 'OUT', 0, 'D-1,2,3,4,5,6,7', 19 FROM dual union all
select 'MYER', 'TEST1', 'TE11_AU_00001T_<#YYYYMMDD>_TEST_<##HH24MISS>.TXT', 'OUT', 2, 'M-12,17,16', 12 FROM dual union all
select 'MYER', 'TEST2', 'TE11_AU_00001T_.TXT', 'OUT', 1, 'W-1', 12 FROM dual union all
select 'MYER', 'TEST3', 'ABCD', 'OUT', 1, 'D-1,2,3,4,5,6,7', 12 FROM dual union all
select 'MYER', 'TEST4', '_.TXTT', 'OUT', 1, 'M-1,2,3,10', 12 FROM dual union all
select 'MYER', 'TEST5', 'ABC<><><>_.TXTT', 'OUT', 1, 'W-5,2', 12 FROM dual union all
select 'MYER', 'TEST6', 'ABC/,@12M``=-/_.TXTT', 'OUT', 1, 'D-1,2,3,4,5,6,7', 12 FROM dual union all
select 'MYER', 'TEST7', '><_.TXTT', 'OUT', 1, 'M-8,10', 12 FROM dual union all
select 'MYER', 'TEST8', '>_____<________.TXTT', 'OUT', 1, 'W-3', 12 FROM dual union all
select 'MYER', 'TEST9', '>_____<_______<_.TXTT', 'OUT', 1, 'D-1,2,3,4,5,6,7', 12 FROM dual union all
select 'MYER', 'TEST10', 'TEST!<_<#YYYYMMDD>MIDDLE<!<##HH24MISS>.xmlL', 'OUT', 6, 'M-15', 12 FROM dual union all
select 'MYER', 'TEST11', 'TEST!<_<#YYYYMM>MIDDLE<<##HH24MISS>.xmlL', 'OUT', 6, 'W-2', 12 FROM dual union all
select 'MYER', 'TEST12', '<#YYYYMM><##HH24MISS>.xml', 'OUT', 6, 'D-1,2,3,4,5,6,7', 12 FROM dual union all
select 'MYER', 'T1', 'T1_<#YYYYMM>_TEST_<##HH24MISS>.xml', 'OUT', 6, 'M-10,15,12', 12 FROM dual union all
select 'MYER', 'T2', 'T2._<#YYYYMM>_TEST2_<##HH24MISS>..xml', 'OUT', 10, 'Y-12,1', 12 FROM dual union all
select 'MYER', 'DEC1', 'DEC1_<#YYYYMMDD>__DEC1___<##HH24MISS>.xml', 'OUT', 0, 'D-1,2,3,4,5,6,7', 19 FROM dual union all
select 'MYER', 'DEC2', 'DEC2_<#YYYYMM>__DEC2___<##HH24MISS>.xml', 'OUT', 0, 'D-1,2,3,4,5,6,7', 19 FROM dual union all
select 'MYER', 'DEC2', 'DEC2_<#YYYYMM>__DEC2___<##HH24MISS>.xml', 'OUT', 0, 'D-1,2,3,4,5,6,7', 19 FROM dual union all
select 'MYER', 'DEC3', 'DEC3_<#YYYYMM><##HH24MISS>.xml', 'OUT', 0, 'D-1,2,3,4,5,6,7', 19 FROM dual union all
select 'MYER', 'DEC4', 'DEC4_<#YYYYMM>_______<##HH24MISS>.xml', 'OUT', 0, 'M-8,10,15,12,7', 19 FROM dual union all
select 'MYER', 'JAN17', 'JANTEST123<#YYYYMM>_______<##HH24MISS>.xml', 'IN', 1, 'M-4,8,10,15,12,17', 19 FROM dual union all
select 'MYER', 'INSERT', 'INSERTTEST1<#YYYYMM>_______<##HH24MISS>.xml', 'OUT', 0, 'M-4,8,10,15,18,12,7', 19 FROM dual
           )  
select * from names