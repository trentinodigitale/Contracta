USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOC_RFQ_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





create PROCEDURE [dbo].[OLD_DOC_RFQ_CREATE_FROM_NEW] ( @idRDA int  , @idUser int )
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

	declare @idazi int

	SET NOCOUNT ON

	set @Id = 0
	set @Errore = ''
	
	--select * from ctl_doc
	--inner join document_bando on id=idheader
	--where TipoProceduraCaratteristica  = 'RFQ'

	select @idazi = pfuidazi from profiliutente where idpfu = @idUser
	
	-- PRENDO IL DOCUMENTO CREATO IN PRECEDENZA SE ESISTE
	--select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idRDA and TipoDoc = 'BANDO_GARA' and Deleted = 0 and StatoFunzionale <> 'Annullato'

	IF @id = 0
	BEGIN
		-- aggiorna lo stato della RDA in CreataRDO
		--update CTL_DOC set StatoFunzionale = 'CreataRDO' where Id = @idRDA


		INSERT INTO CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, ProtocolloRiferimento,  Fascicolo, 
		LinkedDoc, StatoFunzionale ,Versione, caption, JumpCheck )
			SELECT @idUser ,  'BANDO_GARA' , 'Saved' , 'RDO', '' , @idazi, '',
					''  , '' ,  0  ,'InLavorazioneCreaModello' , '2', 'Richiesta di Offerta', ''
				--from CTL_DOC d with(nolock)
					--	left join aziende az with(nolock) on az.idazi = d.Azienda
				--where Id = @idRDA

		set @Id = SCOPE_IDENTITY()

		set @ImportoBando = 0
		set @TipoBando = ''
		set @RichiestaQuesito = '0'
		set @ClasseIscriz = ''
		set @ProceduraGara = '15478' --negoziata
		set @TipoBandoGara = '3' --invito
		set @CriterioAggiudicazioneGara = '15531' --prezzo + basso
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
			select  'RFQ', @Id    , @ImportoBando, getDate(), '','', @TipoBando, NULL, @RichiestaQuesito,  @ClasseIscriz, '0', @ProceduraGara, 
						@TipoBandoGara, @CriterioAggiudicazioneGara, @ImportoBando, '', @ImportoBando, 0, @CriterioFormulazioneOfferte, 0, 
						@OffAnomale, '', NULL, '0', '1', '', '', @TipoAppaltoGara,  @Conformita, @Divisione_lotti,
						NULL, '', '16308', @TipoIVA, '0',NULL,azienda,NULL
				from ctl_doc with(nolock)
				where Id = @id


		--select top 1 @ListaAlbi=cast(id as varchar(50)) from ctl_doc with(nolock) where tipodoc='BANDO_QF' and StatoFunzionale = 'Pubblicato' and StatoDoc = 'Sended' and deleted=0 and isnull(jumpcheck,'')='' order by id desc

		--if  isnull(@ListaAlbi,'') <> ''
		--begin

		--	update document_bando 
		--			set ListaAlbi = '###' + isnull(@ListaAlbi,'') + '###'
		--		where idheader = @id

		--end

		insert into Document_dati_protocollo ( idHeader)
									  values (  @Id )


	-- aggiunge i fra i destinatari il fornitore indicato nella RDA
		--insert into CTL_DOC_Destinatari ( NumRiga, idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb)
		--	select  1, @Id , c.vatValore_FT as CodiceFiscale, IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb
		--		from ctl_doc doc with(nolock)
		--				inner join aziende a with(nolock) on a.idazi = doc.Destinatario_Azi
		--				inner join DM_Attributi c with(nolock) on c.lnk = a.IdAzi and c.dztNome = 'codicefiscale'
		--		where doc.id = @idRDA




		

		
		
		--------------------------------------------------r
		-- associo modello di default
		--------------------------------------------------
		insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values ( @Id , 'TESTATA_PRODOTTI' , 0 , 'Ambito' , '3' ) -- ambito = '3' -- ALTRI BENI

		declare @CodiceModello varchar(200)
		set @CodiceModello = ''
		select top 1 @CodiceModello = m.titolo  
			from ctl_doc m with(nolock) 
			INNER JOIN CTL_DOC_VALUE V1 with(nolock) on v1.idheader = m.id and v1.DSE_ID = 'AMBITO' and v1.DZT_Name = 'MacroAreaMerc' and v1.value = '3'

			INNER JOIN CTL_DOC_VALUE V2 with(nolock) on v2.idheader = m.id and v2.DSE_ID = 'CRITERI' and v2.DZT_Name = 'TipoProcedureApplicate' and v2.value like '%###RDO###%'  -- RDO
			INNER JOIN CTL_DOC_VALUE V3 with(nolock) on v3.idheader = m.id and v3.DSE_ID = 'CRITERI' and v3.DZT_Name = 'CriterioAggiudicazioneGara' and v3.value like '%###15531###%' -- PREZZO più basso
			INNER JOIN CTL_DOC_VALUE V4 with(nolock) on v4.idheader = m.id and v4.DSE_ID = 'CRITERI' and v4.DZT_Name = 'CriterioFormulazioneOfferte' and v4.value like '%###15536###%' -- Prezzo
			
			where tipodoc = 'CONFIG_MODELLI_LOTTI' /*and titolo like  'BENI_PPB_da_CPM%' */ and m.deleted = 0 and statofunzionale = 'Pubblicato'  and linkeddoc = 0 
			order by m.protocollo desc

		-- se non trovo il modello il documento sarà in lavorazione
		if isnull( @CodiceModello , '' ) = '' 
		begin
			update ctl_doc set StatoFunzionale = 'InLavorazione' where id = @id
		end
		else
		begin
		
			update document_bando set TipoBando = @CodiceModello + '_MONOLOTTO' where idheader = @id   
			insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values ( @Id , 'TESTATA_PRODOTTI' , 0 , 'TipoBandoScelta' ,  @CodiceModello + '_MONOLOTTO' ) 
		end 

		--setto il punteggio economico a 100
		insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values ( @Id , 'CRITERI_ECO' , 0 , 'PunteggioEconomico' , '100' ) 

		--------------------------------------------------
		-- iNSERISCO LE RIGHE RICHIESTE NELLA RFQ
		--------------------------------------------------

		-- metto prima la riga 0 che rappresenta la gara
		insert into Document_MicroLotti_Dettagli( IdHeader, numerolotto , voce , NumeroRiga, TipoDoc, Descrizione
												)
			select @id, 1 , 0 , 0 , 'BANDO_GARA', 'RDO'
				--from CTL_DOC  with(nolock)
				--where id = @idRDA
				

		-- riporto le righe della RDA
		--insert into Document_MicroLotti_Dettagli( IdHeader, numerolotto , voce , NumeroRiga, TipoDoc
		--											,PROGRESSIVO_RIGA
		--											,CodiceProdotto
		--											,Descrizione
		--											,DENOMINAZIONE_ARTICOLO_COMPLETA
		--											,UnitadiMisura
		--											,CampoTesto_20
		--											,Quantita
		--											,PrezzoUnitario
		--											,DATA_CONSEGNA
		--											,NoteLotto
		--											,CODICE_WBS
		--											,DESCRIZIONE_WBS
		--											,PREZZO_BASE_ASTA_UM_IVA_ESCLUSA
		--											,VALORE_BASE_ASTA_IVA_ESCLUSA
		--										)
		--	select @id, 1 , ROW_NUMBER() OVER(ORDER BY PurchaseRequestMeasurementId ASC), ROW_NUMBER() OVER(ORDER BY PurchaseRequestMeasurementId ASC), 'BANDO_GARA'
		--											,PurchaseRequestMeasurementId
		--											,ProductId
		--											,[ProductDescription]
		--											,[ProductDescriptionText]
		--											,ProductUnitId
		--											,ProductUnitDescription
		--											,Quantity
		--											,UnitCost
		--											,DeliveryDate
		--											,DescriptionText
		--											,WorkBreakdownElementId
		--											,WorkBreakdownElementDescription
		--											,UnitCost
		--											,UnitCost

		--		from document_pr_product with(nolock)
		--		where idheader = @idRDA
		--		order by PurchaseRequestMeasurementId

		----------------------------------------------------------------------
		-- aggiungo di base l'utente che crea la RDO nei riferimenti
		----------------------------------------------------------------------
		insert into [dbo].[Document_Bando_Riferimenti] (  [idHeader], [idPfu], [RuoloRiferimenti] ) 
			select @id as [idHeader], @idUser as [idPfu], 'Quesiti' as [RuoloRiferimenti]

		insert into [dbo].[Document_Bando_Riferimenti] (  [idHeader], [idPfu], [RuoloRiferimenti] ) 
			select @id as [idHeader], @idUser as [idPfu], 'Bando' as [RuoloRiferimenti]


		----------------------------------------------------------------------
		-- di base il compilatore è anche il responsabile
		----------------------------------------------------------------------
		insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values ( @Id , 'InfoTec_comune' , 0 , 'UserRUP' , @idUser ) 



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
