USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_CREATE_FROM_BANDO_CONCORSO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[ISTANZA_CREATE_FROM_BANDO_CONCORSO]( @idOrigin as int, @idPfu as int = -20, @newId as int output ) 
AS
BEGIN
	
	  Exec  RISPOSTA_CONCORSO_CREATE_FROM_BANDO_CONCORSO  @idOrigin, @idPfu, @newId output
   

END




















GO
