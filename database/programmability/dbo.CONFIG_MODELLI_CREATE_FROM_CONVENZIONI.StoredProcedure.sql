USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONFIG_MODELLI_CREATE_FROM_CONVENZIONI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--exec CONFIG_MODELLI_CREATE_FROM_CONVENZIONI -1,-20
--exec CONFIG_MODELLI_CREATE_FROM_CONVENZIONI -1 , 42768
--exec CONFIG_MODELLI_CREATE_FROM_CONVENZIONI -1 , 42768

CREATE PROCEDURE [dbo].[CONFIG_MODELLI_CREATE_FROM_CONVENZIONI] 
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
						Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck , idPfuInCharge
						)
		select @idUser, 'CONFIG_MODELLI', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
			,'', 0 , '','', '', '', ''
			,'', '', NULL, NULL, NULL, 'CONVENZIONI' , @idUser


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	set @newId = @@identity

	print @newId

	INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		 VALUES(@newId,'MODELLI','CONFIG_MODELLI_CONVENZIONI_MODELLI')
    --inserisco i DESCRIZIONE E CODICE REGIONALE DI DEFAULT SUL MODELLO
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'FNZ_DEL' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'FNZ_COPY' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'FNZ_UPD' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'DZT_Name' , 'CODICE_REGIONALE' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'Descrizione' , 'CODICE REGIONALE' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'NonEditabili' , 'fissa' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'MOD_Convenzione' , 'obblig' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'MOD_StampaListino' , 'lettura' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'MOD_PerfListino' , 'scrittura' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'MOD_Carrello' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'MOD_Ordinativo' , 'lettura' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'MOD_StampaOrdinativo' , 'lettura' 

	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'NumeroDec' , '0' 

	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'FNZ_DEL' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'FNZ_COPY' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'FNZ_UPD' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'DZT_Name' , 'DESCRIZIONE_CODICE_REGIONALE' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'Descrizione' , 'DESCRIZIONE CODICE REGIONALE' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'NonEditabili' , 'fissa' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'MOD_Convenzione' , 'obblig' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'MOD_StampaListino' , 'lettura' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'MOD_PerfListino' , 'scrittura' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'MOD_Carrello' , '' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'MOD_Ordinativo' , 'lettura' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 1 , 'MOD_StampaOrdinativo' , 'lettura' 
	INSERT INTO CTL_DOC_VALUE ( IdHeader , DSE_ID , Row ,Dzt_Name , Value )
	select @newId , 'MODELLI' , 0 , 'NumeroDec' , '0' 

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
