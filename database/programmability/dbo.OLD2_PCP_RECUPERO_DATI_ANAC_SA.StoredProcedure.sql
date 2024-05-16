USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_PCP_RECUPERO_DATI_ANAC_SA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[OLD2_PCP_RECUPERO_DATI_ANAC_SA] 	(@idDoc int,  @contesto varchar(500) = 'Comunica appalto', @servizio varchar(500) = '/crea-appalto')
as
begin
	SET NOCOUNT ON;
	declare @cfRP as varchar(16)
	declare @cfSA as varchar(16)
	declare @codAUSA as bigint -- non so quanto è lungo 
	declare @centroCosto as varchar(100)
	declare @id as int
	declare @purposeId as varchar(60)
	declare @endpointOut as varchar(200)
	declare @kid as varchar(100)
	declare @idAzi as int
	declare @codiceAUSA as varchar(30)
	declare @codicePiattaforma as varchar(50)
	declare @userLoa as int
	declare @IdTipoUtente as varchar(30)
	declare @clientId as varchar(200)
	declare @BusinessflowID as varchar(100)
	declare @SpanID as varchar(100)
	declare @traceID as varchar(100)
	declare @funzioniSvolte as nvarchar(100)
	declare @PCP_regCodiceComponente as nvarchar(100)

	declare @urlAuth as nvarchar(max)
	declare @audAuth as nvarchar(max)
	declare @PemPrivateKey as nvarchar(max)

	declare @dataLogin datetime
	declare @dataLogout datetime

	declare @CriterioControllo as varchar(100)
	declare @Da_X_Giorni as int

	declare @DMin datetime
	declare @DMax datetime

	declare @Rup				int
	declare @Ente				int
	declare @RupProponente		int
	declare @EnteProponente 	int
	declare @Delegato_PCP		int
	declare @EnteDelegato_PCP	int
	declare @CDCDelegato_PCP	varchar( 100 )
	declare @CDC				varchar( 100 )
	declare @CDCProponente		varchar( 100 )
	declare @TipoDoc_Innesco as varchar(200)

	select @TipoDoc_Innesco = TipoDoc from CTL_DOC with (nolock) where Id = @idDoc 


	set @Delegato_PCP = 0
	set @Rup = 0
	
	declare @Tipo_Rup as varchar(100)

	select @Tipo_Rup=dbo.PARAMETRI ('SIMOG','TIPO_RUP','DefaultValue','UserRUP',-1) 


	-------------------------------------------------------------------------------------	
	-- dal documento indicato si recuperano RUP,Ente e  Centro di costo riferito all'utente delegato
	-- questo puo essere inizialmente,  in funzione di un parametro, il rup appaltante oppure il rup proponente
	-- il crea appalto è il primo step di chiamate ed è quello che azzera il riferimento per poterlo riutilizzare
	-- sulle chiamate successive
	-------------------------------------------------------------------------------------	


	-- in caso di crea appalto cancello un precedente utente delegato perchè solo il rup puo creare l'appalto
	if @servizio = '/crea-appalto'
	begin
		set @Delegato_PCP = null
		set @EnteDelegato_PCP = null
		set @CDCDelegato_PCP = null
	end
	else
	begin
		-- recupero l'utente con il quale effettuare le chiamate alla PCP
		select @Delegato_PCP = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'Delegato_PCP' 
		select @EnteDelegato_PCP = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'EnteDelegato_PCP' 
		select @CDCDelegato_PCP = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'CDCDelegato_PCP' 
	end


	
	-- se l'utente non è definito
	if isnull( @Delegato_PCP , 0 ) = 0
	begin

		-- per preservare le gare che non avevano ancora il parametro del tipo rup se non è crea appalto usiamo il rup espletante se non ho definito in precedenza l'utente
		if @servizio <> '/crea-appalto'
		begin
			select @Delegato_PCP = Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'InfoTec_comune' and dzt_name = @Tipo_Rup 
			
			select 
					@EnteDelegato_PCP = azienda ,
					@CDCDelegato_PCP = ap.pcp_CodiceCentroDiCosto
				from CTL_DOC b with(nolock) 
					left join Document_PCP_Appalto ap  with (nolock) on b.id = ap.idHeader
				where id = @idDoc
		end
		else
		begin

			-- prendo l'utente per fare le chiamate alla PCP in funzione del parametro: Espletante oppure proponente
			if @Tipo_Rup='UserRUP'  -- ESPLETANTE / APPALTANTE
			begin
				
				--PER INNESCO DA ODC CAMBIA IL RECUPERO DEL RUP
				if @TipoDoc_Innesco ='ODC'
				begin
					select @Delegato_PCP = UserRUP from Document_ODC with(nolock) where RDA_ID=@idDoc
				end
				else
				begin
					select @Delegato_PCP = Value 
						from ctl_doc_value  with(nolock) 
						where idheader = @idDoc and dse_id = 'InfoTec_comune' and dzt_name = @Tipo_Rup 
				end

				select 
						@EnteDelegato_PCP = azienda ,
						@CDCDelegato_PCP = ap.pcp_CodiceCentroDiCosto
					from CTL_DOC b with(nolock) 
						left join Document_PCP_Appalto ap  with (nolock) on b.id = ap.idHeader
					where id = @idDoc
			end
			else
			begin  -- PROPONENTE / RICHIEDENTE
				
				select 
						@Delegato_PCP = RupProponente , 
						@EnteDelegato_PCP = dbo.GetPos ( EnteProponente , '#' , 1 ) ,
						@CDCDelegato_PCP = pcp_CodiceCentroDiCostoProponente
					from document_bando  with(nolock) where idheader = @idDoc 
			end

		end

		-- se non ho recuperato il RUP allora prendo quello appaltante / Espletante
		if isnull( @Delegato_PCP , 0 ) = 0 
		begin
			
			--select @Delegato_PCP = Value 
			--	from ctl_doc_value  with(nolock) 
			--	where idheader = @idDoc and dse_id = 'InfoTec_comune' and dzt_name = 'UserRUP'
				
			--PER INNESCO DA ODC CAMBIA IL RECUPERO DEL RUP
			if @TipoDoc_Innesco ='ODC'
			begin
				select @Delegato_PCP = UserRUP from Document_ODC with(nolock) where RDA_ID=@idDoc
			end
			else
			begin
				select @Delegato_PCP = Value 
					from ctl_doc_value  with(nolock) 
					where idheader = @idDoc and dse_id = 'InfoTec_comune' and dzt_name = 'UserRUP' 
			end

			select 
					@EnteDelegato_PCP = azienda ,
					@CDCDelegato_PCP = ap.pcp_CodiceCentroDiCosto
				from CTL_DOC b with(nolock) 
					left join Document_PCP_Appalto ap  with (nolock) on b.id = ap.idHeader
				where id = @idDoc

		end

	end


	---- memorizzo sulla procedura l'utente trovato per riutilizzarlo sulle chiamate successive
	--if not exists( select Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'Delegato_PCP'  )
	--	insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
	--		select @idDoc as [IdHeader], 'Delegato_PCP' as [DSE_ID], 0 as [Row], 'Delegato_PCP' as [DZT_Name], @Delegato_PCP as [Value] 
	--else
	--	update ctl_doc_value  set value =  @Delegato_PCP where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'Delegato_PCP'  



	--if not exists( select Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'EnteDelegato_PCP'  )
	--	insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
	--		select @idDoc as [IdHeader], 'Delegato_PCP' as [DSE_ID], 0 as [Row], 'EnteDelegato_PCP' as [DZT_Name], @EnteDelegato_PCP as [Value] 
	--else
	--	update ctl_doc_value  set value =  @EnteDelegato_PCP where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'EnteDelegato_PCP'  



	--if not exists( select Value from ctl_doc_value  with(nolock) where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'CDCDelegato_PCP'  )
	--	insert into ctl_doc_value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) 
	--		select @idDoc as [IdHeader], 'Delegato_PCP' as [DSE_ID], 0 as [Row], 'CDCDelegato_PCP' as [DZT_Name], @CDCDelegato_PCP as [Value] 
	--else
	--	update ctl_doc_value  set value =  @CDCDelegato_PCP where idheader = @idDoc and dse_id = 'Delegato_PCP' and dzt_name = 'CDCDelegato_PCP'  




	-- manca l'uso




	--set @cfRP = 'USRRUP20A01A110A'
	SELECT    @cfSA = cf.vatValore_FT-- a.aziPartitaIVA
			, @idAzi = a.IdAzi
			, @cfRP = p.pfuCodiceFiscale
			, @id = b.IdDoc
			, @purposeId = c.PurposeId
			, @kid = c.Kid 
			, @endpointOut = c.BaseAddress
			
			--recupero codice_ausa dalla document_pcp_appalto
			--se non lo trovo le prendo come adesso

			, @codiceAUSA =  case 
								when isnull(ap.pcp_codice_ausa,'') = '' then  au.codice_ausa
								when ap.pcp_codice_ausa = '' then au.codice_ausa
								else ap.pcp_codice_ausa
							end 
			
			, @codicePiattaforma = an.CodicePiattaformaAnac
	
			--- utenteRUP
			, @IdTipoUtente = 'SPID' --an.IdTipoUtente
			, @userLoa = '3' --an.userLoa

			-- 
			, @clientId = c.clientId
			--, @centroCosto = ap.pcp_CodiceCentroDiCosto
			
			, @BusinessflowID = case when isnull( ap.pcp_CodiceAppalto , '' ) = '' 
							then   '00000000-0000-0000-0000-000000000000' 
							else  ap.pcp_CodiceAppalto  end

			, @traceID = cast( newid() as varchar(100)) 

			--QUANDO GARA DUE FASI DEVO RECUPERARE GUID DELLA GARA PRIMO GIRO (AVVISO/BANDO)
			, @SpanID = 
				case	
				
					when  
						(
							( G.proceduragara ='15477' and G.TipobandoGara='2' ) --BANDO -RISTRETTA
							or 
							( G.proceduragara ='15478' and G.TipobandoGara='1' ) --AVVISO - NEGOZIATA
						) --GUID DEL PRIMO GIRO
						then cast( AV.GUID as varchar(100)) 

					else cast( B.GUID as varchar(100)) 
				end 

			, @funzioniSvolte = isnull(pcp_FunzioniSvolte,'')
			, @PCP_regCodiceComponente = an.PCP_regCodiceComponente
			, @audAuth = an.audAuth
			, @urlAuth = an.urlAuth
			, @PemPrivateKey = an.PRIVATE_KEY
			, @dataLogin = p.pfuLastLogin
			, @dataLogout = isnull( p.pfuLastLogout , '2000-01-01T00:00:00' ) 

			, @CriterioControllo = isnull( CriterioControllo , 'Da_X_Giorni' ) 
			, @Da_X_Giorni = isnull( Da_X_Giorni , 30 ) 



		from ctl_doc B with (nolock)
				left join document_bando G  with (nolock) on G.idheader = B.id 
				--PROVO AD ANDARE SUL PRIMO GIRO
				left join ctl_doc AV with (nolock)  on AV.id = B.LinkedDoc and AV.deleted=0
				cross join PDND_Dati_ANAC an with (nolock) --on b.Azienda = an.IdAzi
				left join Aziende a on a.idAzi = @EnteDelegato_PCP--b.Azienda = a.IdAzi
				left join DM_Attributi CF  with(nolock) on cf.lnk = a.idazi and dztNome = 'codicefiscale' and cf.idapp = 1
				left join PCP_CodiciAUSA AU with(nolock) on au.codice_fiscale = cf.vatValore_FT
				--inner join CTL_DOC_Value  RUP  with (nolock) on rup.idheader = B.id and rup.DZT_Name = 'UserRup'
				left join ProfiliUtente P  with (nolock) on p.idpfu = @Delegato_PCP --rup.value = p.IdPfu

				--left join PDND_Contesti c  with (nolock) ON c.idAzi = a.IdAzi
				left join PDND_Contesti c  with (nolock) ON c.NomeContesto = @contesto

				left join PDND_Servizi S  with (nolock) ON C.IdContesti = s.IDContesto
				left join Document_PCP_Appalto ap  with (nolock) on b.id = ap.idHeader

		where b.Id = @idDoc and s.Endpoint = @servizio

		-- centro di costo recuperato in precedenza
		set @centroCosto = @CDCDelegato_PCP


    -- Insert statements for procedure here



	-- recupera livello e canale di accesso del RUP, di base vengono azzerati
	set @userLoa = '0'
	set @IdTipoUtente = ''
	

	---------------------------------------------------------
	-- recupero il LOA dalla sessione di attiva del RUP
	---------------------------------------------------------
	if @CriterioControllo = 'InSessione' 
	begin

		-- intervallo di controllo
	
		set @DMin = dateadd( ss , -5 , @dataLogin )
		set @DMax = dateadd( ss , 5 , @dataLogin )


		-- verifico se la sessione dell'utente è attiva -- se la data di ultima login è maggiore dell'ultimo logout vuol dire che ha iniziato una sessione di lavoro ancora aperta
		if @dataLogin >= @dataLogout
		begin 

			-- verifico che la sessione in corso sia stata attivata con uno strumento di autenticazione forte ( SPID )
			select top 1 
					@userLoa = LOA , @IdTipoUtente = Canale  
				from CTL_LOG_SPID with(nolock) 
				where HTTP_FISCALNUMBER = @cfRP and dataInsRecord >=  @DMin and dataInsRecord <= @DMax
				order by id desc

		end

	end



	---------------------------------------------------------
	-- recupero il LOA dalla sessione di attiva del RUP
	---------------------------------------------------------
	if @CriterioControllo = 'Da_X_Giorni' 
	begin

		set @DMin = dateadd( dd , - @Da_X_Giorni , getDate() )

		-- recupera il loa MAX
		select @userLoa = max( ISNULL(loa,'') ) 
			from CTL_LOG_SPID with(nolock) 
			where HTTP_FISCALNUMBER = @cfRP and dataInsRecord >=  @DMin 

		if @userLoa <> '0'
		begin
			-- recupera l'ultimo canale associato a quel loa
			select top 1 
					 @IdTipoUtente = Canale  
				from CTL_LOG_SPID with(nolock) 
				where HTTP_FISCALNUMBER = @cfRP and @userLoa = LOA
				order by id desc
		end

	end


	---------------------------------------------------------
	-- recupero il LOA dalla sessione di attiva del RUP
	---------------------------------------------------------
	if @CriterioControllo = 'AlmenoUnAccesso' 
	begin


		-- recupera il loa MAX
		select @userLoa = max( ISNULL(loa,'') ) 
			from CTL_LOG_SPID with(nolock) 
			where HTTP_FISCALNUMBER = @cfRP 

		if @userLoa <> '0'
		begin
			-- recupera l'ultimo canale associato a quel loa
			select top 1 
					 @IdTipoUtente = Canale  
				from CTL_LOG_SPID with(nolock) 
				where HTTP_FISCALNUMBER = @cfRP and @userLoa = LOA
				order by id desc
		end

	end


	---- se non ho recuperato il LOA verifico se è entrato almeno una volta con traccia sulla CTL_LOG_SPID
	---- ovvero con autenticazione a due fattori
	--if @userLoa = '0' and @IdTipoUtente = ''
	--begin

	--	if exists ( 
	--			select top 1 HTTP_FISCALNUMBER
	--				from CTL_LOG_SPID with(nolock) 
	--				where HTTP_FISCALNUMBER = @cfRP 
	--			)
	--	begin
	--		set @userLoa = '3'
	--		set @IdTipoUtente = 'CUSTOM'
	--	end

	--end


	-- se siamo in TEST si consente di simulare l'ingresso con SPID 
	-- questo lo desumiamo dal codice AUSA che inizia con il numero 9
	if left( @codiceAUSA , 1 ) = '9' and @IdTipoUtente = '' 
	begin
		set @userLoa = '3'
		set @IdTipoUtente = 'SPID'
	end

	if @IdTipoUtente ='LOCAL'
		set @IdTipoUtente='CUSTOM'


    -- Insert statements for procedure here
	SELECT 
		@cfSA as cfSA,
		@cfRP as cfRP, 
		@idAzi as idAzi, 
		@purposeId as purposeId, 
		@kid as Kid, 
		@endpointOut as endpoint, 
		@codiceAUSA as codiceAUSA, 
		@codicePiattaforma as codicePiattaforma, 
		@userLoa as userLoA, 
		@IdTipoUtente as IdTipoUtente, 
		@clientId as clientId, 
		@centroCosto as centroDiCosto,
		@BusinessflowID as BusinessflowID, 
		@traceID as traceID, 
		@SpanID  as SpanID, 
		@funzioniSvolte as funzioniSvolte,
		case 
			when @funzioniSvolte = '' then 0
			else 1
		end as SaTitolare
		, @PCP_regCodiceComponente as PCP_regCodiceComponente
		, @audAuth as audAuth
		, @urlAuth as urlAuth
		, @PemPrivateKey as PemPrivateKey


END





GO
