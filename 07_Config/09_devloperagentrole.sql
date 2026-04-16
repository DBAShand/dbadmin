USE [msdb]
GO

/****** Object:  DatabaseRole [DeveloperAgentRole]    Script Date: 9/18/2017 1:03:22 PM ******/
CREATE ROLE [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_delete_jobschedule] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_add_schedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_check_for_owned_jobsteps] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_enum_sqlagent_subsystems] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobhistory_sem] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_uniquetaskname] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobcount] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobsteplog] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_get_jobstep_db_username] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_attach_schedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_get_job_alerts] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_agent_get_jobstep] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_update_jobstep] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_stop_job] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobserver] TO [DeveloperAgentRole]
GO
GRANT SELECT ON [dbo].[sysschedules_localserver_view] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_delete_jobserver] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_proxy] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_delete_schedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_delete_jobsteplog] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_delete_job] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_detach_schedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_schedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_maintplan_subplans_by_job] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_add_jobschedule] TO [DeveloperAgentRole]
GO
GRANT SELECT ON [dbo].[sysjobs_view] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_update_schedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_notify_operator] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobhistory] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_add_jobserver] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_droptask] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_get_sqlagent_properties] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_job] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_start_job] TO [DeveloperAgentRole]
GO
GRANT SELECT ON [dbo].[syscategories] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_update_jobschedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_check_for_owned_jobs] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobschedule] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobactivity] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_delete_jobstep] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_add_jobstep] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_operator] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_addtask] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_update_job] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobhistory_summary] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobstep] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobs_in_schedule] TO [DeveloperAgentRole]
GO
DENY EXECUTE ON [dbo].[sp_add_job] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_jobhistory_full] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_category] TO [DeveloperAgentRole]
GO
GRANT SELECT ON [dbo].[sysalerts_performance_counters_view] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_enum_login_for_proxy] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_targetserver] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_alert] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_purge_jobhistory] TO [DeveloperAgentRole]
GO
GRANT EXECUTE ON [dbo].[sp_help_notification] TO [DeveloperAgentRole]
GO
GRANT SELECT ON [dbo].[sysnotifications] TO [DeveloperAgentRole]
GO
GRANT SELECT ON [dbo].[sysoperators] TO [DeveloperAgentRole]
GO
GRANT SELECT ON [dbo].[sysalerts] TO [DeveloperAgentRole]
GO
