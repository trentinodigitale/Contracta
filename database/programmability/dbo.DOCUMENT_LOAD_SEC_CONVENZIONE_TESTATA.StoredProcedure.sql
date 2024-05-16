USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_LOAD_SEC_CONVENZIONE_TESTATA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



















-- in sostituzione della vista document_bando_copertina

CREATE PROCEDURE [dbo].[DOCUMENT_LOAD_SEC_CONVENZIONE_TESTATA](  @DocName nvarchar(500) , @Section nvarchar (500) , @IdDoc nvarchar(500) , @idUser int )
AS
begin
	
	set nocount on

	declare @idDocListinoOrdini as int
	declare @PresenzaRigheListinoOrdini as int
	declare @NotEditable as varchar(500)

	DECLARE @statoScheda varchar(100)

	--att.587323
	--SE HO ESEGUITO "PUBBLICA AVVISO AGGIUDICAZIONE" BLOCCO I CAMPI
	--"Gender Equality", Presenza Listino Ordini
	select top 1 @statoScheda = isnull(statoScheda,'') 
				from Document_PCP_Appalto_Schede with(nolock) 
				where IdDoc_Scheda = @IdDoc and bDeleted = 0 and tipoScheda in ('A1_29','A2_29','A7_1_2','A2_32','A1_32','A1_33','A2_33') 
				order by idRow desc
	set @NotEditable = ''
	if @statoScheda in ( 'InvioInCorso', 'Creato', 'Confermato', 'SC_CONF', 'AP_CONF', 'CigRecuperati', 'InPubblicazione', 'AV_PUBB','SC_CONF', 'AV_RETT', 'AV_N_RETT', 'AV_RICHIESTA_RETT_IN_CORSO' ,'PUBB')	---------------------------------------------------------------------
	begin
		set @NotEditable = ' GenderEquality PresenzaListinoOrdini '
	end

	select  
		DC.ID, 
		ISNULL(DC.DOC_Owner,C.idpfu) as DOC_Owner, 
		c.titolo as DOC_Name, 
		DC.DataCreazione, 
		c.protocollo as Protocol, 
		DC.DescrizioneEstesa, 
		DC.StatoConvenzione, 
		DC.AZI, 
		DC.Plant, 
		DC.Deleted, 
		DC.AZI_Dest, 
		DC.NumOrd, 
		DC.Imballo, 
		DC.Resa, 
		DC.Spedizione, 
		DC.Pagamento, 
		DC.Valuta, 
		DC.Total, 
		DC.Completo,
		DC.Allegato, 
		DC.Telefono, 
		DC.Compilatore, 
		DC.RuoloCompilatore, 
		DC.TipoOrdine, 
		DC.SendingDate, 
		DC.ProtocolloBando, 
		DC.DataInizio, 
		DC.DataFine, 
		DC.Merceologia, 
		DC.TotaleOrdinato, 
		DC.IVA, 
		DC.NewTotal, 
		DC.RicPropBozza, 
		DC.ConvNoMail, 
		DC.QtMinTot, 
		DC.RicPreventivo, 
		DC.TipoImporto, 
		DC.TipoEstensione, 
		'1' as RichiediFirmaOrdine	,
		--DC.ID as LinkedDoc, 
		c.LinkedDoc,
		isnull( DC.Total , 0 ) - isnull( DC.TotaleOrdinato , 0 ) as BDG_TOT_Residuo
		--,isnull( DC.Total , 0 ) - ISNULL(AL2.ImportoAllocabile,0) as ImportoAllocabile
		, DC.IdRow
		,DC.DataProtocolloBando
		,DC.OggettoBando
		,DC.Mandataria
		,DC.ProtocolloListino
		,DC.dataListino
		,DC.statoListino
		,DC.ProtocolloContratto
		,DC.ReferenteFornitore
		,DC.CodiceFiscaleReferente
		,DC.ReferenteFornitoreHide
		,DC.Ambito
		,DC.GestioneQuote
		,ISNULL(DC.NotEditable,'') + @NotEditable  as NotEditable
		,DC.DataContratto
		,DC.StatoContratto
		,c.idpfu
		,c.titolo
		,c.protocollo
		,c.datainvio
		,c.StatoFunzionale 
		,c.tipodoc
		,DC.IdentificativoIniziativa
		,DC.DescrizioneIniziativa
		,DC.DataStipulaConvenzione
		,DC.RichiestaFirma
		,DC.CIG_MADRE
		,C.protocollogenerale
		,C.Dataprotocollogenerale
		,DC.TipoConvenzione
		,DC.ConAccessori
		,DC.ImportoMinimoOrdinativo
		,DC.OrdinativiIntegrativi
		,DC.TipoScadenzaOrdinativo
		,DC.NumeroMesi
		,DC.DataScadenzaOrdinativo
		,year(DC.DataInizio) as Anno_inizio_convenzione
		--,c1.value as Appalto_Verde
		--,c2.value as Acquisto_Sociale
		,DC.Macro_Convenzione
		,C.JumpCheck
		, case DC.Total
			when 0 then null
			else (DC.TotaleOrdinato/DC.Total)*100 
			end
			as PercErosione
		, 'CONVENZIONE_IMPORTI' as OPEN_DOC_NAME
		, year (DC.DataInizio) as AnnoPubConvenzione
		, year (dc.datafine) as AnnoScadConvenzione
		,p.pfuidazi as azienda
		,DC.mandataria as destinatario_azi
		,c.Note	
		,'' as DataChiusuraTecnical
		,'' as Object
	
		,c.id as idConvenzione
		--, model.value as idModello
		, P2.IdPfu as Owner
		, dc.EvidenzaPubblica
		, DC.Stipula_in_forma_pubblica
		--, GARA.datainvio as DataPubblicazioneBando 
		, DC.PossibilitaRinnovo
		, DC.UserRUP 
		, isnull(DC.ConvenzioniInUrgenza,'0') as ConvenzioniInUrgenza
		, ISNULL(DC.AllegatoDetermina,'') as AllegatoDetermina
		, ISNULL(DC.FondiFinanziamento,'') as FondiFinanziamento
		, P.pfuE_Mail as EMAILUTENTE
		, DC.PresenzaListinoOrdini
		, DC.ProtocolloListinoOrdini
		, DC.dataListinoOrdini
		, DC.statoListinoOrdini
		, DC.idBando as ID_BANDO
		, DC.GenderEquality
		, DC.Importo_Cauzione 
		, DC.DirettoreEsecuzioneContratto 
			into #D

		from 
			ctl_doc c with(nolock) 
				inner join Document_Convenzione DC with(nolock) on C.id=DC.id	
				left join profiliUtente P  with(nolock) on P.idpfu=c.idpfu
				inner join ProfiliUtente P2 with(nolock) on P2.pfuIdAzi=p.pfuidazi and P2.pfudeleted=0
		where 
			c.id=@IdDoc and DC.Deleted = 0 and C.Deleted = 0 and C.tipodoc='CONVENZIONE'



	--recupero email e telefono del fornitore
	declare @EmailFornitore as nvarchar(255)
	declare @TelefonoFornitore as nvarchar(50)
	select 
		
		@EmailFornitore=aziE_Mail ,
		@TelefonoFornitore = aziTelefono1 
		 
		from 
			document_convenzione with(nolock) 
				inner join aziende with(nolock)  on mandataria = idazi
		where 
			id=@IdDoc


	declare @ImportoAllocabile as float
	Select 
		@ImportoAllocabile= sum(Importo) 
		from 
			CTL_DOC with(nolock)
				inner join Document_Convenzione_Quote with(nolock) on id = idheader
		where 
			StatoDoc = 'Sended' and TipoDoc='QUOTA' and LinkedDoc=@IdDoc		
	
	declare @AppaltoVerde  as nvarchar(max) 
	set @AppaltoVerde=''
	SELECT 
		@AppaltoVerde = c1.value
		from 
			ctl_doc_value c1  with(nolock) 
		where  C1.idheader=@IdDoc and c1.DSE_ID='INFO_AGGIUNTIVE' and c1.DZT_Name='Appalto_Verde'
	
	declare @Acquisto_Sociale  as nvarchar(max) 
	set @Acquisto_Sociale=''
	SELECT 
		@Acquisto_Sociale = c2.value
			from
			ctl_doc_value c2  with(nolock) 
			where C2.idheader=@IdDoc and c2.DSE_ID='INFO_AGGIUNTIVE' and c2.DZT_Name='Acquisto_Sociale'
	
	declare @Modello as nvarchar(max)
	set @Modello=''
	SELECT 
		@Modello = value
			from
				ctl_doc_value with(nolock)
			where 
				IdHeader = @IdDoc and dse_id = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello' and isnull(value,'') <> ''

	declare @Cig_Madre as varchar(200)
	select @Cig_Madre=isnull(CIG_MADRE,'')  from document_convenzione with (nolock) where id = @IdDoc
	if @Cig_Madre <> ''
	begin
		 --per recuperare data pubblicazione della gara
		 --devo matchare anche sul cig dei lotti delle gare
		declare @DataInvio as datetime
		set @DataInvio=null
		--cerco su una gara monolotto
		select 
			top 1 @DataInvio= GARA.datainvio
			from 
			
				document_bando DETT_BANDO with(nolock) 
					--left join document_microlotti_dettagli DETT_GARA with(nolock) on DETT_GARA.tipodoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO') and isnull(voce,0)=0 and isnull(DETT_GARA.cig,'')=DC.CIG_MADRE 
					left join ctl_doc GARA with(nolock) on   Gara.id = DETT_BANDO.idHeader and GARA.StatoFunzionale <>'inlavorazione' and GARA.deleted=0
			 where Divisione_lotti = 0 and isnull(cig,'') = @Cig_Madre	
	
		if @DataInvio is null
		begin
			--cerco su una gara a lotti
			select 
			top 1 @DataInvio= GARA.datainvio
			from 
				 document_microlotti_dettagli DETT_GARA with(nolock) 
					left join ctl_doc GARA with(nolock) on   Gara.id = DETT_GARA.idHeader   and GARA.StatoFunzionale <>'inlavorazione' and GARA.deleted=0
			 where  DETT_GARA.tipodoc in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO') and isnull(voce,0)=0 and isnull(DETT_GARA.cig,'')=@Cig_Madre
		end
	end



	--verifico se esiste il doc di listino ordini e se ha righe
	--idDocListinoOrdini
	--PresenzaRigheListinoOrdini
	set @idDocListinoOrdini = 0
	select @idDocListinoOrdini = id from ctl_doc with (nolock) where linkeddoc =  @IdDoc and tipodoc='LISTINO_ORDINI' and Deleted = 0

	set @PresenzaRigheListinoOrdini = 0
	if @idDocListinoOrdini <> 0
	begin
		if exists (select top 1 id from document_microlotti_dettagli with (nolock) where idheader=@idDocListinoOrdini and tipodoc='LISTINO_ORDINI' )
			set @PresenzaRigheListinoOrdini = 1
	end

	select 
		
		D.* 
		, isnull( D.Total , 0 ) - ISNULL(@ImportoAllocabile,0) as ImportoAllocabile
		,@AppaltoVerde as Appalto_Verde
		,@Acquisto_Sociale as Acquisto_Sociale
		,@Modello as idModello
		,@DataInvio as DataPubblicazioneBando
		,@EmailFornitore as EmailFornitore
		,@TelefonoFornitore as TelefonoFornitore
		,@idDocListinoOrdini as idDocListinoOrdini
		,@PresenzaRigheListinoOrdini as PresenzaRigheListinoOrdini

		from 
			#D D

	
	





end

GO
