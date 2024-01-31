-- Create table
create table TEMP_TABLE
(
  brand                 VARCHAR2(225),
  module                VARCHAR2(225),
  exp_full_filename     VARCHAR2(225),
  exp_filename          VARCHAR2(225),
  latest_filename       VARCHAR2(225),
  status                VARCHAR2(100),
  upload                VARCHAR2(225),
  filecreate_daysbehind VARCHAR2(50)
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