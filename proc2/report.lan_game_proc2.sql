if (object_id('report.lan_game_proc2', 'P') is not null)
    drop proc report.lan_game_proc2;
go
CREATE PROC [report].[lan_game_proc2] @day_id [int],@p_train_pv_tmp_tab_name [varchar](64) AS
Declare @lan_game_tmp_tab_name varchar(64) = '';
DECLARE @PointerPrev int = 0;
DECLARE @PointerCurr int = 0;
DECLARE @TId varchar(64) = 0;
DECLARE @ID varchar(1024) = 'h5_banner,h5_2048,h5_zuqiu,h5game_2048,h5game_zuqiu,h5game_2048_start,h5game_zuqiu_start,';
DECLARE @PointerPrev2 int = 0;
DECLARE @PointerCurr2 int = 0;
DECLARE	@T_NAME nvarchar(1024) = '';
Declare @v_t_order int =0;
Declare @tmp_sql nvarchar(1024) = '';
DECLARE	@NAME nvarchar(1024) = N'游戏banner点击,游戏列表页2048开始点击,游戏列表页滚滚足球开始点击,2048游戏加载,滚滚足球游戏加载,2048游戏页面开始点击,滚滚足球游戏页面开始点击,';

set @lan_game_tmp_tab_name='report.lan_game_'+convert(varchar(20),@day_id);

IF OBJECT_ID(@lan_game_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@lan_game_tmp_tab_name) ;

-- 游戏banner点击

exec('create table '+@lan_game_tmp_tab_name+'(game_name nvarchar(255),t_order int,user_cnt int,click_cnt int)WITH
(CLUSTERED COLUMNSTORE INDEX,
DISTRIBUTION = HASH(game_name))');

    Set @PointerPrev=1;
	Set @PointerPrev2=1;
    while (@PointerPrev < LEN(@ID))
    Begin
        Set @PointerCurr=CharIndex(',',@ID,@PointerPrev);
		SET @PointerCurr2=CharIndex(',',@NAME,@PointerPrev2);
        if(@PointerCurr>0)
			Begin
      	set @v_t_order+=1;
				set @TId=SUBSTRING(@ID,@PointerPrev,@PointerCurr-@PointerPrev)
				set @T_NAME=SUBSTRING(@NAME,@PointerPrev2,@PointerCurr2-@PointerPrev2)
     		    set @tmp_sql='insert into '+@lan_game_tmp_tab_name+' select N'''+@T_NAME+''','+convert(varchar(3),@v_t_order)+',COUNT(DISTINCT(p.mac)) ,COUNT(*) from '
				+@p_train_pv_tmp_tab_name+' p where  p.page='''+@TID+''''
				exec(@tmp_sql)
				SET @PointerPrev = @PointerCurr+1
				SET @PointerPrev2 = @PointerCurr2+1
			End
        else
            Break
    End
GO
