CREATE PROC [report].[east_headline_proc2] @day_id [int],@p_train_pv_tmp_tab_name [varchar](64) AS
Declare @east_headline_tmp_tab_name varchar(64) = '';
DECLARE @PointerPrev int = 0;
DECLARE @PointerCurr int = 0;
DECLARE @TId varchar(64) = '';
DECLARE @ID varchar(1024) = 'boxshow_dftt,code_dftt,regist_dftt,re_success_dftt,re_error_dftt,close_dftt,online_dftt,online_error_dftt,';
DECLARE @PointerPrev2 int = 0;
DECLARE @PointerCurr2 int = 0;
DECLARE	@T_NAME nvarchar(64) = '';
DECLARE	@NAME nvarchar(1024) = N'广告页加载,获取验证码,认证按钮,认证成功,认证失败,稍后认证,上网成功,上网失败,';
Declare @v_t_order int = 0;
Declare @tmp_sql nvarchar(1024)='';

set @east_headline_tmp_tab_name='report.east_headline_'+convert(varchar(20),@day_id);

IF OBJECT_ID(@east_headline_tmp_tab_name, 'U') IS NOT NULL
  exec ('drop table '+@east_headline_tmp_tab_name) ;


set @tmp_sql='create table '+@east_headline_tmp_tab_name+'(
     east_headline_auth nvarchar(64),t_order int,user_cnt int,click_cnt int)
	 WITH (CLUSTERED COLUMNSTORE INDEX,DISTRIBUTION = HASH(east_headline_auth))';

    exec(@tmp_sql)
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
     			set @tmp_sql='insert into '+@east_headline_tmp_tab_name+' select N'''+@T_NAME+''','+convert(varchar(3),@v_t_order)+',COUNT(DISTINCT(p.mac)) ,COUNT(*) from '
				+@p_train_pv_tmp_tab_name+' p where p.page='''+@TID+'''';
				--print @tmp_sql
				exec(@tmp_sql)
				SET @PointerPrev = @PointerCurr+1
				SET @PointerPrev2 = @PointerCurr2+1
			End
        else
            Break
    End
