if (object_id('report.crt_pv_tmp_proc2', 'P') is not null)
    drop proc report.crt_pv_tmp_proc2;
go
CREATE PROC [report].[crt_pv_tmp_proc2] @day_id [int],@p_src_pv_tab_name [varchar](64) AS
Declare  @pv_tmp_tab_name varchar(64)='[report].[pv_tmp_'+convert(varchar(20),@day_id)+']';
Declare  @train_pv_tmp_tab_name varchar(64)='report.train_pv_tmp_'+convert(varchar(20),@day_id);
Declare  @bus_pv_tmp_tab_name varchar(64)='report.bus_pv_tmp_'+convert(varchar(20),@day_id);
Declare  @train_page_click_tmp_tab_name varchar(64)='report.train_page_click_tmp_'+convert(varchar(20),@day_id);
Declare  @bus_page_click_tmp_tab_name varchar(64)='report.bus_page_click_tmp_'+convert(varchar(20),@day_id);

Declare @tmp_sql varchar(8000)='';

/*
IF OBJECT_ID(''+@pv_tmp_tab_name+'', 'U') IS NOT NULL
  exec('drop table '+@pv_tmp_tab_name);
IF OBJECT_ID(''+@train_pv_tmp_tab_name+'', 'U') IS NOT NULL
  exec('drop table '+@train_pv_tmp_tab_name) ;
IF OBJECT_ID(''+@bus_pv_tmp_tab_name+'', 'U') IS NOT NULL
  exec('drop table '+@bus_pv_tmp_tab_name) ;
*/
IF OBJECT_ID(''+@train_page_click_tmp_tab_name+'', 'U') IS NOT NULL
  exec('drop table '+@train_page_click_tmp_tab_name) ;
IF OBJECT_ID(''+@bus_page_click_tmp_tab_name+'', 'U') IS NOT NULL
  exec('drop table '+@bus_page_click_tmp_tab_name) ;


set @tmp_sql='create table '+ @pv_tmp_tab_name +' WITH
(CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(dmac))
as SELECT
case when httpUri LIKE ''/doHeartbeatRetrieve.php?click_url=onwifi%'' then ''onwifi''
when httpUri like ''%click_url=wifi%'' then ''freewifi''
when httpUri like ''%bootstrap.html%'' then ''welcome''
when httpUri like ''%click_url=i_know%'' then ''i_know''
when httpUri like ''%click_url=home%'' then ''home''
when httpUri like ''%click_url=boxshow_dftt_train%'' then ''boxshow_dftt''
when httpUri like ''%click_url=code_dftt_train%'' then ''code_dftt''
when httpUri like ''%click_url=regist_dftt_train%'' then ''regist_dftt''
when httpUri like ''%click_url=re_success_dftt_train%'' then ''re_success_dftt''
when httpUri like ''%click_url=re_error_dftt_train%'' then ''re_error_dftt''
when httpUri like ''%click_url=close_dftt_train%'' then ''close_dftt''
when httpUri like ''%click_url=online_dftt_train%'' then ''online_dftt''
when httpUri like ''%click_url=online_error_dftt_train%'' then ''online_error_dftt''
when httpUri like ''%click_url=movie-detail/%/%'' then ''movie-detail''
when httpUri like ''%click_url=audio/%/%'' then ''audio-detail''
when httpUri like ''%click_url=novel-detail/%/%'' then ''novel-detail''
when httpUri like ''%click_url=article-detail/%/%'' then ''article-detail''
when httpUri like ''%click_url=wifi_bus%'' then ''wifi_bus''
when httpUri like ''%click_url=code_bus%'' then ''code_bus''
when httpUri like ''%click_url=close_bus%'' then ''close_bus''
when httpUri like ''%click_url=success_bus%'' then ''success_bus''
when httpUri like ''%click_url_banner_id=5768537e1aa0473f9228593be14319b8%'' then ''h5_banner''
when httpUri like ''%click_h5_id=d761ade194d24284889b244270c11a18%'' then ''h5_2048''
when httpUri like ''%click_h5_id=5c58438cb7174b5b952e7e9182d81a77%'' then ''h5_zuqiu''
when httpUri like ''%click_url=h5game_2048_loading&h5gameid=2%'' then ''h5game_2048''
when httpUri like ''%click_url=h5game_zuqiu_loading&h5gameid=1%'' then ''h5game_zuqiu''
when httpUri like ''%click_url=h5game_2048_start&h5gameid=2%'' then ''h5game_2048_start''
when httpUri like ''%click_url=h5game_zuqiu_start&h5gameid=1%'' then ''h5game_zuqiu_start''
when httpUri like ''%click_url=boxshow_kjyy_train%'' then ''boxshow_kjyy''
when httpUri like ''%click_url=code_kjyy_train%'' then ''code_kjyy''
when httpUri like ''%click_url=regist_kjyy_train%'' then ''regist_kjyy''
when httpUri like ''%click_url=re_success_kjyy_train%'' then ''re_success_kjyy''
when httpUri like ''%click_url=re_error_kjyy_train%'' then ''re_error_kjyy''
when httpUri like ''%click_url=close_kjyy_train%'' then ''close_kjyy''
when httpUri like ''%click_url=online_kjyy_train%'' then ''online_kjyy''
when httpUri like ''%click_url=online_error_kjyy_train%'' then ''online_error_kjyy''
when httpUri like ''%click_url=play_movie%'' or  httpUri LIKE ''%click_url=movie_play%'' then ''movie_play''
when httpUri like ''%click_url=exchange%'' or  httpUri LIKE ''%click_url=reg_exchange_train%'' then ''exchange''
when httpUri like ''%exchange=get_flow%'' then ''exchange_get_flow''
when httpUri like ''%exchange=ad_load%'' then ''exchange_ad_load''
when httpUri like ''%exchange=ad_reg_success%'' then ''exchange_ad_reg_success''
when httpUri like ''%click_url=movie-detail/%'' then ''exchange_movie-detail''
when httpUri like ''%click_url_banner_id=d0507d6c90e641729d27f8d0a359631f%'' then ''topic_movie_banner''
when httpUri like ''click_url_topic_movie=1483'' then ''topic_movie_1483''
when httpUri like ''%click_url_topic_movie=1498%'' then ''topic_movie_1498''
when httpUri like ''%click_url_topic_movie=1490%'' then ''topic_movie_1490''
when httpUri like ''%click_url_topic_movie=1507%'' then ''topic_movie_1507''
when httpUri like ''%click_url_topic_movie=1493%'' then ''topic_movie_1493''
when httpUri like ''%click_url_topic_movie=1504%'' then ''topic_movie_1504''
when httpUri like ''%click_url_topic_movie=1492%'' then ''topic_movie_1492''
when httpUri like ''%click_url_topic_movie=1510%'' then ''topic_movie_1510''
when httpUri like ''%click_url=movie%'' then ''movie''
when httpUri like ''%click_url=article%'' then ''article''
when httpUri like ''%click_url=novel%'' then ''novel''
when httpUri like ''%click_url=audio%'' then ''audio''
when httpUri like ''%click_url=joke%'' then ''joke''
when httpUri like ''%click_url=game%'' then ''game''
when httpUri like ''%click_url=app%'' then ''app''
when httpUri like ''%page_type=home&index=1%'' then ''page_home_1''
when httpUri like ''%page_type=home&index=2%'' then ''page_home_2''
when httpUri like ''%page_type=home&index=3%'' then ''page_home_3''
when httpUri like ''%page_type=home&index=4%'' then ''page_home_4''
when httpUri like ''%page_type=movie&index=1%'' then ''page_movie_1''
when httpUri like ''%page_type=movie&index=2%'' then ''page_movie_2''
when httpUri like ''%page_type=movie&index=3%'' then ''page_movie_3''
when httpUri like ''%page_type=article&index=1%'' then ''page_article_1''
when httpUri like ''%page_type=novel&index=1%'' then ''page_novel_1''
when httpUri like ''%page_type=novel&index=2%'' then ''page_novel_2''
when httpUri like ''%page_type=audio&index=1%'' then ''page_audio_1''
when httpUri like ''%page_type=audio&index=2%'' then ''page_audio_2''
when httpUri like ''%page_type=joke&index=1%'' then ''page_joke_1''
when httpUri like ''%page_type=app&index=1%'' then ''page_app_1''
when httpUri like ''%page_type=app&index=2%'' then ''page_app_2''
when httpUri like ''%page_type=game&index=1%'' then ''page_game_1''
end as page,
httpUri,
mac,
dmac,
referer,
client_os,
mobile_brand,
client_browser,
day_id
from '+ @p_src_pv_tab_name+
' where day_id ='+convert(varchar(20),@day_id)
--print @tmp_sql
--exec(@tmp_sql)

set @tmp_sql='create table '+@train_pv_tmp_tab_name+' WITH
(CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = HASH(dmac))
as SELECT *
from '+@pv_tmp_tab_name+' p
where p.dmac like ''GD200%'''
--print @tmp_sql
--sexec(@tmp_sql);


set @tmp_sql='create table '+ @train_page_click_tmp_tab_name +' WITH
  (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(page))
  as SELECT page,COUNT(DISTINCT(mac)) user_cnt,count(*) click_cnt from '+@train_pv_tmp_tab_name
  +' group by page';
  print @tmp_sql
  exec(@tmp_sql);

set @tmp_sql='create table '+@bus_pv_tmp_tab_name+' WITH
(CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = HASH(dmac))
from '+@pv_tmp_tab_name+' p
where p.dmac not like ''GD200%''';
--print @tmp_sql
--exec(@tmp_sql);


set @tmp_sql='create table '+ @bus_page_click_tmp_tab_name +' WITH
  (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(page))
  as SELECT page,COUNT(DISTINCT(mac)) user_cnt,count(*) click_cnt from '+@bus_pv_tmp_tab_name
  +' group by page'
  print @tmp_sql
  exec(@tmp_sql);

-- drop table pv_tmpywx;
