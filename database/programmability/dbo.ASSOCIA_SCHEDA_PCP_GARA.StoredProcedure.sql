USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ASSOCIA_SCHEDA_PCP_GARA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[ASSOCIA_SCHEDA_PCP_GARA]  ( @IdGara int , @Idpfu int )
AS
BEGIN

	exec INIT_SCHEDA_PCP_GARA   @IdGara , @Idpfu 
	
	
END






GO
