USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RETTIFICA_GARA_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RETTIFICA_GARA_CREATE_FROM_BANDO_GARA] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT
	declare @Errore as nvarchar(2000)
	declare @motivaz_ret as Nvarchar(4000)

	declare @jumpCheck varchar(100) = 'BANDO_GARA'

	declare @statoSchedaPCP varchar(100) = dbo.RECUPERA_STATO_PCP_SCHEDA(@idDoc)

	set @motivaz_ret = dbo.CNV('RETTIFICA_GARA_MSG_BANDO_GARA', 'I' )

	set @Errore = ''
	set @PrevDoc=0

	-- Recupero il tipoDoc originario
	select @jumpCheck = CASE WHEN ISNULL(TipoDoc,'') = 'BANDO_CONCORSO' THEN 'BANDO_CONCORSO' 
							  ELSE 'BANDO_GARA' 
						END
		from CTL_DOC with(nolock)
		where id = @idDoc

	IF @statoSchedaPCP = 'AV_IN_PUBB'
	BEGIN
		set @Errore = 'Pubblicazione in corso, non e possibile procedere con la rettifica'
	END
	
	--se la gara ha lo stato pcp 'Avviso pubblicato' ma non è stata ancora recuperata la pubblicità a valore legale allora blocchiamo
	IF @Errore = '' and @statoSchedaPCP = 'AV_PUBB' and NOT EXISTS (
		select top 1 a.IdRow
			from ctl_doc_value a with(nolock) 
			where a.idHeader = @idDoc and a.dse_id = 'InfoTec_DatePub' and a.DZT_Name = 'Pubblicazioni' and a.value = 'PVL'
	)
	BEGIN
		
		--Richiesta nel ticket BVEP-7708 : <<un blocco al click del rettifica avviso che scatti nel momento in cui il consulta-avviso automatico sia andato in errore 
		--o non scattato e presenti il seguente messaggio: "Prima di procedere innescare un consulta avviso presente in Gestione PCP">>
		set @errore = 'Prima di procedere innescare un consulta avviso presente in Gestione PCP'

	END

	IF @Errore = '' and EXISTS ( select id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PDA_COMUNICAZIONE_GENERICA' ) and jumpcheck = '0-REVOCA_BANDO' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di rettifica non puo essere creato se non viene conclusa la revoca in corso sul bando'
	END

	---controllo se per quel bando esiste una proroga/estensione
	IF @Errore = '' and EXISTS ( select id from ctl_doc with(nolock) where LinkedDoc=@idDoc and TipoDoc='PROROGA_GARA' and StatoFunzionale='InLavorazione' and deleted = 0)
	BEGIN
		set @Errore = 'Il documento di rettifica non puo essere creato se non viene conclusa l''estensione in corso sul bando'
	END

	-- cerco una versione precedente del documento 
	set @id = null

	select @id = id 
		from CTL_DOC with(nolock)
		where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RETTIFICA_GARA' ) and statofunzionale in ( 'InLavorazione','InApprovazione', 'InAttesaTed' )

	-- se non esiste lo creo
	if @id is null and  @Errore = '' 
	begin

			-- Altrimenti lo creo cambio statoFunzionale del Bando
			Update CTL_DOC 
					set StatoFunzionale='InRettifica' 
				where id=@idDoc

			-- Recupero un eventuale precedente proroga inviata
			Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
				from CTL_DOC with(nolock)
				where LinkedDoc=@idDoc and tipodoc='RETTIFICA_GARA' and Statofunzionale='Inviato'

			INSERT into CTL_DOC (IdPfu,  TipoDoc, Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Caption,Fascicolo,note,FascicoloGenerale,VersioneLinkedDoc )
					select @IdUser as idpfu , 'RETTIFICA_GARA' as TipoDoc ,  
							'Rettifica gara Num. ' + Protocollo as Titolo,  
							@idDoc as LinkedDoc,@PrevDoc,@jumpCheck,Body,Protocollo,CIG,'RichiestaQuesiti:'+RichiestaQuesito,Fascicolo,@motivaz_ret,ISNULL(TipoProceduraCaratteristica,''),
							CASE 
								when ISNULL(TipoProceduraCaratteristica,'') = 'RDO' then 'Rettifica RDO' 
								when ISNULL(TipoBandoGara , '') = '1' then 'Rettifica Avviso' 
								else 'Rettifica Gara' 
							END
					from document_bando  with(nolock)
						inner join ctl_doc  with(nolock) on id=idheader -- and tipodoc in ( 'BANDO_GARA' , 'BANDO_SEMPLIFICATO' )
					where idheader = @idDoc

			set @id = SCOPE_IDENTITY()

			----recupero tutti i dati del Bando
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','ProtocolloBando',ProtocolloBando
				from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','CIG',CIG
				from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','Descrizione',Body
				from CTL_DOC  with(nolock) where id = @idDoc --and tipodoc='BANDO_GARA' 
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','OLD_DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
				from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','OLD_DataSeduta', CONVERT(nvarchar(30), DataAperturaOfferte, 126)
				from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','OLD_DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
				from document_bando  with(nolock) where idheader = @idDoc

			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
				from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','DataSeduta', CONVERT(nvarchar(30), DataAperturaOfferte, 126)
				from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
					from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','DataRiferimentoInizio',CONVERT(nvarchar(30), DataRiferimentoInizio, 126)
					from document_bando  with(nolock) where idheader = @idDoc

			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','OLD_DataRiferimentoInizio',CONVERT(nvarchar(30), DataRiferimentoInizio, 126)	
					from document_bando  with(nolock) where idheader = @idDoc

			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','OLD_DataTermineRispostaQuesiti',CONVERT(nvarchar(30), ISNULL(DataTermineRispostaQuesiti,NULL), 126)
				from document_bando  with(nolock) where idheader = @idDoc
				
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','DataTermineRispostaQuesiti',CONVERT(nvarchar(30), ISNULL(DataTermineRispostaQuesiti,NULL), 126)
					from document_bando  with(nolock) 
					where idheader = @idDoc

			IF EXISTS ( select * from document_bando with(nolock) where idheader = @idDoc and TipoBandoGara = '1' and ProceduraGara = '15478' )
			BEGIN
					Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
						values (@id, 'TESTATA','TipoGara', 'AVVISO')
			END

			--controllo se vengo da un BANDO_SEMPLIFICATO 
			IF EXISTS ( select id from ctl_doc with(nolock) where id = @idDoc and TipoDoc ='BANDO_SEMPLIFICATO' )
			BEGIN
					Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
						values (@id, 'TESTATA','TipoGara', 'BANDO_SEMPLIFICATO')
			END

			--se la data DataPresentazioneRisposteDal è superata non consento di editare il campo
			if EXISTS (Select idRow from Document_Bando where idHeader=@idDoc and getdate() > DataRiferimentoInizio or isnull(DataRiferimentoInizio,'') = '' )
			BEGIN

				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					VALUES (@id,'TESTATA','Not_Editable',' DataRiferimentoInizio ')

			END

			--Recupero gli atti di gara del Bando e li inserisco nella rettifica
			insert into Document_Atti_Rettifica ( idHeader , Allegato_OLD,Descrizione_OLD,EvidenzaPubblica_OLD,AnagDoc)
				select @id,Allegato,Descrizione,EvidenzaPubblica,AnagDoc
				from CTL_DOC_ALLEGATI  with(nolock)
				where idHEader=@idDoc

	END

	IF @Errore = ''
	BEGIN

		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	END
	ELSE
	BEGIN

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	END

	SET NOCOUNT OFF

END














GO
