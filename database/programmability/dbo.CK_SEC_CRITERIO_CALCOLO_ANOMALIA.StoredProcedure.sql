USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_CRITERIO_CALCOLO_ANOMALIA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[CK_SEC_CRITERIO_CALCOLO_ANOMALIA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	
	--inserita perchè non restituiva record se faceva una insert
	SET NOCOUNT ON
	declare @Blocco nvarchar(1000)
	set @Blocco = ''
	declare @IdCommissione as int
	set @IdCommissione=-1
	declare @IdBando as int
	declare @SessionID as varchar(4000)
	declare @idPDA int
	set @idPDA = null
	declare @Fascicolo as varchar(100)
	declare @ProtocolloRiferimento as varchar(100)
	declare @TipoDoc as varchar(200)
	declare @TipoCommissione as varchar(10)
	declare @Jumpcheck as varchar(200)
	declare @GuidBando as varchar(200)
	set @TipoCommissione='A'
	
	if exists(select * from ctl_doc where id=@IdDoc and statofunzionale<>'Inviato')
	begin
		-- recupero la PDA
		select @idPDA = o.LinkedDoc , @Jumpcheck=jumpcheck  from CTL_DOC o where o.id = @IdDoc 

		--recupero id del bando
		if @Jumpcheck <> 'DOCUMENTOGENERICO'
		begin
			select @TipoDoc=JumpCheck,@IdBando=linkeddoc from ctl_doc where id=@IdPDA
		end
		else
		begin
		
			--recupero id del bando documento generico 55;167
			select @GuidBando=mfFieldValue from MessageFields where mfIdMsg=56868 and mfFieldName='IdDoc_Bando' and mfIsubType=169 and mfitype=55
		
			set @TipoDoc='55;167'
		
			select top 1 @IdBando=idmsg  from TAB_MESSAGGI_FIELDS where iddoc=@GuidBando order by idmsg asc

		end	

		select @SessionID=pfuSessionID from profiliutente where idpfu=@IdUser

		--recupero documento commissione e se esiste faccio i controlli
		--altrimenti sono le vecchie PDA
		select @IdCommissione=ID ,@Fascicolo=fascicolo,@ProtocolloRiferimento=protocolloriferimento from ctl_doc where deleted=0 and linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato'  and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 
					
	
		if @Blocco=''
		begin
					
				--se la busta richiede blocco controllo che esiste il documento credenziali
				if exists (select * from document_CommissionePda_Blocco where busta='BUSTA_DOCUMENTAZIONE' and idheader=@IdCommissione and BloccoBusta='si')
				begin
					
					--se ci sono blocchi ci deve essere il documento di credenziali valido nella stessa sessione
					if not exists(
						select 
							id 
						from 
							ctl_doc 
						where 
							tipodoc='CREDENZIALI_COMMISSIONE' and StatoFunzionale='Pubblicato' 
							and iddoc=@IdCommissione and linkeddoc=@IdBando and versione=@SessionID 
							and left(VersioneLinkedDoc,1) = @TipoCommissione and jumpcheck=@TipoDoc
					)
					
					begin
							
						--creo il documento per le credenziali	
						declare @titolo as varchar(500)
						declare @VersioneLinkedDoc as varchar(500)
						declare @IdCred as int

						set @titolo = dbo.CNV('credenziali tipocommissione ' + @TipoCommissione , 'I')
						set @VersioneLinkedDoc = @TipoCommissione + ':' + @SectionName
							
						insert into ctl_doc 
							(IdPfu,TipoDoc,Titolo,Fascicolo,ProtocolloRiferimento,
							LinkedDoc,IdDoc,JumpCheck,Versione,VersioneLinkedDoc) 
						VALUES 
							(@IdUser,'CREDENZIALI_COMMISSIONE', @titolo , replace(@Fascicolo,'''','''''') , replace(@ProtocolloRiferimento,'''','''''') , 
							@IdBando ,@IdCommissione ,@TipoDoc,@SessionID,@VersioneLinkedDoc)
							
						set @IdCred = @@IDENTITY
							
						--inserisco nella ctl_doc_value il parametro utile	al ridisegno della sezione
						declare @ParamSectionOpen as varchar(500)
						set @ParamSectionOpen= cast(@idDoc as varchar(100)) + '#' + @SectionName
						insert into ctl_doc_value 
							( IdHeader, DSE_ID, Row, DZT_Name, Value) 
						values
							( @IdCred , 'TESTATA', 0, 'PARAM', @ParamSectionOpen ) 
							
						--inserisco le entrate per i componenti che devono inserire le credenziali
						insert into Document_CommissionePda_Credenziali 
							(IdHeader, UtenteCommissione, RuoloCommissione)
						select @IdCred, UtenteCommissione,RuoloCOmmissione 
						from 
							ctl_doc , Document_CommissionePda_Utenti   
						where 
							linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato' and deleted=0 and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 
							and idheader=id and tipocommissione=@TipoCommissione and ruolocommissione<>'15540' 
							
						set @Blocco = 'NO_ML:' + dbo.CNV('Busta bloccata. Necessario inserire credenziali della commissione' , 'I') + '<br><span class="Toolbar_button" onclick="ExecFunctionCenter( ''../../ctl_library/document/document.asp?UpdateParent=no&MODE=SHOW&JScript=CREDENZIALI_COMMISSIONE&DOCUMENT=CREDENZIALI_COMMISSIONE&IDDOC=' + cast(@IdCred as varchar(100)) + '#credenzialicommissione#1000,600#'' )" >' + dbo.CNV('inserisci credenziali commissione' , 'I') + '</span>'
					
					end

				end
		end

	end

	select @Blocco as Blocco 
	
	

end




GO
