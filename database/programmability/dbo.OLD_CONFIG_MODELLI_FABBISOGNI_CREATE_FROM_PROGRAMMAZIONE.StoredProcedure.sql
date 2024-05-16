USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONFIG_MODELLI_FABBISOGNI_CREATE_FROM_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD_CONFIG_MODELLI_FABBISOGNI_CREATE_FROM_PROGRAMMAZIONE] 
	( @idDoc int  , @idUser int )
AS
BEGIN	

	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1

	insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
						sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck,Caption
						)
		select @idUser, 'CONFIG_MODELLI_FABBISOGNI', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
			,'', 0 , '','', '', '', ''
			,'', '', NULL, NULL, NULL, 'PROGRAMMAZIONE','Configurazione Modelli Programmazione'


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	set @newId = SCOPE_IDENTITY()

	INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		 VALUES(@newId,'MODELLI','CONFIG_MODELLI_PROGRAMMAZIONE_MODELLI')
	
	INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		 VALUES(@newId,'AMBITO','CONFIG_MODELLI_PROGRAMMAZIONE_AMBITO')

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
