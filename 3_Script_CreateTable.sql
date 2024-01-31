-- Create table
create table SYSTEMCHECK_CONFIG
(
  brand                 VARCHAR2(50),
  module                VARCHAR2(50),
  filefix               VARCHAR2(100),
  inout                 VARCHAR2(10),
  filecreate_daysbehind NUMBER,
  filecreate_days       VARCHAR2(20),
  filecreate_hour       NUMBER
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