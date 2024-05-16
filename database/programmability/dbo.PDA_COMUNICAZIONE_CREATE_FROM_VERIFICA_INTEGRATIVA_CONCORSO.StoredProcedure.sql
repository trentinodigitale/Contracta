USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA_CONCORSO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA_CONCORSO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @DataScadenza as datetime
	declare @IdPfu as INT
	declare @Dati_In_Chiaro as varchar(10)

	declare @crlf  varchar(20)
	set @crlf  = '
'

	
	--RECUPERO SE I DATI SONO IN CHIARO SULLA PDA
	set @Dati_In_Chiaro = '0'
	select
		@Dati_In_Chiaro = isnull([Value],0)
		from 
			ctl_doc_value  with(nolock) 
		where idheader = @idDoc 
			and DSE_ID = 'ANONIMATO' 
			and DZT_Name = 'DATI_IN_CHIARO' 
			and Row = 0


	Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale from CTL_DOC where id=@idDoc
	set @DataScadenza=DATEADD(hh,13,DATEADD(dd, 10, DATEDIFF(dd, 0, GETDATE())))
	---Insert nella CTL_DOC per creare la comunicazione 
	insert into 
		CTL_DOC 
			(IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataScadenza,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
		VALUES
			(@IdUser,'PDA_COMUNICAZIONE','Comunicazione Di Verifica Integrativa Lotto',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataScadenza,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-VERIFICA_INTEGRATIVA' )

		
	set @Id = SCOPE_IDENTITY() --@@identity	

    ---inserisco la riga per tracciare la cronologia nella PDA
	declare @userRole as varchar(100)
	select    @userRole= isnull( attvalue,'')
		from ctl_doc d 
			left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
		where id = @id

		
	insert into CTL_ApprovalSteps 
		( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values ('PDA_CONCORSO' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione di Verifica Integrativa Lotto' , @IdUser , @userRole   , 1  , getdate() )
		
		
				
		
	-- lista dei fornitori - creiamo le singole comunicazioni
	--insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck,Caption) 
	--	select @IdUser,'PDA_COMUNICAZIONE_GARA', left( 'Comunicazione di Verifica Integrativa Lotto Numero ' + l.NumeroLotto + ' - ' + l.Descrizione , 100 ) ,@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),'Si richedono verifiche per il lotto numero ' + l.NumeroLotto + ' - ' + l.Descrizione + ' per i motivi di seguito indicati' + @crlf + @crlf + cast( c.Body as nvarchar(4000)),'1-VERIFICA_INTEGRATIVA','Comunicazione di Verifica Integrativa Lotto'
	--			from Document_PDA_OFFERTE o
	--				inner join 	Document_MicroLotti_Dettagli b on o.IdHeader = b.idheader and b.Voce = 0 --and b.tipodoc = 'PDA_CONCORSO'
	--				inner join 	Document_MicroLotti_Dettagli l on o.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
	--				inner join	ctl_doc c on c.tipodoc = 'ESITO_LOTTO_VERIFICA' and c.StatoDoc = 'Sended' and c.StatoFunzionale = 'Confermato' and c.LinkedDoc = l.id
	--			where l.StatoRiga = 'inVerifica' and o.IdHeader = @idDoc -- b.id = @idDocLotto


	--recupero le comunicazioni figlie appena create e per ognuna aggiungo 
	--il record nella ctl_doc_value con il campo "NumeroDocumento" che determina l'ordinamento
	

	--metto in una tabella temporanea i destinatari della comunicazione
	CREATE TABLE #TempDestinatari_Comunicazioni(
			[ProtocolloRiferimento] [varchar] (200) collate DATABASE_DEFAULT ,
			[idaziPartecipante] int,
			[Ruolo_Partecipante] [varchar] (200) collate DATABASE_DEFAULT,
			[idaziRiferimento] int,
			[CodiceFiscale] [varchar] (200) collate DATABASE_DEFAULT,
			[RagSocRiferimento] [varchar] (1000) collate DATABASE_DEFAULT,
			[Note] [ntext], 
			-- Aggiunto il campo Progressivo_Risposta che contiene l'identificativo del concorso
			[Progressivo_Risposta] [varchar] (200) collate DATABASE_DEFAULT
		)

	insert into #TempDestinatari_Comunicazioni
		(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento,Note,
		Progressivo_Risposta)
					
		--singolo partecipante oppure mandataria di una rti
		select 
			distinct 
			OFFERTA.protocollo,
			idaziPartecipante,	
			case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as Ruolo_Partecipante,
			idaziPartecipante,
			do.codicefiscale,
			DO.RagSocRiferimento,
			--dbo.PDA_MICROLOTTI_Esito(DPO.IdRow), --+ ' <br/> ' + @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA,
			cast( E.Body as nvarchar(4000)) as Note,
			-- Il campo titolo contiene il Progressivo_Risposta
			OFFERTA.Titolo as Progressivo_Risposta
			from 
				Document_PDA_OFFERTE DPO with(nolock)
					
					inner join 	Document_MicroLotti_Dettagli b on DPO.IdHeader = b.idheader and b.Voce = 0 --and b.tipodoc = 'PDA_CONCORSO'
					inner join 	Document_MicroLotti_Dettagli l on DPO.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
					inner join	ctl_doc E on E.tipodoc = 'ESITO_LOTTO_VERIFICA' and E.StatoDoc = 'Sended' and E.StatoFunzionale = 'Confermato' and E.LinkedDoc = l.id
					inner join ctl_doc OFFERTA with(nolock)  on OFFERTA.id=idmsg
					left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=idmsg
					left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
					cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H
				where DPO.idHEader=@idDoc  and l.StatoRiga = 'inVerifica'
				
				--and StatoPda in ('9','22')
		UNION 
		
		--lista altre partecipanti(mandanti/esecutrici)
		select 
			distinct
			DPO.ProtocolloRiferimento, 
			PARTECIPANTE , 
			Ruolo_Partecipante ,
			DPO.idaziriferimento,
			DPO.codicefiscale,
			DPO.RagSocRiferimento,
			cast( E.Body as nvarchar(4000)) as Note, --dbo.PDA_MICROLOTTI_Esito(DPO.IdRow), --+ ' <br/> ' + @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA,
			-- Il campo titolo contiene il Progressivo_Risposta
			DPO.Titolo as Progressivo_Risposta
			from 
				Document_PDA_OFFERTE O
					inner join dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc)  DPO on DPO.IdMsg = O.IdMsg
					inner join 	Document_MicroLotti_Dettagli b on O.IdHeader = b.idheader and b.Voce = 0
					inner join 	Document_MicroLotti_Dettagli l on DPO.IdRow = l.idheader and l.tipodoc = 'PDA_OFFERTE' and b.NumeroLotto = l.NumeroLotto and l.Voce = 0
					inner join	ctl_doc E on E.tipodoc = 'ESITO_LOTTO_VERIFICA' and E.StatoDoc = 'Sended' and E.StatoFunzionale = 'Confermato' and E.LinkedDoc = l.id
			where O.idHEader=@idDoc and l.StatoRiga = 'inVerifica'


		--CREO LE SINGOLE COPMUNICAZIONI FIGLIE
		insert into CTL_DOC 
			(IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck,  VersioneLinkedDoc) 

		select 
			@IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Integrativa',@Fascicolo,@Id,@Body,
					DEST.ProtocolloRiferimento,
					@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,DEST.idaziPartecipante,getDate(),
					DEST.Note,'1-VERIFICA_INTEGRATIVA' ,
					
					--compongo la colonna Ruolo a seconda della tipologia del partecipante nella RTI
					case
						when DEST.Ruolo_Partecipante='' then ''
						when DEST.Ruolo_Partecipante in ('Mandataria','Mandante') then 
						
							case 
								when @Dati_In_Chiaro='1' then DEST.RagSocRiferimento + ' - ' + DEST.Ruolo_Partecipante
								else DEST.Ruolo_Partecipante
							end

						when DEST.Ruolo_Partecipante in ('Esecutrice') then
							
							case
								when @Dati_In_Chiaro='1' then 
					
									isnull(DEST_RIF.RagSocRiferimento,'') +  
								case 
									when isnull(DEST_RIF.RagSocRiferimento,'') <> '' then ' - ' 
									else '' 
								end 
								
								+ ' Esecutrice di ' + DEST.RagSocRiferimento

							else 'Esecutrice'

					end 

					end as VersioneLinkedDoc

					from 
						#TempDestinatari_Comunicazioni DEST
							left join #TempDestinatari_Comunicazioni DEST_RIF on 
									DEST_RIF.ProtocolloRiferimento = DEST.ProtocolloRiferimento 
									and DEST.idaziRiferimento = DEST_RIF.idaziPartecipante 

	

	--inserisco progressivo risposta per ogni comunicazione figlia
	select 
		id,ProtocolloRiferimento,Destinatario_Azi 
			into #temp_com_dettagli 
		from 
			ctl_doc with (nolock) 
		where 
			linkeddoc = @Id and tipodoc= 'PDA_COMUNICAZIONE_GARA'

	
	insert into ctl_Doc_value
	( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
				
		select 
			id,'ANONIMATO' as DSE_ID ,0 as Row ,'Progressivo_Risposta' as DZT_Name
			,DEST.Progressivo_Risposta
			from 
				
				#temp_com_dettagli COM_DET
					inner join #TempDestinatari_Comunicazioni DEST 
					on  DEST.ProtocolloRiferimento=COM_DET.ProtocolloRiferimento 
														and DEST.idaziPartecipante=COM_DET.Destinatario_Azi


	IF NOT EXISTS (SELECT * FROM CTL_DOC_SECTION_MODEL WHERE [IdHeader] IN (SELECT ID FROM #temp_com_dettagli)  AND [DSE_ID] = 'TESTATA' AND [MOD_Name] = 'PDA_COMUNICAZIONE_GARA_TESTATA_CONCORSO')
	BEGIN
		--inserisco modello dinamico per la testata di ogni com di dettaglio
		insert into CTL_DOC_SECTION_MODEL			
		( [IdHeader], [DSE_ID], [MOD_Name]	)
			select 
					Id,'TESTATA','PDA_COMUNICAZIONE_GARA_TESTATA_CONCORSO'
				from 
					#temp_com_dettagli
		END

	IF NOT EXISTS (SELECT * FROM CTL_DOC_SECTION_MODEL WHERE [IdHeader] = @Id AND [DSE_ID] = 'DETTAGLI' AND [MOD_Name] = 'PDA_COMUNICAZIONE_CONCORSO_DETTAGLI')
	BEGIN
		--inserisco modello dinamico per la testata di ogni com di dettaglio
		insert into CTL_DOC_SECTION_MODEL			
		( [IdHeader], [DSE_ID], [MOD_Name]	)
			
		select 	@Id,'DETTAGLI','PDA_COMUNICAZIONE_CONCORSO_DETTAGLI'
		--from 
		--	#temp_com_dettagli
	END

	-- rirorna l'id della nuova comunicazione appena creata
	select @Id as id--, 'PDA_COMUNICAZIONE' as TYPE_TO

END



GO
