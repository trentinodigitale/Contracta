USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_MICROLOTTI_CREATE_FROM_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[OLD_PDA_MICROLOTTI_CREATE_FROM_BANDO_SEMPLIFICATO] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @ProtocolBG  varchar(50)
	declare @TipoDoc  varchar(250)
	declare @IdCommissione as int
	declare @Esito as varchar(100)
	declare @Errore as nvarchar(2000)	
	declare @USERRUP as nvarchar(500)

	declare @CodiceFiscale as varchar(20)
	declare @Nome as nvarchar(200)
	declare @cognome as nvarchar(200)
	declare @RagioneSociale as nvarchar(450)
	declare @RuoloUtente as nvarchar(200)

	declare @TipoBandoGara varchar(500)
	declare @ProceduraGara varchar(500)
	declare @TipoSeduta as varchar(20)
	declare @ProtocolloBando as varchar(50)
	declare @TipoProceduraCaratteristica as varchar(20)
	declare @IdRDA int

	set @TipoSeduta=''
	
	set @Id = 0
	
	set @Esito='OK'

	set @IdRDA = NULL

	SET NOCOUNT ON

	--recupero info dal bando
	select    
	
			@ProtocolBG = a.Fascicolo--ProtocolBG 
			, @TipoDoc = a.TipoDoc
			, @TipoBandoGara = b.TipoBandoGara
			, @ProceduraGara = b.ProceduraGara			
			, @USERRUP=RUP.Value
			, @TipoSeduta = b.TipoSedutaGara
			, @ProtocolloBando = a.Protocollo
			,@TipoProceduraCaratteristica = b.TipoProceduraCaratteristica 
			, @IdRDA = isnull(a.LinkedDoc ,0)
		from 
			CTL_DOC a with(nolock)
				LEFT JOIN document_bando b with(nolock) ON id = idheader
				LEFT OUTER JOIN CTL_DOC_Value RUP with(nolock) on RUP.IdHeader=Id and RUP.DSE_ID='InfoTec_comune' and RUP.DZT_Name='UserRUP'
		where Id = @idDoc
	
	-- cerca una versione precedente del documento PDA
	select 
			@Id = id 
		from CTL_DOC with(nolock) 
		where 
			LinkedDoc = @idDoc and TipoDoc = 'PDA_MICROLOTTI' 
			and deleted = 0 and StatoDoc = 'Saved' and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc --'BANDO_SEMPLIFICATO'
	
	--se non esiste la PDA procedo a fare i controlli
	--if isnull(@Id , 0 ) = 0 
	begin
		
		--chiamo la stored per i controlli sul tipo utente
		CREATE TABLE #TempCheck
		(
			[Id] [varchar](200) collate DATABASE_DEFAULT NULL,
			[Errore] [varchar](200) collate DATABASE_DEFAULT NULL
		)  
	
		insert into #TempCheck select top 0 '' as id,'' as errore from aziende 
	
		--chiamo la stored di controllo specifica
		insert into #TempCheck  exec CK_PDA_MICROLOTTI_CREATE_FROM_BANDO 
													@idDoc, 
													@idUser				
	
		select @Esito=id,@Errore=Errore from #TempCheck
	
		--cancello la tabella temporanea
		drop table #TempCheck

	end

	--set @Esito='OK'
	if @Esito='OK'
	begin
	
		-- se non viene trovato allora si crea il nuovo documento
		if isnull(@Id , 0 ) = 0 
		begin

			-- aggiorno il bando mettendo la fase in esame
			update CTL_DOC set statofunzionale = 'InEsame' where id = @idDoc 

			-- nel caso di RFQ aggiorna l'eventuale RDA collegata
			if (@TipoProceduraCaratteristica = 'RFQ') and not (@IdRDA is NULL)
			begin
				if @IdRDA > 0
					update CTL_DOC
						set StatoFunzionale = 'ValutazioneOfferte' 
							where id = @IdRDA and tipodoc='PURCHASE_REQUEST' 
			end

			insert into CTL_DOC (
					 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
						ProtocolloRiferimento,  Fascicolo,  JumpCheck ,
						LinkedDoc, StatoFunzionale,Caption )
				select @idUser as IdPfu ,  'PDA_MICROLOTTI' , 'Saved' , 'PDA per ' + d.Protocollo , d.Body , Azienda ,   StrutturaAziendale
						, d.Protocollo  ,  Fascicolo ,  @TipoDoc ,
						Id  ,'VERIFICA_AMMINISTRATIVA', 
							case when ProceduraGara = '15477' and TipoBandoGara='2' then 'Prequalifica' 
								 else 
									   case isnull(TipoSceltaContraente,'') when 'ACCORDOQUADRO' then 'Procedura di Valutazione' 
																		    else '' 
										end 
								 end
					from CTL_DOC d with(nolock)
							INNER JOIN document_Bando b with(nolock) on d.id = b.idheader
					where Id = @idDoc

			set @Id = SCOPE_IDENTITY()
			
			
			-- inizializzo i dati per la gestione della seduta virtuale sul bando
			UPDATE [Document_Bando]
					SET StatoSeduta='chiusa' , statochat = 'CLOSE'
				where idHeader = @idDoc
				--From [Document_Bando] d
					--inner join [CTL_DOC] c on d.idHeader=c.LinkedDoc
				--where c.id = @Id
			

			insert into Document_PDA_TESTATA
					( idHeader, ImportoBaseAsta, DataAperturaOfferte, CriterioAggiudicazioneGara, ModalitadiPartecipazione, CriterioFormulazioneOfferte, CIG , OffAnomale , CUP , ImportoBaseAsta2 
						, DataIISeduta , 	NumeroIndizione , DataIndizione , NRDeterminazione , Oggetto , DataDetermina , ListaModelliMicrolotti	, DirezioneProponente  , RequestSignTemp  , Conformita , TipoBandoGara, ProceduraGara, RichiestaCampionatura)
				select  @id   , ImportoBaseAsta, DataAperturaOfferte, CriterioAggiudicazioneGara, '16308' as ModalitadiPartecipazione, CriterioFormulazioneOfferte, CIG --, OffAnomale , CUP , ImportoBaseAsta2  
						 ,  OffAnomale
						 ,  CUP
						 ,  ImportoBaseAsta2
						 ,  null as  DataIISeduta
						 ,  NumeroIndizione
						 , DataIndizione
						 ,  '' as NRDeterminazione
						 , Body  as Oggetto
						 ,  null as DataDetermina
						 , TipoBando as ListaModelliMicrolotti
						 ,  StrutturaAziendale as DirezioneProponente
						 , null as  RequestSignTemp
						 , Conformita
						 , TipoBandoGara
						 , ProceduraGara
						 , isnull(RichiestaCampionatura,0) as RichiestaCampionatura
						 
					from  

						ctl_doc with (nolock)
							INNER JOIN Document_Bando with (nolock) on idHeader = id
					where Id = @idDoc
			
			--inizializzo le colonne fisse della PDA sulla tabella DOCUMENT_PODA_TESTATA
			exec PDA_MICROLOTTI_INIZIALIZZA_COLONNE_FISSE @id,@idUser


			--aggiungere le offerte
			declare @NumRiga as int


			insert into Document_PDA_OFFERTE
						( TipoDoc , IdHeader, NumRiga, aziRagioneSociale, ProtocolloOfferta, ReceivedDataMsg, IdMsg, IdMittente, idAziPartecipante, StatoPDA, Motivazione , Sostituita )
					select	d.TipoDoc , @id, ROW_NUMBER() over (order by DataInvio,Protocollo)  , case isnull(value,'') when '' then aziRagionesociale else value end , Protocollo , DataInvio , d.id, d.idpfu , IdAzi, 
							case 
								when  statodoc in ('Invalidate')   then  '99' 								
								else '8' 
							end as StatoPDA
							, '' as Motivazione , case when  statodoc in ('Invalidate') then  'si' else '' end as Sostituita
						from CTL_DOC d with(nolock)
							INNER JOIN aziende a with(nolock) on azienda= idazi 
							LEFT JOIN ctl_doc_value with(nolock) on d.id=idheader and dse_id='TESTATA_RTI' and dzt_name='DenominazioneATI'
						where LinkedDoc =  @idDoc and TipoDoc in ( 'OFFERTA', 'DOMANDA_PARTECIPAZIONE' ) and StatoDoc <> 'Saved' and d.Deleted = 0
						order by DataInvio,Protocollo

			if (@TipoProceduraCaratteristica = 'RFQ') 
				update Document_PDA_OFFERTE set StatoPDA='2' where IdHeader = @id  and TipoDoc in ( 'OFFERTA', 'DOMANDA_PARTECIPAZIONE' )

			--per ogni offerta verifico se ci sono anomalie
			exec CK_ANOMALIE_PDA @id

			
			declare @keyTestoDocEsclusi varchar(1000)

			set @keyTestoDocEsclusi = ''

			IF @TipoBandoGara = '2' AND @ProceduraGara = '15477'
			BEGIN
				set @keyTestoDocEsclusi = 'PDA_MSG_domanda_esclusa_invalidata'
			END
			ELSE
			BEGIN
				set @keyTestoDocEsclusi = 'PDA_MSG_esclusa_invalidata'
			END


			-- genero la motivazione di esclusione se necessario
			declare  @idRow INT
			declare @Stato varchar(50)
			declare @Protocollo varchar(50)


			DECLARE CurProg CURSOR STATIC FOR 
				
				select idRow ,  StatoPDA  
					from 
						Document_PDA_OFFERTE o with(nolock)
					where 
						IdHeader = @id and StatoPDA in ( '99')

			open CurProg

			FETCH NEXT FROM CurProg 
			INTO @idRow , @Stato


			WHILE @@FETCH_STATUS = 0
			BEGIN

				exec CTL_GetProtocol @idUser ,@Protocollo output 

				
				insert into CTL_DOC ( IdPfu , IdDoc , TipoDoc , StatoDoc , Protocollo , Titolo  , Body  , Azienda
										, DataInvio , Fascicolo , LinkedDoc , StatoFunzionale ) 
					select @idUser , m.id  , 'ESITO_ESCLUSA', 'Sended', @Protocollo , '' , case when ISNULL(ritiro.id,0) > 0 then l2.ML_Description else l.ML_Description end , p.pfuidazi
										, getdate() , m.Fascicolo , idRow , 'Sended' 
							from Document_PDA_OFFERTE o with(nolock)
									INNER JOIN CTL_DOC  m with(nolock) on m.Id  = o.IdMsg
									INNER JOIN profiliutente p with(nolock) on m.idPfu = p.idpfu
									--verifica se presente il ritiro offerta
									LEFT OUTER JOIN CTL_DOC ritiro with(nolock) on ritiro.LinkedDoc=o.IdMsg and ritiro.TipoDoc='RITIRA_OFFERTA' and ritiro.Deleted=0 and ritiro.StatoFunzionale='Inviato'
									LEFT OUTER JOIN LIB_Multilinguismo l with(nolock) on l.ML_KEY = @keyTestoDocEsclusi and l.ML_LNG = 'I'
									LEFT OUTER JOIN LIB_Multilinguismo l2 with(nolock) on l2.ML_KEY = 'PDA_MSG_esclusa_ritirata' and l2.ML_LNG = 'I'
							where o.idRow = @idRow


				FETCH NEXT FROM CurProg 
				INTO @idRow , @Stato
			END 

			CLOSE CurProg
			DEALLOCATE CurProg

			--ricopio le commissioni dal documento COMMISSIONE_PDA se esiste
			if exists(
					select id 
						from 
							CTL_DOC with(nolock) 
						where LinkedDoc = @idDoc and TipoDoc = 'COMMISSIONE_PDA' and deleted = 0 and statofunzionale = 'Pubblicato' and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc )		
			begin
				
				select 
					@IdCommissione=id 
					from 
						CTL_DOC with(nolock) 
					where LinkedDoc = @idDoc and TipoDoc = 'COMMISSIONE_PDA' and deleted = 0 and statofunzionale = 'Pubblicato' and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc
				
				declare @UtenteCommissione as int
				declare @RuoloCommissione as int
				declare @TipoCommissione as varchar(1)
				declare @RowA as int
				declare @RowB as int
				declare @RowC as int

				set	@RowA = 0		
				set	@RowB = 0
				set	@RowC = 0

 				DECLARE crsCommissione CURSOR STATIC FOR 

					select 
						UtenteCommissione, RuoloCommissione, TipoCommissione,CodiceFiscale ,Nome, cognome, RagioneSociale, RuoloUtente 
						from 
							Document_CommissionePda_Utenti with(nolock) 
						where idheader=@IdCommissione order by idrow

				OPEN crsCommissione

				FETCH NEXT FROM crsCommissione INTO @UtenteCommissione,@RuoloCommissione,@TipoCommissione, @CodiceFiscale , @Nome, @cognome, @RagioneSociale, @RuoloUtente
				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					if @TipoCommissione='A'
					begin
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GARA_D',@RowA,'NominativoCommissioneAggiudicatrice',@UtenteCommissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GARA_D',@RowA,'RuoloCommissione',@RuoloCommissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GARA_D',@RowA,'CodiceFiscale',@CodiceFiscale)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GARA_D',@RowA,'Nome',@Nome)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GARA_D',@RowA,'Cognome',@cognome)
			
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GARA_D',@RowA,'RagioneSociale',@RagioneSociale)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GARA_D',@RowA,'Ruoloutente',@RuoloUtente)

						set @RowA = @RowA + 1
					end
					
					if @TipoCommissione='G'
					begin
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GIUDICATRICE_D',@RowB,'NominativoCommissioneGiudicatrice',@UtenteCommissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GIUDICATRICE_D',@RowB,'RuoloCommissione',@RuoloCommissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GIUDICATRICE_D',@RowB,'CodiceFiscale',@CodiceFiscale)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GIUDICATRICE_D',@RowB,'Nome',@Nome)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GIUDICATRICE_D',@RowB,'Cognome',@cognome)
			
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GIUDICATRICE_D',@RowB,'RagioneSociale',@RagioneSociale)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_GIUDICATRICE_D',@RowB,'Ruoloutente',@RuoloUtente)
				

						set @RowB = @RowB + 1

					end
					
					if @TipoCommissione='C'
					begin
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_ECONOMICA_C',@RowC,'NominativoCommissioneGiudicatrice',@UtenteCommissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_ECONOMICA_C',@RowC,'RuoloCommissione',@RuoloCommissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_ECONOMICA_C',@RowC,'CodiceFiscale',@CodiceFiscale)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_ECONOMICA_C',@RowC,'Nome',@Nome)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_ECONOMICA_C',@RowC,'Cognome',@cognome)
			
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_ECONOMICA_C',@RowC,'RagioneSociale',@RagioneSociale)
				
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'COMMISSIONE_ECONOMICA_C',@RowC,'Ruoloutente',@RuoloUtente)

						set @RowC = @RowC + 1

					end

					FETCH NEXT FROM crsCommissione INTO @UtenteCommissione,@RuoloCommissione,@TipoCommissione, @CodiceFiscale , @Nome, @cognome, @RagioneSociale, @RuoloUtente
				END

				CLOSE crsCommissione 
				DEALLOCATE crsCommissione 
				

				
				declare @AnagDoc as varchar(200)
				declare @Descrizione as varchar(200)
				declare @DataEmissione as varchar(50)
				declare @allegato as varchar(200)
				declare @dse_id as varchar(50)
				
				set	@RowA = 0		
				set	@RowB = 0
				set	@RowC = 0

				--sostituisco gli atti
				DECLARE crsAtti CURSOR STATIC FOR 

					select 
						AnagDoc, Descrizione, convert( varchar , DataEmissione , 126 ) , allegato,dse_id 
						from 
							ctl_doc_allegati with(nolock) 
						where 
							idheader = @IdCommissione 
							order by idrow

				OPEN crsAtti

				FETCH NEXT FROM crsAtti INTO @AnagDoc,@Descrizione,@DataEmissione,@allegato,@dse_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					if @dse_id='ATTI'
					begin
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTI',@RowA,'AnagDoc',@AnagDoc)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTI',@RowA,'Descrizione',@Descrizione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTI',@RowA,'DataEmissione',@DataEmissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTI',@RowA,'allegato',@allegato)
						
						
						set @RowA = @RowA + 1
					end
					
					if @dse_id='ATTIG'
					begin
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIG',@RowB,'AnagDoc',@AnagDoc)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIG',@RowB,'Descrizione',@Descrizione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIG',@RowB,'DataEmissione',@DataEmissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIG',@RowB,'allegato',@allegato)

						set @RowB = @RowB + 1

					end
					
					if @dse_id='ATTIC'
					begin
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIC',@RowC,'AnagDoc',@AnagDoc)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIC',@RowC,'Descrizione',@Descrizione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIC',@RowC,'DataEmissione',@DataEmissione)
						
						insert into ctl_doc_value				
							(IdHeader, DSE_ID, Row, DZT_Name, Value)
						values
							(@id, 'ATTIC',@RowC,'allegato',@allegato)

						set @RowC = @RowC + 1

					end					

					FETCH NEXT FROM crsAtti INTO @AnagDoc,@Descrizione,@DataEmissione,@allegato,@dse_id
				END

				CLOSE crsAtti 
				DEALLOCATE crsAtti 

			end

			--SE SONO UNA GARAINFORMALE e non esiste la commissione allora inserisco il RUP come presidente della commissione
			IF ( @proceduragara  in ('15583','15479') and  NOT EXISTS (select id from CTL_DOC with (nolock) where LinkedDoc = @idDoc and TipoDoc = 'COMMISSIONE_PDA' and deleted = 0 and statofunzionale = 'Pubblicato' and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc ) )
			BEGIN

				--CREA LA COMMISSIONE
				declare @t table (name varchar(100))
				insert @t (name)
				
				EXEC COMMISSIONE_PDA_CREATE_FROM_BANDO_SEMPLIFICATO @idDoc,@idUser

				select @IdCommissione=name from @t
				
				--SETTA IL RUP COME PRESIDENTE DEL SEGGIO
				insert into Document_CommissionePda_Utenti
					(IdHeader, UtenteCommissione, RuoloCommissione, TipoCommissione,CodiceFiscale,Nome,Cognome,RagioneSociale,RuoloUtente,EMAIL)
					select 
						@IdCommissione, @USERRUP, '15548', 'A',pfuCodiceFiscale,pfunomeutente,pfuCognome,aziRagioneSociale,pfuRuoloAziendale,pfuE_Mail
						from ProfiliUtente with (nolock)
							INNER JOIN Aziende with (nolock) on pfuIdAzi=IdAzi
						where IdPfu=@USERRUP
				
				--CAMBIO LO STATO ALLA COMMISSIONE
				update ctl_doc set StatoFunzionale = 'Pubblicato', StatoDoc='Sended', DataInvio=getDate(),VersioneLinkedDoc='GARA_INFORMALE' where id = @IdCommissione

			END



			IF dbo.OCP_isActive( @idDoc, @idUser ) = 1
			BEGIN
				exec OCP_ISTANZIA_IMPRESE_CREATE_FROM_BANDO  @idDOC, @idUser, 0, 1
			END

		end


		--Una volta ottenuta la id della PDA si crea la chat room nel caso il tipo di seduta è virtuale.
		if(@TipoSeduta = 'virtuale')
		begin

			if(not exists(select * from VIEW_CHAT_INFO v with (nolock)  where v.idHeader=@id and v.DSE_ID = 'CHAT' and Chat_Stato='OPEN'))
			begin
				declare @titolo as varchar(100)
				set @titolo = 'Seduta Virtuale Gara ' + @ProtocolloBando
				EXECUTE [dbo].[CHAT_ROOM_CREATE] @idUser, @id, @titolo
				EXECUTE [dbo].[CHAT_ROOM_UPD]   @idUser, @id, @titolo, 'CLOSE'
			end

			-- iscrivo implicitamente l'utente alla chat
			exec CHAT_ROOM_ENTRY  @idUser , @id 


		end

		-- rirorna l'id della PDA
		select @id as id

	end
	else
	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end
	

END


















GO
