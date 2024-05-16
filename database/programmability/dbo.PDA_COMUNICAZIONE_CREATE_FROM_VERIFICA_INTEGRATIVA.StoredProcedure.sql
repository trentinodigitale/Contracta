USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_CREATE_FROM_VERIFICA_INTEGRATIVA] 
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
	declare @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA as nvarchar(4000)
	set @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA=''

	--controllo se esistono fornitori nello stato utile alla comunicazione integrativa
	IF NOT EXISTS ( select * from Document_PDA_OFFERTE with (nolock) where idHEader=@idDoc and StatoPda in ('9','22') )
	BEGIN
		select 'ERRORE' as id , 'Non sono presenti offerte il cui stato consente la creazione della comunicazione di verifica integrativa.' as Errore
	END
	ELSE
	BEGIN


			Select
				 @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,
					@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,
					@StrutturaAziendale=StrutturaAziendale 
				from CTL_DOC with (nolock) 
				where id=@idDoc

			set @DataScadenza= NULL -- RIMOSSO IN SEGUITO A RICHIESTA DI NAPOLI DATEADD(hh,23,DATEADD(mi,59,DATEADD(dd, 10, DATEDIFF(dd, 0, GETDATE() ) ) ) )
			
			---Insert nella CTL_DOC per creare la comunicazione 
			insert into CTL_DOC 
				(IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataScadenza,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
				VALUES
				(@IdUser,'PDA_COMUNICAZIONE','Comunicazione Di Verifica Integrativa',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataScadenza,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'1-VERIFICA_INTEGRATIVA' )

		
			set @Id = @@identity	

			---inserisco la riga per tracciare la cronologia nella PDA
			declare @userRole as varchar(100)
			select    @userRole= isnull( attvalue,'')
				from ctl_doc d 
					left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
				where id = @id

		
			insert into CTL_ApprovalSteps 
				( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione di Verifica Integrativa' , @IdUser , @userRole   , 1  , getdate() )
		
			
			
			--inserisco riga nella ctl_doc_value 
			insert into CTL_DOC_VALUE 
				(IdHeader, DSE_ID, Row, DZT_Name, Value)
			values
				(@Id, 'DIRIGENTE','0','RichiestaRisposta','si')
				
			select @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA=ML_Description from LIB_Multilinguismo with(nolock) where ML_KEY='testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA'

			declare @RuoloNascosto as int
			declare @ModelloGriglia as varchar(200)
			set @RuoloNascosto=1
			set @ModelloGriglia='PDA_COMUNICAZIONE_DETTAGLI_Ruolo'
			select @RuoloNascosto= dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1)
	
			if   @RuoloNascosto = 1
				set @ModelloGriglia='PDA_COMUNICAZIONE_DETTAGLI_SenzaRuolo'

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
					[Note] [ntext] 
				)  
			insert into #TempDestinatari_Comunicazioni
				(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento,Note)
					
				--singolo partecipante oppure mandataria di una rti
				select 
					distinct 
					OFFERTA.protocollo,
					idaziPartecipante,	
					case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as Ruolo_Partecipante,
					idaziPartecipante,
					do.codicefiscale,
					DO.RagSocRiferimento,
					dbo.PDA_MICROLOTTI_Esito(DPO.IdRow) + ' <br/> ' + @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA
					from 
						Document_PDA_OFFERTE DPO with(nolock)
														
							inner join ctl_doc OFFERTA with(nolock)  on OFFERTA.id=idmsg
							left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=idmsg
							left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
							cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

						where 
							DPO.idHEader=@idDoc and StatoPda in ('9','22')
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
					dbo.PDA_MICROLOTTI_Esito(DPO.IdRow) + ' <br/> ' + @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA
					from 
						dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) DPO 
						
					where 
							StatoPda in ('9','22')


			-- lista dei fornitori - creiamo le singole comunicazioni
			insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck,  VersioneLinkedDoc) 
				--select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Integrativa',@Fascicolo,@Id,@Body,
				-- @ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),
				-- dbo.PDA_MICROLOTTI_Esito(o.IdRow) + ' <br/> ' + @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA,'1-VERIFICA_INTEGRATIVA' 
				--		, case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as VersioneLinkedDoc
				--	from Document_PDA_OFFERTE o with(nolock)
				--	left join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and statofunzionale='Pubblicato' and linkeddoc=idmsg
				--	left join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
				--	cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

				--	where o.idHEader=@idDoc and StatoPda in ('9','22')
				--UNION 
				----AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
				--select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Integrativa',
				--@Fascicolo,@Id,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,
				--@azienda,DF.PARTECIPANTE,getDate(),
				--dbo.PDA_MICROLOTTI_Esito(DF.IdRow) + ' <br/> ' 
				--+ @testo_comunicazione_PDA_COMUNICAZIONE_GARA_VERIFICA_INTEGRATIVA,'1-VERIFICA_INTEGRATIVA' 
				--		,Ruolo_Partecipante
				--	from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) DF						
				--	where StatoPda in ('9','22')

				select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Verifica Integrativa',@Fascicolo,@Id,@Body,
					DEST.ProtocolloRiferimento,
					@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,DEST.idaziPartecipante,getDate(),
					DEST.Note,'1-VERIFICA_INTEGRATIVA' ,
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
										
					
				
	END

	-- rirorna l'id della nuova comunicazione appena creata
	select @Id as id

END







GO
