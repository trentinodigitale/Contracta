USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GEO_AGGIORNA_DA_ISTAT]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  PROCEDURE [dbo].[GEO_AGGIORNA_DA_ISTAT] ( @script nvarchar(max) = '' out, @attivaUpdate INT = 0, @rettifica_import INT = 0, @genera_attivita_intranet INT = 1 ) 
AS
BEGIN

	SET NOCOUNT ON

	-- il parametro opzionale @attivaUpdate (di default è 0) se passato ad 1 fa eseguire direttamente le update a questa stored
	-- invece di generare gli script, cosa che fa di default.

	DECLARE @NEW_ID INT

	set @NEW_ID = null

	
	--costruiamo una tabella temporanea delle province che desumiamo dalla tabella dei comuni	
	--e sostituisce la tabella GEO_ISTAT_ripartizioni_regioni_province che non viene aggiornata dalll'integrazione
	select  CodiceRipartizioneGeografica as  CodiceRipartizione,RipartizioneGeografica,CodiceNUTS1_2010, 
			DenominazioneRegione, CodiceNUTS2_2010, CodiceNUTS3_2010, CodiceProvincia, DenominazioneProvincia
		into #GEO_ISTAT_ripartizioni_regioni_province
		from GEO_ISTAT_elenco_comuni_italiani_temp where ComuneCapoluogoDiProvincia<>0 

	
	
	--rettifico il codice per la regione "trentino alto adige...." che è un eccezione
	update #GEO_ISTAT_ripartizioni_regioni_province set CodiceNUTS2_2010= '-' where DenominazioneRegione='Trentino-Alto Adige/Südtirol'
	

	IF @rettifica_import = 1
	BEGIN

		--http://www.istat.it/it/archivio/6789
		UPDATE GEO_ISTAT_elenco_comuni_italiani_temp
			SET codiceregione = cast( cast(codiceregione as int) as varchar(10) )
				, CodiceProvincia = cast( cast(CodiceProvincia as int) as varchar(10) )
				, CodiceComune = cast( cast(CodiceComune as int) as varchar(10) )
				, CodiceIstatDelComune_formato_alfanumerico = cast( cast(CodiceIstatDelComune_formato_alfanumerico as int) as varchar(10) )

	END

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
			'folder.gif'				as DMV_Image, 
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
			'folder.gif'								as DMV_Image, 
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
			'folder.gif'								as DMV_Image, 
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
			'folder.gif'								as DMV_Image, 
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
			'folder.gif'								as DMV_Image, 
			4								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 1 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

			left outer join ( 
							
							select distinct  CodiceRipartizione , RipartizioneGeografica , CodiceNUTS1_2010
									from	#GEO_ISTAT_ripartizioni_regioni_province 
									 
									
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
			'folder.gif'								as DMV_Image, 
			5								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 ) 
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			left outer join GEO_NUTS N on N.Level = 2 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

			left outer join ( 
								
								select distinct  CodiceNUTS1_2010, DenominazioneRegione , CodiceNUTS2_2010
									from	#GEO_ISTAT_ripartizioni_regioni_province 
								
									
							)		as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
			where N.Code is not null or G.CodiceNUTS1_2010 is not null


		union all

		-- altre regioni fittizie
		--select  
		--	'GEO'							as DMV_DM_ID, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) + '-XXX' as DMV_Cod, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) + '-XXX-'   as DMV_Father, 
		--	5								as DMV_Level, 
		--	'Altra Regione'				 	as DMV_DescML, 
		--	'folder.gif'								as DMV_Image, 
		--	5								as DMV_Sort, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( N.code , G.CodiceNUTS1_2010 ) + '-XXX' as DMV_CodExt,
		--	'GEO'							as DMV_Module

		--from 
		--	dbo.GEO_CodiciStati_FoglioContinenti C
		--	inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

		--	left outer join GEO_NUTS N on N.Level = 1 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

		--	left outer join ( select distinct   RipartizioneGeografica , CodiceNUTS1_2010
		--							from	GEO_ISTAT_ripartizioni_regioni_province 
									
		--					)		as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
		--	where N.Code is not null or G.CodiceNUTS1_2010 is not null

		--union all


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
			'folder.gif'								as DMV_Image, 
			6								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
			+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 )  
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C

				inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

				left outer join GEO_NUTS N on N.Level = 3 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA'  and substring( code ,3,3) not like '%Z%'

				left outer join #GEO_ISTAT_ripartizioni_regioni_province  as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
				

			where N.Code is not null or G.CodiceNUTS1_2010 is not null

		union all

		-- Altra Provincia fittizia
		--select  
		--	'GEO'							as DMV_DM_ID, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
		--	+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 ) + '-XXX'
		--		as DMV_Cod, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
		--	+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 )  + '-XXX-' 
		--		as DMV_Father, 
		--	6								as DMV_Level, 
		--	'Altra Provincia' 	as DMV_DescML, 
		--	'folder.gif'								as DMV_Image, 
		--	6								as DMV_Sort, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
		--	+ '-' + isnull(  N.code   , G.CodiceNUTS2_2010 ) + '-XXX'
		--		as DMV_CodExt,
		--	'GEO'							as DMV_Module

		--from 
		--	dbo.GEO_CodiciStati_FoglioContinenti C
		--	inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

		--	left outer join GEO_NUTS N on N.Level = 2 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA' and substring( code ,3,3) not like '%Z%'

		--	left outer join ( select distinct  CodiceNUTS1_2010, DenominazioneRegione , CodiceNUTS2_2010
		--							from	GEO_ISTAT_ripartizioni_regioni_province 
									
		--					)		as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
		--	where N.Code is not null or G.CodiceNUTS1_2010 is not null

		--union all

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
			'node.gif'								as DMV_Image, 
			7								as DMV_Sort, 
			'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +   G.CodiceNUTS1_2010 
			+ '-' + G.CodiceNUTS2_2010 + '-' + G.CodiceNUTS3_2010 + '-' + CO.CodiceIstatDelComune_formato_numerico
				as DMV_CodExt,
			'GEO'							as DMV_Module

		from 
			dbo.GEO_CodiciStati_FoglioContinenti C
			inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

			inner join #GEO_ISTAT_ripartizioni_regioni_province  G on  R.ISO_3166_1_3_LetterCode = 'ITA'
			inner join GEO_ISTAT_elenco_comuni_italiani_temp CO on  G.CodiceProvincia = CO.CodiceProvincia
		--where CO.SoloDenominazione_in_italiano like '%Sermide%'

		--union all

		---- altri comuni fittizzi
		--select  
		--	'GEO'							as DMV_DM_ID, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
		--	+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 ) + '-XXX'
		--		as DMV_Cod, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
		--	+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 )  + '-XXX-' 
		--		as DMV_Father, 
		--	7								as DMV_Level, 
		--	'Altro' 	as DMV_DescML, 
		--	'node.gif'								as DMV_Image, 
		--	7								as DMV_Sort, 
		--	'M-' + C.CodContinente + '-' + R.CodArea + '-' + R.ISO_3166_1_3_LetterCode + '-' +  isnull( left( N.code , 3 )  , G.CodiceNUTS1_2010 ) 
		--	+ '-' + isnull(  left( N.code , 4 )   , G.CodiceNUTS2_2010 ) + '-' + isnull(  N.code   , G.CodiceNUTS3_2010 ) + '-XXX'
		--		as DMV_CodExt,
		--	'GEO'							as DMV_Module

		--from 
		--	dbo.GEO_CodiciStati_FoglioContinenti C
		--	inner join dbo.GEO_RaccordoStati R on C.CodContinente = R.CodContinente 

		--	left outer join GEO_NUTS N on N.Level = 3 and  R.Nuts = left( N.Code , 2 ) and R.ISO_3166_1_3_LetterCode  <> 'ITA'

		--	inner join GEO_ISTAT_ripartizioni_regioni_province  as G on  R.ISO_3166_1_3_LetterCode = 'ITA'
	
		--	where G.CodiceNUTS1_2010 is not null

		--order by DMV_Father

		---
		-- aggiungo tutti gli 'altro' fino a completare la gerarchia per avere tutti i rami fino al livello 7
		----
		insert into #NEW_GEO (		 DMV_DM_ID, DMV_Cod, DMV_Father, DMV_Level, DMV_DescML, DMV_Image, DMV_Sort, DMV_CodExt, DMV_Module )
			select a.DMV_DM_ID, a.DMV_Cod, a.DMV_Father, a.DMV_Level, a.DMV_DescML, a.DMV_Image, a.DMV_Sort, a.DMV_CodExt, a.DMV_Module
				from LIB_DomainValues a 
						left join #NEW_GEO b on b.DMV_Cod = a.DMV_Cod
				where a.dmv_dm_id = 'GEO' and b.dmv_cod is null and a.DMV_Father like '%-XXX-%' and a.dmv_level > 3 
					 and left(a.dmv_cod,11) <> 'M-1-11-ITA-'
		

		--select * from #NEW_GEO where DMV_DM_ID='GEO' and 	
		--	left(dmv_cod,11) = 'M-1-11-ITA-' and right(dmv_cod,4)='-XXX'
		--return;

		---------------------------------------------------------------------------------
		--- inizio aggiornamento tabella  GEO_ISTAT_elenco_comuni_italiani
		---------------------------------------------------------------------------------

		-- CANCELLAZIONE
		-- genera le stringhe per SQL dinamico
		declare @lista_comuni_delete varchar(max)
		declare @lista_comuni_delete_descr varchar(max)

		set @lista_comuni_delete=''
		set @lista_comuni_delete_descr = ''

		select @lista_comuni_delete=@lista_comuni_delete + '''' + CodiceIstatDelComune_formato_alfanumerico + ''','
			from  GEO_ISTAT_elenco_comuni_italiani
				where deleted=0 and CodiceIstatDelComune_formato_alfanumerico not IN (
								SELECT CodiceIstatDelComune_formato_alfanumerico	
									FROM GEO_ISTAT_elenco_comuni_italiani_temp										
							)

		if @lista_comuni_delete<>''
		begin
			set @lista_comuni_delete=substring(@lista_comuni_delete,1,len(@lista_comuni_delete)-1)
			set @lista_comuni_delete_descr = @lista_comuni_delete
			set @lista_comuni_delete='update GEO_ISTAT_elenco_comuni_italiani set deleted=1 where CodiceIstatDelComune_formato_alfanumerico in (' + @lista_comuni_delete + ')'
		end


		


		-- INSERIMENTO
		-- genera sql dinamico
		declare @lista_comuni_insert nvarchar(max)
		declare @lista_comuni_insert_descr nvarchar(max)
		declare @CodiceRegione nvarchar(max)
		declare @CodiceCittaMetropolitana nvarchar(max)
		declare @CodiceProvincia nvarchar(max)
		declare @CodiceComune nvarchar(max)
		declare @CodiceIstatDelComune_formato_alfanumerico nvarchar(max)
		declare @SoloDenominazione_in_italiano nvarchar(max)
		declare @SoloDenominazione_in_tedesco nvarchar(max)
		declare @CodiceRipartizioneGeografica nvarchar(max)
		declare @RipartizioneGeografica nvarchar(max)
		declare @DenominazioneRegione nvarchar(max)
		declare @DenominazioneCittaMetropolitana nvarchar(max)
		declare @DenominazioneProvincia nvarchar(max)
		declare @ComuneCapoluogoDiProvincia nvarchar(max)
		declare @SiglaAuto nvarchar(max)
		declare @CodiceIstatDelComune_formato_numerico nvarchar(max)
		declare @CodiceIstatDelComune_a_110_province_formato_numerico nvarchar(max)
		declare @CodiceIstatDelComune_a_107_province_formato_numerico nvarchar(max)
		declare @CodiceIstatDelComune_a_103_province_formato_numerico nvarchar(max)
		declare @CodiceCatastale nvarchar(max)
		declare @Popolazionelegale_2011 nvarchar(max)
		declare @CodiceNUTS1_2010 nvarchar(max)
		declare @CodiceNUTS2_2010 nvarchar(max)
		declare @CodiceNUTS3_2010 nvarchar(max)
		declare @CodiceNUTS1_2006 nvarchar(max)
		declare @CodiceNUTS2_2006 nvarchar(max)
		declare @CodiceNUTS3_2006 nvarchar(max)
	

		declare @temp nvarchar(max)


		set @lista_comuni_insert=''
		set @lista_comuni_insert_descr=''

		if exists(select *
					from  GEO_ISTAT_elenco_comuni_italiani_temp
						where CodiceIstatDelComune_formato_alfanumerico not IN (
										SELECT CodiceIstatDelComune_formato_alfanumerico	
											FROM GEO_ISTAT_elenco_comuni_italiani
									)
					)

		begin
				DECLARE cursGEOINS CURSOR STATIC FOR     
								SELECT 
									[CodiceRegione], [CodiceCittaMetropolitana], [CodiceProvincia], [CodiceComune], [CodiceIstatDelComune_formato_alfanumerico], [SoloDenominazione_in_italiano], [SoloDenominazione_in_tedesco], [CodiceRipartizioneGeografica], [RipartizioneGeografica], [DenominazioneRegione], [DenominazioneCittaMetropolitana], [DenominazioneProvincia], [ComuneCapoluogoDiProvincia], [SiglaAuto], [CodiceIstatDelComune_formato_numerico], [CodiceIstatDelComune_a_110_province_formato_numerico], [CodiceIstatDelComune_a_107_province_formato_numerico], [CodiceIstatDelComune_a_103_province_formato_numerico], [CodiceCatastale], [Popolazionelegale_2011], [CodiceNUTS1_2010], [CodiceNUTS2_2010], [CodiceNUTS3_2010], [CodiceNUTS1_2006], [CodiceNUTS2_2006], [CodiceNUTS3_2006]
									from  GEO_ISTAT_elenco_comuni_italiani_temp
						where CodiceIstatDelComune_formato_alfanumerico not IN (
										SELECT CodiceIstatDelComune_formato_alfanumerico	
											FROM GEO_ISTAT_elenco_comuni_italiani
									)


					OPEN cursGEOINS 
					FETCH NEXT FROM cursGEOINS INTO  @CodiceRegione , @CodiceCittaMetropolitana , @CodiceProvincia , @CodiceComune , @CodiceIstatDelComune_formato_alfanumerico , @SoloDenominazione_in_italiano , @SoloDenominazione_in_tedesco , @CodiceRipartizioneGeografica , @RipartizioneGeografica , @DenominazioneRegione , @DenominazioneCittaMetropolitana , @DenominazioneProvincia , @ComuneCapoluogoDiProvincia , @SiglaAuto , @CodiceIstatDelComune_formato_numerico ,
								 @CodiceIstatDelComune_a_110_province_formato_numerico , @CodiceIstatDelComune_a_107_province_formato_numerico , @CodiceIstatDelComune_a_103_province_formato_numerico , @CodiceCatastale , @Popolazionelegale_2011 , @CodiceNUTS1_2010 , @CodiceNUTS2_2010 ,
								  @CodiceNUTS3_2010 , @CodiceNUTS1_2006 , @CodiceNUTS2_2006 , @CodiceNUTS3_2006 
	




					WHILE @@FETCH_STATUS = 0   
					BEGIN

					set @lista_comuni_insert_descr = @lista_comuni_insert_descr + @CodiceIstatDelComune_formato_alfanumerico + ' , '
				
						set @temp='insert into GEO_ISTAT_elenco_comuni_italiani ([CodiceRegione], [CodiceCittaMetropolitana], [CodiceProvincia], [CodiceComune], [CodiceIstatDelComune_formato_alfanumerico], [SoloDenominazione_in_italiano], [SoloDenominazione_in_tedesco], [CodiceRipartizioneGeografica], [RipartizioneGeografica], [DenominazioneRegione], [DenominazioneCittaMetropolitana], [DenominazioneProvincia], [ComuneCapoluogoDiProvincia], [SiglaAuto], [CodiceIstatDelComune_formato_numerico], [CodiceIstatDelComune_a_110_province_formato_numerico], [CodiceIstatDelComune_a_107_province_formato_numerico], [CodiceIstatDelComune_a_103_province_formato_numerico], [CodiceCatastale], [Popolazionelegale_2011], [CodiceNUTS1_2010], [CodiceNUTS2_2010], [CodiceNUTS3_2010], [CodiceNUTS1_2006], [CodiceNUTS2_2006], [CodiceNUTS3_2006]) 
		values ('

					set @temp=@temp + '''' + isnull(@CodiceRegione,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceCittaMetropolitana,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceProvincia,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceComune,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceIstatDelComune_formato_alfanumerico,'') + ''','
					set @temp=@temp + '''' + isnull(@SoloDenominazione_in_italiano,'') + ''','
					set @temp=@temp + '''' + isnull(@SoloDenominazione_in_tedesco,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceRipartizioneGeografica,'') + ''','
					set @temp=@temp + '''' + isnull(@RipartizioneGeografica,'') + ''','
					set @temp=@temp + '''' + isnull(@DenominazioneRegione,'') + ''','
					set @temp=@temp + '''' + isnull(@DenominazioneCittaMetropolitana,'') + ''','
					set @temp=@temp + '''' + isnull(@DenominazioneProvincia,'') + ''','
					set @temp=@temp + '''' + isnull(@ComuneCapoluogoDiProvincia,'') + ''','
					set @temp=@temp + '''' + isnull(@SiglaAuto,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceIstatDelComune_formato_numerico,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceIstatDelComune_a_110_province_formato_numerico,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceIstatDelComune_a_107_province_formato_numerico,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceIstatDelComune_a_103_province_formato_numerico,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceCatastale,'') + ''','
					set @temp=@temp + '''' + isnull(@Popolazionelegale_2011,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceNUTS1_2010,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceNUTS2_2010,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceNUTS3_2010,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceNUTS1_2006,'') + ''','
					set @temp=@temp + '''' + isnull(@CodiceNUTS2_2006,'') + ''','				
					set @temp=@temp + '''' + isnull(@CodiceNUTS3_2006,'') + ''''

					set @temp=@temp + ')'

						set @lista_comuni_insert=@lista_comuni_insert+ '

		' + @temp
				
				
						FETCH NEXT FROM cursGEOINS INTO  @CodiceRegione , @CodiceCittaMetropolitana , @CodiceProvincia , @CodiceComune , @CodiceIstatDelComune_formato_alfanumerico , @SoloDenominazione_in_italiano , @SoloDenominazione_in_tedesco , @CodiceRipartizioneGeografica , @RipartizioneGeografica , @DenominazioneRegione , @DenominazioneCittaMetropolitana , @DenominazioneProvincia , @ComuneCapoluogoDiProvincia , @SiglaAuto , @CodiceIstatDelComune_formato_numerico ,
								 @CodiceIstatDelComune_a_110_province_formato_numerico , @CodiceIstatDelComune_a_107_province_formato_numerico , @CodiceIstatDelComune_a_103_province_formato_numerico , @CodiceCatastale , @Popolazionelegale_2011 , @CodiceNUTS1_2010 , @CodiceNUTS2_2010 ,
								  @CodiceNUTS3_2010 , @CodiceNUTS1_2006 , @CodiceNUTS2_2006 , @CodiceNUTS3_2006 
	

					END  


					CLOSE cursGEOINS   
					DEALLOCATE cursGEOINS

					

		end

		--- UPDATE
		-- genera SQL dinamico
		declare @lista_comuni_update nvarchar(max)
		declare @lista_comuni_update_descr nvarchar(max)

		set @lista_comuni_update=''
		set @lista_comuni_update_descr = ''

		if exists(select *
					from  GEO_ISTAT_elenco_comuni_italiani_temp a
						inner join GEO_ISTAT_elenco_comuni_italiani b on a.CodiceIstatDelComune_formato_alfanumerico = b.CodiceIstatDelComune_formato_alfanumerico
						where a.SoloDenominazione_in_italiano <> b.SoloDenominazione_in_italiano or
								a.CodiceRegione  <> b.CodiceRegione or
								a.CodiceProvincia <> b.CodiceProvincia or
								a.CodiceComune <> b.CodiceComune or
								(a.deleted = 0 and b.deleted = 1)
					)

		begin
				DECLARE cursGEOUPD CURSOR STATIC FOR     
								select a.CodiceIstatDelComune_formato_alfanumerico,
										a.SoloDenominazione_in_italiano,
										a.CodiceRegione,
										a.CodiceProvincia,
										a.CodiceComune
					from  GEO_ISTAT_elenco_comuni_italiani_temp a
						inner join GEO_ISTAT_elenco_comuni_italiani b on a.CodiceIstatDelComune_formato_alfanumerico = b.CodiceIstatDelComune_formato_alfanumerico
						where a.SoloDenominazione_in_italiano <> b.SoloDenominazione_in_italiano or
								a.CodiceRegione  <> b.CodiceRegione or
								a.CodiceProvincia <> b.CodiceProvincia or
								a.CodiceComune <> b.CodiceComune or
								(a.deleted = 0 and b.deleted = 1)


					OPEN cursGEOUPD 
					FETCH NEXT FROM cursGEOUPD INTO  @CodiceIstatDelComune_formato_alfanumerico,
														@SoloDenominazione_in_italiano,
														@CodiceRegione,
														@CodiceProvincia,
														@CodiceComune
	




					WHILE @@FETCH_STATUS = 0   
					BEGIN
				
						set @lista_comuni_update_descr = @lista_comuni_update_descr + @CodiceIstatDelComune_formato_alfanumerico + ' , '
						
						set @temp='update GEO_ISTAT_elenco_comuni_italiani set SoloDenominazione_in_italiano='


						set @temp=@temp + '''' + isnull(@SoloDenominazione_in_italiano,'') + ''','
			
						set @temp=@temp + 'CodiceRegione='
						set @temp=@temp + '''' + isnull(@CodiceRegione,'') + ''','

						set @temp=@temp + 'CodiceProvincia='
						set @temp=@temp + '''' + isnull(@CodiceProvincia,'') + ''','
				
						set @temp=@temp + 'deleted=0'	
				
						set @temp=@temp + ' where CodiceIstatDelComune_formato_alfanumerico='		
						set @temp=@temp + '''' + isnull(@CodiceIstatDelComune_formato_alfanumerico,'') + ''''	


						set @lista_comuni_update=@lista_comuni_update+ '

		' + @temp
				
				
						FETCH NEXT FROM cursGEOUPD INTO  @CodiceIstatDelComune_formato_alfanumerico,
														@SoloDenominazione_in_italiano,
														@CodiceRegione,
														@CodiceProvincia,
														@CodiceComune
	

					END  


					CLOSE cursGEOUPD   
					DEALLOCATE cursGEOUPD


		end



		----- fine gestione GEO_ISTAT_elenco_comuni_italiani		

		
		IF @attivaUpdate = 1
		BEGIN

			-- METTO A CANCELLATI LOGICAMENTE I RECORD DEL VECCHIO GEO NON PIU' PRESENTI NEL NUOVO GEO

			UPDATE LIB_DomainValues
				set DMV_Deleted = 1
				where id IN (
							SELECT old.id	
								FROM LIB_DomainValues old 
										LEFT JOIN #NEW_GEO new ON new.DMV_Cod = old.DMV_Cod  
								WHERE new.id is null and old.DMV_DM_ID = 'GEO' and isnull(old.DMV_Deleted,0) = 0
						)

			-- RIPRISTINO RECORD PRECEDENTEMENTE MESSI A CANCELLATI LOGICAMENTE CHE INVECE ADESSO COMPAIONO NEI NUOVI DATI ISTAT
			UPDATE LIB_DomainValues
				set DMV_Deleted = 0
				where id IN (
							SELECT old.id	
								FROM LIB_DomainValues old 
										INNER JOIN #NEW_GEO new ON old.DMV_DM_ID = 'GEO' and new.DMV_Cod = old.DMV_Cod and isnull(old.DMV_Deleted,0) = 1
						)

			---- VARIAZIONI DI DENOMINAZIONE A PARITA' DI CODICE ISTAT
			UPDATE LIB_DomainValues 
					set DMV_DescML = new.DMV_DescML
				FROM LIB_DomainValues old with(nolock)
						inner join #NEW_GEO new on new.DMV_Cod = old.DMV_Cod  and replace(new.DMV_DescML,' ','') <> replace(old.DMV_DescML,' ','') --confro con descrizione senza spazi
				WHERE old.DMV_DM_ID = 'GEO' and isnull(old.DMV_Deleted,0) = 0

			-- AGGIUNGO I NUOVI RECORD
			INSERT INTO LIB_DomainValues (DMV_DM_ID, DMV_Cod, DMV_Father, DMV_Level, DMV_DescML, DMV_Image, DMV_Sort, DMV_CodExt, DMV_Module)
					SELECT NEW.DMV_DM_ID, NEW.DMV_Cod, NEW.DMV_Father, NEW.DMV_Level, NEW.DMV_DescML, NEW.DMV_Image, NEW.DMV_Sort, NEW.DMV_CodExt, NEW.DMV_Module
							FROM #NEW_GEO new 
									LEFT JOIN LIB_DomainValues old ON old.DMV_DM_ID = 'GEO' and new.DMV_Cod = old.DMV_Cod
							where old.id is null

			if @lista_comuni_delete <> ''
				exec @lista_comuni_delete
			
			if @lista_comuni_insert <> ''
				exec @lista_comuni_insert

			if @lista_comuni_update <> ''
				exec @lista_comuni_update



		END
		ELSE
		BEGIN

			DECLARE @LISTA_COD varchar(max)
			DECLARE @LISTA_DESC_COD_CANCELLA varchar(max)
			DECLARE @LISTA_DESC_COD_RIPRISTINA varchar(max)
			DECLARE @LISTA_DESC_COD_AGGIUNGI varchar(max)
			DECLARE @LISTA_DESC_COD_VARIA varchar(max)
			DECLARE @LISTA_DESC_COD varchar(max)

			DECLARE @SCRIPT_CANCELLA NVARCHAR(MAX)
			DECLARE @SCRIPT_RIPRISTINA NVARCHAR(MAX)
			DECLARE @SCRIPT_AGGIUNGI NVARCHAR(MAX)
			DECLARE @SCRIPT_VARIA NVARCHAR(MAX)
			DECLARE @vbcrlf varchar(100)

			set @vbcrlf ='
'

			SET @SCRIPT_CANCELLA = ''
			SET @SCRIPT_RIPRISTINA = ''
			SET @SCRIPT_AGGIUNGI = ''
			SET @LISTA_COD = ''
			set @SCRIPT_VARIA = ''
			set @LISTA_DESC_COD_CANCELLA = ''
			set @LISTA_DESC_COD_RIPRISTINA = ''
			set @LISTA_DESC_COD_AGGIUNGI = ''
			set @LISTA_DESC_COD_VARIA = ''
			set @LISTA_DESC_COD = ''


			SELECT  @LISTA_COD = @LISTA_COD + '''' + cast(old.DMV_Cod as varchar(4000)) + ''',',
					@LISTA_DESC_COD_CANCELLA = @LISTA_DESC_COD_CANCELLA + cast(old.DMV_Cod as varchar(4000)) + ' - ' +  old.DMV_DescML + @vbcrlf
				FROM LIB_DomainValues old 
						LEFT JOIN #NEW_GEO new ON new.DMV_Cod = old.DMV_Cod  
				WHERE new.id is null and old.DMV_DM_ID = 'GEO' and isnull(old.DMV_Deleted,0) = 0

			IF @LISTA_COD <> ''
			BEGIN
				SET @LISTA_COD = LEFT(@LISTA_COD,LEN(@LISTA_COD)-1)
				SET @SCRIPT_CANCELLA = 'UPDATE LIB_DomainValues set DMV_Deleted = 1 where DMV_DM_ID = ''GEO'' and DMV_Cod IN (' + @LISTA_COD + ')'
				SET @LISTA_COD = ''
			END

			SELECT @LISTA_COD = @LISTA_COD + '''' + cast(old.DMV_Cod as varchar(4000)) + ''',',
					@LISTA_DESC_COD_RIPRISTINA = @LISTA_DESC_COD_RIPRISTINA + cast(old.DMV_Cod as varchar(4000)) + ' - ' +  old.DMV_DescML + @vbcrlf
				FROM LIB_DomainValues old 
						INNER JOIN #NEW_GEO new ON old.DMV_DM_ID = 'GEO' and new.DMV_Cod = old.DMV_Cod and isnull(old.DMV_Deleted,0) = 1
			
			IF @LISTA_COD <> ''
			BEGIN
				SET @LISTA_COD = LEFT(@LISTA_COD,LEN(@LISTA_COD)-1)
				SET @SCRIPT_RIPRISTINA = 'UPDATE LIB_DomainValues set DMV_Deleted = 0 where DMV_DM_ID = ''GEO'' and DMV_Cod IN (' + @LISTA_COD + ')'
				SET @LISTA_COD = ''
			END

			DECLARE @DMV_DM_ID VARCHAR(500)
			DECLARE @DMV_Cod VARCHAR(500)
			DECLARE @DMV_Father VARCHAR(500)
			DECLARE @DMV_Level INT
			DECLARE @DMV_DescML VARCHAR(1000)
			DECLARE @OLD_DMV_DescML VARCHAR(1000)
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

				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + 'IF NOT EXISTS ( select * from LIB_DomainValues with(nolock) where DMV_DM_ID = ''GEO'' and DMV_Cod = ''' + isnull(@DMV_Cod,'') + ''') ' + @vbcrlf
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + 'BEGIN' + @vbcrlf
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + ''
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + '		INSERT INTO LIB_DomainValues (DMV_DM_ID, DMV_Cod, DMV_Father, DMV_Level, DMV_DescML, DMV_Image, DMV_Sort, DMV_CodExt, DMV_Module)' + @vbcrlf
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + '			VALUES (''' + isnull(@DMV_DM_ID,'') + ''',''' + isnull(@DMV_Cod,'') + ''',''' + isnull(@DMV_Father,'') + ''',' + CAST(isnull(@DMV_Level,0) AS VARCHAR(10)) + ',''' + replace(isnull(@DMV_DescML,''),'''','''''') + ''',''' + isnull(@DMV_Image,'') + ''',' + CAST(isnull(@DMV_Sort,0) AS VARCHAR(10)) + ',''' + isnull(@DMV_CodExt,'') + ''',''' + isnull(@DMV_Module,'') + ''')' + @vbcrlf
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + ''
				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + 'END'

				SET @SCRIPT_AGGIUNGI = @SCRIPT_AGGIUNGI + @vbcrlf + @vbcrlf

				set @LISTA_DESC_COD_AGGIUNGI = @LISTA_DESC_COD_AGGIUNGI + isnull(@DMV_Cod,'') + ' - ' + isnull(@DMV_DescML,'') + @vbcrlf

				FETCH NEXT FROM curs INTO @DMV_DM_ID,@DMV_Cod,@DMV_Father,@DMV_Level,@DMV_DescML,@DMV_Image,@DMV_Sort,@DMV_CodExt,@DMV_Module

			END  


			CLOSE curs   
			DEALLOCATE curs

			---------------------------------------------------------------------
			--- GESTIONE VARIAZIONI DI DENOMINAZIONE A PARITA' DI CODICE ISTAT --
			---------------------------------------------------------------------
			DECLARE curs2 CURSOR STATIC FOR     
						SELECT old.DMV_Cod, old.DMV_DescML, new.DMV_DescML
							FROM LIB_DomainValues old with(nolock)
									inner join #NEW_GEO new on new.DMV_Cod = old.DMV_Cod  and replace(new.DMV_DescML,' ','') <> replace(old.DMV_DescML,' ','') --confro con descrizione senza spazi
							WHERE old.DMV_DM_ID = 'GEO' and isnull(old.DMV_Deleted,0) = 0

			SET @SCRIPT_VARIA = ''
			set @LISTA_DESC_COD_VARIA = ''

			OPEN curs2 
			FETCH NEXT FROM curs2 INTO @DMV_Cod, @OLD_DMV_DescML, @DMV_DescML

			WHILE @@FETCH_STATUS = 0   
			BEGIN

				SET @SCRIPT_VARIA = @SCRIPT_VARIA + 'UPDATE LIB_DomainValues ' + @vbcrlf
				SET @SCRIPT_VARIA = @SCRIPT_VARIA + '	set DMV_DescML = ''' + replace(@DMV_DescML,'''','''''') + '''' + @vbcrlf
				--SET @SCRIPT_VARIA = @SCRIPT_VARIA + '	WHERE DMV_DM_ID = ''GEO'' and isnull(DMV_Deleted,0) = 0 and DMV_DescML = ''' + replace(@OLD_DMV_DescML,'''','''''') + '''' + @vbcrlf
				SET @SCRIPT_VARIA = @SCRIPT_VARIA + '	WHERE DMV_DM_ID = ''GEO'' and DMV_COD = ''' + @DMV_Cod + '''  ' + @vbcrlf
				SET @SCRIPT_VARIA = @SCRIPT_VARIA + @vbcrlf + @vbcrlf

				set @LISTA_DESC_COD_VARIA = @LISTA_DESC_COD_VARIA + @DMV_Cod + ' - cambiata descrizione da ' + @OLD_DMV_DescML + ' a ' + @DMV_DescML + @vbcrlf

				FETCH NEXT FROM curs2 INTO @DMV_Cod, @OLD_DMV_DescML, @DMV_DescML

			END  


			CLOSE curs2   
			DEALLOCATE curs2


			-- COMPONGO LO SCRIPT FINALE SE CI SONO DATI VARIATI

			IF @SCRIPT_CANCELLA <> '' or  @SCRIPT_RIPRISTINA <> '' or @SCRIPT_AGGIUNGI <> '' or @SCRIPT_VARIA <> '' or @lista_comuni_delete <> '' or @lista_comuni_insert <> '' or @lista_comuni_update <> ''
			BEGIN

				SET @script = @SCRIPT_CANCELLA + @vbcrlf + @vbcrlf + @SCRIPT_RIPRISTINA + @vbcrlf + @vbcrlf + @SCRIPT_AGGIUNGI + @vbcrlf + @vbcrlf + @SCRIPT_VARIA

				
				set @LISTA_DESC_COD = 'elementi aggiunti:' + @vbcrlf + @LISTA_DESC_COD_AGGIUNGI + @vbcrlf + 'elementi eliminati:' + @vbcrlf + @LISTA_DESC_COD_CANCELLA + @vbcrlf + 'elementi ripristinati:' + @vbcrlf + @LISTA_DESC_COD_RIPRISTINA + @vbcrlf + 'elementi variati di denominazione:' + @vbcrlf + @LISTA_DESC_COD_VARIA


				set @LISTA_DESC_COD = @LISTA_DESC_COD + @vbcrlf +  @vbcrlf + ' Aggiornamenti alla tabella dei comuni GEO_ISTAT_elenco_comuni_italiani :' +  @vbcrlf + 'comuni aggiunti:' + @vbcrlf + @lista_comuni_insert_descr + @vbcrlf + 'comuni eliminati:' + @vbcrlf + @lista_comuni_delete_descr + @vbcrlf  + 'comuni variati :' + @vbcrlf + @lista_comuni_update_descr

				--print @script 
				--print @LISTA_DESC_COD

				-- GENERO L'ATTIVITA NELLA INTRANET E SCHEDULO UN PROCESSO PER INVIARE UN EMAIL DI SEGNALAZIONE 
				IF @genera_attivita_intranet = 1 -- and 1 = 2
				BEGIN

					
					DECLARE @utente_in_carico INT 

					--set @utente_in_carico = 148 --federico leone
					set @utente_in_carico = 149 --Francesco D'Angelo 

					INSERT INTO AFSOLUZIONI.dbo.[Document_Attivita]
							   ([RisorsaInCarico]
							   ,[Prodotto]
							   ,[Oggetto]
							   ,[Descrizione]
							   ,[StatoAttivita]
							   ,[InseritoDa]
							   ,[TipoAttivita]
							   ,[Cliente]
							   ,[Deleted]
							   ,releasenotes)
						 VALUES  (@utente_in_carico
							   ,'AFLINK PA'
							   ,'AGGIORNAMENTO GEO DA INTEGRAZIONE ISTAT'
							   ,@LISTA_DESC_COD
							   ,'NonIniziata'
							   ,0
							   ,'Sviluppo'
							   ,35219606
							   ,0
							   ,'AGGIORNAMENTO DEL DOMINIO GEO DA INTEGRAZIONE ISTAT')

					SET @NEW_ID = SCOPE_IDENTITY() 

					INSERT INTO AFSOLUZIONI.dbo.Document_Attivita_Upgrade ( idHeader, sort, NewUpd, tipoObj, idObj, AreaNote, ScriptSQL )
						VALUES ( @NEW_ID, 0, 'new','SQL-Script', 'GEO', 'Aggiornamento dominio GEO', @script )

					declare @script2 nvarchar(max)

					if @lista_comuni_delete <> '' or @lista_comuni_insert <> '' or @lista_comuni_update <> ''
					begin
						SET @script2 =  @lista_comuni_delete + @vbcrlf + @vbcrlf + @lista_comuni_insert + @vbcrlf + @vbcrlf + @lista_comuni_update 
						
						INSERT INTO AFSOLUZIONI.dbo.Document_Attivita_Upgrade ( idHeader, sort, NewUpd, tipoObj, idObj, AreaNote, ScriptSQL )
						VALUES ( @NEW_ID, 0, 'new','SQL-Script', 'GEO_ISTAT_elenco_comuni_italiani', 'Aggiornamento tabella GEO_ISTAT_elenco_comuni_italiani', @script2 )

					end


					INSERT INTO AFSOLUZIONI.dbo.[CTL_Schedule_Process]
								([IdDoc]
								,[IdUser]
								,[DPR_DOC_ID]
								,[DPR_ID]
								,[DataRequestExec]
								,[State])
							VALUES
								(@NEW_ID
								,@utente_in_carico
								,'ATTIVITA'
								,'SOLLECITO_GEO'
								,NULL
								,0)

					

					--CERCA LA RELEASE PER LO SCAFFALE AFLINK PA
					declare @release as int
					declare @idlink as int
					declare @progressivo as varchar(500)
					declare @nome_pacchetto as varchar(500)
					set @release=0
					select top 1 @release=r.id  
					from AFSOLUZIONI.dbo.Document_Attivita a 
					inner join AFSOLUZIONI.dbo.DASHBOARD_VIEW_ATTIVITA_RELEASE r on 'AFLINK PA'=r.Prodotto and 35219606=r.Cliente and r.StatoAttivita = 'Incorso' and r.TipoAttivita <> 'Scaffale' 
					where a.id=@NEW_ID
					order by r.id desc

					IF @release > 0
					BEGIN
						--RECUPERATA LA RELEASE VA A PRENDERE IL PROGRESSIVO DEL PACCHETTO, NEL CASO GIA' PRESENTE VIENE ASSEGNATO DI NUOVO QUEL PROGRESSIVO
						select top 1 @progressivo=
							CASE 
									WHEN  ISNUMERIC(dbo.GetPos(NoteLink,'-',1)) = 1 
									THEN cast(dbo.GetPos(NoteLink,'-',1) as int) +1
									ELSE 0 
								END ,
							@idlink	= p.numero 
							from AFSOLUZIONI.dbo.[Document_Attivita] p 
								left join AFSOLUZIONI.dbo.[Document_Attivita_Link] l on l.idHeader = p.id --and l.LINKGrid_ID_DOC=@NEW_ID
							where p.AttivitaPadre=@release 
							order by cast(dbo.GetPos(NoteLink,'-',1) as int) +1 desc
	
						if CAST(@progressivo as int ) < 10
							set @progressivo='00' + @progressivo
						if CAST(@progressivo as int ) > 9 and CAST(@progressivo as int ) < 100
							set @progressivo='0' + @progressivo
	
						insert into AFSOLUZIONI.dbo.[Document_Attivita_Link] (LINKGrid_ID_DOC,NoteLink,idHeader)  
							select id,@progressivo  + ' - ' + cast(Oggetto as varchar(MAX)) , @idlink  
								 from AFSOLUZIONI.dbo.Document_Attivita where id=@NEW_ID	
	
					END
					
					
					--CERCA LA RELEASE PER LO SCAFFALE AFLink IMPRESA
					--set @release=0
					--select top 1 @release=r.id  
					--from AFSOLUZIONI.dbo.Document_Attivita a 
					--inner join AFSOLUZIONI.dbo.DASHBOARD_VIEW_ATTIVITA_RELEASE r on 'AFLink IMPRESA 2.0'=r.Prodotto and 35219606=r.Cliente and r.StatoAttivita = 'Incorso' and r.TipoAttivita <> 'Scaffale' 
					--where a.id=@NEW_ID
					--order by r.id desc

					--IF @release > 0
					--BEGIN
					--	--RECUPERATA LA RELEASE VA A PRENDERE IL PROGRESSIVO DEL PACCHETTO, NEL CASO GIA' PRESENTE VIENE ASSEGNATO DI NUOVO QUEL PROGRESSIVO
					--	select top 1 @progressivo=
					--		CASE 
					--				WHEN  ISNUMERIC(dbo.GetPos(NoteLink,'-',1)) = 1 
					--				THEN cast(dbo.GetPos(NoteLink,'-',1) as int) +1
					--				ELSE 0 
					--			END ,
					--		@idlink	= p.numero 
					--		from AFSOLUZIONI.dbo.[Document_Attivita] p 
					--			left join AFSOLUZIONI.dbo.[Document_Attivita_Link] l on l.idHeader = p.id --and l.LINKGrid_ID_DOC=@NEW_ID
					--		where p.AttivitaPadre=@release 
					--		order by cast(dbo.GetPos(NoteLink,'-',1) as int) +1 desc
	
					--	if CAST(@progressivo as int ) < 10
					--		set @progressivo='00' + @progressivo
					--	if CAST(@progressivo as int ) > 9 and CAST(@progressivo as int ) < 100
					--		set @progressivo='0' + @progressivo
	
					--	insert into AFSOLUZIONI.dbo.[Document_Attivita_Link] (LINKGrid_ID_DOC,NoteLink,idHeader)  
					--		select id,@progressivo  + ' - ' + cast(Oggetto as varchar(MAX)) , @idlink  
					--			 from AFSOLUZIONI.dbo.Document_Attivita where id=@NEW_ID	
	
					--END




				END


			END

		END
	
	
	-- select per i parametri di output
	if  @NEW_ID is not null
		select 	@NEW_ID as 'ID', 		@LISTA_DESC_COD as 'Descr'		
	else
		select 	top 0 @NEW_ID as 'ID', 		@LISTA_DESC_COD as 'Descr'



						
END










GO
