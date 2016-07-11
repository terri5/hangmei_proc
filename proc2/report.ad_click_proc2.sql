if (object_id('report.ad_click_proc2', 'P') is not null)
    drop proc report.ad_click_proc2;
go
CREATE PROC [report].[ad_click_proc2]  @day_id [int],@p_train_pv_tmp_tab_name [varchar](64),@bus_pv_tab_name [varchar](64) AS 
Declare @train_ad_click_tmp_tab_name varchar(64) = '';
Declare @bus_ad_click_tmp_tab_name varchar(64) = '';
DECLARE @PointerPrev int = 0;
DECLARE @PointerCurr int = 0;


DECLARE @PointerPrev2 int = 0;
DECLARE @PointerCurr2 int = 0;

DECLARE @PointerPrev3 int = 0;
DECLARE @PointerCurr3 int = 0;

DECLARE @TId varchar(64) = '';
DECLARE @T_PAGE_KEY varchar(64) = '';
DECLARE	@T_NAME nvarchar(128) = ''; 
DECLARE	@tmp_sql nvarchar(4000) = '';
DECLARE @v_order int =0 ;
DECLARE @TRAIN_HOME_PAGE_KEYS varchar(1024) = 'page_home_1,page_home_2,page_home_3,page_home_4,page_movie_1,page_movie_2,page_movie_3,page_article_1,page_novel_1,page_novel_2,'+
                                              'page_audio_1,page_audio_2,page_joke_1,page_app_1,page_app_2,page_game_1,';
DECLARE @TRAIN_HOME_INDEX_KEYS varchar(1024) = 'page_type=home&index=1,page_type=home&index=2,page_type=home&index=3,page_type=home&index=4,';
DECLARE	@TRAIN_HOME_VALUES nvarchar(1024) = N'首页第一条广告,首页第二条广告,首页第三条广告,首页第四条广告,';
DECLARE @TRAIN_MOVIE_INDEX_KEYS varchar(1024) = 'page_type=movie&index=1,page_type=movie&index=2,page_type=movie&index=3,';
DECLARE	@TRAIN_MOVIE_VALUES nvarchar(1024) = N'电影第一条广告,电影第二条广告,电影第三条广告,';


DECLARE @TRAIN_OTHER_AD_INDEX_KEYS varchar(1024)='page_type=article&index=1,page_type=novel&index=1,page_type=novel&index=2,page_type=joke&index=1,page_type=audio&index=1,page_type=audio&index=2,page_type=app&index=1,page_type=app&index=2,page_type=game&index=1,'
DECLARE @TRAIN_OTHER_VALUES nvarchar(1024)=N'新闻频道第一条广告,小说频道第一条广告,小说频道第二条广告,笑话频道第一条广告,听书频道第一条广告,听书频道第二条广告,应用频道第一条广告,应用频道第二条广告,游戏第一条广告,'

DECLARE @TRAIN_ALL_AD_NAME_KEYS varchar(1024)=@TRAIN_HOME_INDEX_KEYS+@TRAIN_MOVIE_INDEX_KEYS+@TRAIN_OTHER_AD_INDEX_KEYS;
DECLARE @TRAIN_ALL_AD_NAME_VALUES nvarchar(4000)=@TRAIN_HOME_VALUES+@TRAIN_MOVIE_VALUES+@TRAIN_OTHER_VALUES;

DECLARE @BUS_ALL_KEYS VARCHAR(1024)='page_home_1,page_home_2,page_movie_1,'+
                                    'page_article_1,page_novel_1,page_novel_2,'+
									'page_audio_1,page_joke_1,';
DECLARE @BUS_ALL_VALUES nvarchar(1024)= N'首页第一条广告,首页第二条广告,'+
                                       '电影第一条广告,新闻频道第一条广告,'+
                                      '小说频道第一条广告,小说频道第二条广告,听书频道第一条广告,笑话频道第一条广告,'

set @train_ad_click_tmp_tab_name='report.train_ad_click_'+convert(varchar(20),@day_id);
IF OBJECT_ID(@train_ad_click_tmp_tab_name, 'U') IS NOT NULL 
  exec ('drop table '+@train_ad_click_tmp_tab_name);
  
set @bus_ad_click_tmp_tab_name='report.bus_ad_click_'+convert(varchar(20),@day_id);
IF OBJECT_ID(@bus_ad_click_tmp_tab_name, 'U') IS NOT NULL 
  exec ('drop table '+@bus_ad_click_tmp_tab_name) ;
 
set @tmp_sql='create table '+@train_ad_click_tmp_tab_name+'(
          ad_name nvarchar(128),row_order int,ad_id varchar(128),user_cnt int,click_cnt int
      )WITH 
	  (CLUSTERED COLUMNSTORE INDEX,
		DISTRIBUTION = HASH(ad_name))';

exec(@tmp_sql)

set @tmp_sql='create table '+@bus_ad_click_tmp_tab_name+'(
          ad_name nvarchar(128),row_order int,ad_index varchar(128),user_cnt int ,click_cnt int 
      )WITH 
	  (CLUSTERED COLUMNSTORE INDEX,
		DISTRIBUTION = HASH(ad_name))';
exec(@tmp_sql)
   
     --火车相关
    Set @PointerPrev=1; 
	Set @PointerPrev2=1;  
    Set @PointerPrev3=1;	
    while (@PointerPrev < LEN(@TRAIN_ALL_AD_NAME_KEYS)) 
    Begin 
        Set @PointerCurr=CharIndex(',',@TRAIN_ALL_AD_NAME_KEYS,@PointerPrev); 
		SET @PointerCurr2=CharIndex(',',@TRAIN_ALL_AD_NAME_VALUES,@PointerPrev2);
        SET @PointerCurr3=CharIndex(',',@TRAIN_HOME_PAGE_KEYS,@PointerPrev3); 		
        if(@PointerCurr>0) 
			Begin 
			    set @v_order+=1;
				set @TId=SUBSTRING(@TRAIN_ALL_AD_NAME_KEYS,@PointerPrev,@PointerCurr-@PointerPrev) 
				set @T_NAME=SUBSTRING(@TRAIN_ALL_AD_NAME_VALUES,@PointerPrev2,@PointerCurr2-@PointerPrev2)
				set @T_PAGE_KEY=SUBSTRING(@TRAIN_HOME_PAGE_KEYS,@PointerPrev3,@PointerCurr3-@PointerPrev3)
     			set @tmp_sql='insert into '+@train_ad_click_tmp_tab_name+' select N'''+@T_NAME+''','+convert(varchar(3),@v_order)+',substring(p.httpUri,0,charindex('''+@TId+''',p.httpUri)),COUNT(DISTINCT(p.mac)) ,COUNT(*) from '
				+@p_train_pv_tmp_tab_name+' p where  p.page= '''+@T_PAGE_KEY+''' group by substring(p.httpUri,0,charindex('''+@TId+''',p.httpUri))'
               -- print @tmp_sql
                exec(@tmp_sql)
   
				SET @PointerPrev = @PointerCurr+1 
				SET @PointerPrev2 = @PointerCurr2+1 
				SET @PointerPrev3 = @PointerCurr3+1 
			End 
        else 
            Break 
    End 
	
	  --大巴相关
    Set @PointerPrev=1; 
	Set @PointerPrev2=1;  
	set @v_order=1;  	
    while (@PointerPrev < LEN(@BUS_ALL_KEYS)) 
    Begin 
        Set @PointerCurr=CharIndex(',',@BUS_ALL_KEYS,@PointerPrev); 
		SET @PointerCurr2=CharIndex(',',@BUS_ALL_VALUES,@PointerPrev2); 
        if(@PointerCurr>0) 
			Begin 
			    set @v_order+=1;
				set @TId=SUBSTRING(@BUS_ALL_KEYS,@PointerPrev,@PointerCurr-@PointerPrev) 
				set @T_NAME=SUBSTRING(@BUS_ALL_VALUES,@PointerPrev2,@PointerCurr2-@PointerPrev2)
				set @tmp_sql='insert into '+@train_ad_click_tmp_tab_name+' select N'''+@T_NAME+''','+convert(varchar(3),@v_order)+',COUNT(DISTINCT(p.mac)) user_cnt ,COUNT(*) click_cnt from '
				+@p_train_pv_tmp_tab_name+' p where p.page= '''+@T_PAGE_KEY+'''';
				--print @tmp_sql
     			exec(@tmp_sql); 

				SET @PointerPrev = @PointerCurr+1 
				SET @PointerPrev2 = @PointerCurr2+1 
			End 
        else 
            Break 
    End 

go