USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RISPOSTA_CONSULTAZIONE_CREATE_FROM_BANDO_CONSULTAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[RISPOSTA_CONSULTAZIONE_CREATE_FROM_BANDO_CONSULTAZIONE]( @idOrigin as int, @idPfu as int = -20 ) 
AS
BEGIN

	SET NOCOUNT ON

	declare @output as nvarchar(max)
	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)
	DECLARE @newId as int

	declare @fascicolo as varchar(1000)
	declare @linkedDoc as int
	declare @prevDoc as int
	declare @richiestaFirma as varchar(100)
	declare @sign_lock as int
	declare @sign_attach as varchar(400)
	declare @protocolloRiferimento as varchar(1000)
	declare @strutturaAziendale as varchar(4000)

	declare @body as nvarchar(max)
	declare @azienda as varchar(100)
	declare @DataScadenza as datetime
	declare @Destinatario_Azi as int
	declare @Destinatario_User as int
	declare @jumpCheck  as varchar(1000)

	declare @Modello varchar(500)
	declare @ModelloTec varchar(500)
	declare @Tipodoc varchar(500)


	select @fascicolo = Fascicolo, 
		   @linkedDoc = LinkedDoc,
		   @prevDoc = 0,
		   @richiestaFirma = RichiestaFirma,
		   @sign_lock = '',
		   @sign_attach = '',
		   @protocolloRiferimento = protocolloRiferimento,
		   @strutturaAziendale = strutturaAziendale,
		   @body			= Body,
		   @azienda			= Azienda,
		   @DataScadenza	= DataScadenza,
		   @Destinatario_Azi = Destinatario_Azi,
		   @Destinatario_User = Destinatario_User,
		   @jumpCheck = JumpCheck 

		from OFFERTA_TESTATA_FROM_BANDO_GARA 
		where id_from = @idOrigin and idpfu = @idpfu

	insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
						   sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						   Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck,idPfuInCharge, Titolo
						   )
		select @idPfu, 'RISPOSTA_CONSULTAZIONE', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				,@fascicolo, @linkedDoc, @richiestaFirma,@sign_lock, @sign_attach, @protocolloRiferimento, @strutturaAziendale
				,@body, @azienda, @DataScadenza, @Destinatario_Azi, @Destinatario_User, @jumpCheck,@idPfu, 'Senza Titolo'

	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		return 99
	END 

	set @newId = SCOPE_IDENTITY()

	-- sezione DOCUMENTAZIONE	
	insert into CTL_DOC_ALLEGATI ( descrizione, allegato, obbligatorio, anagDoc, idHeader , TipoFile,RichiediFirma, NotEditable )
		select descrizione, allegato, obbligatorio, anagDoc, @newId as idHeader , TipoFile, RichiediFirma , NotEditable 
			from OFFERTA_ALLEGATI_FROM_BANDO_GARA
			where id_from = @idOrigin
   
   select @newId as id


END




GO
