USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_QUESTIONARIO_PROGRAMMAZIONE_CREATE_FROM_QUESTIONARIO_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_QUESTIONARIO_PROGRAMMAZIONE_CREATE_FROM_QUESTIONARIO_PROGRAMMAZIONE]( @idOrigin as int, @idPfu as int ) 
AS
BEGIN
	--BEGIN TRAN

	SET NOCOUNT ON

	declare @output as nvarchar(max)
	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)
	declare @linkedDoc as int
	declare @prevDoc as int
	declare @richiestaFirma as varchar(100)	
	declare @body as nvarchar(max)	
	declare @errore as nvarchar(max)	
	declare @DataScadenza as datetime
	declare @Modello varchar(500)	
	declare @CodiceModello varchar(500)	
	declare @Tipodoc varchar(500)
	declare @idbando as int
	declare @newId as int
	declare @ente as int
	declare @ProtocolloRichiesta as varchar(500)
	declare @statobando as varchar(500)	
	declare @datainviorichiesta as datetime

	set @errore=''
	
	select @idbando=LinkedDoc ,@ente = Azienda from CTL_DOC where Id=@idOrigin

	select  
		   @linkedDoc = id,
		   @prevDoc = 0,
		   @richiestaFirma = RichiestaFirma,
		   @body			= Body,
		   @DataScadenza	= DataPresentazioneRisposte,
		   @CodiceModello =  TipoBando,
		   @ProtocolloRichiesta = protocollo,
		   @datainviorichiesta= datainvio,
		   @statobando=StatoFunzionale

		from CTL_DOC 
			inner join document_bando on idHeader=id
		where id = @idbando 

	--recupero ente dell'utente
	--select @ente=pfuidazi from  ProfiliUtente where idpfu=@idPfu

	-- verifico se esiste un documento QUESTIONARIO_FABBISOGNI nel sistema
	-- in funzione dello stato del Bando, quando è Completato mi prendo quello completato oppure annullato altrimenti il MAX(id)
	if @statobando <> 'Inviato'
	BEGIN
		Set @errore='Lo stato della Richiesta Programmazione non consente la creazione della risposta'
	END
	ELSE
	BEGIN
		select @newId = max(id) from CTL_DOC where LinkedDoc = @linkedDoc and deleted = 0 and TipoDoc in (  'QUESTIONARIO_PROGRAMMAZIONE'  ) and azienda = @ente and StatoDoc='Saved'
	END


	if @newId is null and @errore=''
	begin
		insert into CTL_DOC (  idpfu,Azienda ,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,linkedDoc,richiestaFirma, Body, DataScadenza, idPfuInCharge,ProtocolloGenerale,DataProtocolloGenerale)
			select @idPfu,pfuIdAzi, 'QUESTIONARIO_PROGRAMMAZIONE', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, @idOrigin as PrevDoc, 0 as Deleted , @linkedDoc, @richiestaFirma,@body, @DataScadenza,@idPfu,@ProtocolloRichiesta,@datainviorichiesta
			from ProfiliUtente
			where idpfu=@idPfu
			IF @@ERROR <> 0 
			BEGIN
				raiserror ('Errore creazione record in ctl_doc.', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
				--rollback tran
				return 99
			END 

		set @newId = SCOPE_IDENTITY()

			--INSERISCO IL RECORD NELLA CRONOLOGIA DI CREAZIONE DOCUMENTO
				
		declare @userRole as varchar(100)
		select  @userRole= isnull( attvalue,'')
			from  profiliutenteattrib where idpfu = @idPfu and dztnome = 'UserRoleDefault'  
		IF ISNULL(@userRole ,'') = ''
		set @userRole ='UtenteEnte'

	    insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values ('QUESTIONARIO_PROGRAMMAZIONE' , @newId , 'Compiled' , '' , @idPfu     , @userRole       , 1         , getdate() )

		--Aggiorno lo statoiscrizione sulla ctl_doc_destinatari per l'ente
		--update CTL_DOC_Destinatari set StatoIscrizione='In Lavorazione' where idrow=@idOrigin

		-----Inserisco la data di default per i sub_questionari
		--Insert into CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value)
		--select @newId,'TESTATA_SUB_QUESTIONARI',0,'DataScadenzaIstanza',CONVERT(nvarchar(30), @DataScadenza, 126)
		

		-----------------------------------------------------------------------------------
		-- precarico i modelli da usare 
		-----------------------------------------------------------------------------------
		set @Modello = 'MODELLO_BASE_PROGRAMMAZIONE_' + @CodiceModello + '_Fabb_Questionario'
	

		insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			values( @newId , 'PRODOTTI' , @Modello  )
	
		
		
		-----------------------------------------------------------------------------------
		-- precarico i prodotti prelevando dal bando dal precedente QUESTIONARIO INVIATO
		-----------------------------------------------------------------------------------

		--Enrico 2017-01-16 - COMMENTATO VECCHIO MODO DI PRECARICARE I PRODOTTI DAL BANDO ALL'OFFERTA sostituito con INSERT_RECORD_NEW

		--declare @IdRow2 INT
		--declare @idr INT
		--declare CurProg2 Cursor Static for 
		--	select   id as IdRow2
		--		from Document_MicroLotti_Dettagli 
		--		where idheader = @idOrigin  and TipoDoc = 'QUESTIONARIO_FABBISOGNI'
		--		order by Id

		--open CurProg2

		--FETCH NEXT FROM CurProg2 
		--INTO @IdRow2
		--	WHILE @@FETCH_STATUS = 0
		--		BEGIN
			
		--			INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
		--				select @newId , 'QUESTIONARIO_FABBISOGNI' as TipoDoc,'' as StatoRiga,'' as EsitoRiga
		--			set @idr = @@identity				
		--			-- ricopio tutti i valori
		--			exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga '			 
		--				FETCH NEXT FROM CurProg2
		--			INTO @IdRow2
		--			END 

		--CLOSE CurProg2
		--DEALLOCATE CurProg2

		declare @Filter as varchar(500)
		declare @DestListField as varchar(500)

		set @Filter = ' Tipodoc=''QUESTIONARIO_PROGRAMMAZIONE'' '
		set @DestListField = ' ''QUESTIONARIO_PROGRAMMAZIONE'' as TipoDoc, '''' as EsitoRiga, '''' as StatoRiga '
		  
		  
		  

		exec INSERT_RECORD_NEW 'Document_PROGRAMMAZIONE_Dettagli', @idOrigin, @newId, 'IdHeader', 
							' Id,IdHeader,TipoDoc,EsitoRiga,StatoRiga ', 
							@Filter, 
							' TipoDoc, EsitoRiga, StatoRiga ', 
							@DestListField,
							' id '


	END
	
	-- COMMIT TRAN



	
	if  ISNULL(@newId,0) <> 0
	begin
		-- rirorna l'id del doc da aprire
		select @newId as id
	
	end
	else
	begin

		select 'Errore' as id , 'ERROR' as Errore

	end
	

END











GO
