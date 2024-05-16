USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RISPOSTA_CONCORSO_CREATE_FROM_BANDO_CONCORSO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD_RISPOSTA_CONCORSO_CREATE_FROM_BANDO_CONCORSO]( @idOrigin as int, @idPfu as int = -20 , @newId as int output ) 
AS
BEGIN

	SET NOCOUNT ON

	declare @output as nvarchar(max)
	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)
	--DECLARE @newId as int

	declare @fascicolo as varchar(1000)
	declare @linkedDoc as int
	declare @prevDoc as int
	declare @richiestaFirma as varchar(100)
	declare @sign_lock as int
	declare @sign_attach as varchar(400)
	declare @protocolloRiferimento as varchar(1000)
	declare @strutturaAziendale as varchar(4000)

	declare @body as nvarchar(max)
	declare @azienda as varchar(100)
	declare @DataScadenza as datetime
	declare @Destinatario_Azi as int
	declare @Destinatario_User as int
	declare @jumpCheck  as varchar(1000)

	declare @Modello varchar(500)
	declare @ModelloTec varchar(500)
	declare @Tipodoc varchar(500)
	declare @FaseConcorso as varchar(100)
	declare @IdConcorso_PrimaFase as int
	declare @IdRisp_PrimaFase as int

	set @IdRisp_PrimaFase = 0

	set @FaseConcorso=''
	set @IdConcorso_PrimaFase = 0 

	select @fascicolo = Fascicolo, 
		   @linkedDoc = LinkedDoc,
		   @prevDoc = 0,
		   @richiestaFirma = 'no', --RichiestaFirma,
		   @sign_lock = '',
		   @sign_attach = '',
		   @protocolloRiferimento = protocolloRiferimento,
		   @strutturaAziendale = strutturaAziendale,
		   @body			= Body,
		   @azienda			= Azienda,
		   @DataScadenza	= DataScadenza,
		   @Destinatario_Azi = Destinatario_Azi,
		   @Destinatario_User = Destinatario_User,
		   @jumpCheck = JumpCheck 

		from OFFERTA_TESTATA_FROM_BANDO_GARA 
		where id_from = @idOrigin and idpfu = @idpfu

	insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
						   sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						   Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck,idPfuInCharge, Titolo
						   )
		select @idPfu, 'RISPOSTA_CONCORSO', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				,@fascicolo, @linkedDoc, @richiestaFirma,@sign_lock, @sign_attach, @protocolloRiferimento, @strutturaAziendale
				,@body, @azienda, @DataScadenza, @Destinatario_Azi, @Destinatario_User, @jumpCheck,@idPfu, 'Senza Titolo'

	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		return 99
	END 

	set @newId = SCOPE_IDENTITY()


   

   -- se sono su un concorso seconda fase aggiungo gli allegati (non editabili) che l'OE
   -- ha aggiunto nella prima fase dal documento RISPOSTA_CONCORSO collegato al bando concorso prima fase
   select 
		@FaseConcorso=isnull(FaseConcorso,'') 
		, @IdConcorso_PrimaFase = isnull(C.LinkedDoc,0)
		from 
			ctl_doc C with (nolock) 
				inner join document_bando  with (nolock)  on idHeader = id 
		where C.id= @idOrigin

   if @FaseConcorso='seconda'
   begin
		--recupero risposta al primo giro legato all'azienda in input
		select @IdRisp_PrimaFase = id 
			from ctl_doc with (nolock) 
			where tipodoc='RISPOSTA_CONCORSO' and Deleted = 0 and azienda = @azienda and linkeddoc = @IdConcorso_PrimaFase
					and StatoFunzionale = 'Inviato' and statodoc = 'Sended'
		
		if @IdRisp_PrimaFase <> 0
		begin

			--decifro gli allegati prima di rpenderli
			exec START_OFFERTA_CHECK  @IdRisp_PrimaFase , @idPfu

			--aggiungo gli allegati (non editabili) che l'OE ha aggiunto nella prima fase
			insert into CTL_DOC_ALLEGATI 
				( descrizione, allegato, obbligatorio, anagDoc, idHeader , TipoFile,RichiediFirma, NotEditable,DSE_ID )
			select 
				descrizione, allegato, obbligatorio, anagDoc, @newId as  idHeader, TipoFile,RichiediFirma, ' descrizione allegato obbligatorio ' ,DSE_ID
				from 
					CTL_DOC_ALLEGATI with (nolock)
				where idheader = @IdRisp_PrimaFase and dse_id='DOCUMENTAZIONE_RICHIESTA'
			
			exec END_OFFERTA_CHECK  @IdRisp_PrimaFase , @idPfu

			--setto un modello di visualizzazione diverso che ha una colonna in più per indicare gli allegati aggiunti nella seconda fase
			insert into CTL_DOC_SECTION_MODEL 
				(IdHeader, DSE_ID, MOD_Name)
				values
				(@newId  , 'DOCUMENTAZIONE' , 'RISPOSTA_CONCORSO_ALLEGATI_II_FASE' )

				

			--riporto la forma di partecipazione RTI dalla prima fase
			insert into ctl_doc_value
					(IdHeader , dse_id,row,dzt_name,value)
				select IdHeader , dse_id,row,dzt_name,value
					from ctl_Doc_value with (nolock) where idheader=@IdRisp_PrimaFase and dse_id='TESTATA_RTI' order by IdRow 
			
			insert into ctl_doc_value
					(IdHeader , dse_id,row,dzt_name,value)
				select @newId as IdHeader , dse_id,row,dzt_name,value
					from ctl_Doc_value with (nolock) where idheader=@IdRisp_PrimaFase and dse_id in ('RTI','AUSILIARIE','SUBAPPALTO','ESECUTRICI')  order by IdRow 
			
			insert into Document_Offerta_Partecipanti
				( [IdHeader], [TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa], [StatoDGUE], [AllegatoDGUE], [IdDocRicDGUE], [EsitoRiga], [Allegato]	)
				select 
					@newId as [IdHeader], [TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa], [StatoDGUE], [AllegatoDGUE], [IdDocRicDGUE], [EsitoRiga], [Allegato]
					from
						Document_Offerta_Partecipanti
					where
						idheader= @IdRisp_PrimaFase


		

		end

   end


   	-- recupero la sezione DOCUMENTAZIONE e la sezione DOCUMENTAZIONE_TECNICA dal bando 	
	insert into CTL_DOC_ALLEGATI ( descrizione, allegato, obbligatorio, anagDoc, idHeader , TipoFile,RichiediFirma, NotEditable,DSE_ID )
		select descrizione, allegato, obbligatorio, anagDoc, @newId as idHeader , TipoFile, RichiediFirma , NotEditable , DSE_ID
			from OFFERTA_ALLEGATI_FROM_BANDO_GARA
			where id_from = @idOrigin  and DSE_ID <> 'DOCUMENTAZIONE_RICHIESTA_PRIMAFASE'


   --ALLA CREAZIONE VALORIZZO I CAMPI ESITO COMPLESSIVO
	insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
		select @newId,'TESTATA_DOCUMENTAZIONE','EsitoRiga','<img src="../images/Domain/State_Warning.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'


	 insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
		select @newId,'TESTATA_DOCUMENTAZIONE_TECNICA','EsitoRiga','<img src="../images/Domain/State_Warning.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'



   --select @newId as id


END




GO
