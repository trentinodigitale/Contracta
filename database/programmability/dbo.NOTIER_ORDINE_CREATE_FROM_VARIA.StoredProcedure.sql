USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[NOTIER_ORDINE_CREATE_FROM_VARIA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NOTIER_ORDINE_CREATE_FROM_VARIA] ( @IdDoc int  , @idUser int, @varia int = 0 )
AS
BEGIN

	EXEC NOTIER_ORDINE_CREATE_FROM_LISTA @IdDoc, @idUser, 1

END


GO
