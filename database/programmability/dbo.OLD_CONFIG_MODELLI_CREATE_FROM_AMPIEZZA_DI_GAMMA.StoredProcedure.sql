USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONFIG_MODELLI_CREATE_FROM_AMPIEZZA_DI_GAMMA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_CONFIG_MODELLI_CREATE_FROM_AMPIEZZA_DI_GAMMA]
	( @idDoc int  , @idUser int )
AS
BEGIN

	--Versione=1&data=2014-10-07&Attivita=63991&Nominativo=Federico
	--Versione=2&data=2015-03-23Attivita=68663&Nominativo=Sabato

	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1

	insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
						sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck,caption , idPfuInCharge
						)
		select @idUser, 'CONFIG_MODELLI', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
			,'', 0 , '','', '', '', ''
			,'', '', NULL, NULL, NULL, 'AMPIEZZA_DI_GAMMA','Ampiezza di Gamma' , @idUser


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	set @newId = @@identity

	print @newId

	INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		 VALUES(@newId,'MODELLI','CONFIG_MODELLI_AMPIEZZA_DI_GAMMA')
    

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
