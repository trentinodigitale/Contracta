USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CMP_VIEW_STORED]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--			exec CMP_VIEW_STORED  'Document_Bando_Semplificato_view','DOCUMENT_CK_TOOLBAR_BANDO_GARA','id',42374,45094,1,1
--			exec CMP_VIEW_STORED  'PDA_MICROLOTTI_VIEW_TESTATA ','DOCUMENT_LOAD_SEC_PDA_MICROLOTTI','id',307618,1,2

/*

	DECLARE  @id int
	declare @idpfu int 
	DECLARE CURSOR_CMP CURSOR FOR
		
	SELECT distinct  id, idpfu from document_bando_semplificato_view 

	OPEN CURSOR_CMP 

	FETCH NEXT FROM CURSOR_CMP INTO @ID , @idpfu

	WHILE @@FETCH_STATUS = 0

	BEGIN

		EXEC CMP_VIEW_STORED  'document_bando_semplificato_view', 'DOCUMENT_CK_TOOLBAR_BANDO_GARA','id', @ID,@idpfu,1,1
		FETCH NEXT FROM CURSOR_CMP INTO @ID , @idpfu

	END

	CLOSE CURSOR_CMP

	DEALLOCATE CURSOR_CMP

*/



CREATE PROCEDURE [dbo].[CMP_VIEW_STORED] ( @ViewName as varchar(1000), @StoredName as varchar(1000) ,@ColIdentity as varchar(100),  @IdDoc as int, @IdPfu as int, @nTypeCompare  as int = 1 ,@outputsoloeccezioni as int = 0 , @ColIdentity2 as varchar(100 )='' )
AS
BEGIN	
--@ViewName = nome vista
--@StoredName = nome stored
--@ColIdentity = colonna identity
--@IdDoc = id documento
--@IdPfu = id user
--@nTypeCompare = 1 per i documenti , 2 per le sezioni
--@outputsoloeccezioni = nel caso in cui si voglia usare il cursore è meglio settarlo a 1 per evitare migliaia di record che danno esito positivo
	



	SET NOCOUNT ON	
	-- STEP 1: controllo che le colonne della vista, sono le stesse delle colonne della stored
	
	---TRAVASO LE COLONNE DELLA VISTA NELLA TEMP #temp1
	select 
		t.name as tablename ,
		c.name as nome_colonna ,
		c.length,
		n.name as tipo
		into #temp1
	from 
	  sysobjects  as t 
	  inner join syscolumns as c on t.id=c.id
	  inner join systypes as n on n.xtype=c.xtype

	  where 
		t.name= @ViewName and n.name <> 'sysname'
	  order by 2,4

	  
	
	declare @SqlListColumn as nvarchar(max)
	set @SqlListColumn=''	

	declare @SqlListselect as nvarchar(max)
	set @SqlListselect=''	

	declare @SqlListDifference as nvarchar(max)
	set @SqlListDifference=' case when '

	--inserisco nella variabile @SqlListColumn la condizione di where per il confronto finale 
	--inserisco nella variabile @SqlListselect tutti i campi con valori ok se combaciano e not ok se non combaciano
	--inserisco nella variabile @SqlListDifference un case che riporta a video solo i cambi di cui  non combaciano i valori
	select 
			@SqlListColumn =  @SqlListColumn + ' ' +  case when n.name = 'ntext' or n.name = 'text' then + ' ( cast (  ISNULL(A.' + C.name + ','''') as nvarchar(max))'  else +  ' (ISNULL(A.' + C.name + ','''')'  end + ' <> ' + case when n.name = 'ntext' or n.name = 'text' then + 'cast (  ISNULL(B.' + C.name + ','''') as nvarchar(max)))'  else +  'ISNULL( B.' + C.name + ',''''))' end +  ' or '
			, @SqlListselect=  @SqlListselect + 'case when ' +  case when n.name = 'ntext' or n.name = 'text' then + 'cast (  ISNULL(A.' + C.name + ','''') as nvarchar(max))'  else +  ' ISNULL(A.' + C.name + ','''')'  end + ' = ' + case when n.name = 'ntext' or n.name = 'text' then + 'cast (  ISNULL(B.' + C.name + ','''') as nvarchar(max))'  else +  'ISNULL( B.' + C.name + ','''')' end + '  then   ''ok'' else   ''not ok''   end   as ' + c.name + ','
			--, @SqlListselect=  @SqlListselect + 'case when ' + case when n.name = 'text' then + 'cast (  ISNULL(A.' + C.name + ','''') as nvarchar(max))'   when n.name = 'ntext' then + 'cast (  ISNULL(A.' + C.name + ','''') as nvarchar(max))'  else +  ' ISNULL(A.' + C.name + ','''')'  end + ' = ' + case when n.name = 'text' then + 'cast (  ISNULL(B.' + C.name + ','''') as nvarchar(max))'  when n.name = 'ntext' then + 'cast (  ISNULL(B.' + C.name + ','''') as nvarchar(max))' else +  ' ISNULL(B.' + C.name + ','''')'  end + '  then   ''ok'' else   ''not ok''   end   as ' + c.name + ','
			, @SqlListDifference =  @SqlListDifference  +  case when n.name = 'ntext' then + 'cast (  ISNULL(A.' + C.name + ','''') as nvarchar(max))'  else +  ' ISNULL(A.' + C.name + ','''')'  end + ' <> ' + case when n.name = 'ntext' then + 'cast (  ISNULL(B.' + C.name + ','''') as nvarchar(max))'  else +  'ISNULL( B.' + C.name + ','''')' end + '  then   '' ' + c.name + ' NOT OK'' when '
	
	FROM sysobjects  as t 
			inner join syscolumns as c on t.id=c.id
			inner join systypes as n on n.xtype=c.xtype
	WHERE t.name=@ViewName and n.name <> 'sysname'


	-- rimuovo da 	@SqlListColumn l'ultimo AND
	set @SqlListColumn = SUBSTRING(@SqlListColumn,1,len(@SqlListColumn)-2)

	-- rimuovo da @SqlListselect l'ultima ,
	set @SqlListselect = SUBSTRING(@SqlListselect,1,len(@SqlListselect)-1)

	--rimuovo da @SqlListDifference l'ultimo then e aggiungo l'end finale per chiudere il case
	set @SqlListDifference = SUBSTRING(@SqlListDifference,1,len(@SqlListDifference)-4)
	set @SqlListDifference = @SqlListDifference + ' end'



	declare @strSQl  nvarchar(max)
	
	-- inserisco i valori recuperati dalla stored nella tabella #temp_controllo
	set @strSQl ='
		SELECT 
		* INTO #temp_controllo
			FROM OPENROWSET(''SQLNCLI'', ''Server=172.16.0.103\afsse103;Uid=afsuser;Pwd=AFS.user!;Database=Aflink_pa_dev'' ,
				''SET NOCOUNT ON; set fmtonly off EXEC Aflink_pa_dev..' + @StoredName 
	

	-- se @nTypeCompare	=1 invochiamo la stored per il documento, altrimenti per la sezione
	if @nTypeCompare = '1' 
		set @strSQl = @strSQl + ' '''''''',' + CAST( @IdDoc as varchar)  + ' ,'+  CAST( @IdPfu as varchar) +' '') '
	else
		set @strSQl = @strSQl + ' '''''''','''''''',' + CAST( @IdDoc as varchar)  +',' +  CAST( @IdPfu as varchar) +' '') '
		
 

	set @strSQl = @strSQl +'		  
			  
	

	--inserisco il tipo e la grandezza delle colonne della stored nella tabella #temp2
	SELECT ''' + 
		@StoredName + ''' as tablename, 
		t.name as nome_colonna,
		max_length as length, 
		n.name as tipo
			
		into #temp2

	FROM tempdb.sys.columns t
			inner join systypes  n on n.xtype=system_type_id
	WHERE 
		object_id = OBJECT_ID(''tempdb..#temp_controllo'')
			



	--effettuo il confronto delle colonne tra vista e stored	
	select 
		t1.nome_colonna --,t1.tipo as tipo_colonna_vista,t2.tipo as tipo_colonna_stored, t1.length as length_vista , t2.length as length_stored
	into #temp_diff
	from #temp1 T1
		left join #temp2 T2 on  T1.nome_colonna=T2.nome_colonna and T1.tipo=T2.tipo and T1.length=T2.length
	where t2.nome_colonna is null 
	



	--ritorno i campi diversi o  mancanti se ci sono
	if  exists (select * from #temp_diff)
	BEGIN
		select * from #temp1 where nome_colonna in (select * from #temp_diff ) order by 2
		select * from #temp2 where nome_colonna in (select * from #temp_diff ) order by 2
	END




	--se non ho differnze di struttura procedo con le differnze di contenuto
	--STEP 2 CONTROLLO CHE I VALORI DELLA VISTA SONO GLI STESSI DELLA STORED
	--join tra vista e tabella output della stored per vedere le righe diverse
	ELSE
	BEGIN
				 
		--confronto i valori della stored con quelli della vista e ritorno come valore ok se combaciano altrimetni not ok
		if not exists(
						select ' + @SqlListselect +	',A.* , B.*
							from  #temp_controllo as A 
								left join ' + @ViewName + ' as B on A.' + @ColIdentity  + '= B.' + @ColIdentity 
								
								+ 
								
								case 
									when @ColIdentity2 <>'' then  + ' and A.' + @ColIdentity2  + '= B.' + @ColIdentity2 
									else + ''
								end 
								+
								
								'



						where ' + @SqlListColumn + '
					) 
		begin	
		if ( '+ cast ( @outputsoloeccezioni as varchar (100) ) + ' <> ''1'')
		begin

			declare @rowView as int
			declare @rowStored as int

			select  @rowstored = count (*) from #temp_controllo
			select  @rowview = count (*) from ' + @ViewName + ' where id= ' +cast ( @IdDoc  as varchar (100) )+ '
				select   ' +cast ( @IdDoc  as varchar (100) )+ ' as IDDOC
						,''Le colonne della vista e della stored hanno lo stesso TYPE e LENGTH'' as ESITO_STRUTTURA_COLONNE 
						,''I valori contenuti dalle colonne della vista e della stored sono identici'' as ESITO_VALORI
						,  @rowstored as RECORD_PRESENTI_CON_ESECUZIONE_STORED
						,  @rowview AS  RECORD_PRESENTI_CON_ESECUZIONE_VIEW
		end		
		end
		else
		begin
			select   ' + @SqlListselect +	',A.* , B.*
				from  #temp_controllo as A 
					left join ' + @ViewName + ' as B on A.' + @ColIdentity  + '= B.' + @ColIdentity + '
			
		end
	END
			  
'
	--select @strSQl
	exec  (@strSQl) 
	
	
		
END






GO
