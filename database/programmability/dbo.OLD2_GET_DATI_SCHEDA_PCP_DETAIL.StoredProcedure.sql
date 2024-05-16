USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GET_DATI_SCHEDA_PCP_DETAIL]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[OLD2_GET_DATI_SCHEDA_PCP_DETAIL] ( @IdGara int  )
AS
BEGIN

	SET NOCOUNT ON
	
	
	declare @Divisione_lotti as varchar(10)
	declare @CondLotti as varchar(100)
	declare @SQL as nvarchar(max)
	declare @TipoAppaltoGara as varchar(100)
	declare @COD_LUOGO_ISTAT as varchar(100)
	declare @afferenteInvestimentiPNRR as varchar(1)
	declare @TipoScheda as varchar(100)
	declare @TipoDocGara as varchar(100)
	declare @IdPda as int
	declare @importoOrd float = 0 

	select @TipoDocGara = tipodoc from CTL_DOC Gara with (nolock) where Gara.Id = @IdGara
	
	--RECUPERO INFO DALLA GARA
	if @TipoDocGara in ('BANDO_GARA','BANDO_SEMPLIFICATO','AFFIDAMENTO_SENZA_NEGOZIAZIONE')
	BEGIN
		
		select 
			  @Divisione_lotti=Divisione_lotti ,
			   --@OggettoPrincipaleContratto=dbo.Get_DescMulti_Dom('Tipologia',TipoAppaltoGara,'I'),
			   @TipoAppaltoGara = TipoAppaltoGara,
			   @COD_LUOGO_ISTAT= dbo.Get_Istat_From_Geo( isnull(D.value,'') , 1 ) ,
			   --@afferenteInvestimentiPNRR = isnull(Appalto_PNRR_PNC,0),
			   @afferenteInvestimentiPNRR = 
				   case 
						when isnull(Appalto_PNRR,'no') = 'si' or isnull(Appalto_PNC,'no') = 'si' then 1
						else 0 
				   end,
			   @TipoScheda = pcp_TipoScheda
			  
			from 
				Document_Bando Dett with (nolock) 
					left join Document_PCP_Appalto SC with (nolock) on SC.idHeader = Dett.idHeader 
					left join  ctl_doc_value D with (nolock) on D.IdHeader = Dett.idheader 
															and D.DSE_ID='InfoTec_SIMOG' and d.DZT_Name='COD_LUOGO_ISTAT'
			where Dett.idHeader=@IdGara

	END

	if @TipoDocGara = 'ODC'
	begin

		set @Divisione_lotti='0'
		
		select 	@COD_LUOGO_ISTAT= dbo.Get_Istat_From_Geo( isnull(D.value,'') , 1 ) ,

				@afferenteInvestimentiPNRR = 
								   case 
										when isnull(Appalto_PNRR,'no') = 'si' or isnull(Appalto_PNC,'no') = 'si' then 1
										else 0 
								   end,
				@TipoScheda = pcp_TipoScheda,
				@importoOrd = RDA_Total
			  
			from Document_ODC Dett with (nolock) 
					left join Document_PCP_Appalto SC with (nolock) on SC.idHeader = Dett.rda_id 
					left join  ctl_doc_value D with (nolock) on D.IdHeader = Dett.rda_id 
															and D.DSE_ID='DICHIARAZIONI' and d.DZT_Name='COD_LUOGO_ISTAT'
			where Dett.rda_id=@IdGara
			
	end

	if @TipoDocGara = 'ODA'
	begin

		set @Divisione_lotti='0'
		
		select @COD_LUOGO_ISTAT= dbo.Get_Istat_From_Geo( isnull(dett.COD_LUOGO_ISTAT ,'') , 1 ) ,
			    @afferenteInvestimentiPNRR = 0,
				@TipoScheda = pcp_TipoScheda,
				@TipoAppaltoGara = TipoAppaltoGara,
				@importoOrd = TotaleEroso
			from Document_ODA Dett with (nolock) 
					left join Document_PCP_Appalto SC with (nolock) on SC.idHeader = Dett.idHeader
			where Dett.idHeader = @IdGara

	end

	--RICAVO CONDIZIONE DI WHERE PERRR RECUPERARE I PRODOTTI
	set @CondLotti = ' and Voce=0 '
	
	-- PER LE GARE NON A LOTTI CONSIDERO NUMERORIGA=0
	if @Divisione_lotti = '0'
	begin
		set @CondLotti = ' and NumeroRiga = 0 '
	end

	--se si tratta di una scheda di AFFIDAMENTO DIRETTO
	if @TipoScheda in ('AD3','AD5','AD2_25','AD4')
	begin

		--GARA ('BANDO_GARA' , 'BANDO_SEMPLIFICATO')
		if @TipoDocGara in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO')
		begin
			set @IdPda=0
			select  @IdPda=Id 
				from 
					CTL_DOC with (nolock)
				where
					LinkedDoc = @IdGara and TipoDoc='PDA_MICROLOTTI' and Deleted=0
		--end	
			--metto in una temp i lotti in uno stato finale valido
			select 
				NumeroLotto into #LottiValdi
				from 
					document_microlotti_dettagli with (nolock) 
				where idheader=@IdPda and TipoDoc='PDA_MICROLOTTI'
					and statoriga  in ('AggiudicazioneProvv','Controllato','AggiudicazioneCond','AggiudicazioneDef')
		end

		--'AFFIDAMENTO_SENZA_NEGOZIAZIONE'
		if @TipoDocGara in ('AFFIDAMENTO_SENZA_NEGOZIAZIONE')
		begin
			select 
				NumeroLotto into #LottiValidi1
				from 
					document_microlotti_dettagli with (nolock) 
				where idheader = @IdGara and TipoDoc='AFFIDAMENTO_SENZA_NEGOZIAZIONE' and voce = 0
		end

	end

	--SELECT CHE RITORNA I DATI 	
	--PER TUTTI I CASI DI INNESCO TRANNE CHE ODC/ODA
	if @TipoDocGara not in ( 'ODC', 'ODA' )
	BEGIN

		set @SQL= '
			select 			
					case
						when tipoappaltogara=2 then ltrim( str( ValoreImportoLotto , 25 , 2 ) )
						else ''0''
					end as impLavori,
					case
						when tipoappaltogara=3 then ltrim( str( ValoreImportoLotto , 25 , 2 ) )
						else ''0''
					end as impServizi,
					case
						when tipoappaltogara=1 then ltrim( str( ValoreImportoLotto , 25 , 2 ) )
						else ''0''
					end as impForniture,

					TipoBandoGara, 
					NumeroLotto,
					dbo.eFroms_GetIdentifier(''Lot'', NumeroLotto,'''') AS lotIdentifier , 

					ltrim( str(  
								ValoreImportoLotto + 
								isnull(dett.IMPORTO_OPZIONI,0) + 
								isnull(dett.IMPORTO_ATTUAZIONE_SICUREZZA,0) +	
								isnull(dett.pcp_UlterioriSommeNoRibasso,0) + 
								isnull(dett.pcp_SommeRipetizioni,0) +	
								isnull(dett.pcp_SommeOpzioniRinnovi,0) 
							, 25 , 2 ) ) as ValoreBase,
					
					ltrim( str( dett.pcp_SommeRipetizioni , 25 , 2 ) ) as sommeRipetizioni,
					ltrim( str( dett.pcp_SommeADisposizione , 25 , 2 ) ) as sommeADisposizione,
					ltrim( str( isnull(dett.pcp_SommeOpzioniRinnovi,0) + isnull(IMPORTO_OPZIONI,0) , 25 , 2 ) ) as sommeOpzioniRinnovi,
					ltrim( str( dett.pcp_UlterioriSommeNoRibasso , 25 , 2 ) ) as ulterioriSommeNoRibasso, 
					ltrim( str( dett.impProgettazione , 25 , 2 ) ) as impProgettazione,
				
					case 
						when isnull(ba.W9APOUSCOMP,'''')='''' or ba.W9APOUSCOMP='''' then ''false''
						else ba.W9APOUSCOMP
					end as W9APOUSCOMP,

					case 
						when isnull(ba.W3PROCEDUR ,'''')='''' or ba.W3PROCEDUR='''' then ''false''
						else ba.W3PROCEDUR
					end as proceduraAccelerata,

					ltrim( str( IMPORTO_ATTUAZIONE_SICUREZZA , 25 , 2 ) )  as ImportoSicurezza,  
					ltrim( str( IMPORTO_ATTUAZIONE_SICUREZZA , 25 , 2 ) )  as impTotaleSicurezza, 
				
					case 
						when isnull(dett.CUP,'''') ='''' or dett.CUP='''' then ba.CUP
						else dett.CUP
					end as CUP, 
				
					app.pcp_OggettoPrincipaleContratto, 
					app.pcp_PrevedeRipetizioniOpzioni, 

					--EP ATT. 585216
					--RECUPERATO SEMPRE A LIVELLO DI LOTTO
					--case 							
					--	when isnull(ba.divisione_lotti,''0'') = ''0'' and ( isnull(app.pcp_PrevedeRipetizioniOpzioni,'''')='''' or app.pcp_PrevedeRipetizioniOpzioni='''' ) then ''true''
					--	when isnull(ba.divisione_lotti,''0'') = ''0'' then app.pcp_PrevedeRipetizioniOpzioni
					--	else isnull(dett.pcp_PrevedeRipetizioniOpzioni,app.pcp_PrevedeRipetizioniOpzioni)
					
					--end as opzioniRinnovi,
					

					case
						when isnull(dett.pcp_PrevedeRipetizioniOpzioni,'''') ='''' then ''false''
						when dett.pcp_PrevedeRipetizioniOpzioni ='''' then ''false''
						else dett.pcp_PrevedeRipetizioniOpzioni
					end as opzioniRinnovi,


					app.pcp_TipologiaLavoro, 
				
					case 
						when isnull(ba.divisione_lotti,''0'') = ''0'' then app.pcp_Categoria
						else 			
							case 
								--sempre quella di testata perchè sui lotti non presente il campo per gli AD
								when pcp_TipoScheda in (''AD3'',''AD5'',''AD2_25'',''AD4'') then app.pcp_Categoria
								else
									case
										when isnull(dett.pcp_Categoria,'''') = '''' then app.pcp_Categoria
										else dett.pcp_Categoria
									end
							end 
					end as pcp_Categoria
					, 
				
					isnull(dett.pcp_CondizioniNegoziata,app.pcp_CondizioniNegoziata) as pcp_CondizioniNegoziata, 
					app.pcp_ContrattiDisposizioniParticolari, 
					
					case 
						when isnull(dett.pcp_ModalitaAcquisizione,'''')=''''  then app.pcp_ModalitaAcquisizione
						else dett.pcp_ModalitaAcquisizione
					end as pcp_ModalitaAcquisizione, 

					app.pcp_PrestazioniComprese, 
					isnull(dett.pcp_ServizioPubblicoLocale,app.pcp_ServizioPubblicoLocale) as pcp_ServizioPubblicoLocale, 
					
					--app.pcp_PrevedeRipetizioniCompl, 		

					case
						when isnull(dett.pcp_PrevedeRipetizioniCompl,'''') ='''' then ''false''
						when dett.pcp_PrevedeRipetizioniCompl ='''' then ''false''
						else dett.pcp_PrevedeRipetizioniCompl
					end as pcp_PrevedeRipetizioniCompl,

					--EP ATT. 585216
					--case 							
					--	when isnull(ba.divisione_lotti,''0'') = ''0'' and ( isnull(app.pcp_PrevedeRipetizioniCompl,'''')='''' or app.pcp_PrevedeRipetizioniCompl='''' ) then ''true''
					--	when isnull(ba.divisione_lotti,''0'') = ''0'' then app.pcp_PrevedeRipetizioniCompl
					--	else isnull(dett.pcp_PrevedeRipetizioniCompl,app.pcp_PrevedeRipetizioniCompl)
					
					--end as ripetizioniEConsegneComplementari,
					
					case
						when isnull(dett.pcp_PrevedeRipetizioniCompl,'''') ='''' then ''false''
						when dett.pcp_PrevedeRipetizioniCompl ='''' then ''false''
						else dett.pcp_PrevedeRipetizioniCompl
					end as ripetizioniEConsegneComplementari,


					app.pcp_CodiceCUI,
					app.pcp_RelazioneUnicaSulleProcedure,
					app.pcp_OpereUrbanizzateScomputo,
					app.pcp_MotivoUrgenza,
					dett.MOTIVAZIONE_CIG,
					dett.TIPO_FINANZIAMENTO,
					dett.MOTIVO_COLLEGAMENTO,
					dett.pcp_iniziativeNonSoddisfacenti as iniziativeNonSoddisfacenti,
					dett.pcp_iniziativeNonSoddisfacenti as pcp_iniziativeNonSoddisfacenti,
					dett.pcp_ImportoFinanziamento,
					dett.pcp_cigCollegato,
					dett.CODICE_CPV,
					dett.CIG,
					dett.pcp_saNonSoggettaObblighi24Dicembre2015 as saNonSoggettaObblighi24Dicembre2015,
					--duplicate per evitare di ricompilare inipec
					--dett.pcp_saNonSoggettaObblighi24Dicembre2015 as pcp_saNonSogettaObblighi24Dicembre2015,
					dett.pcp_lavoroOAcquistoPrevistoInProgrammazione,
					--dett.pcp_lavoroOAcquistoPrevistoInProgrammazione as pcp_lavoroOAquistoPrevistoInProgrammazione,
					''' +  @COD_LUOGO_ISTAT + ''' as codIstat,

					''non-applicabile'' as ccnl,
					''' + @afferenteInvestimentiPNRR + ''' as afferenteInvestimentiPNRR,
				
					case
						when isnull(ba.divisione_lotti,''0'') = ''0'' then 
						
							case 
								when ba.CUP <> '''' then ''true''
								else ''false''
							end

						else 
							case 
								when dett.CUP <> '''' or ba.CUP <> '''' then ''true''
								else ''false''
							end

					  end as acquisizioneCup,

					 case
						when tipoappaltogara = 1 then ''F'' 
						when tipoappaltogara = 2 then ''L'' 
						when tipoappaltogara = 3 then ''S'' 

					end as oggettoPrincipaleContratto,

					case
						when tipoappaltogara = 2 then ''false''
						else ''''
					end as StrumentiElettroniciSpecifici,
				
					case
						when tipoappaltogara = 1 then ''supplies''   --forniture
						when tipoappaltogara = 2 then ''works''		--lavori
						when tipoappaltogara = 3 then ''services'' --forniture
					end as oggettoContratto

				from 
					Document_MicroLotti_Dettagli dett with (nolock)
						inner join Document_PCP_Appalto app with (nolock) on dett.IdHeader = app.idHeader 
						inner join Document_Bando ba with (nolock) on dett.IdHeader = ba.idHeader 
				where dett.idheader =' + CAST(@IdGara as varchar(50)) + ' and TipoDoc in (''' + @TipoDocGara + ''')  
						and dett.StatoRiga <> ''Revocato'' ' + @CondLotti
		
			if @TipoScheda in ('AD3','AD5','AD2_25','AD4')
			begin
				if @TipoDocGara in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO')
				begin

					set @SQL = @SQL + 
						' and numerolotto in (select numerolotto from #LottiValdi )  
						
						'
				end

				if @TipoDocGara in ('AFFIDAMENTO_SENZA_NEGOZIAZIONE')
				begin
				
					set @SQL = @SQL + 
						' and numerolotto in (select numerolotto from #LottiValidi1 )  
						
						'
				end
			end

			--AGGUINGO ORDINAMENTO PER NUMERO LOTTO
			set @SQL = @SQL + ' ORDER BY CAST(NUMEROLOTTO AS INT)
		
			'

			--ESEGUO SELECT DINAMICA
			--select @SQL
			exec ( @SQL )
	END
	ELSE
	BEGIN
		
		--IN CASO DI INNESCO DA ODC/ODA
		select 
			
			case
				when @TipoAppaltoGara=2 then ltrim( str( @importoOrd , 25 , 2 ) )
				else '0'
			end as impLavori,
			case
				when @TipoAppaltoGara=3 then ltrim( str( @importoOrd , 25 , 2 ) )
				else '0'
			end as impServizi,
			case
				when @TipoAppaltoGara=1 then ltrim( str( @importoOrd , 25 , 2 ) )
				else '0'
			end as impForniture,
			
			'1' as NumeroLotto,

			dbo.eFroms_GetIdentifier('Lot', '1','') AS lotIdentifier,

			'' as CUP,

			@COD_LUOGO_ISTAT as codIstat,

			'non-applicabile' as ccnl,

			@afferenteInvestimentiPNRR as afferenteInvestimentiPNRR,

			case 
				when @afferenteInvestimentiPNRR = 0 then 'false'
				else 'true'
			end as acquisizioneCup,

			case
				when @TipoAppaltoGara = 1 then 'F' 
				when @TipoAppaltoGara = 2 then 'L' 
				when @TipoAppaltoGara = 3 then 'S' 

			end as oggettoPrincipaleContratto,

			case
				when @TipoAppaltoGara = 2 then 'false'
				else ''
			end as StrumentiElettroniciSpecifici,
				
			case
				when @TipoAppaltoGara = 1 then 'supplies'   --forniture
				when @TipoAppaltoGara = 2 then 'works'		--lavori
				when @TipoAppaltoGara = 3 then 'services' --forniture
			end as oggettoContratto,
			
			pcp_Categoria,

			null as impTotaleSicurezza,
			null as ulterioriSommeNoRibasso,
			null as impProgettazione,
			null as sommeOpzioniRinnovi,
			null as sommeRipetizioni,
			ltrim( str( isnull(pcp_SommeADisposizione,0) , 25 , 2 ) ) as sommeADisposizione

			from 
				Document_PCP_Appalto with (nolock) 
			where idHeader = @IdGara

	END

END








GO
