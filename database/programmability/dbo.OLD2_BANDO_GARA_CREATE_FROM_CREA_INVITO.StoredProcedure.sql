USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_BANDO_GARA_CREATE_FROM_CREA_INVITO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







 CREATE PROCEDURE [dbo].[OLD2_BANDO_GARA_CREATE_FROM_CREA_INVITO] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @idRow int
	declare @ProtocolBG  varchar(50)
	declare @TipoBandoGara varchar(100)
	declare @ProceduraGara varchar(100)
	declare @num INT
	declare @idPda INT
	declare @giroRistetta int
	declare @RichiestaCigSimog  varchar(50)
	declare @NumeroGara as varchar(100)
	declare @IdPregara as int
	declare @Lista_Enti_abilitati_RCig as varchar (4000)
	declare @idAzi INT
	declare @EvidenzaPubblica_Parametro as varchar(10)
	declare @TipoDocGara as varchar(100)

	set @Id = 0
	set @giroRistetta = 0

	SET NOCOUNT ON

	
	-- Se sto creando un invito dalla pda vuol dire che sono sul giro di ristretta
	IF EXISTS ( select id from CTL_DOC with(nolock) where Id = @idDoc and TipoDoc = 'PDA_MICROLOTTI' )
	BEGIN

		set @giroRistetta = 1
		set @idPda = @idDoc
		
		--recupero id della gara
		select @idDoc = LinkedDoc  from CTL_DOC with(nolock) where Id = @idDoc

	END


	if dbo.attivo_INTEROP_Gara (@idDoc)= 0
	BEGIN
		

		--PER LA RISTRETTA CONSENTIAMO LA CREAZIONE DI N INVITI
		IF @giroRistetta <> 1
		BEGIN
			-- cerca una versione precedente del documento
			select @Id = id 
				from CTL_DOC with(nolock)
					where LinkedDoc = @idDoc and TipoDoc = 'BANDO_GARA' and deleted = 0 and StatoDoc = 'Saved' 
		END

		-- se non viene trovato allora si crea il nuovo documento
		if isnull(@Id , 0 ) = 0 
		BEGIN
		
			declare @strDesc varchar(200)

			select  @strDesc  = case when TipoBandoGara  in ( '1' , '4' ) then dbo.CNV( 'dall'' Avviso' , 'I' ) else dbo.CNV( 'dal Bando' , 'I' ) end
					, @TipoBandoGara = TipoBandoGara
					, @ProceduraGara = ProceduraGara
				from document_Bando WITH(NOLOCK)
				where idheader = @idDoc

			select @ProtocolBG = Fascicolo--ProtocolBG
				from CTL_DOC
				where Id = @idDoc

			------------------------------------------------------------------------------------
			-- SE PROVENGO DA AVVISO-NEGOZIATA PASSO LO STATO FUNZIONALE DELLA GARA A CHIUSO ---
			------------------------------------------------------------------------------------
			update CTL_DOC 
					set statofunzionale = 'Chiuso' 
				where id = @idDoc and ( ( @TipoBandoGara = '1' and @ProceduraGara = 15478 ) or ( @TipoBandoGara = '2' and @ProceduraGara = 15477 ) )

			IF @giroRistetta = 1
			BEGIN

				update CTL_DOC 
						set statofunzionale = 'Chiuso' 
					WHERE Id = @idPda
		
			END
		
			-- genero la testata del documento
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
									ProtocolloRiferimento,  Fascicolo, LinkedDoc, StatoFunzionale ,Versione )
				select @idUser as IdPfu ,  'BANDO_GARA' , 'Saved' , 'Invito ' + @strDesc + d.Protocollo , d.Body , Azienda ,   StrutturaAziendale
						, d.Protocollo  , '' as Fascicolo ,  Id  ,'InLavorazione' , d.Versione
					from CTL_DOC d with(nolock)
							inner join document_Bando b with(nolock) on d.id = b.idheader
					where Id = @idDoc

			--ID DEL NUOVO DOCUMENTO
			set @Id = SCOPE_IDENTITY()

			--Se sul documento di partenza è presente la RIGAZERO la inserisco anche sull'invito
			IF EXISTS (select idrow from ctl_doc_value with(nolock) where idheader = @idDoc and DSE_ID = 'TESTATA_PRODOTTI' and DZT_Name = 'RigaZero' and Value = '1')
			BEGIN
				insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value) values (@Id,'TESTATA_PRODOTTI','RigaZero','1')
			END
		
		
			--settaggio RichiestaCigSimog
			IF (select dbo.attivoSimog())=1
				 set @RichiestaCigSimog= 'si'
			ELSE 
				 set @RichiestaCigSimog=null

			select @idazi = pfuidazi from profiliutente with(nolock) where idpfu = @idUser

			--se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no
			select  @Lista_Enti_abilitati_RCig= dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)
			if @Lista_Enti_abilitati_RCig <> '' and CHARINDEX (',' + cast(@idazi as varchar(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
				set @RichiestaCigSimog = 'no'


			-- inserico i dati base del bando
			insert into Document_Bando (
						idHeader, ImportoBando, dataCreazione, FAX , Ufficio, TipoBando, TipoAppalto, RichiestaQuesito,  ClasseIscriz, RichiediProdotti, ProceduraGara, 
						TipoBandoGara       , CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, 
						OffAnomale, NumeroIndizione, DataIndizione, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, TipoAppaltoGara,  Conformita, Divisione_lotti,
						NumDec, DirezioneEspletante, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica,Concessione,EnteProponente,RupProponente,RichiestaCigSimog, 
						Appalto_PNRR_PNC, Appalto_PNRR, Appalto_PNC, Motivazione_Appalto_PNRR, Motivazione_Appalto_PNC, ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, 
						ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE  )
				select  @Id    , ImportoBando, dataCreazione, FAX , Ufficio, TipoBando, TipoAppalto, RichiestaQuesito,  ClasseIscriz, RichiediProdotti, ProceduraGara, 
						'3' as TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, 
						OffAnomale, NumeroIndizione, DataIndizione, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, TipoAppaltoGara,  Conformita, Divisione_lotti,
						NumDec, DirezioneEspletante, ModalitadiPartecipazione, TipoIVA, 
					
						--se ristretta setto evidenza pubblica a 0 altrimenti 1 
						case when proceduragara = '15477' then '0' else '1' end as EvidenzaPubblica ,concessione,EnteProponente,RupProponente,@RichiestaCigSimog,

						Appalto_PNRR_PNC, Appalto_PNRR, Appalto_PNC, Motivazione_Appalto_PNRR, Motivazione_Appalto_PNC, ID_MOTIVO_DEROGA, FLAG_MISURE_PREMIALI, 
						ID_MISURA_PREMIALE, FLAG_PREVISIONE_QUOTA, QUOTA_FEMMINILE, QUOTA_GIOVANILE

					from document_bando f WITH (NOLOCK)
					where f.idHeader = @idDoc

			--riporto il campo UserRup dal primo giro
			insert into CTL_DOC_Value
				( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )
				select 
					@Id as idheader , dse_id,row,dzt_name,value
					from
						CTL_DOC_Value with (nolock)
					where IdHeader = @idDoc and DSE_ID='InfoTec_comune' and DZT_Name='UserRUP'

			insert into Document_dati_protocollo ( idHeader)
										  values (  @Id )

			-- SE L'UTENTE HA EFFETTUATO UN SORTEGGIO PUBBLICO CONGELO I DESTINATARI TRA QUELLI SORTEGGIATI
			IF EXISTS ( select id from CTL_DOC sortPub with(nolock) where sortPub.LinkedDoc = @idDoc and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0 and sortPub.StatoFunzionale = 'Confermato' )
					OR
				@giroRistetta = 1
			BEGIN

				IF @giroRistetta = 0
				BEGIN

					insert into CTL_DOC_Destinatari ( idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, ordinamento)
						select   @Id , ISNULL(a.CodiceFiscale,c.vatValore_FT) as CodiceFiscale, a.IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, CDDStato, Seleziona, NumRiga, a.ordinamento
						from CTL_DOC_Destinatari a with(nolock)
								inner join aziende b with(nolock) on b.idazi=a.idazi
								left join DM_Attributi c with(nolock) on c.lnk=b.IdAzi and c.idApp=1 and c.dztNome='Codicefiscale'
								inner join CTL_DOC sortPub with(nolock) on sortPub.LinkedDoc = @idDoc and sortPub.TipoDoc = 'SORTEGGIO_PUBBLICO' and sortPub.Deleted = 0 and sortPub.StatoFunzionale = 'Confermato'	
								inner join 	Document_AziSortPub sb with(nolock) on sb.idAzi = a.IdAzi and sb.idHeader = sortPub.id
						where a.idheader = @idDoc and isnull(StatoIscrizione,'') = ''

				END
				ELSE
				BEGIN

					insert into CTL_DOC_Destinatari ( idHeader, CodiceFiscale, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, ordinamento)
						select   @Id , ISNULL(a.CodiceFiscale,c.vatValore_FT) as CodiceFiscale, IdPfu, a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, CDDStato, Seleziona, a.NumRiga, ordinamento
						from CTL_DOC_Destinatari a with(nolock)
								inner join aziende b with(nolock) on b.idazi=a.idazi
								inner join Document_PDA_OFFERTE pdaOff with(nolock) on pdaOff.IdHeader = @idPda and pdaOff.StatoPDA = '2' and pdaOff.idAziPartecipante = b.IdAzi
								left join DM_Attributi c with(nolock) on c.lnk=b.IdAzi and c.idApp=1 and c.dztNome='Codicefiscale'
						where a.idheader = @idDoc --and isnull(StatoIscrizione,'') = ''

				END


				set @num=1

				declare CurProg Cursor Static for 
												select idRow 
												from CTL_DOC_Destinatari  with(nolock)
												where idHeader = @Id	
												order by ordinamento

				open CurProg
				FETCH NEXT FROM CurProg INTO @idrow

				WHILE @@FETCH_STATUS = 0
				BEGIN

					update CTL_DOC_Destinatari 
							set NumRiga=@num 
						where idrow=@idrow
				 
					set @num = @num + 1
				 			 
					FETCH NEXT FROM CurProg INTO @idrow

				END 

				CLOSE CurProg
				DEALLOCATE CurProg

			END

 


		END

		exec BANDO_GARA_DEFINIZIONE_STRUTTURA @id


		--recupero numero gara dalla gara
		select @NumeroGara=cig from document_bando  with (nolock) where  idHeader =  @id 

		--se numerogara presente su una richiesta CIG non associato ad un'altra gara 
	
		--recupero le gare che hanno associate una richiesta cig nello stato inviata 
		select 
			G.id
			into #tempCigara
		from
			CTL_DOC G with (nolock)
				inner join Document_Bando with (nolock) on idHeader = G.id
				inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG') and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
				left join Document_SIMOG_GARA DSG with (nolock) on DSG.idHeader =  RIC_CIG.id  
				left join Document_SIMOG_LOTTI DSL with (nolock) on DSL.idheader =  RIC_CIG.id  
				left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id
		where 
			G.TipoDoc in ('BANDO_GARA') and G.Deleted = 0 and G.Id <> @id
			and  (
					--presente su una richiesta smart cig
					( divisione_lotti = '0' and DSC.smart_cig = @NumeroGara )
					or
					--presente su numero gara si una richiesta cig a lotti
					( divisione_lotti <> '0' and DSG.id_gara  = @NumeroGara )
					or 
					--presente sui lotti di una richiesta cig non a lotti 
					( divisione_lotti = '0' and DSL.cig  = @NumeroGara )
				)

	
	
		 --e presente su un pregara non ancora utilizzato su nessuna gara allora faccio 
		 --recupero numero gara della gara
	
		if not exists (select * from #tempCigara)
		begin

			set @IdPregara=0

			select 
				--RIC_CIG.id
				--into #tempCigPreGara
				@IdPregara = G.Id 
			from
				CTL_DOC G with (nolock)
					inner join Document_Bando with (nolock) on idHeader = G.id
					inner join CTL_DOC RIC_CIG with (nolock) on  RIC_CIG.LinkedDoc = G.Id and RIC_CIG.tipodoc in ('RICHIESTA_CIG','RICHIESTA_SMART_CIG')  and RIC_CIG.StatoFunzionale ='inviato' and  RIC_CIG.Deleted =0
					left join Document_SIMOG_GARA DSG with (nolock) on DSG.idHeader =  RIC_CIG.id  
					left join Document_SIMOG_LOTTI DSL with (nolock) on DSL.idheader =  RIC_CIG.id 
					left join Document_SIMOG_SMART_CIG DSC with (nolock) on DSC.idHeader =  RIC_CIG.Id
			where 
				G.TipoDoc in ('PREGARA') and G.Deleted = 0 and G.StatoFunzionale  in ( 'Completo' ,'Concluso')
				and  (
						--presente su una richiesta smart cig
						(  DSC.smart_cig = @NumeroGara ) --divisione_lotti = '0' and
						or
						--presente su numero gara di una richiesta cig a lotti
						(  DSG.id_gara  = @NumeroGara ) --divisione_lotti <> '0' and
						or 
						--presente sui lotti di una richiesta cig non a lotti 
						(  DSL.cig  = @NumeroGara ) --divisione_lotti = '0' and
					)

			if @IdPregara <> 0 
				exec ASSOCIA_RICHIESTACIG_GARA_FROM_PREGARA  @IdPregara ,  @id,  @idUser

			--associao alla gara il pregara
			insert into CTL_DOC_Value ( IdHeader , DSE_ID , DZT_Name , Value )
				values
					(@id , 'InfoTec_comune', 'IdDocPreGara', cast(@IdPregara as varchar(100) ) )

		end


		--recupero @EvidenzaPubblica_Parametro dai parametri
		select @EvidenzaPubblica_Parametro = dbo.PARAMETRI('NUOVA_PROCEDURA-SAVE:INVITO','EvidenzaPubblica','DefaultValue','NULL',-1)
		if @EvidenzaPubblica_Parametro <> 'NULL'
		begin
			update Document_Bando 
				set EvidenzaPubblica = @EvidenzaPubblica_Parametro
				where idheader= @id
		end
		
		-- rirorna l'id del nuovo documento creato
		select @id as id

	END
	ELSE
	BEGIN
		
		--rimetto come iddoc input quello di partenza
		--perchè nella SP chiamata rifaccio il ragionamento
		if @giroRistetta = 1 
			set @idDoc = @idPda

		EXEC BANDO_GARA_CREATE_FROM_CREA_INVITO_INTEROP @idDoc,@idUser 

	END


	

END















GO
