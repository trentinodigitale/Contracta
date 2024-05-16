USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






















CREATE proc [dbo].[DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO]
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


	declare @Param						varchar(8000)
	
	declare @aziCAPLeg				varchar(50)
	declare @aziCodiceFiscale		varchar(50)
	declare @aziLog					varchar(50)
	declare @ClasseIscriz			varchar(MAX)
	declare @AttivitaProfessionale	varchar(Max)
	declare @GerarchicoSOA      	varchar(Max)
	declare @aziE_Mail				varchar(5000)
	declare @aziIndirizzoLeg		varchar(5000)
	declare @aziLocalitaLeg			varchar(5000)
	declare @aziPartitaIVA			varchar(50)
	declare @aziProvinciaLeg		varchar(5000)
	declare @aziRagioneSociale		varchar(5000)
	declare @aziTelefono1		    varchar(50)
	declare @StatoIscrizione					varchar(50)

	declare @data_ultima_valutazione_a		varchar(50)
	declare @data_ultima_valutazione_da		varchar(50)
	declare @DataA					        varchar(50)
	declare @DataDA					        varchar(50)

	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @Note as nvarchar(max)
	declare @esclusiva as varchar(100)
	declare @ListaAlbi		varchar(50)

	declare @Certificazioni_Verdi		varchar(50)
	declare @Certificazioni_Sociali		varchar(50)
	declare @certificazioni			     varchar(max)

	set @esclusiva='NO'
	
	declare @ColPathFather as varchar(500)
	declare @ColPath as varchar(500)
	declare @doc_to_upd			int
	declare @Is_Group as varchar(2)
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	declare @SQLCmd			varchar(max)
	declare @SQLAZI			varchar(max)
	declare @SQLRESTRICTAZI		varchar(max)
	declare @SQLWhere			varchar(max)

	set @SQLRESTRICTAZI = ''	
	set @SQLCmd =''
	set @SQLWhere=''
	declare @CrLf varchar (10)
	set @CrLf = '
'


	-- criteri di ricerca
	set @aziCAPLeg					= replace( dbo.GetParam( 'aziCAPLeg' , @Param ,1) ,'''','''''')
	set @aziCodiceFiscale			= replace( dbo.GetParam( 'aziCodiceFiscale' , @Param ,1) ,'''','''''')
	set @aziLog						= replace( dbo.GetParam( 'aziLog' , @Param ,1) ,'''','''''')
	set @aziE_Mail					= replace( dbo.GetParam( 'aziE_Mail' , @Param ,1) ,'''','''''')
	set @aziIndirizzoLeg			= replace( dbo.GetParam( 'aziIndirizzoLeg' , @Param ,1) ,'''','''''')	
	set @aziLocalitaLeg				= replace( dbo.GetParam( 'aziLocalitaLeg' , @Param ,1) ,'''','''''')
	set @aziPartitaIVA				= replace( dbo.GetParam( 'aziPartitaIVA' , @Param ,1) ,'''','''''')
	set @aziProvinciaLeg			= replace( dbo.GetParam( 'aziProvinciaLeg' , @Param ,1) ,'''','''''')
	set @aziRagioneSociale			= replace( dbo.GetParam( 'aziRagioneSociale' , @Param ,1) ,'''','''''')
	set @ClasseIscriz				= replace( dbo.GetParam( 'ClasseIscriz' , @Param ,1) ,'''','''''')
	set @AttivitaProfessionale		= replace( dbo.GetParam( 'AttivitaProfessionale' , @Param ,1) ,'''','''''')
	set @GerarchicoSOA				= replace( dbo.GetParam( 'ClassificazioneSOA' , @Param ,1) ,'''','''''')
	set @aziTelefono1				= replace( dbo.GetParam( 'aziTelefono1' , @Param ,1) ,'''','''''')
	set @StatoIscrizione			= replace( dbo.GetParam( 'StatoIscrizione' , @Param ,1) ,'''','''''')
	set @doc_to_upd					= replace( dbo.GetParam( 'doc_to_upd' , @Param ,1) ,'''','''''')
	
	set @data_ultima_valutazione_a	 = left( replace( dbo.GetParam( 'data_ultima_valutazione_a' , @Param ,1) ,'''','''''') , 10 )
	set @data_ultima_valutazione_da	 = left( replace( dbo.GetParam( 'data_ultima_valutazione_da' , @Param ,1) ,'''',''''''), 10 )
	set @DataA						 = left( replace( dbo.GetParam( 'DataA' , @Param ,1) ,'''',''''''), 10 )
	set @DataDA						 = left( replace( dbo.GetParam( 'DataDA' , @Param ,1) ,'''',''''''), 10 )

	set @ListaAlbi					= replace( dbo.GetParam( 'ListaAlbi' , @Param ,1) ,'''','''''')
	set @Is_Group					= replace( dbo.GetParam( 'Is_Group' , @Param ,1) ,'''','''''')
	set @certificazioni				= replace( dbo.GetParam( 'Certificazioni' , @Param ,1) ,'''','''''')

	set @Certificazioni_Verdi				=  dbo.GetParam( 'Certificazioni_Verdi' , @Param ,0) 
	set @Certificazioni_Sociali				=  dbo.GetParam( 'Certificazioni_Sociali' , @Param ,0) 

	
	if @Filter = 'ONLY_ALBO_ME' 
		if @ListaAlbi <> '' -- se ho indicato un albo non è necessari oche filtro su tutti i ME
			set @Filter = ''
	/*
		else
			--set @Filter = ' idHeader in ( select id from ctl_doc with(nolock) where tipodoc = ''BANDO'' and deleted = 0 and isnull( jumpcheck , '''' ) = '''' and StatoFunzionale = ''Pubblicato'' ) '

			--set @Filter = ' idHeader in ( select id from #Temp_List_Bandi ) '
			set @Filter = ' inner join #Temp_List_Bandi on idheader=id '
	*/

	if @ClasseIscriz <> ''
	begin	
		
		--	select top 0 DMV_Father as ColPath into #temp_ClasseIscriz from lib_domainvalues WITH (NOLOCK)
		--		exec recuperaPathDaDominio 'ClasseIscriz', @ClasseIscriz

		select top 0 DMV_Father as ColPath,DMV_Father as ColPathFather into #temp_ClasseIscriz from lib_domainvalues 
		--cambiato stored che mi ritorna anche ColPathFather
		exec recuperaPathDaDominioEsteso 'ClasseIscriz', @ClasseIscriz
		
	end
	if @AttivitaProfessionale <> ''
	begin	
		
		select top 0 DMV_Father as ColPath into #temp_TipologiaIncarico from lib_domainvalues 
		exec recuperaPathDaDominio 'TipologiaIncarico', @AttivitaProfessionale
		
	end
	if @GerarchicoSOA <> ''
	begin	
		
		select top 0 DMV_Father as ColPath,DMV_Father as ColPathFather into #temp_GerarchicoSOA from lib_domainvalues 
		--cambiato stored che mi ritorna anche ColPathFather
		exec recuperaPathDaDominioEsteso 'GerarchicoSOA', @GerarchicoSOA
		
	end
	if @certificazioni <> ''
	begin	
		
		select top 0 DMV_Father as ColPath into #temp_Certificazioni from lib_domainvalues  WITH (NOLOCK)
		exec recuperaPathDaDominio 'Certificazioni', @certificazioni
		
	end
		
	-----------------------------------------------------
	-- SI DETERMINA LA RESTRIZIONE PER ULTERIORI CRITERI
	-----------------------------------------------------

	declare @idx int
	set @idx=1
	declare @RestrictAzi int
	set @RestrictAzi  = 0
	
	if @ClasseIscriz <> '' 
	BEGIN 

		IF EXISTS ( select * from CTL_Parametri with(nolock) where Contesto='selezione_fascia' and Oggetto='ClasseIscriz' and Proprieta='esclusiva' and Valore='SI')
		BEGIN
			set @esclusiva='SI'
		END
        
		--operatore da utilizzare per la ClasseIscriz (salita o discesa sui gerarchici o enterambi)
		declare @opClasseIscr as nvarchar(10)
		set @opClasseIscr = dbo.GetParamOperation( 'ClasseIscriz' , @Param ,1)
		
		IF EXISTS ( select * from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO' and REL_VALUEINPUT='opClasseIscr' )
		BEGIN
			 select top 1 @opClasseIscr=REL_VALUEOUTPUT from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO' and REL_VALUEINPUT='opClasseIscr'
		END

		declare @navigaAlbero as nvarchar(500)
		declare @Operatore as varchar(10)
		
		set @Operatore = 'AND'

		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO' and REL_VALUEINPUT='ClasseIscr' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DASHBOARD_VIEW_OE_ALBO' and REL_VALUEINPUT='ClasseIscr'
		END

		
		if @Operatore = 'AND'
		begin
			
			--set @idx = 1
			declare CurClasseIsc Cursor static for 
				Select ColPath , ColPathFather
					from #temp_ClasseIscriz 
						
			
			open CurClasseIsc

			FETCH NEXT FROM CurClasseIsc 	INTO @ColPath,@ColPathFather
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
				--inner join DizionarioAttributi dzta on dzta.dztnome = c.dztnome 
				--inner join DominiGerarchici dm on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlbero + @CrLf + 
				set @idx = @idx + 1
				set @SQLAZI = ' select a.idazi into #TempAziTT_' + cast( @idx as varchar) + ' from  aziende a 
											inner join  dm_attributi c on c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''
											inner join ClasseIscriz  dm on dm.dmv_cod=vatvalore_ft ' + @CrLf + @navigaAlbero + @CrLf + 
											' inner join #TempResulAziende t on t.idazi = a.idazi
											 where  azideleted=0 and dm.dmv_father <> ''''  
											
									truncate table  #TempResulAziende
									insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAziTT_' + cast( @idx as varchar) + '
									drop table #TempAziTT_' + cast( @idx as varchar) + '
											' + @CrLf

				
				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi  = 1



				FETCH NEXT FROM CurClasseIsc 	INTO @ColPath,@ColPathFather
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
			--inner join DizionarioAttributi dzta on dzta.dztnome = c.dztnome 
			--inner join DominiGerarchici dm on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlbero + @CrLf + 
			
			set @SQLAZI =  '  select a.idazi into #TempAzi_2 from  aziende a inner join dm_attributi c on c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''
										
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



	if @GerarchicoSOA <> '' 
	begin 
		
		declare @navigaAlberoGerarchicoSOA as nvarchar(500)
		
		IF EXISTS ( select * from CTL_Parametri with(nolock) where Contesto='selezione_fascia' and Oggetto='GerarchicoSOA' and Proprieta='esclusiva' and Valore='SI')
		BEGIN
			set @esclusiva='SI'
		END

		set @Operatore = 'AND'

		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='GerarchicoSOA' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='GerarchicoSOA'
		END

		
		if @Operatore = 'AND'	 
		begin
			 set @idx = 1

			 declare CurCategoriaSOA Cursor static for 
				Select ColPathFather,ColPath
					   from #temp_GerarchicoSOA 
						
			
			 open CurCategoriaSOA

			 FETCH NEXT FROM CurCategoriaSOA 	INTO @ColPathFather,@colpath
			 WHILE @@FETCH_STATUS = 0
			 BEGIN

				set @idx = @idx + 1

				if exists(select top 1 * from LIB_DomainValues where dmv_dm_id= 'GerarchicoSOA' )
				--LIB_DomainValues
				begin
				 
				    --set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(''' + @ColPath +''',len('''+ @ColPath +''') - 4 ) = left(dmv_father,len(dmv_father) - 4 ) and  dmv_father >=colpath ' 

					--set @SQLAZI =  '   select a.idazi into  #TempAzi_TTT' + cast( @idx as varchar) + ' from  aziende a inner join dm_attributi c on  c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA''
								--			 inner join LIB_DomainValues dm on dm.dmv_dm_id= ''GerarchicoSOA'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
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

				    
				--    set @SQLAZI =  '   select a.idazi into  #TempAziTTT_' + cast( @idx as varchar) + ' from  aziende a inner join dm_attributi c on  c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA''
				--							 inner join DizionarioAttributi dzta on dzta.dztnome = c.dztnome 
				--							 inner join DominiGerarchici dm on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
				--							 ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
				--							 where azideleted=0 and dm.dgPath <> '''' 


				--    truncate table   #TempResulAziende
				--    insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTT_' + cast( @idx as varchar) + '
				--    drop table #TempAziTTT_' + cast( @idx as varchar) + '
				--    ' + @CrLf
				
				--end

				
				set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
				set @RestrictAzi  = 1



				FETCH NEXT FROM CurCategoriaSOA 	INTO @ColPathFather,@colpath
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
				IF @esclusiva='SI'
					set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(colPath,len(ColPath)-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father >=colpath  ' 
				ELSE
					set @navigaAlberoGerarchicoSOA = ' inner join #temp_GerarchicoSOA d on left(colPath,len(ColPath)-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father =colpath  ' 

				--set @SQLAZI =  '   select a.idazi into  #TempAzi_17  from  aziende a inner join dm_attributi c on  c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClassificazioneSOA''
				--						  inner join LIB_DomainValues dm on dm.dmv_dm_id= ''GerarchicoSOA'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
				--						  ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
				--						  where azideleted=0 and dm.dmv_father <> ''''   and len(dm.dmv_father) > 2


				--				truncate table   #TempResulAziende
				--				insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAzi_17 
				--				drop table #TempAzi_17 
				--				' + @CrLf
				
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

			--	set @SQLAZI =  '  select a.idazi into TempAzi_17  from  aziende a inner join dm_attributi c on c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''ClasseIscriz''
			--							inner join DizionarioAttributi dzta on dzta.dztnome = c.dztnome 
			--							inner join DominiGerarchici dm on dzta.dztIdTid = dgTipoGerarchia  and vatvalore_ft = dgCodiceInterno ' + @CrLf + @navigaAlberoGerarchicoSOA + @CrLf + 
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
		IF EXISTS ( select * from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='AttivitaProfessionale' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT from CTL_RELATIONS where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='AttivitaProfessionale'
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

				if exists(select top 1 * from LIB_DomainValues where dmv_dm_id= 'TipologiaIncarico' )
				--LIB_DomainValues
				begin

				 set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',len(''' + @ColPath +''')-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father >=colpath '
				    IF @esclusiva='SI'
						set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',len(''' + @ColPath +''')-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father >=colpath '
						--set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',8)=left(dmv_father,8) and  dmv_father >=colpath ' 
					ELSE
						set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',len(''' + @ColPath +''')-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father =colpath '
						
						--set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',8)=left(dmv_father,8) and  dmv_father=colpath ' 

				    set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_AP' + cast( @idx as varchar) + ' from  aziende a inner join dm_attributi c on  c.lnk = a.idazi and c.dztnome = ''AttivitaProfessionale''											 
											 inner join GESTIONE_DOMINIO_TipologiaIncarico dm on vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoAttivitaProfessionale + @CrLf + 
											 ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
											 where azideleted=0 and dm.dmv_father <> '''' 


				    truncate table   #TempResulAziende
				    insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_AP' + cast( @idx as varchar) + '
				    drop table #TempAziTTTT_AP' + cast( @idx as varchar) + '
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

					set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',len(''' + @ColPath +''')-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father >=colpath '
					--' inner join #temp_TipologiaIncarico d on left(colPath,8)=left(dmv_father,8) and  dmv_father >=colpath ' 
				ELSE
					set @navigaAlberoAttivitaProfessionale = ' inner join #temp_TipologiaIncarico d on left(''' + @ColPath +''',len(''' + @ColPath +''')-4)=left(dmv_father,len(dmv_father)-4) and   dmv_father =colpath '
					--' inner join #temp_TipologiaIncarico d on  left(colPath,8)=left(dmv_father,8) and  dmv_father =colpath ' 

				set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_TI  from  aziende a inner join dm_attributi c on c.lnk = a.idazi and c.dztnome = ''AttivitaProfessionale''										  
										  inner join GESTIONE_DOMINIO_TipologiaIncarico dm on vatvalore_ft = dmv_cod ' + @CrLf + @navigaAlberoAttivitaProfessionale + @CrLf + 
										  ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
										  where azideleted=0 and dm.dmv_father <> '''' 


								truncate table   #TempResulAziende
								insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_TI 
								drop table #TempAziTTTT_TI 
								' + @CrLf

			end

			
		
			
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

				    set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_C' + cast( @idx as varchar) + ' from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.lnk = a.idazi and c.dztnome = ''CertificazioneQualita''
											 inner join LIB_DomainValues dm WITH (NOLOCK) on dm.dmv_dm_id= ''Certificazioni'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaCertificazioni + @CrLf + 
											 ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
											 where azideleted=0 and dm.dmv_father <> '''' 


				    truncate table   #TempResulAziende
				    insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_C' + cast( @idx as varchar) + '
				    drop table #TempAziTTTT_C' + cast( @idx as varchar) + '
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

			--IF exists(select top 1 id from LIB_DomainValues with(nolock) where dmv_dm_id= 'Certificazioni' )
			begin

				set @navigaCertificazioni = ' inner join #temp_Certificazioni d on dmv_father = ''' + @ColPath + ''''

				set @SQLAZI =  '   select a.idazi into  #TempAziTTTT_C  from  aziende a WITH (NOLOCK) inner join dm_attributi c WITH (NOLOCK) on  c.lnk = a.idazi and c.dztnome = ''CertificazioneQualita''
										  inner join LIB_DomainValues dm WITH (NOLOCK) on dm.dmv_dm_id= ''Certificazioni'' and vatvalore_ft = dmv_cod ' + @CrLf + @navigaCertificazioni + @CrLf + 
										  ' inner join #TempResulAziende t on t.idazi = a.IdAzi 
										  where azideleted=0 and dm.dmv_father <> '''' 


								truncate table   #TempResulAziende
								insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_C 
								drop table #TempAziTTTT_C 
								' + @CrLf

			end
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1

		end

	END


	if @Certificazioni_Sociali = '1'
	begin


			set @SQLAZI =  '   select distinct a.idazi into  #TempAziTTTT_CS  
									from  aziende a WITH (NOLOCK) 
										inner join #TempResulAziende t on t.idazi = a.IdAzi 
										inner join dm_attributi c WITH (NOLOCK) on  c.idapp = 1  and c.lnk = a.idazi and c.dztnome = ''CertificazioneQualita''
										inner join LIB_DomainValues dm WITH (NOLOCK) on dm.dmv_dm_id= ''Certificazioni'' and c.vatvalore_ft = dmv_cod and dm.dmv_image = ''Acquisto_Sociale.png''
										where a.azideleted=0 


							truncate table   #TempResulAziende
							insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_CS 
							drop table #TempAziTTTT_CS 
							' + @CrLf

			
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1

	end

	if @Certificazioni_Verdi = '1'
	begin


			set @SQLAZI =  '   select distinct a.idazi into  #TempAziTTTT_CV  
									from  aziende a WITH (NOLOCK) 
										inner join #TempResulAziende t on t.idazi = a.IdAzi 
										inner join dm_attributi c WITH (NOLOCK) on  c.idapp = 1  and c.lnk = a.idazi and c.dztnome = ''CertificazioneQualita''
										inner join LIB_DomainValues dm WITH (NOLOCK) on dm.dmv_dm_id= ''Certificazioni'' and c.vatvalore_ft = dmv_cod and dm.dmv_image = ''Appalto_Verde.png''
										where a.azideleted=0 


							truncate table   #TempResulAziende
							insert into #TempResulAziende ( idAzi ) select distinct idAzi    from  #TempAziTTTT_CV 
							drop table #TempAziTTTT_CV 
							' + @CrLf

			
			
			set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
			set @RestrictAzi  = 1

	end
		
	
	--------------------------- QUERY ------------------------------
	set @SQLCmd =  ''
	if @RestrictAzi  = 1
	begin
	
		set @SQLCmd = 'create table  #TempResulAziende ( idAzi  Int )
		insert into #TempResulAziende select idazi from aziende ' + @Crlf + @SQLRESTRICTAZI  + @Crlf

	end
	
	if @doc_to_upd > 0
	begin
		select 
			@fascicolo = ISNULL(fascicolo,''),
			@body=ISNULL(body,''),
			@ProtocolloRiferimento=ISNULL(ProtocolloRiferimento,''),
			@DataProtocolloGenerale=ISNULL(DataProtocolloGenerale,''),
			@ProtocolloGenerale=ISNULL(protocollogenerale,''),
			@azienda=ISNULL(Azienda,''),
			@note=ISNULL(note,'')
		from ctl_doc where id=@doc_to_upd and tipodoc='PDA_COMUNICAZIONE_GENERICA' and JumpCheck='0-GENERICA_FROM_ALBO'
		
		set @SQLCmd =  @SQLCmd +  '
		delete from ctl_doc where linkeddoc=' + cast(@doc_to_upd as varchar(50)) + ' and tipodoc=''PDA_COMUNICAZIONE_GARA'' and JumpCheck=''0-GENERICA_FROM_ALBO''
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck) 	
		select ' + cast(@IdPfu as varchar(50)) + ' , ''PDA_COMUNICAZIONE_GARA'',''Comunicazione'' , '' ' + @fascicolo + ' '',' + cast(@doc_to_upd as varchar(50)) + ','' '  + replace(@body,'''','''''')  + ' '',''' + @ProtocolloRiferimento + ''','' ' + @ProtocolloGenerale + ' '','' ' + cast(@DataProtocolloGenerale as varchar(20)) + ' '',' +  @azienda + ', idazi,getdate(),'' ' + replace(@Note,'''','''''')  + ' '',''0-GENERICA_FROM_ALBO'' from DASHBOARD_VIEW_OE_ALBO ' + @CrLf
	end
	else
	begin
		
		--per creare la tabella temporanea con i bandi
		--if @Filter <> '' 
		if @Filter = 'ONLY_ALBO_ME'
		begin
			
			set @SQLCmd =  @SQLCmd +  '
		
					select id into #Temp_List_Bandi from ctl_doc with(nolock) where tipodoc = ''BANDO'' and deleted = 0 and isnull( jumpcheck , '''' ) = '''' and StatoFunzionale = ''Pubblicato''
		
			'
		end

		set @SQLCmd =  @SQLCmd +  '

					select *'
		
		--nel caso di excel aggiungo le colonne visuali per classeiscriz e certificazioni
		if @nIsExcel = 1 
			set @SQLCmd =  @SQLCmd +  
				' , dbo.Get_Desc_ClasseIscriz(classeiscriz , ''I'') as ClasseIscrizDesc 
				  ,	dbo.GetDescFromMultivalore(''Certificazioni'',Certificazioni,''I'') as CertificazioniDesc 
				  , dbo.Get_Desc_ClassificazioneSOA(ClassificazioneSOA , ''I'') as ClassificazioneSOADesc 
				  , dbo.Get_Desc_AttivitaProfessionale(AttivitaProfessionale , ''I'') as AttivitaProfessionaleDesc '

		set @SQLCmd =  @SQLCmd +  ' from DASHBOARD_VIEW_OE_ALBO ' + @CrLf


	end
	
	--if @Filter <> '' 
	if @Filter = 'ONLY_ALBO_ME'  -- nel caso sia filtrato solo sugli albi inserisco la inner join con la tabella temporanea precedentemente creata
		set @SQLCmd = @SQLCmd +  ' inner join #Temp_List_Bandi on idheader=id ' +  + @CrLf

	if ( ISNULL(@SQLWhere,'' ) = '')
		set @SQLCmd = @SQLCmd + ' where 1=1 ' + @SQLWhere + @CrLf

	
	-- altrimenti se è presente un filtro differente lo aggiungo alla clausola di where
	if @Filter <> 'ONLY_ALBO_ME' and @Filter <> ''
		set @SQLCmd = @SQLCmd + ' and ( ' +  @Filter + ' ) ' + @CrLf


	
	if @DataDA <> ''
		set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , DataDA , 121 ) >= ''' + @DataDA + '''  '

	if @DataA <> ''
		set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , DataA , 121 ) <= ''' + @DataA + '''  '

	if @data_ultima_valutazione_da <> ''
		set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , data_ultima_valutazione_da , 121 ) >= ''' + @data_ultima_valutazione_da + '''  '

	if @data_ultima_valutazione_a <> ''
		set @SQLCmd = @SQLCmd + ' and  convert( varchar(10) , data_ultima_valutazione_a , 121 ) <= ''' + @data_ultima_valutazione_a + '''  '

	if @StatoIscrizione <> ''
		set @SQLCmd = @SQLCmd + ' and StatoIscrizione = ''' + @StatoIscrizione + ''' '	
	
	if @Is_Group <> ''
		set @SQLCmd = @SQLCmd + ' and Is_Group = ''' + @Is_Group + ''' '		

	if @aziTelefono1 <> ''
		set @SQLCmd = @SQLCmd + ' and aziTelefono1 like ''' + @aziTelefono1 + ''' '

	if @aziRagioneSociale <> ''
		set @SQLCmd = @SQLCmd + ' and aziRagioneSociale like ''' + @aziRagioneSociale + ''' '

	if @aziCAPLeg <> ''
		set @SQLCmd = @SQLCmd + ' and aziCAPLeg like ''' + @aziCAPLeg + ''' '
	
	if @aziCodiceFiscale <> ''
		set @SQLCmd = @SQLCmd + ' and aziCodiceFiscale like ''' + @aziCodiceFiscale + ''' '

	if @aziLog <> ''
		set @SQLCmd = @SQLCmd + ' and aziLog like ''' + @aziLog + ''' '

	if @aziE_Mail <> ''
		set @SQLCmd = @SQLCmd + ' and aziE_Mail like ''' + @aziE_Mail + ''' '

	if @aziIndirizzoLeg <> ''
		set @SQLCmd = @SQLCmd + ' and aziIndirizzoLeg like ''' + @aziIndirizzoLeg + ''' '

	if @aziLocalitaLeg <> ''
		set @SQLCmd = @SQLCmd + ' and aziLocalitaLeg like ''' + @aziLocalitaLeg + ''' '

	if @aziPartitaIVA <> ''
		set @SQLCmd = @SQLCmd + ' and aziPartitaIVA like ''' + @aziPartitaIVA + ''' '

	if @aziProvinciaLeg <> ''
		set @SQLCmd = @SQLCmd + ' and aziProvinciaLeg like ''' + @aziProvinciaLeg + ''' '
					
	if @ListaAlbi <> ''
		set @SQLCmd = @SQLCmd + ' and ListaAlbi = ''' + @ListaAlbi + ''' '
		


	if @RestrictAzi  = 1
	begin
		set @SQLCmd = @SQLCmd + ' and idazi in ( select idazi from #TempResulAziende ) '

	end
	if @doc_to_upd > 0 
	begin
		set @SQLCmd = @SQLCmd  + ' and IdAzi not in ( select Destinatario_Azi from ctl_doc where LinkedDoc=' + cast(@doc_to_upd as varchar(50)) + ' and tipodoc=''PDA_COMUNICAZIONE_GARA'' and JumpCheck=''0-GENERICA_FROM_ALBO'' )'
	end

	


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	set @SQLCmd = @SQLCmd + '  option (maxdop 1) '  + @CrLf


	if @RestrictAzi  = 1
	begin	
		set @SQLCmd = @SQLCmd + ' drop table  #TempResulAziende '
	end
	
	exec (@SQLCmd)
	--print @SQLCmd
	--insert into CTL_DOC_Value (IdHeader,value) values (-12589,@SQLCmd)
	--set @cnt = @@rowcount

	if @doc_to_upd > 0 
	begin
		IF EXISTS (select * from ctl_doc where linkeddoc=@doc_to_upd and tipodoc='PDA_COMUNICAZIONE_GARA' and JumpCheck='0-GENERICA_FROM_ALBO')
		BEGIN
			select 'OK' as esito
		END
		
	end






GO
