USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[EncryptPwdNonReversibile]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EncryptPwdNonReversibile] ( @PwdIN NVARCHAR(250) , @PwdOUT NVARCHAR(250) OUTPUT )
AS
BEGIN 
	set @PwdOUT=''


	--Da commentare su SQL Server 2000
	
	set @PwdOUT=HashBytes ( 'SHA1', @PwdIN )
    
	--exec EncryptPwdBase '0' , @PwdIN , @PwdOUT output	


END

GO
