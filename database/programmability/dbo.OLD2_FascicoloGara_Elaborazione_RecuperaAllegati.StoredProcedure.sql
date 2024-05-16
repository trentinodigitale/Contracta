USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_FascicoloGara_Elaborazione_RecuperaAllegati]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Versione=1&data=2022-05-11&Attivita=450375&Nominativo=EP
CREATE PROCEDURE [dbo].[OLD2_FascicoloGara_Elaborazione_RecuperaAllegati] ( @IdDoc as int )
AS
BEGIN

	declare @Fascicolo as varchar(50)
	declare @IdDocumento as int
	declare @TipoDoc as varchar(50)
	declare @IdRow as int


	--recupero il fascicolo di gara
	select @Fascicolo = fascicolo from ctl_doc with (nolock) where id = @IdDoc

	--select * from Document_Fascicolo_Gara_Documenti
	--select * from document_Fascicolo_Gara_Allegati 

	--se non ci sono allegati da recuperare cambio stato al documento
	if not exists ( select top 1 idrow from Document_Fascicolo_Gara_Documenti with (nolock) where idheader = @IdDoc and Esito='' )
	begin
		--se non ci sono errori setto lo stato funzionale a "GenerazioneZIP"
		--altrimenti a "Invio_con_errori"
		if not exists ( select top 1 idrow from Document_Fascicolo_Gara_Documenti with (nolock) where idheader = @IdDoc and Esito='NonOK')
		begin	

			--verifichiamo se ci sono allegati per tutti i documenti 
			--se non ci sono ne chiediamo la generazione del PDF
			select 
				DF.idrow 
					into #TempDocPdf
				from 
					Document_Fascicolo_Gara_Documenti DF with (nolock)
						left join Document_Fascicolo_Gara_Allegati FA with (nolock) on FA.idheader = DF.idheader and DF.iddoc = FA.iddoc 
				where
					DF.idheader = @IdDoc and FA.idrow is null
			
			----aggiungo idrow dei documenti per i quali voglio comunque il PDF tramite una relazione 
			insert into 
					#TempDocPdf
					( idrow )
				select idrow 
					from 
						Document_Fascicolo_Gara_Documenti with (nolock)
							inner join ctl_relations with (nolock) on rel_type ='FASCICOLO_GARA' and REL_ValueInput ='DOCUMENTI_GENERA_PDF_PLUS'
																				and tipodoc = REL_ValueOutput 
					where 
						idheader = @IdDoc and GeneraPdf = 0

			if exists (select * from #TempDocPdf )
			begin

				update Document_Fascicolo_Gara_Documenti set GeneraPdf=1,Esito='' where idrow in (select idrow from #TempDocPdf )

				--cambio statofunzionale al documento rimettendo in GenerazionePDF
				update ctl_doc set StatoFunzionale ='GenerazionePDF' where id = @IdDoc

			end
			else
			begin
			
				--setto path e nome file per ogni allegato da aggiungere nello zip
				exec FascicoloGara_Elaborazione_CalcolaPathNomeFile  @IdDoc

				--aggiorno lo stato funzionale 
				update ctl_doc set StatoFunzionale ='GenerazioneZIP' where id = @IdDoc	
			end 
				
		end
		else
		begin
			--aggiorno lo stato funzionale 
			update ctl_doc set StatoFunzionale ='Invio_con_errori' where id = @IdDoc	
		end
	end 
	else
	begin 

		--per ogni documento della tabella Document_Fascicolo_Gara_Documenti con la colonna Esito=''
		--recupero gli allegati e li metto nella tabella document_Fascicolo_Gara_Allegati
		--le due colonne "path" e "nomefile" per lo ZIP le genero alla fine

		DECLARE crsDoc CURSOR STATIC FOR 
	
			select IdRow, iddoc,TipoDoc from Document_Fascicolo_Gara_Documenti with (nolock) where idheader = @IdDoc and Esito='' order by IdRow

		OPEN crsDoc

		FETCH NEXT FROM crsDoc INTO @IdRow, @IdDocumento, @TipoDoc
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			--a meno di documenti che vanno gestiti in modo sepcifico chiamo 
			--una stored che popola gli allegati per il documento
			if @TipoDoc  not in ( 'OFFERTA' )
			begin
				Exec POPOLA_FASCICOLO_ALLEGATI_FROM_DOCUMENT  @IdDoc, @IdDocumento, @TipoDoc
			end

			--se OFFERTA,DOMANDA_DI_PARTECIPAZIONE,ecc... tratto in modo specifico
			--vedere la stored POPOLA_OFFERTA_ALLEGATI cosa fa 
			--vedere cosa fa GET_HASH_FOR_DOWNLOAD_ATTACH_CONTEXT
			if @TipoDoc  in ( 'OFFERTA' )
			begin
			
				----------------------------------------------
				-- decifro l'offerta in modo precauzionale
				----------------------------------------------
				exec AFS_OFFERTA_DECRYPT  @IdDocumento , -1
				exec AFS_DECRYPT_DATI  -1 ,  'CTL_DOC_ALLEGATI' , 'DOCUMENTAZIONE' ,  'idHeader'  ,  @IdDocumento   ,'OFFERTA_ALLEGATI'  , 'idRow,idHeader' , '' , 1 

				--popolo allegati della busta documentazione			
				exec POPOLA_FASCICOLO_ALLEGATI_FROM_OFFERTA @IdDoc, @IdDocumento,'BUSTA_AMMINISTRATIVA'
				
				--GARA MONOLOTTO
				if exists ( select 
								id
								from 
									ctl_doc O with (nolock)
										inner join document_bando with (nolock) on idheader = O.LinkedDoc and Divisione_lotti = '0'
								where O.id =@IdDocumento 
							)
				begin
					--popolo allegati della busta tecnica
					exec POPOLA_FASCICOLO_ALLEGATI_FROM_OFFERTA @IdDoc, @IdDocumento,'TECNICA_MONOLOTTO'
					
					--popolo allegati busta economica
					exec POPOLA_FASCICOLO_ALLEGATI_FROM_OFFERTA @IdDoc, @IdDocumento,'ECONOMICA_MONOLOTTO'
				
				
					-- richiudo la busta dei prodotti
					--chiudo la busta amministrativa se non letta

				end
				else
				--GARA A LOTTI
				begin

					--popolo allegati della busta tecnica
					exec POPOLA_FASCICOLO_ALLEGATI_FROM_OFFERTA @IdDoc, @IdDocumento,'TECNICA_LISTA_LOTTI'
					
					--popolo allegati busta economica
					exec POPOLA_FASCICOLO_ALLEGATI_FROM_OFFERTA @IdDoc, @IdDocumento,'ECONOMICA_LISTA_LOTTI'


					-- richiude le buste non lette relativamente ai lotti
					--chiudo la busta amministrativa se non letta



				end



			end
			
						
			--aggiorno esito per il documento corrente
			update Document_Fascicolo_Gara_Documenti set Esito = 'OK' where IdRow = @IdRow



			FETCH NEXT FROM crsDoc INTO @IdRow, @IdDocumento, @TipoDoc
		END

		CLOSE crsDoc 
		DEALLOCATE crsDoc 

	end
	

END -- Fine stored









GO
