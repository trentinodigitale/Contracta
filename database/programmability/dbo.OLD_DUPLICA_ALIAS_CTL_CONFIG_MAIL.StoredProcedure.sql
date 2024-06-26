USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DUPLICA_ALIAS_CTL_CONFIG_MAIL]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD_DUPLICA_ALIAS_CTL_CONFIG_MAIL]( @IdDoc int )
AS
begin
	
	declare @IdMailSource as int
	declare @IdMailDest as int
	declare @mailfrom as varchar(1000)

	declare @UsingMethod as tinyint
	declare @Server as varchar(50)
	declare @ServerPort as int
	declare @UseSSL as tinyint
	declare @connectiontimeout as int
	declare @Authenticate as tinyint
	declare @UserName as varchar(255)
	declare @Password as nvarchar(255)
	declare @AliasFrom as varchar(500)
	declare @BodyFormat as varchar(50)
	declare @NotificationTo as varchar(255)
	declare @ReceiptTo as varchar(255)
	declare @DSNOptions as tinyint
	declare @Certified as tinyint
	declare @StartTLS as tinyint
	declare @ServerRead as varchar(50)
	declare @ServerPortRead as int

	declare @IdDocNew int
	declare @PrevDoc int
	declare @Protocollo varchar(100)
	declare @alias varchar(500)
	declare @idcv int 
	declare @cvlastvalue varchar(100)
	declare @app int
	
	-- seleziona id source della CTL_CONFIG_MAIL (la configurazione da copiare)
	select @IdMailSource = linkeddoc from ctl_doc with (nolock) where id = @IdDoc

	-- seleziona mailfrom su cui copiare la configurazione e gli altri campi da copiare
	select	@mailfrom = mailfrom ,
			@UsingMethod = UsingMethod,
			@Server = [Server],
			@ServerPort = ServerPort,
			@UseSSL = UseSSL,
			@connectiontimeout = connectiontimeout,
			@Authenticate = Authenticate,
			@UserName = UserName,
			@Password = [Password],			
			@BodyFormat = BodyFormat,
			@NotificationTo = NotificationTo,
			@ReceiptTo = ReceiptTo,
			@DSNOptions = DSNOptions,
			@Certified = Certified,
			@StartTLS = StartTLS,
			@ServerRead = ServerRead,
			@ServerPortRead = ServerPortRead

		from CTL_CONFIG_MAIL with (nolock) 
			where id = @IdMailSource

	

	

	-- seleziona le righe target ovvero gli altri alias con lo stesso mailfrom
	declare crs cursor static
	for 
		select id, alias, AliasFrom  from CTL_CONFIG_MAIL with (nolock)
				where mailfrom = @mailfrom
							and id <> @IdMailSource

	open crs

	fetch next from crs into @IdMailDest, @alias, @aliasfrom

	while @@fetch_status=0
	begin
        
			-- aggiorna i campi sulla riga target prendendoli da quella sorgente
			update CTL_CONFIG_MAIL
				set UsingMethod = @UsingMethod,
					[Server] = @Server,
					ServerPort = @ServerPort,
					UseSSL = @UseSSL,
					connectiontimeout = @connectiontimeout,
					Authenticate = @Authenticate,
					UserName = @UserName,
					[Password] = @Password,					
					BodyFormat = @BodyFormat,
					NotificationTo = @NotificationTo,
					ReceiptTo = @ReceiptTo,
					DSNOptions = @DSNOptions,
					Certified = @Certified,
					StartTLS = @StartTLS,
					ServerRead = @ServerRead,
					ServerPortRead = @ServerPortRead

						where id = @IdMailDest


			-- per ogni configurazione copiata deve inserire un documento di tipo CTL_CONFIG_MAIL
			-- cerca il prevdoc

			set @PrevDoc = NULL

			select @PrevDoc = max(id)
				from ctl_doc
					where TipoDoc = 'CTL_CONFIG_MAIL'
						and deleted = 0
						and LinkedDoc = @IdMailDest

			if @PrevDoc is null
				set @PrevDoc = 0

			-- calcolo del protocollo
			BEGIN TRY 
				exec GetProtocollo_Old 'ProtocolloOfferta', @Protocollo output			
			END TRY  
			BEGIN CATCH  
				 set @app = 0
			END CATCH
			
			-- inserimento documento
			insert into ctl_doc
				( [IdPfu], [IdDoc], [TipoDoc], [StatoDoc], [Data], [Protocollo], [PrevDoc], [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], [DataInvio], [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], [LinkedDoc], [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], [StatoFunzionale], [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], [GUID], [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale] )
				
				select
					[IdPfu], [IdDoc], [TipoDoc], 'Sent', getdate(), @Protocollo, @PrevDoc, [Deleted], [Titolo], [Body], [Azienda], [StrutturaAziendale], getdate(), [DataScadenza], [ProtocolloRiferimento], [ProtocolloGenerale], [Fascicolo], [Note], [DataProtocolloGenerale], @IdMailDest, [SIGN_HASH], [SIGN_ATTACH], [SIGN_LOCK], [JumpCheck], 'Confermato', [Destinatario_User], [Destinatario_Azi], [RichiestaFirma], [NumeroDocumento], [DataDocumento], [Versione], [VersioneLinkedDoc], NEWID() , [idPfuInCharge], [CanaleNotifica], [URL_CLIENT], [Caption], [FascicoloGenerale]

					from ctl_doc with (nolock)
						where id = @IdDoc

			set @IdDocNew = SCOPE_IDENTITY() 
			
			-- annulla i documenti precedenti (se ci sono) sulla stessa configurazione
			update ctl_doc
				set StatoDoc = 'Invalidate', StatoFunzionale = 'Variato'
					where TipoDoc = 'CTL_CONFIG_MAIL'
						and deleted = 0
						and LinkedDoc = @IdMailDest
						and id <> @IdDocNew
			
			
			-- inserisce i valori copiandoli dal documento origine (tranne ALIAS)
			insert into CTL_DOC_Value
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
					select 
						@IdDocNew , [DSE_ID], [Row], [DZT_Name], [Value]
							from CTL_DOC_Value
								where [IdHeader] = @IdDoc and [DZT_Name] <> 'Alias' and [DZT_Name] <> 'AliasFrom'


			insert into CTL_DOC_Value
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
					select 
						@IdDocNew , [DSE_ID], [Row], [DZT_Name], @alias
							from CTL_DOC_Value
								where [IdHeader] = @IdDoc and [DZT_Name] = 'Alias'

			insert into CTL_DOC_Value
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
					select 
						@IdDocNew , [DSE_ID], [Row], [DZT_Name], @AliasFrom
							from CTL_DOC_Value
								where [IdHeader] = @IdDoc and [DZT_Name] = 'AliasFrom'

			
			
			fetch next from crs into @IdMailDest, @alias, @aliasfrom
        
	end

	close crs

	deallocate crs

	
end

GO
