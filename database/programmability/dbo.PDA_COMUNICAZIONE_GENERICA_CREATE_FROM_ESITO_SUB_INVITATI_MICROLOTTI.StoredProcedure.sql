USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_SUB_INVITATI_MICROLOTTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[PDA_COMUNICAZIONE_GENERICA_CREATE_FROM_ESITO_SUB_INVITATI_MICROLOTTI] 
	( @idDoc int , @IdUser int , @TipoAggiudicazione varchar(200), @CriterioAggiudicazioneGara varchar(100) )
AS
--Versione=1&data=2014-03-18&Attivita=54707&Nominativo=Enrico
--crea la nuova comunicazione di aggiudicazione provvisoria invitati

BEGIN

	SET NOCOUNT ON;

	declare @Id as INT
	declare @c as INT
	declare @n as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT
	declare @Errore as nvarchar(2000)
	declare	@statoAgg as varchar(200)
	declare @JumpCheck as varchar(200)
	declare @Titolo as varchar(200)
	declare @JumpCheckPDA as varchar(200)
	declare @LinkedDoc as INT
	declare @conformita as varchar(100)
	declare @TipoDoc as varchar(100)

	select @TipoDoc=TipoDoc from ctl_doc where id=@idDoc
	
	if @TipoDoc='PDA_MICROLOTTI'
	begin
		select @conformita  = conformita  
			from CTL_DOC p with (nolock)
				inner join Document_Bando b with (nolock) on b.idheader = p.LinkedDoc
			where p.id = @idDoc
	end
	
	if @TipoDoc='BANDO_ASTA'
	begin
		select @CriterioAggiudicazioneGara=CriterioAggiudicazioneGara from document_bando with (nolock) where idheader=@idDoc
	end

	if @TipoAggiudicazione='AggiudicazioneProvv'
	begin

		set @statoAgg='AggiudicazioneProvv'
		set @JumpCheck='0-ESITO_MICROLOTTI'
		set @Titolo='Esito Provvisorio'

	end 		
	else
	begin

			-- ANCHE NELLA DEFINITIVA SI PARTE DAGLI AGGIUDICATI  PROVVISORI

			--set @statoAgg='AggiudicazioneDef'
			set @statoAgg='AggiudicazioneProvv'

			if @conformita = 'Ex-Post' -- se è richiesta la conformità expost si prendono i lotti controllati altrimenti quelli in aggiudicazione provvisoria
				set @statoAgg='Controllato'

			set @JumpCheck='0-ESITO_DEFINITIVO_MICROLOTTI'
			set @Titolo='Esito Definitivo'

	end

	set @Errore=''
	
		
	CREATE TABLE #TempLotti(
						[NumeroLotto] [varchar](200) collate DATABASE_DEFAULT NULL,
						[Aggiudicata] [int] NULL
					)  

	-- creo una tabella temporanea con i lotti nello stato adeguato
	if @TipoDoc='PDA_MICROLOTTI'
	begin
		insert into #TempLotti (NumeroLotto,Aggiudicata) 
			select NumeroLotto ,Aggiudicata
				from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,@statoAgg,@JumpCheck,@CriterioAggiudicazioneGara)
	end
	
	if @TipoDoc='BANDO_ASTA'
	begin
		
		--setto aggudicatario provvisorio e II classificato dell'asta
		exec ASTA_GRADUATORIA @idDoc
		
		insert into #TempLotti (NumeroLotto,Aggiudicata) 
			select NumeroLotto ,Aggiudicata 
				from GET_LOTTI_ASTA_COMUNICAZIONE_GENERICA(@idDoc,@statoAgg,@JumpCheck,@CriterioAggiudicazioneGara)

	end

	-- controllo che ci sono lotti nello stato richiesto
	--if not exists( select NumeroLotto from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,@statoAgg,@JumpCheck)) 
	
	--NON HO LOTTI DA INSERIRE NELLA COMUNICAZIONE, MA HO IL LOTTO IN @statoAgg, QUESTO SIGNIFICA CHE HO OFFERTE FT DA VALUTARE
	if not exists( select NumeroLotto from #TempLotti ) 
		and exists ( select * from Document_MicroLotti_Dettagli with (nolock) 
			where IdHeader=@idDoc AND TipoDoc='PDA_MICROLOTTI' and StatoRiga=@statoAgg )
	begin
		set @Errore = 'I Lotti in aggiudicazione presentano offerte per le quali non è stata ultimata la valutazione della documentazione.Prima di procedere ultimare la valutazione della documentazione delle offerte ricevute'
	end
	
	if not exists( select NumeroLotto from #TempLotti ) and @Errore=''
	begin 
		-- rirorna l'errore
		set @Errore = 'Non ci sono lotti nello stato ' + @statoAgg 
	end

	-- verifico se per i lotti recuperati c'è un fornitore in ammesso con riserva
	if @TipoDoc='PDA_MICROLOTTI'
	begin
		if exists( 
	
			--select l.*
			--	from document_pda_offerte o
			--		inner join Document_MicroLotti_Dettagli l on l.IdHeader = o.IdRow and Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'escluso' , 'esclusoEco' )
			--		inner join #TempLotti t on t.NumeroLotto = l.NumeroLotto
			--	where o.idheader = @idDoc and o.StatoPDA = '22' -- ammesso con riserva

				select o.IdMsgFornitore
				from document_pda_offerte o with (nolock)
					inner join Document_MicroLotti_Dettagli l with (nolock) on l.IdHeader = o.IdRow and Voce = 0 and l.TipoDoc = 'PDA_OFFERTE' and l.statoriga not in ( 'escluso' , 'esclusoEco' ) 
																						-- questa condizione ci focvalizza solo sugli aggiudicatari
																						and l.posizione in ( 'Aggiudicatario definitivo','Aggiudicatario definitivo condizionato','Aggiudicatario provvisorio')
						inner join #TempLotti t on t.NumeroLotto = l.NumeroLotto
							left join CTL_DOC EL with (nolock)on EL.linkeddoc=o.IdMsg and EL.TipoDoc='ESCLUDI_LOTTI' and EL.Deleted=0 and EL.StatoFunzionale='Confermato'
							left join 	ESCLUDI_LOTTI_LOTTI_VIEW ELD with (nolock) on ELD.IdHeader=EL.Id and ELD.NumeroLotto=l.NumeroLotto 
						
				where 
					 o.idheader = @idDoc 
					 
					 and 
			
						( 
							---- ammesso ex art 133 su intera offerta
							( o.StatoPDA = '222' ) 
							or
							---- in Verifica
							( o.StatoPDA = '9' ) 
							or
							---- ammesso con riserva su intera offerta
							( o.StatoPDA = '22' and EL.Id is null)
							or 
							-- ammesso con riserva non sciolta sul singolo lotto
							( o.StatoPDA = '22' and  ELD.StatoLotto = 'AmmessoRiserva' and ELD.EsitoRiserva <> 'OK'  )
						)

			) 
		begin 
			-- rirorna l'errore
			--set @Errore = 'Per i lotti dove e'' necessario fare la comunicazione di aggiudicazione e'' presente un fornitore con stato ammesso con riserva. Prima di procedere e'' necessario cambiare lo stato di questo fornitore'
			set @Errore = 'Per i lotti dove e'' necessario fare la comunicazione di aggiudicazione lo stato del fornitore aggiudicatario, nella fase amministrativa, deve essere ''Ammesso''. Prima di procedere e'' necessario cambiare lo stato di questo fornitore'

		end
	end


	--recupero campi per inserire la nuova comunicazione capogruppo
	Select @LinkedDoc=linkeddoc, @JumpCheckPDA=isnull(JumpCheck,''), @IdPfu=IdPfu, @Fascicolo=Fascicolo,
			@ProtocolloGenerale=ProtocolloGenerale,@DataProtocolloGenerale=DataProtocolloGenerale,
			@ProtocolloRiferimento=ProtocolloRiferimento,@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale 
		from CTL_DOC with (nolock)  where id=@idDoc

	
	
	-- inserisco i destinatari in una tabella temporanea	
	--select top 0 0 as idazi , cast( '' as nvarchar(100) ) as Ruolo_Partecipante
	--	into #TempInvitatiEsito 
	
	if @JumpCheckPDA<>'' or @TipoDoc='BANDO_ASTA'
	begin
		if @TipoDoc='PDA_MICROLOTTI'
		begin

			
			--provenienza nuovi documenti PDA_MICROLOTTI
			--insert into #TempInvitatiEsito
				
			--	select idazi , '' as Ruolo_Partecipante
			--		from 
			--			ctl_doc,ctl_doc_destinatari
			--		where id=@LinkedDoc and idheader=id
			--	UNION
			--	--AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
			--	select PARTECIPANTE as idazi , Ruolo_Partecipante
			--		from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI(@idDoc)
				
				--metto in una tabella temporanea i destinatari della comunicazione
			CREATE TABLE #TempDestinatari_Comunicazioni(
					[ProtocolloRiferimento] [varchar] (200) collate DATABASE_DEFAULT ,
					[idaziPartecipante] int,
					[Ruolo_Partecipante] [varchar] (200) collate DATABASE_DEFAULT,
					[idaziRiferimento] int,
					[CodiceFiscale] [varchar] (200) collate DATABASE_DEFAULT,
					[RagSocRiferimento] [varchar] (1000) collate DATABASE_DEFAULT
				) 

			insert into #TempDestinatari_Comunicazioni
				(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento)
				select '' as ProtocolloRiferimento ,idazi , '' as Ruolo_Partecipante,idazi,CodiceFiscale,aziRagioneSociale 
					from 
						ctl_doc with (nolock)
							inner join ctl_doc_destinatari with (nolock) on idheader=id
					where id=@LinkedDoc  

				UNION
				
				--AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
				select 
						distinct
						DPO.ProtocolloRiferimento, 
						PARTECIPANTE , 
						Ruolo_Partecipante ,
						DPO.idaziriferimento,
						DPO.codicefiscale,
						DPO.RagSocRiferimento

						from 
							dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) DPO 
									
								
		end
		else
		begin
			--provenienza nuovi documenti BANDO_ASTA
			--insert into #TempInvitatiEsito
			--	select idazi , '' as Ruolo_Partecipante
			--		from 
			--			ctl_doc,ctl_doc_destinatari
			--		where id=@idDoc and id=idheader 
			insert into #TempDestinatari_Comunicazioni
				(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento)
				select '' as ProtocolloRiferimento ,idazi , '' as Ruolo_Partecipante,idazi,CodiceFiscale,aziRagioneSociale 
					from 
						ctl_doc with (nolock)
							inner join ctl_doc_destinatari with (nolock) on idheader=id
					where id=@LinkedDoc 
		end
	end
	else	
	--provenienza documento generico
	begin

		--insert into #TempInvitatiEsito
		--	c 
		--		pfuidazi as idazi , '' as Ruolo_Partecipante
		--		from 
		--			tab_messaggi_fields,tab_utenti_messaggi TU, profiliutente
		--		where 
		--			iddoc=(select iddoc from tab_messaggi_fields where idmsg=@LinkedDoc) 
		--			and idmsg=umidmsg and isubtype in (69,48,168)
		--			and idpfu=TU.umidpfu

		insert into #TempDestinatari_Comunicazioni
				(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento)
				select '' as ProtocolloRiferimento, pfuidazi as idazi , '' as Ruolo_Partecipante,pfuidazi as idaziRiferimento, '' as CodiceFiscale, '' as RagSocRiferimento
				from 
					tab_messaggi_fields,tab_utenti_messaggi TU, profiliutente
				where 
					iddoc=(select iddoc from tab_messaggi_fields where idmsg=@LinkedDoc) 
					and idmsg=umidmsg and isubtype in (69,48,168)
					and idpfu=TU.umidpfu
	end

	if @Errore=''
	begin
		--controllo che ci sono aziende a cui fare la comunicazione
		if	not exists( 

--					select 
--						idazi 
--					from 
--						ctl_doc,ctl_doc_destinatari
--					where id=@idDoc and id=idheader 
--						
				--select top 1 * from #TempInvitatiEsito	
				select top 1 * from #TempDestinatari_Comunicazioni
		
						)
		begin 
			-- rirorna l'errore
			set @Errore = 'Non ci sono invitati' 
		end	
	end

	if @Errore = ''
	begin
		
		-- invalido le precedenti comunicazioni di dettaglio non inviate
		update CTL_DOC set StatoFunzionale='Invalidato',StatoDoc='Invalidate' 
				where JumpCheck=@JumpCheck and TipoDoc='PDA_COMUNICAZIONE_GARA' and 
						StatoFunzionale='InLavorazione' 
				and LinkedDoc in (Select id from CTL_DOC where LinkedDoc=@idDoc )
			
		--invalido la precedente capogruppo
		update CTL_DOC set StatoFunzionale='Invalidato',StatoDoc='Invalidate' 
				where JumpCheck=@JumpCheck and TipoDoc='PDA_COMUNICAZIONE_GENERICA' and 
						StatoFunzionale='InLavorazione' 
				and LinkedDoc=@idDoc

		

		--determino il corpo della comunicazione (da inserire nel campo note)
		--escludere i lotti per i quali ho già fatto una comunicazione dello stesso tipo
		
		--DA FARE
		--recupero la lista dei lotti per costruire il testo della comunicazione
		declare @Note as nvarchar(max)
		set @Note=dbo.RisolvoTemplatePDAMicrolotti(@idDoc,@JumpCheck,@statoAgg,@CriterioAggiudicazioneGara)
		
		--select 	len(dbo.RisolvoTemplatePDAMicrolotti(42227))
		
		---Insert nella CTL_DOC per creare la comunicazione capogruppo
		insert into CTL_DOC 
			(IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck,Note,Caption)
		VALUES
			(@IdUser,'PDA_COMUNICAZIONE_GENERICA',@Titolo,@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,@JumpCheck,@Note,@Titolo )

		set @Id = SCOPE_IDENTITY()	
		
		declare @RuoloNascosto as int
		declare @ModelloGriglia as varchar(200)
		set @RuoloNascosto=1
		set @ModelloGriglia='PDA_COMUNICAZIONE_GENERICA_DETTAGLI_Ruolo'
		select @RuoloNascosto= dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1)
	
		if   @RuoloNascosto = 1
			set @ModelloGriglia='PDA_COMUNICAZIONE_GENERICA_DETTAGLI_SenzaRuolo'
		
		-- aggiungo nella ctl_doc_section_model il modello di griglia con il ruolo
		insert into CTL_DOC_SECTION_MODEL			
			( [IdHeader], [DSE_ID], [MOD_Name]	)
			values
			( @Id,'DETTAGLI',@ModelloGriglia)	

		IF @JumpCheck = '0-ESITO_DEFINITIVO_MICROLOTTI'
		BEGIN

			-- mod. id att : 302476 Affinchè il sistema individui in maniera puntuale l'atto presente nella griglia degli allegati dell'Esito,
			--  occorre modificare tale comunicazione, like contratto, ovvero nella griglia occorre prevedere una prima riga bloccata
			--  che non si può eliminare con descrizione generica e non modificabile "Determina" dove inserire il provvedimento 
			--	che viene passato al Sitar al momento dell’invocazione del WS "IstanziaEsito"
			INSERT INTO CTL_DOC_ALLEGATI( idHeader, Descrizione, NotEditable)
					 VALUES ( @Id, 'Determina', ' Descrizione ' )

		END


		---inserisco la riga per tracciare la cronologia nella PDA
		declare @userRole as varchar(100)
		select    @userRole= isnull( attvalue,'')
			from ctl_doc d 
				left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
			where id = @id

			
		insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
			values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GENERICA' , 'Comunicazione di ' + @Titolo , @IdUser , @userRole   , 1  , getdate() )

		-- lista dei partecipanti (non esclusi) ai lotti che si trovano nello stato aggiucatario provvisorio
		-- creiamo le singole comunicazioni
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck , VersioneLinkedDoc) 
			--select @IdUser,'PDA_COMUNICAZIONE_GARA',@Titolo,@Fascicolo,@Id,@Body,@ProtocolloRiferimento,
			--@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,IdAzi,getDate(),@Note,@JumpCheck , Ruolo_Partecipante
			--	from 
			--		#TempInvitatiEsito
					--ctl_doc,ctl_doc_destinatari
				--where 
					--id=@idDoc and id=idheader 
				
			select @IdUser,'PDA_COMUNICAZIONE_GARA',@Titolo,@Fascicolo,@Id,@Body,DEST.ProtocolloRiferimento,
							@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,DEST.idaziPartecipante,getDate(),
							@Note,@JumpCheck ,
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
										
					
		
		--Per il controllo all'invio memorizzo i lotti aggiudicati in modo provvisorio con i secondi classificati
		--per i quali ho fatto la comunicazione
		if @TipoDoc='PDA_MICROLOTTI'
		begin

			insert into Document_comunicazione_StatoLotti
				(IdHeader, NumeroLotto, IdAziAggiudicataria, Importo, IdAziIIClassificata)
				select @id,NumeroLotto,Aggiudicata,ValoreImportoLotto,IIClassificata from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(@idDoc,@statoAgg,@JumpCheck,@CriterioAggiudicazioneGara)	
		end
		
		if @TipoDoc='BANDO_ASTA'
		begin

			insert into Document_comunicazione_StatoLotti
				(IdHeader, NumeroLotto, IdAziAggiudicataria, Importo, IdAziIIClassificata)
				select @id,NumeroLotto,Aggiudicata,ValoreImportoLotto,IIClassificata from GET_LOTTI_ASTA_COMUNICAZIONE_GENERICA(@idDoc,@statoAgg,@JumpCheck,@CriterioAggiudicazioneGara)	
		end
	end
	
	--select NumeroLotto from GET_LOTTI_PDA_COMUNICAZIONE_GENERICA(42227,'AggiudicazioneProvv')			
	
	-- rirorna l'id della nuova comunicazione appena creata se non ci sono stati errori
	if @Errore = ''
		begin
			-- rirorna l'id della nuova comunicazione appena creata
			select @Id as id
		
		end
	else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end	

END




GO
