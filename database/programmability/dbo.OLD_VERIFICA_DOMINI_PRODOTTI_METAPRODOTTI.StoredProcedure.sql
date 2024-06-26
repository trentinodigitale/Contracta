USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_VERIFICA_DOMINI_PRODOTTI_METAPRODOTTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  PROCEDURE [dbo].[OLD_VERIFICA_DOMINI_PRODOTTI_METAPRODOTTI] ( @TipoProdotto varchar(100)  , @Output int = 0) 

AS

BEGIN
	
	set nocount on

	declare @Attributo as varchar(500)
	declare @Descrizione as nvarchar (max)
	declare @dm_query as nvarchar (max)
	declare @Sql_Insert_Dinamici as nvarchar (max)
	declare @Sql as nvarchar (max)

	

	--select * from Document_MicroLotti_Dettagli where TipoDoc='meta_prodotto'
	--@TipoProdotto = meta_prodotto/prodotto
	


	--svuoto esito riga sui meta prodotti quando faccio la verifica
	if @Output=0
	begin
		if @TipoProdotto <>''
		begin
			update Document_MicroLotti_Dettagli set EsitoRiga='' where TipoDoc=@TipoProdotto
		end
		else
		begin
			update Document_MicroLotti_Dettagli set EsitoRiga='' where TipoDoc in ('meta_prodotto','prodotto')
		end
	end


	if @TipoProdotto <>''
		set @TipoProdotto = '''' + @TipoProdotto + ''''
	else
		set @TipoProdotto = ' ''meta_prodotto'',''prodotto'' '
	--recupero gli attributi relativi alla tabella document_microlotti_dettagli che sono attributi a dominio
	--in una tabella temporanea #temp_attrib_domini

	--select column_name into #Column_Of_Table from information_schema.columns where table_name = @Table
	--select column_name into #temp_attrib_domini
	--select column_name  
	--	from information_schema.columns 
	--		inner join lib_dictionary L with (nolock) on   L.DZT_Name = column_name and L.dzt_type in ( 4,5,8 )
	--	where table_name = 'document_microlotti_dettagli'
	--			and L.DZT_Name not like 'Dominio_SiNo%' 
	--			and L.DZT_Name not in ('TipoDoc','StatoRiga', 'Posizione','Subordinato','Intervallo_0_24','Erosione','TipoAcquisto'
	--								,'ArticoliPrimari')
	--			and L.DZT_DM_ID <>'sino'
	

	--select * from #temp_modelli_ambiti
	--mi recupero i modelli legati agli ambiti
	--drop table #temp_modelli_ambiti
	select Id into #temp_modelli_ambiti from ctl_doc where tipodoc='CONFIG_MODELLI' and JumpCheck='CODIFICA_PRODOTTI' and StatoFunzionale='pubblicato'

	--select * from ctl_doc where tipodoc='CONFIG_MODELLI' and JumpCheck='CODIFICA_PRODOTTI' and StatoFunzionale='pubblicato'
	

	--mi recupero gli attributi a dominio presenti nei modelli recuperati
	--e mi conservo la descrizione (prendo la max se presente più volte)
	--drop table #Attrib_Dominio_Modelli
	select  c1.value as Attributo ,max(c2.value) as Descrizione into #Attrib_Dominio_Modelli from 
	
			ctl_doc_value c1 
				
				inner join ctl_doc_value c2	 on c2.IdHeader = c1.IdHeader and c2.Row = c1.Row  and c2.DZT_Name ='Descrizione'
				inner join  lib_dictionary L with (nolock) on   L.DZT_Name = c1.value and L.dzt_type in ( 4,5,8 )
				--left join ctl_doc_value c2 on c2.IdHeader = c1.IdHeader and c2.Row = c1.Row  and c2.DZT_Name='MOD_Macro_Prodotto'
				--								and c2.Value <>''
				--left join ctl_doc_value c3 on c3.IdHeader = c1.IdHeader and c3.Row = c1.Row  and c3.DZT_Name='MOD_Prodotto'
				--								and c3.Value <>''
		where c1.idheader in (select id from #temp_modelli_ambiti ) and c1.DSE_ID='modelli' and c1.DZT_Name='DZT_Name'
				group by c1.value
	
	--per questi attributi che sono a dominio mi popolo una tabella temporanea 
	--con dominio,codice,descrizione

	--a questo punto faccio un cursore  su questi attributi
	--per ognuno mi recupero le codifiche
	--faccio update sui meta prodotti e prodotti per segnalare 
	--i codici non validi (cancellati o non presenti )

	--select * from #Attrib_Dominio_Modelli
	--drop table #Codifiche_Codici_Dominio
	--creo tabella temporanea con i domini e con le codifiche dei codici
	CREATE TABLE #Codifiche_Codici_Dominio 
		(
			codice varchar(600) COLLATE database_default,
			codifica nvarchar(max) COLLATE database_default,
			deleted int
		)
	
	CREATE TABLE #Codifiche_Obsolete
		(
			Attributo varchar(600) COLLATE database_default,
			codice varchar(600) COLLATE database_default
			
		)
	   
	--creo un indice sulla tabella temporanea per dominio e codice
	--CREATE INDEX IXTEMP ON #Codifiche_Codici_Dominio(codice,codifica)

	--select * from #Attrib_Dominio_Modelli

	DECLARE crsAttrib CURSOR STATIC FOR 
	
		select  Attributo ,  Descrizione from #Attrib_Dominio_Modelli

	OPEN crsAttrib

	FETCH NEXT FROM crsAttrib INTO @Attributo, @Descrizione
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
			--ATTRIBUTO SENZA QUERY DINAMICA
			INSERT INTO #Codifiche_Codici_Dominio ( codice, codifica, deleted )
			select distinct 
						DV.DMV_Cod ,
						isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max)))  as Codifica_Codice_Dominio
						, isnull(DV.DMV_Deleted,0) as DMV_Deleted
					from 
					
						LIB_Dictionary L with (nolock) 
							inner join LIB_Domain D  with (nolock) on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')=''	
							left JOIN LIB_DomainValues DV  with (nolock)  on DV.DMV_DM_ID = D.DM_ID
							left outer join dbo.LIB_Multilinguismo mlg  with (nolock)  on DMV_DescML = ML_KEY and ML_LNG='I'
					where 
						L.DZT_Name = @Attributo 
			
			
			--ATTRIBUTI CON QUERY DINAMICHE SUL DOMINIO
			select 
				@dm_query = cast(dm_query as nvarchar(max))
				from 
					LIB_Dictionary L  with (nolock) 
						inner join LIB_Domain D  with (nolock) on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')<>''	
				where 
					L.DZT_Name = @Attributo 

			if @dm_query <> ''
			BEGIN 

				if charindex( ' order by' , @dm_query ) > 0 
					begin 
					set @dm_query = left( @dm_query , charindex( ' order by' , @dm_query ) )
					end

				if charindex( 'order by' , @dm_query ) > 0 
					begin 
					set @dm_query = left( @dm_query , charindex( 'order by' , @dm_query )-1 )
					end

				--sostutisco la lingua per avere le desc in lingua
				set @dm_query = replace(@dm_query,'#LNG#','I')
				
				set @Sql_Insert_Dinamici = '

					INSERT INTO #Codifiche_Codici_Dominio ( codice, codifica, deleted)
			
					select 
							DMV.DMV_Cod , cast( DMV_DescML as nvarchar( max))  as Codifica_Codice_Dominio
							, isnull(DMV.DMV_Deleted,0) as DMV_Deleted

							from 
								( '  + @dm_query + ' ) as DMV '
				
				exec(@Sql_Insert_Dinamici)
			END

			--conideriamo anche i codici non presenti nel dominio (valori errati)
			--select   id , '' '  + @Descrizione + ' - Valore Obsoleto - "'' + C.codifica + ''"'' 
			
			--se outpt vale 0 sto invocando la verifica
			if @Output=0
			begin
				set @Sql='
				
					update 
						A 
						set EsitoRiga = isnull(EsitoRiga,'''') + ''<br>' + @Descrizione + ' - Valore Obsoleto - "'' + isnull(C.codifica,' + @Attributo + ') + ''"'' 
						
							from Document_MicroLotti_Dettagli A
								left join #Codifiche_Codici_Dominio C on C.codice = ' + @Attributo + ' 
							where TipoDoc in ('+ @TipoProdotto + ') and ( c.deleted=1 or ( c.codice is null and isnull(' + @Attributo + ','''') <> '''' )  )'
			end


			if @Output=1
			begin
				set @Sql='
					insert into #Codifiche_Obsolete
						(Attributo,Codice)
					
					select ''' + @Attributo + ''' as Attributo,' +  @Attributo + '
						from Document_MicroLotti_Dettagli 
							left join #Codifiche_Codici_Dominio C on C.codice = ' + @Attributo + '
							where TipoDoc in ('+ @TipoProdotto + ') and ( c.deleted=1 or ( c.codice is null and isnull(' + @Attributo + ','''') <> '''' )  )'

			end
			--print   (@Sql) 
			exec (@Sql)

			--IF OBJECT_ID('tempdb..#Codifiche_Codici_Dominio') IS NOT NULL
			--	 DROP TABLE #Codifiche_Codici_Dominio
			delete from #Codifiche_Codici_Dominio

		FETCH NEXT FROM crsAttrib INTO  @Attributo, @Descrizione
	END

	CLOSE crsAttrib 
	DEALLOCATE crsAttrib 
	
	--se Esito Riga valorizzato metto immagine di errore 
	--altrimenti la spunta 
	if @Output=0
	begin
		set @Sql = '
			update 
				Document_MicroLotti_Dettagli 
					set EsitoRiga=
						case 
							when EsitoRiga <> '''' then ''<img src="../images/Domain/State_ERR.gif">''  + EsitoRiga
							else ''<img src="../images/Domain/State_OK.gif">''
						end 
				where TipoDoc in (' +  @TipoProdotto  + ') 
			'
	
		exec (@Sql)
	end

	--print @Sql
	--se richiesto restituisco le codifiche errate
	if @Output = 1
		select distinct Attributo,codice from #Codifiche_Obsolete
		













END



GO
