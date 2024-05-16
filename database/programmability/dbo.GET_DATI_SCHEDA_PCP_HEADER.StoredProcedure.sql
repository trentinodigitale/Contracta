USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_DATI_SCHEDA_PCP_HEADER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[GET_DATI_SCHEDA_PCP_HEADER] ( @IdGara int  )
AS
BEGIN

	SET NOCOUNT ON
	
	declare @OggettoGara nvarchar(max)
	declare @ProceduraGara as varchar(100)
	declare @tipoProcedura as varchar(100)
	declare @TipoBandoGara as varchar(100)
	declare @ImportoBaseAsta as float
	declare @ScadenzaOfferta as datetime
	declare @W9APOUSCOMP as varchar(10)

	--campi Ente Appaltante/Proponente
	declare @CFProponente as varchar(50)
	declare @CodiceAusaProponente as varchar(30)
	declare @CDCProponente as varchar(100)
	declare @CFAppaltante as varchar(50)
	declare @CodiceAusaAppaltante as varchar(30)
	declare @CDCAppaltante as varchar(100)
	declare @idAziProponente as varchar(50)
	declare @idAziAppaltante as varchar(50)
	declare @CIG as varchar(50)
	declare @TipoDoc_Innesco as varchar(100)
	declare @dataAdesione as datetime
	declare @Concessione as varchar(10)

	--campi ParitaDiGenereGenerazionale
	declare @Appalto_PNRR as varchar(20)
	declare @FLAG_PREVISIONE_QUOTA as varchar(10)
	declare @ID_MISURA_PREMIALE as varchar(10)
	declare @CUP as varchar(10)

	declare @QUOTA_FEMMINILE as varchar(10)
	declare @QUOTA_GIOVANILE as varchar(10)
	declare @ID_MOTIVO_DEROGA as varchar(10)



	select @TipoDoc_Innesco = tipodoc from CTL_DOC with (nolock) where id= @IdGara

	--recupero informazioni dalla gara
	select 
			@OggettoGara= body ,
			@ProceduraGara = ProceduraGara,
			@TipoBandoGara=TipoBandoGara,
			@ImportoBaseAsta= ImportoBaseAsta,
			@ScadenzaOfferta = DataScadenzaOfferta,
			@W9APOUSCOMP = case 
								when isnull(W9APOUSCOMP,'')='' or W9APOUSCOMP='' then 'false'
								else W9APOUSCOMP
							end,

			--campi Ente Appaltante/Proponente
			@CDCProponente = pcp_CodiceCentroDiCostoProponente,
			@idAziAppaltante = Azienda,
			@idAziProponente = isnull(EnteProponente,''),
			@Concessione = isnull(Concessione,'no'),
			--fine campi Ente Appaltante/Proponente

			--campi ParitaDiGenereGenerazionale
			@Appalto_PNRR = Appalto_PNRR,
			@FLAG_PREVISIONE_QUOTA = FLAG_PREVISIONE_QUOTA,
			@ID_MISURA_PREMIALE = ID_MISURA_PREMIALE,
			@CUP = CUP,
			@QUOTA_FEMMINILE = QUOTA_FEMMINILE ,
			@QUOTA_GIOVANILE = QUOTA_GIOVANILE,
			@ID_MOTIVO_DEROGA = ID_MOTIVO_DEROGA
			--fine campi ParitaDiGenereGenerazionale

		from 
			ctl_doc with (nolock) 
				inner join document_bando with (nolock) on idHeader = id
		where id= @IdGara

	
	--SE INNESCO DA ODC RECUPERO I CAMPI IN MODO DIVERSO
	if @TipoDoc_Innesco = 'ODC'
	begin
		select 
			@OggettoGara = O.Note,
			@idAziAppaltante = O.Azienda,
			@CIG = isnull(O_Dett.CIG_MADRE,''),
			@dataAdesione = O.[data],
			@Concessione = 'no'
		from 
				ctl_doc O with (nolock) 
					inner join document_odc O_Dett with (nolock) on O_Dett.rda_id = O.id
			where O.id= @IdGara
	end

	--SE INNESCO DA ODA RECUPERO I CAMPI IN MODO DIVERSO
	IF @TipoDoc_Innesco = 'ODA'
	BEGIN

		SELECT  @OggettoGara = O.Note,
				@idAziAppaltante = O.Azienda,
				@CIG = isnull(O_Dett.CIG,''),
				@dataAdesione = O.[data],
				@Concessione = 'no'
			FROM ctl_doc O with (nolock) 
					inner join Document_ODA O_Dett with (nolock) on O_Dett.idHeader = O.id
			WHERE O.id= @IdGara

	END

	--Recupero dati dell'ente Appaltante
	select
		@CFAppaltante = CF.vatValore_FT,
		@CDCAppaltante = pcp_CodiceCentroDiCosto,
		@CodiceAusaAppaltante = case 
									when isnull(Ap.pcp_codice_ausa,'') = '' then  Au.codice_ausa
									when Ap.pcp_codice_ausa = '' then Au.codice_ausa
									else Ap.pcp_codice_ausa
								end 
		from 
			Document_PCP_Appalto Ap with(nolock)
				left join DM_Attributi CF with(nolock) on CF.dztNome = 'codicefiscale' and CF.lnk = @idAziAppaltante
				left join PCP_CodiciAUSA Au with(nolock) on Au.codice_fiscale = CF.vatValore_FT
		where Ap.idHeader = @IdGara


	-- Recupero dati dell'ente Proponente se presente
	if @idAziProponente <> ''
	begin
		
		--Prendo solo la parte dell'idazi
		set @idAziProponente = SUBSTRING(@idAziProponente, 1, CHARINDEX('#', @idAziProponente) - 1)
		
		select 
			@CFProponente = vatValore_FT,
			@CodiceAusaProponente = Au.codice_ausa
			from 
				Document_Bando B with(nolock)
				left join DM_Attributi CF with(nolock) on CF.dztNome = 'codicefiscale' and lnk = @idAziProponente
					left join PCP_CodiciAUSA Au with(nolock) on Au.codice_fiscale = CF.vatValore_FT 
			where B.idHeader = @IdGara

	end
		


	--tipoprocedura
	--"codice":"open", Aperta
	--"codice":"restricted",
	--"codice":"neg-w-call","Negoziata con previa indizione di gara / competitiva con negoziazione",
	--"codice":"neg-wo-call","Negoziata senza previa indizione di gara",
	--"codice":"comp-dial","it": "Dialogo competitivo",  ??
	--"codice":"innovation","it": "Partenariato per l'innovazione", ??
	--"codice":"oth-single","it": "Altra procedura a fase unica", ??
	--"codice":"oth-mult","it": "Altra procedura a più fasi", ??
	--"codice":"comp-tend","it": "Procedura di gara", ??
	
	set @tipoProcedura = 
						case 
							when @ProceduraGara='15476' then 'open' -- APERTA
							when @ProceduraGara='15477' then 'restricted' -- RISTRETTA
							when @ProceduraGara='15478' and @TipoBandoGara='1' then 'neg-w-call' -- NEGOZIATA CON AVVISO
							when @ProceduraGara='15478' and @TipoBandoGara='3' then 'neg-wo-call' -- NEGOZIATA INVITO (senza avviso)				
							else	'comp-tend'
						end

	--Compongo la select finale da ritornare
	select 

		@OggettoGara as Oggetto

		,ltrim( str( @ImportoBaseAsta , 25 , 2 ) )  as importo

		,case 
			--per la scheda AD2_25 "Altra procedura a fase unica" 
			when pcp_TipoScheda ='AD2_25' then 'oth-single'
			else @tipoProcedura 
		end as tipoProcedura
		
		,pcp_OpereUrbanizzateScomputo as  pcp_opereUrbanizzazioneScomputo
		
		,'' as modalitaRiaggiudicazioneAffidamento -- DA CAPIRE

		--,'5' as strumentiSvolgimentoProcedure  -- PER ADESSO FISSO POI CAPIAMO
		, P.strumentiSvolgimentoProcedure
		
		, dbo.GetStrTecDateUTC(@ScadenzaOfferta) as oraScadenzaPresentazioneOfferte
		
		, @W9APOUSCOMP as W9APOUSCOMP
		
		, --per le schede AD se la versione >='01.00.01' restituisco valorizzato il campo 
		  --datiBaseDocumenti_url altrimenti lo restituisco vuoto
		  case
			when pcp_TipoScheda in ('AD3','AD5','AD2_25','P7_1_2', 'P7_1_3' , 'P7_2') and  pcp_VersioneScheda >='01.00.01' then cn16_CallForTendersDocumentReference_ExternalRef 
			else '' 
		  end AS datiBaseDocumenti_url

		, 
			--per la P2_16 se procedura NON aperta (ProceduraGara=15476) ritorno scadenzaPresentazioneInvito valorizzato
			--altrimenti vuoto
			case 
				when pcp_TipoScheda in ( 'P2_16' ) AND @ProceduraGara <> '15476'
					then dbo.GetStrTecDateUTC(@ScadenzaOfferta) 
				else ''
			end as scadenzaPresentazioneInvito

		-- INIZIO Dati relativi a ente Appaltante e Proponente
		-- utilizzati per costruire la parte "StazioneAppalatanti" delle schede
		,@CFAppaltante as codiceFiscaleAppaltante
		,@CodiceAusaAppaltante as codiceAusaAppaltante
		,@CDCAppaltante as centroDiCostoAppaltante
		,@CFProponente as codiceFiscaleProponente
		,@CodiceAusaProponente as CodiceAusaProponente
		,@CDCProponente as centroDiCostoProponente
		-- FINE Dati relativi a ente Appaltante e Proponente

		--Document_pcp_appalto
		, [pcp_test], [pcp_CodiceCentroDiCosto], [pcp_FunzioniSvolte], [pcp_MotivoUrgenza], [pcp_LinkDocumenti], [pcp_CondizioniNegoziata], [pcp_ContrattiDisposizioniParticolari], [pcp_ModalitaAcquisizione], [pcp_OggettoPrincipaleContratto], [pcp_PrestazioniComprese], [pcp_ServizioPubblicoLocale], [pcp_PrevedeRipetizioniCompl], [pcp_Dl50], [pcp_CodiceCUI], [pcp_TipologiaLavoro], [pcp_PrevedeRipetizioniOpzioni], [pcp_Categoria], [pcp_CodiceAppalto], [pcp_TipoScheda], [pcp_VersioneScheda], [pcp_Codice_Ausa], [pcp_CodiceScheda], [pcp_CodiceAvviso], [pcp_RelazioneUnicaSulleProcedure], [pcp_OpereUrbanizzateScomputo], [MOTIVO_COLLEGAMENTO], [MOTIVAZIONE_CIG], [TIPO_FINANZIAMENTO], [pcp_iniziativeNonSoddisfacenti], [pcp_saNonSoggettaObblighi24Dicembre2015], [pcp_lavoroOAcquistoPrevistoInProgrammazione], [pcp_cigCollegato], [pcp_ImportoFinanziamento], [pcp_proceduraAccelerata], [strumentiSvolgimentoProcedure]
		, [GIUSTIFICAZIONE_AGG_DIRETTA] as giustificazioniAggiudicazioneDiretta

		--Document_E_FORM_CONTRACT_NOTICE
		, [cn16_AuctionConstraintIndicator], [cn16_ContractingSystemTypeCode_framework], [cn16_FundingProgramCode_eu_funded], [cn16_FinancingIdentifier], [cn16_FundingProgramCode_eu_programme], [cn16_Funding_Description], [cn16_TendererRequirementTypeCode_reserved_proc], [cn16_ExecutionRequirementCode_reserved_execution], [cn16_CallForTendersDocumentReference_DocumentType], [cn16_CallForTendersDocumentReference_ExternalRef], [CN16_CODICE_APPALTO], [cn16_Funding_FinancingIdentifier], [cn16_OrgRicorso_Name], [cn16_OrgRicorso_CompanyID], [cn16_OrgRicorso_CityName], [cn16_OrgRicorso_countryCode], [cn16_OrgRicorso_ElectronicMail], [cn16_OrgRicorso_Telephone], [cn16_ProcessJustification_accelerated_procedure], [cn16_ProcessJustification_ProcessReason], [cn16_publication_id], [cn16_FundingProgramCode], [cn16_FundingProgram_Description], [cn16_OrgRicorso_codnuts], [cn16_OrgRicorso_cap]
		
		--INIZIO info agg utilizzate per AD4 
		, @CIG as cig
		, dbo.GetStrTecDateUTC(@dataAdesione)  as dataAdesione
		, @Concessione as Concessione
		--FINE info agg utilizzate per AD4

		--INIZIO campi ParitaDiGenereGenerazionale
		, @Appalto_PNRR as Appalto_PNRR
		, @FLAG_PREVISIONE_QUOTA as FLAG_PREVISIONE_QUOTA
		, @ID_MISURA_PREMIALE as ID_MISURA_PREMIALE
		, @CUP as CUP
		, @QUOTA_FEMMINILE as QUOTA_FEMMINILE
		, @QUOTA_GIOVANILE as QUOTA_GIOVANILE
		, @ID_MOTIVO_DEROGA as ID_MOTIVO_DEROGA
		-- FINE campi ParitaDiGenereGenerazionale

		from 
			document_pcp_appalto P with (nolock) 
				left join Document_E_FORM_CONTRACT_NOTICE E with (nolock) on E.idHeader = P.idHeader
		where 
			P.idHeader= @IdGara

	

END



GO
