USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONFIGURAZIONE_MONITOR_EVENTI_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CONFIGURAZIONE_MONITOR_EVENTI_CREATE_FROM_USER] 
	( @idDoc int  , @idUser int )
AS
BEGIN


	--Versione=1&data=2015-03-23Attivita=68663&Nominativo=Sabato

	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1
	
	select @newId=id from ctl_doc where tipodoc='CONFIGURAZIONE_MONITOR_EVENTI' and statofunzionale='inlavorazione' and idpfu =@idUser

	--se NON esiste uno in lavorazione per l'utente lo CREO
	if @newId = -1
	begin

		insert into CTL_DOC (  idPfuInCharge , idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
							sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
							Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck
							)
			select @idUser,@idUser, 'CONFIGURAZIONE_MONITOR_EVENTI', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				,'', 0 , '','', '', '', ''
				,'', '', NULL, NULL, NULL, ''

	


		IF @@ERROR <> 0 
		BEGIN
			raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
			rollback tran
			return 99
		END

		set @newId = @@identity


		--ricopio nella tabella dei dettagli quelli dell'ultimo documento confermato
		insert into Document_Configurazione_Monitor_Tipologie
			( [IdHeader], [Titolo_Tipologia], [Descrizione_Tipologia], [ParoleChiavi_Tipologia], [Soglia_Ultimi_3Mesi], [Soglia_Ultimo_Mese], [Soglia_Ultima_Settimana], [Soglia_Oggi], [Data_Notifica_U3Mesi], [Data_Notifica_UMese], [Data_Notifica_USettimana], [Data_Notifica_Oggi], [MailTo], [Deleted]	)
			select 
				@newId, [Titolo_Tipologia], [Descrizione_Tipologia], [ParoleChiavi_Tipologia], [Soglia_Ultimi_3Mesi], [Soglia_Ultimo_Mese], [Soglia_Ultima_Settimana], [Soglia_Oggi], [Data_Notifica_U3Mesi], [Data_Notifica_UMese], [Data_Notifica_USettimana], [Data_Notifica_Oggi], [MailTo], [Deleted]
				from 
					Document_Configurazione_Monitor_Tipologie with (nolock)
				where deleted=0

		--se non esiste la riga altro la aggiungo sempre
		if not exists(
			select * from Document_Configurazione_Monitor_Tipologie with (nolock) where idheader =@newId and Titolo_Tipologia='altro' 
			)
		begin
			insert into Document_Configurazione_Monitor_Tipologie
				( [IdHeader], [Titolo_Tipologia], [Descrizione_Tipologia],[ParoleChiavi_Tipologia], [Deleted]	)
				select 
					@newId, 'Altro', 'Altro', '',0
		
		end

		IF @@ERROR <> 0 
		BEGIN
			raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
			rollback tran
			return 99
		END
	end

	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END



GO
