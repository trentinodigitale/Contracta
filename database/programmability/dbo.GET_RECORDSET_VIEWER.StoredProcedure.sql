USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_RECORDSET_VIEWER]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[GET_RECORDSET_VIEWER]( @TableName as varchar(1000) , @Top as varchar (100) , @Filter as nvarchar(max) , @Owner as varchar( 200 )  , @FilterHide as nvarchar(max) , @OrderBy as nvarchar (1000) , @Parametri as varchar (max) , @idpfu as varchar(10) )
AS
BEGIN	

	set nocount on

	declare @ColumnList varchar(max)
	declare @SQL varchar(max)
	declare @Modello varchar(1000)
	declare @Identity varchar(1000)
	declare @All_Column varchar(10)
	declare @RowCondition varchar(1000)
	declare @nPos as int
	declare @SingleCondition as varchar(500)
	declare @strCond as varchar(500)
	declare @List_Col_Cond as varchar(500)
	declare @strCol as varchar(500)
	set @List_Col_Cond= ''

	set @All_Column =''

	set @Modello = dbo.GetValue( 'MODELLO'  ,   @Parametri )
	set @Identity = dbo.GetValue( 'IDENTITY'  ,   @Parametri )
	set @All_Column = dbo.GetValue( 'ALL_COLUMN'  ,   @Parametri )
	set @RowCondition = dbo.GetValue( 'ROWCONDITION'  ,   @Parametri )
	

	--set @All_Column='YES'
	set @ColumnList = ' '
	
	--se diverso da yes recupero le colonne del modello
	if upper(@All_Column) <> 'YES'  and @Modello <> ''
	begin
		
		
		--controllo se il modello presente nella LIB_Models oppure nella ctl_models
		if exists (select id  from LIB_Models with (nolock) where mod_id=@Modello)
		begin
			-- dal nome del modello determino le colonne utili
			select 
				@ColumnList  = @ColumnList    +  c.name + ' , '
				from syscolumns c
					inner join sysobjects o on o.id = c.id
					inner join systypes s on c.xusertype = s.xusertype
					inner join LIB_ModelAttributes a with(nolock) on c.name = MA_DZT_Name and a.MA_MOD_ID = @Modello
				where 
					o.name = @TableName
		end
		else
		begin
			select 
				@ColumnList  = @ColumnList    +  c.name + ' , '
				from syscolumns c
					inner join sysobjects o on o.id = c.id
					inner join systypes s on c.xusertype = s.xusertype
					inner join CTL_ModelAttributes a with(nolock) on c.name = MA_DZT_Name and a.MA_MOD_ID = @Modello
				where 
					o.name = @TableName
		end


		

	end



	-- tolgo l'ultima virgola
	if rtrim( @ColumnList ) = ''
		set @ColumnList = ' * ' 
	else
	begin

		set @ColumnList = LEFT( @ColumnList , LEN(@ColumnList ) - 2)

		if CHARINDEX( ' ' + @Identity + ' ' , @ColumnList ) = 0 
			set @ColumnList =  @ColumnList + ' , ' + @Identity
		

		
		--per adesso per queste table/view aggiungiamo la colonna bread perchè
		--configurata sul viewer la ROWCONDITION e unica utilizzata 
		--if @TableName in (  
		--					'DASHBOARD_VIEW_BANDI_FORN_SERV_PRIV',
		--					'DASHBOARD_VIEW_BANDI_LAVORI_PRIV',
		--					'DASHBOARD_VIEW_BANDILAVORIPRIVATI',
		--					'DASHBOARD_VIEW_COMUNICAZIONI_FORNITORI',
		--					'DASHBOARD_VIEW_ISCRIZIONE_SDA',
		--					'MSG_LINKED_ATTI_GARA',
		--					'MSG_LINKED_COMUNICAZIONI_ALBO',
		--					'MSG_LINKED_COMUNICAZIONI_LAVORITELEMATICI',
		--					'MSG_LINKED_CONSULTAZIONE_BANDO',
		--					'MSG_LINKED_DOCUMENTI_INDIRETTI',
		--					'MSG_LINKED_ISCRIZIONE_ALBO',
		--					'MSG_LINKED_NUOVIQUESITI'
		--			    )
		--begin
		--	set @ColumnList =  @ColumnList + ' , bread ' 
		--end

		--controllo se esite il parametro ROWCONDITION per aggiungere alla select
		--le colonne necessarie alla valutazione
		--ROWCONDITION=NOTREAD,bread=1~......
		if @RowCondition <> '' 
		begin

			--sotituisco gli operatori gestiti =,<,> con @@@
			set @RowCondition = replace(@RowCondition,'=','@@@')
			set @RowCondition = replace(@RowCondition,'<','@@@')
			set @RowCondition = replace(@RowCondition,'>','@@@')
		 
			
			--ricavo le condizioni (sono separate da ~)
			--e da ognuno ricavo la colonna da aggiungere 
			select items into #t   from dbo.Split(@RowCondition ,'~')

			DECLARE crsCondition CURSOR STATIC FOR 
				
				select * from #t

			OPEN crsCondition

			FETCH NEXT FROM crsCondition INTO @SingleCondition
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--cerco la ',' che separa la classe dalla condizione di valutazione
				set @nPos = 0
				set @nPos=charindex(',',@SingleCondition)

				if @nPos > 0 
				begin
					--recupero la condizione
					set @strCond  = SUBSTRING (@SingleCondition,@nPos+1,len(@SingleCondition))
					if @strCond <> ''
					begin

						set @nPos = 0
						--cerco operatore @@@
						set @nPos = charindex('@@@',@strCond)
						if @nPos > 0 
						begin

							set @strCol = rtrim(ltrim(SUBSTRING (@strCond,1,@nPos-1)))
						
							--se la colonna non è presente nella lista delle colonne la aggiungo
							if charindex( ' , ' + @strCol + ' , ' , ' , ' + @ColumnList + ' , ') = 0
							begin
								set @ColumnList = @ColumnList + ' , ' + @strCol
							end

						end 
					end
				end

			FETCH NEXT FROM crsCondition INTO @SingleCondition
			END

			CLOSE crsCondition 
			DEALLOCATE crsCondition 
			
			

		end
		
	end


	If @Top =  '' 
		set @SQL = 'select ' + @ColumnList + ' from ' +  @TableName
    Else
		set @SQL = 'select top ' + @Top + ' ' + @ColumnList + ' from ' +  @TableName

	set @SQL = @SQL  + ' with (nolock) '

	If @Filter <> ''
	begin
		set @SQL = @SQL + ' where ' + @Filter

		IF @Owner <> '' 
			set @SQL = @SQL + ' AND  ' + @Owner + ' = ''' + @idpfu + ''' '

	end
	else
		IF @Owner <> '' 
			set @SQL = @SQL + ' where  ' + @Owner + ' = ''' + @idpfu + ''' '

        
    -- accoda alla query il filtro implicito non visibile
    
	if @FilterHide <> '' 
		if CHARINDEX( ' where ' , @SQL ) = 0 
			set @SQL = @SQL + ' where  ( ' + @FilterHide + ' ) '
		else
			set @SQL = @SQL + ' and  ( ' + @FilterHide + ' ) '

        
	-- accoda le condizione di sort ( forse )
	if RTRIM(ltrim(@OrderBy)) <> '' 
		set @SQL = @SQL + ' order by ' + @OrderBy

	--per alcune viste aggiungiamo opzione per non parallelizzare la query
	if @TableName in ( 'DASHBOARD_VIEW_BANDOUNICO')
		set @SQL = @SQL + ' option (maxdop 1) '

	exec( @SQL )
	--print ( @SQL )

end

	

GO
