if (object_id('report.call_all_manual_proc2', 'P') is not null)
    drop proc report.call_all_manual_proc2;
go
if (object_id('report.call_all_manual_proc2', 'P') is not null)
    drop proc report.call_all_manual_proc2;
go
CREATE PROC [report].[call_all_manual_proc2] AS
Declare @v_day_id int=20160512;
Declare @v_bus_pv_tmp_tab_name varchar(64)='report.bus_pv_tmp_'+convert(varchar(20),@v_day_id);
Declare @v_train_pv_tmp_tab_name varchar(64)='report.train_pv_tmp_'+convert(varchar(20),@v_day_id);
--初始化当天的数据表
exec [report].[crt_pv_tmp_proc_1] @day_id,@v_src_pv_tab_name;
--大巴注册相关
exec [report].[bus_user_registration_proc2] @day_id,@v_bus_pv_tmp_tab_name;
--电影专场
exec [report].[movie_click_proc2] @day_id,@v_train_pv_tmp_tab_name;
--东方头条
exec [report].[east_headline_proc2] @day_id,@v_train_pv_tmp_tab_name;
--火车注册相关
exec report.train_user_registration_part_about_proc2 @day_id,@v_train_pv_tmp_tab_name;
--广告点击
exec [report].[ad_click_proc2] @v_day_id,@v_train_pv_tmp_tab_name,@v_bus_pv_tmp_tab_name
