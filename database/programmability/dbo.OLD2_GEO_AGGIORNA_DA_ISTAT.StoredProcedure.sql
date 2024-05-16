USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GEO_AGGIORNA_DA_ISTAT]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_GEO_AGGIORNA_DA_ISTAT] ( @script nvarchar(max) = '' out, @attivaUpdate INT = 0 ) 
AS
BEGIN

	SET NOCOUNT ON

	-- il parametro opzionale @attivaUpdate (di default è 0) se passato ad 1 fa eseguire direttamente le update a questa stored
	-- invece di generare gli script, cosa che fa di default.


	-- GENERO LA TABELLA DI APPOGGIO PER VERIFICARE LA PRESENZA DI MODIFICHE AL DOMINIO GEO RISPETTO AD AGGIORNAMENTI ISTAT
	SELECT * INTO #NEW_GEO FROM LIB_DomainValues where DMV_DM_ID = 'NON_ESISTE'

	-- POPOLO LA TABELLA TEMPORANEA CON IL DOMINIO GEO GENERATO A PARTIRE DAI NUOVI DATI ISTAT
	insert into #NEW_GEO
		( DMV_DM_ID, DMV_Cod, DMV_Father, DMV_Level, DMV_DescML, DMV_Image, DMV_Sort, DMV_CodExt, DMV_Module )


		select  
			'GEO'			as DMV_DM_ID, 
			'M'	as DMV_Cod, 
			'M-' as DMV_Father, 
			0				as DMV_Level, 
			'Mondo' as DMV_DescML, 
			''				as DMV_Image, 
			0				as DMV_Sort, 
			'M' as DMV_CodExt,
			'GEO'			as DMV_Module

		union all
	
		-----------------------------------------
		-- CONTINENTI
		-------------------------------------------
		select  
			'GEO'			as DMV_DM_ID, 
			'M-' + CodContinente	as DMV_Cod, 
			'M-' + CodContinente + '-' 	as DMV_Father, 
			1				as DMV_Level, 
			Denominazione	as DMV_DescML, 
			''				as DMV_Image, 
			1				as DMV_Sort, 
			'M-' + CodContinente	as DMV_CodExt,
			'GEO'			as DMV_Module
		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			where C.CodContinente <> '6'

		union all

		-----------------------------------------
		-- CONTINENTI-AREE
		-----------------------------------------

		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + AC.CodArea	as DMV_Cod, 
			'M-' + C.CodContinente + '-' + AC.CodArea + '-' 	as DMV_Father, 
			2								as DMV_Level, 
			AC.Denominazione				as DMV_DescML, 
			''								as DMV_Image, 
			2								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + AC.CodArea	as DMV_CodExt,
			'GEO'							as DMV_Module

	
		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_CodiciStati_FoglioAree AC on C.CodContinente = left( AC.CodArea , 1 ) 
			where C.CodContinente <> '6'

		union all

		-----------------------------------------
		-- STATI
		-----------------------------------------
		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-'  as DMV_Father, 
			3								as DMV_Level, 
			R.unioneeuropea					as DMV_DescML, 
			--R.CommonName					as DMV_DescML, 
			''								as DMV_Image, 
			3								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 
			--inner join dbo.GEO_Elenco_Stati_ISO_3166_1 S on R.ISO_3166_1_3_LetterCode = S.ISO_3166_1_3_LetterCode and S.commonname = R.CommonName

		union all

		-- stati fittizzi per ogni AREA Continente 
		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + AC.CodArea + '-XXX' 	as DMV_Cod, 
			'M-' + C.CodContinente + '-' + AC.CodArea + '-XXX-' 	as DMV_Father, 
			3								as DMV_Level, 
			'Altro'					as DMV_DescML, 
			''								as DMV_Image, 
			3								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + AC.CodArea + '-XXX' as DMV_CodExt,
			'GEO'							as DMV_Module
	
		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_CodiciStati_FoglioAree AC on C.CodContinente = left( AC.CodArea , 1 ) 

		union all


		-----------------------------------------
		-- AREE
		-----------------------------------------

		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) + '-'  as DMV_Father, 
			4								as DMV_Level, 
			isnull( N.Name , RipartizioneGeografica ) 	as DMV_DescML, 
			''								as DMV_Image, 
			4								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 1 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

			left outer join ( select distinct  CodiceRipartizione , RipartizioneGeografica , CodiceNUTS1_2010
									from	GEO_ISTAT_ripartizioni_regioni_province 
									
							)		as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
			where N.Code is not null or G.CodiceNUTS1_2010 is not null

		union all

		-----------------------------------------
		-- REGIONI
		-----------------------------------------

		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 ) 
				as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 )  + '-' 
				as DMV_Father, 
			5								as DMV_Level, 
			isnull( N.Name , DenominazioneRegione ) 	as DMV_DescML, 
			''								as DMV_Image, 
			5								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 ) 
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 2 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

			left outer join ( select distinct  CodiceNUTS1_2010, DenominazioneRegione , CodiceNUTS2_2010
									from	GEO_ISTAT_ripartizioni_regioni_province 
									
							)		as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
			where N.Code is not null or G.CodiceNUTS1_2010 is not null


		union all

		-- altre regioni fittizie
		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) + '-XXX' as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) + '-XXX-'   as DMV_Father, 
			5								as DMV_Level, 
			'Altra Regione'				 	as DMV_DescML, 
			''								as DMV_Image, 
			5								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) + '-XXX' as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 1 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

			left outer join ( select distinct   RipartizioneGeografica , CodiceNUTS1_2010
									from	GEO_ISTAT_ripartizioni_regioni_province 
									
							)		as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
			where N.Code is not null or G.CodiceNUTS1_2010 is not null

		union all


		-----------------------------------------
		-- PROVINCIE
		-----------------------------------------

		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 ) 
				as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 )   + '-' 
				as DMV_Father, 
			6								as DMV_Level, 
			isnull( N.Name , DenominazioneProvincia ) 	as DMV_DescML, 
			''								as DMV_Image, 
			6								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 )  
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 3 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA'

			left outer join GEO_ISTAT_ripartizioni_regioni_province  as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
	
			where N.Code is not null or G.CodiceNUTS1_2010 is not null

		union all

		-- Altra Provincia fittizia
		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 ) + '-XXX'
				as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 )  + '-XXX-' 
				as DMV_Father, 
			6								as DMV_Level, 
			'Altra Provincia' 	as DMV_DescML, 
			''								as DMV_Image, 
			6								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 ) + '-XXX'
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 2 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

			left outer join ( select distinct  CodiceNUTS1_2010, DenominazioneRegione , CodiceNUTS2_2010
									from	GEO_ISTAT_ripartizioni_regioni_province 
									
							)		as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
			where N.Code is not null or G.CodiceNUTS1_2010 is not null

		union all

		-----------------------------------------
		-- COMUNI
		-----------------------------------------


		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +   G.CodiceNUTS1_2010 
			+ '-' + G.CodiceNUTS2_2010 + '-' + G.CodiceNUTS3_2010 + '-' + CO.CodiceIstatDelComune_formato_numerico
				as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +   G.CodiceNUTS1_2010 
			+ '-' + G.CodiceNUTS2_2010 + '-' + G.CodiceNUTS3_2010 + '-' + CO.CodiceIstatDelComune_formato_numerico + '-' 
				as DMV_Father, 
			7								as DMV_Level, 
			CO.SoloDenominazione_in_italiano as DMV_DescML, 
			''								as DMV_Image, 
			7								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +   G.CodiceNUTS1_2010 
			+ '-' + G.CodiceNUTS2_2010 + '-' + G.CodiceNUTS3_2010 + '-' + CO.CodiceIstatDelComune_formato_numerico
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			inner join GEO_ISTAT_ripartizioni_regioni_province  G on  R.ISO_3166_1_3_LetterCode = 'ITA'
			inner join GEO_ISTAT_elenco_comuni_italiani CO on  G.CodiceProvincia = CO.CodiceProvincia
	

		union all

		-- altri comuni fittizzi
		select  
			'GEO'							as DMV_DM_ID, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 ) + '-XXX'
				as DMV_Cod, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 )  + '-XXX-' 
				as DMV_Father, 
			7								as DMV_Level, 
			'Altro' 	as DMV_DescML, 
			''								as DMV_Image, 
			7								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 ) + '-XXX'
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 3 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA'

			inner join GEO_ISTAT_ripartizioni_regioni_province  as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
	
			where G.CodiceNUTS1_2010 is not null


		order by DMV_Father


		IF @attivaUpdate = 1
		BEGIN

			-- METTO A CANCELLATI LOGICAMENTE I RECORD DEL VECCHIO GEO NON PIU' PRESENTI NEL NUOVO GEO

			UPDATE LIB_DomainValues
				set DMV_Deleted = 1
				where id IN (
							SELECT old.id	
								FROM LIB_DomainValues old 
										LEFT JOIN #NEW_GEO new ON new.DMV_Cod = old.DMV_Cod  
								WHERE new.id is null and old.DMV_DM_ID = 'GEO'
						)

			-- RIPRISTINO RECORD PRECEDENTEMENTE MESSI A CANCELLATI LOGICAMENTE CHE INVECE ADESSO COMPAIONO NEI NUOVI DATI ISTAT
			UPDATE LIB_DomainValues
				set DMV_Deleted = 0
				where id IN (
							SELECT old.id	
								FROM LIB_DomainValues old 
										INNER JOIN #NEW_GEO new ON old.DMV_DM_ID = 'GEO' and new.DMV_Cod = old.DMV_Cod and old.DMV_Deleted = 1
						)

			-- AGGIUNGO I NUOVI RECORD
			INSERT INTO LIB_DomainValues (DMV_DM_ID, DMV_Cod, DMV_Father, DMV_Level, DMV_DescML, DMV_Image, DMV_Sort, DMV_CodExt, DMV_Module)
					SELECT NEW.DMV_DM_ID, NEW.DMV_Cod, NEW.DMV_Father, NEW.DMV_Level, NEW.DMV_DescML, NEW.DMV_Image, NEW.DMV_Sort, NEW.DMV_CodExt, NEW.DMV_Module
							FROM #NEW_GEO new 
									LEFT JOIN LIB_DomainValues old ON old.DMV_DM_ID = 'GEO' and new.DMV_Cod = old.DMV_Cod
							where old.id is null

		END
		ELSE
		BEGIN

			DECLARE @LISTA_ID varchar(max)
			DECLARE @SCRIPT_CANCELLA NVARCHAR(MAX)
			DECLARE @SCRIPT_RIPRISTINA NVARCHAR(MAX)
			DECLARE @SCRIPT_AGGIUNGI NVARCHAR(MAX)
			DECLARE @vbcrlf varchar(100)

			set @vbcrlf ='
			'

			SET @SCRIPT_CANCELLA = ''
			SET @SCRIPT_RIPRISTINA = ''
			SET @SCRIPT_AGGIUNGI = ''
			SET @LISTA_ID = ''

			SELECT @LISTA_ID = @LISTA_ID + cast(old.id as varchar(100)) + ','
				FROM LIB_DomainValues old 
						LEFT JOIN #NEW_GEO new ON new.DMV_Cod = old.DMV_Cod  
				WHERE new.id is null and old.DMV_DM_ID = 'GEO'

			IF @LISTA_ID <> ''
			BEGIN
				SET @LISTA_ID = LEFT(@LISTA_ID,LEN(@LISTA_ID)-1)
				SET @SCRIPT_CANCELLA = 'UPDATE LIB_DomainValues set DMV_Deleted = 1 where id IN (' + @LISTA_ID + ')'
				SET @LISTA_ID = ''
			END

			SELECT @LISTA_ID = @LISTA_ID + cast(old.id as varchar(100)) + ','
				FROM LIB_DomainValues old 
						INNER JOIN #NEW_GEO new ON old.DMV_DM_ID = 'GEO' and new.DMV_Cod = old.DMV_Cod and old.DMV_Deleted = 1
			
			IF @LISTA_ID <> ''
			BEGIN
				SET @LISTA_ID = LEFT(@LISTA_ID,LEN(@LISTA_ID)-1)
				SET @SCRIPT_RIPRISTINA = 'UPDATE LIB_DomainValues set DMV_Deleted = 0 where id IN (' + @LISTA_ID + ')'
				SET @LISTA_ID = ''
			END

			DECLARE @DMV_DM_ID VARCHAR(500)
			DECLARE @DMV_Cod VARCHAR(500)
			DECLARE @DMV_Father VARCHAR(500)
			DECLARE @DMV_Level INT
			DECLARE @DMV_DescML VARCHAR(500)
			DECLARE @DMV_Image VARCHAR(500)
			DECLARE @DMV_Sort INT
			DECLARE @DMV_CodExt VARCHAR(500)
			DECLARE @DMV_Module VARCHAR(500)


			DECLARE curs CURSOR STATIC FOR     
						SELECT NEW.DMV_DM_ID, NEW.DMV_Cod, NEW.DMV_Father, NEW.DMV_Level, NEW.DMV_DescML, NEW.DMV_Image, NEW.DMV_Sort, NEW.DMV_CodExt, NEW.DMV_Module
							FROM #NEW_GEO new 
									LEFT JOIN LIB_DomainValues old ON old.DMV_DM_ID = 'GEO' and new.DMV_Cod = old.DMV_Cod
							where old.id is null


			OPEN curs 
			FETCH NEXT FROM curs INTO @DMV_DM_ID,@DMV_Cod,@DMV_Father,@DMV_Level,@DMV_DescML,@DMV_Image,@DMV_Sort,@DMV_CodExt,@DMV_Module

			WHILE @@FETCH_STATUS = 0   
			BEGIN  
	
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + 'INSERT INTO LIB_DomainValues (DMV_DM_ID, DMV_Cod, DMV_Father, DMV_Level, DMV_DescML, DMV_Image, DMV_Sort, DMV_CodExt, DMV_Module)' + @vbcrlf
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + '	VALUES (''' + isnull(@DMV_DM_ID,'') + ''',''' + isnull(@DMV_Cod,'') + ''',''' + isnull(@DMV_Father,'') + ''',' + CAST(isnull(@DMV_Level,0) AS VARCHAR(10)) + ',''' + replace(isnull(@DMV_DescML,''),'''','''''') + ''',''' + isnull(@DMV_Image,'') + ''',' + CAST(isnull(@DMV_Sort,0) AS VARCHAR(10)) + ',''' + isnull(@DMV_CodExt,'') + ''',''' + isnull(@DMV_Module,'') + ''')' + @vbcrlf

				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + @vbcrlf + @vbcrlf

				FETCH NEXT FROM curs INTO @DMV_DM_ID,@DMV_Cod,@DMV_Father,@DMV_Level,@DMV_DescML,@DMV_Image,@DMV_Sort,@DMV_CodExt,@DMV_Module

			END  


			CLOSE curs   
			DEALLOCATE curs

			-- COMPONGO LO SCRIPT FINALE SE CI SONO DATI VARIATI

			IF @SCRIPT_CANCELLA <> '' or  @SCRIPT_RIPRISTINA <> '' or @SCRIPT_AGGIUNGI <> ''
				SET @script = @SCRIPT_CANCELLA + @vbcrlf + @vbcrlf + @SCRIPT_RIPRISTINA + @vbcrlf + @vbcrlf + @SCRIPT_AGGIUNGI

		END
					
						
END



GO
