USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONFIG_MODELLI_MEA_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[CONFIG_MODELLI_MEA_CREATE_FROM_NEW] 
	( @idDoc int  , @idUser int )
AS
BEGIN


	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1

	insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
						sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck
						)
		select @idUser, 'CONFIG_MODELLI_MEA', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
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

	if @newId > -1
		declare @nome varchar(5000);
		declare @descrizione varchar(5000);
		declare @dominio varchar(5000);
		declare @row int = 0;

		Begin
			declare ctl_relation_cursor CURSOR FOR   
				select REL_ValueOutput , ISNULL(ML_Description,DZT_DescML) as Descrizione, ISNULL(DZT_DM_ID, '') as dominio from CTL_Relations
					left join LIB_DICTIONARY on dzt_name= REL_ValueOutput 
					left join LIB_MULTILINGUISMO on DZT_DescML=ML_KEY and ML_LNG='I' 
					where REL_Type = 'CONFIG_MODELLI_MEA' AND REL_ValueInput like 'RIGHE%'

			open ctl_relation_cursor

			fetch next from ctl_relation_cursor into @nome, @descrizione, @dominio;

			while @@FETCH_STATUS = 0 and @nome <> ''
			Begin
			
				insert into CTL_DOC_Value(IdHeader, DSE_ID, Row, DZT_Name, Value)
				values	(@newId, 'MODELLI', @row, 'DZT_Name', @nome),
						(@newId, 'MODELLI', @row, 'MOD_Modello', 'obblig'),
						(@newId, 'MODELLI', @row, 'NonEditabili', 'fissa'),
						(@newId, 'MODELLI', @row, 'Descrizione', @descrizione),
						(@newId, 'MODELLI', @row, 'Obbligatorio', '1'),
						(@newId, 'MODELLI', @row, 'PresenzaDominio', @Dominio)
				
				set @row = @row + 1

				FETCH NEXT FROM ctl_relation_cursor into @nome, @descrizione, @dominio;
			end	

			close ctl_relation_cursor
			deallocate ctl_relation_cursor
		end

	select @newId as id

	return 

END




GO
