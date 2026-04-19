-- ============================================================
-- 08_disable_sa.sql
-- Disables the SA login as a security hardening step.
--
-- !! DECISION REQUIRED BEFORE RUNNING !!
-- Verify ALL of the following before executing:
--   1. At least one other sysadmin login exists and is tested
--   2. SQL Agent service account has appropriate rights
--   3. Any monitoring tools NOT relying on SA
--
-- POWERSHELL TOKENS: none — this script takes no input.
-- ============================================================

-- Safety check: refuse to run if SA is the only sysadmin
IF (SELECT COUNT(*) FROM sys.server_principals sp
    JOIN sys.server_role_members srm ON sp.principal_id = srm.member_principal_id
    JOIN sys.server_principals r ON srm.role_principal_id = r.principal_id
    WHERE r.name = 'sysadmin'
    AND sp.name <> 'sa'
    AND sp.is_disabled = 0) = 0
BEGIN
    RAISERROR('ABORTED: No other enabled sysadmin logins found. Add one before disabling SA.', 16, 1)
    RETURN
END

ALTER LOGIN [sa] DISABLE
PRINT 'SA login disabled.'
GO
