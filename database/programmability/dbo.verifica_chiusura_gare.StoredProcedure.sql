USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[verifica_chiusura_gare]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[verifica_chiusura_gare]
(
	@protocolloGara VARCHAR(250) = ''
)
AS
BEGIN

	-- LA STORED VIENE CHIAMATA DALLA LIB_SERVICES E LAVORA SU TUTTE LE GARE( CHIAMATA PRIVA DI PARAMETRI )
	--		SE LA STORED VIENE INVECE INVOCATA CON IL REGISTRO DI SISTEMA DI UNA SPECIFICA GARA, PARAMETRO PROTOCOLLOGARA, VIENE FATTA LA VERIFICA DI CHIUSURA PER QUELLA PROCEDURA
	--		E NEL CASO QUESTA GARA NON POSSA ESSERE CHIUSURA VIENE DATO IN OUTPUT, COME SELECT, IL MOTIVO DELLA MANCATA CHIUSURA

	SET NOCOUNT ON	
	declare @totLottiGara int
	declare @tipoProceduraCaratteristica varchar(100)
	declare @generaConvenzione varchar(10)
	declare @idGara int
	declare @idPDA int
	declare @Xgiorni int
	declare @Divisione_lotti varchar(10)
	declare @TipoBandoGara varchar(100)
	declare @ProceduraGara varchar(100)
	declare @dataInvioGara datetime
	declare @StatoFunzionaleGara as varchar(100)
	declare @StatoFunzionalePDA as varchar(100)
	declare @motivazioneMancataChiusura as varchar(1000)
	declare @protGara varchar(1000)
	declare @GareDaChiudere TABLE (IdGara int)
	declare @DATA_CONFRONTO as  datetime
	declare @idPfuGara INT = NULL
	DECLARE @ListaCig VARCHAR(MAX)
	DECLARE @TipoSoglia VARCHAR(MAX)

	set @StatoFunzionalePDA = ''
	set @motivazioneMancataChiusura = ''

	-- 180 giorni dalla comunicazione di aggiudicazione def
	set @Xgiorni = dbo.parametri('verifica_chiusura_gare','NumeroGiorniChiusura','DefaultValue','180',-1) 

	--creo tabella temporanea delle gare da esaminare
	SELECT gara.id, 
				isnull(b.TipoProceduraCaratteristica,'') as TipoProceduraCaratteristica, 
				isnull(b.GeneraConvenzione,'0') as GeneraConvenzione, 
				isnull(pda.id,0) as idPDA , 
				b.Divisione_lotti, 
				TipoBandoGara, 
				ProceduraGara, 
				gara.DataInvio,
				gara.StatoFunzionale as StatoFunzionaleGara, 
				pda.StatoFunzionale as StatoFunzionalePDA,
				gara.Protocollo,
				isnull( case 
							when year(b.DataAperturaOfferte) = 1900 then null 
							--PER GLI ACCORDOQUADRO DEVE ESSERE SUPERATA DataRiferimentoFine
							when b.TipoSceltaContraente = 'ACCORDOQUADRO' then b.DataRiferimentoFine
							else b.DataAperturaOfferte 
						end , b.DataScadenzaOfferta)   as DATA_CONFRONTO,
				gara.IdPfu,
                gara.TipoDoc,
				isnull(TipoSoglia, '') as TipoSoglia
			INTO #GareDaEsaminare
		FROM ctl_doc gara with(nolock)
			inner join Document_Bando b with(nolock) ON b.idHeader = gara.id
			left join ctl_doc pda with(nolock) ON pda.linkeddoc = gara.id and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI' and pda.StatoFunzionale <> 'VERIFICA_AMMINISTRATIVA'
		WHERE gara.tipodoc in ( 'BANDO_GARA', 'BANDO_SEMPLIFICATO') and gara.deleted = 0 
			 and gara.StatoFunzionale not in ( 'Chiuso', 'InApprove', 'InLavorazione', 'Rifiutato', 'Revocato' , 'Sospeso') 			 
			 and getdate() >= isnull( case 
											when year(b.DataAperturaOfferte) = 1900 then null 
											--PER GLI ACCORDOQUADRO DEVE ESSERE SUPERATA DataRiferimentoFine
											when b.TipoSceltaContraente = 'ACCORDOQUADRO' then b.DataRiferimentoFine
											else b.DataAperturaOfferte 
										end , b.DataScadenzaOfferta) 

                    --todo
				--select * from #GareDaEsaminare
         --       select COUNT(*) from #GareDaEsaminare
	        --drop table #GareDaEsaminare
			

	--se è richiesta una gara specifica 
	IF ( @protocolloGara <> '' )
	BEGIN
		-- rimuovo dalla tabella temporanea tutte le altre
		DELETE FROM #GareDaEsaminare WHERE Protocollo <> @protocolloGara 
	END

	IF ( @protocolloGara <> '' ) AND NOT EXISTS ( select id from #GareDaEsaminare )
	BEGIN
		set @motivazioneMancataChiusura = 'La gara richiesta non verrà chiusa perchè ha uno stato funzionale fra Chiuso,InApprove,InLavorazione,Rifiutato,Revocato,Sospeso OPPURE non è stata raggiunta la DataAperturaOfferte/DataScadenzaOfferta'
	END

	--creo tabella temporanea dei lotti delle PDA (con la voce 0) relative alle gare da esaminare
	SELECT LottiPDA.id, 
			LottiPDA.idheader, 
			LottiPDA.StatoRiga,
			NumeroLotto
		INTO #LottiPDA 
		FROM Document_MicroLotti_Dettagli LottiPDA with(nolock)
				inner join #GareDaEsaminare G on G.idPDA = LottiPDA.IdHeader 
		WHERE LottiPDA.TipoDoc='PDA_MICROLOTTI' and isnull(LottiPDA.Voce,0) = 0

	CREATE NONCLUSTERED INDEX IDX_LottiPDA_idheader ON #LottiPDA(id asc,idheader asc,StatoRiga asc,numerolotto asc)

	DECLARE curs CURSOR STATIC FOR     
		select id,TipoProceduraCaratteristica, GeneraConvenzione, idPDA , Divisione_lotti,TipoBandoGara,ProceduraGara, 
				DataInvio, StatoFunzionaleGara, StatoFunzionalePDA,Protocollo, DATA_CONFRONTO,IdPfu, TipoSoglia 
			from  #GareDaEsaminare

	OPEN curs
	FETCH NEXT FROM curs INTO @idGara,@tipoProceduraCaratteristica,@generaConvenzione,@idPDA,@Divisione_lotti, @TipoBandoGara, @ProceduraGara,@dataInvioGara,@StatoFunzionaleGara,@StatoFunzionalePDA, @protGara,@DATA_CONFRONTO, @idPfuGara, @TipoSoglia
    
	
	----------------------------------------
	-- ITERO SULLE GARE IN AGGIUDICAZIONE --
	----------------------------------------
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
        -- Se è stato passato il protocollo di gara e c'è solo una gara da esaminare
	    IF ( ( @protocolloGara <> '' ) AND ( select COUNT(*) from #GareDaEsaminare ) = 1 )
	    BEGIN
            -- Se è abilitato il modulo SIMOG_GGAP allora schedulo nella Service_SIMOG_Requests l'invocazione l'endpoint per creare l'aggiudicazione del lotto in GGPA (CreaAggiudicazioneLotto)
            IF EXISTS ( SELECT id
                            FROM LIB_Dictionary WITH(NOLOCK)
                            WHERE DZT_Name = 'sys_moduli_gruppi' AND DZT_ValueDef LIKE '%,SIMOG_GGAP,%'
	        	)
            BEGIN
	            -- Si inserisce la richiesta
                INSERT INTO Service_SIMOG_Requests (idRichiesta, operazioneRichiesta, statoRichiesta, idPfuRup, dateIn)
                    VALUES (@idPda, 'creaAggiudicazioneLottoGgapPda', 'Inserita', @idPfuGara, GETDATE())
            END
	    END


		if   OBJECT_ID('tempdb..#LastComEsito') is not null
		begin
			drop table #LastComEsito
		end

		--recupero ultima com di esito definitivo e la memorizzo in una tabella temporanea 
		select 
			top  1  com.id, isnull(  CAST(ltVa.value AS datetime)   ,com.datainvio) as DataInvio
			into #LastComEsito
			from 
				ctl_doc com with(nolock)
					left join Document_comunicazione_StatoLotti com2 with(nolock) ON com2.IdHeader = com.id and com2.Deleted=0
					left join #LottiPDA lottiT ON lottiT.idheader = @idPDA and lottiT.NumeroLotto = com2.NumeroLotto  
					-- se l'aggiudicazione era condizionata recupero la datainvio del processo PDA_MICROLOTTI-AGG_DEFINITIVA_LOTTO
					left join Document_Microlotti_DOC_Value ltVa with(nolock) ON ltVa.idheader = lottiT.id and dse_id = 'INVIO_FINE_AGG_CONDIZ' and DZT_Name = 'DataInvio' and isnull(value,'') <> ''
			where 	com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.LinkedDoc = @idPDA and com.JumpCheck in ( '1-ESITO_DEFINITIVO_MICROLOTTI','0-ESITO_DEFINITIVO_MICROLOTTI' ) and com.Deleted = 0
			order by isnull(  CAST(ltVa.value AS datetime)   ,com.datainvio) desc
								
							

		-----------------------------------------------------------------------------------------
		-- GARE DESERTE DA INVIARE AD OCP, NON ASPETTIAMO I GIORNI PREVISTI DAL PAAMETRO   ------
		-----------------------------------------------------------------------------------------
		IF dbo.OCP_isActive( @idGara, @idPfuGara ) = 1
		BEGIN

			IF ( @TipoBandoGara <> '1' or @ProceduraGara <> '15478' ) and not ( @TipoBandoGara = '2' and @ProceduraGara = '15477' )
				
				AND 

				(
					--NON ESISTONO OFFERTE INVIATE PER LA GARA
					(
						NOT EXISTS 
						( 
							select id from ctl_doc with(nolock) 
								where LinkedDoc = @idGara and tipodoc = 'OFFERTA' 
									and deleted = 0 and StatoFunzionale in ( 'Inviato' , 'Rettificata' )
						)
					)

					OR

					-- SE LA GARA NON E' IN AGGIUDICAZIONE E I LOTTI SULLA PDA SONO TUTTTI IN UNO STATO FINALE ALLORA POSSO CHIUDURE
					-- dovrebbe essere valida sia per le gare a lotti che non a lotti se le gare non a lotti hanno sempre la voce 0
					(
					
						@StatoFunzionalePDA not IN ('','VERIFICA_AMMINISTRATIVA')
							and 
						NOT EXISTS( 			
									select lottiT.IdHeader
										from #LottiPDA lottiT
										where lottiT.idheader =@idPDA and lottiT.StatoRiga not in ('Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato' ) 
								)	
					)
					
					

				)
			BEGIN
				
				EXEC OCP_ISTANZIA_DOCUMENTAZIONE_CREATE_FROM_BANDO @idGara, @idPfuGara, 0, 17, NULL, NULL,'Deserta'

				-- inviamo il formulario ted di aggiudicazione F003 per tutti i lotti della gara ( essendo deserta )
				EXEC DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_LOTTI_DESERTI @idGara,@idPfuGara,NULL

			END

		END --if ocp



		-----------------------------------------------------
		-- INVIO SCHEDA NON AGGIUDICAZIONE (DESERTA)   ------
		-----------------------------------------------------
		--CONTROLLO CHE INTEROPERABILITà SIA ATTIVA
		IF dbo.attivo_INTEROP_Gara( @IdGara ) = 1
		BEGIN

			IF (
					--NON ESISTONO OFFERTE INVIATE PER LA GARA
					(
						NOT EXISTS 
						( 
							select id from ctl_doc with(nolock) 
								where LinkedDoc = @idGara and tipodoc = 'OFFERTA' 
									and deleted = 0 and StatoFunzionale in ( 'Inviato' , 'Rettificata' )
						)
					)

					OR

					-- SE LA GARA NON E' IN AGGIUDICAZIONE E I LOTTI SULLA PDA SONO TUTTTI IN UNO STATO FINALE ALLORA POSSO CHIUDURE
					-- dovrebbe essere valida sia per le gare a lotti che non a lotti se le gare non a lotti hanno sempre la voce 0
					(
					
						@StatoFunzionalePDA not IN ('','VERIFICA_AMMINISTRATIVA')
							and 
						NOT EXISTS( 			
									select lottiT.IdHeader
										from #LottiPDA lottiT
										where lottiT.idheader =@idPDA and lottiT.StatoRiga not in ('Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato' ) 
								)	
					)
					
					

				)
			BEGIN

				--SE SI TRATTA DI UNA GARA MONOLOTTO
				if( ISNULL(@Divisione_lotti,0) = 0)
				BEGIN
			
					select @ListaCig = CIG from Document_Bando with(nolock) where idHeader = @IdGara

				END
				ELSE
				BEGIN

						select @IdPda=id  from ctl_doc with(nolock) where tipodoc='PDA_MICROLOTTI' and linkeddoc=@idGara and Deleted=0
					
						--INSRISCO I CIG IN UNA TABELLA TEMPORANEA
						create table #CIGs (CIG varchar(max))

						insert into #CIGs
						select CIG from Document_MicroLotti_Dettagli with(nolock) where IdHeader = @idGara
						
						--SOTTRAGGO CONTRATTI
						DELETE from #CIGs where CIG in (
						select distinct l.CIG  COLLATE SQL_Latin1_General_CP1_CI_AS
							from document_microlotti_dettagli l with(nolock) -- lotto
								inner join ctl_doc m with(nolock) on m.linkeddoc = l.idheader and m.TipoDoc = 'PDA_COMUNICAZIONE_GENERICA' and m.Deleted = 0 -- comunicazione
								inner join ctl_doc c with(nolock) on c.tipodoc in ( 'CONTRATTO_GARA' , 'SCRITTURA_PRIVATA' )  and c.Deleted = 0 and 	m.id = c.LinkedDoc -- contratto
								inner join document_microlotti_dettagli lc with(nolock) on lc.idheader = c.id and lc.TipoDoc = c.TipoDoc and lc.CIg = l.cig-- lotto del contratto
							where l.idheader=@IdPda and l.TipoDoc='PDA_MICROLOTTI' and l.voce=0 and l.statoriga in ('AggiudicazioneDef','AggiudicazioneCond') )
					
						--SOTTRAGGO CONVENZIONI
						DELETE from #CIGs where CIG in ( 
							select distinct  l.CIG COLLATE SQL_Latin1_General_CP1_CI_AS
							from document_microlotti_dettagli l with(nolock) -- lotto
								inner join document_microlotti_dettagli lc with(nolock) on lc.cig = l.cig and lc.TipoDoc = 'CONVENZIONE' -- lotto in convenzione
								inner join ctl_doc c with(nolock ) on c.id = lc.IdHeader and c.deleted = 0 
								where l.idheader=@IdPda and l.TipoDoc='PDA_MICROLOTTI' and l.voce=0 and l.statoriga in ('AggiudicazioneDef','AggiudicazioneCond') )
						
						--ELIMINO I CIG CHE HANNO GIà UNA SCHEDA INVIATA
						DELETE from #CIGs where CIG in (
							select CIG COLLATE SQL_Latin1_General_CP1_CI_AS 
							from Document_pcp_appalto_schede where idHeader = @IdGara and statoScheda NOT IN ('SC_N_CONF','SC_CONF_MAX_RETRY','SC_CONF_NO_ESITO','ErroreCreazione') and bDeleted = 0 and tipoScheda in  ('NAG','A1_29'))
						

						--SE TROVO UN SOLO CIG LO SELEZIONE DIRETTEMENTE PER EVITARE BUG
						IF (SELECT COUNT(*) from #CIGs) = 1
						BEGIN
							SELECT @ListaCig = CIG from #CIGs
						END
						ELSE
						BEGIN
							--CONCATENO I CIG
							SELECT @ListaCig = STUFF((
								SELECT ',' + CIG
								from #CIGs
								FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
						END


						

						drop table #CIGs
			
				END


				if not(@ListaCig = '')
				BEGIN

					EXEC PCP_NON_AGGIUDICAZIONE_LOTTI -20, @ListaCig, 'DESERTA', @IdGara, 0, @TipoSoglia

				END

			END

		END



		--SE LA GARA E' DESERTA ( non ha ricevuto offerte )
		-- OPPURE SE LA GARA NON E' IN AGGIUDICAZIONE E I LOTTI SULLA PDA SONO TUTTTI IN UNO STATO FINALE ALLORA POSSO CHIUDURE
		--- e non è un giro di 'Negoziata con avviso'		  ----
		--- e non è un giro di 'Bando Ristretta'			  ----
		--- la chiudo subito								  ----
		--- non è un giro avviso/avviso con destinatari  ----
		----------------------------------------------------------	
		IF ( @TipoBandoGara <> '1' or @ProceduraGara <> '15478' ) and not ( @TipoBandoGara = '2' and @ProceduraGara = '15477' )
			AND (  @TipoBandoGara not in('4','5') and @ProceduraGara <> '15583'  )
				
				AND 

				(
					--NON ESISTONO OFFERTE INVIATE PER LA GARA
					(
						NOT EXISTS 
						( 
							select id from ctl_doc with(nolock) 
								where LinkedDoc = @idGara and tipodoc = 'OFFERTA' 
									and deleted = 0 and StatoFunzionale in ( 'Inviato' , 'Rettificata' )
						--E SONO SUPERATI EVENTUALI GIORNI CONFIGURATI PRIMA DI METTERLA A CHIUSA
						
						)
						AND
						--E SONO SUPERATI EVENTUALI GIORNI CONFIGURATI PRIMA DI METTERLA A CHIUSA
						EXISTS ( select 'a' as a where GETDATE() >= @DATA_CONFRONTO + cast(dbo.PARAMETRI('verifica_chiusura_gare','GARA_DESERTA','NUM_GIORNI_CHIUSURA','0',-1) as int) )
					)

					OR

					-- SE LA GARA NON E' IN AGGIUDICAZIONE E I LOTTI SULLA PDA SONO TUTTTI IN UNO STATO FINALE ALLORA POSSO CHIUDURE
					-- dovrebbe essere valida sia per le gare a lotti che non a lotti se le gare non a lotti hanno sempre la voce 0
					(
					
						@StatoFunzionalePDA not IN ('','VERIFICA_AMMINISTRATIVA')
						and 
						NOT EXISTS( 
							--select 
							--	pda.id 
							--		from ctl_doc pda with(nolock)  
							--					-- lotti della gara
							--					inner join Document_MicroLotti_Dettagli lottiT with(nolock) ON lottiT.idheader = pda.id and lottiT.tipodoc = 'PDA_MICROLOTTI' 
							--									and lottiT.StatoRiga not in ('Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato' ) and isnull(lottiT.Voce,0) = 0
							--		where pda.id = @idPDA and pda.Deleted=0 --and @StatoFunzionaleGara <> 'InAggiudicazione'
							
								select 
									lottiT.IdHeader
									from 
										#LottiPDA lottiT
									where lottiT.idheader =@idPDA and lottiT.StatoRiga not in ('Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato' ) 
								)	
					)
					
					

				)

		BEGIN

			-- se non esiste un offerta inviata legata alla gara in esame
			--INSERT INTO CTL_Schedule_Process( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
									   --select @idGara, -20, 'BANDO_GARA','CHIUDI'
			  insert into @GareDaChiudere(IdGara)			   
						values ( @idGara)
		END
		ELSE
		BEGIN

			-----------------------------------------------------------------------------------
			-- SE LA GARA SULLA QUALE STO ITERANDO NON HA LOTTI IN UNO STATO DI NON-TERMINATO -
			--	( ED HA ASSOCIATA UNA PDA IN UNA FASE NON DI VERIFICA_AMMINISTRATIVA )
			-----------------------------------------------------------------------------------
			IF @idPDA > 0 AND NOT EXISTS ( 

							--select 
							--	pda.Id
							--		from ctl_doc pda with(nolock)
							--			-- tutti i lotti della gara
							--			inner join Document_MicroLotti_Dettagli lotti with(nolock) ON lotti.IdHeader = pda.id and isnull(lotti.voce,0) = 0
							--			-- tutti i lotti in uno stato 'terminale'
							--			left join Document_MicroLotti_Dettagli lottiT with(nolock) ON lottiT.Id = lotti.Id and lottiT.StatoRiga in ('AggiudicazioneDef','Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato'  )
							--		where pda.linkeddoc = @idGara and pda.deleted = 0 and pda.TipoDoc = 'PDA_MICROLOTTI' and lottiT.Id is null --filtro sui lotti non terminati
							
							select 
								lottiT.IdHeader
								from 				
									#LottiPDA lottiT
								where 
									lottiT.idheader =@idPDA and  lottiT.StatoRiga NOT in ('AggiudicazioneDef','Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato'  )
							)
			BEGIN
				
								

				-- SE ESISTE LA COMUNICAZIONE DI AGGIUDICAZIONE INVIATA DA X GIORNI
				-- MODIFICATA CONDIZIONE ULTIMA COM DI ESITO INVIATA DA X GIORNI
				IF EXISTS ( 
							
							--select distinct pda.LinkedDoc, -20, 'BANDO_GARA','CHIUDI'
							--		from ctl_doc pda with(nolock)
							--				inner join ctl_doc com with(nolock) ON com.LinkedDoc = pda.id and com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.JumpCheck like '%-ESITO_DEFINITIVO_MICROLOTTI' and com.Deleted = 0
							--				left join Document_comunicazione_StatoLotti com2 with(nolock) ON com2.IdHeader = com.id 
							--				left join Document_MicroLotti_Dettagli lottiT with(nolock) ON lottiT.idheader = pda.id and lottit.NumeroLotto = com2.NumeroLotto  and lottit.tipodoc = 'PDA_MICROLOTTI' and isnull(lottit.Voce,0) = 0
							--				-- se l'aggiudicazione era condizionata recupero la datainvio del processo PDA_MICROLOTTI-AGG_DEFINITIVA_LOTTO
							--				left join Document_Microlotti_DOC_Value ltVa with(nolock) ON ltVa.idheader = lottiT.id and dse_id = 'INVIO_FINE_AGG_CONDIZ' and DZT_Name = 'DataInvio' and isnull(value,'') <> ''
							--		where pda.id = @idPDA and datediff(day, isnull(  CAST(ltVa.value AS datetime)   ,com.datainvio), getdate()) >= @Xgiorni
							
										
							
							--select 
							--	* com.id
							--	from 
							--		ctl_doc com
							--			left join Document_comunicazione_StatoLotti com2 with(nolock) ON com2.IdHeader = com.id 
							--			left join #LottiPDA lottiT ON lottiT.idheader = @idPDA and lottiT.NumeroLotto = com2.NumeroLotto  
							--			-- se l'aggiudicazione era condizionata recupero la datainvio del processo PDA_MICROLOTTI-AGG_DEFINITIVA_LOTTO
							--			left join Document_Microlotti_DOC_Value ltVa with(nolock) ON ltVa.idheader = lottiT.id and dse_id = 'INVIO_FINE_AGG_CONDIZ' and DZT_Name = 'DataInvio' and isnull(value,'') <> ''
							--	where 	com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.LinkedDoc = @idPDA and com.JumpCheck like '%-ESITO_DEFINITIVO_MICROLOTTI' and com.Deleted = 0
							--		    and datediff(day, isnull(  CAST(ltVa.value AS datetime)   ,com.datainvio), getdate()) >= @Xgiorni
							
							select * from #LastComEsito where datediff(day, DataInvio, getdate()) >= @Xgiorni
										
						  )
				BEGIN

						-- AL MOMENTO PER LE GARE APERTE QUESTA CONDIZIONE SARA' L'UNICA PER LA QUALE SI CHIUDERA' LA GARA
						--INSERT INTO CTL_Schedule_Process( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
											--values ( @idGara, -20, 'BANDO_GARA','CHIUDI' )
											--select @idGara, -20, 'BANDO_GARA','CHIUDI'
						insert into @GareDaChiudere(IdGara)			   
									Values( @idGara)

				END
				ELSE
				BEGIN

					--- PER LE RDO ---> CON L'INTRODUZIONE DEL CONTRATTO_GARA ADESSO SIA LE RDO CHE LE ALTRE GARE. 
					--IF @tipoProceduraCaratteristica = 'RDO' 
					IF ISNULL(@generaConvenzione,'0') <> '1'
					BEGIN


						-- SE LA PROCEDURA E' MULTI LOTTO
						IF 
						( 
							
								@Divisione_lotti <> '0' and 
									
								(
						
									-- SE ESISTE ALMENO UN LOTTO NON IN STATO DI TERMINALE 
									-- OPPURE non c'è la comunicazione di aggiudicazione, NON CHIUDO
									EXISTS ( 

										select Lottit.id
											from ctl_doc pda with(nolock)
													
													left join ctl_doc com with(nolock) ON com.LinkedDoc = pda.id and com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.JumpCheck in ('1-ESITO_DEFINITIVO_MICROLOTTI','0-ESITO_DEFINITIVO_MICROLOTTI')  and com.Deleted = 0
													left join Document_comunicazione_StatoLotti com2 with(nolock) ON com2.IdHeader = com.id and com2.Deleted=0

													-- lotti della gara
													inner join Document_MicroLotti_Dettagli lottiT with(nolock) ON lottiT.idheader = pda.id and lottit.NumeroLotto = com2.NumeroLotto  and lottit.tipodoc = 'PDA_MICROLOTTI' and lottiT.StatoRiga not in ('AggiudicazioneDef','Interrotto', 'Deserta', 'NonAggiudicabile', 'NonGiudicabile','Revocato' ) and isnull(lottit.Voce,0) = 0

											where pda.id = @idPDA and not com.id is null 
												  --and @StatoFunzionaleGara ='InAggiudicazione' --per le gare in aggiusicazione deve esistere la com di esito
										
										
										
												
										)

										OR

										-- SE ESISTE ALMENO UN LOTTO IN UNO STATO TERMINALE di AGGIUDICAZIONEDEF SENZA CONTRATTO O CON UN CONTRATTO IN LAVORAZIONE, NON CHIUDO
										EXISTS ( 

											select lottiT.id--,lottiC.cig,cont.*
												from ctl_doc pda with(nolock)

														inner join ctl_doc com with(nolock) ON com.LinkedDoc = pda.id and com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.JumpCheck in ('1-ESITO_DEFINITIVO_MICROLOTTI','0-ESITO_DEFINITIVO_MICROLOTTI') and com.Deleted = 0
														inner join Document_comunicazione_StatoLotti com2 with(nolock) ON com2.IdHeader = com.id and com2.Deleted=0

														-- lotti della gara nello stato di AggiudicazioneDef essendo l'unico stato che può portare ad un contratto 
														inner join Document_MicroLotti_Dettagli lottiT with(nolock) ON lottiT.idheader = pda.id and lottit.NumeroLotto = com2.NumeroLotto and lottit.tipodoc = 'PDA_MICROLOTTI' and lottiT.StatoRiga in ('AggiudicazioneDef' ) and isnull(lottit.Voce,0) = 0

														--contratto / scrittura privata
														--left join ctl_doc cont with(nolock) ON cont.LinkedDoc = com.id and cont.tipodoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and cont.Deleted = 0

														-- lotti del contratto
														--left join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = cont.id and lottic.TipoDoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and lottic.cig = lottit.cig and isnull(lottiC.Voce,0) = 0

														left join (
															
															--prendo tutti i Lotti con contratti	
															select lottiC.id, cont.LinkedDoc as ComE, lottic.cig , cont.StatoFunzionale
																from ctl_doc cont with(nolock)
																		inner join Document_MicroLotti_Dettagli lottiC with(nolock) ON lottiC.idheader = cont.id and lottic.TipoDoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA')  and isnull(lottiC.Voce,0) = 0
																where cont.Tipodoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and cont.Deleted = 0
									

															) LC on  LC.ComE = com.id  and  LC.cig = lottit.cig 


												--where pda.id = @idPDA  and (  lottiC.id is null or cont.StatoFunzionale = 'InLavorazione' ) -- CHIUDIAMO LA GARA ANCHE SE IL CONTRATTO RIMANE IN 'INVIATO' O SE VIENE RIFIUTATO
												where pda.id = @idPDA  and (  LC.id is null or LC.StatoFunzionale = 'InLavorazione' ) -- CHIUDIAMO LA GARA ANCHE SE IL CONTRATTO RIMANE IN 'INVIATO' O SE VIENE RIFIUTATO

												

											)

										
								)
						)
						BEGIN

							IF ( @protocolloGara <> '' )
							BEGIN
								set @motivazioneMancataChiusura = 'La gara richiesta ha almeno un lotto in uno stato NON terminale OPPURE non c''è la comunicazione di aggiudicazione OPPURE non c''è il contratto in uno stato diverso da InLavorazione'
							END

							--INSERT INTO CTL_Schedule_Process( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
								--select TOP 0 0, -20, 'BANDO_GARA','CHIUDI'
								insert into @GareDaChiudere(IdGara)	
									select TOP 0 0
						END
						ELSE
						BEGIN

							IF ( @protocolloGara <> '' )
							BEGIN
								set @motivazioneMancataChiusura = 'La gara richiesta non ha un contratto o è rimasto nello stato di InLavorazione'
							END
					
							-- SCHEDULO LA CHIUSURA PER LA GARA SE LA SCRITTURA PRIVATA E' INVIATA DA PIU' DI X GIORNI
								--INSERT INTO CTL_Schedule_Process( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
								insert into @GareDaChiudere(IdGara)			   
										select 
											distinct pda.LinkedDoc--, -20, 'BANDO_GARA','CHIUDI'
												from ctl_doc pda with(nolock)
														inner join ctl_doc com with(nolock) ON com.LinkedDoc = pda.id and com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.JumpCheck in ('1-ESITO_DEFINITIVO_MICROLOTTI','0-ESITO_DEFINITIVO_MICROLOTTI') and com.Deleted = 0
														inner join ctl_doc cont with(nolock) ON cont.LinkedDoc = com.id and cont.tipodoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and cont.Deleted = 0 and cont.StatoFunzionale <> 'InLavorazione'
												where pda.id = @idPDA --and datediff(day, cont.datainvio, getdate()) >= @Xgiorni

						END
					
					 
						IF 
						( 
					
								@Divisione_lotti = '0' and EXISTS (
						
									-- SE ESISTE UNA SCRITTURA PRIVATA LEGATA AD UNA COMUNICAZIONE DI AGGIUDICAZIONE DEFINITIVA PER LA GARA
									-- QUANDO MONOLOTTO NON DEVO ANDARE SULLE RIGHE. IN CHIAVE SUL CIG. PERCHE' UN RDO SFOCIERA' al + IN 1 CONTRATTO

									select pda.id 
										from ctl_doc pda with(nolock)
												inner join ctl_doc com with(nolock) ON com.LinkedDoc = pda.id and com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.JumpCheck in ('1-ESITO_DEFINITIVO_MICROLOTTI','0-ESITO_DEFINITIVO_MICROLOTTI') and com.Deleted = 0
												inner join ctl_doc cont with(nolock) ON cont.LinkedDoc = com.id and cont.tipodoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and cont.Deleted = 0 and cont.StatoFunzionale <> 'InLavorazione'
												--inner join document_bando gara with(nolock) ON gara.idHeader = pda.LinkedDoc

										where pda.id = @idPDA 
								
								
								--union tutte le offerte sono in uno stato finale


								)
						)
						BEGIN
					
							IF ( @protocolloGara <> '' )
							BEGIN
								set @motivazioneMancataChiusura = 'La gara richiesta non ha un contratto o è rimasto nello stato di InLavorazione'
							END

							-- SCHEDULO LA CHIUSURA PER LA GARA SE LA SCRITTURA PRIVATA E' INVIATA DA PIU' DI X GIORNI
							--INSERT INTO #CTL_Schedule_Process--( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
							insert into @GareDaChiudere(IdGara)			   
											
								select distinct pda.LinkedDoc--, -20, 'BANDO_GARA','CHIUDI'
										from ctl_doc pda with(nolock)
												inner join ctl_doc com with(nolock) ON com.LinkedDoc = pda.id and com.tipodoc = 'PDA_COMUNICAZIONE_GENERICA' and com.JumpCheck in ('1-ESITO_DEFINITIVO_MICROLOTTI','0-ESITO_DEFINITIVO_MICROLOTTI') and com.Deleted = 0
												inner join ctl_doc cont with(nolock) ON cont.LinkedDoc = com.id and cont.tipodoc in ( 'CONTRATTO_GARA', 'SCRITTURA_PRIVATA') and cont.Deleted = 0 and cont.StatoFunzionale <> 'InLavorazione'
									where pda.id = @idPDA --and datediff(day, cont.datainvio, getdate()) >= @Xgiorni

						END
						ELSE
						BEGIN

							IF ( @protocolloGara <> '' )
							BEGIN
								set @motivazioneMancataChiusura = 'La gara richiesta non ha un contratto agganciato per CIG o è rimasto nello stato di InLavorazione'
							END

						END


					END

					ELSE IF @generaConvenzione = '1'
					BEGIN
				

						-- SE TUTTI I LOTTI IN AggiudicazioneDef SONO SFOCIATI IN UNA CONVENZIONE NON IN LAVORAZIONE

						IF ( 
								---------------------------------------------------------------------------------------------
								--- SE LA GARA E' MULTILOTTO LA CHIAVE CON LA CONVENZIONE E' IL CIG PRESENTE SUI LOTTI ------
								---------------------------------------------------------------------------------------------
								@Divisione_lotti <> '0' and NOT EXISTS 
							
									(
											-- select per verificare che tutti i lotti sono sfociati in uno stato di AggiudicazioneDef e con convenzione
											select conv.id
												from ctl_doc pda with(nolock) 
														inner join Document_MicroLotti_Dettagli lg with(nolock) ON pda.id = lg.IdHeader and lg.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0 and lg.StatoRiga <> 'AggiudicazioneDef'
														inner join Document_MicroLotti_Dettagli lc with(nolock) ON lc.cig = lg.cig and lc.tipodoc = 'CONVENZIONE'-- and isnull(lc.voce,0) = 0
														inner join ctl_doc conv with(nolock) ON conv.id = lc.idheader and conv.TipoDoc = 'CONVENZIONE' and conv.deleted = 0
												where pda.id = @idPDA

											union 

											--SELECT per verificare che non ci siano convenzioni inLavorazione
											select conv.id
												from ctl_doc pda with(nolock) 
														inner join Document_MicroLotti_Dettagli lg with(nolock) ON pda.id = lg.IdHeader and lg.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0 --and lg.StatoRiga <> 'AggiudicazioneDef'
														inner join Document_MicroLotti_Dettagli lc with(nolock) ON lc.cig = lg.cig and lc.tipodoc = 'CONVENZIONE'-- and isnull(lc.voce,0) = 0
														inner join ctl_doc conv with(nolock) ON conv.id = lc.idheader and conv.TipoDoc = 'CONVENZIONE' and conv.deleted = 0
												where pda.id = @idPDA and conv.statofunzionale = 'InLavorazione' 	
	
											union

											-- se la pda è ancora in verifica amministrativa non ci sono le righe Document_MicroLotti_Dettagli quindi le condizioni sopra non sono valide. 
											-- con questa union non faccio chiudere la gara se in verifica amministrativa
											select id from CTL_DOC with(nolock) where Id = @idPDA and StatoFunzionale = 'VERIFICA_AMMINISTRATIVA'

											union

											--ritorno righe e quindi blocco se non esiste un match per convenzione /cig
											select v.id
												from ctl_doc pda with(nolock) 
														inner join Document_MicroLotti_Dettagli lg with(nolock) ON pda.id = lg.IdHeader and lg.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0 and lg.StatoRiga = 'AggiudicazioneDef'
														--left join Document_MicroLotti_Dettagli lc with(nolock) ON lc.cig = lg.cig and lc.tipodoc = 'CONVENZIONE'-- and isnull(lc.voce,0) = 0
														--left join ctl_doc conv with(nolock) ON conv.id = lc.idheader and conv.TipoDoc = 'CONVENZIONE' and conv.deleted = 0
														--prendo priam le convenzioni nn cancellate
														--e poi metto injoin
														left join 
																(
																	select lc.id , lc.cig
																		from 
																			CTL_DOC conv with (nolock)
																				inner join Document_MicroLotti_Dettagli lc with (nolock) on lc.idheader = conv.id and conv.TipoDoc=lc.TipoDoc
																		where conv.TipoDoc='CONVENZIONE'  and conv.deleted = 0
																		
																) V on V.cig = lg.cig

										
												where
													-- pda.id = @idPDA  and conv.id is null 
													 pda.id = @idPDA  and v.id is null 
											
									)
							) 
					
							OR

							(
								-----------------------------------------------------------------------------------------------------
								--- NELLA GARA MONOLOTTO IL CIG NON LO PRENDO DALLA MICROLOTTIDETTAGLI MA DALLA TESTATA DELLA GARA --
								-----------------------------------------------------------------------------------------------------
								@Divisione_lotti = '0' and NOT EXISTS 

								(
									select conv.id
										from ctl_doc pda with(nolock) 
												inner join document_bando gara with(nolock) ON gara.idHeader = pda.LinkedDoc
												inner join Document_MicroLotti_Dettagli lg with(nolock) ON pda.id = lg.IdHeader and pda.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0 and lg.StatoRiga <> 'AggiudicazioneDef'
												inner join Document_Convenzione dtConv with(nolock) ON dtConv.CIG_MADRE = gara.CIG and dtConv.deleted=0
												inner join ctl_doc conv with(nolock) ON dtConv.id = conv.id and conv.TipoDoc = 'CONVENZIONE' and conv.deleted = 0
										where pda.id = @idPDA and conv.statofunzionale <> 'InLavorazione' 

									union 

									-- se la pda è ancora in verifica amministrativa non ci sono le righe Document_MicroLotti_Dettagli quindi le condizioni sopra non sono valide. 
									-- con questa union non faccio chiudere la gara se in verifica amministrativa
									select id from CTL_DOC with(nolock) where Id = @idPDA and StatoFunzionale = 'VERIFICA_AMMINISTRATIVA'

									union 
									
									--ritorno righe e quindi blocco se non esiste un match per covenzione /cig
									select conv.id
										from ctl_doc pda with(nolock) 
												inner join document_bando gara with(nolock) ON gara.idHeader = pda.LinkedDoc
												inner join Document_MicroLotti_Dettagli lg with(nolock) ON pda.id = lg.IdHeader and pda.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0 and lg.StatoRiga = 'AggiudicazioneDef'
												left join Document_Convenzione dtConv with(nolock) ON dtConv.CIG_MADRE = gara.CIG and dtConv.deleted=0
												left join ctl_doc conv with(nolock) ON dtConv.id = conv.id and conv.TipoDoc = 'CONVENZIONE' and conv.deleted = 0
										where pda.id = @idPDA and conv.id is null


								)
							
							)

						BEGIN

					
								-- SCHEDULO LA CHIUSURA PER LA GARA SE LA SCRITTURA PRIVATA E' INVIATA DA PIU' DI X GIORNI
								--INSERT INTO CTL_Schedule_Process( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
											--select @idGara, -20, 'BANDO_GARA','CHIUDI'
											--print  @idGara
								insert into @GareDaChiudere(IdGara)			   
											Values( @idGara)


						END
						ELSE
						BEGIN

							IF ( @protocolloGara <> '' )
							BEGIN
								set @motivazioneMancataChiusura = 'La gara richiesta deve sfociare in convenzione per tutti i suoi lotti e devono essere tutti in aggiudicazione definitiva. La convenzione non deve restare InLavorazione'
							END

						END

					END


				END


			END -- END PER IF PER VERIFICARE LOTTI TERMINATI
			ELSE
			BEGIN			
				-- SE NON C'E UNA PDA O NON SONO STATI 'CHIUSI' TUTTI I LOTTI
				-- E SIAMO SU UN GIRO DI NEGOZIATA + AVVISO
				IF ( @TipoBandoGara = '1' and @ProceduraGara = '15478' )
					-- è un giro avviso/avviso con destinatari  ----
					or (  @TipoBandoGara  in('4','5') and @ProceduraGara = '15583'  )
				
				BEGIN

					DECLARE @maxDataInvioCollegati datetime

					select @maxDataInvioCollegati = max(d.DataInvio)
						from ctl_doc gara with(nolock)
								inner join ctl_doc d with(nolock) ON d.Fascicolo = gara.Fascicolo and d.Deleted = 0 and d.StatoDoc <> 'Saved'
						where gara.id = @idGara

					set @maxDataInvioCollegati = isnull(@maxDataInvioCollegati, @dataInvioGara)

					-- SE SONO PASSI 180 GIORNI DALL'INVIO DELL'ULTIMO DOCUMENTO A PARITA' DI FASCICOLO CON LA GARA
					IF datediff(day, @maxDataInvioCollegati, getdate()) >= @Xgiorni
					BEGIN

							--INSERT INTO CTL_Schedule_Process( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
											--select @idGara, -20, 'BANDO_GARA','CHIUDI'
											--print @idGara
							  insert into @GareDaChiudere(IdGara)			   
								Values( @idGara)

					END
					ELSE
					BEGIN

						IF ( @protocolloGara <> '' )
						BEGIN
							set @motivazioneMancataChiusura = 'La gara richiesta è un giro di negoziata con avviso ma non sono passati 180 giorni dall''ultimo documento legato al fascicolo di gara'
						END

					END

				END
				ELSE
				BEGIN

					IF ( @protocolloGara <> '' )
					BEGIN
						set @motivazioneMancataChiusura = 'La gara richiesta non ha tutti i lotti in uno stato terminale. L''elenco degli stati terminali sono : AggiudicazioneDef,Interrotto, Deserta, NonAggiudicabile, NonGiudicabile,Revocato'
					END

				END


			END

		END

		FETCH NEXT FROM curs INTO @idGara,@tipoProceduraCaratteristica,@generaConvenzione,@idPDA,@Divisione_lotti, @TipoBandoGara, @ProceduraGara,@dataInvioGara,@StatoFunzionaleGara,@StatoFunzionalePDA, @protGara,@DATA_CONFRONTO, @idPfuGara, @TipoSoglia

	END  

	CLOSE curs   
	DEALLOCATE curs

	drop table #GareDaEsaminare
	drop table #LottiPDA

	INSERT INTO CTL_Schedule_Process( idDoc, IdUser, DPR_DOC_ID, DPR_ID )
		select distinct IdGara,-20, 'BANDO_GARA','CHIUDI' from 
			@GareDaChiudere order by 1

	-- se è stata richiesta la verifica di chiusura e non è stata chiusura la gara richiesta, do la motivazione in output
	IF @protocolloGara <> '' and NOT EXISTS ( select idgara from @GareDaChiudere )
	BEGIN
		select @motivazioneMancataChiusura as motivazione
	END


END

GO
