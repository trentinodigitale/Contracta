USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_INTEGRA_ISCRIZIONE_SDA_CREATE_FROM_RISPOSTA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_INTEGRA_ISCRIZIONE_SDA_CREATE_FROM_RISPOSTA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @idIstanza as int


	select @idIstanza = C3.LinkedDoc from CTL_DOC C1 with(nolock)
		INNER JOIN CTL_DOC C2 with(nolock) ON C2.ID=c1.LinkedDoc
		INNER JOIN CTL_DOC C3 with(nolock) ON C3.ID=c2.LinkedDoc
		WHERE c1.id=@idDoc

	EXEC [dbo].INTEGRA_ISCRIZIONE_SDA_CREATE_FROM_ISTANZA_SDA_FARMACI @idIstanza, @IdUser
END
GO
