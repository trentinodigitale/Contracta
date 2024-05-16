USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CHANGE_NOTICE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[E_FORMS_CHANGE_NOTICE] ( @idDoc int , @idProc int , @idUser int = 0 , @extraParams nvarchar(4000) = '', @guidOperation varchar(500) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- L'idDoc in input è l'id del documento di rettifica/proroga/revoca
	-- l'idProc è l'id della procedura

	-- Ancora non gestito dai WS al momento della scrittura di questa stored ma predispongo il campo. il suo valore avrà una forma del tipo "102273-2023"
	declare @PublicationID varchar(100) = '' 
	declare @chReasonCode varchar(100) = ''
	declare @chReasonDesc varchar(1000) = ''
	declare @tipoDoc varchar(100) = ''
	declare @jumpCheck varchar(1000) = ''

	SELECT @PublicationID = cn16_publication_id
		FROM Document_E_FORM_CONTRACT_NOTICE with(nolock) 
		where idHeader = @idProc

	SELECT  @tipoDoc = TipoDoc,
			@jumpCheck = JumpCheck
		FROM ctl_doc gara with(nolock) 
		WHERE id = @idDoc

	IF @tipoDoc = 'PDA_COMUNICAZIONE_GENERICA' and @jumpCheck like '%-REVOCA_BANDO'
	BEGIN
		set @chReasonCode = 'cancel' --Avviso annullato
		set @chReasonDesc = 'Revoca della procedura'
	END
	ELSE
	BEGIN

		set @chReasonCode = 'update-add' --Codice associato a "Aggiornamento informazioni"
		set @chReasonDesc = 'Aggiornamento dati' --diamo un default

		IF @tipoDoc = 'RETTIFICA_GARA'
			set @chReasonDesc = @chReasonDesc + ' a seguito di Rettifica'
			--potrebbe essere utile avere come motivo della rettifica quanto inserito dall'utente ?
			--select @descMotivoRettifica = note from ctl_doc with(nolock) where id = @idDoc

		IF @tipoDoc = 'PROROGA_GARA'
			set @chReasonDesc = @chReasonDesc + ' a seguito di Proroga'
			--potrebbe essere utile avere come motivo della proroga quanto inserito dall'utente ?
			--select @descMotivoRettifica = [value] from CTL_DOC_Value with(nolock) where IdHeader = @idDoc and DSE_ID = 'TESTATA' and DZT_Name = 'body'
	END


	SELECT  isnull(@PublicationID,'') as CHANGED_NOTICE_IDENTIFIER,
			@chReasonCode as CHANGE_REASON_CODE,
			@chReasonDesc as CHANGE_REASON_DESC

END
GO
