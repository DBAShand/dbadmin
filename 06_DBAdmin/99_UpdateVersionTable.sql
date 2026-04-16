USE DBAdmin
GO
DECLARE @dbadminversion decimal(10,9)
DECLARE @lastUpdatedDate datetime 
set @dbadminVersion = 1.39485
set @lastUpdatedDate = GETDATE()

TRUNCATE TABLE scs.Version

INSERT INTO scs.Version
        ( Version, LastUpdatedDate )
VALUES  ( @dbadminversion, -- Version - decimal
          @lastUpdatedDate  -- LastUpdatedDate - date
          )


GO
