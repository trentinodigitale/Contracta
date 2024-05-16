USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SP_CHECK_ESTENS_DECURTAZIONE_AUTO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[OLD_SP_CHECK_ESTENS_DECURTAZIONE_AUTO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	--declare @idDoc as int
	--declare @IdUser as int
	--set @idDoc=184936
	--set @IdUser=45094

	declare @idconv as int
	declare @ID_ALTRE_CONV as INT
	declare @tipodoc as varchar(500)
	declare @jumpcheck as varchar(500)
	declare @ID_PDA_GRADUATORIA_AGGIUDICAZIONE as int
	declare @estensione as float
	declare @new_id AS INT
	declare @Filter as varchar(500)
    declare @DestListField as varchar(500)

	select @idconv=LinkedDoc,@tipodoc=TipoDoc,@jumpcheck=ISNULL(JumpCheck,'') from ctl_doc WITH(NOLOCK) where id=@idDoc 
	
	-- VERIFICO SE TROVA SULLA CONVENZIONE idbando valorizzato, in quel caso
	-- cerca se ci sono lotti convenzioni che fanno parte della multi aggiudicazione 
	-- allora occorre in automatico eseguire la stessa estensione su tutte le altre convenzioni
	-- ed aggiornare l’informazione presente sul documento Graduatoria Aggiudicazione della PdA. 
	IF EXISTS ( select * from Document_Convenzione WITH(NOLOCK) where id=@idconv and ISNULL(idBando,0) > 0 ) and @jumpcheck <> 'AUTO_DA_CONV'
	BEGIN
		--RECUPERO I LOTTI e CIG INCLUSI NEL DOCUMENTO DI DECURTAZIONE/ESTENSIONE
		--CHE SIANO ANCHE USATE DA ALTRE CONVENZIONI Pubblicate
		Select distinct DC.NumeroLotto,DC.CIG into #tmp_lotti 
			from Document_Convenzione_Lotti DL WITH(NOLOCK)
				inner join Document_MicroLotti_Dettagli DC WITH(NOLOCK) On DC.IdHeader=@idconv and DC.TipoDoc='CONVENZIONE' and DL.NumeroLotto=DC.NumeroLotto				
		where DL.idHeader=@idDoc and DL.Seleziona='Includi'		
	
		--CONTROLLO SE PER I LOTTO/CIG DEVO FARE IN AUTOMATICO IL DOCUMENTO  DECURTAZIONE/ESTENSIONE
		select dettConv.NumeroLotto,dettConv.CIG,gr.id as ID_PDA_GRADUATORIA_AGGIUDICAZIONE  into #tmp_lotti_OK
			from #tmp_lotti dettConv with (nolock)
				inner join Document_MicroLotti_Dettagli lg with(nolock) ON lg.cig = dettConv.CIG and lg.tipodoc = 'PDA_MICROLOTTI' and isnull(lg.voce,0) = 0
				inner join ctl_doc pda with(nolock) ON pda.id = lg.IdHeader and pda.deleted=0 and pda.TipoDoc = 'PDA_MICROLOTTI'
				--inner join Document_Bando gara with(nolock) on gara.idHeader = pda.LinkedDoc
				inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO BCL on BCL.idBando = pda.LinkedDoc and (BCL.N_Lotto = lg.NumeroLotto or BCL.N_Lotto is null )
				inner join CTL_DOC docGara with(nolock) ON docGara.Id = pda.LinkedDoc and docGara.Deleted = 0 
				inner join CTL_DOC gr with(nolock) ON gr.LinkedDoc = lg.Id and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato'
				inner join CTL_DOC_Value gr2 with(nolock) ON gr2.IdHeader = gr.Id and gr2.DSE_ID = 'IMPORTO' and gr2.DZT_Name = 'CIG_LOTTO' and gr2.Value=dettConv.CIG
				inner join Document_microlotti_dettagli aggiud with(nolock) ON aggiud.IdHeader = gr.Id and aggiud.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and ISNULL(aggiud.PercAgg,0) = 100 -- Prendo solo 100%
				inner join Document_Convenzione dc with(nolock) on dc.ID = @idconv and dc.AZI_Dest = aggiud.Aggiudicata	--Il destinatario della conv deve essere tra gli idonei
		where 
			--ISNULL(gara.TipoAggiudicazione,'')='multifornitore'
			ISNULL(BCL.TipoAggiudicazione,'')='multifornitore'
		
		--SE LA TABLE CONTIENE RECORD ALLORA DEVO GENERARE IL DOCUMENTO IN AUTOMATICO DI PDA_GRADUATORIA_AGGIUDICAZIONE
		--PER OGNI LOTTO PRESENTE 
		IF EXISTS (select * from #tmp_lotti_OK)
		BEGIN
			---CREO PDA_GRADUATORIA_AGGIUDICAZIONE IN AUTOMATICO IN AUMENTO/DIMINUZIONE			
			declare CurProg Cursor Static for 	
				select Estensione,ID_PDA_GRADUATORIA_AGGIUDICAZIONE
					from #tmp_lotti_OK TP
						inner join Document_Convenzione_Lotti DL WITH(NOLOCK) on DL.NumeroLotto=TP.NumeroLotto
						inner join ctl_doc CD WITH(NOLOCK) on CD.id=TP.ID_PDA_GRADUATORIA_AGGIUDICAZIONE
					where DL.idHeader=@idDoc
			open CurProg 
			FETCH NEXT FROM CurProg INTO @Estensione,@ID_PDA_GRADUATORIA_AGGIUDICAZIONE
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--CREO IL RECORD NELLA CTL_DOC PER COPIA DA QUELLO DI PARTENZA
				insert into CTL_DOC (IdPfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Titolo, Body, Azienda, StrutturaAziendale, DataInvio, Fascicolo, LinkedDoc, JumpCheck, StatoFunzionale) 
					select @IdUser,'PDA_GRADUATORIA_AGGIUDICAZIONE',CD.StatoDoc,GETDATE(),CD.Protocollo,CD.Id,CD.Titolo,CD.Body,CD.Azienda,CD.StrutturaAziendale,CD.DataInvio,CD.Fascicolo,CD.LinkedDoc,Cd.JumpCheck,CD.StatoFunzionale
						from ctl_doc CD WITH(NOLOCK) 
						where CD.id=@ID_PDA_GRADUATORIA_AGGIUDICAZIONE
				
				SET @new_id=SCOPE_IDENTITY()
				--RICOPIA LA CTL_DOC_VALUE
				Insert into CTL_DOC_Value (IdHeader, DSE_ID, Row, DZT_Name, Value)
					select @new_id, DSE_ID, Row, DZT_Name, Value
						from CTL_DOC_Value where IdHeader=@ID_PDA_GRADUATORIA_AGGIUDICAZIONE

				-- RICOPIO LA MICROLOTTI DETTAGLI 	

				  set @Filter = ' Tipodoc=''PDA_GRADUATORIA_AGGIUDICAZIONE'' '
				  set @DestListField = ' ''PDA_GRADUATORIA_AGGIUDICAZIONE'' as TipoDoc '
		  
				  exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @ID_PDA_GRADUATORIA_AGGIUDICAZIONE, @new_id, 'IdHeader', 
									 ' Id,IdHeader,TipoDoc ', 
									 @Filter, 
									 ' TipoDoc ', 
									 @DestListField,
									 ' id '

				--DECURTA OPPURE AUMENTA IL VALORE PER IL LOTTO
				IF @tipodoc='CONVENZIONE_VALORE'
				BEGIN
					update CTL_DOC_Value set value=cast(cast(value as float) + @Estensione as decimal(18,2)) where IdHeader=@new_id and DSE_ID='IMPORTO' and DZT_Name='ImportoAggiudicatoInConvenzione'
				END
				IF @tipodoc='CONVENZIONE_DECURTAZIONE'
				BEGIN
					update CTL_DOC_Value set value=cast(cast(value as float) - @Estensione as decimal(18,2)) where IdHeader=@new_id and DSE_ID='IMPORTO' and DZT_Name='ImportoAggiudicatoInConvenzione'
				END

				--metto a variato il precedente
				update ctl_doc set StatoFunzionale='Variato' where id=@ID_PDA_GRADUATORIA_AGGIUDICAZIONE
				
				FETCH NEXT FROM CurProg INTO @Estensione,@ID_PDA_GRADUATORIA_AGGIUDICAZIONE
			END

			CLOSE CurProg
			DEALLOCATE CurProg
			
			
			
			--MESSA IN JOIN CON ALTRE CONVENZIONI CHE NON SIA QUELLA CORRENTE PER RECUPERARE
			--SE ESISTONO ALTRE CONVENZIONI OLTRE LA CORRENTE CHE USANO LO STESSO LOTTO/CIG
				select distinct DC2.IdHeader into #tmp_convenzioni
					from #tmp_lotti_OK DC
						inner join  Document_MicroLotti_Dettagli DC2 WITH(NOLOCK) On  DC2.TipoDoc='CONVENZIONE' and DC.NumeroLotto=DC2.NumeroLotto and DC.CIG=DC2.CIG
						inner join ctl_doc CONV WITH(NOLOCK) On CONV.id=DC2.idheader and ISNULL(CONV.JumpCheck,'') <>'INTEGRAZIONE' and CONV.StatoFunzionale='Pubblicato'
					where DC2.IdHeader <> @idconv

			---CI SONO ALTRE CONVENZIONI
			IF EXISTS (select * from #tmp_convenzioni)
			BEGIN
				declare CurProg1 Cursor Static for 	
					select idheader as ID_ALTRE_CONV from #tmp_convenzioni
				open CurProg1 
				FETCH NEXT FROM CurProg1 INTO @ID_ALTRE_CONV
				WHILE @@FETCH_STATUS = 0
				BEGIN
					--CREA I DOCUMENTI DI DECURTAZIONE/ESTENSIONE PER CONVENZIONE ED INCLUDO I LOTTI VALIDI PER QUELLA CONVENZIONE
                     IF @tipodoc = 'CONVENZIONE_VALORE'			
					 BEGIN
						--CREO IL DOCUMENTO
						INSERT into CTL_DOC (
							IdPfu,  TipoDoc, 
							Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_azi,Destinatario_user,JumpCheck
							 )
						select 
							@IdUser as idpfu ,
							 'CONVENZIONE_VALORE' as TipoDoc ,  
							'Convenzione Estensione' as Titolo,
							 DC.DescrizioneEstesa as Body, 
							protocollo as ProtocolloRiferimento, 
							C.id as LinkedDoc			
							,azi_dest
							,referentefornitore
							,'AUTO_DA_CONV'
						from CTL_DOC C  WITH(NOLOCK)
							inner join Document_Convenzione DC  WITH(NOLOCK) on C.id = DC.id
						where C.id = @ID_ALTRE_CONV and C.tipodoc='CONVENZIONE'

						set @new_id = SCOPE_IDENTITY()

						Insert into Document_Convenzione_Azioni ( [IdHeader],Stato, Owner, Protocol, Motivazione, Total, DataIns, deleted, Azione, TipoEstensione, Vaue_Originario, ImportoEstensione, PercEstensione, ImportoEstensioneDigitato,AggiornaQuote)
							select @new_id,Stato, Owner, Protocol, Motivazione, Total, DataIns, deleted, Azione, TipoEstensione, Vaue_Originario, ImportoEstensione, PercEstensione, ImportoEstensioneDigitato,AggiornaQuote
								from Document_Convenzione_Azioni  WITH(NOLOCK) where IdHeader=@idDoc
				
						Insert into Document_Convenzione_Lotti ( idHeader, Seleziona, StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo )
							select   @new_id, DL2.Seleziona, DL2.StatoLottoConvenzione, DL2.NumeroLotto, DL2.Descrizione, DL2.Importo, DL2.Impegnato,DL2.Estensione, DL2.Finale, DL2.Residuo 
								from Document_Convenzione_Lotti DL  WITH(NOLOCK)
									inner join #tmp_lotti_OK T on T.NumeroLotto=DL.NumeroLotto
									inner join Document_Convenzione_Lotti DL2  WITH(NOLOCK) on DL2.idHeader=@idDoc and DL2.NumeroLotto=T.NumeroLotto
								where DL.idheader=@ID_ALTRE_CONV order by DL.idrow

						--SCHEDULO INVIO DEL DOCUMENTO APPENA GENERATO
						insert into CTL_Schedule_Process (IdDoc, IdUser, DPR_DOC_ID, DPR_ID, State, dateIn)
							select @new_id,@IdUser,'CONVENZIONE_VALORE','CAMBIA_VALORE_CONVENZIONE',0,GETDATE()



					 END	
					 IF @tipodoc = 'CONVENZIONE_DECURTAZIONE'			
					 BEGIN
						--CREO IL DOCUMENTO
						INSERT into CTL_DOC (
							IdPfu,  TipoDoc, 
							Titolo, Body, ProtocolloRiferimento, LinkedDoc,Destinatario_azi,Destinatario_user,JumpCheck
							 )
						select 
							@IdUser as idpfu ,
							 'CONVENZIONE_DECURTAZIONE' as TipoDoc ,  
							'Convenzione Decurtazione' as Titolo,
							 DC.DescrizioneEstesa as Body, 
							protocollo as ProtocolloRiferimento, 
							C.id as LinkedDoc			
							,azi_dest
							,referentefornitore
							,'AUTO_DA_CONV'
						from CTL_DOC C  WITH(NOLOCK)
							inner join Document_Convenzione DC  WITH(NOLOCK) on C.id = DC.id
						where C.id = @ID_ALTRE_CONV and C.tipodoc='CONVENZIONE'

						set @new_id = SCOPE_IDENTITY()

						Insert into Document_Convenzione_Azioni ( [IdHeader],Stato, Owner, Protocol, Motivazione, Total, DataIns, deleted, Azione, TipoEstensione, Vaue_Originario, ImportoEstensione, PercEstensione, ImportoEstensioneDigitato)
							select @new_id,Stato, Owner, Protocol, Motivazione, Total, DataIns, deleted, Azione, TipoEstensione, Vaue_Originario, ImportoEstensione, PercEstensione, ImportoEstensioneDigitato
								from Document_Convenzione_Azioni  WITH(NOLOCK) where IdHeader=@idDoc
				
						Insert into Document_Convenzione_Lotti ( idHeader, Seleziona, StatoLottoConvenzione, NumeroLotto, Descrizione, Importo, Impegnato, Estensione, Finale, Residuo )
							select   @new_id, DL2.Seleziona, DL2.StatoLottoConvenzione, DL2.NumeroLotto, DL2.Descrizione, DL2.Importo, DL2.Impegnato,DL2.Estensione, DL2.Finale, DL2.Residuo 
								from Document_Convenzione_Lotti DL  WITH(NOLOCK)
									inner join #tmp_lotti_OK T on T.NumeroLotto=DL.NumeroLotto
									inner join Document_Convenzione_Lotti DL2  WITH(NOLOCK) on DL2.idHeader=@idDoc and DL2.NumeroLotto=T.NumeroLotto
								where DL.idheader=@ID_ALTRE_CONV order by DL.idrow

						--SCHEDULO INVIO DEL DOCUMENTO APPENA GENERATO
						insert into CTL_Schedule_Process (IdDoc, IdUser, DPR_DOC_ID, DPR_ID, State, dateIn)
							select @new_id,@IdUser,'CONVENZIONE_VALORE','CAMBIA_VALORE_CONVENZIONE',0,GETDATE()
					 END
						
					FETCH NEXT FROM CurProg1 INTO @ID_ALTRE_CONV
				END

				CLOSE CurProg1
				DEALLOCATE CurProg1
			END



		END
		
	END
	
END
GO
