if (object_id('report.game_app_click_proc2', 'P') is not null)
    drop proc report.game_app_click_proc2;
go
CREATE PROC [report].[game_app_click_proc2] @day_id [int],@p_train_pv_tab_name [varchar](64),@p_bus_pv_tab_name [varchar](64) AS
DECLARE @bus_game_app_click_tab_name varchar(64)='report.bus_game_app_click_tmp_'+convert(varchar(20),@day_id);
DECLARE @train_game_app_click_tab_name varchar(64)='report.train_game_app_click_tmp_'+convert(varchar(20),@day_id);
Declare @tmp_sql varchar(1024)='';

IF OBJECT_ID(@bus_game_app_click_tab_name, 'U') IS NOT NULL
exec ('drop table '+@bus_game_app_click_tab_name) ;
IF OBJECT_ID(@train_game_app_click_tab_name, 'U') IS NOT NULL
exec ('drop table '+@train_game_app_click_tab_name) ;


--火车 游戏内容
exec('create table '+@train_game_app_click_tab_name+ '(id varchar(128),t_order int,user_cnt int,click_cnt int,content_type int) WITH
(CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = HASH(id))');

set @tmp_sql='insert into  '+@train_game_app_click_tab_name+'
   select app.id1 id,1,count(distinct mac) user_cnt,count(*) click_cnt ,0  content_type from '+ @p_train_pv_tab_name+
   '  p,(select a.id1 from base.test1 a) app
	WHERE p.httpUri like ''%click_app_id=''+app.id1+''%'' and substring(p.httpUri,charindex(''click_app_id='',p.httpUri)+13,3) = app.id1 group by app.id1';
--print @tmp_sql
exec(@tmp_sql);
--火车 应用内容
set @tmp_sql='insert into  '+@train_game_app_click_tab_name+
    ' select app.id1 id,2,count(distinct mac) user_cnt,count(*) click_cnt,1 content_type from '+ @p_train_pv_tab_name+' p,
	(select a.id1 from base.test2 a) app
	WHERE  p.httpUri like ''%click_app_id=''+app.id1+''%''
	and substring(p.httpUri,charindex(''click_app_id='',p.httpUri)+13,3) = app.id1
	group by app.id1 ';
  --print @tmp_sql
  exec(@tmp_sql)
--大巴 游戏内容

set @tmp_sql='create table '+@bus_game_app_click_tab_name+
 '(id varchar(128),t_order int,user_cnt int,click_cnt int,content_type int) WITH(CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(id))';
--print @tmp_sql
exec(@tmp_sql)

set @tmp_sql='insert into '+@bus_game_app_click_tab_name+' select app.id1 id,1,count(distinct mac) user_cnt,count(*) click_cnt ,0  content_type from '
  + @p_bus_pv_tab_name+' p, (select a.id1 from base.test1 a) app
	WHERE p.httpUri like ''%click_app_id=''+app.id1+''%''
	and substring(p.httpUri,charindex(''click_app_id='',p.httpUri)+13,3) = app.id1
	group by app.id1 ';
  --print @tmp_sql
  exec(@tmp_sql);
--大巴应用内容
set @tmp_sql='insert into '+@bus_game_app_click_tab_name+
    ' select app.id1 id,2,count(distinct mac) user_cnt,count(*) click_cnt,1 content_type from '+ @p_bus_pv_tab_name+' p,
	(select a.id1 from base.test2 a) app WHERE  p.httpUri like ''%click_app_id=''+app.id1+''%''
	and substring(p.httpUri,charindex(''click_app_id='',p.httpUri)+13,3) = app.id1 group by app.id1';

  --print @tmp_sql
  exec(@tmp_sql);
