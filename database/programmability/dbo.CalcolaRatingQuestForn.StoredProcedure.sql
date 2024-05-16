USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CalcolaRatingQuestForn]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CalcolaRatingQuestForn](@id int)
AS


		declare @idQuest int
		declare @iddocForn int
		declare @cnt int
		declare @cnt1 int
		declare @cnt2 int
		declare @IdAzi int
		declare @Punteggio float
		declare @Punteggio1 float
		declare @PunteggioZero int
		declare @protocollo varchar(50)
		declare @PunteggioGenerale float
		declare @PunteggioTecnico float
		declare @SommaPesi float
		declare @SommaPesi1 float
		declare @idrow int
		declare @DataPrimaValutazione datetime
		declare @PunteggioMedio float
		declare @PunteggioReqFacolt float
		declare @IdIstanza int
		declare @MercIst varchar(5000)

		--prende id del questionario (BANDO) e del documento fornitore
		select	@idQuest=linkeddoc,
				@iddocForn=numerodocumento,
				@IdAzi=azienda,
				@protocollo=protocollo,
				@IdIstanza=NumeroDocumento 

			from ctl_doc
		where id=@id

		-- legge merceologia istanza
		set @MercIst = null


			select @MercIst=value 
							from ctl_doc_value
			where idheader=@IdIstanza
					and DZT_Name = 'ArtClasMerceologica'
					and DSE_ID = 'DISPLAY_ABILITAZIONI'
					and row=0




		set @protocollo = left(@protocollo,charindex('-',@protocollo) - 1)

		--conta le risposte al questionario
		select @cnt=count(*)
				from ctl_doc
		where tipodoc='QUESTIONARIO_FORNITORE'
				and deleted=0 and linkeddoc=@idQuest
				and protocollo like @protocollo + '%'

		--conta le risposte al questionario che sono state valutate
		select @cnt1=count(*)
					from ctl_doc
		where tipodoc='QUESTIONARIO_FORNITORE'
					and deleted=0 and linkeddoc=@idQuest
					and statofunzionale='Valutato'
					and protocollo like @protocollo + '%'

		--se sono state tutte valutate genera il record per il report
		if @cnt = @cnt1
		begin
    
    
			set @PunteggioGenerale = 0
			set @PunteggioTecnico = 0
    
			---------------------------------------------------------------------------------
			-- CALCOLA PUNTEGGIO GENERALE ovvero la media pesata dei punteggi per certe
			-- aree di valutazione
			---------------------------------------------------------------------------------
			set @PunteggioZero = 0
			set @Punteggio1 = 0
			set @SommaPesi = 0
			set @SommaPesi1 = 0
    
			set @Punteggio = null
    
			-- calcola punteggio
			-- prende la risposta sull'area di valutazione di testata
			-- si assume che abbia peso 1
			select @Punteggio=isnull(punteggio,0)
					from DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
			where idheader in 
							(
							   select id
									from ctl_doc
											inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
							  where tipodoc='QUESTIONARIO_FORNITORE'
										  and deleted=0 and linkeddoc=@idQuest
										  and istestata=1
										  and protocollo like @protocollo + '%'
							) 
							and isnull(areavalutazione,'') in 
								  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
    
			-- se non lo trova perchè l'area non è tra quelle non ne tiene conto
			if @Punteggio is null
			   set @Punteggio = 0
			else
			begin
			   if @Punteggio = 0
				  set @PunteggioZero = 1
			   else
				  set @SommaPesi = 1
			end
    
			--calcola il punteggio su tutte le righe per le aree non di testata
			--tiene conto solo dei documenti valutati tramite il peso
			select @Punteggio1=sum(isnull(punteggio,0) * isnull(peso,0)),@SommaPesi1=sum(isnull(peso,0))
							from Document_Bando_DocumentazioneRichiesta
			where idheader in 
								(
								  select id
										from ctl_doc
												inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
								  where tipodoc='QUESTIONARIO_FORNITORE'
											  and deleted=0 and linkeddoc=@idQuest
											  and istestata=0
											  and protocollo like @protocollo + '%'
								) 
							and isnull(areavalutazione,'')<>''
							and isnull(areavalutazione,'') in 
								  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
							and punteggio <> -1
							and isnull(obbligatorio,0)=1
							and isnull(tipovalutazione,'Peso')='Peso'
		  
			set @SommaPesi = @SommaPesi + @SommaPesi1
    
			--conta tutte le righe per le aree non di testata
			--tiene conto solo dei documenti valutati tramite il peso
			select @cnt=count(*)
						from Document_Bando_DocumentazioneRichiesta
			where idheader in 
							(
							  select id
									from ctl_doc
											inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
							  where tipodoc='QUESTIONARIO_FORNITORE'
											  and deleted=0 and linkeddoc=@idQuest
											  and istestata=0
											  and protocollo like @protocollo + '%'
							) 
							and isnull(areavalutazione,'')<>''
							and isnull(areavalutazione,'') in 
								  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
							and punteggio <> -1
							and isnull(obbligatorio,0)=1
							and isnull(tipovalutazione,'Peso')='Peso'
    
    
			--conta tutte le righe per le aree non di testata con punteggio 0 ed obbligatorie
			--tiene conto solo dei documenti valutati tramite il peso
			select @cnt2=count(*)
							from Document_Bando_DocumentazioneRichiesta
								where idheader in 
								(
								  select id
											from ctl_doc
												 inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
								  where tipodoc='QUESTIONARIO_FORNITORE'
											  and deleted=0 and linkeddoc=@idQuest
											  and istestata=0
											  and protocollo like @protocollo + '%'
								) 
								and isnull(areavalutazione,'')<>''
								and isnull(areavalutazione,'') in 
									  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
								and isnull(punteggio,0) = 0
								and isnull(obbligatorio,0)=1
								and isnull(tipovalutazione,'Peso')='Peso'
    
			if @cnt2>0
			   set @PunteggioZero = 1
    
    
			set @Punteggio = (@Punteggio + @Punteggio1) / @SommaPesi
    
			-- se c'è almeno un punteggio a zero mette zero al risultato finale
			if @PunteggioZero = 1
			   set @Punteggio = 0
	   
			set @PunteggioGenerale = @Punteggio
    
    
			---------------------------------------------------------------------------------
			-- CALCOLA PUNTEGGIO TECNICO ovvero la media pesata dei punteggi per le
			-- aree di valutazione rimanenti
			---------------------------------------------------------------------------------
			set @PunteggioZero = 0       
			set @Punteggio1 = 0
			set @SommaPesi = 0
			set @SommaPesi1 = 0
    
    
			set @Punteggio = null
    
			-- calcola punteggio
			-- prende la risposta sull'area di valutazione di testata
			-- si assume che abbia peso 1
			select @Punteggio=isnull(punteggio,0)
						from DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi
							where idheader in 
							(
							   select id
											from ctl_doc
										inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
							  where tipodoc='QUESTIONARIO_FORNITORE'
										  and deleted=0 and linkeddoc=@idQuest
										  and istestata=1
										  and protocollo like @protocollo + '%'
							) 
							and isnull(areavalutazione,'') not in 
								  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
    
			-- se non lo trova perchè l'area non è tra quelle non ne tiene conto	
			if @Punteggio is null
			   set @Punteggio = 0
			else
			begin
			   if @Punteggio = 0
				  set @PunteggioZero = 1
			   else
				  set @SommaPesi = 1
			end
    
			--calcola il punteggio su tutte le righe per le aree non di testata   
			--tiene conto solo dei documenti valutati tramite il peso 
			select @Punteggio1=sum(isnull(punteggio,0) * isnull(peso,0)),@SommaPesi1=sum(isnull(peso,0))
					from Document_Bando_DocumentazioneRichiesta
							where idheader in 
							(
							  select id
									from ctl_doc
											inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
							  where tipodoc='QUESTIONARIO_FORNITORE'
											  and deleted=0 and linkeddoc=@idQuest
											  and istestata=0
											  and protocollo like @protocollo + '%'
							) 
							and isnull(areavalutazione,'')<>''
							and isnull(areavalutazione,'') not in 
								  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
							and punteggio <> -1
							and isnull(obbligatorio,0)=1
							and isnull(tipovalutazione,'Peso')='Peso'
		  
			set @SommaPesi = @SommaPesi + @SommaPesi1
    
			--conta tutte le righe per le aree non di testata
			--tiene conto solo dei documenti valutati tramite il peso
			select @cnt=count(*)
						from Document_Bando_DocumentazioneRichiesta
							where idheader in 
							(
							  select id
									from ctl_doc
											inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
							  where tipodoc='QUESTIONARIO_FORNITORE'
										  and deleted=0 and linkeddoc=@idQuest
										  and istestata=0
										  and protocollo like @protocollo + '%'
							) 
							and isnull(areavalutazione,'')<>''
							and isnull(areavalutazione,'') not in 
								  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
							and punteggio <> -1
							and isnull(obbligatorio,0)=1
							and isnull(tipovalutazione,'Peso')='Peso'
    
    
			--conta tutte le righe per le aree non di testata con punteggio 0
			--tiene conto solo dei documenti valutati tramite il peso
			select @cnt2=count(*)
					from Document_Bando_DocumentazioneRichiesta
			where idheader in 
						(
						  select id
								from ctl_doc
										inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
						  where tipodoc='QUESTIONARIO_FORNITORE'
									  and deleted=0 and linkeddoc=@idQuest
									  and istestata=0
									  and protocollo like @protocollo + '%'
						) 
						and isnull(areavalutazione,'')<>''
						and isnull(areavalutazione,'') not in 
							  ('GENERALE','CERTIFICAZIONI','REQUISITI_ETICI','SICUREZZA','ECONOMICO-FINANZIARIO','REQUISITI_EMAS')
						and isnull(punteggio,0) = 0
						and isnull(obbligatorio,0)=1
						and isnull(tipovalutazione,'Peso')='Peso'

    
			if @cnt2>0
			   set @PunteggioZero = 1
    
    
			set @Punteggio = (@Punteggio + @Punteggio1) / @SommaPesi
    
			-- se c'è almeno un punteggio a zero mette zero al risultato finale
			if @PunteggioZero = 1
			   set @Punteggio = 0
	   
			set @PunteggioTecnico = @Punteggio
    
    
			-- calcola la prima data di valutazione
    
			select @DataPrimaValutazione=min(datainvio)
					from ctl_doc	  
			  where tipodoc='QUESTIONARIO_FORNITORE'
					  and deleted=0 and linkeddoc=@idQuest	  
					  and protocollo like @protocollo + '%'
    
    
			 ---------------------------------------------------------------------------------
			-- CALCOLA PUNTEGGIO REQUISITI FACOLTATIVI ovvero la media pesata dei punteggi per 
			-- i non obbligatori
			---------------------------------------------------------------------------------
			set @PunteggioZero = 0       
			set @Punteggio1 = 0
			set @SommaPesi = 0
			set @SommaPesi1 = 0
    
    
			set @Punteggio = null
    
    
    
			--calcola il punteggio su tutte le righe per le aree non di testata    
			--tiene conto solo dei documenti valutati tramite il peso
			select @Punteggio1=sum(isnull(punteggio,0) * isnull(peso,0)),@SommaPesi1=sum(isnull(peso,0))
					from Document_Bando_DocumentazioneRichiesta
								where idheader in 
								(
								  select id
										from ctl_doc
												inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
								  where tipodoc='QUESTIONARIO_FORNITORE'
											  and deleted=0 and linkeddoc=@idQuest
											  and istestata=0
											  and protocollo like @protocollo + '%'
								) 
								and isnull(areavalutazione,'')<>''    
								and punteggio <> -1
								and isnull(obbligatorio,0)=0
								and isnull(tipovalutazione,'Peso')='Peso'


		  
			set @SommaPesi =  @SommaPesi1
    
			--conta tutte le righe per le aree non di testata
			--tiene conto solo dei documenti valutati tramite il peso
			select @cnt=count(*)
					from Document_Bando_DocumentazioneRichiesta
			where idheader in 
						(
						  select id
								from ctl_doc
										inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
						  where tipodoc='QUESTIONARIO_FORNITORE'
								  and deleted=0 and linkeddoc=@idQuest
								  and istestata=0
								  and protocollo like @protocollo + '%'
						) 
						and isnull(areavalutazione,'')<>''    
						and punteggio <> -1
						and isnull(obbligatorio,0)=0
						and isnull(tipovalutazione,'Peso')='Peso'
    
    
			--conta tutte le righe per le aree non di testata con punteggio 0
			--tiene conto solo dei documenti valutati tramite il peso
			select @cnt2=count(*)
					from Document_Bando_DocumentazioneRichiesta
			where idheader in 
							(
							  select id
									from ctl_doc
											inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
							  where tipodoc='QUESTIONARIO_FORNITORE'
									  and deleted=0 and linkeddoc=@idQuest
									  and istestata=0
									  and protocollo like @protocollo + '%'
							) 
							and isnull(areavalutazione,'')<>''    
							and isnull(punteggio,0) = 0
							and isnull(obbligatorio,0)=0
							and isnull(tipovalutazione,'Peso')='Peso'


    
			if @cnt2>0
			   set @PunteggioZero = 1
    
    
			set @Punteggio = @Punteggio1 / @SommaPesi
    
			-- se c'è almeno un punteggio a zero mette zero al risultato finale
			if @PunteggioZero = 1
			   set @Punteggio = 0
	   
			set @PunteggioReqFacolt = @Punteggio

			declare @cnt4 int
			declare @cnt5 int
			declare @NumeroQuestionariNonConformi varchar(20)

			set @cnt4 = 0
			set @cnt5 = 0
			set @NumeroQuestionariNonConformi = ''


			--conta tutte le righe per le aree non di testata
			--con valutazione = conformita
			select @cnt4 = count(*)
					from Document_Bando_DocumentazioneRichiesta
			where idheader in 
						(
						  select id
								from ctl_doc
										inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
						  where tipodoc='QUESTIONARIO_FORNITORE'
								  and deleted=0 and linkeddoc=@idQuest
								  and istestata=0
								  and protocollo like @protocollo + '%'
						) 
						and isnull(areavalutazione,'')<>''    	
						--and isnull(obbligatorio,0)=0	
						and isnull(tipovalutazione,'Peso')='Conformita'


			--conta tutte le righe per le aree non di testata
			--con valutazione = conformita e NON CONFORMI
			select @cnt5 = count(*)
					from Document_Bando_DocumentazioneRichiesta
			where idheader in 
							(
							  select id
									from ctl_doc
												inner join DOCUMENT_ISTANZA_AlboOperaEco_DatiAzi on id=idheader
							  where tipodoc='QUESTIONARIO_FORNITORE'
									  and deleted=0 and linkeddoc=@idQuest
									  and istestata=0
									  and protocollo like @protocollo + '%'
							) 
							and isnull(areavalutazione,'')<>''    	
							--and isnull(obbligatorio,0)=0	
							and isnull(tipovalutazione,'Peso')='Conformita'
							and isnull(punteggio,0) = 12

			set @NumeroQuestionariNonConformi = cast(isnull(@cnt5,'0') as varchar(10)) + '/' + cast(isnull(@cnt4,'0') as varchar(10))
    
			--------------------------------------------------------------------------------------
			-- INSERT NELLA TABELLA DEL REPORT
			--------------------------------------------------------------------------------------
    
			set @PunteggioMedio = (@PunteggioGenerale + @PunteggioTecnico) / 2
    
			-- cancella record già presenti per stesso fornitore,bando,istanza (caso di una rielaborazione)
			delete 
				from Document_Questionario_Fornitore_Punteggi
			where idHeader=@idQuest and IdAzi=@IdAzi and IdDocForn=@IdDocForn

			insert into Document_Questionario_Fornitore_Punteggi
			(idHeader,IdAzi,IdDocForn,PunteggioGenerale,PunteggioTecnico,DataUltimaValutazione,DataScadenzaAbilitazione,PunteggioMedio,PunteggioReqFacolt,NumeroQuestionariNonConformi,MercForn)
			values
			(@idQuest,@IdAzi,@iddocForn,@PunteggioGenerale,@PunteggioTecnico,getdate(),null,@PunteggioMedio,@PunteggioReqFacolt,@NumeroQuestionariNonConformi,@MercIst )
	
	
			set @idrow = @@identity
	
			update Document_Questionario_Fornitore_Punteggi
			--set DataScadenzaAbilitazione = dbo.GetDataScadQuestionario(@idQuest,@IdAzi),DataPrimaValutazione=@DataPrimaValutazione
			set DataScadenzaAbilitazione = null,DataPrimaValutazione=@DataPrimaValutazione
			where idrow = @idrow
	
			-- inserisce i documenti nella tabella Aziende_Documentazione
			declare @Descrizione as nvarchar(250) 
			declare @DataEmissione datetime
			declare @idChainDocStory int

			declare @AnagDoc as nvarchar(150) 
			declare @Allegato as nvarchar(255) 
			declare @DataScadenza datetime
			declare @Obblig int
			declare @AllegatoValutatore as nvarchar(255)



			declare CurProg Cursor for

					select AnagDoc,AllegatoRichiesto,Obbligatorio,DataScadenza, rtrim(isnull(AllegatoValutatore,''))
							from dbo.Document_Bando_DocumentazioneRichiesta
					where idheader in
									(
											select id
												from ctl_doc
										where tipodoc='QUESTIONARIO_FORNITORE'
												and deleted=0 and linkeddoc=@idQuest
												and protocollo like @protocollo + '%'
									)
									and isnull(AnagDoc,'')<>''	
					order by idrow



			open CurProg

			FETCH NEXT FROM CurProg 
					INTO @AnagDoc,@Allegato,@Obblig,@DataScadenza,@AllegatoValutatore

				WHILE @@FETCH_STATUS = 0
				 BEGIN

					 set @Descrizione = @AnagDoc

					 if @AllegatoValutatore <> ''
						set @Allegato = @AllegatoValutatore
			 
					 select @DataEmissione = data 
							from ctl_doc a
								inner join document_anag_documentazione b on a.id=b.idheader
					 where tipodoc='ANAG_DOCUMENTAZIONE' and a.deleted=0
							and AnagDoc=@AnagDoc and a.StatoFunzionale = 'Pubblicato'
			
			 
			
					IF EXISTS (SELECT * from Aziende_Documentazione where idAzi=@IdAzi and AnagDoc=@AnagDoc and ISNULL(@AnagDoc,'')<>'')
						   BEGIN
				    
								Select @idChainDocStory=idChainDocStory from Aziende_Documentazione where idAzi=@IdAzi and AnagDoc=@AnagDoc

								update Aziende_Documentazione set deleted=1 where  idAzi=@IdAzi and AnagDoc=@AnagDoc 

						   END
					 ELSE
					 BEGIN 
						Select @idChainDocStory=MAX(IdRow)+1  from Aziende_Documentazione 
					 END

					 Insert Into Aziende_Documentazione 
						(idAzi, idChainDocStory, AnagDoc, Descrizione, Allegato, DataEmissione, DataInserimento, LinkedDoc, TipoDoc, StatoDocumentazione, deleted, DataSollecito, Interno, DataScadenza)
					 Values 
						(@IdAzi,@idChainDocStory,@AnagDoc,@Descrizione,@Allegato,@DataEmissione,getdate(),@iddocForn,'ISTANZA_AlboOperaEco_qf','Valido',0,'',0,@DataScadenza)
		 
				  FETCH NEXT FROM CurProg 
						INTO @AnagDoc,@Allegato,@Obblig,@DataScadenza,@AllegatoValutatore

				 END 

			CLOSE CurProg
			DEALLOCATE CurProg

		end











GO
