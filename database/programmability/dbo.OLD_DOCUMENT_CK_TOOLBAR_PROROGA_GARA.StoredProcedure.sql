USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_CK_TOOLBAR_PROROGA_GARA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- in sostituzione della vista CTL_DOC_VIEW_FUNZIONI_PROCEDURA per il documento PROROGA_GARA e RETTIFICA_GARA
CREATE PROCEDURE [dbo].[OLD_DOCUMENT_CK_TOOLBAR_PROROGA_GARA]( @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int )
AS
BEGIN
	
	SET NOCOUNT ON
	
	--select distinct statofunzionale from ctl_doc with(nolock) where tipodoc = 'RETTIFICA_GARA'

	-- Appena possibile rimuovere l'uso della vista CTL_DOC_VIEW_FUNZIONI_PROCEDURA e spostare le logiche in questa stored, così da ottimizzare i tempi di risposta
	select * into #condizioni_toolbar from CTL_DOC_VIEW_FUNZIONI_PROCEDURA where id = @IdDoc

	declare @idGara int = 0
	declare @statoFunzionale varchar(100) = ''

	select  @idGara = A.LinkedDoc,
			@statoFunzionale = a.StatoFunzionale
		from ctl_doc A with(nolock)
		where a.id = @IdDoc

	DECLARE @bAttivaChangeNotice varchar(1) = '0'

	-- Per rendere la modifica retrocompatibile (quindi permettere il rilascio di questa stored senza le attività degli eforms ) testiamo l'esistenza della tabella
	IF exists (SELECT * FROM sys.objects  WHERE name='Document_E_FORM_PAYLOADS' and type='U' )
	BEGIN	

		--se sulla gara è stato generato con successo il contract notice 
		--	e se lo della rettifica è inviato
		IF EXISTS ( select top 1 idrow from Document_E_FORM_PAYLOADS with(nolock) where idHeader = @idGara and operationType = 'CN16' )
				AND	@statoFunzionale = 'Inviato'
		BEGIN
			set @bAttivaChangeNotice = '1'
		END

	END

	select a.*, 
		  @bAttivaChangeNotice as attivaChangeNotice
		from #condizioni_toolbar a

	drop table #condizioni_toolbar

END

GO
