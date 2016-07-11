if (object_id('report.user_about_proc2', 'P') is not null)
    drop proc report.user_about_proc2;
go
CREATE PROC [report].[user_about_proc2] @day_id [int],@p_train_pv_tmp_tab_name [varchar](64),@p_bus_pv_tmp_tab_name [varchar](64) AS

Declare @bus_user_about_tmp_tab_name varchar(64) = '';
set @bus_user_about_tmp_tab_name='report.bus_user_about_'+convert(varchar(20),@day_id);
Declare @train_user_about_tmp_tab_name varchar(64) = '';
set @train_user_about_tmp_tab_name='report.train_user_about_'+convert(varchar(20),@day_id);
Declare @tmp_sql nvarchar(1024)='';

IF OBJECT_ID(@train_user_about_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@train_user_about_tmp_tab_name) ;

IF OBJECT_ID(@bus_user_about_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@bus_user_about_tmp_tab_name) ;

set @tmp_sql=' create table '+@train_user_about_tmp_tab_name +
  '( item nvarchar(128),t_order int,user_cnt int,click_cnt int)WITH
  (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(item))'
  print @tmp_sql
exec(@tmp_sql);

set @tmp_sql='create table '+@bus_user_about_tmp_tab_name +
    '( item nvarchar(128),t_order int,device_cnt int)WITH
    (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(item))'
    print @tmp_sql
exec(@tmp_sql);


set @tmp_sql='insert into  '+@train_user_about_tmp_tab_name+'  SELECT N''连接wifi用户量'' item,1 ,COUNT(DISTINCT p.httpUri) user_cnt,COUNT(DISTINCT(p.dmac)) device_cnt
FROM '+@p_train_pv_tmp_tab_name+ ' p WHERE p.page=''onwifi''';
  print @tmp_sql
exec(@tmp_sql);

set @tmp_sql='insert into  '+@train_user_about_tmp_tab_name+'  SELECT N''我知道'' item,3,COUNT(DISTINCT p.mac) user_cnt,COUNT(DISTINCT(p.dmac)) device_cnt
FROM '+@p_train_pv_tmp_tab_name+ ' p WHERE p.page=''i_know''';
  print @tmp_sql
exec(@tmp_sql)

set @tmp_sql='insert into  '+@train_user_about_tmp_tab_name+' SELECT N''首页'' item ,4,COUNT(DISTINCT p.mac) user_cnt,COUNT(DISTINCT(p.dmac)) device_cnt
FROM '+@p_train_pv_tmp_tab_name+ ' p WHERE p.page= ''home''';
exec(@tmp_sql)

--大巴
set @tmp_sql='insert into '+@bus_user_about_tmp_tab_name+
  ' SELECT N''连接wifi用户量'' item,1,COUNT(DISTINCT(p.dmac)) device_cnt
  FROM '+@p_bus_pv_tmp_tab_name+ ' p';
  print @tmp_sql
  exec(@tmp_sql);

set @tmp_sql='insert into '+@bus_user_about_tmp_tab_name+' SELECT N''欢迎页弹出用户量'' item,2,COUNT(DISTINCT(p.dmac)) device_cnt
FROM '+@p_bus_pv_tmp_tab_name+ ' p where p.page=''welcome''';
  print @tmp_sql
exec(@tmp_sql);

set @tmp_sql='insert into '+@bus_user_about_tmp_tab_name+' SELECT N''我知道'' item,3,COUNT(DISTINCT(p.dmac)) device_cnt
FROM '+@p_bus_pv_tmp_tab_name+ ' p where p.page = ''i_know''';
  print @tmp_sql
exec(@tmp_sql)

set @tmp_sql='insert into '+@bus_user_about_tmp_tab_name+' SELECT N''首页用户量'' item,4,COUNT(DISTINCT(p.dmac)) device_cnt
FROM '+@p_bus_pv_tmp_tab_name+ ' p WHERE p.page= ''home''';
print @tmp_sql
exec(@tmp_sql);

GO
