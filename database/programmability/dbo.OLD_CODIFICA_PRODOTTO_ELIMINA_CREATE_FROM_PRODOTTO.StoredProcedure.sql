USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CODIFICA_PRODOTTO_ELIMINA_CREATE_FROM_PRODOTTO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[OLD_CODIFICA_PRODOTTO_ELIMINA_CREATE_FROM_PRODOTTO]( @idOrigin as int, @idPfu as int ) 
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)
	declare @linkedDoc as int
	declare @prevDoc as int	
	declare @body as nvarchar(max)		
	declare @Modello varchar(500)	
	declare @CodiceModello varchar(500)	
	declare @Tipodoc varchar(500)	
	declare @newId as int
	declare @userRole as varchar(100)

	declare @modelloChiave varchar(1000)
	declare @modelloOpt varchar(1000)
	declare @modelloObblig varchar(1000)

	declare @ambito varchar(100)

	set @ambito = ''

	select @ambito = Posizione from Document_MicroLotti_Dettagli with(nolock) where id = @idOrigin 


	-- IN LINKED DOC CI SARA' L'ID DELL'AMBITO SCELTO E IN PrevDoc il documento dal quale si è partiti per la modifica

	insert into CTL_DOC (  fascicolo,ProtocolloRiferimento,titolo,idpfu,Azienda ,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,linkedDoc, Body, idPfuInCharge,StatoFunzionale)
			select '', '','Elimina Codifica Prodotto',@idPfu, pfuidazi , 'CODIFICA_PRODOTTO_ELIMINA', 'Saved' , getdate() , '', @idOrigin , 0 as Deleted , @ambito,NULL,@idPfu,'InLavorazione'
			from profiliutente with(nolock) where idpfu = @idpfu

	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.', 16, 1)
		return 99
	END 

	set @newId = SCOPE_IDENTITY()

	insert into Document_dati_protocollo (idHeader) values(@newId)



	INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
			select @newId , 'CODIFICA_PRODOTTO_ELIMINA' as TipoDoc, 'Saved' as StatoRiga, '' as EsitoRiga

	declare @idr int
	set @idr = SCOPE_IDENTITY()				
		
	-- ricopio tutti i valori
	exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@idOrigin  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga,idHeaderLotto, '	

	set @modelloChiave = 'DOCUMENT_CODIFICA_PRODOTTO_' + @ambito + '_Mod_KEY'
	set @modelloOpt = 'DOCUMENT_CODIFICA_PRODOTTO_' + @ambito + '_Mod_OPT'
	set @modelloObblig = 'DOCUMENT_CODIFICA_PRODOTTO_' + @ambito + '_Mod_OBBLIG'

	--------------------------------------------------------------------------------
	-- IMPOSTO I MODELLI PER GLI ATTRIBUTI CHIAVE, OBBLIGATORI E OPZIONALE ---------
	--------------------------------------------------------------------------------
	insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
		values (   @newId , 'KEY' , @modelloChiave )

	insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
		values (   @newId , 'OBBLIG' , @modelloObblig )

	insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
		values (   @newId , 'OPT' , @modelloOpt )



	IF ISNULL(@newId,0) <> 0
	BEGIN

		-- ritorna l'id del doc da aprire
		select @newId as id
	
	END
	ELSE
	BEGIN

		select 'Errore' as id , 'ERROR' as Errore

	END

END




GO
