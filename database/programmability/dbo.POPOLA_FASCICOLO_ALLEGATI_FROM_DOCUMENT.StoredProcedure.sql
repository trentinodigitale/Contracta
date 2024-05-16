USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[POPOLA_FASCICOLO_ALLEGATI_FROM_DOCUMENT]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE  proc [dbo].[POPOLA_FASCICOLO_ALLEGATI_FROM_DOCUMENT] ( @IdDocFascicolo as int, @IdDoc as int , @TipoDoc as varchar (50))
as
begin	
	SET NOCOUNT ON
	--declare @IdDoc as int
	--declare @IdDocFascicolo as int
	
	--set @IdDoc = 414508
	--set @IdDocFascicolo = 423039

	--declare @TipoDoc as varchar (50)
	declare @Sezione as varchar(1000)
	declare @Modello as varchar (1000)
	declare @StrTable as varchar(1000)
	declare @StrView as varchar(1000)
	declare @StrFilterRow as varchar(1000)
	declare @strFieldIdDoc as varchar (100)
	declare @StrDynamic_Model as varchar(20)
	declare @StrWRITE_VERTICAL as varchar(20)
	declare @ModelloDinamico as varchar (1000)
	declare @Sql as nvarchar(max)
	declare @ListAttrib as nvarchar(max)
	declare @Attrib as nvarchar(max)

	--creo una tabella temporanea che conterrà la lista degli allegati
	
	DECLARE @List_Attach_Doc TABLE
	(
		DSE_ID nvarchar(500),
		Allegato  nvarchar(max)
	)

	--DECLARE @List_Attrib TABLE
	--(
	--	dzt_name varchar(100)
		
	--)
	

	--recupero TIPODOC del documento da cui recuperare gli allegati
	--select @TipoDoc=TipoDoc from ctl_doc with (nolock) where id = @IdDoc
	

	--recupero dalla configurazione le sezioni del documento
	--faccio un cursore che per ognuna mi recupero il valore degli atttributi di tipo allegato 
	--se ci sono
	DECLARE crsSection CURSOR STATIC FOR 

		select
			--dbo.GetValue('FOLDER',convert(varchar(MAX),DOC_Param)) as Folder,
			DS.DSE_ID as Sezione,
			DSE_MOD_ID as Modello,
			DES_Table as Tabella,
			dbo.GetValue('VIEW',convert(varchar(MAX),DSE_PARAM)) as Vista,
			dbo.GetValue('FILTER_ROW',convert(varchar(MAX),DSE_PARAM)) as FilterRow,
			DES_FieldIdDoc as FieldIdDoc, 
			dbo.GetValue('DYNAMIC_MODEL',convert(varchar(MAX),DSE_PARAM)) as Dynamic_Model,
			upper(dbo.GetValue('WRITE_VERTICAL',convert(varchar(MAX),DSE_PARAM))) as WRITE_VERTICAL, 
			isnull(CM.MOD_Name,'') as ModelloDinamico--, 
			--isnull(DES_PosPermission,0) as DES_PosPermission 
			from  
				lib_documents with (nolock)
					inner join LIB_DocumentSections  DS  with (nolock) on DSE_DOC_ID=DOC_ID
					left outer join CTL_DOC_SECTION_MODEL  CM with (nolock) on CM.IdHeader=414510 and CM.DSE_ID=DS.DSE_ID 
			where 
				DSE_DOC_ID=DOC_ID and DSE_DOC_ID=@TipoDoc
				and des_progid not in ('CtlDocument.Sec_Static','CtlDocument.Sec_Total')
				
				--escludo le sezioni di un documento indicate da una relazione
				and DSE_DOC_ID + '-' + DS.DSE_ID not in ( 
														select 
															REL_ValueOutput  
															from 
																ctl_relations with (nolock) 
															where 
																rel_type='FASCICOLO_GARA' and REL_ValueInput ='SEZIONI_DOCUMENTI_DA_ESCLUDERE'
														)

			order by des_order

	OPEN crsSection

	FETCH NEXT FROM crsSection INTO @Sezione, @Modello, @StrTable, @StrView, @StrFilterRow, @strFieldIdDoc,
									@StrDynamic_Model, @StrWRITE_VERTICAL,@ModelloDinamico
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--se presente la vista la considero come sorgente dati
		if @StrView <> ''
			set @StrTable = @StrView

		--se presente il modello dinamico lo considero
		if @ModelloDinamico <> ''
			set @Modello = @ModelloDinamico
		
		if @Modello <> ''
		begin

			--recupero gli attributi di tipo allegato dal modello 
			--prima provo dai modelli CTL dinamici
			--insert into @List_Attrib
			--		(dzt_name )
			set @ListAttrib = ''

			select
				@ListAttrib = @ListAttrib + ',' + DZT_Name 
				from 
					CTL_ModelAttributes with (nolock)
						inner join lib_dictionary d  with (nolock) on  ma_dzt_name=d.dzt_name  and d.dzt_type=18
				where 
					ma_mod_id=@Modello 
		
			--se non ho trovato nulla 
			if @ListAttrib = ''
			begin
				select
				@ListAttrib = @ListAttrib + ',' + DZT_Name 
					from 
						LIB_ModelAttributes with (nolock)
							inner join lib_dictionary d  with (nolock) on  ma_dzt_name=d.dzt_name  and d.dzt_type=18
					where 
						ma_mod_id=@Modello 
			end


			--se ho trovato attributi allora ne recupero i valori
			--select * from @List_Attrib
			if @ListAttrib <> ''
			begin
							

				--tolgo la ',' in testa
				set @ListAttrib = right(@ListAttrib,len(@ListAttrib)-1)

				--faccio un corsore per tutti gli attributi per andare a recuperare il valore 
				DECLARE crsAttrib CURSOR STATIC FOR 
					
					select items from dbo.split (@ListAttrib , ',') 

				OPEN crsAttrib

				FETCH NEXT FROM crsAttrib INTO @Attrib
				WHILE @@FETCH_STATUS = 0
				BEGIN
					

					--se la scrittura è verticale i valori sono nella tabella ctl_doc_value
				if @StrWRITE_VERTICAL = 'YES'
				begin
					set @Sql = '
								--insert into @List_Attach_Doc
								--	(DSE_ID, Allegato)

								insert into document_Fascicolo_Gara_Allegati
									(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry] ) 

								select 
										' + cast ( @IdDocFascicolo as varchar(50) ) + ', value, ' + cast(@IdDoc as varchar(50)) + ',''' + @Sezione + ''','''',0    
									from 
										' + @StrTable + ' with (nolock) 
									where 
										' + @strFieldIdDoc  + ' = ' + cast(@IdDoc as varchar(50)) 
										+ ' and dzt_name in (''' + replace ( @Attrib, ',' , ''',''') + ''') and isnull(value,'''')<>'''' and DSE_ID='''  + @Sezione + ''''

						
				end
				else
				begin
					set @Sql = '
								--insert into @List_Attach_Doc
								--	(DSE_ID, Allegato)

								insert into document_Fascicolo_Gara_Allegati
									(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry] ) 

								--select ''' + @Sezione + ''',' + @ListAttrib +' 
								select 
										' + cast ( @IdDocFascicolo as varchar(50) ) + ','  + @Attrib + ', ' + cast(@IdDoc as varchar(50)) + ',''' + @Sezione + ''','''',0   
									from 
										'  + @StrTable + ' with (nolock)
									where 
										' + @strFieldIdDoc  + ' = ' + cast(@IdDoc as varchar(50)) + 
										' and isnull(' + @Attrib + ','''') <> '''' '
							

				end

				if @StrFilterRow <> ''
					set @Sql = @Sql + ' and ' + @StrFilterRow
									
				exec (@Sql)
				--print (@Sql)



					FETCH NEXT FROM crsAttrib INTO @Attrib
				END

				CLOSE crsAttrib 
				DEALLOCATE crsAttrib 


				

			end
		
		end

		FETCH NEXT FROM crsSection INTO @Sezione, @Modello, @StrTable, @StrView, @StrFilterRow, @strFieldIdDoc,
										@StrDynamic_Model, @StrWRITE_VERTICAL,@ModelloDinamico
	END
		
	CLOSE crsSection 
	DEALLOCATE crsSection 


	
	--select * from @List_Attach_Doc


	--select * from document_Fascicolo_Gara_Allegati where idheader = 423039
	--delete from document_Fascicolo_Gara_Allegati where idheader = 423039
	
	--insert into document_Fascicolo_Gara_Allegati
	--(  [IdHeader],  [Attach], [IdDoc], [DSE_ID], [Esito], [NumRetry] ) 
					
	--select 
	--	@IdDocFascicolo as [IdHeader], Allegato as  [Attach], @IdDoc as [IdDoc], 
	--	dse_id as [DSE_ID], '' as [Esito], 0 as [NumRetry]
	--	from @List_Attach_Doc


end


GO
