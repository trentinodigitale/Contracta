USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_RICHIESTA_SMART_CIG]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_RICHIESTA_SMART_CIG](  @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on
	EXEC DOCUMENT_LOAD_RICHIESTA_SMART_CIG @DocName,'',@IdDoc,@idUser
end

GO
