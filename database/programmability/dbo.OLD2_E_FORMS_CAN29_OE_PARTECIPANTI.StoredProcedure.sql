USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_E_FORMS_CAN29_OE_PARTECIPANTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_E_FORMS_CAN29_OE_PARTECIPANTI] ( @idProc int, @idPDA int , @idUser int = 0, @guidOperation varchar(500), @numeroLotto varchar(1000) = '', @debug int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	--RIPULISCO GLIAGGIUDICATARI
	delete from Document_E_FORM_ORGANIZATION where recordType='aggiudicatari' and idHeader = @idProc


	-- MANTENERE LE COLONNE DI OUTPUT DI QUESTA SELECT ALLINEATE CON QUELLE DELLA STORED E_FORMS_CN16_DATI_ENTE. ENTRAMBE PRODUCONO ORGANIZATIONS

	DECLARE @TempMandatarie table ( idazi int )

	DECLARE @idMicDet INT
	DECLARE @numlottoDett varchar(10)
	DECLARE @Aggiudicata int 
	DECLARE @TipoAggiudicazione VARCHAR(100)

	-- prendiamo dalla tabella di "buffer" tutti i lotti aggiudicati
	SELECT idRow as idMicDet,strData1 as NumeroLotto, intData1 as Aggiudicata, case when isnull(strData3,'') = '' then 'monofornitore' else strData3 end as TipoAggiudicazione
		INTO #lotti_agg_def
		FROM Document_E_FORM_BUFFER a WITH(NOLOCK)
		WHERE a.[guid] = @guidOperation and infoType = 'LOTTI_CHIUSI' and strData2 = 'AggiudicazioneDef'

	CREATE TABLE #offerteAgg ( idOff INT, NumeroLotto varchar(100), idAziPartecipante INT, idPdaOff INT  )

	-- GESTIONE PER VALORIZZARE IL CAMPO BT-165 ( WINNER SIZE )
	--	determino il nome dell'attributo del DGUE che contiene l'informazione per le aziende PMI (S/N)
	--	il record sul criterio è quello che ha nella colonna SorgenteCampo il valore 'PMI'
	--	recupero il template DGUE PUBBLICATO
	declare @IdTemplate INT = -1
	declare @MA_DZT_NAME varchar(1000) = ''

	select top 1 @IdTemplate = id from ctl_doc with (nolock) where tipodoc='TEMPLATE_REQUEST' and statofunzionale='Pubblicato'

	IF @IdTemplate > 0
	BEGIN

		--recupero il nome dell'attributo contenente l'informazione utile a calcolare winner size
		SELECT top 1  @MA_DZT_NAME = upper( 'MOD_' + replace( k.value , '.' , '_' )  + '_FLD_' +   dbo.GetID_ElementModulo ( ItemPath , ItemLevel  , TypeRequest ) ) 
			FROM CTL_DOC_Value t with(nolock)
					inner join CTL_DOC_Value k with(nolock) on t.idheader = k.idheader and t.Row = k.Row and k.DSE_ID = 'VALORI' and k.DZT_Name = 'KeyRiga'
					inner join CTL_DOC_Value M with(nolock) on t.idheader = M.idheader and t.Row = M.Row and M.DSE_ID = 'VALORI' and M.DZT_Name = 'IdModulo'
					inner join DOCUMENT_REQUEST_GROUP G with(nolock) on G.idheader = M.value and G.SorgenteCampo='PMI'
			WHERE t.idHeader=@IdTemplate and t.DSE_ID = 'VALORI' and t.DZT_Name = 'REQUEST_PART' and t.value = 'Modulo' 
					
	END


	CREATE TABLE #aggiudicataLotto
	(
		idAzi INT,
		NumeroLotto varchar(100),
	)

	DECLARE cursAgg CURSOR FAST_FORWARD FOR

		select idMicDet, NumeroLotto, Aggiudicata, TipoAggiudicazione from #lotti_agg_def

	OPEN cursAgg
	FETCH NEXT FROM cursAgg INTO @idMicDet, @numlottoDett, @Aggiudicata, @TipoAggiudicazione

	--ESEGUO UN CURSORE PER CAMBIARE IL MODO DI POPOLARE LE AGGIUDICATARIE IN BASE AL TIPO DI AGGIUDICAZIONE MONO/MULTI
	WHILE @@FETCH_STATUS = 0   
	BEGIN

		IF @debug = 1
		BEGIN
			print '@numlottoDett:' + @numlottoDett
			print '@TipoAggiudicazione:' + @TipoAggiudicazione
		END

		IF isnull(@TipoAggiudicazione,'') in (  'monofornitore' , '' )
		BEGIN

			INSERT INTO @TempMandatarie ( idazi ) SELECT @Aggiudicata

			INSERT INTO #aggiudicataLotto( idAzi, NumeroLotto ) SELECT @Aggiudicata, @numlottoDett

		END
		ELSE
		BEGIN
			
			-- CASO AGGIUDICAZIONE MULTI FORNITORE
			INSERT INTO #aggiudicataLotto ( idazi, NumeroLotto )
				SELECT Aggiudicata, @numlottoDett
					FROM ctl_doc gr with (nolock)	
							INNER JOIN Document_microlotti_dettagli aggiud with(nolock) ON aggiud.IdHeader = gr.Id and aggiud.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE'
							--LEFT JOIN ctl_doc_value impAggM with(nolock) on impaggm.idheader = gr.id and impAggM.dse_id = 'IMPORTO' and impAggM.dzt_name = 'ImportoAggiudicatoInConvenzione'
					WHERE gr.LinkedDoc = @idMicDet and gr.TipoDoc = 'PDA_GRADUATORIA_AGGIUDICAZIONE' and gr.StatoFunzionale = 'Confermato'		
							and aggiud.Posizione in ('','Idoneo provvisorio')

			INSERT INTO @TempMandatarie ( idazi )
				select  idazi from #aggiudicataLotto

		END

		-- Carichiamo tutte le offerte vincenti di questo lotto filtrando per lotto e per idAziPartecipante ( aggiudicate )
		INSERT INTO #offerteAgg ( idOff, NumeroLotto, idAziPartecipante, idPdaOff )
			SELECT IdMsgFornitore, @numlottoDett, O_PDA.idAziPartecipante, lo.Id
				FROM document_pda_offerte O_PDA with(nolock) 
						inner join Document_MicroLotti_Dettagli LO with(nolock) on LO.idheader = O_PDA.idrow and LO.TipoDoc='PDA_OFFERTE' and LO.NumeroLotto = @numlottoDett and LO.Voce = 0
				WHERE O_PDA.idheader = @IdPda and O_PDA.idAziPartecipante in ( select idazi from #aggiudicataLotto )

		truncate table #aggiudicataLotto

		FETCH NEXT FROM cursAgg INTO @idMicDet, @numlottoDett, @Aggiudicata, @TipoAggiudicazione

	END  

	CLOSE cursAgg 
	DEALLOCATE cursAgg 

	DROP TABLE #aggiudicataLotto

	-- SALVIAMO NELLA TABELLA DI BUFFER TUTTE LE OFFERTE
	INSERT INTO Document_E_FORM_BUFFER( [guid], infoType, strData1, intData1, intData2 ,IdProc )
								select @guidOperation, 'OFF_WINNER', NumeroLotto, idOff, idPdaOff, @idProc
								from #offerteAgg

	--INSERIAMO GLI AGGIUDICATARI RTI
	SELECT OFFERTA.Id as idOfferta, DO.idazi, Ruolo_Impresa, IdAziRiferimento as idaziRTI, do.RagSocRiferimento as RagSocRTI, 1 as RTI, DO.IdDocRicDGUE, cast('' as varchar(10)) as PMI 
		INTO #tempAzi
			FROM ctl_doc OFFERTA with(nolock) 
						inner join CTL_DOC C with(nolock) on C.tipodoc='OFFERTA_PARTECIPANTI' and c.statofunzionale='Pubblicato' and c.linkeddoc=OFFERTA.ID
						inner join Document_Offerta_Partecipanti DO with(nolock) on C.id = DO.IdHeader and TipoRiferimento = 'RTI' --and Ruolo_Impresa <> 'mandataria'
			WHERE OFFERTA.id in ( select idOff from #offerteAgg )

	-- Togliamo dalla tabella temporanea le offerte aggiudicate alle RTI
	DELETE FROM #offerteAgg where idOff in ( select idOfferta from #tempAzi )

	--INSERIAMO GLI AGGIUDICATARI NON RTI
	INSERT INTO #tempAzi( idOfferta, idazi, Ruolo_Impresa, idaziRTI, RagSocRTI, RTI, IdDocRicDGUE, PMI )
		SELECT OFFERTA.Id, Idazi, 'mandataria', 0, '', 0 , offerta.id, ''
			FROM @TempMandatarie
					inner join ctl_doc OFFERTA with (nolock) on azienda = Idazi and Tipodoc='OFFERTA' and OFFERTA.Deleted=0
			WHERE OFFERTA.id in ( select idOff from #offerteAgg )

	-- se abbiamo l'attributo da cui prendere l'informazione di PMI
	IF @MA_DZT_NAME <> ''
	BEGIN

		-- DESUMIAMO L'INFORMAZIONE PMI RECUPERANDO IL DATO DAL DGUE
		DECLARE curs2 CURSOR FAST_FORWARD FOR
			select IdDocRicDGUE,idazi,RTI  from #tempAzi

		declare @isRTI INT = 0
		declare @idAzi INT = 0
		declare @idAggancio INT = 0

		OPEN curs2 
		FETCH NEXT FROM curs2 INTO @idAggancio, @idAzi, @isRTI

		WHILE @@FETCH_STATUS = 0   
		BEGIN  

			declare @PMI varchar(100) = ''

			IF @isRTI = 0
			BEGIN

				select top 1 @PMI = isnull(value,'si')
					from ctl_doc DGUE with(nolock)
							inner join ctl_doc_value DGUE_DETT  with(nolock) on DGUE_DETT.IdHeader = DGUE.id and DGUE_DETT.dse_id = 'MODULO' and DGUE_DETT.DZT_Name = @MA_DZT_NAME
					where DGUE.LinkedDoc = @idaggancio and DGUE.tipodoc='MODULO_TEMPLATE_REQUEST' and DGUE.Deleted=0

			END
			ELSE
			BEGIN

				select top 1 @PMI = isnull(value,'si')
					from ctl_doc RIC_COMP_DGUE with(nolock)
						--salgo sulla risposta alla  richiesta compilazione DGUE
						inner join ctl_doc RIS_RIC_COMP_DGUE with(nolock) on RIS_RIC_COMP_DGUE.LinkedDoc = RIC_COMP_DGUE.ID and RIS_RIC_COMP_DGUE.tipodoc='RICHIESTA_COMPILAZIONE_DGUE_RISPOSTA' and RIS_RIC_COMP_DGUE.Deleted=0 and RIS_RIC_COMP_DGUE.StatoFunzionale='Inviato'
						--salgo sul DGUE
						inner join ctl_doc DGUE with(nolock) on DGUE.LinkedDoc = RIS_RIC_COMP_DGUE.ID and DGUE.tipodoc='MODULO_TEMPLATE_REQUEST' and DGUE.Deleted=0
						--salgo sul contentuto del dgue
						inner join ctl_doc_value DGUE_DETT  with(nolock) on DGUE_DETT.IdHeader = DGUE.id and DGUE_DETT.dse_id = 'MODULO' and DGUE_DETT.DZT_Name = @MA_DZT_NAME
					where RIC_COMP_DGUE.id = @idaggancio and RIC_COMP_DGUE.tipodoc='RICHIESTA_COMPILAZIONE_DGUE' and RIC_COMP_DGUE.Deleted=0 and RIC_COMP_DGUE.StatoFunzionale='Inviata Risposta'					

			END

			update #tempAzi
					set PMI = @PMI
				where idazi = @idazi

			FETCH NEXT FROM curs2 INTO @idAggancio, @idAzi, @isRTI

		END  

		CLOSE curs2
		DEALLOCATE curs2

	END --IF @MA_DZT_NAME <> ''


	--recuperiamo il numero di organizzazioni inserite fino ad ora per partire dall'id ORG successivo
	declare @numOrgs INT
	select @numOrgs = count(*) from Document_E_FORM_ORGANIZATION with(nolock) where idheader = @idProc

	IF @debug = 1
		PRINT '@numOrgs = ' + CAST( @numOrgs as varchar )

	declare @vbcrlf varchar(10) = '
'

	-- INSERIAMO NELLA TABELLA TUTTI GLI OE NON ANCORA PRESENTI 
	--( SE AVEVANO GIÀ PARTECIPATO SU UN ALTRO LOTTO POTREBBERO ESSERE GIÀ PRESENTI )
	INSERT INTO Document_E_FORM_ORGANIZATION (idHeader, recordType, idazi,idOfferta,Ruolo_Impresa,PartyIdentification,fiscalNumber,PartyName,CityName,Telephone,
												ElectronicMail,Country, idaziRTI, RagSocRTI, RTI, telefax, postalCode, BuyerProfileURI )
		SELECT @idProc as idHeader,
				'aggiudicatari' as recordType,
				t.idazi,
				t.idOfferta,
				t.Ruolo_Impresa,
				'ORG-' + RIGHT('0000' + CAST( @numOrgs + ( ROW_NUMBER() OVER(ORDER BY t.idazi ASC) ) AS NVARCHAR(4)), 4) AS PartyIdentification,
				dm.vatValore_FT as fiscalNumber,
				left(aziRagioneSociale,400) as PartyName,
				left(aziLocalitaLeg,400) as CityName,
				aziTelefono1 as Telephone,
				aziE_Mail as ElectronicMail,
				case when dbo.getpos(isnull(azistatoleg2,''),'-',4) = '' then 'ITA' else dbo.getpos(isnull(azistatoleg2,''),'-',4) end as  Country,

				t.idaziRTI,
				t.RagSocRTI,
				t.RTI,

				aziFAX,
				aziCAPLeg,
				aziSitoWeb

			FROM #tempAzi T
					inner join aziende A with (nolock) on A.idazi = T.Idazi
					inner join dm_attributi DM with (nolock) on Dm.lnk=T.Idazi and DM.dztNome='codicefiscale' and dm.idapp = 1
					left join Document_E_FORM_ORGANIZATION org with(nolock) on 
						org.idHeader = @idProc and org.idazi = t.idazi and recordType = 'aggiudicatari' and org.idOfferta = t.idOfferta
			WHERE org.idRow is null -- oe aggiudicatario non ancora inserito
			ORDER BY t.RTI, t.idOfferta

	-- associo il guid ai record utili sulla document_e_form_organization, per poi recuperarli più avanti
	update Document_E_FORM_ORGANIZATION
			set operationGuid = @guidOperation
		from Document_E_FORM_ORGANIZATION org with(Nolock)
				inner join #tempAzi T on t.idazi = org.idAzi
		where org.idHeader = @idProc and recordType = 'aggiudicatari'

	--------------------------------------------------------------------------------
	-- RETTIFICO IL PartyIdentification assegnandolo in modo sequenziale corretto --
	--------------------------------------------------------------------------------
	DECLARE @idRowOrg INT = @numOrgs
	DECLARE @partyID varchar(100) = ''
	DECLARE @prevPartyID varchar(100) = ''
	DECLARE @cont INT = 0

	DECLARE cursOE CURSOR FAST_FORWARD FOR
		select org.idRow,PartyIdentification from Document_E_FORM_ORGANIZATION org with(nolock) where org.idHeader = @idProc and recordType = 'aggiudicatari' order by PartyIdentification

	OPEN cursOE 
	FETCH NEXT FROM cursOE INTO @idRowOrg, @partyID
	WHILE @@FETCH_STATUS = 0   
	BEGIN

		set @cont = @cont + 1

		--Se troviamo un PartyIdentification uguale al precedente iniziamo la rettifica
		IF @prevPartyID <> ''
		BEGIN

			IF @partyID = @prevPartyID
			BEGIN

				update Document_E_FORM_ORGANIZATION
						set PartyIdentification = 'ORG-' + RIGHT('0000' + CAST( @cont AS NVARCHAR(4)), 4)
					where idrow = @idRowOrg

				--forziamo un cambio per tutti i successivi
				SET @partyID = 'CAMBIO'

			END

		END

		SET @prevPartyID = @partyID

		FETCH NEXT FROM cursOE INTO @idRowOrg, @partyID

	END
	CLOSE cursOE
	DEALLOCATE cursOE

	SELECT DISTINCT PartyIdentification as ENTE_ID, 
			fiscalNumber as ENTE_NUMERO_REG, 
			isnull(PartyName,'') AS ENTE_RAG_SOC , 
			isnull(CityName,'') AS ENTE_LOCAL, 
			isnull(Telephone,'') AS ENTE_TEL,
			isnull(ElectronicMail,'') AS ENTE_EMAIL, 
			isnull(Country,'') AS ENTE_PAESE, 
			
			'<efbc:ListedOnRegulatedMarketIndicator>true</efbc:ListedOnRegulatedMarketIndicator>' AS OE_NO_ENCODE_WINNER,
			'' AS ENTE_NO_ENCODE_AWARDINGCPBINDICATOR,

			case isnull(T.PMI,'') 
					when '' then ''
					when 'si' then '<efbc:CompanySizeCode listName="economic-operator-size">sme</efbc:CompanySizeCode>'
					else '<efbc:CompanySizeCode listName="economic-operator-size">large</efbc:CompanySizeCode>' end
				as OE_NO_ENCODE_WINNER_SIZE,

			left(PartyName,400) as ENTE_CONTACT_NAME,

			case when telefax <> '' then '<!-- BT-739 - Fax -->' + @vbcrlf + '<cbc:Telefax>' + dbo.HTML_Encode(telefax) + '</cbc:Telefax>' else '' end AS ENTE_NO_ENCODE_FAX,
			
			case when postalCode <> '' then '<!-- BT-512 - Codice Postale -->' + @vbcrlf + '<cbc:PostalZone>' + dbo.HTML_Encode(postalCode) + '</cbc:PostalZone>' else '' end AS ENTE_NO_ENCODE_POSTAL_ZONE,

			case when BuyerProfileURI <> '' then '<!-- BT-508 - Buyer Profile URL -->' + @vbcrlf + '<cbc:BuyerProfileURI>' + LTRIM(RTRIM(LEFT(dbo.HTML_Encode(BuyerProfileURI),400))) + ' </cbc:BuyerProfileURI>' else '' end AS ENTE_NO_ENCODE_BUYERPROFILEURI

		from Document_E_FORM_ORGANIZATION org with(Nolock)
				inner join #tempAzi T on t.idazi = org.idAzi
		where org.idHeader = @idProc and recordType = 'aggiudicatari'
		order by ENTE_ID

	DROP TABLE #tempAzi
	DROP TABLE #offerteAgg
	DROP TABLE #lotti_agg_def

END
GO
