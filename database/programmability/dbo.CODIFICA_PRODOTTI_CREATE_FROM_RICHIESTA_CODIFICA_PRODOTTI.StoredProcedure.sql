USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CODIFICA_PRODOTTI_CREATE_FROM_RICHIESTA_CODIFICA_PRODOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[CODIFICA_PRODOTTI_CREATE_FROM_RICHIESTA_CODIFICA_PRODOTTI]( @idOrigin as int, @idPfu as int ) 
AS
BEGIN
	--BEGIN TRAN

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
	

	-- verifico se esiste un documento CODIFICA_PRODOTTI nel sistema
	select @newId = id from CTL_DOC where LinkedDoc = @idOrigin and deleted = 0 and TipoDoc in (  'CODIFICA_PRODOTTI'  ) 
	if @newId is null
	begin
		insert into CTL_DOC (  fascicolo,ProtocolloRiferimento,titolo,idpfu,Azienda ,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,linkedDoc, Body, idPfuInCharge,StatoFunzionale)
			select fascicolo,Protocollo,'Codifica Prodotti',@idPfu,Azienda, 'CODIFICA_PRODOTTI', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted , @idOrigin,Body,@idPfu,'NEW_CODIFICA_PRODOTTI'
			    from ctl_doc
			    where id=@idOrigin

			IF @@ERROR <> 0 
			BEGIN
				raiserror ('Errore creazione record in ctl_doc.', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
				--rollback tran
				return 99
			END 

		set @newId = SCOPE_IDENTITY()

		--INSERISCO UN RECORD FITTIZIO PER LA SEZIONE PROTOCOLLO
		insert into Document_dati_protocollo (idHeader) values(@newId)

		--INSERISCO IL RECORD NELLA CRONOLOGIA DI CREAZIONE DOCUMENTO
				
		declare @userRole as varchar(100)
		select  @userRole= isnull( attvalue,'')
			from  profiliutenteattrib where idpfu = @idPfu and dztnome = 'UserRoleDefault'  
		IF ISNULL(@userRole ,'') = ''
		set @userRole ='UtenteEnte'

	    insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values ('CODIFICA_PRODOTTI' , @newId , 'Compiled' , '' , @idPfu     , @userRole       , 1         , getdate() )

		--mi riporto id del modello selezionato sulla richiesta anche sul documento di codifica
		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
		select @newId,'TESTATA_PRODOTTI' ,'Id_modello',value
		    from CTL_DOC_Value
		    where IdHeader=@idOrigin and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='Id_modello'

		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
		select @newId,'TESTATA_PRODOTTI' ,'TipoBando',value
		    from CTL_DOC_Value
		    where IdHeader=@idOrigin and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='TipoBando'
		-----------------------------------------------------------------------------------
		-- precarico i modelli da usare 
		-----------------------------------------------------------------------------------
		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
		select  @newId , 'PRODOTTI' ,MOD_Name
			from CTL_DOC_SECTION_MODEL
			where IdHeader=@idOrigin and DSE_ID='PRODOTTI'
	
		-----------------------------------------------------------------------------------
		-- precarico i prodotti prelevando dal bando
		-----------------------------------------------------------------------------------

		  --ENRICO COMMENTATO VECCHIO MODO 
		  --declare @IdRow2 INT
		  --declare @idr INT
		  --declare CurProg2 Cursor Static for 
			 --select   id as IdRow2
				--    from Document_MicroLotti_Dettagli 
				--    where idheader = @idOrigin  and TipoDoc = 'RICHIESTA_CODIFICA_PRODOTTI'
				--    order by Id

		  --open CurProg2

		  --FETCH NEXT FROM CurProg2 INTO @IdRow2
		  --WHILE @@FETCH_STATUS = 0
		  --BEGIN
			
			 --INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga,idHeaderLotto )
				--select @newId , 'CODIFICA_PRODOTTI' as TipoDoc,'' as StatoRiga,'' as EsitoRiga,@IdRow2
					   
			 --set @idr = SCOPE_IDENTITY()				
			 ---- ricopio tutti i valori
			 --exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga,idHeaderLotto, '			 
					   
			 --FETCH NEXT FROM CurProg2 INTO @IdRow2
		  --END 

		  --CLOSE CurProg2
		  --DEALLOCATE CurProg2

		  declare @Filter as varchar(500)
		  declare @DestListField as varchar(500)

		  set @Filter = ' Tipodoc=''RICHIESTA_CODIFICA_PRODOTTI'' '
		  set @DestListField = ' ''CODIFICA_PRODOTTI'' as TipoDoc, '''' as StatoRiga, '''' as EsitoRiga, id as idHeaderLotto '
		  
		  exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idOrigin, @newId, 'IdHeader', 
							 ' Id,IdHeader,TipoDoc,StatoRiga,EsitoRiga,idHeaderLotto ', 
							 @Filter, 
							 ' TipoDoc, StatoRiga, EsitoRiga, idHeaderLotto ', 
							 @DestListField,
							 ' id '

	END
	
	-- COMMIT TRAN



	
	if  ISNULL(@newId,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @newId as id , '' as Errore
	
	end
	else
	begin

		select 'Errore' as id , 'ERROR' as Errore

	end
	

END













GO
