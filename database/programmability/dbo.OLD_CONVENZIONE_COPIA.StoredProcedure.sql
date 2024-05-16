USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONVENZIONE_COPIA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[OLD_CONVENZIONE_COPIA] 
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
	declare @contatore as varchar(50)	
	declare @identifIniziativa varchar(500)
	declare @notEdit varchar(4000)
	set @identifIniziativa = NULL
	set @notEdit = null


	-- se l'utente che sta creando la convenzione non è dell'agenzia
	if not exists ( select idpfu from profiliutente with(Nolock) where idpfu = @IdUser and pfuIdAzi = 35152001 )
	begin
		set @notedit = ' IdentificativoIniziativa '
	end

	-- altrimenti lo creo
	INSERT into CTL_DOC 
	(
		IdPfu,  TipoDoc, 
		Titolo,LinkedDoc,idPfuInCharge,jumpcheck,Caption,PrevDoc 
		)
	select 
		@IdUser  
		,'CONVENZIONE' 
		,'Copia di ' + Titolo
		,LinkedDoc
		,@IdUser
		,jumpcheck
		,Caption
		,C.id
					

	from CTL_DOC C with (nolock)
		inner join Document_Convenzione DC with (nolock) on C.id = DC.id
			where C.id = @idDoc and C.tipodoc='CONVENZIONE'

	--set @id = @@identity	
	set @id = SCOPE_IDENTITY() 
				
	exec CTL_GetNewProtocol 'CONVENZIONE','',@contatore output
				
	--informzioni della convenzione
	insert into Document_Convenzione (ID,DOC_Owner,DataCreazione,AZI_Dest,IdentificativoIniziativa,Macro_Convenzione,CIG_MADRE,NumOrd,Mandataria,ReferenteFornitore,ReferenteFornitoreHide,CodiceFiscaleReferente,RichiestaFirma,GestioneQuote,TipoConvenzione,ConAccessori,Valuta,IVA,TipoImporto,DataInizio,DataFine,RichiediFirmaOrdine,OrdinativiIntegrativi,ImportoMinimoOrdinativo,TipoScadenzaOrdinativo,NumeroMesi,DataScadenzaOrdinativo,Merceologia,Ambito,DescrizioneEstesa)
		--select @id,@IdUser,getdate(),AZI_Dest,IdentificativoIniziativa,Macro_Convenzione,CIG_MADRE,@contatore,Mandataria,ReferenteFornitore,ReferenteFornitoreHide,CodiceFiscaleReferente,RichiestaFirma,GestioneQuote,TipoConvenzione,ConAccessori,Valuta,IVA,TipoImporto,DataInizio,DataFine,RichiediFirmaOrdine,OrdinativiIntegrativi,ImportoMinimoOrdinativo,TipoScadenzaOrdinativo,NumeroMesi,DataScadenzaOrdinativo,Merceologia,Ambito
		select @id,@IdUser,getdate(),null,IdentificativoIniziativa,Macro_Convenzione,null,@contatore,null,null,null,null,RichiestaFirma,GestioneQuote,TipoConvenzione,ConAccessori,Valuta,IVA,TipoImporto,null,null,RichiediFirmaOrdine,OrdinativiIntegrativi,ImportoMinimoOrdinativo,TipoScadenzaOrdinativo,NumeroMesi,null,Merceologia,Ambito,DescrizioneEstesa
			from document_convenzione with (nolock)
				where id=@idDoc

	-- copia dati protocollo
	insert into Document_dati_protocollo ( idHeader,fascicoloSecondario)
		-- values (  @Id )
		select  @Id,fascicoloSecondario
			from Document_dati_protocollo with (nolock)
				where idHeader=@idDoc

	--informzioni aggiuntive della convenzione				
	insert into ctl_doc_Value (idheader,DSE_ID,DZT_Name,Value)
		select @id,DSE_ID,DZT_Name,Value
			from  CTL_DOC_Value with (nolock)
				where idheader=@idDoc and DSE_ID='INFO_AGGIUNTIVE'

	insert into ctl_doc_Value (idheader,DSE_ID,DZT_Name,Value)
		select @id,DSE_ID,DZT_Name,Value
			from  CTL_DOC_Value with (nolock)
				where idheader=@idDoc and DSE_ID='STRUTTURA'
				
				
	--informzioni prodotti della convenzione
	insert into ctl_doc_Value (idheader,DSE_ID,DZT_Name,Value)
		select @id,DSE_ID,DZT_Name,Value
			from  CTL_DOC_Value with (nolock)
				where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI'

	---------------------------------------------------------------------
	-- MODELLO PRODOTTI CONVENZIONE
	---------------------------------------------------------------------
	declare @IdModello varchar(500)
	declare @IdModelloOld varchar(500)
	declare @NomeModello varchar(500)
	declare @NomeModelloBase varchar(500)
	declare @NomeModello2 varchar(500)
	declare @NomeModello3 varchar(500)
	declare @NomeModelloOld varchar(500)
	declare @NomeModelloOld2 varchar(500)
	declare @StatoModello varchar(500)
	declare @PrevDoc int
	declare @IdModelloNew int

	set @IdModello = NULL
	set @NomeModello = NULL

	select @NomeModelloOld2 = mod_name from CTL_DOC_SECTION_MODEL with (nolock) 
		where IdHeader = @idDoc and DSE_ID='PRODOTTI'

	-- legge i dati del modello attuale
	select @IdModello=value
		from CTL_DOC_Value with (nolock)
			where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI'
					and DZT_Name = 'id_modello'

	set @IdModelloOld = @IdModello
	
	select @NomeModello=value
		from CTL_DOC_Value with (nolock)
			where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI'
					and DZT_Name = 'Tipo_Modello_Convenzione'

	-- se il modello non esiste non lo copio altrimenti vado a fare i controlli
	if (not (@IdModello is NULL)) and @IdModello <> ''
	begin
				
		-- vedo se il modello è ancora valido
		--select @StatoModello=StatoFunzionale ,@PrevDoc=PREVdoc from ctl_doc with (nolock)  
		--	where tipodoc = 'CONFIG_MODELLI' and deleted = 0 
		--	and JumpCheck = 'CONVENZIONI' 
		--	and id = @IdModello

		---- se lo stato del modello è pubblicato o se in lavorazione allora è buono da usare
		--if @StatoModello <> 'Pubblicato' and @StatoModello <> 'InLavorazione'
		--begin
		--	-- se lo stato è Variato cerco un modello valido successivo
		--	set @IdModello = NULL
		--	set @NomeModello = NULL

		--	select top 1 @IdModello=id,@NomeModello=titolo from ctl_doc with (nolock)  
		--		where tipodoc = 'CONFIG_MODELLI' and deleted = 0 							
		--				and JumpCheck = 'CONVENZIONI' 
		--				and StatoFunzionale = 'Pubblicato'
		--				and prevdoc=@IdModello and id>@IdModello
		--		order by id desc
		--end

		-- vedo se il modello BASE è ancora valido
		declare @nome varchar(500)

		select @nome=titolo from ctl_doc with (nolock)  
			where tipodoc = 'CONFIG_MODELLI' and deleted = 0 
			and JumpCheck = 'CONVENZIONI' 
			and id = @IdModello

		set @nome = replace(@nome, '_' + cast(@IdModello as varchar(15)),'' ) 

		-- cerca il modello base pubblicato
		--if @StatoModello <> 'Pubblicato' and @StatoModello <> 'InLavorazione'
		--begin
			-- se lo stato è Variato cerco un modello valido successivo
			set @IdModello = NULL
			set @NomeModello = NULL

			select top 1 @IdModello=id,@NomeModello=titolo from ctl_doc with (nolock)  
				where tipodoc = 'CONFIG_MODELLI' and deleted = 0 							
						and JumpCheck = 'CONVENZIONI' 
						and StatoFunzionale = 'Pubblicato'
						and ISNULL(LinkedDoc,0) = 0						
						and titolo like @nome + '%'
				order by id desc
		--end

		if @IdModello is NULL
		begin
			-- riprova la select eliminando un altro eventuale numero in coda al nome
			declare @reversed varchar(500)
			declare @fine varchar(100)
			declare @ind int

			set @reversed = REVERSE(@nome)
			set @ind = CHARINDEX('_', @reversed)

			if @ind>0 
			begin
				set @fine = reverse(SUBSTRING(@reversed,1, @ind-1))
				
				set @nome = replace(@nome, '_' + @fine ,'' ) 
				set @IdModello = NULL

				select top 1 @IdModello=id,@NomeModello=titolo from ctl_doc with (nolock)  
				where tipodoc = 'CONFIG_MODELLI' and deleted = 0 							
						and JumpCheck = 'CONVENZIONI' 
						and StatoFunzionale = 'Pubblicato'
						and ISNULL(LinkedDoc,0) = 0						
						and titolo like @nome + '%'
				order by id desc

				-- riprova una seconda volta in caso di fallimento
				if @IdModello is NULL
				begin
					set @reversed = REVERSE(@nome)
					set @ind = CHARINDEX('_', @reversed)

					if @ind>0 
					begin
						set @fine = reverse(SUBSTRING(@reversed,1, @ind-1))
				
						set @nome = replace(@nome, '_' + @fine ,'' ) 
						set @IdModello = NULL

						select top 1 @IdModello=id,@NomeModello=titolo from ctl_doc with (nolock)  
						where tipodoc = 'CONFIG_MODELLI' and deleted = 0 							
								and JumpCheck = 'CONVENZIONI' 
								and StatoFunzionale = 'Pubblicato'
								and ISNULL(LinkedDoc,0) = 0						
								and titolo like @nome + '%'
						order by id desc

					end


				end

			end

		end
					
					

	end

	

	-- se esiste modello lo copia
	if (not (@IdModello is NULL)) and @IdModello <> ''
	begin		
							
		select  @NomeModelloBase = [Titolo] from CTL_DOC with (nolock) where id = @IdModello
		
		-- copia il modello della convenzione
		set @IdModello = @IdModelloOld   ---!!!!! here !!!!!!

		select  @NomeModello = [Titolo] from CTL_DOC with (nolock) where id = @IdModello
		set @NomeModelloOld = @NomeModello

		-- cerca la parte numerica da sostiture nel nome modello dopo averlo copiato
		declare @cnt int
		declare @out varchar(500)

		--select @cnt = count(*) from dbo.Split(@NomeModello ,'_')
		--set @out = dbo.GetPos(@NomeModello,'_',@cnt)

		-- duplica modello nella ctl_doc
		insert into CTL_DOC
			( [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale] )
		select
			@IdUser, [IdDoc], [TipoDoc], [StatoDoc], getdate(), null, [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], null, [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], @id, [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], 'InLavorazione', [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], @IdUser , [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]
		from CTL_DOC with (nolock)
			where id = @IdModello

		--set @IdModelloNew = @@identity
		set @IdModelloNew = SCOPE_IDENTITY() 

		insert into ctl_doc_Value (idheader,DSE_ID,DZT_Name,Value,row)
			select @IdModelloNew,DSE_ID,DZT_Name,Value,Row
				from  CTL_DOC_Value with (nolock)
					where idheader=@IdModello 

		-- nuovo nome modello
		
		--set @NomeModello = @NomeModello + '_' + cast(@IdModelloNew as varchar(15))
		set @NomeModello = @NomeModelloBase + '_' + cast(@IdModelloNew as varchar(15))

		-- nome esteso da inserire nella CTL_DOC_SECTION_MODEL
		set @NomeModello3 = 'MODELLO_BASE_CONVENZIONI_' + @NomeModello  + '_MOD_Convenzione'

		update CTL_DOC set [Titolo] = @NomeModello where id = @IdModelloNew

		--forzo la sentinella a ERRORE sul nuovo modello per forzare il conferma sul modello
	    update CTL_DOC_VALUE set Value='ERRORE' where IdHeader=@IdModelloNew and DSE_ID='STATO_MODELLO' and DZT_Name='Stato_Modello_Gara'
		
		-- copia i dati nelle CTL_Models
		insert into CTL_Models( MOD_ID, MOD_Name, MOD_DescML, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template )
			select @NomeModello3, @NomeModello3, @NomeModello3, MOD_Type, MOD_Sys, MOD_help, MOD_Param, MOD_Module, MOD_Template 
				from CTL_Models  with(nolock) 
					--where mod_id = @NomeModelloOld2 
					where mod_id = 'MODELLO_BASE_CONVENZIONI_' + @NomeModelloOld  + '_MOD_Convenzione'
			
		INSERT INTO CTL_ModelAttributes ( MA_MOD_ID, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module)
			select @NomeModello3, MA_DZT_Name, MA_DescML, MA_Pos, MA_Len, MA_Order, MA_Module
				from CTL_ModelAttributes with(nolock, index (IX_CTL_ModelAttributes_MA_MOD_ID)) 				   
				   --where MA_MOD_ID = @NomeModelloOld2 
				   where MA_MOD_ID = 'MODELLO_BASE_CONVENZIONI_' + @NomeModelloOld  + '_MOD_Convenzione'
		
		INSERT INTO CTL_ModelAttributeProperties (MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module)
			select @NomeModello3, MAP_MA_DZT_Name, MAP_Propety, MAP_Value, MAP_Module
				from CTL_ModelAttributeProperties with(nolock,index(IX_CTL_ModelAttributeProperties_MAP_MA_MOD_ID)) 				   
				   --where  MAP_MA_MOD_ID = @NomeModelloOld2 
				   where  MAP_MA_MOD_ID = 'MODELLO_BASE_CONVENZIONI_' + @NomeModelloOld  + '_MOD_Convenzione'


		-- salva il modello per la convenzione	
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			select @id, DSE_ID, @NomeModello3
				from CTL_DOC_SECTION_MODEL
					where IdHeader=@idDoc

		-- copia i vincoli
		insert into Document_Vincoli ( IdHeader, Espressione, Descrizione, EsitoRiga, Seleziona,[contesto_vincoli])
			select @IdModelloNew,Espressione, Descrizione, EsitoRiga, Seleziona,[contesto_vincoli]
				from Document_Vincoli  with (nolock)
				where IdHeader=@IdModello
				order by IdRow

		insert into CTL_DOC_SECTION_MODEL (Idheader,DSE_ID,MOD_NAME)
			Values(@IdModelloNew,'TESTATA','CONFIG_MODELLI_LOTTI_TESTATA_GARA')

		insert into CTL_DOC_SECTION_MODEL (Idheader,DSE_ID,MOD_NAME)
			Values(@IdModelloNew,'MODELLI','CONFIG_MODELLI_CONVENZIONI_MODELLI')

		-- sostituisce i dati per la convenzione mettendo il nuovo modello
		update CTL_DOC_Value
			set Value = @IdModelloNew
				where idheader=@id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name = 'id_modello'
					
		update CTL_DOC_Value
			set Value = @NomeModello
				where idheader=@id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name = 'Tipo_Modello_Convenzione'
					
		--set @NomeModello2 = replace(@NomeModello,  '_' + cast(@IdModelloNew as varchar(15)), '')		
		set @NomeModello2 = @NomeModelloBase
		
		if exists (select [value] from 	CTL_DOC_Value with (nolock)
						where idheader=@id and DSE_ID='TESTATA_PRODOTTI' 
							and DZT_Name = 'Tipo_Modello_Convenzione_Scelta')
		begin
		update CTL_DOC_Value
			set Value = @NomeModello2
				where idheader=@id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name = 'Tipo_Modello_Convenzione_Scelta'	
		end
		else
		begin
			insert into CTL_DOC_Value
				(idheader,DSE_ID,DZT_Name,[value])
			values
				(@id,'TESTATA_PRODOTTI','Tipo_Modello_Convenzione_Scelta',@NomeModello2)
		end

		
					
		if exists (select [value] from 	CTL_DOC_Value with (nolock)
						where idheader=@id and DSE_ID='TESTATA_PRODOTTI' 
							and DZT_Name = 'TipoBandoSceltaHide')
		begin
			update CTL_DOC_Value
				set Value = @NomeModello2
					where idheader=@id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name = 'TipoBandoSceltaHide'
		end
		else
		begin
			insert into CTL_DOC_Value
				(idheader,DSE_ID,DZT_Name,[value])
			values
				(@id,'TESTATA_PRODOTTI','TipoBandoSceltaHide',@NomeModello2)
		end

					
		if exists (select [value] from 	CTL_DOC_Value with (nolock)
						where idheader=@id and DSE_ID='TESTATA_PRODOTTI' 
							and DZT_Name = 'TipoBandoSceltaOLD')
		begin
			update CTL_DOC_Value
				set Value = @NomeModello2
					where idheader=@id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name = 'TipoBandoSceltaOLD'
		end
		else
		begin
			insert into CTL_DOC_Value
				(idheader,DSE_ID,DZT_Name,[value])
			values
				(@id,'TESTATA_PRODOTTI','TipoBandoSceltaOLD',@NomeModello2)
		end
					
					

	end
	else
	begin

		-- se non esiste un modello base
		if exists (select [value] from 	CTL_DOC_Value with (nolock)
						where idheader=@id and DSE_ID='TESTATA_PRODOTTI' 
							and DZT_Name = 'Tipo_Modello_Convenzione_Scelta')
		begin
		update CTL_DOC_Value
			set Value = ''
				where idheader=@id and DSE_ID='TESTATA_PRODOTTI' and DZT_Name = 'Tipo_Modello_Convenzione_Scelta'	
		end
		else
		begin
			insert into CTL_DOC_Value
				(idheader,DSE_ID,DZT_Name,[value])
			values
				(@id,'TESTATA_PRODOTTI','Tipo_Modello_Convenzione_Scelta','')
		end


	end
				

	-- allegati
	--insert into CTL_DOC_ALLEGATI
	--	( [idHeader], [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione], [Interno], [Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], [EvidenzaPubblica], [RichiediFirma], [FirmeRichieste], [AllegatoRisposta], [EsitoRiga] )
	--select @id, [Descrizione], [Allegato], [Obbligatorio], [AnagDoc], [DataEmissione], [Interno], [Modified], [NotEditable], [TipoFile], [DataScadenza], [DSE_ID], [EvidenzaPubblica], [RichiediFirma], [FirmeRichieste], [AllegatoRisposta], [EsitoRiga]
	--	from CTL_DOC_ALLEGATI with (nolock)
	--		where IdHeader = @idDoc

	-- allegati firmati
	--insert into CTL_DOC_SIGN
	--( [idHeader], [F1_DESC], [F1_SIGN_HASH], [F1_SIGN_ATTACH], [F1_SIGN_LOCK], [F2_DESC], [F2_SIGN_HASH], [F2_SIGN_ATTACH], [F2_SIGN_LOCK], [F3_DESC], [F3_SIGN_HASH], [F3_SIGN_ATTACH], [F3_SIGN_LOCK], [F4_DESC], [F4_SIGN_HASH], [F4_SIGN_ATTACH], [F4_SIGN_LOCK] )
	--	select @id, [F1_DESC], [F1_SIGN_HASH], [F1_SIGN_ATTACH], [F1_SIGN_LOCK], [F2_DESC], [F2_SIGN_HASH], [F2_SIGN_ATTACH], [F2_SIGN_LOCK], [F3_DESC], [F3_SIGN_HASH], [F3_SIGN_ATTACH], [F3_SIGN_LOCK], [F4_DESC], [F4_SIGN_HASH], [F4_SIGN_ATTACH], [F4_SIGN_LOCK]
	--			from CTL_DOC_SIGN with (nolock)
	--				where IdHeader = @idDoc
				
	--chiamo la stored che gestisce i campi not editable sulla convenzione
	exec CAMPI_NOT_EDITABLE_CONVENZIONE @id , @IdUser
			
	update Document_convenzione 
		set noteditable = isnull(noteditable,'') + isnull(@notedit,'')
	where id = @id

		


END







GO
