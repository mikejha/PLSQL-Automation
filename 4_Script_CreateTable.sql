-- Create table
create table SYSTEMSTATUS
(
  brand      VARCHAR2(20),
  module     VARCHAR2(20),
  attribute  VARCHAR2(100),
  value      VARCHAR2(100),
  insertedon DATE
)
tablespace USERS
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
/