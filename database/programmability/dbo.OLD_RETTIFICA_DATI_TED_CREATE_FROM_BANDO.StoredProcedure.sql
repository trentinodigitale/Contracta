USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RETTIFICA_DATI_TED_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_RETTIFICA_DATI_TED_CREATE_FROM_BANDO] ( @idDoc int , @IdUser int )
AS
BEGIN

	SET NOCOUNT ON


	EXEC DELTA_TED_CREATE_FROM_BANDO @idDoc, @IdUser, 1, 1 
	
	

END










GO
