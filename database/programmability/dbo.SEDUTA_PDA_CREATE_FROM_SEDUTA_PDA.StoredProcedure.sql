USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SEDUTA_PDA_CREATE_FROM_SEDUTA_PDA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[SEDUTA_PDA_CREATE_FROM_SEDUTA_PDA] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT

	declare @IdMittenteCom as int
	declare @TipoSeduta as varchar(50)
	declare @IdVerbale as INT
	declare @IdVerbale_New as INT
	declare @Guid as varchar(200)

	set @Errore = ''

	if @Errore = '' 
	begin

		-- cerco una versione precedente del documento 
		set @id = null

		select @id = id from CTL_DOC 
			where ISNULL(Versione,'') = cast(@idDoc  as varchar(200))
						and deleted = 0 
						and TipoDoc = 'SEDUTA_PDA'
						and StatoFunzionale = 'InLavorazione' 
						and idpfu = @IdUser

		if @id is null
		begin
			   -- altrimenti lo creo
			   set @Guid = NEWID ()

				INSERT into CTL_DOC (
					 [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], 
					 [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], 
					 [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], 
					 [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], 
					 [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], 
					 [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]
					 )
					select 
							 @IdUser, [IdDoc], [TipoDoc], 'Saved', getdate(), '', [PrevDoc], 0, [Titolo], [Body], 
							 [Azienda], [StrutturaAziendale], null, [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], 
							 [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], 
							 [JumpCheck], 'InLavorazione', [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], 
							 [NumeroDocumento], [DataDocumento], @idDoc, [VersioneLinkedDoc], @Guid, [idPfuInCharge], 
							 [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]
					 	
					 from CTL_DOC
						where Id= @idDoc

				set @id = SCOPE_IDENTITY()	--@@identity

				-- copia altri dati
				insert into [dbo].[CTL_DOC_Value]
						( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )

					select @id, [DSE_ID], [Row], [DZT_Name], [Value]
						from [dbo].[CTL_DOC_Value]
							where [IdHeader] = @idDoc

				-- inserisce colonna NotEditable
				set @TipoSeduta = null

				select @TipoSeduta = value from [CTL_DOC_Value]
					where [IdHeader] = @idDoc and DSE_ID = 'DATE' and DZT_Name = 'TipoSeduta'

				if @TipoSeduta = 'Virtuale'
					insert into [dbo].[CTL_DOC_Value]
						( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )

					values( @id, 'DATE', 0, 'NotEditable', ' TipoSeduta ' )


				-- riporto gli allegati / verbali della versione precedente
				insert into CTL_DOC_ALLEGATI ( [idHeader], [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione], [Interno], [Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], [EvidenzaPubblica], [RichiediFirma], [FirmeRichieste], [AllegatoRisposta], [EsitoRiga])
					select @id as [idHeader], [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione], [Interno], [Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], [EvidenzaPubblica], [RichiediFirma], [FirmeRichieste], [AllegatoRisposta], [EsitoRiga]
						from CTL_DOC_ALLEGATI
						where idheader = @idDoc
						order by [idrow]
				
				-- copia verbale se presente
				--set @IdVerbale = NULL
				--set @IdVerbale_New = NULL

				--select @IdVerbale=id from CTL_DOC 
				--		where	LinkedDoc  = @idDoc 
				--				and Deleted = 0 
				--				and TipoDoc = 'VERBALEGARA'

				--if not (@IdVerbale is null)
				--begin

				--	-- inserisce verbale
				--	INSERT into CTL_DOC (
				--		 [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], 
				--		 [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], 
				--		 [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], 
				--		 [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], 
				--		 [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], 
				--		 [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]
				--	 )
				--	select 
				--		@IdUser, [IdDoc], [TipoDoc], 'Saved', getdate(), '', [PrevDoc], 0, [Titolo], [Body], 
				--		[Azienda], [StrutturaAziendale], null, [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], 
				--		[Fascicolo], [Note], [DataProtocolloGenerale], @id, [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], 
				--		[JumpCheck], 'InLavorazione', [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], 
				--		[NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], 
				--		[CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]
					 	
				--	 from CTL_DOC
				--		where Id= @IdVerbale

				--	set @IdVerbale_New = SCOPE_IDENTITY()

				--	-- inserisce nella [Document_VerbaleGara]
				--	insert into [dbo].[Document_VerbaleGara]
				--		( [IdHeader], [ProceduraGara], [CriterioAggiudicazioneGara], [Testata], [PiePagina], [Testata2], 
				--		[Multiplo], [IdTipoVerbale], [TipoVerbale], [TipoSorgente], [CriterioFormulazioneOfferte] )
				--	select
				--		@IdVerbale_New, [ProceduraGara], [CriterioAggiudicazioneGara], [Testata], [PiePagina], [Testata2], 
				--		[Multiplo], [IdTipoVerbale], [TipoVerbale], [TipoSorgente], [CriterioFormulazioneOfferte]

				--	from [dbo].[Document_VerbaleGara]
				--		where [IdHeader] = @IdVerbale

				--	-- inserisce nella [Document_VerbaleGara_Dettagli]
				--	insert into [dbo].Document_VerbaleGara_Dettagli
				--		( [IdHeader], [Pos], [SelRow], [TitoloSezione], [DescrizioneEstesa], [Edit], [CanEdit], [Expression] )
				--	select
				--		@IdVerbale_New, [Pos], [SelRow], [TitoloSezione], [DescrizioneEstesa], [Edit], [CanEdit], [Expression]

				--	from [dbo].Document_VerbaleGara_Dettagli
				--		where [IdHeader] = @IdVerbale



				--end

				---- copia record della tabella [dbo].[Document_PDA_Sedute]
				--if exists (select * from [dbo].[Document_PDA_Sedute] where [idSeduta] = @idDoc)
				--begin

				--	insert into [dbo].[Document_PDA_Sedute]
				--	 ( [idHeader], [NumeroSeduta], [TipoSeduta], [Descrizione], [DataInizio], [DataFine], [idPdA], 
				--	  [idVerbale], [idSeduta], [Allegato] )

				--	select 
				--		[idHeader], [NumeroSeduta], [TipoSeduta], [Descrizione], [DataInizio], [DataFine], [idPdA], 
				--	  @IdVerbale_New, @id, [Allegato]
				--		 from [dbo].[Document_PDA_Sedute]
				--			where [idSeduta] = @idDoc

				--end

				
		end
	end
		
	



	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END








GO
