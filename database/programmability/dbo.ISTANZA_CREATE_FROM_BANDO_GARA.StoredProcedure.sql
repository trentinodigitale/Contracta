USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[ISTANZA_CREATE_FROM_BANDO_GARA]( @idOrigin as int, @idPfu as int = -20, @newId as int output ) 
AS
BEGIN
	--Versione=1&data=2014-09-22&Attivita=63141&Nominativo=Federico

	--BEGIN TRAN

	SET NOCOUNT ON

	declare @output as nvarchar(max)
	DECLARE @tabella as varchar(1000)
	DECLARE @model as varchar(1000)

	-- viste di createFrom delle sezioni che hanno il parametro view_from
	--	OFFERTA_TESTATA_FROM_BANDO_GARA	 / TESTATA	/	CTL_DOC / FROM_USER_FIELD=idpfu
	--	OFFERTA_TESTATA_FROM_BANDO_GARA		 / COPERTINA	/	CTL_DOC  / FROM_USER_FIELD=idPfu
	--	OFFERTA_ALLEGATI_FROM_BANDO_GARA	 / DOCUMENTAZIONE	/	CTL_DOC_ALLEGATI 
	--	OFFERTA_TESTATA_PRODOTTI_FROM_BANDO_GARA	 / TESTATA_PRODOTTI	/	CTL_DOC_Value 

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
	declare @excel varchar(500)
	declare @CodiceModello varchar(500)
	declare @MOD_OffertaInd varchar(500)
	declare @MOD_OffertaINPUT varchar(500)
	declare @Divisione_lotti varchar(1)
	


	select @fascicolo = Fascicolo, 
		   @linkedDoc = LinkedDoc,
		   @prevDoc = 0,
		   @richiestaFirma = RichiestaFirma,
		   @sign_lock = '',
		   @sign_attach = '',
		   @protocolloRiferimento = protocolloRiferimento,
		   @strutturaAziendale = strutturaAziendale,

		   @body			= Body,
		   @azienda			= Azienda,
		   @DataScadenza	= DataScadenza,
		   @Destinatario_Azi = Destinatario_Azi,
		   @Destinatario_User = Destinatario_User,
		   @jumpCheck = JumpCheck ,
		   @CodiceModello =  TipoBando,
		   @Divisione_lotti = Divisione_lotti
		   
		from OFFERTA_TESTATA_FROM_BANDO_GARA where id_from = @idOrigin and idpfu = @idpfu
    


    --nel caso della creazione della domnda chiamo una stored specifica
    if exists (select * from document_bando where idheader=@idOrigin and ProceduraGara = '15477' and TipoBandoGara = '2')
    begin
	   Exec  DOMANDA_PARTECIPAZIONE_CREATE_FROM_BANDO_GARA @idOrigin, @idPfu, @newId output
    end	                      
    else 
    begin

	    insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
							  sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
							  Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck,idPfuInCharge, Titolo
							  )
		    select @idPfu, 'OFFERTA', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				    ,@fascicolo, @linkedDoc, @richiestaFirma,@sign_lock, @sign_attach, @protocolloRiferimento, @strutturaAziendale
				    ,@body, @azienda, @DataScadenza, @Destinatario_Azi, @Destinatario_User, @jumpCheck,@idPfu, 'Senza Titolo'

	    IF @@ERROR <> 0 
	    BEGIN
		    raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		    --rollback tran
		    return 99
	    END 

	    set @newId = SCOPE_IDENTITY()--@@identity

	    set @tabella = 'OFFERTA_TESTATA_PRODOTTI_FROM_BANDO_GARA'
	    set @model = 'OFFERTA_TESTATA_PRODOTTI_SAVE'

	    exec GENERATE_INSERT_VERTICAL_FROM_VIEW_AND_MODEL 
			    @tabella,
			    @model,
			    @newId,
			    @idOrigin,
			    'TESTATA_PRODOTTI',
			    '',
			    @idPfu,
			    @output output

	    exec ( @output )

	

	    -- sezione DOCUMENTAZIONE	
	    insert into CTL_DOC_ALLEGATI ( descrizione, allegato, obbligatorio, anagDoc, idHeader , TipoFile,RichiediFirma, NotEditable )
		    select descrizione, allegato, obbligatorio, anagDoc, @newId as idHeader , TipoFile, RichiediFirma , NotEditable 
				from OFFERTA_ALLEGATI_FROM_BANDO_GARA
					where id_from = @idOrigin
					order by idrow 
   

	    -----------------------------------------------------------------------------------
	    -- precarico i modelli da usare con le sezioni
	    -----------------------------------------------------------------------------------
	    set @Modello = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_Offerta'
	    set @ModelloTec = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_OffertaTec'
	    set @MOD_OffertaINPUT = 'MODELLI_LOTTI_' + @CodiceModello + '_MOD_OffertaINPUT'

	    --Nella busta di compilazione dei prodotti è stato associato il modello coerente con la tipologia di gara
	    --Quando una gara prevede la busta tecnica il modello per la compilazione è l'unione della busta tecnica ed economica altrimenti solo la parte economica
	    -- si estende verificando 
	    --if exists (Select * from Document_Bando where idheader=@linkedDoc and ( CriterioAggiudicazioneGara='15532' or Conformita <> 'no') )
	    if exists( 	select b.id
					    from ctl_doc b -- BANDO
						    inner join document_bando ba with (nolock) on ba.idheader = b.id
						    inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc
			
						    left outer join Document_Microlotti_DOC_Value v1 with (nolock) on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
						    left outer join Document_Microlotti_DOC_Value v2 with (nolock) on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			
						    where b.id = @linkedDoc and
								    ( isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532' or isnull( v1.Value , CriterioAggiudicazioneGara ) = '25532'  or isnull( v2.Value , Conformita ) <> 'No' ) 
			    )
	    BEGIN
		    insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			    values( @newId , 'PRODOTTI' , @MOD_OffertaINPUT  )
	    END
	    ELSE
	    BEGIN
		    insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			    values( @newId , 'PRODOTTI' , @Modello  )
	    END
	
	    insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
				    values( @newId , 'BUSTA_ECONOMICA' , @Modello )

	    insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
				    values( @newId , 'BUSTA_TECNICA' , @ModelloTec )

	    

	    --se non supero soglia MAX_NUMROW_IMPORT_FROM_BANDO
	    declare @MAX_ROW_CREATE as int
	    select  @MAX_ROW_CREATE = dbo.PARAMETRI('DOCUMENTO-OFFERTA','MAX_ROW_CREATE' ,'DefaultValue','10',-1)
	    
	    --recupero numero righe del bando
	    declare @NumRowBando as int
	    select @NumRowBando=count(*) from Document_MicroLotti_Dettagli with (nolock) where idheader = @idOrigin  and TipoDoc = 'BANDO_GARA'

		declare @numlotti as INT
		set @numlotti=0

		-- recupero il numero di Lotti GARA
		select  @numlotti=count(*)
			from dbo.Document_MicroLotti_Dettagli D  where Voce=0 and  idheader = @idOrigin
			group by idheader


	    if @NumRowBando <= @MAX_ROW_CREATE or @Divisione_lotti = 0 or @numlotti = 1
	    begin
		  
			declare @Filter as varchar(500)
			declare @DestListField as varchar(500)

			set @Filter = ' Tipodoc=''BANDO_GARA'' '
			set @DestListField = ' ''OFFERTA'' as TipoDoc, '''' as EsitoRiga '
		  
		  
		  

			exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idOrigin, @newId, 'IdHeader', 
								' Id,IdHeader,TipoDoc,EsitoRiga ', 
								@Filter, 
								' TipoDoc, EsitoRiga ', 
								@DestListField,
								' id '

		  

	    end
	    
	    	  
	    -- setto il warning sull'esito complessivo
	    insert into ctl_doc_value ( idheader, DSE_ID, DZT_Name, value)
						    values( @newId, 'TESTATA_PRODOTTI', 'EsitoRiga', 'E necessario compilare la scheda prodotti ed eseguire il comando "Verifica Informazioni"' )


	

	    --se sul bando è richiesta la terna per il subappalto inserisco le 3 righe sulla griglia del subappalto
	    IF EXISTS ( Select * from Document_Bando where idHeader=@idOrigin and ISNULL(Richiesta_terna_subappalto,'')='1')
	    BEGIN	

		    insert into Document_Offerta_Partecipanti ( IdHeader,TipoRiferimento,IdAzi,RagSoc,CodiceFiscale,IndirizzoLeg,LocalitaLeg ,ProvinciaLeg)
		    select @newId , 'SUBAPPALTO','','','','','',''
		    insert into Document_Offerta_Partecipanti ( IdHeader,TipoRiferimento,IdAzi,RagSoc,CodiceFiscale,IndirizzoLeg,LocalitaLeg ,ProvinciaLeg)
		    select @newId , 'SUBAPPALTO','','','','','',''
		    insert into Document_Offerta_Partecipanti ( IdHeader,TipoRiferimento,IdAzi,RagSoc,CodiceFiscale,IndirizzoLeg,LocalitaLeg ,ProvinciaLeg)
		    select @newId , 'SUBAPPALTO','','','','','',''
		
	    END

		--ALLA CREAZIONE VALORIZZO I CAMPI ESITO COMPLESSIVO
		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
			select @newId,'TESTATA_DOCUMENTAZIONE','EsitoRiga','<img src="../images/Domain/State_Warning.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'

		insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
			select @newId,'TESTATA_PRODOTTI','EsitoRiga','<img src="../images/Domain/State_Err.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'



		-- Nel caso di rilancio competitivo viene ripresa la RTI eventualmente presente nell'offerta dei lotti fatta sull'AQ
	    IF EXISTS ( Select * from Document_Bando where idHeader=@idOrigin and ISNULL(TipoProceduraCaratteristica,'') = 'RilancioCompetitivo' )
	    BEGIN	
			
			exec OFFERTA_INIT_FROM_AQ  @idOrigin , @newId 

		end    

		--- nuova gestione ampiezza di gamma
		declare @idmodelloAcquisto int
		declare @idmodelloAmpiezzaGamma int
		declare @BandoAlPrezzoConformita varchar(1)
		declare @ModAmpGammaTecnico varchar(1)
		declare @ModAmpGammaEconomico varchar(1)
		declare @ModAmpGammaTecnicoEconomico varchar(1)		
		declare @nomeModelloAmpGamma varchar(1000)
		declare @nomeModelloAmpGammaTemp varchar(1000)

		set @BandoAlPrezzoConformita = '0'
		set @ModAmpGammaEconomico = '0'
		set @ModAmpGammaTecnico = '0'
		set @ModAmpGammaTecnicoEconomico = '0'

		--se  è attivo il modulo ampiezza di gamma
		IF  EXISTS (	select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name='SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,AMPIEZZA_DI_GAMMA,%'	)
		begin

			select @idmodelloAcquisto = Value						
					from CTL_DOC_Value with(nolock)
					where idheader = @idOrigin and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'id_modello' --idModello acquisto

			select @idmodelloAmpiezzaGamma = Value 
				from CTL_DOC_Value with(nolock)
				where IdHeader = @idmodelloAcquisto and DSE_ID = 'AMBITO' and DZT_Name = 'TipoModelloAmpiezzaDiGamma' --idmodelloAmpiezzaGamma

			--controllo se il bando è al prezzo senza conformita
				if exists (select idLotto from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO with(nolock) where idBando = @idOrigin and CriterioAggiudicazioneGara = 15536 and Conformita = 'no' and idLotto in ( select id from Document_MicroLotti_Dettagli with(nolock) where IdHeader = @idOrigin and AmpiezzaGamma = 1))
					set @BandoAlPrezzoConformita = '1'
			
				--controllo se il modello di ampiezza di gamma prevede busta economica 
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_Offerta' and DSE_ID = 'MODELLI' and Value <> '')  
					set @ModAmpGammaEconomico = '1'

				--controllo se il modello di ampiezza di gamma prevede busta tecnica 
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_OffertaTec' and DSE_ID = 'MODELLI' and Value <> '')  
					set @ModAmpGammaTecnico = '1'

				--controllo se il modello di ampiezza di gamma prevede busta economica e tecnica
				if exists (select * from ctl_doc_value with(nolock) where IdHeader = @idmodelloAmpiezzaGamma and DZT_Name = 'MOD_OffertaINPUT' and DSE_ID = 'MODELLI' and Value <> '')  
					set @ModAmpGammaTecnicoEconomico = '1'

				--associo i modelli

				select @nomeModelloAmpGamma = Titolo from CTL_DOC where id = @idmodelloAmpiezzaGamma
		
				if (@ModAmpGammaTecnicoEconomico = '1')
				begin 
					set @nomeModelloAmpGammaTemp = 'MODELLO_BASE_AMPIEZZA_DI_GAMMA_' + @nomeModelloAmpGamma + '_MOD_OffertaINPUT'

					INSERT INTO CTL_DOC_SECTION_MODEL (IdHeader,DSE_ID,MOD_Name)
						 VALUES(@newId,'PRODOTTI_AMPIEZZA_GAMMA',@nomeModelloAmpGammaTemp)

					insert into ctl_doc_value (IdHeader, DSE_ID, Row, DZT_Name, Value)
						values(@newId, 'MODELLI', 0, 'ModelloAmpiezzaDamma', @nomeModelloAmpGammaTemp)

					insert into ctl_doc_value (IdHeader, DSE_ID, Row, DZT_Name, Value)
						values(@newId, 'TESTATA_PRODOTTI_AMPIEZZA_GAMMA', 0, 'Tipo_Modello_AmpiezzaGamma', @nomeModelloAmpGammaTemp)
					
					--rende editabili gli attributi
					update CTL_ModelAttributeProperties 
						set MAP_Value = 1
						where MAP_MA_MOD_ID = @nomeModelloAmpGammaTemp
							and MAP_MA_DZT_Name in ('NumeroLotto','Voce')
							and MAP_Propety = 'Editable'

				end

			end --se  è attivo il modulo ampiezza di gamma --IF  EXISTS (...

    end

END




















GO
