USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_RICERCA_OE_ESTRAZIONE_AZIENDE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_RICERCA_OE_ESTRAZIONE_AZIENDE] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;

	declare @AttrName		varchar(max) 
	declare @AttrValue		varchar(max) 
	declare @AttrOp 		varchar(max)   
	declare @Filter			varchar(1000)  
	declare @Sort			varchar(1000)  
	declare @codFiscAzi     varchar(1000)
	declare @ListaAlbi as nvarchar(4000)
	declare @classivalide nvarchar(max)
	declare @TipoProceduraCaratteristica varchar(100)
	declare @idBando int
	declare @idBando_lavori int
	declare @TipoSelezionesoggetti varchar(50)

	declare @NumeroRiga int
	declare @idRow int
	declare @Row int
	declare @Cnt int
    declare @Top			int
	declare @Ente int 
	declare @TipoAppalto as varchar(50)
	declare @NumeroOperatoridaInvitare as int
	declare @NumeroOperatoriInvitati int
	declare @NumInviti int
	declare @NumOE int
	declare @rn int
	declare @PrevDoc int
	declare @NumeroOperatori int 
	declare @ret as int

	declare @ValMerc varchar(max)
	declare @ListaAlbiVal varchar(max)

	set @NumeroRiga = 0
	set @Filter = 'RICERCA_OE'
	set @Sort = ''
	set @Top = -1
	set @codFiscAzi = ''
	set @TipoProceduraCaratteristica=''
	set @classivalide=''
	set @ListaAlbi=''

	set @ValMerc = ''
	set @ListaAlbiVal = ''

	Select @TipoSelezioneSoggetti=value  from CTL_DOC_Value where idheader=@IdDoc and DSE_ID='BOTTONE' and dzt_name='TipoSelezioneSoggetti'


	
	
	--SE SONO PRESENTI RIMUOVE NELLA DOCUMENT_BANDO_INVITI_LAVORI I RECORD con idheader=idrow della destinatari
	delete from DOCUMENT_BANDO_INVITI_LAVORI where idHeader in (select idRow from CTL_DOC_Destinatari where idHeader=@idDoc)
	
	--ripulisco prima di eseguire la nuova ricerca
	delete CTL_DOC_Destinatari where IdHeader=@idDoc 
	--recupera @TipoProceduraCaratteristica per capire se RDO
	select  @TipoProceduraCaratteristica=TipoProceduraCaratteristica,
			@IdBando = linkeddoc,
			@PrevDoc=PrevDoc

		from ctl_doc 
			inner join document_bando on idHeader=LinkedDoc
		where id=@idDoc 
		  --aggiunto filtro su jumpcheck per essere sicuri di andare sui nuovi documenti e non sul documento generico
		  and isnull(JumpCheck,'')=''

	if @TipoProceduraCaratteristica = 'RDO' or @TipoProceduraCaratteristica = 'RFQ'
	BEGIN
		select @ListaAlbi=@ListaAlbi + '###' + value  from ctl_doc_value where idheader=@idDoc and DSE_ID='CRITERI' and dzt_name='ListaAlbi' and ISNULL(value,'') <> ''
		set @ListaAlbi = @ListaAlbi + '###'

		--insert into CTL_LOG_UTENTE 
		--(descrizione)
		--values
		--(@ListaAlbi)

		---solo se sono presenti classe sospese o revocate per uno degli albi
		IF EXISTS (select * from CTL_DOC_Value where IdHeader in (select * from dbo.Split(@ListaAlbi,'###')) and DSE_ID='CLASSI' and dzt_name='ClasseIscriz_MENO_Revocate_Sospese' )
		BEGIN
			select @classivalide=dbo.getclassiIscrizListaAlbi(@ListaAlbi)
		END
	END

	CREATE TABLE #AziResult(
		[IdAzi] [int] NULL,
		[NumeroRiga] [nvarchar](50) collate DATABASE_DEFAULT NULL,
	) 

	
	-- preparo la tabella temporanea per accogliere il risultato della ricerca
	--ATTENZIONE
	--QUESTA SELECT DEVE MANTENERE LA COERENZA CON LE COLONNE RITORNATE DALLA STORED DASHBOARD_SP_DOSSIER_AZI
	--
	select top 0 0 as IdAzi
	--, aziLog, aziDataCreazione, aziRagioneSociale, aziIdDscFormaSoc, aziPartitaIVA, aziE_Mail, aziAcquirente, aziVenditore, aziProspect, aziIndirizzoLeg, aziIndirizzoOp, aziLocalitaLeg, aziLocalitaOp, aziProvinciaLeg, aziProvinciaOp, aziStatoLeg, aziStatoOp, aziCAPLeg, aziCapOp, aziPrefisso, aziTelefono1, aziTelefono2, aziFAX, aziIdDscDescrizione, aziGphValueOper, aziDeleted, aziDBNumber, aziAtvAtecord, aziSitoWeb, aziCodEurocredit, aziProfili,  CertificatoIscrAtt, TipoDiAmministr ,
	--		cast( '' as  varchar(250)) as CodiceFiscale , 
	--		cast( '' as varchar(250)) as EmailRapLeg , 
	--		cast( '' as varchar(250)) as CARBelongTo , 
	--		cast( '' as varchar(250)) as CancellatoDiUfficio , 
	--		cast( '' as varchar(max)) as ClasseIscriz,
	--		cast( '' as varchar(500)) as iscrittoPeppol,
	--	     cast( '' as varchar(500)) as PARTICIPANTID,
	--		 cast( '' as varchar(500)) as CodiceComune,
	--	     cast( '' as varchar(500)) as CodiceProvincia

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
		

		exec RICERCA_OE_RECUPERA_CRITERI_DI_RICERCA  @IdDoc , @Row  , @AttrName	output, @AttrValue	output, @AttrOp 	output 
		

		if @TipoProceduraCaratteristica = 'RDO' and @classivalide <> ''    ---solo se sono presenti classe sospese o revocate per uno degli albi
		BEGIN
			set @AttrName=@AttrName + '#@#ClasseIscrizFILTRO'
			set @AttrValue=@AttrValue + '#@#''' + @classivalide + ''''
			set @AttrOp=@AttrOp + '#@# = ' 
		END

		--print '@AttrName=' + @AttrName
		--print '@@AttrValue=' + @AttrValue
		--print '@@AttrOp=' + @AttrOp


		if @TipoProceduraCaratteristica = 'RFQ'
		begin
			--ClasseIscriz#@#aziRagioneSociale	
			--'###9###4###5###6###'#@#'%%%'
			--= #@# like 
			declare @pos int

			set @ValMerc = ''
			set @ListaAlbiVal = ''

			if CHARINDEX ( 'ClasseIscriz', @AttrName ,   1) > 0
			begin
				
				set @pos = dbo.GetPosStrInSplitByVal(@AttrName,'#@#','ClasseIscriz')
				if @pos>0
				begin
					
					set @ValMerc = dbo.GetPos ( @AttrValue , '#@#', @pos)
					
					set @AttrName=dbo.ReplaceStrInSplitByPos(@AttrName,'#@#',@pos ,'aziRagioneSociale')  
					set @AttrValue=dbo.ReplaceStrInSplitByPos(@AttrValue,'#@#',@pos ,'''%%%''')  
					set @AttrOp=dbo.ReplaceStrInSplitByPos(@AttrOp,'#@#',@pos ,' like ')  
				end
			end

			if CHARINDEX ( 'ListaAlbi', @AttrName ,   1) > 0
			begin
				
				set @pos = dbo.GetPosStrInSplitByVal(@AttrName,'#@#','ListaAlbi')
				if @pos>0
				begin
					
					set @ListaAlbiVal = dbo.GetPos ( @AttrValue , '#@#', @pos)
					
					set @AttrName=dbo.ReplaceStrInSplitByPos(@AttrName,'#@#',@pos ,'aziRagioneSociale')  
					set @AttrValue=dbo.ReplaceStrInSplitByPos(@AttrValue,'#@#',@pos ,'''%%%''')  
					set @AttrOp=dbo.ReplaceStrInSplitByPos(@AttrOp,'#@#',@pos ,' like ')  
				end
			end




		end

		
		if @AttrName <> '' 
		begin		

			--insert into CTL_LOG_UTENTE 
			--	(paginaDiArrivo ,paginaDiPartenza )
			--values
			--	(@ListaAlbiVal,'')
			
			
			-- invoco la ricerca degli OE dal Dossier
			delete from #TempRicerca
			insert into #TempRicerca exec DASHBOARD_SP_DOSSIER_AZI 
													 @IdUser						,
													 @AttrName						,
													 @AttrValue						,
													 @AttrOp 						,
													 @Filter                        ,
													 @Sort                          ,
													 @Top                           ,
													 @Cnt                           output
													
			
			declare @FilterMerc varchar(max)
			declare @mySQL varchar(max)

			if @TipoProceduraCaratteristica = 'RFQ' and  @ValMerc <> '' and exists( select top 1 * from  #TempRicerca )
			begin
				
				

				set @FilterMerc = ''

				
				select @FilterMerc = 'MercForn like ''%###' +  items + '###%'' OR ' + @FilterMerc  
							from dbo.split(@ValMerc,'###') where items <> ''''

				if len(@FilterMerc) > 4
					set @FilterMerc = SUBSTRING( @FilterMerc, 1, len(@FilterMerc)-3 ) 

				if @FilterMerc <> ''
				begin
					
					
					
					set @mySQL = 'delete from #TempRicerca where idazi not in ( select idazi from Document_Questionario_Fornitore_Punteggi 	where StatoAbilitazione = ''Qualificato'' and ( ' + @FilterMerc + '))'
					exec (@mySQL)	
					
					
					
													

				end

			end

			if @TipoProceduraCaratteristica = 'RFQ' and  @ListaAlbiVal <> '' and exists( select top 1 * from  #TempRicerca )
			begin
				
				

				set @ListaAlbiVal = replace(@ListaAlbiVal,'''','')
					
					
				set @mySQL = 'delete from #TempRicerca where idazi not in ( select idazi from Document_Questionario_Fornitore_Punteggi where idHeader = ' + @ListaAlbiVal + ')'
				exec (@mySQL)	
				

			end
			
			
			-- Accorpo il risultato ottenuto con eventuali altre righe di ricerche 
			if exists( select top 1 * from  #TempRicerca )
			begin
			
				insert into #AziResult( IdAzi , NumeroRiga )
					select idAzi , '' from #TempRicerca where idAzi not in ( select idazi from #AziResult )
					update #AziResult set NumeroRiga = NumeroRiga + ', ' + cast( @NumeroRiga as varchar(10))
						where idazi in ( select idAzi from  #TempRicerca )
			
			end
			
		end
		


		FETCH NEXT FROM CurRowRicerca 	INTO  @Row , @IdRow
	END 

	CLOSE CurRowRicerca
	DEALLOCATE CurRowRicerca	
	
	
	update #AziResult set NumeroRiga = substring( NumeroRiga , 3 , 200 )

	-- Recupero il codice fiscale dell'azienda collegata per escluderla dalla ricerca delle aziende
	-- (caso d'uso ente censito anche come oe)
	select top 1 @codFiscAzi = attr.vatValore_FT
	    from profiliutente pfu
					INNER JOIN aziende azi ON pfu.pfuidazi = azi.idazi
					INNER JOIN DM_attributi attr ON attr.lnk = azi.idazi and dztnome = 'codicefiscale' and isnull(attr.vatValore_FT,'') <> ''
		where pfu.idpfu = @IdUser 			

    
    declare @CampoEmail as varchar(500)

    set @CampoEmail = 'aziE_Mail'

    IF EXISTS ( select * from CTL_RELATIONS where REL_TYPE='RICERCA_OE_ESTRAZIONE_AZIENDE' and REL_VALUEINPUT='CampoEmail' )
    BEGIN
	   select top 1 @CampoEmail=REL_VALUEOUTPUT from CTL_RELATIONS where REL_TYPE='RICERCA_OE_ESTRAZIONE_AZIENDE' and REL_VALUEINPUT='CampoEmail'
    END 


	-- Algoritmo per la ROTAZIONE2
	if @TipoSelezionesoggetti = 'rotazione2'
	begin
		declare @categoriaSOA as varchar(200)
		declare @categoriaSOA_PREV_DOC as varchar(200)
		declare @classificaSOA as varchar(200)
		
		--PRENDO LE INFO DALLA MIA RICERCA OE, VISTO CHE SULLA CLICK RICERCA VENGONO STATICIZZATI SUL DOC		
		select @categoriaSOA=value from CTL_DOC_Value with(nolock) where  IdHeader=@idDoc and DSE_ID='InfoTec_CategoriaPrevalente' and DZT_Name='CategoriaSOA' and Row=0
		select @classificaSOA=value from CTL_DOC_Value with(nolock) where  IdHeader=@idDoc and DSE_ID='InfoTec_CategoriaPrevalente' and DZT_Name='classificaSOA' and Row=0
		
		--SE PREV_DOC E' VALORIZZATO, RECUPERO LA CATEGORIASOA DEL VECCHIO, SE é UGUALE A QUELLA DEL DOCUMENTO CORRENTE 
		--DOBBIAMO STORNARE DAL NUMERO INVITI
		--if ISNULL(@PrevDoc,0)>0
		--BEGIN
		--	select @categoriaSOA_PREV_DOC=value from CTL_DOC_Value with(nolock) where  IdHeader=@PrevDoc and DSE_ID='InfoTec_CategoriaPrevalente' and DZT_Name='CategoriaSOA' and Row=0
		--END

		--OLD somma di tutti gli inviti per ogni classifica della categoria prevalente 
		--somma di tutti gli inviti per ogni categoria e classifica 
		select 
				DL.idAzi,
				--case 
				--	when min(CD.IdAzi) IS NULL then SUM(ISNULL(DL.NumInvitiReali,0)) 
				--	else SUM(ISNULL(DL.NumInvitiReali,0)) - 1 
				--end as NumInvitiReali  
				SUM(ISNULL(DL.NumInvitiReali,0)) as NumInvitiReali  
				into #temp_tot_inviti_reali
			from #AziResult A with(nolock) 
				inner join DOCUMENT_BANDO_INVITI_LAVORI DL with(nolock)  on DL.idAzi=A.idAzi and ISNULL(DL.idHeader,0) = 0 --and DL.CategoriaSOA=@categoriaSOA
				--left join CTL_DOC_Destinatari CD with(nolock) on CD.IdAzi=A.IdAzi and CD.idHeader=@PrevDoc and Seleziona='Includi'  
				--		   and @categoriaSOA=@categoriaSOA_PREV_DOC

			group by DL.idAzi

		-- inviti virtuali ottenuti per la classifica categoria prevalente
		select  DL.idAzi,SUM(ISNULL(DL.NumInvitiVirtuali,0)) as NumInvitiVirtuali  into #temp_tot_inviti_virtuali		
			from #AziResult A with(nolock) 
				inner join DOCUMENT_BANDO_INVITI_LAVORI DL with(nolock)  on ISNULL(DL.idHeader,0) =0 and DL.idAzi=A.idAzi and DL.CategoriaSOA=@categoriaSOA and DL.ClassificaSOA=@classificaSOA
			group by DL.idAzi		

		--prendo unico albo lavori pubblicato
		select top 1 @idBando_lavori=Id from ctl_doc with(nolock) where TipoDoc='BANDO' and Deleted=0 and JumpCheck='BANDO_ALBO_LAVORI' and StatoFunzionale='Pubblicato'


		-- calcolo il numero di inviti virtuali per la categoria prevalente nel caso in cui un fornitore non è iscritto per quella categoria
		declare @Classifica_3 varchar(50)
		declare @N_I_V  int 

		select @Classifica_3 = dmv_cod  from ( 	select dmv_cod , ROW_NUMBER() over (order by dmv_cod ) as o from GESTIONE_DOMINIO_ClassificaSOA_ML_LNG where ml_lng = 'i' 	) as a where o = 3
		-- prendo il massimo numero di inviti
		select @N_I_V = max( N_I) 
					from ( 
						-- sommo gli inviti reali dalla terza classifica per ogni OE
						select i.idazi , sum( isnull( i.NumInvitiReali , 0 ) ) as N_I from DOCUMENT_BANDO_INVITI_LAVORI i with(nolock) where isnull( idheader , 0 ) = 0 and i.CategoriaSOA = @categoriaSOA and i.ClassificaSOA >= @Classifica_3 group by i.idAzi 
					) as A


		--SOMMA GLI INVITI
		select t.idAzi , SUM( ISNULL(inviti_r.NumInvitiReali,0) + ISNULL(inviti_v.NumInvitiVirtuali,@N_I_V) ) as TOT_INVITI ,100000000 as Numriga 
			into #temp_tot_inviti
			from #AziResult t
				left join #temp_tot_inviti_reali inviti_r on inviti_r.idAzi=t.IdAzi
				left join #temp_tot_inviti_virtuali inviti_v on inviti_v.idAzi=t.IdAzi
			group by t.idAzi
		
		drop table #temp_tot_inviti_reali
		drop table #temp_tot_inviti_virtuali

		--valorizzo la colonna Numriga prendendola dalla CTL_DOC_Destinatari PER IL BANDO INDIVIDUATO SOPRA
		update T set Numriga=CD.NumRiga
			from #temp_tot_inviti T
				inner join CTL_DOC_Destinatari CD on CD.idHeader=@idBando_lavori and CD.StatoIscrizione in ( 'Iscritto','Sospeso') and CD.IdAzi=T.IdAzi 
	
	   --valorizzo la colonna Numriga prendendola dalla CTL_DOC_Destinatari PER ALTRI BANDI 
		update T set Numriga=CD.NumRiga
			from #temp_tot_inviti T
				inner join CTL_DOC_Destinatari CD on CD.StatoIscrizione in ( 'Iscritto','Sospeso') and CD.IdAzi=T.IdAzi 
				inner join CTL_DOC D on D.Id=CD.idHeader and D.TipoDoc='BANDO' and  D.Deleted=0 and D.JumpCheck='BANDO_ALBO_LAVORI' and D.StatoFunzionale='Pubblicato' 
			where T.Numriga=100000000
		
	end



	
	-- travaso il risultato sul documento
	select top 0 * into #CTL_DOC_Destinatari from CTL_DOC_Destinatari

	insert into #CTL_DOC_Destinatari 
			( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale )
		select @idDoc, null , a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, case when @CampoEmail = 'aziE_Mail' then a.aziE_Mail else d2.vatValore_FT end as aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, '' as CDDStato, 'includi' as Seleziona, t.NumeroRiga + case when extra.idrow is not null and extra.tipodoc='DOMANDA_PARTECIPAZIONE' then ', D' when extra.idrow is not null and extra.tipodoc <>  'DOMANDA_PARTECIPAZIONE' then ', M' else '' end, d1.vatValore_FT as CodiceFiscale
			from aziende a
				inner join #AziResult t on a.idAzi = t.idAzi and isnull(a.daValutare,0) = 0
				left outer join DM_Attributi d1 on d1.lnk = a.idazi and d1.dztNome = 'CodiceFiscale' and d1.idapp = 1
				left outer join DM_Attributi d2 on d2.lnk = a.idazi and d2.dztNome = @CampoEmail and d2.idapp = 1
				left join CTL_DOC_Destinatari_View_interessati extra ON extra.idBando = @IdBando and extra.IdAzi = a.IdAzi						
			where d1.vatValore_FT <> @codFiscAzi
			order by a.aziRagioneSociale  asc
			
			--case when @TipoSelezionesoggetti = 'rotazione2' then TOT_INVITI.TOT_INVITI  else a.aziRagioneSociale end asc
			
	--  Aggiungo in automatico nel risultato della ricerca i partecipanti 
	--  selezionati dal primo giro ( proveniente dalle manifestazioni di interesse ). Come numero riga mettiamo la lettera "M"
	insert into #CTL_DOC_Destinatari 
			( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale )
		select @idDoc, null , a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail , a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, '' as CDDStato, 'includi' as Seleziona, case when a.tipodoc='DOMANDA_PARTECIPAZIONE' THEN 'D' else 'M' end , d1.vatValore_FT as CodiceFiscale
			from CTL_DOC_Destinatari_View_interessati a
					left outer join DM_Attributi d1 on d1.lnk = a.idazi and d1.dztNome = 'CodiceFiscale' and d1.idapp = 1
					left join CTL_DOC_Destinatari dest with(nolock) ON dest.idHeader = @idDoc and dest.CodiceFiscale = d1.vatValore_FT
					left join #CTL_DOC_Destinatari dest_t with(nolock) ON dest_t.idHeader = @idDoc and dest_t.IdAzi = a.IdAzi
			where a.idBando = @IdBando and dest.idrow is null and dest_t.IdAzi is null
			order by a.aziRagioneSociale asc
	
	--TRAVASO I FORNITORI TROVATI DALLA RICERCA ORDINATI PER IL CRITERIO	
	if @TipoSelezionesoggetti = 'rotazione2'
	begin
		insert into CTL_DOC_Destinatari 
				( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale,NumeroInviti, [DataConferma])
			select  idHeader, IdPfu, a.IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, TOT_INVITI.NumRiga, CodiceFiscale,TOT_INVITI.TOT_INVITI,GETDATE()
				from #CTL_DOC_Destinatari a
					left join #temp_tot_inviti TOT_INVITI on TOT_INVITI.IdAzi=a.IdAzi
				order by TOT_INVITI.TOT_INVITI,TOT_INVITI.Numriga asc
	end
	else
	begin
		insert into CTL_DOC_Destinatari 
				( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale ,[DataConferma])
			select  idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, CodiceFiscale , GETDATE()
				from #CTL_DOC_Destinatari a
				order by a.aziRagioneSociale asc
	end



	declare @C int
	
	--select @C = count(*) from #AziResult

	select @C = count(*) from CTL_DOC_Destinatari where idHeader=@idDoc

	delete from CTL_DOC_Value where IdHeader = @IdDoc and DSE_ID = 'BOTTONE' and DZT_Name = 'NumRighe'

	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
		values( @IdDoc , 'BOTTONE' , 0 , 'NumRighe' , cast ( @C as varchar(10)) )


	

	
	if @TipoSelezionesoggetti <> 'rotazione2'
	begin
		--recupero TipoAppalto dalla ricerca
		select @idBando = linkeddoc from ctl_doc where id = @idDoc
		select @TipoAppalto=TipoAppaltoGara from document_bando where idheader=@idBando 
		select @Ente = azienda from ctl_doc where id = @idBando 

		--inizializzo a 0 numeroinviti e metto tutti esclusi
		update CTL_DOC_Destinatari  set NumeroInviti = 0 where idheader=@IdDoc 

		--per ogni azienda presente nella tabella Document_Rotazione_Inviti recupero NumeroInviti
		update CTL_DOC_Destinatari 
			set NumeroInviti=DR.NumeroInviti
			from Document_Rotazione_Inviti DR
					inner join CTL_DOC_Destinatari CD on DR.idazi=CD.idazi and DR.tipoappalto=@TipoAppalto
				where CD.idheader=@IdDoc and DR.idEnte = @Ente
	end

	-- Algoritmo per la ROTAZIONE
	if @TipoSelezionesoggetti = 'rotazione'
	begin



		--inizializzo a 0 numeroinviti e metto tutti esclusi
		update CTL_DOC_Destinatari  set Seleziona = 'escludi'  where idheader=@IdDoc 


		--recupero il NumeroOperatoridaInvitare
		Select @NumeroOperatoridaInvitare=value  from CTL_DOC_Value where idheader=@IdDoc and DSE_ID='BOTTONE' and dzt_name='NumeroOperatoridaInvitare'


		-- se il numero di fornitori è >= al numero di operatori richiesti applico il criterio richiesto
		select @NumeroOperatori = count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc 

		--if (select count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc ) >= @NumeroOperatoridaInvitare 
		begin

			set @NumeroOperatoriInvitati = 0
			select  @NumInviti = min ( [NumeroInviti] ) from CTL_DOC_Destinatari where idheader=@IdDoc 

			-- finche non ho terminato di selezionare gli operatori da invitare			
			while @NumeroOperatoriInvitati < @NumeroOperatoridaInvitare and @NumeroOperatoriInvitati < @NumeroOperatori
			begin


				-- recupero il numero di OE che hanno il numero di inviti minimo
				select @NumOE = count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc and [NumeroInviti] = @NumInviti 

				-- se il numero di operatori disponibili con il numero di inviti richiesto 
				-- è inferiore o uguale al numero di operatori da invitare li invito tutti 
				if @NumOE <= @NumeroOperatoridaInvitare - @NumeroOperatoriInvitati 
				begin
					
					update CTL_DOC_Destinatari 
						set Seleziona ='includi'
						where  idheader = @IdDoc and [NumeroInviti] = @NumInviti

					set @NumeroOperatoriInvitati = @NumeroOperatoriInvitati + @NumOE

				end
				else
				begin --  atrimenti il numero di OE è maggiore di quello richiesto e procedo a sorteggiarli
				
				
					declare  @aziRND TABLE ( [IdAzi] [int] NULL, [ix] [int] NOT NULL IDENTITY(1,1) ) 
					insert into @aziRND ( idAzi ) select idazi from CTL_DOC_Destinatari where  idheader = @IdDoc and [NumeroInviti] = @NumInviti 

					-- finchè non ho raggiunto il numero di operatori da invitare
					while  @NumeroOperatoridaInvitare >  ( select count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc and  Seleziona = 'includi' ) 
					begin 

						set @rn=CAST(RAND(CHECKSUM(NEWID())) * @NumOE as INT) + 1

						update CTL_DOC_Destinatari 
							set Seleziona ='includi'
							where idheader = @IdDoc 
								 and Seleziona <> 'includi'
								 and idazi=(select idazi from @aziRND where ix =  @rn ) 

					end 

					set @NumeroOperatoriInvitati = @NumeroOperatoridaInvitare
				end		

				-- aumento il livello da cui prendere gli OE da invitare
				set @NumInviti = @NumInviti + 1
			
			end


		end
	end

	-- Algoritmo per la ROTAZIONE2
	if @TipoSelezionesoggetti = 'rotazione2'
	begin

		--inizializzo a 0 numeroinviti e metto tutti esclusi
		update CTL_DOC_Destinatari  set Seleziona = 'escludi'  where idheader=@IdDoc 

		--recupero il NumeroOperatoridaInvitare
		Select @NumeroOperatoridaInvitare=value  from CTL_DOC_Value where idheader=@IdDoc and DSE_ID='BOTTONE' and dzt_name='NumeroOperatoridaInvitare'

		-- se il numero di fornitori è >= al numero di operatori richiesti applico il criterio richiesto
		select @NumeroOperatori = count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc 

		--if (select count(*) from CTL_DOC_Destinatari where  idheader = @IdDoc ) >= @NumeroOperatoridaInvitare 
		begin

			set @NumeroOperatoriInvitati = 0
			
			-- finche non ho terminato di selezionare gli operatori da invitare			
			while @NumeroOperatoriInvitati < @NumeroOperatoridaInvitare and @NumeroOperatoriInvitati < @NumeroOperatori
			begin
				select  @idrow = min ( idrow ) 
				from CTL_DOC_Destinatari 
				where idheader=@IdDoc and Seleziona = 'escludi' 
				--order by idrow asc

				update CTL_DOC_Destinatari 
						set Seleziona ='includi'
					where idrow=@idRow


					set @NumeroOperatoriInvitati = @NumeroOperatoriInvitati + 1
			end		

			
		end

		
		-- popoliamo i dati necessari al report ovvero tuttii record che servono al conteggio per ottenere il numero di inviti totali necessari per l'ordinamento utile al sorteggio
		 
		insert into DOCUMENT_BANDO_INVITI_LAVORI (  [idHeader], [idAzi], [CategoriaSOA], [ClassificaSOA], [NumInvitiVirtuali],  NumInvitiReali , Iscritto )
			select CD.idrow,CD.IdAzi,[CategoriaSOA], [ClassificaSOA], case when ( @categoriaSOA = [CategoriaSOA] and  @classificaSOA = [ClassificaSOA] ) then [NumInvitiVirtuali] else null end as   NumInvitiVirtuali , NumInvitiReali , Iscritto 
				from CTL_DOC_Destinatari CD
					inner join DOCUMENT_BANDO_INVITI_LAVORI DI on DI.idAzi=CD.IdAzi and DI.idHeader =0 and ( DI.NumInvitiReali > 0 or ( @categoriaSOA = [CategoriaSOA] and  @classificaSOA = [ClassificaSOA] ))
						where CD.idHeader=@IdDoc 
					order by CD.idrow,[CategoriaSOA],ClassificaSOA

				
	end



	--Algoritmo per sorteggio territoriale
	if @TipoSelezionesoggetti = 'sorteggioterritoriale'
	begin
		--inizializzo a 0 numeroinviti e metto tutti esclusi
		update CTL_DOC_Destinatari  set Seleziona = 'escludi'  where idheader=@IdDoc 

		--chiamo una stored che effettua algoritmo per il sorteggio territoriale
		exec APPLICA_SORTEGGIO_TERRITORIALE @IdDoc,@ret out

	end
	

	-- cancello le tabelle temporanee
	drop table #TempRicerca
	drop table #AziResult






END
























GO
