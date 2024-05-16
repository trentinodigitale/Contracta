USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_GENERICA_PDA_CONCORSO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









						
CREATE PROCEDURE [dbo].[OLD2_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_GENERICA_PDA_CONCORSO] 
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
	declare @IdPfu as INT
    declare @Allegato nvarchar(255)
    declare @Descrizione nvarchar(255)
    declare @key_mlng as nvarchar(2000)
    declare @SEDUTA as varchar(50)
    declare @idSeduta INT

	Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,
		@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,
		@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale 
		from CTL_DOC with (nolock) where id=@idDoc
	
	--FG051222 INCLUSI (0) / NON INCLUSI(1)
	declare @Seleziona_Deleted as int
	set @Seleziona_Deleted = convert(int,dbo.PARAMETRI ( 'PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_GENERICA','Seleziona_Deleted','DefaultValue','',0 ))

 	--recupero una chiave di multilinguismo da inserire come testo delle comunicazioni per i fornitori
	--select @key_mlng=ML_Description from LIB_MULTILINGUISMO where ML_KEY='ML_Testo Descrizione Comunicazione Verifica Amministrativa' and ML_LNG='I'

	---Insert nella CTL_DOC per creare la comunicazione 
	insert into CTL_DOC 
		(IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck,DataDocumento,Caption)
		VALUES
		(@IdUser,'PDA_COMUNICAZIONE_GENERICA','Comunicazione Generica',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-GENERICA',getdate(),'Comunicazione Generica')

			
	set @Id = @@identity	

	---inserisco la riga per tracciare la cronologia nella PDA
	declare @userRole as varchar(100)
	select    @userRole= isnull( attvalue,'')
		from ctl_doc d 
			left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
		where id = @id

	-- Utilizzo il tipoDoc PDA_CONCORSO per gestire le comunicazioni
	insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
		values ('PDA_CONCORSO' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione Generica' , @IdUser , @userRole   , 1  , getdate() )
			
		
	--inserisco riga nella ctl_doc_value 
	insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
		values (@Id, 'DIRIGENTE','0','RichiestaRisposta','no')
	
	declare @RuoloNascosto as int
	declare @ModelloGriglia as varchar(200)
	set @RuoloNascosto=1
	-- Modello dinamico creato
	set @ModelloGriglia='PDA_COMUNICAZIONE_CONCORSO_GENERICA_DETTAGLI_Ruolo'
	select @RuoloNascosto= dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1)
	
	if   @RuoloNascosto = 1
		-- Modello dinamico creato 
		set @ModelloGriglia='PDA_COMUNICAZIONE_CONCORSO_GENERICA_DETTAGLI_SenzaRuolo'
		
	-- aggiungo nella ctl_doc_section_model il modello di griglia con il ruolo
	insert into CTL_DOC_SECTION_MODEL			
		( [IdHeader], [DSE_ID], [MOD_Name]	)
		values
		( @Id,'DETTAGLI',@ModelloGriglia)	
								
	--metto in una tabella temporanea i destinatari della comunicazione
	CREATE TABLE #TempDestinatari_Comunicazioni(
			[ProtocolloRiferimento] [varchar] (200) collate DATABASE_DEFAULT ,
			[idaziPartecipante] int,
			[Ruolo_Partecipante] [varchar] (200) collate DATABASE_DEFAULT,
			[idaziRiferimento] int,
			[CodiceFiscale] [varchar] (200) collate DATABASE_DEFAULT,
			[RagSocRiferimento] [varchar] (1000) collate DATABASE_DEFAULT,
			[Deleted] int,
			-- Aggiunto il campo Progressivo_Risposta che contiene l'identificativo del concorso
			[Progressivo_Risposta] [varchar] (200) collate DATABASE_DEFAULT
		)  
	
	insert into #TempDestinatari_Comunicazioni
		(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento, deleted,Progressivo_Risposta)
		select 	distinct 
			OFFERTA.protocollo,
			idaziPartecipante,	
			case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as Ruolo_Partecipante,
			idaziPartecipante,
			do.codicefiscale,
			DO.RagSocRiferimento,
			case when DPO.StatoPda in (1 ) then 1 else @Seleziona_Deleted end as deleted,
			-- Il campo titolo contiene il Progressivo_Risposta
			OFFERTA.Titolo
			from 
				Document_PDA_OFFERTE DPO with(nolock)
														
					inner join ctl_doc OFFERTA with(nolock)  on OFFERTA.id=idmsg
					left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=idmsg
					left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
					cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

				where 
					DPO.idHEader=@idDoc and StatoPda not in ('99')


		

		insert into #TempDestinatari_Comunicazioni
		(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento, deleted,Progressivo_Risposta)
		
		--lista altre partecipanti(mandanti/esecutrici)
		select 
			distinct
			DPO.ProtocolloRiferimento, 
			DPO.PARTECIPANTE , 
			DPO.Ruolo_Partecipante ,
			DPO.idaziriferimento,
			DPO.codicefiscale,
			DPO.RagSocRiferimento,
			case when DPO.StatoPda in (1 ) then 1 else @Seleziona_Deleted end as deleted,
			-- Il campo titolo contiene il Progressivo_Risposta
			DPO.Titolo
			from 
				dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) DPO 
				left join #TempDestinatari_Comunicazioni TMP on TMP.idaziPartecipante=DPO.PARTECIPANTE		
			where 
					StatoPda not in ('99')
					and TMP.idaziPartecipante IS NULL
					
	-- lista dei fornitori - creiamo le singole comunicazioni
	insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,
					DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,JumpCheck,Deleted,  VersioneLinkedDoc) 
		
		select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica',@Fascicolo,@Id,@Body,
			DEST.ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,
			DEST.idaziPartecipante,getDate(),'1-GENERICA',DEST.deleted, 
			--compongo la colonna Ruolo a seconda della tipologia del partecipante nella RTI
			case
				when DEST.Ruolo_Partecipante='' then ''
				when DEST.Ruolo_Partecipante in ('Mandataria','Mandante') then DEST.RagSocRiferimento + ' - ' + DEST.Ruolo_Partecipante
				when DEST.Ruolo_Partecipante in ('Esecutrice') then
							
					isnull(DEST_RIF.RagSocRiferimento,'') +  
					case 
						when isnull(DEST_RIF.RagSocRiferimento,'') <> '' then ' - ' 
						else '' 
					end 
					+ ' Esecutrice di ' + DEST.RagSocRiferimento

			end as VersioneLinkedDoc
		from 
			#TempDestinatari_Comunicazioni DEST
				left join #TempDestinatari_Comunicazioni DEST_RIF on 
						DEST_RIF.ProtocolloRiferimento = DEST.ProtocolloRiferimento 
						and DEST.idaziRiferimento = DEST_RIF.idaziPartecipante 

		--select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica',@Fascicolo,@Id,@Body,@ProtocolloRiferimento,
		--@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),'1-GENERICA' ,
		--		case when StatoPda in (1 ) then 1 else 0 end as deleted
		--		, case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as VersioneLinkedDoc
		--	from Document_PDA_OFFERTE o
		--		left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and statofunzionale='Pubblicato' and linkeddoc=idmsg
		--		left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
		--		cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H
		--	where o.idHEader=@idDoc and StatoPda not in (99)
		--	--where idHEader=@idDoc and StatoPda not in (1,99)
		--UNION
		----AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
		--select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione Generica',@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,DF.PARTECIPANTE,getDate(),'1-GENERICA' ,
		--		case when StatoPda in (1 ) then 1 else 0 end as deleted
		--		,Ruolo_Partecipante
		--	from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI(@idDoc) DF				
		--	where  StatoPda not in (99)
	
	--recupero le comunicazioni figlie appena create e per ognuna aggiungo 
	--il record nella ctl_doc_value con il campo "NumeroDocumento" che determina l'ordinamento
	select 
		id,ProtocolloRiferimento,Destinatario_Azi 
			into #temp_com_dettagli 
		from 
			ctl_doc with (nolock) 
		where 
			linkeddoc = @Id and tipodoc='PDA_COMUNICAZIONE_GARA'
				

	insert into ctl_Doc_value
		( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )

		select 
			id,'SORTEGGIO' as DSE_ID ,0 as Row ,'NumeroDocumento' as DZT_Name,

			COM_DET.ProtocolloRiferimento + ' - ' + 
				case 
					when DEST.Ruolo_Partecipante='' then '0'
					when DEST.Ruolo_Partecipante='mandataria' then '1 - ' + DEST.codicefiscale
					when DEST.Ruolo_Partecipante='mandante' then '2 - '+ DEST.codicefiscale
					when DEST.Ruolo_Partecipante='esecutrice' then '3 - ' + isnull(DEST_RIF.codicefiscale,'') + ' - ' + DEST.codicefiscale
				end  as value		
								
			from 
				#temp_com_dettagli COM_DET
					inner join #TempDestinatari_Comunicazioni DEST 
													on  DEST.ProtocolloRiferimento=COM_DET.ProtocolloRiferimento 
														and DEST.idaziPartecipante=COM_DET.Destinatario_Azi 
					left join #TempDestinatari_Comunicazioni DEST_RIF 
													on DEST_RIF.ProtocolloRiferimento=COM_DET.ProtocolloRiferimento 
														and DEST_RIF.idaziPartecipante  = DEST.idaziriferimento

			--inserisco progressivo risposta per ogni comunicazione figlia
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
				

				--inserisco modello dinamico per la testata di ogni com di dettaglio
				insert into CTL_DOC_SECTION_MODEL			
				( [IdHeader], [DSE_ID], [MOD_Name]	)
					select 
						 Id,'TESTATA','PDA_COMUNICAZIONE_GARA_TESTATA_CONCORSO'
						from 
							#temp_com_dettagli	

	-- rirorna l'id della nuova comunicazione appena creata
	-- utilizzo il TYPE_TO per non creare un nuovo tipoDoc così da poter riutilizzare quello già presente
	select @Id as id, 'PDA_COMUNICAZIONE_GENERICA' as TYPE_TO

	


END



GO
