USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PDA_MICROLOTTI_CREATE_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OLD2_PDA_MICROLOTTI_CREATE_FROM_BANDO_GARA] 
	( @idDoc int  , @idUser int )
AS
BEGIN
	
	declare @id int
	declare @ProtocolBG  varchar(50)

	set @Id = 0

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	-- cerca una versione precedenet del documento
	select @Id = id from CTL_DOC where LinkedDoc = @idDoc and TipoDoc = 'PDA_MICROLOTTI' and deleted = 0 and StatoDoc = 'Saved'

	-- se non viene trovato allora si crea il nuovo documento
	if isnull(@Id , 0 ) = 0 
	begin

		select @ProtocolBG = ProtocolBG
					from tab_messaggi_fields
						where IdMsg = @idDoc

		insert into CTL_DOC (
				 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
					ProtocolloRiferimento,  Fascicolo, 
					LinkedDoc, StatoFunzionale,Caption )
			select @idUser as IdPfu ,  'PDA_MICROLOTTI' , 'Saved' , 'PDA per ' + ProtocolloBando , Object_Cover1 , pfuidazi , '' as StrutturaAziendale
					, ProtocolloBando , ProtocolBG ,
					IdMsg ,'VERIFICA_AMMINISTRATIVA',''
				from tab_messaggi_fields
						inner join profiliutente on IdMittente = idpfu
					where IdMsg = @idDoc

		set @Id = @@identity
		
		insert into Document_PDA_TESTATA
				( idHeader, ImportoBaseAsta, DataAperturaOfferte, CriterioAggiudicazioneGara, ModalitadiPartecipazione, CriterioFormulazioneOfferte, CIG , OffAnomale , CUP , ImportoBaseAsta2 
					, DataIISeduta , 	NumeroIndizione , DataIndizione , NRDeterminazione , Oggetto , DataDetermina , ListaModelliMicrolotti	, DirezioneProponente  , RequestSignTemp,TipoBandoGara,ProceduraGara )
			select  @id   , ImportoBaseAsta, DataAperturaOfferte, CriterioAggiudicazioneGara, ModalitadiPartecipazione, CriterioFormulazioneOfferte, CIG --, OffAnomale , CUP , ImportoBaseAsta2  
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
					 , ListaModelliMicrolotti
					 , CASE CHARINDEX ('<AFLinkFieldDirezioneProponente>', CAST(MSGTEXT AS VARCHAR(8000))) 
							WHEN 0 THEN ''
							ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldDirezioneProponente>', CAST(MSGTEXT AS VARCHAR(8000))) + 32, 400)) 
					   END AS DirezioneProponente
					 , CASE CHARINDEX ('<AFLinkFieldRequestSignTemp>', CAST(MSGTEXT AS VARCHAR(8000))) 
							WHEN 0 THEN ''
							ELSE dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldRequestSignTemp>', CAST(MSGTEXT AS VARCHAR(8000))) + 28, 400)) 
					   END AS RequestSignTemp
					 , TipoBando
					 , ProceduraGara	

				from tab_messaggi_fields f
						inner join tab_messaggi m on m.idmsg =  f.idmsg 
					where f.IdMsg = @idDoc


		--aggiungere le offerte
		declare @NumRiga as int


		insert into Document_PDA_OFFERTE
					( IdHeader, NumRiga, aziRagioneSociale, ProtocolloOfferta, ReceivedDataMsg, IdMsg, IdMittente, idAziPartecipante, StatoPDA, Motivazione , Sostituita )
				select 	@id, 0 , RagSoc, ProtocolloOfferta, convert( datetime , ReceivedDataMsg , 126) , IdMsg, IdMittente, pfuIdAzi, case when  stato in ('4','5') then  '99' else '8' end as StatoPDA, '' as Motivazione , case when  stato in ('4','5') then  'si' else '' end as Sostituita
					from TAB_MESSAGGI_FIELDS 
						inner join profiliutente on idMittente = idpfu
				where isubtype = 171 and ProtocolBG = @ProtocolBG
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
								 , DataInvio , Fascicolo , LinkedDoc , StatoFunzionale ) 
			
				select @idUser , m.idMsg , 'ESITO_ESCLUSA', 'Sended', @Protocollo , '' , ML_Description , p.pfuidazi
								 , getdate() , ProtocolBG , idRow , 'Sended' 
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


--		-- ricopio i dati dei lotti per la PDA
--		insert into Document_MicroLotti_Dettagli ( IdHeader, TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere )
--		select @id as IdHeader, 'PDA_MICROLOTTI' as TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere 
--			from Document_MicroLotti_Dettagli
--			where idheader = @idDoc and TipoDoc = '55;167'


--		-- determino gli idmsg dei messaggi in partenza
--		select min( mfidmsg ) as idOffertaPartenza , max( mfidmsg ) as idOffertaArrivo  
--			into #TempOfferte
--			from MessageFields
--			where 
--					mfFieldName = 'IdDoc'
--					and mfFieldValue in (
--						select mfFieldValue from MessageFields
--								where 
--									mfFieldName = 'IdDoc'
--									and mfidmsg in ( select  idmsg  
--														from Document_PDA_OFFERTE_VIEW 
--														where idheader = @Id 
--															--and StatoPDA = '2'
--													)
--					)
--			group by mfFieldValue
--
--
--		-- aggiorno sul documento l'id di partenza
--		update Document_PDA_OFFERTE set IdMsgFornitore = idOffertaPartenza
--			from Document_PDA_OFFERTE
--				inner join #TempOfferte on idOffertaArrivo = IdMsg
--			where idheader = @Id
--
--
--
--		-- ricopio i dati dei lotti per la PDA
--		insert into Document_MicroLotti_Dettagli ( IdHeader, TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere )
--		select p.id as IdHeader, 'PDA_MICROLOTTI' as TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere 
--			from Document_MicroLotti_Dettagli m
--				inner join ctl_doc p on  idheader = LinkedDoc and m.TipoDoc = '55;167'
--			where p.id  = @Id

--		-- ricopio i dati dei lotti per le offerte 
--		insert into Document_MicroLotti_Dettagli ( IdHeader, TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere )
--		select o.IdRow as IdHeader, 'PDA_OFFERTE' as TipoDoc, Graduatoria, Posizione, Aggiudicata, Exequo, StatoRiga, EsitoRiga, ValoreOfferta, NumeroLotto, Descrizione, Qty, PrezzoUnitario, CauzioneMicrolotto, CIG, CodiceATC, PrincipioAttivo, FormaFarmaceutica, Dosaggio, Somministrazione, UnitadiMisura, Quantita, ImportoBaseAstaUnitaria, ImportoAnnuoLotto, ImportoTriennaleLotto, NoteLotto, CodiceAIC, QuantitaConfezione, ClasseRimborsoMedicinale, PrezzoVenditaConfezione, AliquotaIva, ScontoUlteriore, EstremiGURI, PrezzoUnitarioOfferta, PrezzoUnitarioRiferimento, TotaleOffertaUnitario, ScorporoIVA, PrezzoVenditaConfezioneIvaEsclusa, PrezzoVenditaUnitario, ScontoOffertoUnitario, ScontoObbligatorioUnitario, DenominazioneProdotto, RagSocProduttore, CodiceProdotto, MarcaturaCE, NumeroRepertorio, NumeroCampioni, Versamento, PrezzoInLettere 
--			from Document_PDA_OFFERTE o
--					inner join  Document_MicroLotti_Dettagli d on TipoDoc = '55;186' and d.IdHeader = o.IdMsgFornitore
--			where o.idheader = @Id 
--			order by o.idrow , d.Id


	end



	-- rirorna l'id della PDA
	select @id as id

END




GO
