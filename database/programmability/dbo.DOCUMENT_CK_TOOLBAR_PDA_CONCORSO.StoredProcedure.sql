USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_PDA_CONCORSO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- in sostituzione della vista PDA_MICROLOTTI_VIEW_TESTATA

CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_PDA_CONCORSO](  @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on
	EXEC DOCUMENT_LOAD_SEC_PDA_CONCORSO @DocName,'',@IdDoc,@idUser
end



GO
