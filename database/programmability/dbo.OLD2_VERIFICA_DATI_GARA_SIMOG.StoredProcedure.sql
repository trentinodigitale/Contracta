USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_VERIFICA_DATI_GARA_SIMOG]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_VERIFICA_DATI_GARA_SIMOG] ( @gara int , @IdUser int )
AS
BEGIN

--	declare @gara int
--  set @gara = 402508

	SET NOCOUNT ON

	declare @idRic INT

	declare @oggettoGara nvarchar(max)
	declare @cpvGara varchar(500)
	declare @luogoIstatGara varchar(500)
	declare @luogoNutsGara varchar(500)

	DECLARE @oggettoGaraSimog nvarchar(max)

	declare @numerogaraCIG varchar(100)
	declare @divisioneLotti varchar(10)

	declare @esitoRiga nvarchar(max)
	declare @bUpdateEsito int
	declare @FLAG_SYNC varchar(100)

	
	DECLARE @constErr varchar(500)

	IF dbo.PARAMETRI('SIMOG', 'SIMOG_GET','BLOCCANTE','NO',-1) = 'YES'
	BEGIN
--		set @constErr = '<br/><img src="../images/Domain/State_ERR.gif">'
		set @constErr = '<br>'
	END
	ELSE
	BEGIN
		set @constErr = '<br><img src="../images/Domain/State_Warning.gif">'
	END


	set @bUpdateEsito = 0
	set @esitoRiga = ''
	set @idRic = -1

	select @esitoRiga = isnull(value,'') from CTL_DOC_VALUE with(nolock) where idHeader = @gara and DZT_Name = 'EsitoRiga' and DSE_ID = 'TESTATA_PRODOTTI' 

	select @FLAG_SYNC = value from CTL_DOC_Value with(nolock) where IdHeader = @gara and DSE_ID = 'SIMOG_GET' and DZT_Name = 'FLAG_SYNC'

	DELETE CTL_DOC_Value where IdHeader = @gara and DSE_ID = 'SIMOG_GET' and DZT_Name = 'ERROR'

	--recupero l'ultima richiesta_cig inviata/recuperata con successo ( dovrebbe essercene sempre solo 1 con lo stato di inviato )
	select top 1 @idRic = id from ctl_doc with(nolock) where linkeddoc = @gara and TipoDoc = 'RICHIESTA_CIG' and Deleted = 0 and StatoFunzionale = 'Inviato' and versione = 'SIMOG_GET' order by id desc

	IF @idRic > 0 
	BEGIN

		DECLARE @errore nvarchar(max)

		declare @importoBaseAsta FLOAT
		
		set @errore = ''
		set @luogoIstatGara = ''
		set @luogoNutsGara = ''
		set @cpvGara = ''
		set @oggettoGara = ''

		select	 @numerogaraCIG = CIG
				,@divisioneLotti = Divisione_lotti 
				--,@importoBaseAsta2 = round(importoBaseAsta2, 2, 1)
				--,@importoBaseAsta = round(importoBaseAsta, 2, 1)
				,@importoBaseAsta = importoBaseAsta
			from Document_Bando with(nolock) 
			where idHeader = @gara


		--recupero i dati della gara da confrontare
		select  @luogoIstatGara = case when geo.DMV_Level = 7 then RIGHT( '0000' + dbo.GetColumnValue( g.value,'-', 8), 6) else '' end, -- Se si è selezionato un nodo di livello comune / 7 prendo il codice istat dalla sua ultima parte dmv_cod
				@luogoNutsGara  = case when geo.DMV_Level = 6 then dbo.GetColumnValue( g.value,'-', 7)	-- se si è scelto una provincia prendo il suo codice NUTS
									   when geo.DMV_Level = 5 then dbo.GetColumnValue( g.value,'-', 6)	-- se si è scelta una regione prendo il suo codice NUTS
									   else '' end
			from ctl_doc_value g with(nolock) 
					left join LIB_DomainValues geo with(nolock) on geo.DMV_DM_ID = 'GEO' and geo.DMV_Cod = g.Value
			where idheader = @gara and dse_id = 'InfoTec_SIMOG' and dzt_name = 'COD_LUOGO_ISTAT' 

		--select @cpvGara = isnull(cpv.DMV_CodExt,'') 
		select @cpvGara = isnull(cpv.DMV_Cod,'') 
			from ctl_doc_value v with(nolock) 
					left join LIB_DomainValues cpv with(nolock) on cpv.DMV_DM_ID = 'CODICE_CPV' and cpv.DMV_Deleted = 0 and cpv.DMV_Cod = v.value
			where v.idheader = @gara and v.dse_id = 'InfoTec_SIMOG' and v.dzt_name = 'CODICE_CPV' 

		select @oggettoGara = REPLACE( left(dbo.NormStringExt(body,''),1000) , '  ', ' ') from CTL_DOC with(nolock) where id = @gara
		select @oggettoGaraSimog = REPLACE( left(dbo.NormStringExt(body,''),1000), '  ', ' ') from CTL_DOC with(nolock) where id = @idRic

		-------------------------
		-- CONTROLLO DATI GARA --
		-------------------------
		IF @oggettoGara <> @oggettoGaraSimog
		BEGIN

			set @esitoRiga = @esitoRiga + @constErr + 'SIMOG: L''oggetto della gara non coincide con quanto presente in ANAC : "' + @oggettoGaraSimog + '"'

			set @bUpdateEsito = 1

		END


		-- il @luogoIstatGara a seconda del livello GEO selezionato va confrontato con SYNC_LUOGO_ISTAT o con SYNC_LUOGO_NUTS
		-- i @cpvGara va confrontato con tutti i cpv sui lotti

		DECLARE @idRow INT
		declare @cigLotto varchar(100)
		declare @numeroLotto varchar(100)
		declare @oggettoLotto nvarchar(1000)
		declare @importoLotto FLOAT
		declare @importoOpzioni FLOAT
		declare @importoSicurezza FLOAT

		select  idrow, 
				replace(left(dbo.NormStringExt(OGGETTO,''),1000), '  ', ' ') as oggetto, 
				--round( convert(float, IMPORTO_LOTTO) , 2, 1) as IMPORTO_LOTTO,
				convert(float, IMPORTO_LOTTO) as IMPORTO_LOTTO,
				SYNC_LUOGO_ISTAT, 
				sync_luogo_nuts, 
				NumeroLotto,
				CPV, 
				CIG,
				--round( convert(float, IMPORTO_OPZIONI) , 2, 1) as IMPORTO_OPZIONI,
				--round( convert(float, IMPORTO_ATTUAZIONE_SICUREZZA) , 2, 1) as IMPORTO_ATTUAZIONE_SICUREZZA
				convert(float, IMPORTO_OPZIONI) as IMPORTO_OPZIONI,
				convert(float, IMPORTO_ATTUAZIONE_SICUREZZA) as IMPORTO_ATTUAZIONE_SICUREZZA
			into #dati_simog_lotti 
			from Document_SIMOG_LOTTI with(nolock)
			where idheader = @idRic

		--SE MULTILOTTO
		IF @divisioneLotti <> '0'
		BEGIN

			declare @totLottiSIMOG int
			declare @totLottiGara int

			select @totLottiSIMOG = COUNT(*) from #dati_simog_lotti

			select @totLottiGara = COUNT(*)
				from ctl_doc b with(nolock) 
						inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0
						inner join #dati_simog_lotti l on l.CIG = d.CIG
				where b.id = @gara

			if @totLottiSIMOG <> @totLottiGara
			begin

				set @bUpdateEsito = 1
				--set @esitoRiga = @esitoRiga + '<br/><br/>SIMOG: Il numero dei CIG validi non coincide con quanto presente in anac ( ' + cast(@totLottiGara as varchar) + '~' + CAST( @totLottiSIMOG as varchar ) + ' )'
				---set @esitoRiga = @esitoRiga + '<br/><br/>SIMOG: Il numero dei CIG validi non coincide con quanto presente in anac'
				set @esitoRiga = @esitoRiga + @constErr + 'SIMOG:Nell''Elenco Prodotti devono essere presenti i soli CIG presenti nel SIMOG'

			end

			--recupero i dati dei lotti da confrontare
			DECLARE curs CURSOR FAST_FORWARD FOR
				select d.id,
						d.CIG,
						NumeroLotto, -- il numero lotto non va usato per andare in match. non avendo il numerolotto in simog
						REPLACE( left(dbo.NormStringExt(descrizione,''),1000), '  ',' ') as [OGGETTO], 
						--round(d.ValoreImportoLotto, 2, 1)			as [IMPORTO_LOTTO],
						--round( convert(float, IMPORTO_OPZIONI) , 2, 1) as IMPORTO_OPZIONI,
						--round( convert(float, IMPORTO_ATTUAZIONE_SICUREZZA) , 2, 1) as IMPORTO_ATTUAZIONE_SICUREZZA
						d.ValoreImportoLotto 			as [IMPORTO_LOTTO],
						convert(float, IMPORTO_OPZIONI) as IMPORTO_OPZIONI,
						convert(float, IMPORTO_ATTUAZIONE_SICUREZZA) as IMPORTO_ATTUAZIONE_SICUREZZA
					from ctl_doc b with(nolock) 
							inner join Document_MicroLotti_Dettagli d with(nolock) on d.IdHeader = b.id and b.TipoDoc = d.TipoDoc and d.voce = 0 
					where b.id = @gara and d.CIG <> ''

			OPEN curs 
			FETCH NEXT FROM curs INTO @idRow, @cigLotto, @numeroLotto, @oggettoLotto, @importoLotto, @importoOpzioni, @importosicurezza

			WHILE @@FETCH_STATUS = 0   
			BEGIN

				IF EXISTS ( select idrow from #dati_simog_lotti where cig = @cigLotto )
				BEGIN

					UPDATE Document_MicroLotti_Dettagli
							set EsitoRiga = EsitoRiga + case when @oggettoLotto <> l.oggetto then @constErr + 'SIMOG: La descrizione non coincide con "' + l.oggetto + '" presente nel documento ''Recupero dati SIMOG''' else '' end + 
														case when dbo.AF_FormatNumber(@importoLotto,2) <> dbo.AF_FormatNumber( ( l.IMPORTO_LOTTO - isnull(l.IMPORTO_OPZIONI,0) - isnull(l.IMPORTO_ATTUAZIONE_SICUREZZA,0) ),2 )   then @constErr + 'SIMOG: L''importo non coincide con "' + dbo.AF_FormatNumber( ( ( l.IMPORTO_LOTTO - isnull(l.IMPORTO_OPZIONI,0) - isnull(l.IMPORTO_ATTUAZIONE_SICUREZZA,0) ) ), 2)  + '" presente nel documento ''Recupero dati SIMOG' else '' end +
														case when isnull(@luogoIstatGara,'') <> '' and ISNULL(l.SYNC_LUOGO_ISTAT,'') <> '' and @luogoIstatGara <> l.SYNC_LUOGO_ISTAT then @constErr + 'SIMOG: Luogo istat ( informazioni tecniche ) non coincidente con ISTAT "' + l.SYNC_LUOGO_ISTAT  + '"' else '' end +
														case when isnull(@luogoNutsGara,'') <> '' and ISNULL(l.SYNC_LUOGO_NUTS,'') <> '' and @luogoNutsGara <> l.SYNC_LUOGO_NUTS then @constErr + 'SIMOG: Luogo istat ( informazioni tecniche ) non coincidente con NUTS "' + l.SYNC_LUOGO_NUTS  + '"' else '' end + 
														case when isnull(@cpvGara,'') <> '' and ISNULL(l.CPV,'') <> '' and  @cpvGara <> l.CPV then @constErr + 'SIMOG: CPV ( informazioni tecniche ) non coincidente con  "' + l.CPV  + '" presente nel documento ''Recupero SIMOG''' else '' end +
														case when @importoOpzioni is not null and  dbo.AF_FormatNumber( @importoOpzioni,2 )<> dbo.AF_FormatNumber(l.IMPORTO_OPZIONI,2) then @constErr + 'SIMOG: L''Importo di cui per opzioni non coincide con "' + str( l.IMPORTO_OPZIONI )  + '" presente nel documento ''Recupero dati SIMOG' else '' end +
														case when @importosicurezza is not null and dbo.AF_FormatNumber(@importosicurezza,2 ) <> dbo.AF_FormatNumber( l.IMPORTO_ATTUAZIONE_SICUREZZA,2) then @constErr + 'SIMOG: L''Importo di cui oneri per la Sicurezza non coincide con "' + str( l.IMPORTO_ATTUAZIONE_SICUREZZA )  + '" presente nel documento ''Recupero dati SIMOG' else '' end 
						from Document_MicroLotti_Dettagli m with(nolock)
								inner join #dati_simog_lotti l on l.CIG = m.CIG
						where id = @idRow

				END
				ELSE
				BEGIN

					UPDATE Document_MicroLotti_Dettagli
							--set EsitoRiga = EsitoRiga + '<br/>SIMOG: CIG non presente per il N. di Gara Autorità ' + @numerogaraCIG
							set EsitoRiga = EsitoRiga + @constErr + 'SIMOG: Cig non presente nell''elenco lotti del documento ''Recupero dati SIMOG'''
						where id = @idRow

				END


				FETCH NEXT FROM curs INTO @idRow, @cigLotto, @numeroLotto, @oggettoLotto, @importoLotto, @importoOpzioni, @importosicurezza

			END  

			CLOSE curs   
			DEALLOCATE curs

			IF EXISTS ( select top 1 id from Document_MicroLotti_Dettagli with(nolock) where IdHeader = @gara and EsitoRiga like '%SIMOG:%' )
				INSERT INTO CTL_DOC_VALUE( IdHeader, DSE_ID, DZT_Name, value) values ( @gara, 'SIMOG_GET' , 'ERROR' , '1' )

		END
		ELSE -- SE MONOLOTTO
		BEGIN

			declare @esitoMonolotto nvarchar(max)

			set @esitoMonolotto = ''

			--case when @importoBaseAsta2 <> ( IMPORTO_LOTTO - isnull(IMPORTO_ATTUAZIONE_SICUREZZA,0) - isnull(IMPORTO_OPZIONI,0) ) then @constErr + 'SIMOG: L''importo ' + str(@importoBaseAsta2) + ' non coincide con il valore presente in ANAC ' + str( importo_lotto - isnull(IMPORTO_ATTUAZIONE_SICUREZZA,0) - isnull(IMPORTO_OPZIONI,0)  ) else '' end +
			select @esitoMonolotto = case when dbo.AF_FormatNumber( @importoBaseAsta, 2 ) <> dbo.AF_FormatNumber(IMPORTO_LOTTO , 2) then @constErr + 'SIMOG: L''importo ' + dbo.AF_FormatNumber(@importoBaseAsta,2) + ' non coincide con il valore presente in ANAC ' + dbo.AF_FormatNumber(importo_lotto,2) else '' end +
									 case when isnull(@luogoIstatGara,'') <> '' and ISNULL(l.SYNC_LUOGO_ISTAT,'') <> '' and @luogoIstatGara <> l.SYNC_LUOGO_ISTAT then @constErr + 'SIMOG: Luogo istat ( informazioni tecniche ) non coincidente con ISTAT "' + l.SYNC_LUOGO_ISTAT  + '"' else '' end +
								     case when isnull(@luogoNutsGara,'') <> '' and ISNULL(l.SYNC_LUOGO_NUTS,'') <> '' and @luogoNutsGara <> l.SYNC_LUOGO_NUTS then @constErr + 'SIMOG: Luogo istat ( informazioni tecniche ) non coincidente con NUTS "' + l.SYNC_LUOGO_NUTS  + '"' else '' end + 
									 case when isnull(@cpvGara,'') <> '' and ISNULL(l.CPV,'') <> '' and  @cpvGara <> l.CPV then @constErr + 'SIMOG: CPV ( informazioni tecniche ) non coincidente con  "' + l.CPV  + '"' else '' end 
				from #dati_simog_lotti l


			if @esitoMonolotto <> ''
			begin
				set @esitoRiga = @esitoRiga + @esitoMonolotto
				set @bUpdateEsito = 1 
			end

		END

	END --ELSE se presente documento richiesta_cig
	ELSE
	BEGIN

		IF @FLAG_SYNC = 'InCorso' 
		begin
			set @bUpdateEsito = 1
			set @esitoRiga = @esitoRiga + @constErr + 'SIMOG: Recupero dati SIMOG in corso. Si ricorda che per l''invio della procedura è necessario che i dati sul SIMOG siano stati pubblicati'
		end

		IF @FLAG_SYNC = 'InErrore' 
		begin
			set @bUpdateEsito = 1
			set @esitoRiga = @esitoRiga + @constErr + 'SIMOG: Recuperato dati SIMOG in errore'
		end

	END

	IF @bUpdateEsito = 1 and isnull(@esitoRiga,'') <> ''
	BEGIN

		DELETE FROM CTL_DOC_VALUE where idHeader = @gara and DZT_Name = 'EsitoRiga' and DSE_ID = 'TESTATA_PRODOTTI' 
		INSERT INTO CTL_DOC_VALUE( IdHeader, DSE_ID, DZT_Name, value) values ( @gara, 'TESTATA_PRODOTTI' , 'EsitoRiga' , isnull(@esitoRiga,'') )

		INSERT INTO CTL_DOC_VALUE( IdHeader, DSE_ID, DZT_Name, value) values ( @gara, 'SIMOG_GET' , 'ERROR' , '1' )

	END


END
GO
