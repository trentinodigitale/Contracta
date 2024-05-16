USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_COM_ART_36]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










						
CREATE PROCEDURE [dbo].[OLD2_PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_COM_ART_36] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	--@idDoc se vengo da una gara monolotto sarà idpda se vengo da una multilotto id lotto

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
	declare @DivisioneLotti varchar(100)
	declare @CriterioAggiudicazioneGara varchar(100)
	declare @IdPda as int = 0
	declare @JumpCheck as varchar(200)
	declare @Titolo as varchar(200)
	declare	@statoAgg as varchar(200)
	
	CREATE TABLE #TempLotti
	(
		[NumeroLotto] [varchar](200) collate DATABASE_DEFAULT NULL
		
	)  
	if exists (Select id from CTL_DOC with (nolock) where tipodoc = 'PDA_MICROLOTTI' and id = @Iddoc)
	begin
		set @IdPda = @IdDoc
		insert into #TempLotti (NumeroLotto) 
		select '1'
	end
	else
	begin
		select @IdPda = idHeader from Document_MicroLotti_Dettagli with (nolock) where id = @idDoc
		insert into #TempLotti (NumeroLotto) 
			select 
				NumeroLotto 
				from Document_MicroLotti_Dettagli with (nolock) where id = @idDoc
	end


	-- Controllo se c'è già un documento presente o devo crearlo
	if exists	(select id 
					from CTL_DOC with (nolock) 
					where linkeddoc = @IdPda 
						and JumpCheck = '0-COM_ART_36' 
						and tipodoc = 'PDA_COMUNICAZIONE_GENERICA' 
						and statofunzionale = 'InLavorazione'
						and Deleted = 0
				)
	begin

		select @Id = (select id 
					from CTL_DOC with (nolock) 
					where linkeddoc = @IdPda 
						and JumpCheck = '0-COM_ART_36' 
						and tipodoc = 'PDA_COMUNICAZIONE_GENERICA' 
						and statofunzionale = 'InLavorazione'
						and Deleted = 0)
	
	end
	else
	begin
		
		Select 
				@IdPfu=C.IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,
				@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,
				@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale ,
				@DivisioneLotti = B.Divisione_lotti,@CriterioAggiudicazioneGara=B.CriterioAggiudicazioneGara
			from CTL_DOC C with (nolock)
				inner join Document_bando B with (nolock) on C.linkeddoc = B.idheader
			where C.id=@IdPda
	
	

		--set @statoAgg='AggiudicazioneProvv'
		set @JumpCheck='0-COM_ART_36'
		set @Titolo='Art.36 comma 2'

 		--recupero una chiave di multilinguismo da inserire come testo delle comunicazioni per i fornitori
		--al momento non sappiamo se serve e lo lasciamo vuoto
		--select @key_mlng=ML_Description from LIB_MULTILINGUISMO where ML_KEY='ML_Testo Descrizione Comunicazione Verifica Amministrativa' and ML_LNG='I'
		set @key_mlng='' 

		---Insert nella CTL_DOC per creare la comunicazione 
		insert into CTL_DOC 
			(IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,
				JumpCheck,DataDocumento,Caption)
			VALUES
			(@IdUser,'PDA_COMUNICAZIONE_GENERICA',@Titolo,@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@IdPda,
				@azienda,@StrutturaAziendale,@JumpCheck,getdate(),'Art.36 comma 2')

			
		set @Id = SCOPE_IDENTITY()	

		---inserisco la riga per tracciare la cronologia nella PDA
		declare @userRole as varchar(100)
		select    @userRole= isnull( attvalue,'')
			from ctl_doc d with(nolock)
				left outer join profiliutenteattrib p with(nolock) on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
			where id = @id

			
		insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
			values ('PDA_MICROLOTTI' , @IdPda , 'PDA_COMUNICAZIONE_GENERICA' , 'Art.36 comma 2' , @IdUser , @userRole   , 1  , getdate() )
			
		
		--inserisco riga nella ctl_doc_value 
		insert into CTL_DOC_VALUE (IdHeader, DSE_ID, Row, DZT_Name, Value)
			values (@Id, 'DIRIGENTE','0','RichiestaRisposta','no')
	
	

	
		declare @RuoloNascosto as int
		declare @ModelloGriglia as varchar(200)
		set @RuoloNascosto=1
		set @ModelloGriglia='PDA_COMUNICAZIONE_GENERICA_DETTAGLI_Ruolo'
		--select @RuoloNascosto= dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1)
	
		if   @RuoloNascosto = 1
			set @ModelloGriglia='PDA_COMUNICAZIONE_GENERICA_DETTAGLI_SenzaRuolo'
		
		-- aggiungo nella ctl_doc_section_model il modello di griglia con il ruolo
		insert into CTL_DOC_SECTION_MODEL			
			( [IdHeader], [DSE_ID], [MOD_Name]	)
			values
			( @Id,'DETTAGLI',@ModelloGriglia)	


		--Aggiungo nella CTL_DOC_SECTION_MODEL il modello di griglia per gli allegati
		insert into CTL_DOC_SECTION_MODEL			
			( [IdHeader], [DSE_ID], [MOD_Name]	)
			values
			( @Id,'ALLEGATI','PDA_COMUNICAZIONE_GARA_ALLEGATI_ART_36')	

		--Aggiungo nella CTL_DOC_SECTION_MODEL il modello di griglia per la testata
		insert into CTL_DOC_SECTION_MODEL			
			( [IdHeader], [DSE_ID], [MOD_Name]	)
			values
			( @Id,'TESTATA','PDA_COMUNICAZIONE_GARA_TESTATA_ART_36')	
								
		--metto in una tabella temporanea i destinatari della comunicazione
		CREATE TABLE #TempDestinatari_Comunicazioni(
				[ProtocolloRiferimento] [varchar] (200) collate DATABASE_DEFAULT ,
				[idaziPartecipante] int,
				[Ruolo_Partecipante] [varchar] (200) collate DATABASE_DEFAULT,
				[idaziRiferimento] int,
				[CodiceFiscale] [varchar] (200) collate DATABASE_DEFAULT,
				[RagSocRiferimento] [varchar] (1000) collate DATABASE_DEFAULT,
				[Deleted] int,
				[Posizione] varchar(20)
			) 
		
		insert into #TempDestinatari_Comunicazioni
			(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento,[Posizione])
					
			--singolo partecipante oppure mandataria di una rti
			select 
				 top 5
				OFFERTA.protocollo,
				idaziPartecipante,	
				case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as VersioneLinkedDoc,
				idaziPartecipante,
				do.codicefiscale,
				DO.RagSocRiferimento,
				DMDO.Graduatoria
				from 
					Document_PDA_OFFERTE DPO with(nolock)
									
						cross join ( select NumeroLotto from #TempLotti	) as L
									
						inner join  document_microlotti_dettagli DMDO with(nolock) 
													on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'
														and DMDO.NumeroLotto = L.numerolotto and DMDO.Voce=0
									
						inner join ctl_doc OFFERTA with(nolock)  on OFFERTA.id=idmsg
						left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=idmsg
						left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
						cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

					where 
						DPO.idHEader=@idPda and StatoPda not in ('1','99')
					order by DMDO.Graduatoria 					 
					
					--insert into #TempDestinatari_Comunicazioni
					--(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento)
					----lista altre partecipanti(mandanti/esecutrici)
					--	select 
					--			 top 5
					--			DPO.ProtocolloRiferimento, 
					--			DPO.PARTECIPANTE , 
					--			DPO.Ruolo_Partecipante ,
					--			DPO.idaziriferimento,
					--			DPO.codicefiscale,
					--			DPO.RagSocRiferimento

					--			from 
					--				dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) DPO 
					--					inner join  document_microlotti_dettagli DMDO  on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE' and DMDO.Voce=0
					--																	and DMDO.NumeroLotto in (select NumeroLotto from #TempLotti )
					--					left join #TempDestinatari_Comunicazioni TMP on TMP.idaziPartecipante=DPO.PARTECIPANTE		
					--			where 
					--					StatoPda not in ('1','99')
					--					--and DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'
					--					--and DMDO.NumeroLotto in (select NumeroLotto from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,@statoAgg,@JumpCheck,@CriterioAggiudicazioneGara)			)
					--					and TMP.idaziPartecipante IS NULL
					--					order by DMDO.Graduatoria 				

		--select top 10 * from CTL_DOC_ALLEGATI
		--inserisco sulla capogruppo gli allegati
		--insert into CTL_DOC_ALLEGATI(idheader,Descrizione,DSE_ID,Obbligatorio)
		--	select  @Id, AZ.aziRagioneSociale,Posizione, 1
		--		from
		--			#TempDestinatari_Comunicazioni a with (nolock)
		--				inner join Aziende AZ with(nolock) on a.idaziPartecipante=IdAzi

		insert into CTL_DOC_ALLEGATI(idheader,Descrizione,DSE_ID,Obbligatorio, allegato)

			select 
				 top 5
				 @Id , dpo.aziRagioneSociale ,Posizione, 1 , a36.SIGN_ATTACH
				from 
					Document_PDA_OFFERTE DPO with(nolock)
									
						cross join #TempLotti as L
									
						inner join  document_microlotti_dettagli DMDO with(nolock) 
													on DPO.idrow=DMDO.idheader and DMDO.TipoDoc='PDA_OFFERTE'
														and DMDO.NumeroLotto = L.numerolotto and DMDO.Voce=0
									
						inner join ctl_doc A36 with(nolock)  on A36.LinkedDoc = DMDO.id and a36.TipoDoc ='PDA_ART_36' and a36.Deleted = 0 and a36.StatoFunzionale = 'Confermato'


					where 
						DPO.idHEader=@idPda and StatoPda not in ('1','99')
					order by DMDO.Graduatoria 			

			

		-- lista dei partecipanti (non esclusi) ai lotti che si trovano nello stato aggiucatario provvisorio
		-- creiamo le singole comunicazioni
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck ,VersioneLinkedDoc ) 			

			select @IdUser,'PDA_COMUNICAZIONE_GARA',@Titolo,@Fascicolo,@Id,@Body,DEST.ProtocolloRiferimento,
					@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,DEST.idaziPartecipante,getDate(),
					@key_mlng,@JumpCheck ,
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
										
					
						
		--AGGIUNGO IL MODELLO DINAMICO ALLE FIGLIE
		--Aggiung nella CTL_DOC_SECTION_MODEL il modello di griglia per gli allegati
		insert into CTL_DOC_SECTION_MODEL			
			( [IdHeader], [DSE_ID], [MOD_Name]	)				
			select id,'ALLEGATI','PDA_COMUNICAZIONE_GARA_ALLEGATI_ART_36'
				from CTL_DOC with(Nolock) where LinkedDoc=@Id

	end


	-- rirorna l'id della nuova comunicazione appena creata (o di quella già presente in memoria)
	select @Id as id


END
GO
