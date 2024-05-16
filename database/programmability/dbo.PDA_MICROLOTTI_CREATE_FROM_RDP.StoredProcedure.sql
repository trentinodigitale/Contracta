USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_MICROLOTTI_CREATE_FROM_RDP]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[PDA_MICROLOTTI_CREATE_FROM_RDP] 
	( @idDoc int  , @idUser int )
AS
BEGIN

	--declare @idDoc as int
	--declare @idUser as int
	

	--set @idDoc=102633	
	--set @idUser=35774	
	
	declare @CriterioFormulazioneOfferte as varchar(100)
	declare @id int
	declare @ProtocolBG  varchar(50)
	declare @CodiceModello as varchar(100)
	declare @CIG as varchar(100)	
	declare @IdDocRDP as varchar(100)
	declare @strSQL as varchar(8000)
	declare @ColValoreOfferto as varchar(100)
	declare @ColQuantita as varchar(100)
	declare @Errore as nvarchar(2000)

	set @Errore=''
	set @Id = 0

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- cerca una versione precedenet del documento
	select @Id = id from CTL_DOC where LinkedDoc = @idDoc and TipoDoc = 'PDA_MICROLOTTI' and deleted = 0 and StatoDoc = 'Saved'
	
	--print @Id

	-- se non viene trovato allora si crea il nuovo documento
	if isnull(@Id , 0 ) = 0 
	begin
		
		-- controllo che la RDP sia nello stato corretto
		if not exists( select idmsg from tab_messaggi_fields where idmsg=@idDoc and stato='2' and (advancedstate='0' or advancedstate='')) 
		begin 
			-- rirorna l'errore
			set @Errore = 'Operazione non consentita per lo stato del documento' 
		end
		
		if @Errore=''
		begin
			
			select @ProtocolBG = ProtocolBG,@CriterioFormulazioneOfferte=CriterioFormulazioneOfferte,
					@CIG=CIG,@IdDocRDP=IdDoc
						from tab_messaggi_fields
							where IdMsg = @idDoc
			
			--print @IdDocRDP
		

			--determino modello in funz di @CriterioFormulazioneOfferte
			if @CriterioFormulazioneOfferte='15536'
				set @CodiceModello = 'BG_MicrolottoBase_p'
			else
				set @CodiceModello = 'BG_MicrolottoBase_s'



			--creo la riga per il bando nella document_microlotti_dettagli
			if not exists(select id from document_microlotti_dettagli where idheader=@idDoc and tipodoc='55;167')
				insert into document_microlotti_dettagli (
						idheader,TipoDoc,NumeroLotto,Descrizione,Voce,CIG ,StatoRiga)
						values
						(@idDoc,'55;167',1,'Valore Offerto',0, @CIG , 'Saved')

			--determino la colonna da valorizzare per le offerte
			select 
				@ColValoreOfferto=FormulaEconomica , @ColQuantita=Quantita
				from 
					document_modelli_microlotti_formula
						where codice=@CodiceModello and CriterioFormulazioneOfferte=@CriterioFormulazioneOfferte
			
			--print @ColValoreOfferto + '--' + @ColQuantita

		
			--select * from tab_messaggi_fields where isubtype=70 
			
			--creo righe per le offerte in partenza nella document_microlotti_dettagli
			--select top 1  CIG,PrezzoUnitarioOfferta  , ScontoOffertoUnitario,  * from document_microlotti_dettagli where tipodoc='55;186'
			if not exists(select id from document_microlotti_dettagli where idheader in (
				select top 1 mfidmsg from MessageFields,tab_utenti_messaggi where mfidmsg=umidmsg and uminput=0 and mfisubtype=70 and mffieldname='iddoc_pe' and mffieldvalue=@IdDocRDP 
			) and tipodoc='55;186')
			begin
				
				set @strSQL = '
					insert into document_microlotti_dettagli (
							   idheader,TipoDoc,NumeroLotto,Descrizione,Voce,' + @ColValoreOfferto + ',' + @ColQuantita + ',CIG,StatoRiga)
						select mfidmsg, ''55;186'',1,''Valore Offerto'',0 , ValoreOfferta, 1 , CIG , ''Saved''
							from 
								MessageFields,tab_utenti_messaggi ,tab_messaggi_fields
							where 
								mfidmsg=umidmsg and uminput=0 and mfisubtype=70 and mffieldname=''iddoc_pe'' and mffieldvalue=''' + @IdDocRDP + ''' and umidmsg=idmsg'							
				
				execute (@strSQL)			

			end
			
			 
	--	end
	--end		

			insert into CTL_DOC (
					 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
						ProtocolloRiferimento,  Fascicolo, 
						LinkedDoc, StatoFunzionale )
				select @idUser as IdPfu ,  'PDA_MICROLOTTI' , 'Saved' , 'PDA per ' + ProtocolloOfferta , Object_Cover1 , pfuidazi , '' as StrutturaAziendale
						, ProtocolloOfferta , ProtocolBG ,
						IdMsg ,'VERIFICA_AMMINISTRATIVA'
					from tab_messaggi_fields
							inner join profiliutente on IdMittente = idpfu
						where IdMsg = @idDoc
		

			set @Id = @@identity

			
			insert into Document_PDA_TESTATA
					( idHeader, ImportoBaseAsta, DataAperturaOfferte, CriterioAggiudicazioneGara, ModalitadiPartecipazione, CriterioFormulazioneOfferte, CIG , OffAnomale , CUP , ImportoBaseAsta2 
						, DataIISeduta , 	NumeroIndizione , DataIndizione , NRDeterminazione , Oggetto , DataDetermina , ListaModelliMicrolotti	, DirezioneProponente  , RequestSignTemp,TipoBandoGara,Conformita,ProceduraGara )
				select  @id   , ImportoBaseAsta, DataAperturaOfferte, CriterioAggiudicazioneGara, '16308' as ModalitadiPartecipazione, CriterioFormulazioneOfferte, CIG --, OffAnomale , CUP , ImportoBaseAsta2  
						 , CASE CHARINDEX ('<AFLinkFieldOffAnomale>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldOffAnomale>', CAST(MSGTEXT AS VARCHAR(8000))) + 23, 400)) 
						   END AS OffAnomale
						 , CASE CHARINDEX ('<AFLinkFieldCUP>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldCUP>', CAST(MSGTEXT AS VARCHAR(8000))) + 16, 400)) 
						   END AS CUP
						 , CASE CHARINDEX ('<AFLinkFieldImportoBaseAsta2>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldImportoBaseAsta2>', CAST(MSGTEXT AS VARCHAR(8000))) + 29, 400)) 
						   END AS ImportoBaseAsta2

						 , case when 
								CASE CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) 
									WHEN 0 THEN ''
									ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 400)) 
								END
								in( '' , 'T00:00:00')  then null
							else
								CASE CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) 
									WHEN 0 THEN ''
									ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataIISeduta>', CAST(MSGTEXT AS VARCHAR(8000))) + 25, 400)) 
								END
						   END AS DataIISeduta


						 , CASE CHARINDEX ('<AFLinkFieldNumeroIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNumeroIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 400)) 
						   END AS NumeroIndizione



						 , case when 
									CASE CHARINDEX ('<AFLinkFieldDataIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) 
										WHEN 0 THEN ''
										ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 400)) 
									end
								in ( '' , 'T00:00:00') then null
							else							
									CASE CHARINDEX ('<AFLinkFieldDataIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) 
										WHEN 0 THEN ''
										ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataIndizione>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 400)) 
									end
							   END AS DataIndizione


						 , CASE CHARINDEX ('<AFLinkFieldNRDeterminazione>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldNRDeterminazione>', CAST(MSGTEXT AS VARCHAR(8000))) + 29, 400)) 
						   END AS NRDeterminazione
						 , Object_Cover1 

						 , case when 
								CASE CHARINDEX ('<AFLinkFieldDDataDetermina>', CAST(MSGTEXT AS VARCHAR(8000))) 
									WHEN 0 THEN ''
									ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataDetermina>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 400)) 
								end
							   in ( '' , 'T00:00:00') then null
							else
								CASE CHARINDEX ('<AFLinkFieldDDataDetermina>', CAST(MSGTEXT AS VARCHAR(8000))) 
									WHEN 0 THEN ''
									ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDataDetermina>', CAST(MSGTEXT AS VARCHAR(8000))) + 26, 400)) 
								end
						   END AS DataDetermina
						
						--modello di lotto associato
						, @CodiceModello
						 
						, CASE CHARINDEX ('<AFLinkFieldDirezioneProponente>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDirezioneProponente>', CAST(MSGTEXT AS VARCHAR(8000))) + 32, 400)) 
						   END AS DirezioneProponente
						 , CASE CHARINDEX ('<AFLinkFieldRequestSignTemp>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRequestSignTemp>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 400)) 
						   END AS RequestSignTemp
						 , '3' as TipoBando	
						 , 'No' as Conformita	
				
						 ,CASE CHARINDEX ('<AFLinkFieldProceduraGara2>', CAST(MSGTEXT AS VARCHAR(8000))) 
								WHEN 0 THEN ''
								ELSE 
							
									CASE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProceduraGara2>', CAST(MSGTEXT AS VARCHAR(8000))) + 27, 400)) 
										WHEN '15582' THEN '15479'
										ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldProceduraGara2>', CAST(MSGTEXT AS VARCHAR(8000))) + 27, 400))
									END 
									
						 END AS ProceduraGara
						 
					from tab_messaggi_fields f
							inner join tab_messaggi m on m.idmsg =  f.idmsg 
						where f.IdMsg = @idDoc


			--aggiungere le offerte
			declare @NumRiga as int

			insert into Document_PDA_OFFERTE
						( IdHeader, NumRiga, aziRagioneSociale, ProtocolloOfferta, ReceivedDataMsg, IdMsg, IdMittente, idAziPartecipante, StatoPDA, Motivazione , Sostituita )
					select 	@id, 0 , RagSoc, ProtocolloOfferta, convert( datetime , ReceivedDataMsg , 126) , IdMsg, IdMittente, pfuIdAzi, case when  stato in ('4','5') then  '99' else '2' end as StatoPDA, '' as Motivazione , case when  stato in ('4','5') then  'si' else '' end as Sostituita
						from TAB_MESSAGGI_FIELDS 
							inner join profiliutente on idMittente = idpfu
					where isubtype = 71 and ProtocolBG = @ProtocolBG
					order by ReceivedDataMsg , idMsg

			select @NumRiga = min(idRow) from Document_PDA_OFFERTE where IdHeader = @id group by idHeader
			update Document_PDA_OFFERTE set NumRiga = idRow - @NumRiga + 1
				where IdHeader = @id
			

			-- genero la motivazione di esclusione se necessario
			declare  @idRow INT
			declare @Stato varchar(50)
			declare @Protocollo varchar(50)


			declare CurProg Cursor static for 
				select idRow ,  stato  from Document_PDA_OFFERTE o
							inner join TAB_MESSAGGI_FIELDS  m on m.IdMsg = o.IdMsg
					where IdHeader = @id and stato in ('4','5')

			open CurProg


			FETCH NEXT FROM CurProg 
			INTO @idRow , @Stato


			WHILE @@FETCH_STATUS = 0
			BEGIN

				exec CTL_GetProtocol @idUser ,@Protocollo output 

				insert into CTL_DOC ( IdPfu , IdDoc , TipoDoc , StatoDoc , Protocollo , Titolo  , Body  , Azienda
									 , DataInvio , Fascicolo , LinkedDoc , StatoFunzionale,Destinatario_Azi ) 
				
					select @idUser , m.idMsg , 'ESITO_ESCLUSA', 'Sended', @Protocollo , '' , ML_Description , p.pfuidazi
									 , getdate() , ProtocolBG , idRow , 'Sended' , idAziPartecipante
							from Document_PDA_OFFERTE o
									inner join TAB_MESSAGGI_FIELDS  m on m.IdMsg = o.IdMsg
									inner join profiliutente p on m.idMittente = p.idpfu
									left outer join LIB_Multilinguismo l on ML_KEY = 'PDA_MSG_esclusa_invalidata' and ML_LNG = 'I'
							--where IdHeader = @id and stato in ('4','5')
							where o.idRow = @idRow


				FETCH NEXT FROM CurProg 
				INTO @idRow , @Stato
			END 

			CLOSE CurProg
			DEALLOCATE CurProg
			
			
			--INNESCO STORED PER LA VALUTAZIONE ECONOMICA
			exec PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA @Id,@idUser



			-- verifica la presenza di exequo. In tal caso la fase sara Valutazione Exequo
			-- altrimenti Valutazione Economica se è prevista la conformità
			if exists( 	select * from Document_MicroLotti_Dettagli  m
							inner join dbo.Document_PDA_OFFERTE o on m.IdHeader = o.idRow and m.TipoDoc = 'PDA_OFFERTE' 
							where o.IdHeader = @Id
								and m.Exequo = 1 )
			begin
				update CTL_DOC set StatoFunzionale = 'VALUTAZIONE_EXEQUO' where id = @Id
			end 
			else
			if exists ( select idheader from document_pda_testata where idheader = @Id and Conformita = 'Ex-Post' )
				update ctl_doc set StatoFunzionale = 'VALUTAZIONE_ECONOMICA' where id = @Id
			else
			begin
				update ctl_doc set StatoFunzionale = 'AGG_PROVV' where id = @Id
			    
				-- cambio lo stato dei lotti in aggiudicazione provvisoria
				update Document_MicroLotti_Dettagli 
					set StatoRiga = 'AggiudicazioneProvv'
					where idheader = @Id and Tipodoc = 'PDA_MICROLOTTI' and Voce = 0
			    
			end

		end
		
		
	end


	-- rirorna l'id della nuova PDA
	if @Errore = ''
		begin
			-- rirorna l'id della nuova PDA appena creata
			select @Id as id , 'FLD_RIEP' as FOLDER
		
		end
	else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end	
	

END


GO
