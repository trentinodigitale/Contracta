USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VERBALEGARA_CREATE_FROM_CONTRATTO_GARA]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[VERBALEGARA_CREATE_FROM_CONTRATTO_GARA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN


	exec VERBALEGARA_CREATE_FROM_DOCUMENT @idDoc , @IdUser   , 'CONTRATTO_GARA' 

	
END














GO
