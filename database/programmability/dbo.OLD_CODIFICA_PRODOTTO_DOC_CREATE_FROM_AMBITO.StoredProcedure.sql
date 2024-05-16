USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CODIFICA_PRODOTTO_DOC_CREATE_FROM_AMBITO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[OLD_CODIFICA_PRODOTTO_DOC_CREATE_FROM_AMBITO]( @idOrigin as int, @idPfu as int ) 
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

	IF @idOrigin > 0
	BEGIN

		-- IN LINKED DOC FINIRA' L'ID DELL'AMBITO SCELTO

		insert into CTL_DOC (  fascicolo,ProtocolloRiferimento,titolo,idpfu,Azienda ,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,linkedDoc, Body, idPfuInCharge,StatoFunzionale, JumpCheck)
				select  '','','Codifica Prodottio',@idPfu, pfuidazi , 'CODIFICA_PRODOTTO_DOC', 'Saved' , getdate() , '', 0 , 0 as Deleted , NULL,NULL,@idPfu,'InLavorazione', cast( @idOrigin as varchar(10))
				from profiliutente with(nolock) where idpfu = @idPfu

		IF @@ERROR <> 0 
		BEGIN
			raiserror ('Errore creazione record in ctl_doc.', 16, 1)
			return 99
		END 

		set @newId = SCOPE_IDENTITY()


		insert into Document_dati_protocollo (idHeader) values(@newId)

		insert into document_microlotti_dettagli ( idHeader, TipoDoc, Posizione , StatoRiga ) values ( @newId,'CODIFICA_PRODOTTO_DOC', @idOrigin, 'Saved')

		set @modelloChiave = 'DOCUMENT_CODIFICA_PRODOTTO_' + cast(@idOrigin as varchar(10)) + '_Mod_KEY'
		set @modelloOpt = 'DOCUMENT_CODIFICA_PRODOTTO_' + cast(@idOrigin as varchar(10)) + '_Mod_OPT'
		set @modelloObblig = 'DOCUMENT_CODIFICA_PRODOTTO_' + cast(@idOrigin as varchar(10)) + '_Mod_OBBLIG'

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

			-- rirorna l'id del doc da aprire
			select @newId as id
	
		END
		ELSE
		BEGIN

			select 'Errore' as id , 'ERROR' as Errore

		END

	END
	ELSE
	BEGIN

		select 'Errore' as id , 'Ambito scelto non valido' as Errore

	END

END




GO
