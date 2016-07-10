CREATE PROC [report].[bus_user_registration_proc2] @day_id [int],@p_bus_pv_tmp_tab_name [varchar](64) AS
Declare @bus_user_registration_tmp_tab_name varchar(64) = '';
DECLARE @PointerPrev int = 0;
DECLARE @PointerCurr int = 0;
DECLARE @TId varchar(64) = 0;
DECLARE @KEYS varchar(1024) = 'wifi_bus,code_bus,close_bus,success_bus,';
DECLARE @PointerPrev2 int = 0;
DECLARE @PointerCurr2 int = 0;
DECLARE	@T_NAME nvarchar(1024) = '';
DECLARE	@_VALUES nvarchar(1024) = N'免费上网点击_注册往返弹出页用户,免费上网点击_获取验证码点击用户,免费上网点击_稍后验证点击用户,免费上网点击_注册往返成功用户,';
Declare @tmp_sql nvarchar(1020)=''
Declare @v_t_order int = 0;

set @bus_user_registration_tmp_tab_name='report.bus_user_registration_'+convert(varchar(20),@day_id);

IF OBJECT_ID(@bus_user_registration_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@bus_user_registration_tmp_tab_name) ;

-- 点击首页专场电影banner
set @tmp_sql='create table '+@bus_user_registration_tmp_tab_name+'(
      resigter_process nvarchar(128),t_order int,user_cnt int ,click_cnt int
   ) WITH (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(resigter_process))'
exec(@tmp_sql);
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
     			set @tmp_sql='insert into '+@bus_user_registration_tmp_tab_name+' select N'''+@T_NAME+''','+convert(varchar(3),@v_t_order)+',COUNT(DISTINCT(p.mac)) ,COUNT(*) from '
				+@p_bus_pv_tmp_tab_name+' p where  p.page='''+@TID+'''';
				exec(@tmp_sql)
				SET @PointerPrev = @PointerCurr+1
				SET @PointerPrev2 = @PointerCurr2+1
			End
        else
            Break
    End
GO
