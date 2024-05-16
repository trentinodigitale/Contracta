USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_DOSSIER_AZI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















CREATE         proc [dbo].[DASHBOARD_SP_DOSSIER_AZI]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as

	--------STORED ALLINEATA ANCHE SU IMPRESA--------

	--Versione=9&data=2019-07-25&Attivita=&Nominativo=FRANCESCO
	
	
	--Versione=8&data=2016-11-15&Attivita=&Nominativo=Enrico
	--Versione=7&data=2016-07-11&Attivita=114868&Nominativo=Federico
	--Versione=6&data=2015-12-18&Attivita=94797&Nominativo=Sabato
	--Versione=5&data=2014-09-04&Attivita=62233&Nominativo=Sabato
	--Versione=4&data=2013-04-11&Attivita=42862&Nominativo=Sabato

	declare @Operatore as varchar(10)
	declare @Param						varchar(8000)
	declare @CodiceArticolo				varchar(50)
	declare @MercerceologiaFornitore	     varchar(5000)
	declare @MercerceologiaFornitore_2	     varchar(5000)
	declare @attivoCPN					varchar(50)
	declare @CodiceFornitore			     varchar(50)
	declare @Iscritto					varchar(50)


	declare @ANNOCOSTITUZIONE			varchar(50)
	declare @IscrCCIAA					varchar(50)
	declare @SedeCCIAA					varchar(50)
	declare @ClasseIscriz				varchar(5000)
	declare @ClasseIscrizFILTRO			varchar(5000)
	declare @ATECO						varchar(5000)
	declare @CARClasMercAzienda			varchar(50)
	declare @AltraClassificazione		     varchar(50)
	declare @CancellatoDiUfficio		     varchar(50)

	declare @GerarchicoSOA				varchar(5000)
	declare @AreaGeograficaAlbo			varchar(5000)

	declare @TipologiaIncarico		     varchar(50)
	declare @OrdineProfessionale			varchar(50)
	
	declare @aziDataCreazioneDa			varchar(50)
	declare @sysHabilitStartDateDa		varchar(50)
	declare @aziDataCreazioneA			varchar(50)
	declare @sysHabilitStartDateA		     varchar(50)
	declare @sysHabilitStartDate		     varchar(50)

	declare @ListaAlbi					varchar(50)
	

	declare @CodiceFiscale				varchar(50)
	declare @AttivitaProfessionale	     varchar(max)

	declare @participantID				varchar(500)
	declare @iscrittoPeppol				varchar(500)
	declare @DataIscrizioneDal			varchar(50)
	declare @DataIscrizioneAl			varchar(50)

	declare @Province_Dove_Opera         varchar(max)
	declare @Tempi_Medi_gg_consegna      varchar(max)
	declare @Fatturato_ultimo_anno       varchar(max)
	declare @certificazioni			     varchar(max)
	declare @IdBando_v					 varchar(30)
	declare @StatoAbilitazione			 varchar(30)

	declare @Filtro_ClasseIscriz		 varchar(max)
	
	declare @ColPathFather as varchar(500)
	declare @ColPath as varchar(500)

	declare @esclusiva as varchar(100)

	set @esclusiva='NO'

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	declare @SQLCmd			varchar(max)
	declare @SQLAZI			varchar(max)
	declare @SQLRESTRICTAZI		varchar(max)
	declare @SQLWhere			varchar(max)

	set @SQLRESTRICTAZI = ''	
	
	set @SQLWhere = dbo.GetWhere( 'aziende' , 'U', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'


	-- criteri di ricerca
	set @CodiceArticolo				= replace( dbo.GetParam( 'CodiceArticolo' , @Param ,1) ,'''','''''')
	set @CodiceFornitore			= replace( dbo.GetParam( 'CodiceFornitore' , @Param ,1) ,'''','''''')
	set @MercerceologiaFornitore	= dbo.GetParam( 'Merceologia' , @Param ,1) 
	set @MercerceologiaFornitore_2		= replace( dbo.GetParam( 'MercerceologiaFornitore' , @Param ,1) ,'''','''''')
	set @attivoCPN					= replace( dbo.GetParam( 'attivoCPN' , @Param ,1) ,'''','''''')
	set @Iscritto					= replace( dbo.GetParam( 'CARBelongTo' , @Param ,1) ,'''','''''')
	
	set @CodiceFiscale				= replace( dbo.GetParam( 'codiceFiscale' , @Param ,1) ,'''','''''')

	set @ANNOCOSTITUZIONE			= replace( dbo.GetParam( 'ANNOCOSTITUZIONE' , @Param ,1) ,'''','''''')
	set @IscrCCIAA					= replace( dbo.GetParam( 'IscrCCIAA' , @Param ,1) ,'''','''''')
	set @SedeCCIAA					= replace( dbo.GetParam( 'SedeCCIAA' , @Param ,1) ,'''','''''')
	set @ClasseIscriz				= replace( dbo.GetParam( 'ClasseIscriz' , @Param ,1) ,'''','''''')
	set @Province_Dove_Opera		= replace( dbo.GetParam( 'Province_Dove_Opera' , @Param ,1) ,'''','''''')
	set @Tempi_Medi_gg_consegna		= replace( dbo.GetParam( 'Tempi_Medi_gg_consegna' , @Param ,1) ,'''','''''')
	set @Fatturato_ultimo_anno		= replace( dbo.GetParam( 'Fatturato_ultimo_anno' , @Param ,1) ,'''','''''')
	set @ClasseIscrizFILTRO			= replace( dbo.GetParam( 'ClasseIscrizFILTRO' , @Param ,1) ,'''','''''')
	set @ATECO					= replace( dbo.GetParam( 'ATECO' , @Param ,1) ,'''','''''')
	set @CARClasMercAzienda			= replace( dbo.GetParam( 'CARClasMercAzienda' , @Param ,1) ,'''','''''')
	set @AltraClassificazione		= replace( dbo.GetParam( 'AltraClassificazione' , @Param ,1) ,'''','''''')
	set @CancellatoDiUfficio			= replace( dbo.GetParam( 'CancellatoDiUfficio' , @Param ,1) ,'''','''''')
	set @ListaAlbi					= replace( dbo.GetParam( 'ListaAlbi' , @Param ,1) ,'''','''''')

	set @aziDataCreazioneDa		     = left( replace( dbo.GetParam( 'aziDataCreazioneDa' , @Param ,1) ,'''','''''') , 10 )
	set @sysHabilitStartDateDa		= left( replace( dbo.GetParam( 'sysHabilitStartDateDa' , @Param ,1) ,'''',''''''), 10 )
	set @aziDataCreazioneA			= left( replace( dbo.GetParam( 'aziDataCreazioneA' , @Param ,1) ,'''',''''''), 10 )
	set @sysHabilitStartDateA		= left( replace( dbo.GetParam( 'sysHabilitStartDateA' , @Param ,1) ,'''',''''''), 10 )
	set @sysHabilitStartDate			= left( replace( dbo.GetParam( 'sysHabilitStartDate' , @Param ,1) ,'''',''''''), 10 )

	set @GerarchicoSOA				= replace( dbo.GetParam( 'GerarchicoSOA' , @Param ,1) ,'''','''''')
	set @AreaGeograficaAlbo			= replace( dbo.GetParam( 'AreaGeograficaAlbo' , @Param ,1) ,'''','''''')

	set @TipologiaIncarico			= replace( dbo.GetParam( 'TipologiaIncarico' , @Param ,1) ,'''','''''')
	set @OrdineProfessionale			= replace( dbo.GetParam( 'OrdineProfessionale' , @Param ,1) ,'''','''''')
	set @AttivitaProfessionale		= replace( dbo.GetParam( 'AttivitaProfessionale' , @Param ,1) ,'''','''''')

	set @participantID				= replace( dbo.GetParam( 'PARTICIPANTID' , @Param ,1) ,'''','''''')
	set @iscrittoPeppol				= replace( dbo.GetParam( 'iscrittoPeppol' , @Param ,1) ,'''','''''')
	
	set @DataIscrizioneDal		     = left( replace( dbo.GetParam( 'DataIscrizioneDal' , @Param ,1) ,'''',''''''), 16)
	set @DataIscrizioneAl		     = left(replace( dbo.GetParam( 'DataIscrizioneAl' , @Param ,1) ,'''',''''''), 16)
	
	set @certificazioni = replace( dbo.GetParam( 'Certificazioni' , @Param ,1) ,'''','''''')

	set @IdBando_v = dbo.GetParam( 'IdBando' , @Param ,1) 
	set @StatoAbilitazione = dbo.GetParam( 'StatoAbilitazione' , @Param ,1) 

	--declare @testInt int
	--set @testInt = 'errore'

	set @Filtro_ClasseIscriz = replace( dbo.GetParam( 'Filtro_ClasseIscriz' , @Param , 1) , '''', '''''')
	if left(@Filtro_ClasseIscriz, 1) = '%'
		set @Filtro_ClasseIscriz = substring(@Filtro_ClasseIscriz, 2 , len(@Filtro_ClasseIscriz) - 2)

	if @ClasseIscriz <> ''
	begin	
		
		--	select top 0 DMV_Father as ColPath into #temp_ClasseIscriz from lib_domainvalues WITH (NOLOCK)
		--		exec recuperaPathDaDominio 'ClasseIscriz', @ClasseIscriz

		select top 0 DMV_Father as ColPath,DMV_Father as ColPathFather into #temp_ClasseIscriz from lib_domainvalues 
		--cambiato stored che mi ritorna anche ColPathFather
		exec recuperaPathDaDominioEsteso 'ClasseIscriz', @ClasseIscriz
		
	end
	
	
	if @ClasseIscrizFILTRO <> ''
	begin	
		
		select top 0 DMV_Father as ColPath into #temp_ClasseIscrizFILTRO from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'ClasseIscriz', @ClasseIscrizFILTRO,'#temp_ClasseIscrizFILTRO'
		
	end

	if @ATECO <> ''
	begin	
		
		select top 0 DMV_Father as ColPath into #temp_ATECO from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'ATECO', @ATECO
		
	end
	
	if @GerarchicoSOA <> ''
	begin	
		
		--select top 0 DMV_Father as ColPath into #temp_GerarchicoSOA from lib_domainvalues  WITH (NOLOCK)
		--exec recuperaPathDaDominio 'GerarchicoSOA', @GerarchicoSOA
		select top 0 DMV_Father as ColPath,DMV_Father as ColPathFather into #temp_GerarchicoSOA from lib_domainvalues 
		--cambiato stored che mi ritorna anche ColPathFather
		exec recuperaPathDaDominioEsteso 'GerarchicoSOA', @GerarchicoSOA
		
	end

	if @AreaGeograficaAlbo <> ''
	begin	
		
		select top 0 DMV_Father as ColPath into #temp_AreaGeograficaAlbo from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'AreaGeograficaAlbo', @AreaGeograficaAlbo
		
	end

	if @certificazioni <> ''
	begin	
		
		select top 0 DMV_Father as ColPath into #temp_Certificazioni from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'Certificazioni', @certificazioni
		
	end



	if @CARClasMercAzienda <> ''
	begin

		set @CARClasMercAzienda = replace( @CARClasMercAzienda , '###' , ''',''' )
		set @CARClasMercAzienda = substring( @CARClasMercAzienda  , 2 , len( @CARClasMercAzienda ) - 2 )
	
	end
	--print @Province_Dove_Opera
	if @Province_Dove_Opera <> ''
	begin

		set @Province_Dove_Opera = replace( @Province_Dove_Opera , '###' , ''',''' )
		set @Province_Dove_Opera = substring( @Province_Dove_Opera  , 3 , len( @Province_Dove_Opera ) - 4 )
	
	end
	--print @Province_Dove_Opera
	--print @Tempi_Medi_gg_consegna
	if @Tempi_Medi_gg_consegna <> ''
	begin

		set @Tempi_Medi_gg_consegna = replace( @Tempi_Medi_gg_consegna , '###' , ''',''' )
		set @Tempi_Medi_gg_consegna = substring( @Tempi_Medi_gg_consegna  , 3 , len( @Tempi_Medi_gg_consegna ) - 4 )
	
	end
	--print @Tempi_Medi_gg_consegna
	--print @Fatturato_ultimo_anno
	if @Fatturato_ultimo_anno <> ''
	begin

		set @Fatturato_ultimo_anno = replace( @Fatturato_ultimo_anno , '###' , ''',''' )
		set @Fatturato_ultimo_anno = substring( @Fatturato_ultimo_anno  , 3 , len( @Fatturato_ultimo_anno ) - 4 )
	
	end
	--print @Fatturato_ultimo_anno

	if @AttivitaProfessionale <> ''
	begin	
		
		select top 0 DMV_Father as ColPath into #temp_TipologiaIncarico from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'TipologiaIncarico', @AttivitaProfessionale
		
	end

	
	-----------------------------------------------------
	-- SI DETERMINA LA RESTRIZIONE PER ULTERIORI CRITERI
	-----------------------------------------------------

	declare @idx int
	set @idx=1
	declare @RestrictAzi int
	set @RestrictAzi  = 0
	
	if @ClasseIscriz <> '' 
	begin 
        

		IF EXISTS ( select * from CTL_Parametri with(nolock) where Contesto='selezione_fascia' and Oggetto='ClasseIscriz' and Proprieta='esclusiva' and Valore='SI')
		BEGIN
			set @esclusiva='SI'
		END

		--operatore da utilizzare per la ClasseIscriz (salita o discesa sui gerarchici o enterambi)
		declare @opClasseIscr as nvarchar(10)
		set @opClasseIscr = dbo.GetParamOperation( 'ClasseIscriz' , @Param ,1)
		
		IF EXISTS ( select * from CTL_RELATIONS  WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='opClasseIscr' )
		BEGIN
			 select top 1 @opClasseIscr=REL_VALUEOUTPUT from CTL_RELATIONS  WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='opClasseIscr'
		END

		declare @navigaAlbero as nvarchar(500)
		

		set @Operatore = 'AND'

		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS  WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='ClasseIscr' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS  WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='ClasseIscr'
		END

		
		if @Operatore = 'AND'
		begin
			
			--set @idx = 1
			declare CurClasseIsc Cursor static for 
				Select ColPath , ColPathFather
					from #temp_ClasseIscriz 
						
			
			open CurClasseIsc

			FETCH NEXT FROM CurClasseIsc 	INTO @ColPath , @ColPathFather
			WHILE @@FETCH_STATUS = 0
			BEGIN


				if @esclusiva = 'SI'  
				begin
					--IN QUESTO CASO FACCIAMO LA RICERCA PER FASCIA, SI PRENDE SE STESSO ED I FRATELLI DI ORDINE SUPERIORE		
					set @navigaAlbero = ' and  dmv_father like ''' + @ColPathFather + '%''  and  dmv_father >= ''' + @ColPath + ''' '
				end
				else
				begin
					if rtrim(ltrim(@opClasseIscr)) = '='
					begin
						set @navigaAlbero = ' and  ( left(  dm.dmv_father , len ( ''' + @ColPath + ''' )) =   ''' + @ColPath + ''' or left( ''' + @ColPath + ''' , len (  dm.dmv_father )) = dm.dmv_father ) '
					end
				
					if rtrim(ltrim(@opClasseIscr)) = '>'
					begin
						set @navigaAlbero = ' and ( left(  dm.dmv_father , len ( ''' + @ColPath + ''' )) =  ''' + @ColPath + ''' ) '
					end

					if rtrim(ltrim(@opClasseIscr)) = '<'
					begin
						set @navigaAlbero = ' and ( left( ''' + @ColPath + ''' , len ( dm.dmv_father )) =  dm.dmv_father) '
					end
				end
				
				
				
			

				
				-- se il path della classeIscrizione sull'azienda è contenuto nel path ricercato oppure
				-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
				--inner join DizionarioAttributi dzta WITH (NOLOCK) on dzta.dztnome = c.dztnome 
				--inner join DominiGerarchici dm WITH (NOLOCK) on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlbero + @CrLf + 
				set @idx = @idx + 1
				set @SQLAZI = ' select a.idazi into #TempAziTT_' + cast( @idx as varchar) + ' from  aziende a  WITH (NOLOCK)  
											inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''											
											inner join ClasseIscriz  dm on dm.dmv_cod=vatvalore_ft ' + @CrLf + @navigaAlbero + @CrLf + 
											' inner join #TempResulAziende t on t.idazi = a.idazi
											 where  azideleted=0 and dm.dmv_father <> ''''  
											
									truncate table  #TempResulAziende
									insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAziTT_' + cast( @idx as varchar) + '
									drop table #TempAziTT_' + cast( @idx as varchar) + '
											' + @CrLf

				
				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi  = 1



				FETCH NEXT FROM CurClasseIsc 	INTO @ColPath , @ColPathFather
			END 
			CLOSE CurClasseIsc
			DEALLOCATE CurClasseIsc	




		end
		else
		begin

			if @esclusiva = 'SI'  
			begin
				--IN QUESTO CASO FACCIAMO LA RICERCA PER FASCIA, SI PRENDE SE STESSO ED I FRATELLI DI ORDINE SUPERIORE		
				set @navigaAlbero = ' inner join #temp_ClasseIscriz d on  dm.dmv_father like d.ColPathFather + ''%''  and  dm.dmv_father >= d.ColPath'
			end
			else
			begin
				if rtrim(ltrim(@opClasseIscr)) = '='
				begin
					set @navigaAlbero = ' inner join #temp_ClasseIscriz d on ( left(  dm.dmv_father , len ( d.ColPath )) =  d.ColPath or left( d.ColPath , len (  dm.dmv_father )) =  dm.dmv_father ) '
				end
			
				if rtrim(ltrim(@opClasseIscr)) = '>'
				begin
					set @navigaAlbero = ' inner join #temp_ClasseIscriz d on ( left(  dm.dmv_father , len ( d.ColPath )) =  d.ColPath ) '
				end

				if rtrim(ltrim(@opClasseIscr)) = '<'
				begin
					set @navigaAlbero = ' inner join #temp_ClasseIscriz d on ( left( d.ColPath , len ( dm.dmv_father )) =  dm.dmv_father) '
				end
			end
			
			-- se il path della classeIscrizione sull'azienda è contenuto nel path ricercato oppure
			-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
			--inner join DizionarioAttributi dzta WITH (NOLOCK) on dzta.dztnome = c.dztnome 
			--inner join DominiGerarchici dm WITH (NOLOCK) on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlbero + @CrLf + 
			
			set @SQLAZI =  '  select a.idazi into #TempAzi_2 from  aziende a WITH (NOLOCK)  inner join dm_attributi c WITH (NOLOCK)  on c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''										
										inner join ClasseIscriz  dm on dm.dmv_cod=vatvalore_ft ' + @CrLf + @navigaAlbero + @CrLf + 
										'  inner join #TempResulAziende t on t.idazi = a.idazi
										where 
														  azideleted=0 and dm.dmv_father <> ''''  
									truncate table   #TempResulAziende
									insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_2  
									drop table #TempAzi_2
														  ' + @CrLf
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1



		end
	end
	
	

	if @ClasseIscrizFILTRO <> '' 
	begin 
        
		--operatore da utilizzare per la ClasseIscriz (salita o discesa sui gerarchici o enterambi)
		set @ColPath=''
		declare @opClasseIscrFILTRO as nvarchar(10)
		set @opClasseIscrFILTRO = dbo.GetParamOperation( 'ClasseIscrizFILTRO' , @Param ,1)
		-----------------------------
		---- RECUPERARE PARAMETRO @@opClasseIscrFILTRO
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS WITH (NOLOCK)  where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='opClasseIscrizFILTRO' )
		BEGIN
			 select top 1 @opClasseIscrFILTRO=REL_VALUEOUTPUT from CTL_RELATIONS WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='opClasseIscrizFILTRO'
		END

				
		declare @navigaAlberoFILTRO as nvarchar(500)
		
		set @Operatore = 'OR'
		-----------------------------
		---- RECUPERARE PARAMETRO @@Operatore -- ClasseIscrizFILTRO
		-----------------------------		
		IF EXISTS ( select * from CTL_RELATIONS WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='ClasseIscrizFILTRO' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='ClasseIscrizFILTRO'
		END


		if @Operatore = 'AND'
		begin
			
			--set @idx = 1

			declare CurClasseIscFILTRO Cursor static for 
				Select ColPath
					from #temp_ClasseIscrizFILTRO 
						
			
			open CurClasseIscFILTRO
			
			FETCH NEXT FROM CurClasseIscFILTRO 	INTO @ColPath
			WHILE @@FETCH_STATUS = 0
			BEGIN
			

				if rtrim(ltrim(@opClasseIscrFILTRO)) = '='
				begin
					set @navigaAlberoFILTRO = ' and  ( left(  dm.dmv_father , len ( ''' + @ColPath + ''' )) =   ''' + @ColPath + ''' or left( ''' + @ColPath + ''' , len (  dm.dmv_father )) =  dm.dmv_father ) '
				end
				
				if rtrim(ltrim(@opClasseIscrFILTRO)) = '>'
				begin
					set @navigaAlberoFILTRO = ' and ( left( dm.dmv_father , len ( ''' + @ColPath + ''' )) =  ''' + @ColPath + ''' ) '
				end

				if rtrim(ltrim(@opClasseIscrFILTRO)) = '<'
				begin
					set @navigaAlberoFILTRO = ' and ( left( ''' + @ColPath + ''' , len ( dm.dmv_father )) =  dm.dmv_father) '
				end

				
				-- se il path della classeIscrizione sull'azienda è contenuto nel path ricercato oppure
				-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
				set @idx = @idx + 1
				set @SQLAZI = ' select a.idazi into #TempAziTT_' + cast( @idx as varchar) + ' from  aziende a WITH (NOLOCK)  
											inner join  dm_attributi c WITH (NOLOCK) on  c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''
											inner join ClasseIscriz  dm on dm.dmv_cod=vatvalore_ft ' + @CrLf + @navigaAlberoFILTRO + @CrLf + 
											' inner join #TempResulAziende t on t.idazi = a.idazi
											 where  azideleted=0 and dm.dmv_father <> ''''  
											
									truncate table  #TempResulAziende
									insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAziTT_' + cast( @idx as varchar) + '
									drop table #TempAziTT_' + cast( @idx as varchar) + '
											' + @CrLf

				--exec ( @SQLAZI )  
				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi  = 1



				FETCH NEXT FROM CurClasseIscFILTRO 	INTO @ColPath
			END 
			CLOSE CurClasseIscFILTRO
			DEALLOCATE CurClasseIscFILTRO	




		end
		else
		begin

		
			if rtrim(ltrim(@opClasseIscrFILTRO)) = '='
			begin
				set @navigaAlberoFILTRO = ' inner join #temp_ClasseIscrizFILTRO d on ( left(  dm.dmv_father , len ( d.ColPath )) =  d.ColPath or left( d.ColPath , len (   dm.dmv_father )) =   dm.dmv_father ) '
			end
			
			if rtrim(ltrim(@opClasseIscrFILTRO)) = '>'
			begin
				set @navigaAlberoFILTRO = ' inner join #temp_ClasseIscrizFILTRO d on ( left(  dm.dmv_father , len ( d.ColPath )) =  d.ColPath ) '
			end

			if rtrim(ltrim(@opClasseIscrFILTRO)) = '<'
			begin
				set @navigaAlberoFILTRO = ' inner join #temp_ClasseIscrizFILTRO d on ( left( d.ColPath , len (  dm.dmv_father )) =   dm.dmv_father) '
			end

			
			-- se il path della classeIscrizione sull'azienda è contenuto nel path ricercato oppure
			-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
			set @SQLAZI =  '  select a.idazi into #TempAzi_2 from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''
										inner join ClasseIscriz  dm on dm.dmv_cod=vatvalore_ft ' + @CrLf + @navigaAlberoFILTRO + @CrLf + 
										'  inner join #TempResulAziende t on t.idazi = a.idazi
										where 
														  azideleted=0 and dm.dmv_father <> ''''  
									truncate table   #TempResulAziende
									insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_2  
									drop table #TempAzi_2
														  ' + @CrLf
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1



		end
	end
	
	
	if @ListaAlbi <> ''
	begin
		set @ListaAlbi = replace( @ListaAlbi , '###' , ',' )
		if substring( @ListaAlbi , 1 , 1 ) = ','
			set @ListaAlbi = substring( @ListaAlbi , 2 , len( @ListaAlbi ) -2)

		
		set @SQLAZI = '   select a.IdAzi into #TempAzi_3 from CTL_DOC_Destinatari a WITH (NOLOCK)  inner join #TempResulAziende t on t.idazi = a.idazi where idHeader in ( ' + @ListaAlbi + ' ) and StatoIscrizione = ''Iscritto'' '

		if @DataIscrizioneDal <> ''
		  set @SQLAZI = @SQLAZI + ' and convert( varchar(16) , DataIscrizione , 121 ) >= ''' + @DataIscrizioneDal  + '''  '
		 
		if @DataIscrizioneAl <> ''
		  set @SQLAZI = @SQLAZI + ' and convert( varchar(16) , DataIscrizione , 121 ) <= ''' + @DataIscrizioneAl   + '''  '

		set @SQLAZI = @SQLAZI + '   
			 truncate table   #TempResulAziende
			 insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_3	
			 drop table #TempAzi_3

			 ' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1
	end
	

	if @sysHabilitStartDateDa <> ''
	begin
		
		set @SQLAZI =  '  select lnk as idAzi into #TempAzi_4 from DM_Attributi WITH (NOLOCK) inner join #TempResulAziende t on t.idazi = lnk where dztNome = ''sysHabilitStartDate'' and idapp = 1 and left( vatvalore_ft , 10 ) >= ''' + @sysHabilitStartDateDa + ''' 
		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_4	
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end


	if @sysHabilitStartDateA <> ''
	begin
		
		set @SQLAZI = '  select lnk as idAzi into #TempAzi_5 from DM_Attributi WITH (NOLOCK)  inner join #TempResulAziende t on t.idazi = lnk where dztNome = ''sysHabilitStartDate'' and idapp = 1 and left( vatvalore_ft , 10 ) <= ''' + @sysHabilitStartDateA + ''' 
		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_5	
		drop table #TempAzi_5	
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end


	if @sysHabilitStartDate <> ''
	begin
	
		set @SQLAZI = '  select lnk as idAzi into #TempAzi_15 from DM_Attributi WITH (NOLOCK)   inner join #TempResulAziende t on t.idazi = lnk where dztNome = ''sysHabilitStartDate'' and idapp = 1 and left( vatvalore_ft , 10 ) = ''' + @sysHabilitStartDate + ''' 
		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_15	
		drop table #TempAzi_5	
		' 
	
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1
	end


	if @CodiceArticolo <> ''
	begin

		set @SQLAZI = ' select artIdAzi as idAzi into #TempAzi_6 from Articoli WITH (NOLOCK)  inner join #TempResulAziende t on t.idazi = artIdAzi  where artdeleted = 0 and artCode like ''' + @CodiceArticolo + ''' 
		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_6	
		drop table #TempAzi_6	
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end



	if @MercerceologiaFornitore <> '' 
	begin 

		set @MercerceologiaFornitore=substring(@MercerceologiaFornitore,4,len(@MercerceologiaFornitore))
		set @MercerceologiaFornitore=substring(@MercerceologiaFornitore,1,len(@MercerceologiaFornitore)-3)

		set @MercerceologiaFornitore=replace(@MercerceologiaFornitore,'###',''',''')

		set @MercerceologiaFornitore = '''' + @MercerceologiaFornitore + ''''


        set @SQLAZI =  '  select a.idazi  into #TempAzi_7	from  aziende a WITH (NOLOCK)  
												inner join  mpaziende WITH (NOLOCK)  on  a.idazi=mpaidazi and   mpaidmp = 1 and   mpadeleted = 0
												inner join dm_attributi c WITH (NOLOCK)  on  c.lnk = a.idazi and c.dztnome = ''Merceologia''
															and   c.vatvalore_FT in ( ' + @MercerceologiaFornitore + ' )
												  inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 
												
												
		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_7	
		drop table #TempAzi_7
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end


	if @MercerceologiaFornitore_2 <> '' 
	begin 

        set @SQLAZI =  '  select a.idazi   into #TempAzi_7_2 from	 aziende a WITH (NOLOCK)  
												inner join  mpaziende WITH (NOLOCK)  on  a.idazi=mpaidazi and   mpaidmp = 1 and   mpadeleted = 0
												inner join dm_attributi c WITH (NOLOCK)  on c.lnk = a.idazi and c.dztnome = ''CARClasMercAzienda''
															and   c.vatvalore_FT = ''' + @MercerceologiaFornitore_2 + ''' 
												  inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 
												
												
		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_7_2	
		drop table #TempAzi_7_2
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end

	if  @attivoCPN <> ''
	begin 
     
	   set @SQLAZI =  '  select a.idazi from  into #TempAzi_8	 aziende a WITH (NOLOCK)  
												inner join  mpaziende WITH (NOLOCK) on  a.idazi=mpaidazi and   mpaidmp = 1 and   mpadeleted = 0
												inner join dm_attributi c WITH (NOLOCK)  on  c.lnk = a.idazi and c.dztnome = ''CARFornitoreAttivo''
															and   c.vatvalore_FT = ''' + @attivoCPN + ''' 
												  inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 

												
												
		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_8	
		drop table #TempAzi_8
		' 
	
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end



	if  @Iscritto = '1'
	begin 

        set @SQLAZI = ' select a.idazi into #TempAzi_9 from  aziende WITH (NOLOCK)  a inner join dm_attributi c WITH (NOLOCK)  on c.lnk = a.idazi and c.dztnome = ''CARBelongTo'' and   c.vatvalore_FT = ''1'' 
											  inner join #TempResulAziende t on t.idazi = a.IdAzi
												
												where azideleted=0 

		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_9	
		drop table #TempAzi_9
		' 

		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
	   	set @RestrictAzi  = 1

	end


	-- per default la piattaforma non lo gestisce ( recupero proprietà con valore = 0 )
	if  @Iscritto = '0'
	begin 


        set @SQLAZI = ' select a.idazi into #TempAzi_91 from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK)  on c.lnk = a.idazi and c.dztnome = ''CARBelongTo'' and   c.vatvalore_FT = ''0'' 
											  inner join #TempResulAziende t on t.idazi = a.IdAzi
												
												where azideleted=0 

		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_91	
		drop table #TempAzi_91
		' 
		--exec ( @SQLAZI )  
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end  


	if @CancellatoDiUfficio = '1'
	begin 

        set @SQLAZI = ' select a.idazi into #TempAzi_10 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''CancellatoDiUfficio'' and   c.vatvalore_FT = ''1'' 
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_10	
		drop table #TempAzi_10
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1



	end

	if @CancellatoDiUfficio = '0'
	begin 

        
        set @SQLAZI =  ' select a.idazi into #TempAzi_11 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK)  on c.lnk = a.idazi and c.dztnome = ''CancellatoDiUfficio'' and   c.vatvalore_FT = ''0'' 
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_11	
		drop table #TempAzi_11
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1


	end


	if @CancellatoDiUfficio = '2'
	begin 

        
        set @SQLAZI = ' select a.idazi into #TempAzi_12 from  aziende a WITH (NOLOCK)  inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''CancellatoDiUfficio'' and   c.vatvalore_FT = ''2'' 
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_12	
		drop table #TempAzi_12
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end


	if @AltraClassificazione <> '' 
	begin 
        
        set @SQLAZI = ' select a.idazi into #TempAzi_13 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK)  on c.lnk = a.idazi and c.dztnome = ''AltraClassificazione'' and   c.vatvalore_FT = ''' + @AltraClassificazione + ''' 
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_13	
		drop table #TempAzi_13
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end


	if @CARClasMercAzienda <> '' 
	begin 
        

        set @SQLAZI = ' select a.idazi into #TempAzi_14 from  aziende a WITH (NOLOCK)  inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''CARClasMercAzienda'' and   c.vatvalore_FT in ( ' + @CARClasMercAzienda + ' )
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_14	
		drop table #TempAzi_14
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end

	if @Province_Dove_Opera <> '' 
	begin 
        

        set @SQLAZI = ' select a.idazi into #TempAzi_141 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''Province_Dove_Opera'' and   c.vatvalore_FT in ( ' + @Province_Dove_Opera + ' )
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_141
		drop table #TempAzi_141
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end

	if @Tempi_Medi_gg_consegna <> '' 
	begin 
        

        set @SQLAZI = ' select a.idazi into #TempAzi_1411 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''Tempi_Medi_gg_consegna'' and   c.vatvalore_FT in ( ' + @Tempi_Medi_gg_consegna + ' )
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_1411
		drop table #TempAzi_1411
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end

	if @Fatturato_ultimo_anno <> '' 
	begin 
        

        set @SQLAZI = ' select a.idazi into #TempAzi_14111 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''Fatturato_ultimo_anno'' and   c.vatvalore_FT in ( ' + @Fatturato_ultimo_anno + ' )
												inner join #TempResulAziende t on t.idazi = a.IdAzi
												where azideleted=0 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_14111
		drop table #TempAzi_14111
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end


	if @ATECO <> '' 
	begin 
        
		--operatore da utilizzare per la ClasseIscriz (salita o discesa sui gerarchici o enterambi)
		declare @opClasseATECO as nvarchar(10)
		set @opClasseATECO = dbo.GetParamOperation( 'ATECO' , @Param ,1)
		
		declare @navigaAlberoATECO as nvarchar(500)
		
		---controllo se esiste la relazione per la gestione della modalità di ricerca
		IF EXISTS ( select * from CTL_RELATIONS WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='opClasseATECO' )
		BEGIN
			 select top 1 @opClasseATECO=REL_VALUEOUTPUT from CTL_RELATIONS WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='opClasseATECO'
		END


		if rtrim(ltrim(@opClasseATECO)) = '='
		begin
			set @navigaAlberoATECO = ' inner join #temp_ATECO d on ( left( ''000.'' + dm.dgPath , len ( d.ColPath )) =  d.ColPath or left( d.ColPath , len ( ''000.'' + dm.dgPath )) = ''000.'' + dm.dgPath ) '
		end
		
		if rtrim(ltrim(@opClasseATECO)) = '>'
		begin
			set @navigaAlberoATECO = ' inner join #temp_ATECO d on ( left( ''000.'' + dm.dgPath , len ( d.ColPath )) =  d.ColPath ) '
		end

		if rtrim(ltrim(@opClasseATECO)) = '<'
		begin
			set @navigaAlberoATECO = ' inner join #temp_ATECO d on ( left( d.ColPath , len ( ''000.'' + dm.dgPath )) = ''000.'' + dm.dgPath) '
		end

		
		-- se il path della classeIscrizione sull'azienda è contenuto nel path ricercato oppure
		-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
		
		set @SQLAZI = '   select a.idazi into #TempAzi_16 from  aziende a WITH (NOLOCK)  
									inner join aziateco c WITH (NOLOCK)  on c.idazi = a.idazi
									inner join DizionarioAttributi dzta WITH (NOLOCK)  on dzta.dztnome = ''ATECO'' 
									inner join DominiGerarchici dm WITH (NOLOCK)  on dzta.dztIdTid = dgTipoGerarchia  and atvatecord = dgCodiceInterno ' + @CrLf + @navigaAlberoATECO + @CrLf + 
									'
									inner join #TempResulAziende t on t.idazi = a.IdAzi 
									where  azideleted=0 

		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_16	
		drop table #TempAzi_16
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1



	end

	
	-----------------------------
	---- GESTIRE AND / OR 
	-----------------------------
	if @GerarchicoSOA <> '' 
	begin 

		IF EXISTS ( select * from CTL_Parametri with(nolock) where Contesto='selezione_fascia' and Oggetto='GerarchicoSOA' and Proprieta='esclusiva' and Valore='SI')
		BEGIN
			set @esclusiva='SI'
		END
		
		declare @navigaAlberoGerarchicoSOA as nvarchar(500)

		set @Operatore = 'AND'

		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='GerarchicoSOA' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS WITH (NOLOCK)  where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='GerarchicoSOA'
		END

		
		if @Operatore = 'AND'	 
		begin
			 set @idx = 1

			 declare CurCategoriaSOA Cursor static for 
				Select ColPathFather,ColPath
					   from #temp_GerarchicoSOA 
						
			
			 open CurCategoriaSOA

			 FETCH NEXT FROM CurCategoriaSOA 	INTO @ColPathFather,@ColPath
			 WHILE @@FETCH_STATUS = 0
			 BEGIN

				set @idx = @idx + 1

				if exists(select top 1 * from LIB_DomainValues where dmv_dm_id= 'GerarchicoSOA' )
				--LIB_DomainValues
				begin
				 
				    --set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(''' + @ColPath +''',len('''+ @ColPath +''')-4)=left(dmv_father,len(dmv_father)-4) and  dmv_father >=colpath ' 
					
					--set @SQLAZI =  '   select a.idazi into  #TempAzi_TTT' + cast( @idx as varchar) + ' from  aziende a WITH (NOLOCK)  inner join dm_attributi c WITH (NOLOCK)  on  c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA''
								--			 inner join LIB_DomainValues dm WITH (NOLOCK) on dm.dmv_dm_id= ''GerarchicoSOA'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
								--			 ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
								--			 where azideleted=0 and dm.dmv_father <> '''' 


				    --truncate table   #TempResulAziende
				    --insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAzi_TTT' + cast( @idx as varchar) + '
				    --drop table #TempAzi_TTT' + cast( @idx as varchar) + '
				    --' + @CrLf

						
					IF @esclusiva='SI'
						set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on dmv_father like ''' + @ColPathFather + '%''  and  dmv_father >= ''' + @ColPath + ''' ' 
					ELSE
						set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on dmv_father like ''' + @ColPathFather + '%''  and  dmv_father = ''' + @ColPath + ''' '  

					set @SQLAZI =  '   select a.idazi into  #TempAzi_TTT' + cast( @idx as varchar) + ' 
											from  aziende a 
												inner join dm_attributi c on  c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA'' 
												inner join GerarchicoSOA dm on vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + '
												inner join #TempResulAziende t on t.idazi = a.IdAzi 
											where azideleted=0 and dm.dmv_father <> '''' 


				    truncate table   #TempResulAziende
				    insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAzi_TTT' + cast( @idx as varchar) + '
				    drop table #TempAzi_TTT' + cast( @idx as varchar) + '
				    ' + @CrLf
				end
				--else
				----dominigerarchici
				--begin
				
				--    set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(''' + @ColPath +''',len('''+ @ColPath +''')-4)=left(''000.'' + dgPath,len(''000.'' + dgPath)-4) and ''000.'' + dgPath >=colpath ' 

				    
				
				--    set @SQLAZI =  '   select a.idazi into  #TempAziTTT_' + cast( @idx as varchar) + ' from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA''
				--							 inner join DizionarioAttributi dzta WITH (NOLOCK) on dzta.dztnome = c.dztnome 
				--							 inner join DominiGerarchici dm WITH (NOLOCK) on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
				--							 ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
				--							 where azideleted=0 and dm.dgPath <> '''' 


				--    truncate table   #TempResulAziende
				--    insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTT_' + cast( @idx as varchar) + '
				--    drop table #TempAziTTT_' + cast( @idx as varchar) + '
				--    ' + @CrLf
				
				--end

				
				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi  = 1



				FETCH NEXT FROM CurCategoriaSOA 	INTO @ColPathFather,@ColPath
			 END 
			 CLOSE CurCategoriaSOA
			 DEALLOCATE CurCategoriaSOA	

	   end

	   else

	   begin
		  	
			if exists(select top 1 * from LIB_DomainValues where dmv_dm_id= 'GerarchicoSOA' )
			--LIB_DomainValues
			begin

				--set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(colPath,len(ColPath)-4)=left(dmv_father,len(dmv_father)-4) and  dmv_father >=colpath ' 

				--set @SQLAZI =  '   select a.idazi into  #TempAzi_17  from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA''
				--						  inner join LIB_DomainValues dm WITH (NOLOCK)  on dm.dmv_dm_id= ''GerarchicoSOA'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
				--						  ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
				--						  where azideleted=0 and dm.dmv_father <> '''' 


				--				truncate table   #TempResulAziende
				--				insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAzi_17 
				--				drop table #TempAzi_17 
				--				' + @CrLf

				
				--set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on dmv_father like ''' + @ColPathFather + '%''  and  dmv_father >=colpath ' 					
				IF @esclusiva='SI'
					set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(colPath,len(ColPath)-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father >=colpath  ' 
				ELSE
					set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(colPath,len(ColPath)-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father =colpath  ' 

					
				set @SQLAZI =  '   select a.idazi into  #TempAzi_17' + cast( @idx as varchar) + '
											from  aziende a 
												inner join dm_attributi c on  c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA'' 
												inner join GerarchicoSOA dm on vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + '
												inner join #TempResulAziende t on t.idazi = a.IdAzi 
											where azideleted=0 and dm.dmv_father <> ''''


									truncate table   #TempResulAziende
									insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAzi_17' + cast( @idx as varchar) + '
									drop table #TempAzi_17' + cast( @idx as varchar) + '
									' + @CrLf

			end

			--else
			----dominigerarchici
			--begin
				
			--	-- se il path della classeIscrizione sull'azienda è contenuto nel path ricercato oppure
			--	-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
			--	set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(ColPath,len(ColPath)-4)=left(''000.'' + dgPath,len(''000.'' + dgPath)-4) and ''000.'' + dgPath >=colpath ' 

			--	set @SQLAZI =  '  select a.idazi into TempAzi_17  from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''
			--							inner join DizionarioAttributi dzta WITH (NOLOCK) on dzta.dztnome = c.dztnome 
			--							inner join DominiGerarchici dm WITH (NOLOCK) on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
			--							'  inner join #TempResulAziende t on t.idazi = a.idazi
			--							where 
			--											  azideleted=0 and dm.dgPath <> ''''  
			--						truncate table   #TempResulAziende
			--						insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_17
			--						drop table #TempAzi_17
			--											  ' + @CrLf

			--end
			
		
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1

	   end

		

	end

	-----------------------------
	---- GESTIRE AND / OR 
	-----------------------------
	IF @certificazioni <> '' 
	BEGIN 

		declare @navigaCertificazioni varchar(4000)

		set @Operatore = 'AND'

		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS with(nolock) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='Certificazioni' )
		BEGIN
			 select top 1 @Operatore = REL_VALUEOUTPUT from CTL_RELATIONS with(nolock) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='Certificazioni'
		END

		if @Operatore = 'AND'	 
		begin

			set @idx = 1

			 declare CurAttivitaProfessionale Cursor static for 
				Select ColPath
					   from #temp_Certificazioni
						
			
			 open CurAttivitaProfessionale

			 FETCH NEXT FROM CurAttivitaProfessionale 	INTO @ColPath
			 WHILE @@FETCH_STATUS = 0
			 BEGIN

				set @idx = @idx + 1

				IF exists(select top 1 * from LIB_DomainValues WITH (NOLOCK) where dmv_dm_id= 'Certificazioni' )
				BEGIN
				 
				    set @navigaCertificazioni = ' inner join #temp_Certificazioni d on dmv_father = ''' + @ColPath + ''''

				    set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_' + cast( @idx as varchar) + ' from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.lnk = a.idazi and c.dztnome = ''CertificazioneQualita''
											 inner join LIB_DomainValues dm WITH (NOLOCK) on dm.dmv_dm_id= ''Certificazioni'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaCertificazioni + @CrLf + 
											 ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
											 where azideleted=0 and dm.dmv_father <> '''' 


				    truncate table   #TempResulAziende
				    insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_' + cast( @idx as varchar) + '
				    drop table #TempAziTTTT_' + cast( @idx as varchar) + '
				    ' + @CrLf

				END
								
				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi  = 1

				FETCH NEXT FROM CurAttivitaProfessionale 	INTO @ColPath

			 END 
			 CLOSE CurAttivitaProfessionale
			 DEALLOCATE CurAttivitaProfessionale	

		end
		else
		begin

			-- IN OR

			IF exists(select top 1 id from LIB_DomainValues with(nolock) where dmv_dm_id= 'Certificazioni' )
			begin

				set @navigaCertificazioni = ' inner join #temp_Certificazioni d on dmv_father = ''' + @ColPath + ''''

				set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_  from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.lnk = a.idazi and c.dztnome = ''CertificazioneQualita''
										  inner join LIB_DomainValues dm WITH (NOLOCK) on dm.dmv_dm_id= ''Certificazioni'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaCertificazioni + @CrLf + 
										  ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
										  where azideleted=0 and dm.dmv_father <> '''' 


								truncate table   #TempResulAziende
								insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_ 
								drop table #TempAziTTTT_ 
								' + @CrLf

			end
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1

		end

	END


	



	if @AttivitaProfessionale <> '' 
	begin 
		
		declare @navigaAlberoAttivitaProfessionale as nvarchar(500)

		set @Operatore = 'AND'

		IF EXISTS ( select * from CTL_Parametri with(nolock) where Contesto='selezione_fascia' and Oggetto='TIPOLOGIAINCARICO' and Proprieta='esclusiva' and Valore='SI')
		BEGIN
			set @esclusiva='SI'
		END


		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS WITH (NOLOCK)  where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='AttivitaProfessionale' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='AttivitaProfessionale'
		END

		
		if @Operatore = 'AND'	 
		begin
			 set @idx = 1

			 declare CurAttivitaProfessionale Cursor static for 
				Select ColPath
					   from #temp_TipologiaIncarico 
						
			
			 open CurAttivitaProfessionale

			 FETCH NEXT FROM CurAttivitaProfessionale 	INTO @ColPath
			 WHILE @@FETCH_STATUS = 0
			 BEGIN

				set @idx = @idx + 1

				if exists(select top 1 * from LIB_DomainValues WITH (NOLOCK)  where dmv_dm_id= 'TipologiaIncarico' )
				--LIB_DomainValues
				begin
				 
				    
					
				    IF @esclusiva='SI'
						set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',8)=left(dmv_father,8) and  dmv_father >=colpath ' 
					ELSE
						set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',8)=left(dmv_father,8) and  dmv_father=colpath ' 


				    set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_' + cast( @idx as varchar) + ' from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.lnk = a.idazi and c.dztnome = ''AttivitaProfessionale''											 
											 inner join GESTIONE_DOMINIO_TipologiaIncarico dm on vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoAttivitaProfessionale + @CrLf + 											 
											 ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
											 where azideleted=0 and dm.dmv_father <> '''' 


				    truncate table   #TempResulAziende
				    insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_' + cast( @idx as varchar) + '
				    drop table #TempAziTTTT_' + cast( @idx as varchar) + '
				    ' + @CrLf
				end
								
				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi  = 1



				FETCH NEXT FROM CurAttivitaProfessionale 	INTO @ColPath
			 END 
			 CLOSE CurAttivitaProfessionale
			 DEALLOCATE CurAttivitaProfessionale	

	   end

	   else

	   begin
		  	
			if exists(select top 1 * from LIB_DomainValues where dmv_dm_id= 'TipologiaIncarico' )
			--LIB_DomainValues
			begin


				IF @esclusiva='SI'
					set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(colPath,8)=left(dmv_father,8) and  dmv_father >=colpath ' 
				ELSE
					set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on  left(colPath,8)=left(dmv_father,8) and  dmv_father =colpath ' 


				set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_  from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.lnk = a.idazi and c.dztnome = ''AttivitaProfessionale''
										  inner join GESTIONE_DOMINIO_TipologiaIncarico dm on vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoAttivitaProfessionale + @CrLf + 
										  ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
										  where azideleted=0 and dm.dmv_father <> '''' 


								truncate table   #TempResulAziende
								insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_ 
								drop table #TempAziTTTT_ 
								' + @CrLf

			end

			
		
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1

	   end

		

	end


	


	if @AreaGeograficaAlbo <> '' 
	begin 
		
		--SOLITAMENTE NEI FILTRI ANDIAMO PER OR
		--NEL CASO GESTIRE AND CON IL CURSORE
		set @Operatore = 'OR'
		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS  WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='AreaGeograficaAlbo' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS  WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='AreaGeograficaAlbo'
		END

		--LAVORA IN SALITA
		--Nella ricerca se cerco per una regione vuole significare che cerco un OE che 
		--è in grado di coprire tutta la regione, quindi mi usciranno OE 
		--che hanno selezionato quella regione oppure  l'italia 
		declare @navigaAlberoAreaGeograficaAlbo as nvarchar(max)
		
		set @navigaAlberoAreaGeograficaAlbo = ' inner join #temp_AreaGeograficaAlbo d on ( left( d.ColPath , len (  dm.dmv_father )) =   dm.dmv_father) '

			
		-- se il path della @AreaGeograficaAlbo sull'azienda è contenuto nel path ricercato oppure
		-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
		set @SQLAZI = '  select a.idazi into #TempAzi_19 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''AreaGeograficaAlbo''									
									inner join GESTIONE_DOMINIO_AreaGeograficaAlbo dm WITH (NOLOCK) on dm.dmv_cod=vatvalore_ft ' + @CrLf + @navigaAlberoAreaGeograficaAlbo + @CrLf + 
									' inner join #TempResulAziende t on t.idazi = a.IdAzi 
									where   azideleted=0 and dm.dmv_father <> '''' 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_19	
		drop table #TempAzi_19
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end



	if @SedeCCIAA <> '' 
	begin 
     
	   set @SQLAZI =  '   select a.idazi into #TempAzi_20 
									from  aziende a WITH (NOLOCK)  
										inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''SedeCCIAA'' and   c.vatvalore_FT = ''' + @SedeCCIAA + ''' 
										inner join #TempResulAziende t on t.idazi = a.IdAzi 
									where azideleted=0 

		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_20	
		drop table #TempAzi_20
		' 
	
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end

	if @IscrCCIAA <> '' 
	begin 
    
        set @SQLAZI =  '   select a.idazi into #TempAzi_21
									from  aziende a WITH (NOLOCK) 
										inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''IscrCCIAA'' and   c.vatvalore_FT = ''' + @IscrCCIAA + ''' 
										inner join #TempResulAziende t on t.idazi = a.IdAzi 
									where azideleted=0 

		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_21	
		drop table #TempAzi_21
		' 
	
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1
	end



	if @ANNOCOSTITUZIONE <> '' 
	begin 
     
        set @SQLAZI =  '   select a.idazi into #TempAzi_22 
									from  aziende a WITH (NOLOCK) 
										inner join  dm_attributi c WITH (NOLOCK) on c.lnk = a.idazi and c.dztnome = ''ANNOCOSTITUZIONE'' and   c.vatvalore_FT = ''' + @ANNOCOSTITUZIONE + ''' 
										inner join #TempResulAziende t on t.idazi = a.IdAzi 
									where azideleted=0 

		truncate table   #TempResulAziende
		select * into #TempResulAziende from #TempAzi_22	
		drop table #TempAzi_22
		' 
	
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

	end


	if @IdBando_v is not null and @IdBando_v <> ''
	begin
		
		--set @IdBando = @IdBando_v

		--set @SQLCmd = @SQLCmd + ' and x.idheader = '  + @IdBando_v + ' '  + @CrLf

		--set @SQLCmd = @SQLCmd + ' and a.idazi in (select idazi from Document_Questionario_Fornitore_Punteggi where idheader = '  + @IdBando_v + ' ) '  + @CrLf
		
		set @SQLAZI =  '   select a.idazi into #TempAzi_2234 
									from  Document_Questionario_Fornitore_Punteggi a WITH (NOLOCK) 	
										inner join #TempResulAziende t on t.idazi = a.IdAzi 									
									where idheader =  '  + @IdBando_v + '

		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi )  select distinct idAzi from #TempAzi_2234	
		drop table #TempAzi_2234
		' 
	
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1

		  


	end

	if @StatoAbilitazione is not null and @StatoAbilitazione <> ''
	begin
		
		

		--set @SQLCmd = @SQLCmd + ' and x.StatoAbilitazione = '''  + @StatoAbilitazione + ''' '  + @CrLf
		

		--set @SQLCmd = @SQLCmd + ' and a.idazi in (select idazi from Document_Questionario_Fornitore_Punteggi where StatoAbilitazione = '''  + @StatoAbilitazione + ''' ) '  + @CrLf

		set @SQLAZI =  '   select a.idazi into #TempAzi_22344 
									from  Document_Questionario_Fornitore_Punteggi a WITH (NOLOCK) 	
										inner join #TempResulAziende t on t.idazi = a.IdAzi 									
									where StatoAbilitazione =  '''  + @StatoAbilitazione + '''

		truncate table   #TempResulAziende		
		insert into #TempResulAziende ( idAzi )  select distinct idAzi from #TempAzi_22344	
		drop table #TempAzi_22344
		' 
	
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		set @RestrictAzi  = 1


	end

	if @Filtro_ClasseIscriz <> '' 
	BEGIN 
     
		declare @modello as nvarchar(MAX)
		declare @modelloName as nvarchar(MAX)
		declare @attributo as nvarchar(MAX)
		declare @attrModello as nvarchar(MAX)
		declare @attrModelloValue as nvarchar(MAX)
		declare @opAttrModello as nvarchar(MAX)
		declare @strSqlAttributo as nvarchar(MAX)

		set @strSqlAttributo = ''

		select items into #modelli from [dbo].[Split] ( @Filtro_ClasseIscriz, '|||') 

		declare CurModelli CURSOR FOR select * from #modelli 
			OPEN CurModelli		
		
			FETCH NEXT FROM CurModelli INTO @modello
		
			while @@FETCH_STATUS = 0
			BEGIN	
				set @modelloName = replace(LEFT(@modello, CHARINDEX('~', @modello)-1), '#', '')
				set @modello = SUBSTRING(@modello, CHARINDEX('~', @modello) + 3, LEN(@modello))

				select items into #attributi from [dbo].[Split] ( @modello, '~~~') where SUBSTRING(items, CHARINDEX('=', items) + 1, LEN(items)) > ''
				declare CurAttributi CURSOR FOR select * from #attributi
				OPEN CurAttributi

				FETCH NEXT FROM CurAttributi INTO @attributo

				while @@FETCH_STATUS = 0
				BEGIN				
					set @attrModello = LEFT(@attributo, CHARINDEX('=', @attributo)-1)

					select 	@opAttrModello = cv.Value
						from ctl_doc c
							inner join CTL_DOC_Value CV on CV.idHeader=id and CV.DSE_ID='MODELLI' and CV.DZT_Name='DZT_Name'
						where TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO'	
							and c.Titolo= @modelloName
							--and c.Titolo='45452000_0'
							and c.Deleted=0 and cv.Value = @attrModello 

					if (@opAttrModello <> '') 
					BEGIN
						set @attrModelloValue = SUBSTRING(@attributo, CHARINDEX('=', @attributo) + 1, LEN(@attributo))

						if @attrModello = 'AddInfo_Att_SOA'
							set @strSqlAttributo = @strSqlAttributo + ' AND [dbo].[Intersezione_Insiemi]( ''' + @attrModelloValue + ''' , md.AddInfo_Att_SOA , ''###'' ) > '''''
						else
							set @strSqlAttributo = @strSqlAttributo + ' AND md.' + @attrModello + '=''' + @attrModelloValue + ''''

						set @opAttrModello = ''
					END

					FETCH NEXT FROM CurAttributi INTO @attributo
				
				END

				CLOSE CurAttributi
				DEALLOCATE CurAttributi

				DROP table #attributi
				FETCH NEXT FROM CurModelli INTO @modello
			END

			CLOSE CurModelli
			DEALLOCATE CurModelli

			if (@strSqlAttributo <> '')
			BEGIN

				set @SQLAZI =  ' select c.azienda into #TempAzi_25
									from ctl_doc c		 
										inner join CTL_DOC_Value cv on c.Id=IdHeader and cv.DSE_ID=''CLASSE'' and cv.DZT_Name=''ClasseIscriz''
										inner join Document_MicroLotti_Dettagli md on md.idHeader=c.Id
										inner join #TempResulAziende t on t.idazi = c.azienda
									where c.TipoDoc=''MERC_ADDITIONAL_INFO''
										and md.TipoDoc=''MERC_ADDITIONAL_INFO''
										and c.StatoFunzionale = ''InLavorazione'' 
										and c.Deleted=0 ' + @strSqlAttributo + '

				truncate table #TempResulAziende
				insert into #TempResulAziende ( idAzi )  select distinct azienda from #TempAzi_25
				drop table #TempAzi_25
				'

				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi = 1

			END

			DROP table #modelli

	end







	--------------------------- QUERY ------------------------------
	set @SQLCmd =  ''
	if @RestrictAzi  = 1
	begin
	
		set @SQLCmd = 'create table  #TempResulAziende ( idAzi  Int )
		insert into #TempResulAziende select idazi from aziende ' + @Crlf + @SQLRESTRICTAZI  + @Crlf

	end


	if @Filter <> 'RICERCA_OE'
	begin


		set @SQLCmd =  @SQLCmd +  '
		select IdAzi, aziLog, aziDataCreazione, aziRagioneSociale, aziIdDscFormaSoc, aziPartitaIVA, aziE_Mail, aziAcquirente, aziVenditore, aziProspect, aziIndirizzoLeg, aziIndirizzoOp, aziLocalitaLeg, aziLocalitaOp, aziProvinciaLeg, aziProvinciaOp, aziStatoLeg, aziStatoOp, aziCAPLeg, aziCapOp, aziPrefisso, aziTelefono1, aziTelefono2, aziFAX, aziIdDscDescrizione, aziGphValueOper, aziDeleted, aziDBNumber, aziAtvAtecord, aziSitoWeb, aziCodEurocredit, aziProfili,  CertificatoIscrAtt, TipoDiAmministr
			,d1.vatValore_FT as CodiceFiscale , d2.vatValore_FT as EmailRapLeg , d3.vatValore_FT as CARBelongTo , d4.vatValore_FT as CancellatoDiUfficio , dbo.GetMultiValueAzi(a.idAzi,''ClasseIscriz'') as ClasseIscriz
			,case when isnull(dd6.vatValore_FT,'''') = '''' then ''no'' else ''si'' end as iscrittoPeppol
			,dd7.vatValore_FT  as PARTICIPANTID

			, case when g.dmv_cod is null then '''' else right( ''000000'' + reverse( dbo.GetPos( reverse(  g.dmv_cod ) , ''-'' , 1 ) ) , 6 ) end as CodiceComune
			, case when g.dmv_cod is null then '''' else left( right( ''000000'' + reverse( dbo.GetPos( reverse(  g.dmv_cod ) , ''-'' , 1 ) ) , 6 ) , 3 ) end as CodiceProvincia
	 

		from aziende a WITH (NOLOCK) 
			left outer join DM_Attributi d1 WITH (NOLOCK)  on d1.lnk = idazi and d1.dztNome = ''CodiceFiscale'' and d1.idapp = 1
			left outer join DM_Attributi d2 WITH (NOLOCK) on d2.lnk = idazi and d2.dztNome = ''EmailRapLeg'' and d2.idapp = 1
			left outer join DM_Attributi d3 WITH (NOLOCK)  on d3.lnk = idazi and d3.dztNome = ''CARBelongTo'' and d3.idapp = 1
			left outer join DM_Attributi d4 WITH (NOLOCK) on d4.lnk = idazi and d4.dztNome = ''CancellatoDiUfficio'' and d4.idapp = 1

			left outer join DM_Attributi dd6 WITH (NOLOCK) on dd6.lnk = idazi and dd6.dztNome = ''IDNOTIER'' and dd6.idApp = 1
			left outer join DM_Attributi dd7 WITH (NOLOCK) on dd7.lnk = idazi and dd7.dztNome = ''PARTICIPANTID'' and dd7.idApp = 1

			left outer join lib_domainvalues g on g.dmv_dm_id = ''GEO'' and g.dmv_cod = A.aziLocalitaLeg2  and g.dmv_level = 7 and right( g.dmv_cod , 3 ) <> ''xxx''

		where azivenditore > 0   
			and aziacquirente = 0
			and azideleted = 0 ' + @CrLf

	end
	else
	begin

		set @SQLCmd =  @SQLCmd +  '
			select IdAzi
				from aziende a WITH (NOLOCK) 

			'

		
		if @CodiceFiscale <> ''
			set @SQLCmd = @SQLCmd + '
			
						left outer join DM_Attributi d1 WITH (NOLOCK)  on d1.lnk = idazi and d1.dztNome = ''CodiceFiscale'' and d1.idapp = 1
			'
				
		IF @participantID <> '' or @iscrittoPeppol = '00' or @iscrittoPeppol = '1_' or @iscrittoPeppol = '10'
			set @SQLCmd = @SQLCmd + '
						
						left outer join DM_Attributi dd7 WITH (NOLOCK) on dd7.lnk = idazi and dd7.dztNome = ''PARTICIPANTID'' and dd7.idApp = 1

			'

		if @iscrittoPeppol = '11' or @iscrittoPeppol = '10'
			set @SQLCmd = @SQLCmd + '
			
						left outer join DM_Attributi dd6 WITH (NOLOCK) on dd6.lnk = idazi and dd6.dztNome = ''IDNOTIER'' and dd6.idApp = 1

			'


		set @SQLCmd =  @SQLCmd +  '
				where azivenditore > 0   
					and aziacquirente = 0
					and azideleted = 0 ' + @CrLf

	end

	if rtrim( @SQLWhere ) <> ''
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf



	if @aziDataCreazioneDa <> ''
		set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , aziDataCreazione , 121 ) >= ''' + @aziDataCreazioneDa + '''  '

	if @aziDataCreazioneA <> ''
		set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , aziDataCreazione , 121 ) <= ''' + @aziDataCreazioneA + '''  '

	if @CodiceFiscale <> ''
		set @SQLCmd = @SQLCmd + ' and d1.vatValore_FT like ''' + @CodiceFiscale + ''' '

	IF @participantID <> ''
	BEGIN
		if rtrim(ltrim(@participantID)) = '%%%'
			set @SQLCmd = @SQLCmd + ' and isnull(dd7.vatValore_FT,'''') <> '''' '
		else
			set @SQLCmd = @SQLCmd + ' and isnull(dd7.vatValore_FT,'''') like ''' + @participantID + ''' '
	END

	--NO – (gli O.E. non hanno un Participant ID)
    if @iscrittoPeppol = '00'
		set @SQLCmd = @SQLCmd + ' and isnull(dd7.vatValore_FT,'''') = '''' '

	--SI - (gli O.E. hanno un Participant ID)
     if @iscrittoPeppol = '1_'
		set @SQLCmd = @SQLCmd + ' and isnull(dd7.vatValore_FT,'''') <> '''' '
	
	--11 - In Piattaforma – (gli O.E. sono registrati Noti-ER)
	if @iscrittoPeppol = '11'
		set @SQLCmd = @SQLCmd + ' and isnull(dd6.vatValore_FT,'''') <> '''' '

	--10 - Fuori Piattaforma - (gli O.E. hanno il Participant ID e non sono registrati Noti-ER)
	if @iscrittoPeppol = '10'
		set @SQLCmd = @SQLCmd + ' and isnull(dd7.vatValore_FT,'''') <> '''' and isnull(dd6.vatValore_FT,'''') = '''' '

----------------

	if @RestrictAzi  = 1
	begin
		set @SQLCmd = @SQLCmd + ' and idazi in ( select idazi from #TempResulAziende ) '

	end


	if @Filter <> '' and @Filter <> 'RICERCA_OE' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf


	if @RestrictAzi  = 1
	begin	
		set @SQLCmd = @SQLCmd + ' drop table  #TempResulAziende '
	end

	--insert into CTL_DOC_Value (IdHeader,value) values (-12581,@SQLCmd)

	exec (@SQLCmd)
	--print @SQLCmd
	
	--set @cnt = @@rowcount





GO
