USE [DBAdmin]
GO

/****** Object:  StoredProcedure [scs].[dba_CopyLogins]    Script Date: 6/13/2017 11:37:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[scs].[dba_CopyLogins]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [scs].[dba_CopyLogins] AS' 
END
GO





ALTER Procedure [scs].[dba_CopyLogins]
    @print bit = 0,
	@Debug bit = 0,
	@createscript bit = 0

As



Declare @MaxID int,

	@CurrID int,

	@SQL nvarchar(max),

	@LoginName sysname,

	@IsDisabled int,

	@Type char(1),

	@SID varbinary(85),

	@SIDString nvarchar(100),

	@PasswordHash varbinary(256),

	@PasswordHashString nvarchar(300),

	@RoleName sysname,

	@Machine sysname,

	@PermState nvarchar(60),

	@PermName sysname,

	@Class tinyint,

	@MajorID int,

	@ErrNumber int,

	@ErrSeverity int,

	@ErrState int,

	@ErrProcedure sysname,

	@ErrLine int,

	@ErrMsg nvarchar(2048), 

	@datetime datetime, 

	@textdatetime varchar(23)




Set NoCount On;
set @datetime = getdate() 
set @textdatetime = CONVERT(VARCHAR(23),@datetime,121)

truncate table dbadmin.scs.scs_Roles
truncate table dbadmin.scs.scs_Logins 
truncate table dbadmin.scs.scs_Perms
-- Get all Windows logins from server

Set @SQL = 'Select P.name, P.sid, P.is_disabled, P.type, L.password_hash, L.default_database_name,''' + @textdatetime + ''',''' + @@servername + '''' + CHAR(10) +

		'From master.sys.server_principals P' + CHAR(10) +

		'Left Join master.sys.sql_logins L On L.principal_id = P.principal_id' + CHAR(10) +

		'Where P.type In (''U'', ''G'', ''S'')' + CHAR(10) +

		'And P.name <> ''sa''' + CHAR(10) +

		'And P.name Not Like ''##%''' + CHAR(10);



Insert Into dbadmin.scs.scs_Logins  (Name, SID, IsDisabled, Type, PasswordHash, default_database_name,timestamp, servername)

Exec sp_executesql @SQL;


-- Get all roles from principal server

Set @SQL = 'Select RoleP.name, LoginP.name,''' + @textdatetime + ''',''' + @@servername + ''''+ CHAR(10) +

		'From  master.sys.server_role_members RM' + CHAR(10) +

		'Inner Join master.sys.server_principals RoleP' +

		CHAR(10) + char(9) + 'On RoleP.principal_id = RM.role_principal_id' + CHAR(10) +

		'Inner Join master.sys.server_principals LoginP' +

		CHAR(10) + char(9) + 'On LoginP.principal_id = RM.member_principal_id' + CHAR(10) +

		'Where LoginP.type In (''U'', ''G'', ''S'')' + CHAR(10) +

		'And LoginP.name <> ''sa''' + CHAR(10) +

		'And LoginP.name Not Like ''##%''' + CHAR(10) +

		'And RoleP.type = ''R''' + CHAR(10);


print @sql 
Insert Into dbadmin.scs.scs_Roles (RoleName, LoginName,  timestamp, servername)

exec sp_executesql @SQL;


-- Get all explicitly granted permissions

Set @SQL = 'Select P.name Collate database_default,' + CHAR(10) +

		'	SP.state_desc, SP.permission_name, SP.class, SP.class_desc, SP.major_id,' + CHAR(10) +

		'	SubP.name Collate database_default,' + CHAR(10) +

		'	SubEP.name Collate database_default,''' + @textdatetime + ''','''+   @@servername + '''' + CHAR(10) +

		'From master.sys.server_principals P' + CHAR(10) +

		'Inner Join master.sys.server_permissions SP' + CHAR(10) +

		CHAR(9) + 'On SP.grantee_principal_id = P.principal_id' + CHAR(10) +

		'Left Join master.sys.server_principals SubP' + CHAR(10) +

		CHAR(9) + 'On SubP.principal_id = SP.major_id And SP.class = 101' + CHAR(10) +

		'Left Join master.sys.endpoints SubEP' + CHAR(10) +

		CHAR(9) + 'On SubEP.endpoint_id = SP.major_id And SP.class = 105' + CHAR(10) +

		'Where P.type In (''U'', ''G'', ''S'')' + CHAR(10) +

		'And P.name <> ''sa''' + CHAR(10) +

		'And P.name Not Like ''##%''' + CHAR(10) 



Insert Into dbadmin.scs.scs_Perms (LoginName, PermState, PermName, Class, ClassDesc, MajorID, SubLoginName, SubEndPointName,timestamp , servername)

exec sp_executesql @SQL;



Select @MaxID = Max(LoginID), @CurrID = 1

From dbadmin.scs.scs_Logins;



While @CurrID <= @MaxID

  Begin

	Select @LoginName = Name,

		@IsDisabled = IsDisabled,

		@Type = [Type],

		@SID = [SID],

		@PasswordHash = PasswordHash

	From dbadmin.scs.scs_Logins

	Where LoginID = @CurrID;

	

	If @createscript = 1

	  Begin

		Set @SQL = 'Create Login ' + quotename(@LoginName)

		If @Type In ('U', 'G')

		  Begin

			Set @SQL = @SQL + ' From Windows;'

		  End

		Else

		  Begin

			Set @PasswordHashString = '0x' +

				Cast('' As XML).value('xs:hexBinary(sql:variable("@PasswordHash"))', 'nvarchar(300)');

			

			Set @SQL = @SQL + ' With Password = ' + @PasswordHashString + ' HASHED, ';

			

			Set @SIDString = '0x' +

				Cast('' As XML).value('xs:hexBinary(sql:variable("@SID"))', 'nvarchar(100)');

			Set @SQL = @SQL + 'SID = ' + @SIDString + ';';

		  End



		If @Debug = 0

		  Begin

			Begin Try

				Exec sp_executesql @SQL;
				print @SQL

			End Try

			Begin Catch

				Set @ErrNumber = ERROR_NUMBER();

				Set @ErrSeverity = ERROR_SEVERITY();

				Set @ErrState = ERROR_STATE();

				Set @ErrProcedure = ERROR_PROCEDURE();

				Set @ErrLine = ERROR_LINE();

				Set @ErrMsg = ERROR_MESSAGE();

				RaisError(@ErrMsg, 1, 1);

			End Catch

		  End

		Else

		  Begin

			Print @SQL;

		  End

		

		If @IsDisabled = 1

		  Begin

			Set @SQL = 'Alter Login ' + quotename(@LoginName) + ' Disable;'

			If @Debug = 0

			  Begin

				Begin Try

					Exec sp_executesql @SQL;

				End Try

				Begin Catch

					Set @ErrNumber = ERROR_NUMBER();

					Set @ErrSeverity = ERROR_SEVERITY();

					Set @ErrState = ERROR_STATE();

					Set @ErrProcedure = ERROR_PROCEDURE();

					Set @ErrLine = ERROR_LINE();

					Set @ErrMsg = ERROR_MESSAGE();

					RaisError(@ErrMsg, 1, 1);

				End Catch

			  End

			Else

			  Begin

				Print @SQL;

			  End

		  End

		End

	Set @CurrID = @CurrID + 1;

  End



Select @MaxID = Max(RoleID), @CurrID = 1

From dbadmin.scs.scs_Roles;



While @CurrID <= @MaxID

  Begin

	Select @LoginName = LoginName,

		@RoleName = RoleName

	From dbadmin.scs.scs_Roles

	Where RoleID = @CurrID;



	If @createscript = 1

	  Begin

		If @Debug = 0

		  Begin

			Exec sp_addsrvrolemember @rolename = @RoleName,

							@loginame = @LoginName;

		  End

		Else

		  Begin

			Print 'Exec sp_addsrvrolemember @rolename = ''' + @RoleName + ''',';

			Print '		@loginame = ''' + @LoginName + ''';';

		  End

	  End



	Set @CurrID = @CurrID + 1;

  End



Select @MaxID = Max(PermID), @CurrID = 1

From dbadmin.scs.scs_Perms;



While @CurrID <= @MaxID

  Begin

	Select @PermState = PermState,

		@PermName = PermName,

		@Class = Class,

		@LoginName = LoginName,

		@MajorID = MajorID,

		@SQL = PermState + space(1) + PermName + SPACE(1) +

			Case Class When 101 Then 'On Login::' + QUOTENAME(SubLoginName)

					When 105 Then 'On ' + ClassDesc + '::' + QUOTENAME(SubEndPointName)

					Else '' End +

			' To ' + QUOTENAME(LoginName) + ';'

	From dbadmin.scs.scs_Perms

	Where PermID = @CurrID;

	

	If @createscript = 1
	  Begin

		If @Debug = 0

		  Begin

			Begin Try

				--Exec sp_executesql @SQL;
				print @SQL
			End Try

			Begin Catch

				Set @ErrNumber = ERROR_NUMBER();

				Set @ErrSeverity = ERROR_SEVERITY();

				Set @ErrState = ERROR_STATE();

				Set @ErrProcedure = ERROR_PROCEDURE();

				Set @ErrLine = ERROR_LINE();

				Set @ErrMsg = ERROR_MESSAGE();

				RaisError(@ErrMsg, 1, 1);

			End Catch

		  End

		Else

		  Begin

			Print @SQL;

		  End

	  End



	Set @CurrID = @CurrID + 1;

  End

  IF @print = 1 
  BEGIN
  select * from dbadmin.scs.scs_Perms
  select * from dbadmin.scs.scs_Roles
  select * from dbadmin.scs.scs_Logins
  end
Set NoCount Off;


GO


