USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[NOTIER_ISCRIZ_PA_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[NOTIER_ISCRIZ_PA_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int, @jumpcheck varchar(400) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- @jumpcheck è vuoto nel giro classico mentre vale FATTURE quando si proviene dal giro di registrazione notier fatture
	--		( il giro fatture per la parte PA per il momento non è prevista )

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int

	declare @CF varchar(500)
	declare @prevStatoFunz varchar(1000)
	declare @aziStatoLeg2 varchar(100)
	declare @CFUser nvarchar(100)

	set @Id = 0
	set @Errore=''
	set @prevStatoFunz = ''

	select @CFUser = dbo.fn_Handle_Omocodia(pfuCodiceFiscale),
			@aziStatoLeg2 = a.aziStatoLeg2,
			@IdAzi=pfuidazi
		from profiliUtente p with(nolock) 
				inner join aziende a with(nolock) on a.idazi = p.pfuIdAzi
		where IdPfu=@idUser 

	-- Se esiste un documento Revocato per l'azienda collegata (quindi non solo per l'utente) apriamo sempre quello.
	-- Tale documento nello stato di Revocato indica che è stata effettuata un operazione di 'ANNULLAMENTO REGISTRAZIONE PEPPOL' manuale (tramite il db)
	-- e dobbiamo bloccare future iscrizioni tramite aflink ( sia iscrizione peppol per ddt ed ordini che fatture )
	SELECT top 1 @Id = id
		from ctl_doc with(nolock) 
		where tipodoc = 'NOTIER_ISCRIZ_PA' and azienda = @IdAzi and StatoFunzionale = 'Revocato' and deleted = 0

	if @Id = 0
	BEGIN

		-- Recupero un eventuale documento precedente in lavorazione a parità di utenza
		SELECT  top 1 @Id = id, 
					  @prevStatoFunz = StatoFunzionale
			from ctl_doc with(nolock) 
			where tipodoc = 'NOTIER_ISCRIZ_PA' and idpfu = @iduser and StatoFunzionale = 'InLavorazione' and deleted = 0 and JumpCheck = @jumpcheck

	END

	if @Id = 0
	begin

		-- Recupero un eventuale documento precedente creato a parità di utenza
		SELECT top 1 @Id = id, 
					 @prevStatoFunz = StatoFunzionale
			from ctl_doc with(nolock) 
			where tipodoc = 'NOTIER_ISCRIZ_PA' and idpfu = @iduser and StatoFunzionale <> 'Annullato' and deleted = 0 and JumpCheck = @jumpcheck

	
	end


	select @cf=vatValore_FT from DM_Attributi with(nolock) where lnk = @IdAzi and dztNome='codicefiscale' and idApp=1

	IF EXISTS ( 
				select dm.idVat
					from DM_Attributi DM with(nolock)  
							inner join aziende A with(nolock) ON A.idazi=DM.lnk and a.aziAcquirente = 0 and A.aziDeleted = 0 -- OE
							inner join dm_attributi dm1 with(Nolock) on dm1.lnk = a.IdAzi and dm1.idapp = 1 and dm1.dztNome = 'IDNOTIER'  --registrato a peppol tramite noi
					where DM.dztNome='codicefiscale' and dm.vatValore_FT = @cf and dm.lnk <> @idazi and dm.idapp = 1
			  )
	BEGIN	
		set @Errore='Registrazione non possibile poichè l''Ente risulta essere già iscritto a Peppol come Operatore economico. Per proseguire con la registrazione Peppol come Ente, è necessario procedere prima con la deregistrazione Peppol come OE'
	END

	if @Id = 0 and @Errore=''
	begin
			

		declare @idPrimaIscrizione INT
		declare @cfDaControllare nvarchar(500)
		declare @pfuDeleted int

		set @idPrimaIscrizione = -1
		set @cfDaControllare = ''
		set @pfuDeleted = 0

		-- se è stata già effettuata un iscrizione a notier ( quindi non sono il primo utente dell'azienda che si censendo )
		--	recupero il codice fiscale del primo utente dell'azienda che si è registrato così da effettuare il controllo di firma
		--	sul suo codice fiscale ( sempre se l'utente collegato spunta la check indicando di NON essere in possesso di firma )

		select @idPrimaIscrizione = min(id) 
			from ctl_doc with(nolock) 
			where tipodoc = 'NOTIER_ISCRIZ_PA' and StatoFunzionale = 'Inviato' and deleted = 0 and azienda = @IdAzi and JumpCheck = @jumpcheck and idpfu <> @iduser

		select   @cfDaControllare  = pfucodicefiscale
				,@pfuDeleted = b.pfuDeleted -- perchè veniva recupero il pfuDeleted ?
			from CTL_DOC a with(nolock)
					inner join ProfiliUtente b with(nolock) ON b.IdPfu = a.IdPfu 
			where  a.Id = @idPrimaIscrizione

		--inserisco nella ctl_doc		
		insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
			values			( @idUser, 'NOTIER_ISCRIZ_PA', 'Saved' , 'Iscrizione NoTI-ER' , '' , @IdAzi , null,''  , '' ,NULL,'InLavorazione', @idUser , @jumpcheck)
	
		set @Id = SCOPE_IDENTITY()

		INSERT INTO Document_dati_protocollo (idHeader)	values (@id)

		IF @jumpcheck = 'FATTURE'
		BEGIN

			-- CI SERVE PER CAMBIARE IL CAMPO DELL'HELP
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
										values( @id, 'INFO' ,'NOTIER_ISCRIZ_PA_INFO_FATTURE' )

		END

		IF isnull(@cfDaControllare,'') <> ''
		BEGIN
			
			INSERT INTO CTL_DOC_VALUE  ( idheader, DSE_ID, [row], DZT_Name, value )
								values ( @Id, 'INFO', 0, 'codicefiscale', @cfDaControllare )

			INSERT INTO CTL_DOC_VALUE  ( idheader, DSE_ID, [row], DZT_Name, value )
								values ( @Id, 'INFO', 0, 'idDocUno', @idPrimaIscrizione )

		END


		INSERT INTO CTL_DOC_VALUE  ( idheader, DSE_ID, [row], DZT_Name, value )
								values ( @Id, 'PROCURA', 0, 'RichiediFirma', '1' )


		-- se sono un responsabile peppol posso sia togliere che aggiungere IPA, altrimenti posso solo selezionarli
		if exists ( select IdPfu from ProfiliUtenteAttrib pa with(nolock) where pa.IdPfu = @idUser  and pa.dztNome = 'UserRole' and pa.attValue = 'RESPONSABILE_PEPPOL' )
		begin

			INSERT INTO CTL_DOC_SECTION_MODEL  ( IdHeader, DSE_ID, MOD_Name )
										values ( @id, 'IPA', 'NOTIER_ISCRIZ_PA_RESP_IPA' )

			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, row, dzt_name, value )
				select @Id, 'IPA', ( ROW_NUMBER() OVER(ORDER BY attvalue ASC)) - 1, dztnome, attvalue 
					from ProfiliUtenteAttrib with(nolock) 
					where idpfu = @idUser and dztNome = 'CodiceIPA'
			
		end
		else
		begin

			-- recuperiamo la registrazione inviata per l'utente responsabile peppol
			declare @idPrimaReg INT
			declare @idPfuRespPeppol INT

			select @idPfuRespPeppol = p.idpfu 
				from profiliutente p with(nolock)
						inner join ProfiliUtenteAttrib pa with(nolock) on pa.IdPfu = p.IdPfu and pa.dztNome = 'UserRole' and pa.attValue = 'RESPONSABILE_PEPPOL'
				where p.pfuIdAzi = @IdAzi

			select @idPrimaReg = max(id)
				from ctl_doc with(nolock)
				where tipodoc = 'NOTIER_ISCRIZ_PA' and idpfu = @idPfuRespPeppol and StatoFunzionale <> 'Annullato' and deleted = 0 

			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, row, dzt_name, value )
				select @id, DSE_ID, row, dzt_name, value
					from ctl_doc_value with(nolock) 
					where IdHeader = @idPrimaReg and DSE_ID = 'IPA'

		end

		-- ***************************************************************************************
		-- BEGIN Attività 432983 
		-- Aggiungo i dati del comune di nascita dell'utente compilatore Attività 432983 
		--
		declare @CodiceCatastale varchar(10)

		DECLARE @DMV_Cod varchar(200)
		DECLARE @StatoRapLeg varchar(200)
		DECLARE @StatoRapLeg2 varchar(200)
		DECLARE @ProvinciaRapLeg varchar(200)
		DECLARE @ProvinciaRapLeg2 varchar(200)
		DECLARE @LocalitaRapLeg  varchar(200)
		DECLARE @LocalitaRapLeg2  varchar(200)


		-- solo per gli italiani
		IF @aziStatoLeg2 = 'M-1-11-ITA' and len(@CFUser) = 16
		BEGIN

			set @CodiceCatastale = substring(@CFUser,12,4)
		
			declare @CodiceIstatComune varchar(100)

			SELECT @CodiceIstatComune = CodiceIstatDelComune_formato_alfanumerico 
				FROM GEO_ISTAT_elenco_comuni_italiani with(nolock)
				WHERE CodiceCatastale = @CodiceCatastale

			IF @CodiceIstatComune <> ''
			BEGIN

				-- Estrazione Codice comune -- ResidenzaRapLeg2
				SELECT  @DMV_Cod = DMV_Cod,
						@LocalitaRapLeg2 = DMV_Cod, 
						@LocalitaRapLeg = DMV_DescML 
					FROM LIB_DomainValues a with(nolock)
					WHERE DMV_Module = 'GEO' AND DMV_Cod LIKE '%-'+@CodiceIstatComune

				INSERT INTO CTL_DOC_VALUE  ( idheader, DSE_ID, [row], DZT_Name, value )
										values ( @Id, 'FIRMATARIO', 0, 'LocalitaRapLeg2', @LocalitaRapLeg2 ),
												( @Id, 'FIRMATARIO', 0, 'LocalitaRapLeg', @LocalitaRapLeg )
										
				set @DMV_Cod= REVERSE(@DMV_Cod)

				-- PROVINCIA
				set @ProvinciaRapLeg2 = reverse(SUBSTRING(@DMV_Cod ,CHARINDEX('-',@DMV_Cod)+1, LEN(@DMV_Cod)))

				SELECT @ProvinciaRapLeg = DMV_DescML 
					FROM LIB_DomainValues a with(nolock)
					WHERE DMV_Module = 'GEO' AND DMV_Cod = @ProvinciaRapLeg2

				INSERT INTO CTL_DOC_VALUE  ( idheader, DSE_ID, [row], DZT_Name, value )
										values ( @Id, 'FIRMATARIO', 0, 'ProvinciaRapLeg2', @ProvinciaRapLeg2 ),
												( @Id, 'FIRMATARIO', 0, 'ProvinciaRapLeg', @ProvinciaRapLeg )

				-- STATO
				set @DMV_Cod  = (SUBSTRING(@DMV_Cod ,CHARINDEX('-',@DMV_Cod)+1, LEN(@DMV_Cod)))
				set @DMV_Cod  = (SUBSTRING(@DMV_Cod ,CHARINDEX('-',@DMV_Cod)+1, LEN(@DMV_Cod)))
				set @DMV_Cod  = (SUBSTRING(@DMV_Cod ,CHARINDEX('-',@DMV_Cod)+1, LEN(@DMV_Cod)))

				set @StatoRapLeg2 = reverse(SUBSTRING(@DMV_Cod ,CHARINDEX('-',@DMV_Cod)+1, LEN(@DMV_Cod)))

				SELECT @StatoRapLeg = DMV_DescML 
					FROM LIB_DomainValues a with(nolock)
					WHERE DMV_Module = 'GEO' AND DMV_Cod = @StatoRapLeg2

				INSERT INTO CTL_DOC_VALUE  ( idheader, DSE_ID, [row], DZT_Name, value )
										values ( @Id, 'FIRMATARIO', 0, 'StatoRapLeg2', @StatoRapLeg2 ),
												( @Id, 'FIRMATARIO', 0, 'StatoRapLeg', @StatoRapLeg )
			END

		END --IF @aziStatoLeg2 = 'M-1-11-ITA'

		-- END Attività 432983 
		-- ***************************************************************************************	
	END
	ELSE
	BEGIN

		-- se a parità di utente esiste un precedente documento inviato vuol dire che si sta richiedendo una modifica
		IF @errore = '' and @prevStatoFunz = 'Inviato'
		BEGIN

			declare @prevIdDoc INT
			set @prevIdDoc = @id

			---- DA VERBALE : In assenza di codice IPA (spunta del flag), se l'utente dopo aver perfezionato (inviato con successo) la prima registrazione, prova ad eseguirne un’altra, verrà bloccato e visualizzerà un messaggio che lo informa di dover procedere con la deregistrazione e poi una nuova registrazione.
			IF EXISTS ( 
					select IdRow
						from ctl_doc_value b with(nolock) 
						WHERE b.IdHeader = @prevIdDoc and b.DSE_ID = 'PROCURA' and b.DZT_Name = 'AssenzaCodiceIPA' and b.[value] = '1'
						
				)
			BEGIN
				set @errore = 'Annullare la precedente registrazione prima di procedere con una nuova'
			END
			ELSE
			BEGIN
			
				insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
					values ( @idUser, 'NOTIER_ISCRIZ_PA', 'Saved' , 'Iscrizione NoTI-ER' , '' , @IdAzi , null,''  , '' ,NULL,'InLavorazione', @idUser , @jumpcheck)
	
				set @Id = SCOPE_IDENTITY()

				INSERT INTO Document_dati_protocollo (idHeader)	values (@id)

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, row, DZT_Name, value )
									select @Id, DSE_ID, row, DZT_Name, value
										from ctl_doc_value with(nolock)
										where idheader = @prevIdDoc and DSE_ID <> 'XML_LOG_NOTIER'

				INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
										select @id, DSE_ID, MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where IdHeader = @prevIdDoc

										

			END

		END

	END
	
	if @Errore=''
	begin
		select @Id as id , '' as Errore, 'NOTIER_ISCRIZ_PA' as TYPE_TO
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end

END



GO
