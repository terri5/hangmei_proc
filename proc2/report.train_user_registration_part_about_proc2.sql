CREATE PROC [report].[train_user_registration_part_about_proc2] @day_id [int],@p_train_pv_tmp_tab_name [varchar](64) AS
Declare @train_user_registration_part_tmp_tab_name varchar(64) = '';
DECLARE @PointerPrev int = 0;
DECLARE @PointerCurr int = 0;
DECLARE @TId varchar(64) = 0;
DECLARE @KEYS varchar(1024) = 'exchange,exchange_get_flow,exchange_ad_load,exchange_ad_reg_success,exchange_movie-detail,';
DECLARE @PointerPrev2 int = 0;
DECLARE @PointerCurr2 int = 0;
DECLARE	@T_NAME nvarchar(1024) = '';
DECLARE	@_VALUES nvarchar(1024) = N'任务b23anner,立即领取流量,广告页加载,广告注册成功,视频点击总人数,';

Declare @v_t_order int = 0;
Declare @tmp_sql nvarchar(1024)=''

set @train_user_registration_part_tmp_tab_name='report.train_user_registration_part_'+convert(varchar(20),@day_id);

IF OBJECT_ID(@train_user_registration_part_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@train_user_registration_part_tmp_tab_name);

exec('create table '+@train_user_registration_part_tmp_tab_name+'(
      item nvarchar(128),t_order int,user_cnt int,click_cnt int
	  )WITH
	  (CLUSTERED COLUMNSTORE INDEX,
		DISTRIBUTION = HASH(item)) ');

    Set @PointerPrev=1;
	Set @PointerPrev2=1;
    while (@PointerPrev < LEN(@KEYS))
    Begin
        Set @PointerCurr=CharIndex(',',@KEYS,@PointerPrev);
		SET @PointerCurr2=CharIndex(',',@_VALUES,@PointerPrev2);
        if(@PointerCurr>0)
			Begin
			    set @v_t_order+=1;
				set @TId=SUBSTRING(@KEYS,@PointerPrev,@PointerCurr-@PointerPrev)
				set @T_NAME=SUBSTRING(@_VALUES,@PointerPrev2,@PointerCurr2-@PointerPrev2)
     			set @tmp_sql='insert into '+@train_user_registration_part_tmp_tab_name+' select N'''+@T_NAME+''','+convert(varchar(3),@v_t_order)+',COUNT(DISTINCT(p.mac)) ,COUNT(*) from '
				+@p_train_pv_tmp_tab_name+' p where  p.page='''+@TID+'''';
                --print @tmp_sql
				exec(@tmp_sql)
				SET @PointerPrev = @PointerCurr+1
				SET @PointerPrev2 = @PointerCurr2+1
			End
        else
            Break
    End
	/*
    --删除最后一个,因为最后一个后面没有逗号,所以在循环中跳出,需另外再删除
     set @TId=cast(SUBSTRING(@KEYS,@PointerPrev,LEN(@KEYS)-@PointerPrev+1) as int)
     Delete from News where ID=@TID
	 */
