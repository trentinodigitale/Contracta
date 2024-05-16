USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_REFRESH_VISTE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_REFRESH_VISTE] ( @verbose int = 0)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @viewName	NVARCHAR(300)

	DECLARE crs CURSOR FOR SELECT DISTINCT a.name 
									  FROM sysobjects a
										 , syscomments b
									 WHERE a.id = b.id 
									   AND a.xtype = 'V'
									   AND b.text LIKE '%' + name + '%'
									   AND colid = 1
									 ORDER BY 1

	OPEN crs

	FETCH NEXT FROM crs INTO @viewName 

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF @verbose = 1
			PRINT 'REFRESHING VIEW [' + @viewname + ']'

		----------------------------------------------
		-- PER OGNI VISTA INVOCO IL REFRESH 2 VOLTE --
		----------------------------------------------
		EXEC sp_refreshview @viewname
		EXEC sp_refreshview @viewname

		FETCH NEXT FROM crs INTO @viewName 

	END

	CLOSE crs
	DEALLOCATE crs

END



GO
