USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_FABB_QUALITATIVO_CREA_RISPOSTA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[BANDO_FABB_QUALITATIVO_CREA_RISPOSTA] ( @idOrigin as int, @idPfu as int ) 
AS
BEGIN


	SET NOCOUNT ON

	declare @output as nvarchar(max)
	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)
	declare @linkedDoc as int
	declare @prevDoc as int
	declare @richiestaFirma as varchar(100)	
	declare @body as nvarchar(max)	
	declare @DataScadenza as datetime
	declare @Modello varchar(500)	
	declare @TipoBando varchar(500)	
	declare @Tipodoc varchar(500)
	declare @idbando as int
	declare @newId as int
	declare @ente as int
	declare @ProtocolloRichiesta as varchar(500)
	declare @datainviorichiesta as datetime
	

	select @idbando=idheader from CTL_DOC_Destinatari where idrow=@idOrigin

	select  
		   @linkedDoc		= id,
		   @prevDoc			= 0,
		   @richiestaFirma	= RichiestaFirma,
		   @body			= Body,
		   @DataScadenza	= DataPresentazioneRisposte,
		   @TipoBando   =  TipoBando,
		   @ProtocolloRichiesta = protocollo,
		   @datainviorichiesta	= datainvio

		from CTL_DOC 
			inner join document_bando on idHeader=id
		where id = @idbando 

	--recupero ente dell'utente
	select @ente=pfuidazi from  ProfiliUtente where idpfu=@idPfu

	-- verifico se esiste un documento QUESTIONARIO  nel sistema
	select @newId = id from CTL_DOC where LinkedDoc = @linkedDoc and deleted = 0 and TipoDoc = @TipoBando and azienda = @ente
	if @newId is null
	begin

		insert into CTL_DOC (  idpfu,Azienda ,TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,linkedDoc,richiestaFirma, Body, DataScadenza, idPfuInCharge,ProtocolloGenerale,DataProtocolloGenerale)
			select @idPfu,pfuIdAzi, @TipoBando, 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted , @linkedDoc, @richiestaFirma,@body, @DataScadenza,@idPfu,@ProtocolloRichiesta,@datainviorichiesta
				from ProfiliUtente
				where idpfu=@idPfu
		
		IF @@ERROR <> 0 
		BEGIN
			raiserror ('Errore creazione record in ctl_doc.', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
			return 99
		END 

		set @newId = @@identity


		--INSERISCO IL RECORD NELLA CRONOLOGIA DI CREAZIONE DOCUMENTO
		declare @userRole as varchar(100)
		select  @userRole= isnull( attvalue,'')
			from  profiliutenteattrib where idpfu = @idPfu and dztnome = 'UserRoleDefault'  
		IF ISNULL(@userRole ,'') = ''
			set @userRole ='UtenteEnte'

	    insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values (@TipoBando , @newId , 'Compiled' , '' , @idPfu     , @userRole       , 1         , getdate() )

		--Aggiorno lo statoiscrizione sulla ctl_doc_destinatari per l'ente
		update CTL_DOC_Destinatari set StatoIscrizione='In Lavorazione' where idrow=@idOrigin

		---Inserisco la data di default per i sub_questionari
		Insert into CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @newId,'TESTATA_SUB_QUESTIONARI',0,'DataScadenzaIstanza',CONVERT(nvarchar(30), @DataScadenza, 126)
		

		-- preparo il n uovo documento ricopiandoci i valori del template
		declare @idTemplate int
		select @idTemplate = id from CTL_DOC where TipoDoc = @TipoBando and LinkedDoc = @idbando and JumpCheck = 'TEMPLATE'
		Insert into CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value)
			select @newId as  IdHeader,DSE_ID,Row,DZT_Name,Value
				from CTL_DOC_Value where idheader = @idTemplate

		-- aggiorno il riferimento per recuperare il documento
		update CTL_DOC_Destinatari set Id_Doc = @newId where idrow=@idOrigin 


	END


	
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
