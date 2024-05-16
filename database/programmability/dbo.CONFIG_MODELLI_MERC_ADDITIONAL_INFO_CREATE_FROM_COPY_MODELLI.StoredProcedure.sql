USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONFIG_MODELLI_MERC_ADDITIONAL_INFO_CREATE_FROM_COPY_MODELLI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CONFIG_MODELLI_MERC_ADDITIONAL_INFO_CREATE_FROM_COPY_MODELLI] 
	( @idDoc int  , @idUser int )
AS
BEGIN

	--Versione=1&data=2014-10-08&Attivita=63991&Nominativo=Federico

	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	declare @contesto varchar(500)
	declare @modello_dinamico varchar(1000)
	declare @descrizione nvarchar(4000)
	declare @titolo varchar(500)

	set @newId = -1
	set @descrizione = ''
	set @titolo = ''

	select  @descrizione = Body, @titolo = Titolo from ctl_doc where id = @idDoc

	IF ISNULL(@titolo,'') <> ''
	BEGIN
		set @titolo = 'CopiaDi_' + @titolo
	END

	insert into CTL_DOC (  idpfu, TipoDoc, Titolo, StatoDoc, Data, Protocollo, PrevDoc, Deleted,
						   fascicolo,linkedDoc,richiestaFirma,  sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						   Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck
						)
		select @idUser, 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO',@titolo, 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
			  ,'', 0, '','', '', '', ''
			  ,@descrizione, '', NULL, NULL, NULL, @contesto


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)
		rollback tran
		return 99
	END

	set @newId = @@identity

	

	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in CTL_DOC_SECTION_MODEL.  ', 16, 1)
		rollback tran
		return 99
	END


	--copia i dati della CLASSE
	INSERT INTO CTL_DOC_VALUE ( idHeader, dse_id, row, dzt_name, value )
		select @newId, dse_id,row,dzt_name,value
			from ctl_doc_value where dse_id = 'CLASSE' and idHeader = @idDoc



	--copia i dati della griglia degli attributi
	INSERT INTO CTL_DOC_VALUE ( idHeader, dse_id, row, dzt_name, value )
		select @newId, dse_id,row,dzt_name,value
			from ctl_doc_value where dse_id = 'MODELLI' and idHeader = @idDoc


	--copia i dati della griglia FORMULE
	INSERT INTO CTL_DOC_VALUE ( idHeader, dse_id, row, dzt_name, value )
		select @newId, dse_id,row,dzt_name,value
			from ctl_doc_value where dse_id = 'CALCOLI' and idHeader = @idDoc

	
	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END






GO
