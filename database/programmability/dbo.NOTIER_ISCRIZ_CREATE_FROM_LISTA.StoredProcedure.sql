USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[NOTIER_ISCRIZ_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[NOTIER_ISCRIZ_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int, @jumpcheck varchar(400) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- @jumpcheck è vuoto nel giro classico mentre vale FATTURE quando si proviene dal giro di registrazione notier fatture

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int

	declare @idNoter varchar(500)
	declare @CF varchar(500)
	declare @CFUser nvarchar(50)
	declare @aziStatoLeg2 varchar(100)
	declare @caption varchar(500)

	set @Id = 0
	set @Errore=''
	set @idNoter = ''
	set @caption = ''

	select @IdAzi=pfuidazi 
			,@idNoter = vatValore_FT
			,@CFUser = dbo.fn_Handle_Omocodia(pfuCodiceFiscale)
			,@aziStatoLeg2 = a.aziStatoLeg2
		from profiliutente with(nolock)
				inner join aziende a with(nolock) ON pfuidazi=idazi 
				left join DM_Attributi with(nolock) ON lnk = idazi and dztNome = 'IDNOTIER' and isnull(vatValore_FT,'') <>''
		where idpfu=@idUser  

	SELECT @Id = id 
		from ctl_doc with(nolock) 
		where tipodoc = 'NOTIER_ISCRIZ' and idpfu = @iduser and StatoFunzionale <> 'Annullato' and deleted = 0 and JumpCheck = @jumpcheck

	-- aggiungiamo un controllo che se il CF dell'OE è presente come ente nel DB blocchiamo la creazione del documento con un messaggio del tipo 
	--"Registrazione non possibile poichè l'Operatore economico risulta essere anche un Ente. Per approfondimenti rivolgersi al Nodo Telematico di Interscambio Intercenter"

	select @cf=vatValore_FT from DM_Attributi with(nolock) where lnk = @IdAzi and dztNome='codicefiscale' and idApp=1

	IF EXISTS ( 
				select * 
					from DM_Attributi DM with(nolock)  
						inner join aziende A with(nolock)  on A.idazi=DM.lnk and a.aziAcquirente=3 and A.aziDeleted = 0 
				where DM.dztNome='codicefiscale' and vatValore_FT=@cf and lnk <> @idazi 
			  )
	BEGIN	
		set @Errore='Registrazione non possibile poichè l''Operatore economico risulta essere anche un Ente.'
	END

	IF @id=0 and isnull(@idNoter,'')='' and @Errore=''
	BEGIN
		IF EXISTS (Select * from DM_Attributi where lnk=@IdAzi and idApp=1 and dztNome='PARTICIPANTID' and isnull(vatValore_FT,'') <>'' )
		BEGIN
			set @Errore='Per proseguire e'' necessario rimuovere il Participant ID Peppol inserito in anagrafica'
		END
	END

	if @jumpcheck = 'FATTURE'
		set @caption = 'Registrazione Fatture PEPPOL'
	else
		set @caption = 'Registrazione Ordini e DDT PEPPOL'

	-- Se esiste un documento Revocato per l'azienda collegata (quindi non solo per l'utente) apriamo sempre quello.
	-- Tale documento nello stato di Revocato indica che è stata effettuata un operazione di 'ANNULLAMENTO REGISTRAZIONE PEPPOL' manuale (tramite il db)
	-- e dobbiamo bloccare future iscrizioni tramite aflink ( sia iscrizione peppol per ddt ed ordini che fatture )
	IF @Errore=''
	BEGIN
		SELECT top 1 @Id = id
			from ctl_doc with(nolock) 
			where tipodoc = 'NOTIER_ISCRIZ' and azienda = @IdAzi and StatoFunzionale = 'Revocato' and deleted = 0
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

		IF isnull(@idNoter,'') <> ''
		BEGIN

			select @idPrimaIscrizione = min(id) 
				from ctl_doc with(nolock) 
				where tipodoc = 'NOTIER_ISCRIZ' and StatoFunzionale = 'Inviato' and deleted = 0 and azienda = @IdAzi and JumpCheck = @jumpcheck

			select   @cfDaControllare  = pfucodicefiscale
					,@pfuDeleted = b.pfuDeleted
				from CTL_DOC a with(nolock)
						inner join ProfiliUtente b with(nolock) ON b.IdPfu = a.IdPfu 
				where  a.Id = @idPrimaIscrizione


		END

		--inserisco nella ctl_doc		
		insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck, Caption)
			values			( @idUser, 'NOTIER_ISCRIZ', 'Saved' , 'Iscrizione NoTI-ER' , '' , @IdAzi , null	,''  , '' ,NULL,'InLavorazione', @idUser , @jumpcheck, @caption)
					
		set @Id = SCOPE_IDENTITY()
		
		insert into Document_dati_protocollo (idHeader)	values	(@id)	

		IF @jumpcheck = 'FATTURE'
		BEGIN
			-- CI SERVE PER CAMBIARE IL CAMPO DELL'HELP
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
										values( @id, 'INFO' ,'NOTIER_ISCRIZ_INFO_FATTURE' )
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
	
	if @Errore=''
	begin
		select @Id as id , '' as Errore, 'NOTIER_ISCRIZ' as TYPE_TO
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end

END



GO
