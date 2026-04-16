create table DBAdmin.scs.scs_Perms (PermID int identity(1, 1) not null primary key,

					LoginName sysname not null,

					PermState nvarchar(60) not null,

					PermName sysname not null,

					Class tinyint not null,

					ClassDesc nvarchar(60) not null,

					MajorID int not null,

					SubLoginName sysname null,

					SubEndPointName sysname null, 
					
					servername sysname, 
					
					timestamp datetime)
