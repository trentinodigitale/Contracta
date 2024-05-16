USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_DOSSIER]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[OLD2_DASHBOARD_SP_DOSSIER] 
(@IdPfu							int, 
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output,
 @nIsExcel						int = 0
)
as
declare @Param varchar(8000)
	declare @SortPassato varchar(500)
	declare @bVistaFornitore int
	declare @AddATI int
	set @AddATI  = 0
	declare @AziMAster varchar(20)


	declare @ExplicitSediDest int

	set nocount on

	select @AziMAster  = mpIdAziMaster  from marketplace with(nolock)

	set @Sort = @Sort + ' '
	set @SortPassato = @Sort + ' '
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp



	declare @DocumentType                      as varchar(MAX)--                 4          767         1
	declare @Data                              as varchar(50)--                  5          347         2
	declare @DataA                             as varchar(50)--                  5          347         2
	declare @Name                              as varchar(50)--                  4          346         3
	declare @NumOrd                            as varchar(50)--                  4          524         4
	declare @Protocol                          as varchar(50)--                  4          348         5
	declare @ProtLinkMsg                       as varchar(50)--                  4          529         6
	declare @ArtClasMerceologica               as varchar(50)--                  7          107         7
	declare @CodiceArticolo                    as varchar(50)--                  4          69          8
	declare @CARCodiceArticoloFornitore        as varchar(50)--                  4          760         9
	declare @CARCodiceFornitore                as varchar(50)--                  4          658         10
	declare @CARDescrNonCod                    as varchar(50)--                  4          745         10
	declare @RAGSOC                            as varchar(50)--                  4          72          11
	declare @SediDest                          as varchar(2500)--                4          673         12
	declare @CARUtilizzo                       as varchar(50)--                  6          756         13
	declare @OpenOffer                         as varchar(50)--                  6          351         14
	declare @UserId                            as varchar(50)--                  1          551         15
	declare @IdentificativoIniziativa		   as nvarchar(MAX)--                 4          767         1

	declare @pfuProfili		as varchar(50)
	declare @SQLCmd			varchar(8000)
	declare @SQLCmdAZI		varchar(8000)
	declare @AttrNameSort   varchar (50)
	declare @AttrNameTech   varchar (50)

	declare @idAziPartecipante	varchar (50)
	declare @AZI_Ente	varchar (50)	

	declare @pfuIdAzi			varchar (50)
	
	
	

	declare @DZT_Name varchar (50) 
	declare @TipoMem  tinyint 
	declare @Valore	  nvarchar (1000) 
	declare @Condizione varchar (50) 
	declare @TableName varchar (60)
	declare @IdDzt int


	declare @CrLf varchar (10)
	set @CrLf = '
'

	declare @DataName		varchar (60)
	declare @CIG			varchar(50)
	declare @CodiceFiscale	varchar(50)
	declare @nInitTempAzi as int

	set @nInitTempAzi = 0

	set @DataName  = 'ReceivedDataMsg'

	declare @i				int

	select @pfuIdAzi = cast( pfuIdAzi as varchar ) from profiliutente with(nolock) where idpfu = @IdPfu

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- DIFFERENZE DELLA VERSIONE PA
--
-- non è presente l'apertura per SediDest ed è stata commentata la sezione di sort forzato
-- non è presete il campo Data e c'è il campo ReceivedDataMsg che ne prende il posto nei criteri di restrizione
-- aggiunto il campo idAziPartecipante per filtrare direttamente sull'azienda al posto del codice fornitore
-- aggiunta restrizione sull'azienda dell'utente collegato
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

	-- criteri di ricerca
	set @DocumentType				= replace(dbo.GetParam( 'DocumentType' , @Param ,1) ,'''','''''')
	set @SediDest					= replace(dbo.GetParam( 'SediDest' , @Param ,1) ,'''','''''')

	set @CARCodiceFornitore			= replace(dbo.GetParam( 'CARCodiceFornitore' , @Param ,1) ,'''','''''')
	set @RAGSOC						= replace(dbo.GetParam( 'RAGSOC' , @Param ,1) ,'''','''''')

	set @Data						= replace(dbo.GetParam( @DataName , @Param ,1) ,'''','''''')
	set @DataA						= replace(dbo.GetParam( @DataName + 'A' , @Param ,1) ,'''','''''')
	set @Name						= replace(dbo.GetParam( 'Name' , @Param ,1),'''','''''')
	set @Protocol					= replace(dbo.GetParam( 'Protocol' , @Param ,1) ,'''','''''')
	set @UserId						= replace(dbo.GetParam( 'UserId' , @Param ,1),'''','''''')
	set @idAziPartecipante			= replace(dbo.GetParam( 'idAziPartecipante' , @Param ,1),'''','''''')
	set @AZI_Ente					= replace(dbo.GetParam( 'AZI_Ente' , @Param ,1),'''','''''')
	set @CIG					    = replace(dbo.GetParam( 'CIG' , @Param ,1),'''','''''')

	set @IdentificativoIniziativa	= replace(dbo.GetParam( 'IdentificativoIniziativa' , @Param ,1),'''','''''')
	set @CodiceFiscale	= replace(dbo.GetParam( 'CodiceFiscale' , @Param ,1),'''','''''')
	
	-- 
	if @DocumentType <> '' 
	begin
		set @DocumentType = replace ( @DocumentType , '###' , ',' )
		if left ( @DocumentType , 1 ) = ',' 
			set @DocumentType = substring( @DocumentType , 2 , len( @DocumentType ) - 1 ) 

		if RIGHT( @DocumentType , 1 ) = ',' 
			set @DocumentType = left ( @DocumentType , len(@DocumentType) -1 ) 	

	end

	--MC att. 448606 gestione @AZI_Ente come multivalore
	if @AZI_Ente <> '' 
	begin
		set @AZI_Ente = replace ( @AZI_Ente , '###' , ',' )
		if left ( @AZI_Ente , 1 ) = ',' 
			set @AZI_Ente = substring( @AZI_Ente , 2 , len( @AZI_Ente ) - 1 ) 

		if RIGHT( @AZI_Ente , 1 ) = ',' 
			set @AZI_Ente = left ( @AZI_Ente , len(@AZI_Ente) -1 ) 	

	end

	--MC att. 448606 gestione @idAziPartecipante come multivalore
	if @idAziPartecipante <> '' 
	begin
		set @idAziPartecipante = replace ( @idAziPartecipante , '###' , ',' )
		if left ( @idAziPartecipante , 1 ) = ',' 
			set @idAziPartecipante = substring( @idAziPartecipante , 2 , len( @idAziPartecipante ) - 1 ) 

		if RIGHT( @idAziPartecipante , 1 ) = ',' 
			set @idAziPartecipante = left ( @idAziPartecipante , len(@idAziPartecipante) -1 ) 	

	end

	
	-- se l'utente è ristretto nella visibilità per la propria azienda impostiamo un filtro implicito sull'ente
	if exists( select idpfu from profiliutenteattrib with(nolock) where idpfu = @IdPfu and dztnome = 'Dossier_Restrict_Azi' )
	begin
		set  @AZI_Ente = @pfuIdAzi 
	end
	




	-- recupero in una tabella temporanea gli attributi utilizzati dal dossier
	exec GetParamDossier 'DASHBOARD_SP_DOSSIER' ,  @Param ,1 , @IdPfu


	
-------------------------------------------------------------------
-- Verifico la presenza di eventuali restrizioni sull'utente
-------------------------------------------------------------------

	if @DocumentType = ''
	begin
		select @DocumentType = @DocumentType + attvalue +' ,' from profiliutenteattrib with(nolock) where idpfu = @IdPfu and dztnome = 'Dossier_DocumentType' 
		if @DocumentType <> ''
			set @DocumentType = left( @DocumentType , len( @DocumentType ) - 1 )
	end

	if @SediDest = ''
	begin
		set @ExplicitSediDest = 0
		select @SediDest = @SediDest + '''' +attvalue +''' ,' from profiliutenteattrib  with(nolock) where idpfu = @IdPfu and dztnome = 'Dossier_SediDest' 
		if @SediDest <> ''
			set @SediDest = '( ' + left( @SediDest , len( @SediDest ) - 1 )  + ' ) '

	end
	else
	begin
		set @ExplicitSediDest = 1
		set @SediDest = ' ( ''' + @SediDest + ''' ) '
	end

	if @SediDest <> ''
		update TempAttribDossier set Valore = @SediDest  , Condizione = ' in '
			WHERE idPfu = @idPfu and DZT_Name = 'SediDest'




	-- se non ci sono restrizioni specifiche dell'utente vediamo se esistono restrizioni sui suoi profili
	if @DocumentType = ''
	begin

		if exists(	
					select p.idpfu 
						from profiliutenteattrib p  with(nolock) 
							inner join CTL_Relations r  with(nolock) on r.REL_Type = 'PROFILO_DOCUMENTI_DOSSIER' and p.dztNome = 'Profilo' and p.attValue = r.REL_ValueInput
						where idpfu = @IdPfu 

				 )

		select @DocumentType = @DocumentType + r.REL_ValueOutput + ' ,' 
						from profiliutenteattrib p 
							inner join CTL_Relations r on r.REL_Type = 'PROFILO_DOCUMENTI_DOSSIER' and p.dztNome = 'Profilo' and p.attValue = r.REL_ValueInput
						where idpfu = @IdPfu 

		if @DocumentType <> ''
			set @DocumentType = left( @DocumentType , len( @DocumentType ) - 1 )
	end


-------------------------------------------------------------------
-- recupero il profilo dell'utente per determinare la lista dei documenti ammessi se non preventivamente ristretti
-------------------------------------------------------------------

	if @DocumentType = ''
	begin
		select @pfuProfili = pfuProfili  from profiliutente  with(nolock) where idpfu = @IdPfu
		set @i = 0
		while @i < len( @pfuProfili )
		begin
			select @DocumentType = @DocumentType + cast( idDcm as varchar ) + ' ,' from Document  with(nolock) where dcmDetail like '%' + substring( @pfuProfili , @i+1 , 1 ) + '%'
			set @i = @i + 1
		end

		set @DocumentType = left( @DocumentType , len(@DocumentType) - 1 )

	end

	update TempAttribDossier set Valore = @DocumentType  , Condizione = ' in '
		WHERE idPfu = @idPfu and DZT_Name = 'DocumentType'


-------------------------------------------------------------------
-- determino la colonna di sort richiesta per la visualizzazione
-------------------------------------------------------------------
	set @AttrNameSort = @Sort
	if @Sort <> ''
	begin
		set @i =  charindex(' ', @Sort)
		if @i > 0
		begin
			set @AttrNameSort = substring(@Sort, 1, @i - 1)
		end
	end
	set @AttrNameSort = ltrim( @AttrNameSort )

	set @AttrNameTech = ''
	if @AttrNameSort in ( 'Name' , 'Protocol' , 'DocumentType' , 'SediDest' ) 
	begin 
		if @AttrNameSort in ( 'Name' , 'Protocol' )
			set @AttrNameTech = 'msg' + @AttrNameSort 

		if @AttrNameSort in ( 'DocumentType' )
			set @AttrNameTech = 'msgIdDcm' 

		if @AttrNameSort in ( 'SediDest' )
			set @AttrNameTech = 'SediDest' 
	end
	

---------------------------------------------------------------
-- recupero in una tabella temporanea le aziende che soddisfano la richiesta
	-- se si tratta di un fornitore allora l'azienda è predeterminata dalla sua
    -- inoltre vengono considerate anche tutte le ati dove ha partecipato
-------------------------------------------------------------------

	set @SQLCmd = 'set nocount on
				'




	if exists( select * from profiliutente  with(nolock) 
				inner join MarketPlace  with(nolock) on pfuidazi = mpIdAziMaster 
				where idpfu = @IdPfu )
	begin  
		
		-- utente dell'azienda master

		if ( @CARCodiceFornitore <> '' or @RAGSOC <> '' ) and @idAziPartecipante = '' 
		begin 

			if @CARCodiceFornitore <> '' and @RAGSOC <> ''
			begin 
--				set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier from aziende 
--													inner join DM_Attributi on lnk = idAzi and idApp = 1 and dztNome = ''CARCodiceFornitore'' and vatValore_FV like ''%' + @CARCodiceFornitore + '%'' 
--										where aziRagionesociale like ''' + @RAGSOC + ''' ' + @CrLf
				set @SQLCmd = @SQLCmd + ' select 
												idAzi into #TempAziDossier_app 
													from aziende  with(nolock) 
														inner join DM_Attributi  with(nolock) on lnk = idAzi and idApp = 1 and dztNome = ''CARCodiceFornitore'' and vatValore_FV like ''%' + @CARCodiceFornitore + '%'' 
													where aziRagionesociale like ''' + @RAGSOC + ''' ' + @CrLf
		
				set @AddATI = 1
			end

			if @CARCodiceFornitore = '' and @RAGSOC <> ''
			begin 
--				set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier from aziende where aziRagionesociale like ''' + @RAGSOC + '''  ' + @CrLf
				set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app from aziende  with(nolock)  where aziRagionesociale like ''' + @RAGSOC + '''  ' + @CrLf
				set @AddATI = 1
			end

			if @CARCodiceFornitore <> '' and @RAGSOC = ''
			begin 
--				set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier from aziende 
--													inner join DM_Attributi on lnk = idAzi and idApp = 1 and dztNome = ''CARCodiceFornitore'' and vatValore_FV like ''' + @CARCodiceFornitore + ''' ' + @CrLf
				set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app from aziende  with(nolock) 
													inner join DM_Attributi  with(nolock) on lnk = idAzi and idApp = 1 and dztNome = ''CARCodiceFornitore'' and vatValore_FV like ''' + @CARCodiceFornitore + ''' ' + @CrLf
				set @AddATI = 1
			end

		end

		if @idAziPartecipante <> '' and @AZI_Ente <> '' 
		begin
			
			set @nInitTempAzi = 1

			--if ISNUMERIC(@idAziPartecipante) = 0
			--  set @idAziPartecipante = '-1'

			--if ISNUMERIC(@AZI_Ente) = 0
			--	set @AZI_Ente = '-1'

			

			--if @CodiceATC <> ''
			--set @SQLCmd =  @SQLCmd  + ' and dbo.fn_CheckMultiValue( CodiceATC ,  '' = '' ,  ''' + replace( @idAziPartecipante , '''' , '''''' ) + ''' ) = 1 '

			if @CodiceFiscale =''
				set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app from aziende with(nolock)  where idAzi in ( ' + @idAziPartecipante + ' , ' + @AZI_Ente + ' ) ' + @CrLf
			else
				set @SQLCmd = @SQLCmd + ' select 
											idAzi into #TempAziDossier_app  
												from aziende with(nolock)  
													inner join DM_Attributi  with(nolock) on lnk = idAzi and idApp = 1 and dztNome = ''CodiceFiscale'' and vatValore_FV like ''' + @CodiceFiscale + ''' ' + @CrLf + 
											'	where idAzi in ( ' + @idAziPartecipante + ' , ' + @AZI_Ente + ' ) ' + @CrLf
		end
		else
		begin
			if @idAziPartecipante <> '' 
			begin
				
				set @nInitTempAzi = 1

				--if ISNUMERIC(@idAziPartecipante) = 0
				--	set @idAziPartecipante = '-1'

				if @CodiceFiscale =''
					set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app from aziende with(nolock)  where idAzi in ( ' + @idAziPartecipante + ' ) ' + @CrLf
				else
					set @SQLCmd = @SQLCmd + ' select 
											idAzi into #TempAziDossier_app  
												from aziende with(nolock)  
													inner join DM_Attributi  with(nolock) on lnk = idAzi and idApp = 1 and dztNome = ''CodiceFiscale'' and vatValore_FV like ''' + @CodiceFiscale + ''' ' + @CrLf + 
											'	where idAzi in ( ' + @idAziPartecipante + ' ) ' + @CrLf
				set @AddATI = 1
			end

			if @AZI_Ente <> ''
			begin
				set @nInitTempAzi = 1

				--if ISNUMERIC(@AZI_Ente) = 0
				--	set @AZI_Ente = '-1'
				
				if @CodiceFiscale =''
					set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app from aziende  with(nolock) where idAzi in ( ' + @AZI_Ente + ' ) ' + @CrLf
				else
					set @SQLCmd = @SQLCmd + ' select 
											idAzi into #TempAziDossier_app  
												from aziende with(nolock)  
													inner join DM_Attributi  with(nolock) on lnk = idAzi and idApp = 1 and dztNome = ''CodiceFiscale'' and vatValore_FV like ''' + @CodiceFiscale + ''' ' + @CrLf + 
											'	where idAzi in ( ' + @AZI_Ente + ' ) ' + @CrLf
			end
		end

		-- per tutte le aziende che sono uscite dai criteri di ricerca indicati si aggiungono anche 
		-- tutte le ati a cui hanno partecipato		
--		if @AddATI = 1
--		begin
--			set @SQLCmd = @SQLCmd + '  select  idAziRTI as idAzi into #TempAziDossier_app from Document_Aziende_RTI where idAziPartecipante in ( select idazi from #TempAziDossier )
--									insert into #TempAziDossier_app ( idAzi ) select  idAzi from #TempAziDossier ' + @CrLf
--		end

		if  @nInitTempAzi = 0
		begin
			----se sto cercando per codice fiscale aggiungo idazi dell'azienda con quel codice fiscale
			if @CodiceFiscale <>''
			begin
				set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app 
												from aziende  with(nolock) 
														inner join DM_Attributi  with(nolock) 
						on lnk = idAzi and idApp = 1 and dztNome = ''CodiceFiscale'' and vatValore_FV like ''' + @CodiceFiscale + ''' ' + @CrLf
			end

		end

		set @bVistaFornitore = 0

	end
	else
	begin  -- utente fornitore si prende la sua azienda o le ATI a cui partecipa


		set  @idAziPartecipante = @pfuIdAzi

		--if ISNUMERIC(@idAziPartecipante) = 0
			--		set @idAziPartecipante = '-1'

		--set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app from aziende where idAzi in ( ' + @idAziPartecipante + ' ) or idAzi in ( select  idAziRTI from dbo.Document_Aziende_RTI where idAziPartecipante = ' + @idAziPartecipante + ' )' + @CrLf
		if @CodiceFiscale =''
			set @SQLCmd = @SQLCmd + ' select idAzi into #TempAziDossier_app from aziende where idAzi in ( ' + @idAziPartecipante + ' ) ' + @CrLf
		else
			set @SQLCmd = @SQLCmd + ' select 
											idAzi into #TempAziDossier_app  
												from aziende with(nolock)  
													inner join DM_Attributi  with(nolock) on lnk = idAzi and idApp = 1 and dztNome = ''CodiceFiscale'' and vatValore_FV like ''' + @CodiceFiscale + ''' ' + @CrLf + 
											'	where idAzi in ( ' + @idAziPartecipante + ' ) ' + @CrLf

		set @bVistaFornitore = 1

	end


	
---------------------------------------------------------------------
-- per iniziativa si prepara una tabella temporanea con gli identificativi dei documenti 
---------------------------------------------------------------------
	set @SQLCmd = @SQLCmd + ' select cast( idheader as varchar(100)) as idDoc , identificativoIniziativa into #TempDocIniziativaDossier_app from Document_Bando  with(nolock) ' + @CrLf
	set @SQLCmd = @SQLCmd + ' insert into #TempDocIniziativaDossier_app ( idDoc , identificativoIniziativa ) select id , identificativoIniziativa from Document_Convenzione  with(nolock) ' + @CrLf
	set @SQLCmd = @SQLCmd + ' insert into #TempDocIniziativaDossier_app ( idDoc , identificativoIniziativa ) select RDA_Id , identificativoIniziativa from DASHBOARD_VIEW_ODC  with(nolock) ' + @CrLf


	--if @IdentificativoIniziativa <> ''
	--begin

	--		set @SQLCmd = @SQLCmd + ' select cast( idheader as varchar(100)) as idDoc  into #TempDocIniziativaDossier_app from Document_Bando where ''' + @identificativoIniziativa + ''' like ''%###'' + identificativoIniziativa + ''###%'' ' + @CrLf
	--		set @SQLCmd = @SQLCmd + ' insert into #TempDocIniziativaDossier_app ( idDoc ) select id from Document_Convenzione where ''' + @identificativoIniziativa + ''' like ''%###'' + identificativoIniziativa + ''###%'' ' + @CrLf

	--end




---------------------------------------------------------------
-- determina gli id dei MSg che soddisfano il criterio di ricerca
-------------------------------------------------------------------
	set @SQLCmd = @SQLCmd + ' 
		select distinct m.idMsg '



	set @SQLCmd = @SQLCmd + '
			into #TempIdMSG
		from messaggi m WITH (NOLOCK)
'

---------------------------------------------------------------------
-- applica la restrizione per iniziativa se richiesta
---------------------------------------------------------------------
	if @IdentificativoIniziativa <> ''
	begin
		set @SQLCmd = @SQLCmd + ' inner join #TempDocIniziativaDossier_app tmpI on tmpI.idDoc = m.msgIdCDO and ''' + @identificativoIniziativa + ''' like ''%###'' + identificativoIniziativa + ''###%'' ' + @CrLf
	end

	set @i = 1

	declare crs cursor static for 
			SELECT      DZT_Name, TipoMem, Valore, Condizione, TableName , IdDzt
				FROM         TempAttribDossier with(nolock) 
							where idPfu = @idPfu and Filtro = 1 and TableName <> '' and Valore <> ''
									and DZT_Name not in ( @DataName , 'CARCodiceFornitore' , 'RAGSOC' , 'UserId' , 'SediDest' , 'CIG' )

	open crs
	fetch next from crs into @DZT_Name, @TipoMem, @Valore, @Condizione, @TableName , @IdDzt

	while @@fetch_status = 0
	begin

			set @SQLCmd = @SQLCmd + ' inner join ' + @TableName + ' m' + cast( @i as varchar ) + '  WITH (NOLOCK) on m' + cast( @i as varchar ) + '.idmsg = m.idmsg and m' + cast( @i as varchar ) + '.vatIdDzt = ' + cast( @IdDzt as varchar ) + ' and m' + cast( @i as varchar ) + '.vatValore ' + @Condizione + ' ''' + @Valore + ''' ' + @CrLf

			set @i = @i + 1
			fetch next from crs into @DZT_Name, @TipoMem, @Valore, @Condizione, @TableName , @IdDzt
	end
	close crs 
	deallocate crs

	set @i = @i + 1
	
-- controllo una restrizione per data
	if @Data <> '' or @DataA <> ''
	begin
		SELECT     @DZT_Name =  DZT_Name, @TipoMem = TipoMem, @Valore = Valore, @Condizione = Condizione, @TableName  = TableName , @IdDzt = IdDzt
			FROM   TempAttribDossier with(nolock) 
			where idPfu = @idPfu and Filtro = 1 
					and DZT_Name = @DataName--'Data'

		set @SQLCmd = @SQLCmd + ' inner join ' + @TableName + ' m' + cast( @i as varchar ) + '  WITH (NOLOCK) on m' + cast( @i as varchar ) + '.idmsg = m.idmsg and m' + cast( @i as varchar ) + '.vatIdDzt = ' + cast( @IdDzt as varchar ) 
		
		if @Data <> ''
		 	set @SQLCmd = @SQLCmd + ' and m' + cast( @i as varchar ) + '.vatValore >=  ''' + @Data + ''' ' + @CrLf

		if @DataA <> ''
		 	set @SQLCmd = @SQLCmd + ' and m' + cast( @i as varchar ) + '.vatValore <=  ''' + replace(@DataA,'00:00:00','23:59:59') + ''' ' + @CrLf

	end


	if @CIG <> '' 
	begin

		set @SQLCmd = @SQLCmd + ' 
		inner join document doc with(nolock) on doc.IdDcm = m.msgIdDcm  --doc.itype = m.itype and doc.isubtype = m.isubtype 
			left join document_microlotti_dettagli CIG with(nolock)  on cig.tipodoc = doc.tipodoc and m.msgIdCDO = cig.idheader and cig.CIG like ''' + @CIG + ''' 
			left join ctl_doc ba with(nolock) on ba.id = m.msgIdCDO and ba.tipodoc in (''BANDO_GARA'',''BANDO_SEMPLIFICATO'') and ba.deleted = 0 and ba.statofunzionale <> ''InLavorazione''  
			left join document_bando nd with(nolock) on nd.idheader = ba.id and nd.CIG like ''' + @CIG + ''' 
			left join document_odc odc with(nolock) on odc.rda_id = m.msgIdCDO and ( odc.CIG like ''' + @CIG + ''' or odc.cig_madre  like ''' + @CIG + ''' ) 
		'
	end


	if @CodiceFiscale <>''
	begin
		set @SQLCmd = @SQLCmd + ' 
			cross join #TempAziDossier_app TST
			--il documento deve stare nel dossier
			inner join document Def_Doc with(nolock) on Def_Doc.IdDcm = m.msgIdDcm
		
			--può essere azienda mittente oppure destinataria di qualsiasi documento sulla ctl_doc
			left join ctl_doc Doc with(nolock) on Doc.id = m.msgIdCDO and Doc.deleted=0 and Doc.statofunzionale <>''InLavorazione'' and ( doc.azienda=TST.idazi or Doc.Destinatario_azi =TST.idazi )
			left join profiliutente Doc_Azi with(nolock) on ( Doc_Azi.idpfu = Doc.destinatario_user or Doc_Azi.idpfu = Doc.idpfu ) and Doc_Azi.pfuidazi=TST.idazi

			--può essere il destinatario di una comunicazione fornitore
			left join document_com_dpe_fornitori C_OE with(nolock) on C_OE.idcom = m.msgIdCDO  and C_OE.idazi = TST.idazi

			--può essere il destinatario di una comunicazione enti
			left join document_com_dpe_enti C_ENTI with(nolock) on C_ENTI.idcom = m.msgIdCDO and C_ENTI.idazi = TST.idazi

			--può essere azienda che ha inserito/ricevuto il quesito
			left join document_chiarimenti Quesito with(nolock) on Quesito.id =  m.msgIdCDO and Quesito.statofunzionale <> ''InLavorazione''
			left join profiliutente Azi_Quesito with(nolock) on ( Azi_Quesito.idpfu = Quesito.utentedomanda or Azi_Quesito.idpfu =utenterisposta ) and Azi_Quesito.pfuidazi=TST.idazi
			
			--può essere un invitato di una gara
			left join document_bando dettBando with(nolock) on  dettBando.idheader = m.msgIdCDO and dettBando.tipobandogara=''3''
			left join ctl_doc_destinatari Dest with(nolock) on Dest.idheader = dettBando.idheader  and Dest.idazi = TST.idazi
																											
		'
	end


-- utente
--UserId                                             1          551         15
	set @UserId = replace( @UserId , '%' , '' ) 

	if @UserId <> '' and ISNUMERIC(@UserId) = 1
        set @SQLCmd = @SQLCmd + ' inner join MessaggiUtenti u1 WITH (NOLOCK) on u1.muIdMsg = m.IdMsg and ( u1.muIdPfuMitt = ' + @UserId + ' or u1.muIdPfuDest = ' + @UserId + ' ) '


-- COMMENTATO PERCHE' PER APRIRE IL RISULTATO SULLE ATI OCCORRE FARE IL FILTRO SUL PRODOTTO CARTESIANO
------------	if @CARCodiceFornitore <> '' or @RAGSOC <> '' or @idAziPartecipante <> ''
------------	begin
------------		set @SQLCmd = @SQLCmd + ' 
------------
------------		inner join MessaggiUtenti u WITH (NOLOCK) on u.muIdMsg = m.IdMsg 
------------			and ( u.muIdAziDest in ( select idazi from #TempAziDossier_app ) or u.muIdAziMitt in ( select idazi from #TempAziDossier_app )  ) 
------------		'
------------		--	and ( u.muIdAziDest = ' + @pfuIdAzi + '  or u.muIdAziMitt = ' + @pfuIdAzi + '  ) 
------------		
------------	end
--	else
--	begin
--		set @SQLCmd = @SQLCmd + ' 
--
--		inner join MessaggiUtenti u WITH (NOLOCK) on u.muIdMsg = m.IdMsg 
--			and ( u.muIdAziDest = ' + @pfuIdAzi + '  or u.muIdAziMitt = ' + @pfuIdAzi + '  ) 
--		'
--
--	end


	-- aggiungo il criterio di restrizione solo per gli utenti interni
	--
	if @bVistaFornitore = 0
	begin
		set @SQLCmd = @SQLCmd + ' left outer join TAB_MESSAGGI_FIELDS tmb1 on 
			tmb1.IdMsg =  m.IdMsg 
			and tmb1.iSubType in ( ''23'' , ''171'' ) and tmb1.iType = ''55''

			and 
			(
				(tmb1.DataAperturaOfferte > getdate() and tmb1.VisualizzaNotifiche = ''0'' )
--				or
--				(isnull( ModalitadiPartecipazione , 16308 ) = 16307 ) --Tradizionale
			)
			
	'
	end


	set @SQLCmd = @SQLCmd + ' 
			where 
				 m.msgIdDcm in ( ' + @DocumentType + ' )
			'


	if @CIG <> ''
	begin
		set @SQLCmd = @SQLCmd + ' and isnumeric( m.msgIdCDO)=1 and  ( cig.CIG is not  null or nd.cig is not null  or odc.cig is not null or odc.cig_madre is not null) 	'
	end


	if @CodiceFiscale  <> ''
	begin
		set @SQLCmd = @SQLCmd + '   and isnumeric( m.msgIdCDO)=1 
									and ( doc.id is not null or Doc_Azi.pfuidazi is not null or  C_OE.idazi is not null or Azi_Quesito.pfuidazi is not null or C_ENTI.idazi is not null or Dest.idazi is not null )
									 	'
	end


	if @bVistaFornitore = 0
	begin
		set @SQLCmd = @SQLCmd + ' and tmb1.IdMsg is null '
	end



-- base presenti nelle colonne di base Messaggi
--Name                                               4          346         3
--Protocol                                           4          348         5
	if @Name <> ''
        set @SQLCmd = @SQLCmd + ' and msgName like ''' + @Name + ''' '
		
	if @Protocol <> ''
        set @SQLCmd = @SQLCmd + ' and msgProtocol like ''' + @Protocol + ''' '



-------------------------------------------------------------------
-- si aggiungono restrizioni legate ai profili dell'utente
-------------------------------------------------------------------
	if exists( 		
			select r.REL_Type
				from profiliutenteattrib p  with(nolock) 
					inner join CTL_Relations r  with(nolock) on r.REL_Type = 'PROFILO_FILTRO_DOSSIER' and p.dztNome = 'Profilo' and p.attValue = r.REL_ValueInput
				where idpfu = @IdPfu 
			 )
	begin

		declare @SQLFiltro nvarchar (max)

		set @SQLCmd = @SQLCmd + ' and ( '

		declare crs cursor static for 
			select r.REL_ValueOutput
				from profiliutenteattrib p  with(nolock) 
					inner join CTL_Relations r  with(nolock) on r.REL_Type = 'PROFILO_FILTRO_DOSSIER' and p.dztNome = 'Profilo' and p.attValue = r.REL_ValueInput
				where idpfu = @IdPfu 
									
		open crs

		fetch next from crs into @SQLFiltro

		while @@fetch_status = 0
		begin

			--set @SQLCmd = @SQLCmd + '  ( ' + replace( @SQLFiltro , '''' , '''''' ) + ' ) '
			set @SQLCmd = @SQLCmd + '  ( ' +  @SQLFiltro  + ' ) '

			fetch next from crs into @SQLFiltro
			if @@fetch_status = 0
				set @SQLCmd = @SQLCmd + ' or '
		end

		close crs 
		deallocate crs

		set @SQLCmd = @SQLCmd + ' ) '

	end


-------------------------------------------------------------------
-- compongo la query di estrazione delle colonne per la griglia
-------------------------------------------------------------------

	declare @SQLColonne varchar (2000)
	declare @SQLWhere varchar (2000)

	set @SQLWhere  = ''
	set @SQLColonne  = ''
	set @i = 1

	declare crs cursor static for 
			SELECT      DZT_Name, TipoMem, Valore, Condizione, TableName , IdDzt
				FROM         TempAttribDossier  with(nolock) 
							where idPfu = @idPfu and Griglia = 1 and TableName <> '' 
									
	open crs
	fetch next from crs into @DZT_Name, @TipoMem, @Valore, @Condizione, @TableName , @IdDzt

	while @@fetch_status = 0
	begin

			set @SQLColonne = @SQLColonne + ', ' + @DZT_Name

			set @i = @i + 1
			fetch next from crs into @DZT_Name, @TipoMem, @Valore, @Condizione, @TableName , @IdDzt
	end
	close crs 
	deallocate crs


		--,isnull( rti.idAziPartecipante , mu.muIdAziMitt ) as muIdAziMitt 
		--,mu.muIdAziDest


	set @SQLCmd = @SQLCmd + ' 
	select 
		m.IdMsg 

		,mu.muIdPfuMitt
		,mu.muIdPfuDest
		, case when  mu.muIdAziMitt = ' + @AziMAster + ' then  mu.muIdAziMitt 
				else isnull( rti.idAziPartecipante , mu.muIdAziMitt ) 
			end as muIdAziMitt 
		, case when  mu.muIdAziDest = ' + @AziMAster + ' then  mu.muIdAziDest 
				else isnull( rti.idAziPartecipante , mu.muIdAziDest ) 
			end as muIdAziDest 
		,mu.muIdMpMitt
		,mu.muIdMpDest
		, rti.Ruolo_Impresa

		, m.msgName as Name 
		, m.msgProtocol as Protocol 
		, m.msgIdDcm as DocumentType 
		
		, identificativoIniziativa 
		' + @SQLColonne + @CrLf


	set @SQLCmd = @SQLCmd + ' 	into #TEMP_Dossier_Result ' + @CrLf
	set @SQLCmd = @SQLCmd + ' 	from messaggi m WITH (NOLOCK) ' + @CrLf 

	-- per aggiungere mittente e destinatario nella visualizzazione
	set @SQLCmd = @SQLCmd + '	left outer join MessaggiUtenti mu WITH (NOLOCK) on mu.muidmsg = m.idMsg 
								left outer join ( select IdMsg , IdAziendaAti from TAB_MESSAGGI_FIELDS  WITH (NOLOCK) ) as t  on t.IdMsg = m.idMsg 
								left outer join Document_Aziende_RTI rti WITH (NOLOCK) on t.IdAziendaAti = rti.idAziRTI
' + @CrLf

--			set @SQLCmd = @SQLCmd + '  select  idAziRTI as idAzi into #TempAziDossier_app from Document_Aziende_RTI where idAziPartecipante in ( select idazi from #TempAziDossier )
--									insert into #TempAziDossier_app ( idAzi ) select  idAzi from #TempAziDossier ' + @CrLf

	

    set @SQLCmd = @SQLCmd + '		inner join Messaggi_Dossier_View v WITH (NOLOCK) on v.idMsg = m.idMsg '+ @CrLf

	-- aggiunta la join sui bandi e le convenzioni per recuperare l'iniziativa
    set @SQLCmd = @SQLCmd + '		left join #TempDocIniziativaDossier_app tmpI on tmpI.idDoc = m.msgIdCDO  '+ @CrLf



    set @SQLCmd = @SQLCmd + ' where m.idMsg in ( select idMsg from  #TempIdMSG ) '+ @CrLf




	if @SediDest <> ''
	begin 
        set @SQLCmd = @SQLCmd + ' and ( SediDest in  ' + @SediDest + ' '

		-- se la selezione della plant è esplicita allora si ritornano che contengono quella plant
		-- altrimenti nel caso di restrizione implicita si ritornano anche i documenti che non hanno la plant
		if @ExplicitSediDest = 1
			set @SQLCmd = @SQLCmd + '  )' + @CrLf
		else
			set @SQLCmd = @SQLCmd + ' or isnull( SediDest , '''' ) = '''' )' + @CrLf

	end

	if @nIsExcel=0

	begin

	set @SQLCmd = @SQLCmd + 'select  distinct T.* '
	

		if @SortPassato not like '%muIdAziMitt%' and @SortPassato not like '%muIdAziDest%'
		begin
			set @SQLCmd = @SQLCmd + '	from #TEMP_Dossier_Result T '	
		end

		--aggiunto questo passo per far funzionare l'ordine alfabetico quando order è fatto su idazi 
		if @SortPassato like '%muIdAziMitt%'
		BEGIN
		
			set @SQLCmd = @SQLCmd + ',aziRagioneSociale from 	#TEMP_Dossier_Result T '	
			set @SQLCmd = @SQLCmd + ' left join aziende  with(nolock)   on idazi=muIdAziMitt '
			set @SortPassato=Replace(@SortPassato,'muIdAziMitt','aziRagioneSociale')

		END
		if @SortPassato like '%muIdAziDest%'
		BEGIN
		
			set @SQLCmd = @SQLCmd + ',aziRagioneSociale from 	#TEMP_Dossier_Result T '	
			set @SQLCmd = @SQLCmd + ' left join aziende  with(nolock)  on idazi=muIdAziDest '
			set @SortPassato=Replace(@SortPassato,'muIdAziDest','aziRagioneSociale')

		END
	END
	ELSE
	BEGIN
		
		--metto in un atemp le desc dei documenti per ritonare la forma visuale
		select distinct  
			IdDcm ,
			isnull( cast( ML_Description as varchar(300)), dcmDescription ) as NomeDocumento 
			into #Temp_Desc_Doc
		from Document with(nolock)
			left outer join LIB_Multilinguismo  with(nolock) on ML_KEY  = dcmDescription and ML_LNG = 'I' and ML_Context = 0

		where dcmStorico = 1 and IdDcm in ( select distinct msgiddcm from messaggi with(nolock))
		

		--metto in join con la tabella aziende 2 volte per recuperare ragsoc mitt e ragsoc dest
		set @SQLCmd = @SQLCmd + 'select  distinct T.*,Mitt.Aziragionesociale as RagioneSocialeMittente,Dest.Aziragionesociale as RagioneSociale, NomeDocumento '
		set @SQLCmd = @SQLCmd + '   from #TEMP_Dossier_Result T'
		set @SQLCmd = @SQLCmd + ' left join aziende Mitt with(nolock)   on Mitt.idazi=muIdAziMitt'
		set @SQLCmd = @SQLCmd + ' left join aziende Dest with(nolock)  on Dest.idazi=muIdAziDest '
		set @SQLCmd = @SQLCmd + ' left join #Temp_Desc_Doc Doc with(nolock)  on Doc.iddcm=DocumentType '

		if @SortPassato like '%muIdAziMitt%'
		begin
			set @SortPassato=Replace(@SortPassato,'muIdAziMitt','Mitt.Aziragionesociale')
		end

		if @SortPassato like '%muIdAziDest%'
		begin
			set @SortPassato=Replace(@SortPassato,'muIdAziMitt','Dest.Aziragionesociale')
		end

	END
	
	

	if @CARCodiceFornitore <> '' or @RAGSOC <> '' or @idAziPartecipante <> '' or @AZI_Ente <> ''
	begin
		if @idAziPartecipante <> '' and @AZI_Ente <> ''
		begin

			--if ISNUMERIC(@idAziPartecipante) = 0
			--	set @idAziPartecipante = '-1'

			--if ISNUMERIC(@AZI_Ente) = 0
			--	set @AZI_Ente = '-1'

			set @SQLCmd = @SQLCmd + ' 
				where ( 
						--( muIdAziDest = ' + @idAziPartecipante + '  and muIdAziMitt = ' + @AZI_Ente + ' )  
						( muIdAziDest in ( ' + @idAziPartecipante + ' ) and muIdAziMitt in ( ' + @AZI_Ente + ') )  
						or 
						--( muIdAziDest = ' + @AZI_Ente + '  and muIdAziMitt = ' +  @idAziPartecipante + ' )  
						( muIdAziDest in (' + @AZI_Ente + ' )  and muIdAziMitt in ( ' +  @idAziPartecipante + ' ) ) 
					) 
			'
		end
		else
		begin

		
			set @SQLCmd = @SQLCmd + ' 
				where ( muIdAziDest in ( select idazi from #TempAziDossier_app ) 
						or muIdAziMitt in ( select idazi from #TempAziDossier_app )  
						--or isnull( rti.idAziPartecipante , mu.muIdAziMitt ) in ( select idazi from #TempAziDossier_app ) 
					) 
			'
		end
	end	
	
	
	if @SortPassato <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @SortPassato
	

	
-- PER LA PA non è presente sedidest ( plant )
	
--	if @AttrNameSort <> 'SediDest' 
--	begin
--		if @SortPassato <> ''
--			set @SQLCmd = @SQLCmd + ' , SediDest asc '
--		else
--			set @SQLCmd = @SQLCmd + ' SediDest asc '
--	end

	

	exec (@SQLCmd)
	print @SQLCmd

	--set @cnt = @@rowcount







GO
