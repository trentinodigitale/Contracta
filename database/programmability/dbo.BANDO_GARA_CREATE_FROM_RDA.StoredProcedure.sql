USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_GARA_CREATE_FROM_RDA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BANDO_GARA_CREATE_FROM_RDA] ( @idRDA int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @ListaAlbi varchar(4000)
	declare @Errore nvarchar(max)

	declare @ImportoBando FLOAT
	declare @TipoBando varchar(1000)
	declare @RichiestaQuesito varchar(10)
	declare @ClasseIscriz varchar(1000)
	declare @ProceduraGara varchar(100)
	declare @TipoBandoGara varchar(10)
	declare @CriterioAggiudicazioneGara varchar(100)
	declare @CriterioFormulazioneOfferte varchar(100)
	declare @OffAnomale varchar(10)
	declare @TipoAppaltoGara varchar(10)
	declare @Conformita varchar(10)
	declare @Divisione_lotti varchar(10)
	declare @TipoIVA varchar(10)

	declare @modelloProdotti varchar(1000)

	SET NOCOUNT ON

	set @Id = 0
	set @Errore = ''
	 
	select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idRDA and TipoDoc = 'BANDO_GARA' and Deleted = 0 and StatoFunzionale <> 'Annullato'

	IF @id = 0
	BEGIN

		INSERT INTO CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, ProtocolloRiferimento,  Fascicolo, LinkedDoc, StatoFunzionale ,Versione, caption, JumpCheck )
			SELECT @idUser ,  'BANDO_GARA' , 'Saved' , 'RDO da ''' + isnull (titolo,'') + '''', d.Body , d.azienda, cast( idazi as varchar) + '#' + '\0000\0000',
					d.Protocollo  , '' ,  d.Id  ,'InLavorazione' , '2', 'Nuova RdO', 'FROM_RDA'
				from CTL_DOC d with(nolock)
						left join aziende az with(nolock) on az.idazi = d.Azienda
				where Id = @idRDA

		set @Id = SCOPE_IDENTITY()

		set @ImportoBando = 0
		set @TipoBando = ''
		set @RichiestaQuesito = '0'
		set @ClasseIscriz = ''
		set @ProceduraGara = '15478' --negoziata
		set @TipoBandoGara = '3' --invito
		set @CriterioAggiudicazioneGara = '15532' --prezzo + basso
		set @CriterioFormulazioneOfferte = '15536' -- al prezzo
		set @OffAnomale = '16310' --valutazione
		set @TipoAppaltoGara = '1' --forniture
		set @Conformita = 'No'
		set @Divisione_lotti = '0' --no
		set @TipoIVA = '3'

		INSERT INTO Document_Bando ( TipoProceduraCaratteristica,
						idHeader, ImportoBando, dataCreazione, FAX , Ufficio, TipoBando, TipoAppalto, RichiestaQuesito,  ClasseIscriz, RichiediProdotti, ProceduraGara, 
						TipoBandoGara       , CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, 
						OffAnomale, NumeroIndizione, DataIndizione, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, TipoAppaltoGara,  Conformita, Divisione_lotti,
						NumDec, DirezioneEspletante, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Concessione,EnteProponente,RupProponente )
			select  'RDO', @Id    , @ImportoBando, getDate(), '','', @TipoBando, NULL, @RichiestaQuesito,  @ClasseIscriz, '0', @ProceduraGara, 
						@TipoBandoGara, @CriterioAggiudicazioneGara, @ImportoBando, '', @ImportoBando, 0, @CriterioFormulazioneOfferte, 0, 
						@OffAnomale, '', NULL, '0', '1', '', '', @TipoAppaltoGara,  @Conformita, @Divisione_lotti,
						NULL, '', '16308', @TipoIVA, '0',NULL,azienda,NULL
				from ctl_doc with(nolock)
				where Id = @id


		select top 1 @ListaAlbi=cast(id as varchar(50)) from ctl_doc with(nolock) where tipodoc='BANDO_QF' and StatoFunzionale = 'Pubblicato' and StatoDoc = 'Sended' and deleted=0 and isnull(jumpcheck,'')='' order by id desc

		if  isnull(@ListaAlbi,'') <> ''
		begin

			update document_bando 
					set ListaAlbi = '###' + isnull(@ListaAlbi,'') + '###'
				where idheader = @id

		end

		insert into Document_dati_protocollo ( idHeader)
									  values (  @Id )

		insert into CTL_DOC_Destinatari ( NumRiga, idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb)
			select  1, @Id , c.vatValore_FT as CodiceFiscale, IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb
				from ctl_doc doc with(nolock)
						inner join aziende a with(nolock) on a.idazi = doc.Destinatario_Azi
						inner join DM_Attributi c with(nolock) on c.lnk = a.IdAzi and c.dztNome = 'codicefiscale'
				where doc.id = @idRDA

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'TESTATA' , 'BANDO_GARA_TESTATA_RDO_IMPRESA' )

		set @modelloProdotti = 'BANDO_GARA_PRODOTTI_RDO_IMPRESA_COMPUTO'

		select @modelloProdotti = r.REL_ValueOutput
			from CTL_Relations r with(nolock)
					INNER JOIN CTL_DOC c with(nolock) on c.Id = @idRDA
			where r.REL_ValueInput = 'MODELLO_RDO_IMPRESA' and r.REL_ValueInput = c.JumpCheck

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
			values( @id , 'PRODOTTI' ,  @modelloProdotti)

		insert into Document_MicroLotti_Dettagli( IdHeader, NumeroRiga, TipoDoc, CODICE_ARTICOLO_FORNITORE, Descrizione, Quantita, PrezzoUnitario )
			select @id, ROW_NUMBER() OVER(ORDER BY PurchaseRequestMeasurementId ASC), 'BANDO_GARA', ProductId, ProductDescription, Quantity, UnitCost 
				from document_pr_product with(nolock)
				where idheader = @idRDA
				order by PurchaseRequestMeasurementId


	END --if per cercare un rdo già creata

	IF @Errore = ''
	BEGIN

		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id

	END
	ELSE
	BEGIN

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	END

END

GO
