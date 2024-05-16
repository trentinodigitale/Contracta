USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_BANDO] ( @idGara int , @IdUser int, @lotti varchar(max) = null, @Contesto varchar(100) = 'DESERTI', @apriDocumento int = 0, @IdContesto  int = 0  )
AS
BEGIN 

	-- INPUT :
	--	@idGara
	--	@IdUser
	--	@lotti	= Elenco dei lotti che si desidera inviare al TED, stringa con separatore @
	--	@Contesto = stringa contenente il contesto funzionale da gestire, ad esempio "DESERTI"
	--  @IdContesto 0 id convenzione/contratto per evitare query di nvaigazione per info piatti del doc relativo

	SET NOCOUNT ON

	-- QUESTA STORED VIENE CHIAMATA DA : 
	--	DELTA_TED_AGGIUDICAZIONE_CREATE_FROM_LOTTI_DESERTI
	--		* IL CHIAMANTE PASSERA' NELLA VARIABILE DI INPUT @LOTTI, L'ELENCO DEI LOTTI DA RECUPERARE
	--		* PER OGNI LOTTO SI DEVE VERIFICARE PREVENTIVAMENTE SE C'E' GIA' STATO UN INVIO AL TED DELL'F03 E NEL QUAL CASO IMPEDIRLO. PRENDERE SOLO I LOTTI NON ANCORA INVIATI ( RISPETTO ALLA LISTA RICHIESTA IN INPUT ) E SE NON NE RESTANO NON CREARE IL DOCUMENTO
	--		* OGNI NUOVA INVOCAZIONE A QUESTA STORED CREERA' UN NUOVO DOCUMENTO DI AGGIUDICAZIONE TED, CON I LOTTI RICHIESTI. I DOCUMENTI DI AGGIUDICAZIONE TED NON SONO COLLEGATI TRA LORO

	declare @Id				 INT
	declare @Errore			 NVARCHAR(2000)
	declare @newid			 INT
	declare @tipoDoc		 VARCHAR(100)
	declare @separatoreLotti VARCHAR(10) = '@'
	declare @Divisione_lotti as varchar(10)

	select @Divisione_lotti = divisione_lotti 
		from document_bando with (nolock)
		where
			idheader = @idGara

	set @Errore=''	
	set @newid = null
	set @tipoDoc = 'DELTA_TED_AGGIUDICAZIONE'
	
	-- Inneschiamo il formulario F03 SOLO SE la gara è "pubblicata ted"
	IF EXISTS ( select top 1 id from ctl_doc with(nolock) where tipodoc = 'PUBBLICA_GARA_TED' and LinkedDoc = @idGara and StatoFunzionale = 'PubTed' )
	BEGIN
	
		-- prendiamo tutte le aggiudicazioni ted "inviate" ed in "invio in corso" associate alla gara
		--	+ tutte quelle ancora in attesa del tempo di schedulazione per essere inviate ( "AttesaIntegrazione" )
		select b.TED_CIG_AGG into #aggiudicazioni_ted
			from CTL_DOC a with(nolock) 
					inner join Document_TED_Aggiudicazione b with(nolock) on b.idHeader = a.Id
			where a.LinkedDoc = @idGara and a.deleted = 0 and a.TipoDoc = @tipoDoc and a.StatoFunzionale IN ( 'InvioInCorso', 'Inviato', 'AttesaIntegrazione' )

		select top 0 cast('' as varchar(100)) as NumeroLotto, cast('' as varchar(100)) as CIG into #lotti_richiesti

		-- prendiamo tutti i lotti richiesti dal chiamante
		if @lotti is null
		begin

			insert into #lotti_richiesti 
				select b.NumeroLotto, b.CIG
					from CTL_DOC a with(nolock) 
							inner join Document_MicroLotti_Dettagli b with(nolock) on b.IdHeader = a.id and b.TipoDoc = a.TipoDoc and b.voce = 0
					where a.id = @idGara

		end
		else
		begin
			
			insert into #lotti_richiesti 
				select b.NumeroLotto, isnull(b.CIG,db.cig)
					from CTL_DOC a with(nolock) 
							inner join Document_Bando db with(nolock) on db.idHeader=@idGara
							inner join Document_MicroLotti_Dettagli b with(nolock) on b.IdHeader = a.id and b.TipoDoc = a.TipoDoc and b.voce = 0
							inner join dbo.Split(@lotti, @separatoreLotti) c on c.items = b.NumeroLotto
					where a.id = @idGara and c.items <> ''

		end

		-- togliamo dai lotti richiesti tutti quei lotti gia aggiudicati ted. non dobbiamo rimandare le stesse aggiudicazioni a parità di cig
		delete from #lotti_richiesti where cig in ( select TED_CIG_AGG from #aggiudicazioni_ted )

		-- se restano lotti da inviare
		IF EXISTS ( SELECT * from #lotti_richiesti )
		BEGIN
			
			set @newId = null

			-- PRIMA DI CREARE IL DOCUMENTO CERCO LO STESSO TIPODOC, IDGARA ,@LOTTI E JUMPCHECK con statofunzionale diverso da annullato
			SELECT  @newId = id
				FROM CTL_DOC WITH(NOLOCK)
				WHERE tipodoc = 'DELTA_TED_AGGIUDICAZIONE' and Deleted = 0 and VersioneLinkedDoc = isnull(@lotti,'') and LinkedDoc = @idGara and JumpCheck = @Contesto and StatoFunzionale <> 'Annullato'
			
			IF @newId is null
			begin
				--DESCRIZIONE DEL LOTTO PRENDERE QUELLA DELLA VOCE 0
				-- CREO IL DOCUMENTO. LA COLONNA DataDocumento servirà per il servizio di verifica pubblicazione per iterare sulle attesa di pubblicazione con una coda circolare.
				INSERT INTO CTL_DOC (IdPfu,  TipoDoc, DataDocumento, idpfuincharge ,Azienda ,body,note,LinkedDoc, titolo, Deleted, StatoFunzionale, IdDoc, jumpcheck, VersioneLinkedDoc) --in IdDoc ci sarà il numero di volte che abbiamo verificato se l'ocp istanzia esito era andato a buon fine
					select  @IdUser, @tipoDoc,getDate(),  @IdUser ,Azienda,'',body,@idGara, 
						'Richiesta invio dati aggiudicazione GUUE' + 
						case 
							when @Divisione_lotti <>'0' then ' - lotto ' + @lotti 
							else ''
						end 
						, 0, case when  @Contesto = 'DESERTI' then 'AttesaIntegrazione' else 'InLavorazione' end, 1, @Contesto, isnull(@lotti,'')	   --in VersioneLinkedDoc ci sarà la variabile @lotti ( si è deciso di fare sempre 1 documento per ogni lotto )
						from ctl_doc with(nolock)
						where id = @idGara	

				set @newId = SCOPE_IDENTITY()

				declare @numeroLotto varchar(100)
				declare @cig varchar(100)
				declare @newIdLotto int

				IF ( @Contesto = 'DESERTI' )
				BEGIN


					select * into #gara from VIEW_TED_DATI_GARA where id = @idGara

					INSERT INTO Document_TED_GARA (	[idHeader], [id_gara], [TED_TITOLO_PROCEDURA_GARA] )
						select @newId, [id_gara], [TED_TITOLO_PROCEDURA_GARA]
							from #gara
							
					DECLARE cursForTed CURSOR FAST_FORWARD FOR
						
						SELECT NumeroLotto, CIG from #lotti_richiesti

					OPEN cursForTed 
					FETCH NEXT FROM cursForTed INTO @numeroLotto, @cig

					WHILE @@FETCH_STATUS = 0   
					BEGIN  

						INSERT INTO Document_TED_Aggiudicazione ( [idHeader], [NotEditable], [TED_CIG_AGG], [TED_AWARDED_CONTRACT], [TED_PROCUREMENT_UNSUCCESSFUL], 
																	[TED_NB_TENDERS_RECEIVED_SME], 
																	[TED_NB_TENDERS_RECEIVED_OTHER_EU], [TED_NB_TENDERS_RECEIVED_NON_EU], [TED_NB_TENDERS_RECEIVED_EMEANS], 
																	[TED_LIKELY_SUBCONTRACTED], [TED_VAL_SUBCONTRACTING], [TED_PCT_SUBCONTRACTING], [TED_INFO_ADD_SUBCONTRACTING], 
																	[TED_DATE_CONCLUSION_CONTRACT] )
												values ( @newId, '', @cig, 'N', '1',
																	null, null, null, null,
																	null, null, null, null,
																	null)
						
						--setto i valori aggiudicati sulla tabella Document_TED_GARA ed i campi non editabili nella colonna NotEditable
						--altre info sulla tabella Document_TED_Aggiudicazione ed i campi non editabili nella colonna NotEditable
						exec SP_DELTA_TED_Set_Valori @newId, @idGara , @numeroLotto, @cig , @Contesto, @IdContesto


						set @newIdLotto = SCOPE_IDENTITY()

						--INSERT INTO Document_TED_Aggiudicatari ( [idHeader], [TED_AWARDED_IS_SME], [TED_NATIONALID], [TED_NUTS], [TED_E_MAIL], [TED_PHONE], [TED_URL], [TED_FAX] )
						--							values ( @newIdLotto, null, null, null, null, null, null, null )

						FETCH NEXT FROM cursForTed INTO @numeroLotto, @cig

					END  

					CLOSE cursForTed   
					DEALLOCATE cursForTed

					-- scheduliamo l'invio al TED tra 5 giorni. all'interno del processo si verificherà se l'ocp istanzia esito è andata a buon fine.
					--	se è in errore ocp esito rischeduliamo dopo altri 5 giorni
					insert into CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID, DataRequestExec ) 
							values ( @newId , @IdUser , 'DELTA_TED_AGGIUDICAZIONE' , 'SEND_WS' , DATEADD(DAY, 5, getdate()) )


				END

				IF  @Contesto in ('CONVENZIONE', 'CONTRATTO_GARA') 
				BEGIN

					
					select * into #gara_c from VIEW_TED_DATI_GARA where id = @idGara

					
					INSERT INTO Document_TED_GARA (	[idHeader], [id_gara], [TED_TITOLO_PROCEDURA_GARA] )
						select @newId, [id_gara], [TED_TITOLO_PROCEDURA_GARA]
							from #gara_c
					
					DECLARE cursForTed CURSOR FAST_FORWARD FOR
						
						SELECT NumeroLotto, CIG from #lotti_richiesti

					OPEN cursForTed 
					FETCH NEXT FROM cursForTed INTO @numeroLotto, @cig

					WHILE @@FETCH_STATUS = 0   
					BEGIN  
						
						INSERT INTO Document_TED_Aggiudicazione ( [idHeader], [NotEditable], [TED_CIG_AGG], [TED_AWARDED_CONTRACT], [TED_PROCUREMENT_UNSUCCESSFUL], 
																	[TED_NB_TENDERS_RECEIVED_SME], 
																	[TED_NB_TENDERS_RECEIVED_OTHER_EU], [TED_NB_TENDERS_RECEIVED_NON_EU], [TED_NB_TENDERS_RECEIVED_EMEANS], 
																	[TED_LIKELY_SUBCONTRACTED], [TED_VAL_SUBCONTRACTING], [TED_PCT_SUBCONTRACTING], [TED_INFO_ADD_SUBCONTRACTING], 
																	[TED_DATE_CONCLUSION_CONTRACT] )
												values ( @newId, '', @cig, /*'0321654789',*/ 'S', '',
																	null, null, null, null,
																	'N', null, null, null,
																	null)
						
						set @newIdLotto = SCOPE_IDENTITY()

						--setto i valori aggiudicati sulla tabella Document_TED_GARA ed i campi non editabili nella colonna NotEditable
						--altre info sulla tabella Document_TED_Aggiudicazione ed i campi non editabili nella colonna NotEditable
						exec SP_DELTA_TED_Set_Valori @newId, @idGara , @numeroLotto, @cig , @Contesto, @IdContesto

						

						exec SP_DELTA_TED_Set_Aggiudicatari  @newIdLotto , @newId, @idGara , @numeroLotto, @cig , @Contesto, @IdContesto
						--INSERT INTO Document_TED_Aggiudicatari ( [idHeader], [IdDoc], [TED_AWARDED_IS_SME], [TED_NATIONALID], [TED_NUTS], [TED_E_MAIL], [TED_PHONE], [TED_URL], [TED_FAX], [TED_AZIRAGIONESOCIALE], [TED_AZIINDIRIZZOLEG] )
						--							values ( @newIdLotto, @newId , null, null, null, null, null, null, null, null, null )
						

						FETCH NEXT FROM cursForTed INTO @numeroLotto, @cig

					END  

					CLOSE cursForTed   
					DEALLOCATE cursForTed

					


				END

			end --IF @newId is null


		END

	END -- if su gara ted pubblicata
	ELSE
	BEGIN
		set @Errore = 'La gara non risulta pubblicata sul TED'
	END

	if @apriDocumento = 1
	begin

		IF ISNULL(@newId,0) <> 0
		BEGIN
			select @newId as id
		END
		ELSE
		BEGIN
		
			select 'Errore' as id , @Errore as Errore

		END

	end
	
END

GO
