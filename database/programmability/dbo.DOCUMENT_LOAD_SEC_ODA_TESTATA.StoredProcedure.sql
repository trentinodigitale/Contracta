USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_LOAD_SEC_ODA_TESTATA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- in sostituzione della vista Document_ODA_view
CREATE PROCEDURE [dbo].[DOCUMENT_LOAD_SEC_ODA_TESTATA](  @DocName nvarchar(500) , @Section nvarchar (500) , @IdDoc nvarchar(500) , @idUser int )
AS
begin
	
	SET NOCOUNT ON
	
	exec DOCUMENT_CK_TOOLBAR_ODA @DocName,@IdDoc,@idUser
	
end

GO
