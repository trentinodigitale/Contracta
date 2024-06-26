USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_E_FORMS_CHANGE_LIST]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_E_FORMS_CHANGE_LIST] ( @idDoc int , @idProc int , @idUser int = 0 , @extraParams nvarchar(4000) = '', @guidOperation varchar(500) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- L'idDoc in input è l'id del documento di rettifica/proroga/revoca
	-- l'idProc è l'id della procedura

	declare @tipoDoc varchar(100) = ''
	declare @jumpCheck varchar(1000) = ''

	declare @DataTermineQuesiti as datetime = null
	--declare @DataTermineQuesiti_OLD as varchar(50) = null
	declare @DataScadenzaOfferta as datetime = null
	--declare @DataScadenzaOfferta_OLD as varchar(50) = null

	SELECT  @tipoDoc = TipoDoc,
			@jumpCheck = JumpCheck
		FROM ctl_doc with(nolock) 
		WHERE id = @idDoc

	CREATE TABLE #changeList
	(
		CHANGE_DESCRIPTION nvarchar(4000),
		CHANGE_DOCUMENTS_INDICATOR varchar(10),
		CHANGE_SEC_ID varchar(10) NULL,
	)

	IF @tipoDoc = 'PDA_COMUNICAZIONE_GENERICA' and @jumpCheck like '%-REVOCA_BANDO'
	BEGIN
		-- PER LA REVOCA DELLA PROCEDURA NON CI SONO CHANGES
		INSERT INTO #changeList( CHANGE_DESCRIPTION, CHANGE_DOCUMENTS_INDICATOR, CHANGE_SEC_ID )
						select top 0 '','',''
	END

	IF @tipoDoc = 'RETTIFICA_GARA'
	BEGIN

		-- DATI OGGETTO DI MODIFICA PRESENTI NEL CN16, QUINDI DA MANDARE IN CHANGE :
		--		Data Termine Quesiti (  BT-13 livello lotti )
		--		Data Presentazione Offerte/Risposte (  BT-131 o BT-1311 livello lotti )
		
		-- SE È STATO CONFERMATO IL DOCUMENTO DI RETTIFICA SIGNIFICA QUESTE 2 DATE SONO STATE INSERITE ( E MODIFICATE ) E SONO VALIDE. non serve controllare niente !
		INSERT INTO #changeList( CHANGE_DESCRIPTION, CHANGE_DOCUMENTS_INDICATOR, CHANGE_SEC_ID )
							select  'Modifica BT-13 (Termine quesiti) e '
									
									+ case when db.ProceduraGara = '15477' /*Ristretta*/ then 'BT-1311 ( Termine per il ricevimento delle domande di partecipazione )'
																						 else 'BT-131 ( Termine per il ricevimento delle offerte )'
									end +

									' del lotto ' + numeroLotto as CHANGE_DESCRIPTION,

									'true' as CHANGE_DOCUMENTS_INDICATOR,

									dbo.eFroms_GetIdentifier('Lot', NumeroLotto,'') as CHANGE_SEC_ID

							FROM ctl_doc b WITH(NOLOCK) 
									inner join document_bando db with(nolock) on db.idheader = b.id
									inner join Document_MicroLotti_Dettagli d WITH(NOLOCK) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
							WHERE b.id = @idProc and d.StatoRiga <> 'Revocato'

					--select @DataTermineQuesiti = [value]
					--	from ctl_doc_value with(nolock)
					--	where idheader = @idDoc and DSE_ID='TESTATA' and DZT_Name='DataTermineQuesiti'
					--select @DataScadenzaOfferta = [value]
					--	from ctl_doc_value with(nolock)
					--	where idheader = @idDoc and DSE_ID='TESTATA' and DZT_Name='DataPresentazioneRisposte' 

	END

	IF @tipoDoc = 'PROROGA_GARA'
	BEGIN

		-- DATI OGGETTO DI MODIFICA PRESENTI NEL CN16, QUINDI DA MANDARE IN CHANGE :
		--		Data Termine Quesiti (  BT-13 livello lotti )
		--		Data Presentazione Offerte/Risposte (  BT-131 o BT-1311 livello lotti )
		

		INSERT INTO #changeList( CHANGE_DESCRIPTION, CHANGE_DOCUMENTS_INDICATOR, CHANGE_SEC_ID )
							select  'Modifica '

									--+ case when @DataTermineQuesiti is not null then 'BT-13 (Termine quesiti) e ' else '' end
									
									+ 'BT-13 (Termine quesiti) e ' +

									+ case when db.ProceduraGara = '15477' /*Ristretta*/ then 'BT-1311 ( Termine per il ricevimento delle domande di partecipazione )'
																						 else 'BT-131 ( Termine per il ricevimento delle offerte )'
									end +

									' del lotto ' + numeroLotto as CHANGE_DESCRIPTION,

									'false' as CHANGE_DOCUMENTS_INDICATOR,

									dbo.eFroms_GetIdentifier('Lot', NumeroLotto,'') as CHANGE_SEC_ID

							FROM ctl_doc b WITH(NOLOCK) 
									inner join document_bando db with(nolock) on db.idheader = b.id
									inner join Document_MicroLotti_Dettagli d WITH(NOLOCK) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
							WHERE b.id = @idProc and d.StatoRiga <> 'Revocato'


	END


	SELECT  *
		from #changeList

	DROP TABLE #changeList

END
GO
