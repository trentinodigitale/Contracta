USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_NOTIER_ISCRIZ_FATTURE_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_NOTIER_ISCRIZ_FATTURE_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	EXEC NOTIER_ISCRIZ_CREATE_FROM_LISTA @IdDoc, @idUser, 'FATTURE'

END

















GO
