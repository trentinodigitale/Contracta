USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[FORMULARI_CREATE_FROM_FORMULARI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[FORMULARI_CREATE_FROM_FORMULARI] 
	( @idDoc int  , @idUser int )
AS
BEGIN

	--Versione=1&data=2014-10-08&Attivita=63991&Nominativo=Federico

	BEGIN TRAN

		SET NOCOUNT ON	-- set nocount ON è importantissimo

		DECLARE @newId INT
	
		set @newId = -1

		insert into CTL_DOC (  idpfu, TipoDoc, Titolo, StatoDoc, Data, Protocollo, PrevDoc, Deleted,Azienda )
			select  @idUser, 'FORMULARI',dbo.Normalizza_COL_TABLE('CTL_DOC','titolo', 'CopiaDi_' + Titolo ) , 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				  ,Azienda
				from ctl_doc where id=@idDoc


		IF @@ERROR <> 0 
		BEGIN
			raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)
			rollback tran
			return 99
		END

		set @newId = SCOPE_IDENTITY()



		--copia i dati della griglia degli attributi
		INSERT INTO CTL_DOC_VALUE ( idHeader, dse_id, row, dzt_name, value )
			select @newId, dse_id,row,dzt_name,value
				from ctl_doc_value where idHeader = @idDoc


	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END





GO
