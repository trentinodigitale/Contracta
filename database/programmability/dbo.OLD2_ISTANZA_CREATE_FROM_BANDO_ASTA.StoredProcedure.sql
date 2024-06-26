USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ISTANZA_CREATE_FROM_BANDO_ASTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD2_ISTANZA_CREATE_FROM_BANDO_ASTA]( @idOrigin as int, @idPfu as int = -20, @newId as int output ) 
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
	declare @RagSoc nvarchar(500)
	

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
		   @CodiceModello =  TipoBando

		from OFFERTA_TESTATA_FROM_BANDO_GARA where id_from = @idOrigin and idpfu = @idpfu

	--recupero rag soc destinatario
	select  @RagSoc=aziragionesociale from aziende where idazi=@azienda

	insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,fascicolo,linkedDoc,richiestaFirma, 
						   sign_lock, sign_attach,protocolloRiferimento, strutturaAziendale,
						   Body, Azienda, DataScadenza, Destinatario_Azi, Destinatario_User, JumpCheck,idPfuInCharge,Titolo
						   )
		select @idPfu, 'OFFERTA_ASTA', 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
				,@fascicolo, @linkedDoc, @richiestaFirma,@sign_lock, @sign_attach, @protocolloRiferimento, @strutturaAziendale
				,@body, @azienda, @DataScadenza, @Destinatario_Azi, @Destinatario_User, @jumpCheck,@idPfu,'Rilanci ' + @RagSoc

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
	insert into CTL_DOC_ALLEGATI ( descrizione, allegato, obbligatorio, anagDoc, idHeader , TipoFile,RichiediFirma )
		select descrizione, allegato, obbligatorio, anagDoc, @newId as idHeader , TipoFile, RichiediFirma from OFFERTA_ALLEGATI_FROM_BANDO_GARA
			where id_from = @idOrigin
   

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
						inner join document_bando ba on ba.idheader = b.id
						inner join document_microlotti_dettagli lb with (nolock) on b.id = lb.idheader and lb.tipodoc = b.Tipodoc
			
						left outer join Document_Microlotti_DOC_Value v1 on v1.idheader = lb.id and v1.DZT_Name = 'CriterioAggiudicazioneGara'  and v1.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
						left outer join Document_Microlotti_DOC_Value v2 on v2.idheader = lb.id and v2.DZT_Name = 'Conformita'  and v2.DSE_ID = 'CRITERI_AGGIUDICAZIONE'
			
						where b.id = @linkedDoc and
								( isnull( v1.Value , CriterioAggiudicazioneGara ) = '15532'  or isnull( v2.Value , Conformita ) <> 'No' ) 
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
	
	--insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
	--			values( @newId , 'BUSTA_ECONOMICA' , @Modello )

	--insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
	--			values( @newId , 'BUSTA_TECNICA' , @ModelloTec )



	-----------------------------------------------------------------------------------
	-- precarico i prodotti prelevando dal bando
	-----------------------------------------------------------------------------------

	declare @IdRow2 INT
	declare @idr INT
	declare CurProg2 Cursor Static for 
		select   id as IdRow2
			from Document_MicroLotti_Dettagli 
			where idheader = @idOrigin  and TipoDoc = 'BANDO_ASTA'
			order by Id

	open CurProg2

	FETCH NEXT FROM CurProg2 
	INTO @IdRow2
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
				INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc,StatoRiga,EsitoRiga )
					select @newId , 'OFFERTA_ASTA' as TipoDoc,'' as StatoRiga,'' as EsitoRiga
				set @idr = SCOPE_IDENTITY()--@@identity				
				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow2  , @idr , ',Id,IdHeader,TipoDoc,EsitoRiga '			 
				 FETCH NEXT FROM CurProg2
			   INTO @IdRow2
			 END 

	CLOSE CurProg2
	DEALLOCATE CurProg2
		
	
	-- COMMIT TRAN
	

END










GO
