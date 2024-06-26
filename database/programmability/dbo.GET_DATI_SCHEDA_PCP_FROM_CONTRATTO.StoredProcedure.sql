USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_DATI_SCHEDA_PCP_FROM_CONTRATTO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  PROCEDURE [dbo].[GET_DATI_SCHEDA_PCP_FROM_CONTRATTO] 
	( @IdContratto int , @Contesto varchar(100) )
AS
BEGIN
	SET NOCOUNT ON;
	
	-- CON LA SCHEDA A1_29 
	--@Contesto='LOTTI' restituisce I CIG DEL CONTRATTO con il quadro economico
	--@Contesto='PARTECIPANTI' restituisce i partecipanti ad ogni CIG
	--@Contesto='INTESTAZIONE' restituisce i campi per scheda SC1

	--PER LA SCHEDA SC1
	--@Contesto='DATI_CONTRATTO'  restituisce i dati per la scheda SC_1
	
	--PER LA SCHEDA S3
	--@Contesto='ELENCO_INCARICHI' restuisce i dati per la scheda S3

	--PER LA SCHEDA A7_1_2
	--@Contesto='AGGIUDICATARIO' restituisce i dati per popolare il campo partecipanti

		
	--LA NAVIGAZIONE ATTUALE FUNZIONA 
		--	DAL CONTRATTO GARA  (@IdContratto contiene id del contratto In Input) -- OK -- 
		--	DALLA CONVENZIONE (@IdContratto contiene id della convenzione) -- OK --
		--  PER LE RDO DALLA SCRITTURA PRIVATA -- OK -- MAI PROVATA


	--SE VENGO DALLA CONVEZIONE (in input ho IdConvenzione) MI PRENDO I CIG DISTINTI CIG-NUMEROLOTTO
	--IDBANDO DALLA DOCUMENT_BANBDO
	--SE IDBANDO NON VALORIZZATO ALLORA DEVO RECUPERARE IDBANDO 
	--COME FATTONEL PASSO "Valorizzo la colonna idBando se non già presente andando in relazione sul cig per recuperare la gara	"
	--DEL PROCESSO CONVENZIONE-PUBBLICA

	--PER I TEST SULLA 46 MONOLOTTO  GARA = 481038   CONTRATTO = 481065 -
				--CONFERMA SCHEDA OK
				--A1_29 ESITO OPERAZIONE OK
				--SC1 ERR2

	--GARA = 480851 CONTRATTO=481284 errore esito operazione su A1_29 --0#BT-701-notice è obbligatorio nel tipo di avviso '29'
				--CONFERMA SCHEDA OK
				--A1_29 ESITO OPERAZIONE OK
				--SC1 ERR2		
	
	--PER I TEST SULLA 46 GARA A LOTTI  CONTRATTI = 481115, 481065   - GARA =  481086  test 
	
	--PER I TEST SULLA 46 DALLA CONVENZIONE (da gara monolotto)  CONVENZIONE = 481221 --  IDGARA = 481176 
			 --P1_16 pubblicata il 15 alle 23:40 la S2 deve esseer fatta dopo un girono
			 --SU CREA SCHEDA S2 DA ERRORE ERR2 (AVVISO RISULTA IN PUBBLICAZIONE)
	
	--PER I TEST SULLA 46 DALLA CONVENZIONE (da gara multilotto) CONVENZIONE =  481248--  IDGARA = 481209 
			 --SU CREA SCHEDA S2 DA ERRORE ERR2 (AVVISO RISULTA IN PUBBLICAZIONE)

	declare @IdPda as int
	declare @IdGara as int
	declare @Divisione_lotti as varchar(10)
	declare @Cig as varchar (100)
	declare @TipoAppaltoGara as varchar(100)
	declare @TipoDocSource as varchar(100)
	declare @TipoDocGara varchar(100)
	declare @DirettoreEsecuzioneContratto as int
	declare @codiceAusa as varchar(100)
	declare @idPartecipante as varchar(100)
	declare @dataStipula as varchar (50)
	declare @dataScadenza as varchar (50)
	declare @importoCauzione as varchar (50)
	declare @dataDecorrenza as varchar(50)
	declare @importo_cauzione as varchar(50)
	declare @IdAziAgg as int
	declare @afferenteInvestimentiPNRR as varchar(1)

	
	--RECUPERO IL TIPO DOC DA CUI STO INNESCANDO (CONTRATTO_GARA/CONVENZIONE/SCRITTURA_PRIVATA)
	select @TipoDocSource=Tipodoc  from CTL_DOC with (nolock) where Id = @IdContratto

	if @TipoDocSource='CONTRATTO_GARA_FORN' and @Contesto in ('ELENCO_INCARICHI','DATI_CONTRATTO')
	begin
		--recupero id del contratto da quello lato fornitore 
		--in modo che riconduco as una situazione che già conosco
		select @IdContratto=linkeddoc from CTL_DOC with (nolock) where Id = @IdContratto
		set @TipoDocSource='CONTRATTO_GARA'
	end

	--SE VENGO DAL CONTRATTO GARA O DAL CONTRATTO DELLA RDO
	if @TipoDocSource = 'CONTRATTO_GARA' or @TipoDocSource='SCRITTURA_PRIVATA'
	begin
		--DAL CONTRATTO RECUPERO LA PDA COLLEGATA e LA GARA 
		select 
			@Idpda=COM.linkeddoc , @IdGara = PDA.linkeddoc , @TipoDocGara = Gara.tipodoc,
			@Divisione_lotti = DG.Divisione_lotti, @Cig=DG.CIG , @TipoAppaltoGara = TipoAppaltoGara

			 ,@afferenteInvestimentiPNRR = 
			   case 
					when isnull(DG.Appalto_PNRR,'no') = 'si' or isnull(DG.Appalto_PNC,'no') = 'si' then 1
					else 0 
			   end


			from CTL_DOC C
				inner join CTL_DOC COM with (nolock) on COM.id=C.linkeddoc and COM.Deleted=0 
				inner join ctl_Doc PDA with (nolock) on PDA.id=COM.linkeddoc  and PDA.Deleted=0 
				inner join Document_Bando DG with (nolock) on DG.idHeader=PDA.linkeddoc
				inner join ctl_doc Gara with (nolock) on GAra.id=DG.idHeader
			where
				C.Id=@IdContratto
	end

	--SE VENGO DALLA CONVENZIONE
	if @TipoDocSource = 'CONVENZIONE'
	begin

		SELECT
			@Idpda=PDA.id, 
			@IdGara=PDA.linkeddoc,
			@TipoDocGara=BG.TipoDoc,
			@Divisione_lotti=DB.Divisione_lotti,
			@Cig=DB.CIG ,
			@TipoAppaltoGara=TipoAppaltoGara,
			@afferenteInvestimentiPNRR = 
			case 
				when isnull(DB.Appalto_PNRR,'no') = 'si' or isnull(DB.Appalto_PNC,'no') = 'si' then 1
				else 0 
			end
				FROM CTL_DOC Conv WITH(NOLOCK)
				--salgo su bando gara
				JOIN CTL_DOC BG WITH(NOLOCK) ON Conv.LinkedDoc = BG.Id
				JOIN Document_Bando DB WITH(NOLOCK) ON DB.idHeader = BG.Id
				--cerco la PDA
				inner join ctl_Doc PDA WITH(NOLOCK) on PDA.linkeddoc=BG.id and PDA.Deleted=0 and PDA.TipoDoc='PDA_MICROLOTTI'
					WHERE Conv.Id=@IdContratto
	end



	--tab temp dei lotti del contratto
	CREATE TABLE #lotticontratto
	(
		numeroLotto varchar(50) collate DATABASE_DEFAULT NULL ,
		CIG nvarchar(50)  collate DATABASE_DEFAULT NULL 
	)

	--select * from #lotticontratto
	--se monolotto utilizzo il cig della testata della gara
	if	@Divisione_lotti = '0'
	begin
		-- PER LE GARE MONOLOTTO
		INSERT INTO #lotticontratto( numeroLotto, cig )
						values ( '1', @Cig )
		--select '1' as numeroLotto , @Cig as cig  into #lotticontratto
	end
	else
	begin
		--DAL CONTRATTO/CONVENZIONE ANDANDO IN JOIB SULLA GARA MI RECUPERO I CIG AGGIUDICATI (voce=0)
		--JOIN SU NUMERO LOTTO CHE SUL CONTRATTO/CONVENZIONE SEMPRE PRESENTE
		insert into #lotticontratto(numeroLotto,CIG)
			select 
				distinct GARA.NumeroLotto , GARA.CIG 
				from 
					document_microlotti_dettagli C with (nolock) 
						inner join document_microlotti_dettagli GARA with (nolock) on GARA.IdHeader=@IdGara and GARA.TipoDoc=@TipoDocGara and GARA.NumeroLotto=C.NumeroLotto and GARA.Voce=0
				where c.idheader=@IdContratto and C.tipodoc=@TipoDocSource --and Voce=0  
	end

	--select * from #lotticontratto
	
	--recuperiamo il quadro economico standard dalla gara @IdGara
				--"impLavori": "double",
	 --             "impServizi": "double",
	 --             "impForniture": "double",
	 --             "impTotaleSicurezza": "double",
	 --             "ulterioriSommeNoRibasso": "double",
	 --             "impProgettazione": "double",
	 --             "sommeOpzioniRinnovi": "double",
	 --             "sommeRipetizioni": "double",
	 --             "#sommeADisposizione*": "double"
	 -- valoreSogliaAnomalia ?? da dove l oprendo ?
	--select * from #lotticontratto
	
	--recuperiamo il quadro economico standard dalla gara @IdGara
				--"impLavori": "double",
	 --             "impServizi": "double",
	 --             "impForniture": "double",
	 --             "impTotaleSicurezza": "double",
	 --             "ulterioriSommeNoRibasso": "double",
	 --             "impProgettazione": "double",
	 --             "sommeOpzioniRinnovi": "double",
	 --             "sommeRipetizioni": "double",
	 --             "#sommeADisposizione*": "double"
	 -- valoreSogliaAnomalia ?? da dove l oprendo ?
	if @Contesto='LOTTI'
	BEGIN

		--temp con le offerte per ogni lotto della pda
		select 
			count(*) as NumOfferte , o.NumeroLotto , d.idheader  
			 into #TempPdaOfferte
				from Document_PDA_OFFERTE d with(nolock) 
					inner join Document_MicroLotti_Dettagli o with(nolock) on d.idRow = o.idheader and o.TipoDoc = 'PDA_OFFERTE'
				where 
					o.voce = 0 and d.idheader = @IdPda
				group by o.NumeroLotto , d.idheader  
		
		--select @IdPda

		select 
			CONTR.*,
			case
				when @TipoAppaltoGara=2 then ValoreImportoLotto
				else 0
			end as impLavori,
			case
				when @TipoAppaltoGara=3 then ValoreImportoLotto
				else 0
			end as impServizi,
			case
				when @TipoAppaltoGara=1 then ValoreImportoLotto
				else 0
			end as impForniture,

			ltrim( str(isnull(IMPORTO_ATTUAZIONE_SICUREZZA,0), 25 , 2 ) ) as impTotaleSicurezza,
			ltrim( str( isnull(DETT_GARA.pcp_UlterioriSommeNoRibasso,0) , 25 , 2 ) ) as ulterioriSommeNoRibasso,
			ltrim( str( isnull(DETT_GARA.impProgettazione ,0), 25 , 2 ) ) as impProgettazione,
			ltrim( str( isnull(DETT_GARA.pcp_SommeOpzioniRinnovi,0) , 25 , 2 ) ) as sommeOpzioniRinnovi,
			ltrim( str( isnull(DETT_GARA.pcp_SommeADisposizione,0) , 25 , 2 ) ) as sommeADisposizione ,
			ltrim( str( isnull(DETT_GARA.pcp_SommeRipetizioni,0) , 25 , 2 ) ) as sommeRipetizioni,
			
			--DA CAPIRE
			'0.00' as valoreSogliaAnomalia, -- ???
			--salgo da id dell lotto sull apda al doc verifica anomlia e nella doc_value il campo sogliaanomalia

			O.NumOfferte as numeroOfferteAmmesse,

			@afferenteInvestimentiPNRR as afferenteInvestimentiPNRR,
			
			case
				when isnull(@Divisione_lotti,'0') = '0' then 	
					case 
						when CUP <> '' then 'true'
						else 'false'
					end
				else 
					case 
						when CUP <> '' then 'true'
						else 'false'
					end
				end as acquisizioneCup,
				TIPO_FINANZIAMENTO,
				pcp_ImportoFinanziamento

			from
				#lotticontratto CONTR
				inner join
					Document_MicroLotti_Dettagli DETT_GARA on DETT_GARA.NumeroLotto = CONTR.numeroLotto and DETT_GARA.voce =0
				left join #TempPdaOfferte O on O.NumeroLotto=DETT_GARA.NumeroLotto
			where
				DETT_GARA.IdHeader = @IdGara and TipoDoc=@TipoDocGara  

			--select * from #lotticontratto
			--select @IdGara
			--select @TipoDocGara
			drop table #TempPdaOfferte
	END

	--SE CONTESTO PARTECIPANTI RECUPERO I PARTECIPANTI 
	--"#idPartecipante
	--importo
	--aggiudicatario
	
	--ccnl ???
	--	posizioneGraduatoria	[...]
	--offertaEconomica	[...]    
	--offertaQualitativa	[...]
	--offertaInAumento	[...]
	--offertaMaggioreSogliaAnomalia	[...]
	--impresaEsclusaAutomaticamente	[...]
	--offertaAnomala



	if @Contesto='PARTECIPANTI'
	BEGIN
		select 
	
			CONTR.*, 
			--PDA.Aggiudicata , o.idAziPartecipante,
			Offe.guid as idPartecipante, 
			ltrim( str( od.ValoreImportoLotto , 25 , 2 ) )   as importo,
			case 
				when PDA.Aggiudicata = o.idAziPartecipante then 'true'
				else 'false'
			end as aggiudicatario,

			'non applicabile' as ccnl,  -- ??? DA CAPIRE DOVE RECUPERARE
			od.Graduatoria as posizioneGraduatoria,
		
			ltrim( str( od.ValoreSconto , 25 , 2 ) ) as offertaEconomica,   --???
			'0.00' as offertaQualitativa, --???
			'0.00' as offertaInAumento,   --???
			'false' as offertaMaggioreSogliaAnomalia, --???
			'false' as impresaEsclusaAutomaticamente, -- ?? 
			case 
				when od.statoriga = 'anomalo' then 'true'
				else 'false'
			end as offertaAnomala

			from 
			#lotticontratto CONTR
				inner join document_microlotti_dettagli PDA  with(nolock)
					on CONTR.NumeroLotto=PDA.NumeroLotto collate DATABASE_DEFAULT
				--vado a prendere ipartecipanti al lotto
				inner join Document_PDA_OFFERTE o with(nolock) on PDA.idheader =  o.idheader
				inner join CTL_DOC Offe with(nolock) on Offe.Id = o.IdMsg
				inner join Document_MicroLotti_Dettagli od with(nolock) 
						on o.idRow = od.idHeader and od.tipoDoc = 'PDA_OFFERTE' and od.NumeroLotto = PDA.NumeroLotto and od.voce = 0
						and od.StatoRiga<>'escluso'
				
				

			where  pda.idheader=@IdPda and pda.tipodoc='PDA_MICROLOTTI' and PDA.voce=0
				order by cast(PDA.Numerolotto as int)
			
			
		END

	if @Contesto='AGGIUDICATARIO'
	BEGIN

		select 
			CONTR.*,
			OFFERTA.tipoDoc,
			pda_dett.TipoDoc,
			vatValore_FT as codiceFiscale,
			A.aziRagioneSociale as Denominazione,
			'3' as ruoloOE,
			case 
				when dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0) = A.aziIdDscFormaSoc then '1'
				else dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0)
			end  as tipoOE,

			OFFERTA.GUID AS idPartecipante,
			aziLocalitaLeg  as paeseOperatoreEconomico,

			case	
				when AUS.value <> '1' then 'false'
				else 'true'
			end as avvalimento,

			PDA_LO.ValoreImportoLotto AS importo
			from 
			#lotticontratto CONTR
				join
				--prendo tutti i lotti in uno stato valido per il recupera cig
				Document_MicroLotti_Dettagli PDA_DETT with (nolock) 
					on CONTR.NumeroLotto=PDA_DETT.NumeroLotto collate DATABASE_DEFAULT
					--salgo sull'offerta dell'aggiudicatario
					inner join Document_PDA_OFFERTE PDA_OFF  with (nolock)
									on PDA_OFF.IdHeader=PDA_DETT.IdHeader and  PDA_OFF.idAziPartecipante = PDA_DETT.Aggiudicata 
										and PDA_OFF.StatoPDA in ('2')
					--vado su offerta lotto dell'aggiudicataria
					inner join Document_MicroLotti_Dettagli PDA_LO with (nolock)  on PDA_LO.IdHeader = PDA_OFF.IdRow and PDA_LO.TipoDoc ='PDA_OFFERTE'
										and PDA_LO.NumeroLotto = PDA_DETT.NumeroLotto and PDA_LO.Voce=0
					--salgo su offerta complessiva
					inner join CTL_DOC OFFERTA with (nolock) on OFFERTA.Id = PDA_OFF.IdMsg
					--vedo se ricorre ausiliaria
					left join ctl_doc_Value AUS with (nolock)  on AUS.idheader = OFFERTA.Id and dse_id='AUSILIARIE' and dzt_name='RicorriAvvalimento'
					--recupero info aggiudicataria
					inner join aziende A with (nolock) on A.idazi = PDA_DETT.Aggiudicata
					inner join dm_Attributi with (nolock) on lnk=A.idazi and dztNome ='codicefiscale'

				where PDA_DETT.IdHeader=@IdPda and PDA_DETT.TipoDoc ='PDA_MICROLOTTI'
						and PDA_DETT.StatoRiga in ('AggiudicazioneProvv','Controllato','AggiudicazioneCond','AggiudicazioneDef')
	
		END
	
	if @Contesto='ELENCO_INCARICHI' 
	BEGIN
		 --codiceFiscale    ok 
		 --cognome          ok 
		 --nome             ok
		 --telefono         ok
		 --fax              NO
		 --email            ok
		 --indirizzo        NO
		 --cap              NO
		 --codIstat (tipologica il codice )   NO
		--recupero direttoreesecuzione

		--SE VENGO DAI CONTRATTI LA SORGENTE E' LA STESSA
		if @TipoDocSource='CONTRATTO_GARA' or @TipoDocSource='SCRITTURA_PRIVATA'
		BEGIN
			select @DirettoreEsecuzioneContratto= cast ( value as int)
				from CTL_DOC_Value with (nolock)
					where IdHeader = @IdContratto and DSE_ID='CONTRATTO' and DZT_Name='DirettoreEsecuzioneContratto'
		END

		if @TipoDocSource='CONTRATTO_GARA' or @TipoDocSource='CONVENZIONE'
		BEGIN
			--DEVO VERIFICARE DOVE MEMORIZZIAMOIL VALORE IN QUALE SEZIONE
			select @DirettoreEsecuzioneContratto=isnull(DirettoreEsecuzioneContratto,'') from document_convenzione where id = @IdContratto
		END
	

		--RESITUISCO PER OGNI CIG LE INFO DEL DIRETTORE ESECUZIONE DEL CONTRATTO
		--LE INFO NULL NON LE AGGIUGIAMO AL JSON
		select 
			CONTR.*,
			'8' as tipoIncarico,
			pfuCodiceFiscale as codiceFiscale,
			pfuCognome as cognome,
			pfunomeutente as nome,
			pfuTel as telefono,
			NULL as fax,
			pfuE_Mail as email,
			NULL as indirizzo,
			NULL as cap,
			NULL as codIstat,
			'false' as incaricatoEstero
		from 
			#lotticontratto CONTR
				cross join profiliutente with (nolock) 
				
			where idpfu =@DirettoreEsecuzioneContratto
	END
	

	--select @IdContratto 

	--per la scheda SC_1
	if @Contesto='DATI_CONTRATTO'
	BEGIN
		--CIG,
		--codiceAusa --dalla gara (recuperato dai dati piatti della scheda nella WEB\API)
		
		if @TipoDocSource ='CONVENZIONE'
		begin
			--DALLA CONVENZIONE

			--RECUPERO DESTINTARIO CONVENZIONE
			select  @IdAziAgg = Mandataria from Document_Convenzione where ID = @IdContratto

			--per ogni lotto recupero guid offerta dell'azienda agg che ha fatto offerta sul lotto
			select 
				CONTR.*  , Offe.guid as idPartecipante
					into #Dati_Contratto_Convenzione
				from 
					#lotticontratto CONTR
						inner join document_microlotti_dettagli PDA  with(nolock)
							on CONTR.NumeroLotto=PDA.NumeroLotto collate DATABASE_DEFAULT
						--vado a prendere ipartecipanti al lotto
						inner join Document_PDA_OFFERTE o with(nolock) on PDA.idheader =  o.idheader
						inner join CTL_DOC Offe with(nolock) on Offe.Id = o.IdMsg and Offe.Azienda = @IdAziAgg
						inner join Document_MicroLotti_Dettagli od with(nolock) 
							on o.idRow = od.idHeader and od.tipoDoc = 'PDA_OFFERTE' and od.NumeroLotto = PDA.NumeroLotto and od.voce = 0
				where  pda.idheader=@IdPda and pda.tipodoc='PDA_MICROLOTTI' and PDA.voce=0
						order by cast(PDA.Numerolotto as int)

			
			--recupero le altr info dalla convenzione
			select @DataStipula=DataStipulaConvenzione  FROM Document_Convenzione where id = @IdContratto 

			select @dataDecorrenza=DataInizio   FROM Document_Convenzione where id = @IdContratto 

			select @dataScadenza=DataFine   FROM Document_Convenzione where id = @IdContratto

			select @importo_cauzione=Importo_Cauzione  FROM Document_Convenzione where id = @IdContratto
			 
		end
		else
		begin
			
			--DAL CONTRATTO

			--idPartecipante
			select @idPartecipante = O.GUID 
				from 
					ctl_doc_Value with (nolock)  
						inner join ctl_Doc O with (nolock) on O.Protocollo = value  and tipodoc='Offerta'
				where 
					idheader = @IdContratto and dse_id='document' and DZT_Name ='ProtocolloOfferta'
	
			--dataStipula
			--RECUPERO DATA STIPULA DEL CONTRATTO
			select @DataStipula=value 
				from 
					CTL_DOC_Value with (nolock) 
				where IdHeader=@IdContratto and DSE_ID='CONTRATTO' and DZT_Name='DataStipula'

			--dataDecorrenza
			select @dataDecorrenza=value 
				from 
					CTL_DOC_Value with (nolock) 
				where IdHeader=@IdContratto and DSE_ID='CONTRATTO' and DZT_Name='DataDetermina'

			--dataScadenza
			select @dataScadenza=value 
				from 
					CTL_DOC_Value with (nolock) 
				where IdHeader=@IdContratto and DSE_ID='CONTRATTO' and DZT_Name='DataScadenza'

			--importoCauzione
			select @importo_cauzione=value 
				from 
					CTL_DOC_Value with (nolock) 
				where IdHeader=@IdContratto and DSE_ID='CONTRATTO' and DZT_Name='Importo_Cauzione'

			--se data decorrenza vuota considero data stipula
			if @dataDecorrenza= ''
				set @dataDecorrenza = @dataStipula

		end

		--FIX DatePicker FaseII (IL FORMATO TECNICO DELLE DATE E' STATO INFICIATO)
		set @dataStipula = (
			SELECT 
				CASE 
					WHEN CHARINDEX('T:', @dataStipula) > 0 THEN 
						STUFF(REPLACE(@dataStipula, '/', '-'), CHARINDEX('T:', @dataStipula) + 1, 1, '')
					ELSE 
						REPLACE(@dataStipula, '/', '-')
				END --AS data_formattata
		);
		set @dataDecorrenza = (
			SELECT 
				CASE 
					WHEN CHARINDEX('T:', @dataDecorrenza) > 0 THEN 
						STUFF(REPLACE(@dataDecorrenza, '/', '-'), CHARINDEX('T:', @dataDecorrenza) + 1, 1, '')
					ELSE 
						REPLACE(@dataDecorrenza, '/', '-')
				END --AS data_formattata
		);
		set @dataScadenza = (
			SELECT 
				CASE 
					WHEN CHARINDEX('T:', @dataScadenza) > 0 THEN 
						STUFF(REPLACE(@dataScadenza, '/', '-'), CHARINDEX('T:', @dataScadenza) + 1, 1, '')
					ELSE 
						REPLACE(@dataScadenza, '/', '-')
				END --AS data_formattata
		);
		--END FIX

		--rettifico le date nel formato per anac
		SET @dataStipula=		case 
									when isdate(@dataStipula) = 1 then dbo.GetStrTecDateUTC( cast(@DataStipula as datetime)) 
									else ''
								end 
			
		SET @dataDecorrenza=	case 
									when isdate(@dataDecorrenza) = 1  then dbo.GetStrTecDateUTC( cast(@dataDecorrenza as datetime))  
									else ''
								end 

		SET @dataScadenza = 	case 
									when isdate(@dataScadenza)= 1 then dbo.GetStrTecDateUTC( cast(@dataScadenza as datetime))   
									else ''
							end 

		--RESITUISCO PER OGNI CIG LE INFI DEL DIRETTORE ESECUZIONE DEL CONTRATTO
		if @TipoDocSource ='CONTRATTO_GARA'
		BEGIN
			select 
				CONTR.*,
				@codiceAusa as codiceAusa,
				@idPartecipante as idPartecipante,
				@dataStipula AS dataStipula,
				@dataDecorrenza AS dataDecorrenza,
				@dataScadenza AS dataScadenza,
				isnull(@importo_cauzione,0) as importoCauzione

			from 
				#lotticontratto CONTR
		END
		ELSE
		BEGIN

			--dalle CONVENZIONI
			select 
				*,
				@codiceAusa as codiceAusa,
				@dataStipula AS dataStipula,
				@dataDecorrenza AS dataDecorrenza,
				@dataScadenza AS dataScadenza,
				isnull(@importo_cauzione,0) as importoCauzione
				from 
					#Dati_Contratto_Convenzione
		END

	END

	drop table #lotticontratto

END


--declare @test as varchar(50)
--set @test='2023-12-18'
--select cast( @test as datetime)







GO
