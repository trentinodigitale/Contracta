USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SSO_InsertDocUser]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SSO_InsertDocUser] ( @idUser INT )
AS
BEGIN

	SET NOCOUNT ON

	declare		@Id INT
	declare		@idAzi INT
	declare		@aziVenditore INT

	declare		@CodiceFiscaleAzi varchar(100)
	declare		@RagioneSocialeAzi nvarchar(1000)
	declare		@EmailAzi nvarchar(1000)
	declare		@PartitaIvaAzi varchar(100)
	declare		@CittaAzi nvarchar(500)
	declare		@ViaAzi nvarchar(500)
	declare		@CapAzi varchar(100)
	declare		@TelefonoAzi varchar(500)
	declare		@FaxAzi varchar(500)
	declare		@NazioneAzi nvarchar(500)
	declare		@ProvinciaAzi varchar(500)

	DECLARE @CF varchar(100)
	DECLARE @COGNO nvarchar(4000)
	DECLARE @NOME nvarchar(4000)
	DECLARE @MAIL nvarchar(1000)
	DECLARE @TEL varchar(500)
	DECLARE @LOGIN nvarchar(1000)

	DECLARE @TipoDoc varchar(100)

	-- Recupero il flag per capire se l'azienda è un ente o meno
	select top 1 @aziVenditore = aziVenditore, 
				 @idAzi = azi.IdAzi,
				 @RagioneSocialeAzi = azi.aziRagioneSociale,
				 @EmailAzi = azi.aziE_Mail,
				 @PartitaIvaAzi = azi.aziPartitaIVA,
				 @CittaAzi = azi.aziLocalitaLeg,
				 @ViaAzi = azi.aziIndirizzoLeg,
				 @CapAzi = azi.aziCAPLeg,
				 @TelefonoAzi = azi.aziTelefono1,
				 @FaxAzi = azi.aziFAX,
				 @NazioneAzi = azi.aziStatoLeg,
				 @ProvinciaAzi = azi.aziProvinciaLeg,
				 @CodiceFiscaleAzi = dm1.vatValore_FT,
				 @LOGIN = pfu.pfulogin,
				 @NOME = pfu.pfunomeutente,
				 @COGNO = pfu.pfuCognome,
				 @TEL = pfu.pfuTel,
				 @MAIL = pfu.pfuE_Mail,
				 @CF = pfu.pfuCodiceFiscale
		from profiliutente pfu with(nolock) 
					inner join aziende azi with(nolock) ON azi.idazi = pfu.pfuidazi 
					left join dm_attributi dm1 with(nolock) ON dm1.lnk = azi.idazi AND dm1.dztnome = 'codicefiscale'
		where pfu.idpfu = @idUser 

	-- Se è un operatore economico
    IF @aziVenditore <> 0
    BEGIN

		set @TipoDoc = 'USER_DOC_OE'

	END
	ELSE
	BEGIN

		set @TipoDoc = 'USER_DOC'

	END

	INSERT INTO CTL_DOC ( idpfu, TipoDoc, StatoDoc, data, deleted, azienda, Fascicolo, StatoFunzionale, Destinatario_User)
				VALUES  ( @idUser,@TipoDoc, 'Sended', getdate(), 0, @idAzi, @LOGIN, 'Pubblicato', @idUser)

	set @id = @@identity
		  

	--*************************************************
	--*** INSERISCO I DATI DELL'UTENTE  ***************
	--*************************************************

	INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		VALUES ( @id, 'UTENTI','Nome', @NOME )
			 
	INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		VALUES ( @id, 'UTENTI','Cognome', @COGNO ) 
			 			 
	INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		VALUES ( @id, 'UTENTI','pfuTel', @TEL ) 
			 
	INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		VALUES ( @id, 'UTENTI','pfuE_Mail', @MAIL ) 
			 
	INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		VALUES ( @id, 'UTENTI','codicefiscale', @CF ) 

		--manca la qualifica

END






GO
