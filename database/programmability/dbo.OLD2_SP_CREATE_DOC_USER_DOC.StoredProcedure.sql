USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SP_CREATE_DOC_USER_DOC]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc  [dbo].[OLD2_SP_CREATE_DOC_USER_DOC] ( @IdDoc varchar(100) ,  @IdUser varchar(100)  )
AS
BEGIN 
 	set nocount on
	--declare @IdDoc varchar(100)
	--declare @IdUser varchar(100)
	--set @IdDoc='45365'
	--set @IdUser='45365'
	declare @cf varchar(500)
	declare @idAzi varchar(500)
	declare @key varchar(500)
	declare @QUALIFICA varchar(500)
	declare @nomeRapLeg varchar(4000)
	declare @cognomeRapLeg varchar(4000)
	declare @aziLocalitaLeg2 varchar(4000)
	declare @aziProvinciaLeg2 varchar(4000)
	declare @aziStatoLeg2 varchar(4000)
	declare @idPfu int
	declare @TelefonoRapLeg nvarchar(30)
	declare @CellulareRapLeg nvarchar(30)
	declare @newid int
	declare @Tipoazienda int

	set @cf = null
	set @idAzi = null
	set @nomeRapLeg = null
	set @cognomeRapLeg = null

	set @aziLocalitaLeg2 = null
	set @aziProvinciaLeg2 = null
	set @aziStatoLeg2 = null
	
	--in questo caso sono utente dell'ente oppure O.E. di azienda già censita
	if @IdUser = @IdDoc 
	BEGIN
		---controllo se per quell'utente esiste già un documento in quel caso non fa niente
		IF NOT EXISTS (
					Select * from ctl_doc where Destinatario_User=@IdUser and  
					tipodoc in ('USER_DOC','USER_DOC_OE','USER_DOC_READONLY','USERDOC_UPD_BASE','CAMBIO_RUOLO_UTENTE')
			    	)
		BEGIN
			select @idAzi=pfuidazi from ProfiliUtente where idpfu=@IdUser
			--print @idAzi
			--se venditore=2 è un operatore economico
			select @Tipoazienda=azivenditore from aziende where idazi=@idAzi
			--print @Tipoazienda
			-- in questo caso utente O.E
			IF @Tipoazienda = 2
			BEGIN
					set @idpfu=@IdUser
					Insert into CTL_DOC (idpfu,Statodoc,tipodoc,Data,Statofunzionale,Fascicolo,Azienda,Destinatario_user,Note)
					select @idpfu,'Sended','USER_DOC_OE',getdate(),'Pubblicato',pfulogin,@idAzi,@idpfu,''
					from ProfiliUtente where idpfu=@idpfu and pfuIdAzi=@idAzi

					set @newid = @@identity
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'Nome',pfunomeutente
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'Cognome',pfucognome
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuRuoloAziendale',pfuRuoloAziendale
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuE_Mail',pfuE_Mail
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuTel',pfuTel
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuCell',pfuCell
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'LinguaAll',pfuIdLng
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuPrefissoProt',pfuPrefissoProt
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'CodiceFiscale',pfuCodiceFiscale
					from ProfiliUtente where idpfu=@idpfu
			END
			--altrimenti utente ente
			ELSE
			BEGIN
				set @idpfu=@IdUser
					Insert into CTL_DOC (idpfu,Statodoc,tipodoc,Data,Statofunzionale,Fascicolo,Azienda,Destinatario_user,Note)
					select @idpfu,'Sended','USER_DOC',getdate(),'Pubblicato',pfulogin,@idAzi,@idpfu,''
					from ProfiliUtente where idpfu=@idpfu and pfuIdAzi=@idAzi

					set @newid = @@identity
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'Nome',pfunomeutente
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'Cognome',pfucognome
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuRuoloAziendale',pfuRuoloAziendale
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuE_Mail',pfuE_Mail
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuTel',pfuTel
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuCell',pfuCell
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'LinguaAll',pfuIdLng
					from ProfiliUtente where idpfu=@idpfu
							
					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'pfuPrefissoProt',pfuPrefissoProt
					from ProfiliUtente where idpfu=@idpfu

					Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
					Select @newid,'UTENTI',0,'CodiceFiscale',pfuCodiceFiscale
					from ProfiliUtente where idpfu=@idpfu
			END

		END
		
	END
	--sono un utente O:E di una nuova azienda
	ELSE
		BEGIN
			set @key = @IdDoc
			select @idAzi = valore from FormRegistrazione where sessionid = @key and nome_campo = 'ID_AZI'
		
			if @idAzi <> ''
			begin
				select @idpfu = idpfu from profiliutente where pfuidazi = @idAzi
				---controllo se per quell'utente esiste già un documento in quel caso non fa niente
					IF NOT EXISTS (
							Select * from ctl_doc where Destinatario_User=@IdUser and  
							tipodoc in ('USER_DOC','USER_DOC_OE','USER_DOC_READONLY','USERDOC_UPD_BASE','CAMBIO_RUOLO_UTENTE')
			    			)
					BEGIN
							Insert into CTL_DOC (idpfu,Statodoc,tipodoc,Data,Statofunzionale,Fascicolo,Azienda,Destinatario_user,Note)
							select @idpfu,'Sended','USER_DOC_OE',getdate(),'Pubblicato',pfulogin,@idAzi,@idpfu,''
							from ProfiliUtente where idpfu=@idpfu and pfuIdAzi=@idAzi

							set @newid = @@identity
							
							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'Nome',pfunomeutente
							from ProfiliUtente where idpfu=@idpfu

							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'Cognome',pfucognome
							from ProfiliUtente where idpfu=@idpfu

							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'pfuRuoloAziendale',pfuRuoloAziendale
							from ProfiliUtente where idpfu=@idpfu
							
							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'pfuE_Mail',pfuE_Mail
							from ProfiliUtente where idpfu=@idpfu
							
							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'pfuTel',pfuTel
							from ProfiliUtente where idpfu=@idpfu
							
							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'pfuCell',pfuCell
							from ProfiliUtente where idpfu=@idpfu

							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'LinguaAll',pfuIdLng
							from ProfiliUtente where idpfu=@idpfu
							
							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'pfuPrefissoProt',pfuPrefissoProt
							from ProfiliUtente where idpfu=@idpfu

							Insert into CTL_DOC_Value (Idheader,DSE_ID,ROW,DZT_Name,Value)
							Select @newid,'UTENTI',0,'CodiceFiscale',pfuCodiceFiscale
							from ProfiliUtente where idpfu=@idpfu

					END
			end


		END


		
END





GO
