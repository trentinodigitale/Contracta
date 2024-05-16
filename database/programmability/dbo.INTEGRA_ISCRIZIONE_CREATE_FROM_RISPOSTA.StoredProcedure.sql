USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INTEGRA_ISCRIZIONE_CREATE_FROM_RISPOSTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[INTEGRA_ISCRIZIONE_CREATE_FROM_RISPOSTA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @idIstanza as int
	declare @tipoDoc as varchar(50)

	select @tipoDoc = IsNull(C4.JumpCheck, ''), @idIstanza = C2.LinkedDoc from CTL_DOC C1 with(nolock)
		INNER JOIN CTL_DOC C2 with(nolock) ON C2.ID=c1.LinkedDoc --IntegraIscrizione
		INNER JOIN CTL_DOC C3 with(nolock) ON C3.ID=c2.LinkedDoc --Istanza
		INNER JOIN CTL_DOC C4 with(nolock) ON C4.ID=c3.LinkedDoc --Bando
		WHERE c1.id=@idDoc --Risposta

	If @tipoDoc = 'BANDO_ALBO_FORNITORI'
		EXEC [dbo].[INTEGRA_ISCRIZIONE_CREATE_FROM_ISTANZA_AlboFornitori] @idIstanza, @IdUser
	Else If @tipoDoc = 'BANDO_ALBO_LAVORI'
		EXEC [dbo].[INTEGRA_ISCRIZIONE_CREATE_FROM_ISTANZA_AlboLavori] @idIstanza, @IdUser
	Else If @tipoDoc = ''
		 EXEC [dbo].[INTEGRA_ISCRIZIONE_CREATE_FROM_ISTANZA_AlboOperaEco] @idIstanza, @IdUser



END

GO
