USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_PDA_LST_BUSTE_TEC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_PDA_LST_BUSTE_TEC](  @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
begin

	exec DOCUMENT_LOAD_SEC_PDA_LST_BUSTE_TEC_TESTATA @DocName,'',@IdDoc,@idUser

end
GO
