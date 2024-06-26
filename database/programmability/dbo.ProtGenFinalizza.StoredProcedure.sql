USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ProtGenFinalizza]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[ProtGenFinalizza] ( @idVProtGen varchar(50) , @IdUser int , @tipoDoc varchar(500) )
AS
BEGIN

	-- l'avanzamento degli stati del record della v_protgen avviene nel processo che chiama questa stored

	-----------------------------------------------------------------------------------
	-- Stored per ribaltare i dati del protocollo generale sul documento richiedente --
	-----------------------------------------------------------------------------------

	SET NOCOUNT ON

	declare @idDoc int

	declare @protocolloGenerale varchar(4000)
	declare @dataProtGen datetime
	declare @fascicoloGenerale varchar(100)
	declare @titolario varchar(100)


	declare @contratto nvarchar(4000)
	declare @clausoleVessatorie nvarchar(4000)
	declare @allegatoFirmato nvarchar(4000)

	declare @convenzione INT
	declare @linkedDoc INT
	declare @idpfu INT
	declare @Ted_Attivo as varchar(10)
	declare @id_GUEE as int
	declare @IdGara as int
	declare @IsGaraTed as int


	set @idDoc = -1
	set @convenzione = -1
	set @idpfu = -1

	-- se è attivo il protocollo generale
	IF EXISTS( select id from lib_dictionary with(nolock) where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES')
	BEGIN

		IF EXISTS( select top 1 * from v_protgen_dati with(nolock) where idheader = @idVProtGen and DZT_Name = 'ESITO_DOCER' and isnull(Value,'') <> 'OK' )
			AND
		   EXISTS( select top 1 * from v_protgen_dati with(nolock) where idheader = @idVProtGen and DZT_Name = 'ProtocolloGenerale' and isnull(Value,'') <> '' )
		    AND
		   EXISTS( select top 1 * from v_protgen_dati with(nolock) where idheader = @idVProtGen and DZT_Name = 'FascicoloGenerale' and isnull(Value,'') <> '' )
		BEGIN
			-- rettifico una situazione di incoerenza se dovessi trovarmi il protocollogenerale ma l'esito non è ok
				UPDATE v_protgen_dati
					set Value = 'OK'
				where idheader = @idVProtGen and DZT_Name = 'ESITO_DOCER'
		END

		-- Controllo di sicurezza. Per prevenire un eventuale (quanto improbabile) caso in cui
		-- lo stato del record è 'chiusura invocazione protocollo generale' ma non c'è un esito del protocollo
		IF EXISTS( select * from v_protgen_dati with(nolock) where idheader = @idVProtGen and DZT_Name = 'ESITO_DOCER' and isnull(Value,'') <> 'OK' )
		BEGIN
			--IF EXISTS( select id from v_protgen where id = @idVProtGen and isnull(Numero_Protocollo,'') = '' ) 
			raiserror ('ESITO_DOCER assente. Situazione non coerente rispetto allo stato del record v_protgen', 16, 1)
			return 99

		END

		select @idDoc = Appl_id_evento,
			   @protocolloGenerale = Numero_Protocollo,
			   @dataProtGen = Data_Protocollo,
			   @tipoDoc = appl_sigla
			from v_protgen with(nolock) 
			where id = @idVProtGen

		select @fascicoloGenerale = a.Value 
			from v_protgen_dati a with(nolock) 
			where a.IdHeader = @idVProtGen and a.DZT_Name = 'FascicoloGenerale' and isnull(Value,'') <> ''

		select @titolario = a.Value 
			from v_protgen_dati a with(nolock) 
			where a.IdHeader = @idVProtGen and a.DZT_Name = 'titolario' and isnull(Value,'') <> ''

		IF @tipoDoc not in ( 'COM_DPE_FORNITORE')
		BEGIN
			SELECT @idpfu = idpfu
				from ctl_doc with(nolock) 
				where id = @idDoc
		END	

		IF @tipoDoc = 'CONTRATTO_CONVENZIONE'
		BEGIN
			--PER IL GIRO DI STIPULA FORMA PUBB= SI arrivo con id delle conveznione non il del contratto_convenzione visto che non esiste
			if exists ( select ID from CTL_DOC with(nolock) where Id=@idDoc AND TipoDoc='CONVENZIONE' )
			BEGIN
				set @convenzione=@idDoc
			END
			ELSE
			BEGIN
				select @convenzione = LinkedDoc	from ctl_doc with(nolock) where id =  @idDoc
			END
			 ----------------------------------------------------------------------------------------------------------------
			 -- AGGIORNO IL CONTRATTO E LA CONVENZIONE SIA PER QUANTO RIGUARDA IL PROTOCOLLO GENERALE CHE PER IL FASCICOLO --
			 ----------------------------------------------------------------------------------------------------------------
			 UPDATE ctl_doc
				SET DataProtocolloGenerale = @dataProtGen , 
					ProtocolloGenerale = @protocolloGenerale, 
					FascicoloGenerale = @fascicoloGenerale 
				WHERE id in ( @idDoc, @convenzione)

			UPDATE Document_dati_protocollo 
					SET titolarioPrimario = @titolario 
				WHERE idHeader in ( @idDoc, @convenzione)

			------------------------------------------------------------------------
			------ AGGIORNO IL CAMPO DATA STIPULA CONVENZIONE CON LA DATA RSPIC ----
			------------------------------------------------------------------------
			UPDATE Document_Convenzione
					SET DataStipulaConvenzione = @dataProtGen
				WHERE id =  @convenzione
				
			-- se è attivo il versamento degli ordinativi in conservazione
			IF dbo.PARAMETRI('SERVICE_REQUEST','PARER','ATTIVO','NO',-1) = 'YES'
			BEGIN

				declare @idDocOdc int
				declare @idpfuODC int
				
				-- recuperiamo tutti gli ordinativi fatti per questa convenzione ( che non erano stato inviati, perchè non avevamo l'rspic )
				DECLARE curs CURSOR FAST_FORWARD FOR
					select o.Id, o.IdPfu 
						from ctl_doc co with(nolock)
								inner join Document_Convenzione c with(nolock) on co.id = c.id 
								inner join ctl_doc o with(nolock) on o.LinkedDoc = c.ID and o.TipoDoc = 'ODC' and o.Deleted = 0 and o.statofunzionale in ( 'Inviato','Accettato' ) 
						where co.id = @convenzione

				OPEN curs 
				FETCH NEXT FROM curs INTO @idDocOdc,@idpfuODC

				WHILE @@FETCH_STATUS = 0   
				BEGIN  

					EXEC INSERT_SERVICE_REQUEST 'PARER', 'odc', @idpfuODC, @idDocOdc

					FETCH NEXT FROM curs INTO @idDocOdc,@idpfuODC

				END  

				CLOSE curs   
				DEALLOCATE curs

			END
			
			--att. 471284 se CONVENZIONE IN URGENZA devo attivare innesco di un sottoprocesso per 
			--OCP,ISTANZIA_CONTRATTO
			if exists ( select id from document_convenzione with (nolock) where id =@convenzione  and ConvenzioniInUrgenza = '1' )
			begin
				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @convenzione, @idpfu, 'CONVENZIONE','VERIFICA_ISTANZIA_CONTRATTO')

			end


			--se ATTIVO IL TED E SULLA GARA ASSOCIATA ALLA CONVENZIONE E' ATTIVO IL TED ALLORA CREO IL DOCUMENTO GESTIONE_GUUE_F03 se non esiste 
			--recupero se TED attivo dai parametri
			select @Ted_Attivo = dbo.PARAMETRI('SERVICE_REQUEST','TED','ATTIVO','NO',-1)

			set @IdGara = 0
			select 
				top 1 
					@IdGara = lg.LinkedDoc
				
				from 
					Document_MicroLotti_Dettagli dettConv  with(nolock) 
						-- Relazione per CIG tra la gara e la conv
						left join ( 
									select  lg.id  , cig , lg.tipodoc , lg.voce , lg.NumeroLotto , LinkedDoc 
										from Document_MicroLotti_Dettagli lg with(nolock)  
											inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
										where isnull( lg.voce , 0 ) = 0 and isnull( CIG ,'' ) <> '' 
									) as lg  on  lg.cig = dettConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and dettConv.NumeroLotto=lg.NumeroLotto 
											
				where 
					dettConv.IdHeader=@convenzione and dettConv.voce=0 and dettConv.TipoDoc='CONVENZIONE'
					and dettConv.StatoRiga not in ('Trasferito') 
	
			set @IsGaraTed='0'

			if @IdGara <> 0
			begin
				if exists (
							select id from ctl_doc with (nolock) 
								where linkeddoc =@IdGara and tipodoc='PUBBLICA_GARA_TED' and statofunzionale='PubTed'  and deleted=0 )
					set @IsGaraTed = '1'
			end


			if @Ted_Attivo = 'YES' and @IsGaraTed = '1'
			begin
				set @id_GUEE=-1
				select @id_GUEE = id from ctl_doc with (nolock) where linkeddoc = @convenzione and tipodoc='GESTIONE_GUUE_F03' and deleted=0

				--se non esiste creo il doc GESTIONE_GUUE_F03
				if @id_GUEE = -1
				begin
					exec GESTIONE_GUUE_F03_CREATE_FROM_CONVENZIONE @convenzione, @idpfu

					select @id_GUEE = id from ctl_doc with (nolock) where linkeddoc = @convenzione and tipodoc='GESTIONE_GUUE_F03' and deleted=0

				end

				--recupero id dei delta_ted_aggiudicazione della gestione GUUE non ancora inviati che hanno la colonna N/M=1
				--e ne schedulo l'invio
				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					select id_delta as IdDoc, @IdUser as IdUser, 'DELTA_TED_AGGIUDICAZIONE','SEND'
						 from 
							GESTIONE_GUUE_F03_LISTA_LOTTI_VIEW 
								
						 where idheaDer = @id_GUEE and Rapporto_N_M = 1 and statofunzionale = 'InLavorazione'

						

			end
			
		END
		ELSE IF @tipoDoc = 'RETTIFICA_GARA'
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )


			-- Oltre che sul documento capostipite aggiungo il protocollo generale anche sulle comunicazioni figlie
			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where LinkedDoc = @idDoc and tipodoc = 'PDA_COMUNICAZIONE_GARA' and JumpCheck like '%-RETTIFICA_BANDO_GARA'

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				VALUES ( @idDoc, @idpfu, 'RETTIFICA_GARA','SEND_FINALIZZA')
 

		END
		ELSE IF @tipoDoc = 'PROROGA_GARA'
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )

			-- Oltre che sul documento capostipite aggiungo il protocollo generale anche sulle comunicazioni figlie
			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where LinkedDoc = @idDoc and tipodoc = 'PDA_COMUNICAZIONE_GARA' and JumpCheck like '%-PROROGA_GARA'

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				VALUES ( @idDoc, @idpfu, 'PROROGA_GARA','SEND_FINALIZZA')
 

		END
		ELSE IF @tipoDoc = 'RIPRISTINO_GARA'
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )

			-- Oltre che sul documento capostipite aggiungo il protocollo generale anche sulle comunicazioni figlie
			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where LinkedDoc = @idDoc and tipodoc = 'PDA_COMUNICAZIONE_GARA' and JumpCheck like '%-RIPRISTINO_GARA'

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				VALUES ( @idDoc, @idpfu, 'RIPRISTINO_GARA','SEND_FINALIZZA')
 

		END
		ELSE IF @tipoDoc = 'COM_DPE_FORNITORE'
		BEGIN
			SELECT  @idpfu = c.owner				   					   
				FROM Document_Com_DPE_Fornitori d with(nolock)	
					inner join Document_Com_DPE  c with(nolock) ON c.IdCom  = d.IdCom 					
				where d.IdComFor  = @idDoc

			
			UPDATE Document_Com_DPE_Fornitori 
				set DataProtocolloGenerale = @dataProtGen,
					ProtocolloGenerale = @protocolloGenerale
				where IdComFor in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO SULLA COM_DPE SE TUTTE HANNO OTTENUTO IL PROTOCOLLO GENERALE 
			-----------------------------------------------------------------------------------
			IF NOT EXISTS ( select * from Document_Com_DPE_Fornitori CUR with (nolock) 
									inner join Document_Com_DPE_Fornitori TUTTE on CUR.IdCom=TUTTE.IdCom and ISNULL(TUTTE.ProtocolloGenerale,'')=''
							where CUR.idcomfor = @idDoc
							)
			BEGIN
				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					select  IdCom, @idpfu, 'COM_DPE','SEND_FINALIZZA'
						from Document_Com_DPE_Fornitori where idcomfor = @idDoc
			END
		END
		ELSE IF @tipoDoc = 'COM_DPE_ENTE'
		BEGIN
			

			
			UPDATE Document_Com_DPE_Enti 
				set DataProtocolloGenerale = @dataProtGen,
					ProtocolloGenerale = @protocolloGenerale
				where IdComEnte in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO SULLA COM_DPE SE TUTTE HANNO OTTENUTO IL PROTOCOLLO GENERALE 
			-----------------------------------------------------------------------------------
			IF NOT EXISTS ( select * from Document_Com_DPE_Enti CUR with (nolock) 
									inner join Document_Com_DPE_Enti TUTTE on CUR.IdCom=TUTTE.IdCom and ISNULL(TUTTE.ProtocolloGenerale,'')=''
							where CUR.idcomEnte = @idDoc
							)
			BEGIN
				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					select  IdCom, @idpfu, 'COM_DPE','SEND_FINALIZZA'
						from Document_Com_DPE_Enti where idcomEnte = @idDoc
			END
		END
		ELSE IF @tipoDoc = 'ESITO_CONTROLLI_OE'
		BEGIN
			
				UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )
			
			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				VALUES ( @idDoc, @idpfu, 'ESITO_CONTROLLI_OE','SEND_FINALIZZA')
 

		END
		ELSE IF @tipoDoc = 'ODC'
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
					,FascicoloGenerale = @fascicoloGenerale 
				where id in ( @idDoc )


			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @IdUser, 'ODC','SEND_FORNITORE_FINALIZZA')
 

		END
		ELSE IF @tipoDoc IN ( 'ODC-ACCETTATO' , 'ODC-RIFIUTATO' ) -- Conferma Ordinativo di fornitura ( ACCETTA ) e  Conferma Ordinativo di fornitura ( ACCETTA )
		BEGIN
			
			IF EXISTS ( select top 1 idrow from Document_dati_protocollo where idheader = @idDoc )
			BEGIN

				UPDATE Document_dati_protocollo
					set protocolloGeneraleSecondario = @protocolloGenerale
						,dataProtocolloGeneraleSecondario = @dataProtGen
					where idheader = @idDoc

			END
			ELSE
			BEGIN
				
				INSERT INTO Document_dati_protocollo( idheader, protocolloGeneraleSecondario, dataProtocolloGeneraleSecondario )
											 VALUES ( @idDoc, @protocolloGenerale, @dataProtGen )

			END

		END
		ELSE IF @tipoDoc like 'CONFERMA_ISCRIZIONE%'
		BEGIN

			UPDATE ctl_doc
				SET DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				WHERE id in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'CONFERMA_ISCRIZIONE','SEND_FINALIZZA')

		END
		ELSE IF ( @tipoDoc = 'SCARTO_ISCRIZIONE' or @tipoDoc = 'SCARTO_ISCRIZIONE_SDA' or @tipoDoc = 'SCARTO_ISCRIZIONE_LAVORI' )
		BEGIN

			UPDATE ctl_doc
				SET DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				WHERE id in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'SCARTO_ISCRIZIONE','SEND_FINALIZZA')
			

		END
		ELSE IF ( @tipoDoc = 'INTEGRA_ISCRIZIONE' or @tipoDoc = 'INTEGRA_ISCRIZIONE_SDA' )
		BEGIN

			UPDATE ctl_doc
				SET DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				WHERE id in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'INTEGRA_ISCRIZIONE','SEND_FINALIZZA')

		END
		ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_GARA'
		BEGIN
			
			-- L'operazione da fare deve cambiare a seconda del jumpCheck ?

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )


			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------

			-- Faccio eseguire in ordine stretto prima comunicazione-finalizza e poi pda_comunicazione_gara-finalizza
			--RIMOSSO IN QUANTO LO IL PROCESSO "PDA_COMUNICAZIONE_GARA" HA UN COMPORTAMENTO SIMILE
			--INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				--	VALUES ( @idDoc, @idpfu, 'COMUNICAZIONE','FINALIZZA')

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'PDA_COMUNICAZIONE_GARA','FINALIZZA')

		END
		ELSE IF @tipoDoc = 'CONFERMA_ISCRIZIONE_SDA'
		BEGIN

			UPDATE ctl_doc
				SET DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				WHERE id in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'CONFERMA_ISCRIZIONE_SDA','SEND_FINALIZZA')

		END
		ELSE IF @tipoDoc = 'INVIO_ATTI_GARA'
		BEGIN

			UPDATE ctl_doc
				SET DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				WHERE id in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'INVIO_ATTI_GARA','SEND_FINALIZZA')

		END
		ELSE IF @tipoDoc in ('BANDO_GARA', 'BANDO_SEMPLIFICATO')
		BEGIN

			-- Aggiorno protocollo e fascicolo sul documento
			UPDATE ctl_doc
				SET DataProtocolloGenerale = @dataProtGen , 
					ProtocolloGenerale = @protocolloGenerale, 
					FascicoloGenerale = @fascicoloGenerale 
				WHERE id in ( @idDoc )


			UPDATE document_dati_protocollo
				SET fascicoloSecondario = @fascicoloGenerale 
				WHERE idheader in ( @idDoc )

			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------
			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'BANDO_SEMPLIFICATO','APPROVE_FINALIZZA')

		END
		ELSE IF @tipoDoc = 'SCRITTURA_PRIVATA'
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				VALUES ( @idDoc, @idpfu, 'SCRITTURA_PRIVATA','SEND_FINALIZZA')

		END
		ELSE IF @tipoDoc = 'CHIARIMENTI_PORTALE'
		BEGIN
			
			----------------------------
			-------   QUESITO  ---------
			----------------------------

			UPDATE Document_Chiarimenti
				SET DataProtocolloGeneraleIN = @dataProtGen , 
					ProtocolloGeneraleIN  = @protocolloGenerale
			WHERE id in ( @idDoc )

		END
		ELSE IF @tipoDoc = 'DETAIL_CHIARIMENTI_BANDO'
		BEGIN

			----------------------------
			--- RISPOSTA A QUESITO  ----
			----------------------------

			UPDATE Document_Chiarimenti
				SET DataProtocolloGenerale = @dataProtGen , 
					ProtocolloGenerale = @protocolloGenerale
			WHERE id in ( @idDoc )

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
						VALUES ( @idDoc, @IdUser, 'DETAIL_CHIARIMENTI','EVADI')

		END
		ELSE IF @tipoDoc = 'CANCELLA_ISCRIZIONE'
		BEGIN
			
			-----------------------------------------------
			-------  Cancella iscrizione ME e SDA ---------
			-----------------------------------------------

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @IdUser, 'CANCELLA_ISCRIZIONE','SEND_FINALIZZA')

		END
		ELSE IF @tipoDoc = 'VERIFICA_REGISTRAZIONE_ACCETTA'
		BEGIN

			IF EXISTS ( select top 1 idrow from Document_dati_protocollo where idheader = @idDoc )
			BEGIN

				UPDATE Document_dati_protocollo
					set protocolloGeneraleSecondario = @protocolloGenerale
						,dataProtocolloGeneraleSecondario = @dataProtGen
					where idheader = @idDoc

			END
			ELSE
			BEGIN
				
				INSERT INTO Document_dati_protocollo( idheader, protocolloGeneraleSecondario, dataProtocolloGeneraleSecondario )
											 VALUES ( @idDoc, @protocolloGenerale, @dataProtGen )

			END

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
				VALUES ( @idDoc, @IdUser, 'VERIFICA_REGISTRAZIONE','APPROVA_FINALIZZA')

		END
		ELSE IF @tipoDoc = 'VARIAZIONE_ANAGRAFICA_ACCETTA'
		BEGIN

			IF EXISTS ( select top 1 idrow from Document_dati_protocollo where idheader = @idDoc )
			BEGIN

				UPDATE Document_dati_protocollo
					set protocolloGeneraleSecondario = @protocolloGenerale
						,dataProtocolloGeneraleSecondario = @dataProtGen
					where idheader = @idDoc

			END
			ELSE
			BEGIN
				
				INSERT INTO Document_dati_protocollo( idheader, protocolloGeneraleSecondario, dataProtocolloGeneraleSecondario )
											 VALUES ( @idDoc, @protocolloGenerale, @dataProtGen )

			END

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
						VALUES ( @idDoc, @IdUser, 'VARIAZIONE_ANAGRAFICA','ACCETTA_FINALIZZA')

		END
		ELSE IF @tipodoc = 'NOTIER_ISCRIZ'
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )

			select top 1 @fascicoloGenerale = Value 
				from v_protgen_dati with(nolock) 
				where idheader = @idVProtGen and DZT_Name = 'FascicoloGenerale' 

			update Document_dati_protocollo 
				set fascicoloSecondario = @fascicoloGenerale
			where idHeader = @idDoc

		END
		ELSE IF @tipoDoc = 'PDA_COMUNICAZIONE_OFFERTA'
		BEGIN
			
			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )


			-----------------------------------------------------------------------------------
			-- SCHEDULO LA FINALIZZAZIONE DEL PROCESSO AVENDO OTTENUTO IL PROTOCOLLO GENERALE -
			-----------------------------------------------------------------------------------

			INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID  ) 
					VALUES ( @idDoc, @idpfu, 'PDA_COMUNICAZIONE_GARA','FINALIZZA')

		END
		ELSE IF @tipoDoc = 'CONTRATTO_GARA_FORN'
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale    = @protocolloGenerale
					,FascicoloGenerale     = @fascicoloGenerale
				where id in ( @idDoc )

			-- RIBALTO SUL CONTRATTO LATO ENTE I DATI DEL PROTOCOLLO GENERALE GENERATI SUL CONTRATTO LATO FORN
			UPDATE CONTRATTO
					set DataProtocolloGenerale  = @dataProtGen
						,ProtocolloGenerale		= @protocolloGenerale
						,FascicoloGenerale     = @fascicoloGenerale
				FROM CTL_DOC a with(nolock)
						inner join ctl_doc CONTRATTO with(nolock) on CONTRATTO.id = a.linkeddoc and CONTRATTO.tipodoc = 'CONTRATTO_GARA'
				where a.id = @idDoc and a.tipodoc = 'CONTRATTO_GARA_FORN'

		END
		ELSE IF @tipoDoc IN ('OFFERTA_BA' )
		BEGIN

			-- PER I 3 SOTTO-PROTOCOLLI DELL'OFFERTA ( BUSTA AMMINISTRATIVA,TECNICA ED ECONOMICA) NON POSSIAMO ANDARE A SOVRASCRIVERE IL PROTOCOLLO GENERALE SULLA CTL_DOC, PERCHE' E' GIA'
			-- PRESENTE QUELLO DELLA BLIND PHASE. QUINDI FACCIAMO DELLE INSERT NELLA CTL_DOC_VALUE LEGATE ALL'OFFERTA
			--		( AL MOMENTO QUESTI PROTOCOLLI NON SONO VISUALIZZATI DA NESSUNA PARTE )
			INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, DZT_Name, Value )
								VALUES( @idDoc, 'BUSTA_AMMINISTRATIVA', 'ProtocolloGenerale', @protocolloGenerale )

			INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, DZT_Name, Value )
								VALUES( @idDoc, 'BUSTA_AMMINISTRATIVA', 'DataProtocolloGenerale', convert(varchar, @dataProtGen, 126) )

		END
		ELSE IF @tipoDoc  IN ('OFFERTA_BT', 'OFFERTA_BE' )
		BEGIN

			-- METTIAMO IL PROTOCOLLO GENERALE DELLE BUSTE TECNICHE ED ECONOMICHE NELLA CTL_DOC_VALUE E NON NELLA DOCUMENT_MICROLOTTI_DOC_VALUE
			--	PER ESSERE COERENTI CON QUANTO FATTO PER IL LETTABUSTA

			-- l'idDoc è l'id della document_microlotti_dettagli
			DECLARE @idOfferta INT

			select @idOfferta = idheader from document_microlotti_dettagli with(nolock) where id = @idDoc 

			INSERT INTO CTL_DOC_VALUE ( IdHeader, Row, DSE_ID, DZT_Name, Value )
								VALUES(@idOfferta ,@idDoc, @tipoDoc, 'ProtocolloGenerale', @protocolloGenerale )

			INSERT INTO CTL_DOC_VALUE ( IdHeader, row, DSE_ID, DZT_Name, Value )
								VALUES( @idOfferta,@idDoc, @tipoDoc, 'DataProtocolloGenerale', convert(varchar, @dataProtGen, 126) )

 		END
		ELSE
		BEGIN

			UPDATE ctl_doc
				set DataProtocolloGenerale = @dataProtGen
					,ProtocolloGenerale = @protocolloGenerale
				where id in ( @idDoc )

		END


	END
	ELSE
	BEGIN
		SELECT 'SYS_ATTIVA_PROTOCOLLO_GENERALE non attiva'
	END
		
END












GO
