if (object_id('report.movie_play_cnt_proc2', 'P') is not null)
    drop proc report.movie_play_cnt_proc2;
go
CREATE PROC [report].[movie_play_cnt_proc2] @day_id [int],@p_train_pv_tmp_tab_name [varchar](64),@p_bus_pv_tmp_tab_name [varchar](64) AS
Declare @bus_movie_play_cnt_tmp_tab_name varchar(64) = 'report.bus_movie_play_cnt_'+convert(varchar(20),@day_id);
Declare @train_movie_play_cnt_tmp_tab_name varchar(64) = 'report.train_movie_play_cnt_'+convert(varchar(20),@day_id);
Declare @CONDTION1 varchar(64)='''%click_url=movie-detail/%/%''';
Declare @CONDTION2 varchar(64)='''%click_url=play_movie%''';
Declare @CONDTION3 varchar(64)='''%click_url=movie_play%''';
Declare @train_sql varchar(1024)='';
Declare @bus_sql varchar(1024)='';
Declare @sql  varchar(1024)='';

IF OBJECT_ID(@bus_movie_play_cnt_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@bus_movie_play_cnt_tmp_tab_name);

IF OBJECT_ID(@train_movie_play_cnt_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@train_movie_play_cnt_tmp_tab_name);


set @sql = 'insert into sp_movie_play_cnt_tab select
    		b.id,
    		count(distinct pv.mac) playUV,
    		count(*) playPV
    	FROM
              _param_pv_tmp_tab pv,
            (
	            SELECT
		            SUBSTRING(p.httpUri,58,4)  id,
		            max(f.vf_file) filePath
		        FROM
		             _param_pv_tmp_tab p,
		             base.cms_video_file f
		        WHERE p.httpUri LIKE _condtion1 and SUBSTRING(p.httpUri,58,4) = cast(f.video_id as varchar(10))
		        group by SUBSTRING(p.httpUri,58,4)
	        ) b
    	WHERE (pv.httpUri LIKE _condtion2 or  pv.httpUri LIKE _condtion3 )
		    and pv.httpUri like  ''%''+b.filepath+''%''
		    GROUP BY b.id ';


set @train_sql= 'create table '+@train_movie_play_cnt_tmp_tab_name +'(id varchar(64),user_cnt int,click_cnt int)
        WITH (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(id) )';
exec(@train_sql);

set @train_sql=REPLACE(@sql,'_param_pv_tmp_tab',@p_train_pv_tmp_tab_name);

set @train_sql= REPLACE(@train_sql,'sp_movie_play_cnt_tab',@train_movie_play_cnt_tmp_tab_name);
set @train_sql=REPLACE(@train_sql,'_condtion1',@CONDTION1);
set @train_sql=REPLACE(@train_sql,'_condtion2',@CONDTION2);
set @train_sql=REPLACE(@train_sql,'_condtion3',@CONDTION3);
exec(@train_sql);

set @bus_sql= 'create table '+@bus_movie_play_cnt_tmp_tab_name+'(id varchar(64),user_cnt int,click_cnt int)
WITH (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(id))'+@bus_sql;
exec(@bus_sql);
set @bus_sql=REPLACE(@sql,'_param_pv_tmp_tab',@p_bus_pv_tmp_tab_name);
set @bus_sql= REPLACE(@bus_sql,'sp_movie_play_cnt_tab',@bus_movie_play_cnt_tmp_tab_name);
set @bus_sql=REPLACE(@bus_sql,'_condtion1',@CONDTION1);
set @bus_sql=REPLACE(@bus_sql,'_condtion2',@CONDTION2);
set @bus_sql=REPLACE(@bus_sql,'_condtion3',@CONDTION3);
exec(@bus_sql);

go
