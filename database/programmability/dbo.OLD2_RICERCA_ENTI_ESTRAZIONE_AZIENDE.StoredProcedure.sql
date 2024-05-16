USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_RICERCA_ENTI_ESTRAZIONE_AZIENDE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_RICERCA_ENTI_ESTRAZIONE_AZIENDE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @AttrName			varchar(8000) 
	declare @AttrValue			varchar(8000) 
	declare @AttrOp 			varchar(8000)   
	declare @Filter				varchar(1000)  
	declare @Sort				varchar(1000)  
	declare @codFiscAzi			varchar(1000)
	declare @Param				varchar(8000)
	declare @TIPO_AMM_ER		varchar(8000)
	declare @TipoDiAmministr	varchar(8000)
	declare @aziProvinciaLeg3	varchar(8000)
	declare @codicefiscale		varchar(50)
	declare @SQLCmd			varchar(max)

	declare @NumeroRiga int
	declare @idRow int
	declare @Row int
	declare @Cnt int
    declare @Top			int

	set @NumeroRiga = 0
	set @Filter = ''
	set @Sort = ''
	set @Top = -1
	set @codFiscAzi = ''

	set @SQLCmd =  ''

	--ripulisco prima di eseguire la nuova ricerca
	delete CTL_DOC_Destinatari where IdHeader=@idDoc 



	CREATE TABLE #AziResult(
		[IdAzi] [int] NULL,
		[NumeroRiga] [nvarchar](50) collate DATABASE_DEFAULT NULL,
	) 

	
	-- preparo la tabella temporanea per accogliere il risultato della ricerca
	-- questa select deve mantenere la coerenza con le colonne ritornate dalal stored DASHBOARD_SP_DOSSIER_AZI
	select top 0 0 as IdAzi--, aziLog, aziDataCreazione, aziRagioneSociale, aziIdDscFormaSoc, aziPartitaIVA, aziE_Mail, aziAcquirente, aziVenditore, aziProspect, aziIndirizzoLeg, aziIndirizzoOp, aziLocalitaLeg, aziLocalitaOp, aziProvinciaLeg, aziProvinciaOp, aziStatoLeg, aziStatoOp, aziCAPLeg, aziCapOp, aziPrefisso, aziTelefono1, aziTelefono2, aziFAX, aziIdDscDescrizione, aziGphValueOper, aziDeleted, aziDBNumber, aziAtvAtecord, aziSitoWeb, aziCodEurocredit, aziProfili,  CertificatoIscrAtt, TipoDiAmministr ,
			--cast( '' as  varchar(250)) as CodiceFiscale , 
			--cast( '' as varchar(250)) as EmailRapLeg , 
			--cast( '' as varchar(250)) as CARBelongTo , 
			--cast( '' as varchar(250)) as CancellatoDiUfficio , 
			--cast( '' as varchar(8000)) as ClasseIscriz
		into #TempRicerca
		from aziende a 


	-- per ogni riga preparo i criteri di ricerca
	select Row , IdRow into #TempRighe
		from CTL_DOC_Value 
		where IdHeader = @IdDoc and DSE_ID = 'CRITERI' and DZT_Name = 'Sort'
		order by Row
	
	declare CurRowRicerca Cursor static for 
		select  Row , IdRow from #TempRighe order by Row
	
	open CurRowRicerca

	-- ciclo sulle righe dei criteri di ricerca
	FETCH NEXT FROM CurRowRicerca 	INTO  @Row , @IdRow
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @NumeroRiga = @NumeroRiga  + 1

		-- rettifico il numero della riga di ricerca nel caso non sia strettamente crescente
		update CTL_DOC_Value set Value = cast( @NumeroRiga as varchar(10)) where IdRow = @IdRow
		
		--print 'Invoco la ricerca'
		-- Creo i criteri di ricerca della riga
		exec RICERCA_ENTI_RECUPERA_CRITERI_DI_RICERCA  @IdDoc , @Row  , @AttrName	output, @AttrValue	output, @AttrOp 	output 
		
		set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

		set @TIPO_AMM_ER			    = replace( dbo.GetParam( 'TIPO_AMM_ER' , @Param ,1) ,'''','''''')
		set @TipoDiAmministr			= replace( dbo.GetParam( 'TipoDiAmministr' , @Param ,1) ,'''','''''')
		set @aziProvinciaLeg3			= replace( dbo.GetParam( 'aziProvinciaLeg3' , @Param ,1) ,'''','''''')
		set @codicefiscale			= replace( dbo.GetParam( 'codicefiscale' , @Param ,1) ,'''','''''')
		
		--print @Param

		--print @TIPO_AMM_ER
		--print @TipoDiAmministr
		--print @aziProvinciaLeg3
		--print @codicefiscale


		--print '@AttrName=' + @AttrName
		--print '@@AttrValue=' + @AttrValue
		--print '@@AttrOp=' + @AttrOp
		
		if @AttrName <> '' 
		begin			
			delete from #TempRicerca
			set @SQLCmd =  '
			insert into #TempRicerca ( idazi )
			select idazi
			from aziende a
			left outer join DM_Attributi d1 on d1.lnk = a.idazi and d1.dztNome = ''CodiceFiscale'' and d1.idapp = 1
			left outer join DM_Attributi d2 on d2.lnk = a.idazi and d2.dztNome = ''TIPO_AMM_ER'' and d2.idapp = 1
			where aziAcquirente <> 0 and azideleted = 0
			'
			if @codicefiscale <> ''
			begin
				set @SQLCmd = @SQLCmd + ' and d1.vatValore_FT like ''' + @CodiceFiscale + ''' '
			end

			if @TIPO_AMM_ER <> ''
			begin
				set @SQLCmd = @SQLCmd + ' and d2.vatValore_FT = ''' + @TIPO_AMM_ER + ''' '
			end
			if @TipoDiAmministr <> ''
			begin
				set @SQLCmd = @SQLCmd + ' and a.TipodiAmministr = ''' + @TipoDiAmministr + ''' '
			end

			if @aziProvinciaLeg3 <> ''
			BEGIN
				if EXISTS ( select * from LIB_DomainValues 	where DMV_DM_ID='GEO' and dmv_cod=@aziProvinciaLeg3 and DMV_LEVEL < 7 )
				BEGIN
					set @SQLCmd = @SQLCmd + ' and a.aziLocalitaLeg2 like ''' + @aziProvinciaLeg3 + '-%'' '
				END
				ELSE
				BEGIN
					set @SQLCmd = @SQLCmd + ' and a.aziLocalitaLeg2 = ''' + @aziProvinciaLeg3 + ''' '
				END
			END


		end
		exec (@SQLCmd)
		--print @SQLCmd
		--insert into #TempRicerca exec @SQLCmd


		--	insert into #TempRicerca exec DASHBOARD_SP_DOSSIER_AZI 
		--											 @IdUser						,
		--											 @AttrName						,
		--											 @AttrValue						,
		--											 @AttrOp 						,
		--											 @Filter                        ,
		--											 @Sort                          ,
		--											 @Top                           ,
		--											 @Cnt                           output
													
		
		-- Accorpo il risultato ottenuto con eventuali altre righe di ricerche 
			if exists( select top 1 * from  #TempRicerca )
			begin			
				insert into #AziResult( IdAzi , NumeroRiga )
					select idAzi , '' from #TempRicerca where idAzi not in ( select idazi from #AziResult )
					update #AziResult set NumeroRiga = NumeroRiga + ', ' + cast( @NumeroRiga as varchar(10))
						where idazi in ( select idAzi from  #TempRicerca )
			
			end
		

		FETCH NEXT FROM CurRowRicerca 	INTO  @Row , @IdRow
	END 
	CLOSE CurRowRicerca
	DEALLOCATE CurRowRicerca	


	--select * from #AziResult


	
	update #AziResult set NumeroRiga = substring( NumeroRiga , 3 , 200 )

	-- Recupero il codice fiscale dell'azienda collegata per escluderla dalla ricerca delle aziende
	-- (caso d'uso ente censito anche come oe)
	--select top 1 @codFiscAzi = attr.vatValore_FT
	--   from profiliutente pfu
	--   	INNER JOIN aziende azi ON pfu.pfuidazi = azi.idazi
	--	INNER JOIN DM_attributi attr ON attr.lnk = azi.idazi and dztnome = 'codicefiscale' and isnull(attr.vatValore_FT,'') <> ''
	--	where pfu.idpfu = @IdUser 			


	-- travaso il risultato sul documento
	insert into CTL_DOC_Destinatari 
			( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale )
		select @idDoc, null , a.IdAzi, aziRagioneSociale, aziPartitaIVA,  aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, '' as CDDStato, 'includi' as Seleziona, NumeroRiga, d1.vatValore_FT as CodiceFiscale
			from aziende a
			inner join #AziResult t on a.idAzi = t.idAzi
				left outer join DM_Attributi d1 on d1.lnk = a.idazi and d1.dztNome = 'CodiceFiscale' and d1.idapp = 1
			--left outer join DM_Attributi d2 on d2.lnk = a.idazi and d2.dztNome = 'EmailRapLeg' and d2.idapp = 1
			--where d1.vatValore_FT <> @codFiscAzi
		order by d1.vatValore_FT  asc , aziRagioneSociale asc
		--order by aziRagioneSociale asc
			

	--prendo i CF degli enti dove è presente un Referente
	select CodiceFiscale into #TempCF from RICERCA_ENTI_ESITI_DESTINATARI where idheader = @idDoc and PresenzaReferente = 1

	
	-- elimino per gli stessi enti le aziende dove non è presente il referente
	delete from CTL_DOC_Destinatari 
		where idrow in (
						select idrow 
							from RICERCA_ENTI_ESITI_DESTINATARI 
							where idheader = @idDoc and PresenzaReferente = 0 
								and CodiceFiscale in ( select CodiceFiscale from #TempCF )
			)
			and idheader = @idDoc

	declare @C int
	--select @C = count(*) from #AziResult
	select @C = count(*) from CTL_DOC_Destinatari where idheader = @idDoc
	 
	delete from CTL_DOC_Value where IdHeader = @IdDoc and DSE_ID = 'BOTTONE' and DZT_Name = 'NumRighe'
	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
		values( @IdDoc , 'BOTTONE' , 0 , 'NumRighe' , cast ( @C as varchar(10)) )
	
	-- cancello le tabelle temporanee
	drop table #TempRicerca
	drop table #AziResult

END




















GO
