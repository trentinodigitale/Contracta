USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_SEMPLIFICATO_COPIA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BANDO_SEMPLIFICATO_COPIA] ( @idDoc int , @IdUser int ,@IdNewDoc int = 0 output, @copiaRicercaOE int = 0 )
AS
BEGIN

	exec BANDO_GARA_COPIA @idDoc , @IdUser ,@IdNewDoc output, @copiaRicercaOE

END


GO
