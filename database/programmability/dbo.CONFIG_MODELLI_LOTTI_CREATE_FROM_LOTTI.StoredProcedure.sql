USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONFIG_MODELLI_LOTTI_CREATE_FROM_LOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CONFIG_MODELLI_LOTTI_CREATE_FROM_LOTTI] 
	( @idDoc int  , @idUser int )
AS
BEGIN


	--Versione=1&data=2015-03-23Attivita=68663&Nominativo=Sabato

	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1

	insert into CTL_DOC (  idPfuInCharge , idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
						sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck
						)
		select @idUser,@idUser, 'CONFIG_MODELLI_LOTTI', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
			,'', 0 , '','', '', '', ''
			,'', '', NULL, NULL, NULL, ''


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	set @newId = @@identity


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END



GO
