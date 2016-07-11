CREATE PROC [report].[movie_click_proc2] @day_id [int],@p_train_pv_tmp_tab_name [varchar](64) AS
Declare @movie_click_tmp_tab_name varchar(64) = '';
DECLARE @PointerPrev int = 0;
DECLARE @PointerCurr int = 0;
DECLARE @TId nvarchar(64) = 0;
DECLARE @ID varchar(1024) = 'topic_movie_banner,topic_movie_1483,topic_movie_1498,topic_movie_1490,topic_movie_1507,topic_movie_1493,topic_movie_1504,topic_movie_1492,topic_movie_1510,';
DECLARE @PointerPrev2 int = 0;
DECLARE @PointerCurr2 int = 0;
DECLARE	@T_NAME nvarchar(64) = '';
Declare @tmp_sql nvarchar(1024) = '';
Declare @v_t_order int = 0;
DECLARE	@MOVIE_NAME nvarchar(1024) = N'点击首页专场电影banner,玻璃樽,嫁个有钱人,精装追女仔,浪漫樱花,玻璃之城,别恋,夏日么么茶,单身男女,';

set @movie_click_tmp_tab_name='report.movie_click_'+convert(varchar(20),@day_id);

IF OBJECT_ID(@movie_click_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@movie_click_tmp_tab_name) ;


set @tmp_sql='create table '+@movie_click_tmp_tab_name+'(
      movie_name nvarchar(128),t_order int,user_cnt int,click_cnt int
	  )WITH
	  (CLUSTERED COLUMNSTORE INDEX,
		DISTRIBUTION = HASH(movie_name))';

exec(@tmp_sql)

    Set @PointerPrev=1;
	Set @PointerPrev2=1;
    while (@PointerPrev < LEN(@ID))
    Begin
        Set @PointerCurr=CharIndex(',',@ID,@PointerPrev);
		SET @PointerCurr2=CharIndex(',',@MOVIE_NAME,@PointerPrev2);
        if(@PointerCurr>0)
			Begin
			    set @v_t_order+=1;
				set @TId=SUBSTRING(@ID,@PointerPrev,@PointerCurr-@PointerPrev)
				set @T_NAME=SUBSTRING(@MOVIE_NAME,@PointerPrev2,@PointerCurr2-@PointerPrev2)
     			set @tmp_sql='insert into '+@movie_click_tmp_tab_name+' select N'''+@T_NAME+''','+convert(varchar(3),@v_t_order)+',COUNT(DISTINCT(p.mac)) ,COUNT(*) from '
				    +@p_train_pv_tmp_tab_name+' p where p.page='''+@TID+'''';
                 exec(@tmp_sql)
				SET @PointerPrev = @PointerCurr+1
				SET @PointerPrev2 = @PointerCurr2+1
			End
        else
            Break
    End
	/*
    --删除最后一个,因为最后一个后面没有逗号,所以在循环中跳出,需另外再删除
     set @TId=cast(SUBSTRING(@ID,@PointerPrev,LEN(@ID)-@PointerPrev+1) as int)
     Delete from News where ID=@TID
	 */
