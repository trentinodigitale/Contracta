USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONFIG_MODELLI_CREATE_FROM_COPY_MODELLI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_CONFIG_MODELLI_CREATE_FROM_COPY_MODELLI] 
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
	declare @caption varchar(500)

	set @newId = -1
	set @modello_dinamico = 'CONFIG_MODELLI_CONVENZIONI_MODELLI'
	set @descrizione = ''
	set @titolo = ''

	select top 1 @contesto = JumpCheck, @descrizione = Body, @titolo = Titolo from ctl_doc where id = @idDoc

	IF ISNULL(@titolo,'') <> ''
	BEGIN
		set @titolo = 'CopiaDi_' + @titolo
	END

	if @contesto = 'AMPIEZZA_DI_GAMMA'
		set @caption = 'Ampiezza di Gamma'
	else
		set @caption = ''
	

	insert into CTL_DOC (  idpfu, TipoDoc, Titolo, StatoDoc, Data, Protocollo, PrevDoc, Deleted,
						   fascicolo,linkedDoc,richiestaFirma,  sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						   Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck , Caption, idpfuIncharge 
						)
		select @idUser, 'CONFIG_MODELLI',@titolo, 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
			  ,'', 0, '','', '', '', ''
			  ,@descrizione, '', NULL, NULL, NULL, @contesto ,@caption, @idUser


	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)
		rollback tran
		return 99
	END

	set @newId = @@identity

	if isnull(@contesto,'') <> '' 
	BEGIN
		if @contesto = 'AMPIEZZA_DI_GAMMA'
			set @modello_dinamico = 'CONFIG_MODELLI_AMPIEZZA_DI_GAMMA'
		else
			SET @modello_dinamico = 'CONFIG_MODELLI_' + @contesto + '_MODELLI'
	END


	-- copia il modello dinamico usato sul documento di partenza
	INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
		 VALUES(@newId,'MODELLI', @modello_dinamico)

	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in CTL_DOC_SECTION_MODEL.  ', 16, 1)
		rollback tran
		return 99
	END

	--copia i dati della griglia degli attributi
	INSERT INTO CTL_DOC_VALUE ( idHeader, dse_id, row, dzt_name, value )
		select @newId, dse_id,row,dzt_name,value
			from ctl_doc_value where dse_id = 'MODELLI' and idHeader = @idDoc


	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END




GO
