exec report.call_all_manual_proc2
--select * from report.bus_user_registration_20160701
--select * from report.movie_click_20160701
select top 10 * from report.train_ad_click_20160512
  exec report.crt_pv_tmp_proc2 20160701,'[hbase].[device_log_pv_base_2016]'
  select top 10 * from train_page_click_20160701
    select top 10 * from bus_page_click_20160701
--exec report.ad_click_proc2 20160707,'report.train_pv_tmp_20160707','report.bus_pv_tmp_20160707'

report.call_all_auto_proc2 20160512
exec [report].[user_about_proc2] 20160512,'report.train_pv_tmp_20160512','report.bus_pv_tmp_20160512'
select top 10 * from report.train_user_about_20160512

exec report.movie_play_cnt_proc2 20160512,'report.train_pv_tmp_20160512','report.bus_pv_tmp_20160512'

exec report.lan_game_proc2 20160512,'report.train_pv_tmp_20160512'
