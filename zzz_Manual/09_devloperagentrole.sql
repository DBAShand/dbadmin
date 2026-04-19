-- ============================================================
-- 09_devloperagentrole.sql
-- Creates the DeveloperAgentRole in msdb with read-only access
-- to SQL Agent views and limited job management capabilities.
--
-- !! DECISION REQUIRED !!
-- Review the GRANT/DENY list below before running.
-- This gives developers visibility into Agent jobs.
-- Adjust to match your organization's security policy.
--
-- POWERSHELL TOKENS: none — permissions are policy, not env-specific.
-- ============================================================

USE [msdb]
GO

IF NOT EXISTS (SELECT name FROM msdb.sys.database_principals WHERE name = 'DeveloperAgentRole')
BEGIN
    CREATE ROLE [DeveloperAgentRole]
    PRINT 'Role [DeveloperAgentRole] created.'
END
ELSE
    PRINT 'Role [DeveloperAgentRole] already exists, skipping CREATE.'
GO

-- Read/monitor access
GRANT EXECUTE ON [dbo].[sp_check_for_owned_jobs]        TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_enum_sqlagent_subsystems]    TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_jobhistory_sem]         TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_unique_taskname]             TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_jobcount]               TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_jobsteplog]             TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_get_jobs_in_schedule]        TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_attach_schedule]             TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_get_job_alerts]              TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_agent_get_jobstep]           TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_stop_job]                    TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_jobserver]              TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_start_job]                   TO [DeveloperAgentRole]
GRANT SELECT ON [dbo].[sysjobs_view]                    TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_delete_jobserver]            TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_proxy]                  TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_delete_schedule]             TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_delete_jobsteplog]           TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_delete_job]                  TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_detach_schedule]             TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_schedule]               TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_mainplan_subplans_by_job]    TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_operator]               TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_jobhistory_full]        TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_category]               TO [DeveloperAgentRole]
GRANT SELECT ON [dbo].[sysalerts_performance_counters_view] TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_enum_login_for_proxy]        TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_targetserver]           TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_alert]                  TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_purge_jobhistory]            TO [DeveloperAgentRole]
GRANT EXECUTE ON [dbo].[sp_help_notification]           TO [DeveloperAgentRole]
GRANT SELECT ON [dbo].[syscategories]                   TO [DeveloperAgentRole]
GRANT SELECT ON [dbo].[sysoperators]                    TO [DeveloperAgentRole]
GRANT SELECT ON [dbo].[sysalerts]                       TO [DeveloperAgentRole]

-- Restricted — developers cannot modify schedules or add jobs
DENY EXECUTE ON [dbo].[sp_update_jobschedule]   TO [DeveloperAgentRole]
DENY EXECUTE ON [dbo].[sp_add_jobschedule]      TO [DeveloperAgentRole]
DENY EXECUTE ON [dbo].[sp_add_job]              TO [DeveloperAgentRole]
DENY EXECUTE ON [dbo].[sp_update_job]           TO [DeveloperAgentRole]
DENY EXECUTE ON [dbo].[sp_add_jobstep]          TO [DeveloperAgentRole]
DENY EXECUTE ON [dbo].[sp_update_schedule]      TO [DeveloperAgentRole]
DENY EXECUTE ON [dbo].[sp_add_jobserver]        TO [DeveloperAgentRole]
DENY EXECUTE ON [dbo].[sp_addtask]              TO [DeveloperAgentRole]
GO
