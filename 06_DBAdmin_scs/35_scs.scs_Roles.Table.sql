create table DBAdmin.scs.scs_Roles (RoleID int identity(1, 1) not null primary key,

					RoleName sysname not null,

					LoginName sysname not null, 
					
					servername sysname, 
					
					timestamp datetime)