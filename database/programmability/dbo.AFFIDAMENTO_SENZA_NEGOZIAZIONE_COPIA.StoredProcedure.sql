USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AFFIDAMENTO_SENZA_NEGOZIAZIONE_COPIA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AFFIDAMENTO_SENZA_NEGOZIAZIONE_COPIA] ( @idDoc int , @IdUser int ,@IdNewDoc int = 0 output, @RIFIUTA_PROSEGUI int = 0 )
AS
BEGIN
    
	SET NOCOUNT ON

	declare @IdAzi as int

	--Recupero l'azienda
	select 
		@IdAzi = pfuIdAzi
		from
			ProfiliUtente with(nolock)
		where idpfu = @IdUser


	--Creo il Record principale CTL_DOC
	insert into CTL_DOC ( 
							  IdPfu
							, Titolo
							, TipoDoc
							, Body
							, Azienda
							, StatoFunzionale
							, idPfuInCharge
							, Versione
							, CanaleNotifica
						) 
		select 
			  @IdUser as IdPfu
			, 'Copia di ' + Titolo as Titolo
			, TipoDoc
			, Body
			, @IdAzi as Azienda
			, 'InLavorazione' as StatoFunzionale
			, @IdUser as IdpfuInCharge
			, Versione
			, CanaleNotifica
		from 
			CTL_DOC with(nolock)
		where id = @idDoc


	--Recupero l'idDoc appena generato
	set @IdNewDoc = SCOPE_IDENTITY()


	-- Riporto i valori contenuti nella CTL_DOC_VALUE
	insert into CTL_DOC_VALUE (
								  IdHeader
								, DSE_ID
								, DZT_Name
								, Row
								, Value
							  )
		select 
			  @IdNewDoc
			, DSE_ID
			, DZT_Name
			, Row
			, Value
		from 
			CTL_DOC_VALUE with(nolock)
		where DZT_Name <> 'UserRUP' -- Non riporto il RUP avvalorato
			and idheader = @idDoc


	-- Inserisco il RUP ma lo setto vuoto
		insert into CTL_DOC_VALUE (
								  IdHeader
								, DSE_ID
								, DZT_Name
								, Row
								, Value
							  )
		select 
			  @IdNewDoc as IdHeader
			, 'InfoTec_comune' as DSE_ID
			, 'UserRUP' as DZT_Name
			, 0 as Row
			, '' as Value


	-- Riporto eventuali modelli dinamici settati
	insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name ) 
		select 
			  @IdNewDoc as IdHeader
			, DSE_ID
			, MOD_Name
		from
			CTL_DOC_SECTION_MODEL with(nolock)
		where idheader = @idDoc


	-- Popolo la Document_Bando
	insert into Document_Bando (
									  idheader
									, TipoSoglia
									, ImportoBaseAsta
									, CUP
									, TipoAppaltoGara
									, Divisione_lotti
									--, DirezioneEspletante
									, EvidenzaPubblica
									, StipulaDelContratto
									, Appalto_PNRR
									, Appalto_PNC
									, Motivazione_Appalto_PNC
									, Motivazione_Appalto_PNRR
									, FLAG_PREVISIONE_QUOTA
									, QUOTA_FEMMINILE
									, QUOTA_GIOVANILE
									, ID_MOTIVO_DEROGA
									, FLAG_MISURE_PREMIALI
									, ID_MISURA_PREMIALE
								)
		select 
			  @IdNewDoc as IdHeader
			, TipoSoglia
			, ImportoBaseAsta
			, CUP
			, TipoAppaltoGara
			, Divisione_lotti
			--, DirezioneEspletante
			, EvidenzaPubblica
			, StipulaDelContratto
			, Appalto_PNRR
			, Appalto_PNC
			, Motivazione_Appalto_PNC
			, Motivazione_Appalto_PNRR
			, FLAG_PREVISIONE_QUOTA
			, QUOTA_FEMMINILE
			, QUOTA_GIOVANILE
			, ID_MOTIVO_DEROGA
			, FLAG_MISURE_PREMIALI
			, ID_MISURA_PREMIALE
		from
			Document_Bando with(nolock)
		where idheader = @idDoc


	-- Popolo la Document_PCP_Appalto
	Insert into Document_PCP_Appalto (
										  idheader
										, pcp_Categoria
										, pcp_TipoScheda
										, pcp_VersioneScheda
										, pcp_CodiceCentroDiCosto
										, pcp_FunzioniSvolte
										, pcp_LinkDocumenti
										, pcp_MotivoUrgenza
										, pcp_SommeADisposizione
										, pcp_RelazioneUnicaSulleProcedure
									 )
		select
			  @IdNewDoc as IdHeader
			, pcp_Categoria
			, pcp_TipoScheda
			, pcp_VersioneScheda
			, pcp_CodiceCentroDiCosto
			, pcp_FunzioniSvolte
			, pcp_LinkDocumenti
			, pcp_MotivoUrgenza
			, pcp_SommeADisposizione
			, pcp_RelazioneUnicaSulleProcedure
		from
			Document_PCP_Appalto with(nolock)
		where idheader = @idDoc


	-- Popolo la tabella Document_E_FORM_CONTRACT_NOTICE
	Insert into Document_E_FORM_CONTRACT_NOTICE (
													  idheader
													, CN16_CODICE_APPALTO
													, cn16_CallForTendersDocumentReference_ExternalRef
												)
		select
			  @IdNewDoc as idHeader
			, lower(newid()) as CN16_CODICE_APPALTO
			, cn16_CallForTendersDocumentReference_ExternalRef
		from
			Document_E_FORM_CONTRACT_NOTICE with(nolock)
		where idheader = @idDoc


	-- Popolo la tabella Document_MicroLotti_Dettagli
	Insert into Document_MicroLotti_Dettagli (
												idheader
												, TipoDoc
												, NumeroLotto
												, Descrizione
												, Voce
												, NumeroRiga
												, PesoVoce
												, ValoreImportoLotto
												, pcp_Categoria
											 )
		select
			  @IdNewDoc as idHeader
			, TipoDoc
			, NumeroLotto
			, Descrizione
			, Voce
			, NumeroRiga
			, PesoVoce
			, ValoreImportoLotto
			, pcp_Categoria
		from
			Document_MicroLotti_Dettagli with(nolock)
		where idheader = @idDoc


END

GO
